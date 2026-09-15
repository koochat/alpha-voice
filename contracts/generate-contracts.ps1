$ErrorActionPreference = "Stop"

$contractsRoot = $PSScriptRoot
$repoRoot = Split-Path -Parent $contractsRoot

$apiProject = Join-Path $repoRoot "apps/api/AlphaVoice.Api.csproj"
$openApiDirectory = Join-Path $repoRoot "apps/api/obj/openapi"
$openApiPath = Join-Path $openApiDirectory "AlphaVoice.Api.json"

$generatedDirectory = Join-Path $contractsRoot "generated"
$generatedPath = Join-Path $generatedDirectory "alphaVoiceApi.generated.ts"

function Invoke-DotNet {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments
    )

    & dotnet @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

Write-Host "AlphaVoice contract generation"
Write-Host "Repository root: $repoRoot"
Write-Host ""

Push-Location $repoRoot

try {
    Invoke-DotNet @("tool", "restore")
    Invoke-DotNet @("restore", $apiProject)

    if (Test-Path $openApiDirectory) {
        Remove-Item $openApiDirectory -Recurse -Force
    }

    Invoke-DotNet @(
        "build",
        $apiProject,
        "--no-restore",
        "--no-incremental"
    )

    if (-not (Test-Path $openApiPath)) {
        throw "Expected OpenAPI document was not generated: $openApiPath"
    }

    New-Item `
        -ItemType Directory `
        -Path $generatedDirectory `
        -Force |
        Out-Null

    if (Test-Path $generatedPath) {
        Remove-Item $generatedPath -Force
    }

    Invoke-DotNet @(
        "tool",
        "run",
        "nswag",
        "openapi2tsclient",
        "/input:$openApiPath",
        "/output:$generatedPath",
        "/template:Fetch",
        "/typeScriptVersion:5.0"
    )

    if (-not (Test-Path $generatedPath)) {
        throw "Expected TypeScript contract artifact was not generated: $generatedPath"
    }

    # Keep generated output deterministic across Windows/Linux CI.
    $generatedContent =
        [System.IO.File]::ReadAllText($generatedPath).
            Replace("`r`n", "`n")

    [System.IO.File]::WriteAllText(
        $generatedPath,
        $generatedContent,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host ""
    Write-Host "Generated:"
    Write-Host " - $openApiPath"
    Write-Host " - $generatedPath"
    Write-Host ""
    Write-Host "CONTRACT GENERATION PASSED"
}
finally {
    Pop-Location
}