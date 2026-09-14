$ErrorActionPreference = "Stop"

$webOrigin = "http://localhost:3000"
$apiOrigin = "http://127.0.0.1:5080"

$expectedMessage =
    "AlphaVoice API reachable through same-origin development routing"

Write-Host "AlphaVoice E0-S3 same-origin runtime smoke test"
Write-Host "Web origin: $webOrigin"
Write-Host "API tooling origin: $apiOrigin"
Write-Host ""

try {
    $sameOriginResponse = Invoke-RestMethod `
        -Uri "$webOrigin/api/dev-probe" `
        -Method Get

    if ($sameOriginResponse.message -ne $expectedMessage) {
        throw "Unexpected response through Next.js origin."
    }

    Write-Host "PASS: relative /api/dev-probe succeeded through Next.js origin."
}
catch {
    Write-Host "FAIL: same-origin request through Next.js did not succeed."
    Write-Host $_.Exception.Message
    exit 1
}

try {
    $directApiResponse = Invoke-RestMethod `
        -Uri "$apiOrigin/api/dev-probe" `
        -Method Get

    if ($directApiResponse.message -ne $expectedMessage) {
        throw "Unexpected response from direct ASP.NET tooling origin."
    }

    Write-Host "PASS: direct ASP.NET port remains available for tests/tooling."
}
catch {
    Write-Host "FAIL: direct ASP.NET tooling request did not succeed."
    Write-Host $_.Exception.Message
    exit 1
}

Write-Host ""
Write-Host "RUNTIME SMOKE PASSED"
exit 0