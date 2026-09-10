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

Write-Host "AlphaVoice E0-S1 API shell validation"
Write-Host "API root: $apiRoot"
Write-Host ""

# AC-3: ASP.NET Core project must exist and target the approved stable LTS TFM.
$projectFiles = @(
    Get-ChildItem `
        -LiteralPath $apiRoot `
        -Filter "*.csproj" `
        -File `
        -ErrorAction SilentlyContinue
)

if ($projectFiles.Count -ne 1) {
    Add-Failure "Expected exactly one .csproj directly under apps/api"
}

$programPath = Join-Path $apiRoot "Program.cs"

if (-not (Test-Path -LiteralPath $programPath -PathType Leaf)) {
    Add-Failure "Missing apps/api/Program.cs"
}

if ($projectFiles.Count -eq 1) {
    $projectPath = $projectFiles[0].FullName

    try {
        [xml]$projectXml = Get-Content `
            -LiteralPath $projectPath `
            -Raw
    }
    catch {
        Add-Failure "API .csproj is not valid XML"
        $projectXml = $null
    }

    if ($null -ne $projectXml) {
        if ($projectXml.Project.Sdk -ne "Microsoft.NET.Sdk.Web") {
            Add-Failure "API project must use Microsoft.NET.Sdk.Web"
        }

        $targetFramework = [string]$projectXml.Project.PropertyGroup.TargetFramework

        if ($targetFramework -ne "net10.0") {
            Add-Failure "API project must target net10.0; found '$targetFramework'"
        }

        # E0-S1 should not need DB/auth/broker/cache infrastructure packages.
        $prohibitedPackagePatterns = @(
            "StackExchange.Redis",
            "RabbitMQ",
            "Kafka"
        )

        $packageReferences = @(
            $projectXml.SelectNodes("//PackageReference")
        )

        foreach ($packageReference in $packageReferences) {
            $packageName = [string]$packageReference.Include

            foreach ($pattern in $prohibitedPackagePatterns) {
                if ($packageName -match [regex]::Escape($pattern)) {
                    Add-Failure "Prohibited E0-S1 package reference: $packageName"
                }
            }
        }
    }
}

# D43: don't establish global horizontal layers in the API host.
$prohibitedApiDirectories = @(
    "Controllers",
    "Services",
    "Repositories"
)

foreach ($directory in $prohibitedApiDirectories) {
    $fullPath = Join-Path $apiRoot $directory

    if (Test-Path -LiteralPath $fullPath) {
        Add-Failure "Prohibited API organization exists: apps/api/$directory"
    }
}

# AC-6: bootstrap must not leave framework sample/domain behavior behind.
if (Test-Path -LiteralPath $programPath -PathType Leaf) {
    $programContent = Get-Content `
        -LiteralPath $programPath `
        -Raw

    $prohibitedProgramPatterns = @(
        "WeatherForecast",
        "AddAuthentication",
        "AddAuthorization",
        "\.MapGet\s*\(",
        "\.MapPost\s*\(",
        "\.MapPut\s*\(",
        "\.MapPatch\s*\(",
        "\.MapDelete\s*\("
    )

    foreach ($pattern in $prohibitedProgramPatterns) {
        if ($programContent -match $pattern) {
            Add-Failure "Program.cs contains behavior outside the minimal E0-S1 API host shell: $pattern"
        }
    }
}

Write-Host "ASP.NET Core project, target framework, dependencies, and host boundaries checked."
Write-Host ""

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure is expected before the E0-S1 API shell is implemented."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0