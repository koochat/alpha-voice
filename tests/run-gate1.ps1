$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$apiProject = Join-Path $repoRoot "apps/api/AlphaVoice.Api.csproj"
$webRoot = Join-Path $repoRoot "apps/web"
$contractDriftScript = Join-Path $repoRoot "tests/validate-contract-drift.ps1"

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [scriptblock] $Command
    )

    Write-Host ""
    Write-Host "===== $Name ====="

    & $Command

    if ($LASTEXITCODE -ne 0) {
        throw "$Name failed with exit code $LASTEXITCODE."
    }
}

Write-Host "AlphaVoice E0-S4 deterministic Gate 1"
Write-Host "Repository root: $repoRoot"

Push-Location $repoRoot

try {
    Invoke-CheckedCommand "Restore repository-local .NET tools" {
        dotnet tool restore
    }

    Invoke-CheckedCommand "Restore ASP.NET Core API" {
        dotnet restore $apiProject
    }

    Invoke-CheckedCommand "Build ASP.NET Core API" {
        dotnet build $apiProject --no-restore
    }

    $testProjects = @(
        Get-ChildItem `
            (Join-Path $repoRoot "apps"), `
            (Join-Path $repoRoot "backend"), `
            (Join-Path $repoRoot "tests") `
            -Recurse `
            -Filter *.csproj `
            -File `
            -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match '\.Tests?\.csproj$'
        }
    )

    if ($testProjects.Count -eq 0) {
        Write-Host ""
        Write-Host "===== .NET tests ====="
        Write-Host "No .NET test projects are present; nothing to run."
    }
    else {
        foreach ($testProject in $testProjects) {
            $projectPath = $testProject.FullName

            Invoke-CheckedCommand ".NET test: $($testProject.Name)" {
                dotnet test $projectPath
            }
        }
    }

    Invoke-CheckedCommand "Install Web dependencies" {
        npm ci --prefix $webRoot
    }

    Invoke-CheckedCommand "Web lint" {
        npm run lint --prefix $webRoot
    }

    Invoke-CheckedCommand "Web type-check" {
        npm run typecheck --prefix $webRoot
    }

    Invoke-CheckedCommand "Web production build" {
        npm run build --prefix $webRoot
    }

    Invoke-CheckedCommand "Generated contract drift" {
        & $contractDriftScript
    }

    Write-Host ""
    Write-Host "GATE 1 PASSED"
}
finally {
    Pop-Location
}