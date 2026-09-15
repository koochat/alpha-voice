$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$generationScript = Join-Path $repoRoot "contracts/generate-contracts.ps1"
$generatedPath = Join-Path $repoRoot "contracts/generated/alphaVoiceApi.generated.ts"

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    $script:failures.Add($Message)
}

function Get-NormalizedText {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    return [System.IO.File]::ReadAllText($Path).
        Replace("`r`n", "`n").
        Replace("`r", "`n")
}

Write-Host "AlphaVoice E0-S4 contract drift validation"
Write-Host "Repository root: $repoRoot"
Write-Host ""

if (-not (Test-Path $generationScript)) {
    Add-Failure "Missing contract generation script: $generationScript"
}

if (-not (Test-Path $generatedPath)) {
    Add-Failure "Missing generated TypeScript contract artifact: $generatedPath"
}

if ($failures.Count -eq 0) {
    $originalBytes = [System.IO.File]::ReadAllBytes($generatedPath)
    $originalContent = Get-NormalizedText $generatedPath

    try {
        & $generationScript

        if (-not (Test-Path $generatedPath)) {
            throw "Generated contract artifact was not produced: $generatedPath"
        }

        $regeneratedContent = Get-NormalizedText $generatedPath

        if ($originalContent -cne $regeneratedContent) {
            Add-Failure (
                "Generated contract drift detected. " +
                "Run .\contracts\generate-contracts.ps1 and commit the regenerated artifact."
            )
        }
    }
    catch {
        Add-Failure "Contract generation failed: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $originalBytes) {
            [System.IO.File]::WriteAllBytes(
                $generatedPath,
                $originalBytes
            )
        }
    }
}

Write-Host ""
Write-Host "Generated TypeScript contract compared with fresh ASP.NET OpenAPI generation."
Write-Host ""

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