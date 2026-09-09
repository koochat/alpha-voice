$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$webRoot = Join-Path $repoRoot "apps\web"

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $failures.Add($Message)
}

Write-Host "AlphaVoice E0-S1 web shell validation"
Write-Host "Web root: $webRoot"
Write-Host ""

$packageJsonPath = Join-Path $webRoot "package.json"
$tsconfigPath = Join-Path $webRoot "tsconfig.json"

if (-not (Test-Path -LiteralPath $packageJsonPath -PathType Leaf)) {
    Add-Failure "Missing apps/web/package.json"
}

if (-not (Test-Path -LiteralPath $tsconfigPath -PathType Leaf)) {
    Add-Failure "Missing apps/web/tsconfig.json"
}

if (Test-Path -LiteralPath $packageJsonPath -PathType Leaf) {
    try {
        $packageJson = Get-Content `
            -LiteralPath $packageJsonPath `
            -Raw |
            ConvertFrom-Json
    }
    catch {
        Add-Failure "apps/web/package.json is not valid JSON"
        $packageJson = $null
    }

    if ($null -ne $packageJson) {
        $requiredDependencies = @(
            "next",
            "react",
            "react-dom"
        )

        foreach ($dependency in $requiredDependencies) {
            if ($null -eq $packageJson.dependencies.$dependency) {
                Add-Failure "Missing required web dependency: $dependency"
            }
        }

        if ($null -eq $packageJson.devDependencies.typescript) {
            Add-Failure "Missing TypeScript dev dependency"
        }

        if ($null -eq $packageJson.scripts.build) {
            Add-Failure "Missing npm script: build"
        }

        if ($null -eq $packageJson.scripts.lint) {
            Add-Failure "Missing npm script: lint"
        }

        if ($null -eq $packageJson.scripts.typecheck) {
           Add-Failure "Missing npm script: typecheck"
        }
        elseif ([string]$packageJson.scripts.typecheck -notmatch "^\s*next\s+typegen\s*&&\s*tsc\s+--noEmit\s*$") {
           Add-Failure "Web typecheck must run 'next typegen' before 'tsc --noEmit'"
        }
    }
}

Write-Host "Required Web manifest and TypeScript configuration checked."
Write-Host ""

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure is expected before the E0-S1 Web shell is implemented."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0
