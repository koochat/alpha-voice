$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$readmePath = Join-Path $repoRoot "README.md"

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $failures.Add($Message)
}

Write-Host "AlphaVoice E0-S2 PostgreSQL developer documentation validation"
Write-Host "README: $readmePath"
Write-Host ""

if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
    Add-Failure "Missing repository-level README.md"
}
else {
    $content = Get-Content -LiteralPath $readmePath -Raw

    $requiredContent = @(
        "ALPHAVOICE_POSTGRES_PASSWORD",
        "dotnet user-secrets",
        "ConnectionStrings:AlphaVoice",
        "docker compose",
        "infra\containers\postgres.compose.yml",
        "dotnet tool restore",
        "dotnet tool run dotnet-ef database update",
        "controlled migration",
        "down -v",
        "smoke-postgres-fresh-db.ps1"
    )

    foreach ($item in $requiredContent) {
        if (-not $content.Contains($item)) {
            Add-Failure "README.md is missing PostgreSQL developer guidance: $item"
        }
    }

    $applyMigrationsIndex =
        $content.IndexOf("### Apply migrations")

    $startApiIndex =
        $content.IndexOf("### Start API")

    if ($applyMigrationsIndex -lt 0) {
        Add-Failure "README.md is missing the Apply migrations section"
    }

    if ($startApiIndex -lt 0) {
        Add-Failure "README.md is missing the Start API section"
    }

    if ($applyMigrationsIndex -ge 0 -and
        $startApiIndex -ge 0 -and
        $startApiIndex -le $applyMigrationsIndex) {
        Add-Failure "README.md must document PostgreSQL migration before local API startup"
    }

    if ($startApiIndex -ge 0) {
        $startApiSection = $content.Substring($startApiIndex)

        if (-not $startApiSection.Contains(
            '$env:ASPNETCORE_ENVIRONMENT = "Development"'
        )) {
            Add-Failure "Local API startup must explicitly use the Development environment"
        }

        if (-not $startApiSection.Contains(
            'dotnet run --project .\apps\api\AlphaVoice.Api.csproj'
        )) {
            Add-Failure "Local API startup command is missing"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0
