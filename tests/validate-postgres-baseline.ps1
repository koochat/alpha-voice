$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$apiRoot = Join-Path $repoRoot "apps\api"

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $failures.Add($Message)
}

Write-Host "AlphaVoice E0-S2 PostgreSQL baseline validation"
Write-Host "Repository root: $repoRoot"
Write-Host ""

$composePath = Join-Path $repoRoot "infra\containers\postgres.compose.yml"
$projectPath = Join-Path $apiRoot "AlphaVoice.Api.csproj"
$programPath = Join-Path $apiRoot "Program.cs"
$dbContextPath = Join-Path $apiRoot "Database\AlphaVoiceDbContext.cs"
$migrationsPath = Join-Path $apiRoot "Database\Migrations"

# AC-1: repo-owned containerized PostgreSQL definition.
if (-not (Test-Path -LiteralPath $composePath -PathType Leaf)) {
    Add-Failure "Missing infra/containers/postgres.compose.yml"
}
else {
    $composeContent = Get-Content -LiteralPath $composePath -Raw

    if ($composeContent -notmatch "postgres") {
        Add-Failure "PostgreSQL compose file does not define a postgres service/image"
    }

    if ($composeContent -notmatch '\$\{ALPHAVOICE_POSTGRES_PASSWORD') {
        Add-Failure "PostgreSQL password must come from ALPHAVOICE_POSTGRES_PASSWORD rather than a committed secret"
    }
}

# AC-2 / AC-3: EF Core + PostgreSQL provider + local secret mechanism.
if (-not (Test-Path -LiteralPath $projectPath -PathType Leaf)) {
    Add-Failure "Missing apps/api/AlphaVoice.Api.csproj"
}
else {
    [xml]$projectXml = Get-Content -LiteralPath $projectPath -Raw

    $packageNames = @(
        $projectXml.SelectNodes("//PackageReference") |
            ForEach-Object { [string]$_.Include }
    )

    if ($packageNames -notcontains "Npgsql.EntityFrameworkCore.PostgreSQL") {
        Add-Failure "Missing Npgsql.EntityFrameworkCore.PostgreSQL package reference"
    }

    if ($packageNames -notcontains "Microsoft.EntityFrameworkCore.Design") {
        Add-Failure "Missing Microsoft.EntityFrameworkCore.Design package reference"
    }

    $userSecretsId = [string]$projectXml.Project.PropertyGroup.UserSecretsId

    if ([string]::IsNullOrWhiteSpace($userSecretsId)) {
        Add-Failure "API project does not define UserSecretsId for local development secrets"
    }

    if ($packageNames -contains "Microsoft.EntityFrameworkCore.InMemory") {
        Add-Failure "In-memory EF provider must not be used as E0-S2 PostgreSQL evidence"
    }
}

if (-not (Test-Path -LiteralPath $dbContextPath -PathType Leaf)) {
    Add-Failure "Missing apps/api/Database/AlphaVoiceDbContext.cs"
}

if (-not (Test-Path -LiteralPath $migrationsPath -PathType Container)) {
    Add-Failure "Missing apps/api/Database/Migrations baseline"
}
else {
    $migrationFiles = @(
        Get-ChildItem `
            -LiteralPath $migrationsPath `
            -Filter "*.cs" `
            -File `
            -ErrorAction SilentlyContinue
    )

    if ($migrationFiles.Count -eq 0) {
        Add-Failure "No EF Core migration artifacts found"
    }
    else {
        foreach ($migrationFile in $migrationFiles) {
            $migrationContent = Get-Content `
                -LiteralPath $migrationFile.FullName `
                -Raw
            if ($migrationContent -match "\.CreateTable\s*\(") {
                Add-Failure "E0-S2 baseline migration must not create business tables: $($migrationFile.Name)"
            }
        }
    }
}

# AC-5: API startup must not silently apply schema migrations.
if (Test-Path -LiteralPath $programPath -PathType Leaf) {
    $programContent = Get-Content -LiteralPath $programPath -Raw

    if ($programContent -notmatch "UseNpgsql") {
        Add-Failure "API is not wired to PostgreSQL through UseNpgsql"
    }

    $prohibitedStartupPatterns = @(
        "\.Migrate\s*\(",
        "\.MigrateAsync\s*\(",
        "\.EnsureCreated\s*\(",
        "\.EnsureCreatedAsync\s*\("
    )

    foreach ($pattern in $prohibitedStartupPatterns) {
        if ($programContent -match $pattern) {
            Add-Failure "API startup contains uncontrolled database schema mutation: $pattern"
        }
    }

    if ($programContent -match "UseInMemoryDatabase") {
        Add-Failure "API uses an in-memory database instead of PostgreSQL"
    }
}

# Secrets must not appear in committed API JSON configuration.
$configFiles = @(
    (Join-Path $apiRoot "appsettings.json")
    (Join-Path $apiRoot "appsettings.Development.json")
)

foreach ($configFile in $configFiles) {
    if (Test-Path -LiteralPath $configFile -PathType Leaf) {
        $configContent = Get-Content -LiteralPath $configFile -Raw

        if ($configContent -match "(?i)Password\s*=") {
            Add-Failure "Committed configuration appears to contain a database password: $configFile"
        }
    }
}

Write-Host "Container, EF Core, PostgreSQL, migration, and secret boundaries checked."
Write-Host ""

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure is expected before E0-S2 PostgreSQL baseline implementation."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0