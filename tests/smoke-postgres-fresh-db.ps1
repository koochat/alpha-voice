$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$composePath = Join-Path $repoRoot "infra\containers\postgres.compose.yml"
$apiProject = Join-Path $repoRoot "apps\api\AlphaVoice.Api.csproj"

$containerName = "alphavoice-postgres-smoke-$PID"

$oldConnectionString = $env:ConnectionStrings__AlphaVoice
$oldAspNetEnvironment = $env:ASPNETCORE_ENVIRONMENT

function Get-FreeTcpPort {
    $listener = [System.Net.Sockets.TcpListener]::new(
        [System.Net.IPAddress]::Loopback,
        0
    )

    $listener.Start()

    try {
        return ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port
    }
    finally {
        $listener.Stop()
    }
}

function Invoke-DockerExecSql {
    param(
        [Parameter(Mandatory)]
        [string]$Sql
    )

    $output = $Sql |
        docker exec -i $containerName `
        psql `
        -X `
        -v ON_ERROR_STOP=1 `
        -U alphavoice `
        -d alphavoice `
        -tA

    if ($LASTEXITCODE -ne 0) {
        throw "PostgreSQL query failed."
    }

    return @($output)
}

try {
    if (-not (Test-Path -LiteralPath $composePath -PathType Leaf)) {
        throw "Missing PostgreSQL compose definition: $composePath"
    }

    $composeContent = Get-Content `
        -LiteralPath $composePath `
        -Raw

    $imageMatch = [regex]::Match(
        $composeContent,
        "(?m)^\s*image:\s*(?<image>\S+)\s*$"
    )

    if (-not $imageMatch.Success) {
        throw "Could not determine PostgreSQL image from compose definition."
    }

    $postgresImage = $imageMatch.Groups["image"].Value

    if ($postgresImage -eq "postgres:latest") {
        throw "PostgreSQL smoke test refuses an unpinned latest image."
    }

    $port = Get-FreeTcpPort

    $passwordBytes = New-Object byte[] 24

    $rng =
        [System.Security.Cryptography.RandomNumberGenerator]::Create()

    try {
        $rng.GetBytes($passwordBytes)
    }
    finally {
        $rng.Dispose()
    }

    $password =
        [Convert]::ToBase64String($passwordBytes)

    Write-Host "AlphaVoice E0-S2 fresh PostgreSQL smoke test"
    Write-Host "Image: $postgresImage"
    Write-Host "Host port: $port"
    Write-Host ""

    Write-Host "Starting disposable PostgreSQL container..."

    docker run `
        --detach `
        --rm `
        --name $containerName `
        --env POSTGRES_USER=alphavoice `
        --env POSTGRES_PASSWORD=$password `
        --env POSTGRES_DB=alphavoice `
        --publish "${port}:5432" `
        $postgresImage | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Could not start disposable PostgreSQL container."
    }

    Write-Host "Waiting for PostgreSQL readiness..."

    $ready = $false

    for ($attempt = 1; $attempt -le 30; $attempt++) {
        docker exec $containerName `
            pg_isready `
            -U alphavoice `
            -d alphavoice *> $null

        if ($LASTEXITCODE -eq 0) {
            $ready = $true
            break
        }

        Start-Sleep -Seconds 2
    }

    if (-not $ready) {
        throw "PostgreSQL did not become ready within 60 seconds."
    }

    Write-Host "PostgreSQL is ready."

    $tablesBefore = @(
        Invoke-DockerExecSql `
            "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            } |
            ForEach-Object {
                ([string]$_).Trim()
            }
    )

    if ($tablesBefore.Count -ne 0) {
        throw "Fresh PostgreSQL database unexpectedly contains public tables."
    }

    Write-Host "Fresh database verified."

    $env:ConnectionStrings__AlphaVoice =
        "Host=localhost;Port=$port;Database=alphavoice;Username=alphavoice;Password=$password"

    $env:ASPNETCORE_ENVIRONMENT = "Production"

    Write-Host "Applying EF Core migration chain..."

    dotnet tool run dotnet-ef database update `
        --project $apiProject `
        --startup-project $apiProject

    if ($LASTEXITCODE -ne 0) {
        throw "EF Core migration application failed."
    }

    $migrationIds = @(
        Invoke-DockerExecSql `
            'SELECT "MigrationId" FROM "__EFMigrationsHistory" ORDER BY "MigrationId";' |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            } |
            ForEach-Object {
                ([string]$_).Trim()
            }
    )

    if ($migrationIds.Count -ne 1) {
        throw "Expected exactly one migration history row; found $($migrationIds.Count)."
    }

    if ($migrationIds[0] -notmatch "InitialPostgresBaseline$") {
        throw "Unexpected migration history entry: $($migrationIds[0])"
    }

    $tablesAfter = @(
        Invoke-DockerExecSql `
            "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" |
            Where-Object {
                -not [string]::IsNullOrWhiteSpace($_)
            } |
            ForEach-Object {
                ([string]$_).Trim()
            }
    )

    if ($tablesAfter.Count -ne 1 -or
        $tablesAfter[0] -ne "__EFMigrationsHistory") {
        throw "Baseline migration created unexpected public tables: $($tablesAfter -join ', ')"
    }

    Write-Host "Migration history verified."
    Write-Host "No business tables created."

    Write-Host "Re-applying migration chain to verify idempotency..."

    dotnet tool run dotnet-ef database update `
        --project $apiProject `
        --startup-project $apiProject

    if ($LASTEXITCODE -ne 0) {
        throw "Second EF Core migration application failed."
    }

    Write-Host ""
    Write-Host "SMOKE TEST PASSED"
}
finally {
    if (docker ps -a `
        --filter "name=^/${containerName}$" `
        --format "{{.Names}}" |
        Select-String -SimpleMatch $containerName) {

        Write-Host "Removing disposable PostgreSQL container..."

        docker rm -f $containerName *> $null
    }

    if ($null -eq $oldConnectionString) {
        Remove-Item Env:ConnectionStrings__AlphaVoice `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:ConnectionStrings__AlphaVoice =
            $oldConnectionString
    }

    if ($null -eq $oldAspNetEnvironment) {
        Remove-Item Env:ASPNETCORE_ENVIRONMENT `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:ASPNETCORE_ENVIRONMENT =
            $oldAspNetEnvironment
    }
}