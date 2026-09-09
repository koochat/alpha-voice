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

Write-Host "AlphaVoice E0-S1 developer documentation validation"
Write-Host "README: $readmePath"
Write-Host ""

if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
    Add-Failure "Missing repository-level README.md"
}
else {
    $content = Get-Content -LiteralPath $readmePath -Raw

    $requiredCommands = @(
        "npm ci --prefix .\apps\web",
        "npm run typecheck --prefix .\apps\web",
        "npm run lint --prefix .\apps\web",
        "npm run build --prefix .\apps\web",
        "dotnet restore .\apps\api\AlphaVoice.Api.csproj",
        "dotnet build .\apps\api\AlphaVoice.Api.csproj --no-restore"
    )

    foreach ($command in $requiredCommands) {
        if (-not $content.Contains($command)) {
            Add-Failure "README.md is missing developer command: $command"
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure is expected before E0-S1 developer documentation is completed."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0