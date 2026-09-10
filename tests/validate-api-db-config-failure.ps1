$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$apiProject = Join-Path $repoRoot "apps\api\AlphaVoice.Api.csproj"
$apiDll = Join-Path $repoRoot "apps\api\bin\Debug\net10.0\AlphaVoice.Api.dll"

$oldAspNetEnvironment = $env:ASPNETCORE_ENVIRONMENT
$oldDotNetEnvironment = $env:DOTNET_ENVIRONMENT
$oldConnectionString = $env:ConnectionStrings__AlphaVoice

$process = $null

try {
    # Force a non-Development environment so User Secrets are not loaded.
    $env:ASPNETCORE_ENVIRONMENT = "Production"
    $env:DOTNET_ENVIRONMENT = "Production"

    Remove-Item Env:ConnectionStrings__AlphaVoice `
        -ErrorAction SilentlyContinue

    Write-Host "AlphaVoice E0-S2 missing database configuration validation"
    Write-Host ""

    dotnet build $apiProject --nologo

    if ($LASTEXITCODE -ne 0) {
        throw "API build failed before missing-configuration validation."
    }

    if (-not (Test-Path -LiteralPath $apiDll -PathType Leaf)) {
        throw "Expected API build output was not found: $apiDll"
    }

    $startInfo =
        New-Object System.Diagnostics.ProcessStartInfo

    $startInfo.FileName = "dotnet"
    $startInfo.Arguments = "`"$apiDll`""
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process =
        New-Object System.Diagnostics.Process

    $process.StartInfo = $startInfo

    if (-not $process.Start()) {
        throw "Could not start API process for missing-configuration validation."
    }

    # The API must fail quickly when required DB configuration is absent.
    $exited = $process.WaitForExit(10000)

    if (-not $exited) {
        try {
            $process.Kill()
            $process.WaitForExit()
        }
        catch {
            # Best-effort termination; the validation will still fail below.
        }

        throw "API remained running without required database configuration instead of failing within 10 seconds."
    }

    # Process has exited, so redirected streams can now be read completely.
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()

    $text = @(
        $stdout
        $stderr
    ) -join [Environment]::NewLine

    if ($process.ExitCode -eq 0) {
        throw "API unexpectedly exited successfully without required database configuration."
    }

    if ($text -notmatch "Connection string 'AlphaVoice' is required") {
        throw "API failed without the expected bounded database configuration message."
    }

    if ($text -match "(?i)Password=") {
        throw "API failure output appears to expose a database password."
    }

    Write-Host "Missing database configuration failed as expected."
    Write-Host "Failure occurred within the bounded timeout."
    Write-Host "No database password was exposed."
    Write-Host ""
    Write-Host "VALIDATION PASSED"
}
finally {
    if ($null -ne $process) {
        try {
            if (-not $process.HasExited) {
                $process.Kill()
                $process.WaitForExit()
            }
        }
        catch {
            # Best-effort cleanup only.
        }

        $process.Dispose()
    }

    if ($null -eq $oldAspNetEnvironment) {
        Remove-Item Env:ASPNETCORE_ENVIRONMENT `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:ASPNETCORE_ENVIRONMENT =
            $oldAspNetEnvironment
    }

    if ($null -eq $oldDotNetEnvironment) {
        Remove-Item Env:DOTNET_ENVIRONMENT `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:DOTNET_ENVIRONMENT =
            $oldDotNetEnvironment
    }

    if ($null -eq $oldConnectionString) {
        Remove-Item Env:ConnectionStrings__AlphaVoice `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:ConnectionStrings__AlphaVoice =
            $oldConnectionString
    }
}