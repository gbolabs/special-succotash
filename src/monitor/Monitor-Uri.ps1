$uri = $env:APP_MONITORURI
if (-not $uri) {
    Write-Error "Unable to read monitoring UI from Env var."
    exit -1
}

$durationInSeconds = $env:APP_MONITORDURATION
if (-not $durationInSeconds) {
    Write-Warning "Unable to read check duration, uses $([timespan]::FromSeconds(1)) as default."
    $durationInSeconds = 60
}
$durationTs = [timespan]::FromSeconds($durationInSeconds)

$intervalInMSecs = $env:APP_MONITORINTERVAL
if (-not $intervalInMSecs) {
    Write-Warning "Unable to read check interval, uses $([timespan]::FromMilliseconds(250)) as default."
    $intervalInMSecs = 50
}

$expectedStatusCode = $env:APP_MONITORSTATUSCODE
if (-not $expectedStatusCode) {
    Write-Warning "Unable to read check expected status code, uses 200 as default."
    $expectedStatusCode = 200
}

Write-Host "Going to monitor URI: $uri for $durationTs every $interval."
$endTime = [datetime]::Now.Add($durationTs)

$succeeded = 0
$failed = 0
$statusCodes = [System.Collections.ArrayList]@()
do {
    if (($succeeded + $failed) % 10 -eq 0) {
        Write-Host -ForegroundColor Gray "Progress: $($succeeded+$failed) [$succeeded/$failed] - timeleft $($endTime-[datetime]::Now)"
    }
    try {
        $response = Invoke-WebRequest -Method GET -Uri $uri -TimeoutSec 1
        if ($response.StatusCode -ne $expectedStatusCode) {
            $failed++
        }
        else {
            $succeeded++
        }
        $statusCodes.Add($response.StatusCode) | Out-Null
    }
    catch {
        Write-Error $_.Exception
        $failed++
    }
    Start-Sleep -Milliseconds $intervalInMSecs
} while ([datetime]::Now -le $endTime)

Write-Host -ForegroundColor DarkCyan    "Summary: "
Write-Host -ForegroundColor Green       "    Succeeeded: $succeeded"
Write-Host -ForegroundColor DarkRed     "    Failed: $failed"
$statusCodes | Group-Object | Select-Object count, name | Write-Host