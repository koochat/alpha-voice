$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$failures = [System.Collections.Generic.List[string]]::new()

function Assert-DirectoryExists {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $fullPath = Join-Path $repoRoot $RelativePath

    if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        $failures.Add("Missing required directory: $RelativePath")
    }
}

function Assert-PathDoesNotExist {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )

    $fullPath = Join-Path $repoRoot $RelativePath

    if (Test-Path -LiteralPath $fullPath) {
        $failures.Add("Prohibited repository structure exists: $RelativePath")
    }
}

Write-Host "AlphaVoice E0-S1 repository structure validation"
Write-Host "Repository root: $repoRoot"
Write-Host ""

# AC-1: required structured-monorepo boundaries.
$requiredDirectories = @(
    "apps/web",
    "apps/api",
    "backend/modules",
    "tests",
    "contracts/generated",
    "infra",
    "docs"
)

foreach ($directory in $requiredDirectories) {
    Assert-DirectoryExists -RelativePath $directory
}

# AC-5: backend must not default to global horizontal-layer folders.
$prohibitedBackendDirectories = @(
    "backend/Controllers",
    "backend/Services",
    "backend/Repositories"
)

foreach ($directory in $prohibitedBackendDirectories) {
    Assert-PathDoesNotExist -RelativePath $directory
}

Write-Host "Required repository boundaries checked: $($requiredDirectories.Count)"
Write-Host "Prohibited backend boundaries checked: $($prohibitedBackendDirectories.Count)"
Write-Host ""

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure is expected before E0-S1 scaffolding is implemented."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0