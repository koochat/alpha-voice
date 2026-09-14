$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$webRoot = Join-Path $repoRoot "apps\web"
$apiRoot = Join-Path $repoRoot "apps\api"

$nextConfigPath = Join-Path $webRoot "next.config.ts"
$frontendProbePath = Join-Path $webRoot "app\api-probe.tsx"
$pagePath = Join-Path $webRoot "app\page.tsx"
$programPath = Join-Path $apiRoot "Program.cs"
$readmePath = Join-Path $repoRoot "README.md"

$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure {
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    $failures.Add($Message)
}

Write-Host "AlphaVoice E0-S3 same-origin development validation"
Write-Host ""

# AC-1: Next.js development origin must proxy relative /api/* requests
# to the native ASP.NET Core process.
if (-not (Test-Path -LiteralPath $nextConfigPath -PathType Leaf)) {
    Add-Failure "Missing apps/web/next.config.ts"
}
else {
    $nextConfig = Get-Content -LiteralPath $nextConfigPath -Raw

    if ($nextConfig -notmatch "\brewrites\b") {
        Add-Failure "Next.js config does not define rewrites"
    }

    if ($nextConfig -notmatch "/api/:path\*") {
        Add-Failure "Next.js config does not proxy /api/:path*"
    }

    if ($nextConfig -notmatch 'http://127\.0\.0\.1:5080') {
        Add-Failure "Next.js default API proxy target must be http://127.0.0.1:5080"
    }

    if ($nextConfig -match "NEXT_PUBLIC_[A-Za-z0-9_]*API") {
        Add-Failure "API origin must not be exposed as NEXT_PUBLIC browser configuration"
    }
}

# AC-2 / AC-3: frontend probe source must use only a relative /api/... URL.
if (-not (Test-Path -LiteralPath $frontendProbePath -PathType Leaf)) {
    Add-Failure "Missing apps/web/app/api-probe.tsx"
}
else {
    $frontendProbe = Get-Content -LiteralPath $frontendProbePath -Raw

    if ($frontendProbe -notmatch 'fetch\s*\(\s*["'']/api/dev-probe["'']') {
        Add-Failure "Frontend probe must fetch relative /api/dev-probe"
    }

    if ($frontendProbe -match 'https?://') {
        Add-Failure "Frontend probe must not contain a direct HTTP API origin"
    }
}

# Production page must not import or reference the development probe.
if (-not (Test-Path -LiteralPath $pagePath -PathType Leaf)) {
    Add-Failure "Missing apps/web/app/page.tsx"
}
else {
    $pageContent = Get-Content -LiteralPath $pagePath -Raw

    if ($pageContent -notmatch 'process\.env\.NODE_ENV\s*===\s*["'']development["'']') {
        Add-Failure "Frontend API probe must be guarded by compile-time Development environment"
    }

    if ($pageContent -notmatch 'import\s*\(\s*["'']\./api-probe["'']\s*\)') {
        Add-Failure "Frontend Development path must dynamically import ./api-probe"
    }

    if ($pageContent -match '(?m)^\s*import\s+.+["'']\./api-probe["'']') {
        Add-Failure "Frontend API probe must not use a static top-level import"
    }
}

# AC-4: ASP.NET owns the actual development probe endpoint.
if (-not (Test-Path -LiteralPath $programPath -PathType Leaf)) {
    Add-Failure "Missing apps/api/Program.cs"
}
else {
    $programContent = Get-Content -LiteralPath $programPath -Raw

    if ($programContent -notmatch '\.MapGet\s*\(\s*["'']/api/dev-probe["'']') {
        Add-Failure "ASP.NET API does not expose /api/dev-probe"
    }

    if ($programContent -notmatch 'app\.Environment\.IsDevelopment\s*\(\s*\)') {
        Add-Failure "ASP.NET development probe must be scoped to the Development environment"
    }

    # AC-5: topology must not be repaired with broad CORS or security bypasses.
    $prohibitedPatterns = @(
        "AddCors",
        "UseCors",
        "WithOrigins",
        "DisableAntiforgery"
    )

    foreach ($pattern in $prohibitedPatterns) {
        if ($programContent -match [regex]::Escape($pattern)) {
            Add-Failure "Prohibited E0-S3 workaround found in Program.cs: $pattern"
        }
    }
}

# D6: no default Next.js BFF API implementation.
$nextApiDirectory = Join-Path $webRoot "app\api"

if (Test-Path -LiteralPath $nextApiDirectory) {
    Add-Failure "apps/web/app/api must not implement a Next.js BFF for E0-S3"
}

# AC-3: normal frontend source must not embed a direct ASP.NET origin.
$frontendSourceFiles = @(
    Get-ChildItem `
        -LiteralPath (Join-Path $webRoot "app") `
        -Recurse `
        -File `
        -Include "*.ts", "*.tsx", "*.js", "*.jsx" `
        -ErrorAction SilentlyContinue
)

foreach ($file in $frontendSourceFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw

    if ($content -match 'https?://(?:localhost|127\.0\.0\.1):[0-9]+') {
        Add-Failure "Frontend application source embeds a direct local API origin: $($file.FullName)"
    }
}

# Documentation must match the canonical Next.js proxy target.
if (-not (Test-Path -LiteralPath $readmePath -PathType Leaf)) {
    Add-Failure "Missing README.md"
}
else {
    $readmeContent = Get-Content -LiteralPath $readmePath -Raw

    $canonicalApiCommand =
        'dotnet run --project .\apps\api\AlphaVoice.Api.csproj --urls http://127.0.0.1:5080'

    if ($readmeContent -notmatch [regex]::Escape($canonicalApiCommand)) {
        Add-Failure "README does not document the canonical ASP.NET development origin on port 5080"
    }

    $bareApiCommandPattern =
        '(?m)^\s*dotnet run --project \.\\apps\\api\\AlphaVoice\.Api\.csproj\s*$'

    if ($readmeContent -match $bareApiCommandPattern) {
        Add-Failure "README still contains a bare API startup command that can bind to the wrong proxy port"
    }

    if ($readmeContent -match '--urls http://127\.0\.0\.1:5080\s+--urls') {
        Add-Failure "README contains duplicate --urls arguments for the API startup command"
    }
}

Write-Host "Same-origin configuration, frontend probe isolation, documentation, API development scoping, and security guardrails checked."
Write-Host ""

if ($failures.Count -gt 0) {
    Write-Host "VALIDATION FAILED"
    Write-Host ""

    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }

    Write-Host ""
    Write-Host "Failure indicates an E0-S3 same-origin development boundary regression."
    exit 1
}

Write-Host "VALIDATION PASSED"
exit 0