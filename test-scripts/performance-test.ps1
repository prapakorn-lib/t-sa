# Performance Test Script for Concert Ticket System (PowerShell Version)
# Tests: Response Time and Concurrent Requests

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Performance Testing" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000"

# Test 1: Health Check Response Time
Write-Host "Test 1: Health Check API Response Time" -ForegroundColor Yellow
Write-Host "---------------------------------------"
Write-Host "Standard: < 500ms"
Write-Host ""

$totalTime = 0
$numRequests = 5

for ($i = 1; $i -le 5; $i++) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/health" -UseBasicParsing -TimeoutSec 10
        $stopwatch.Stop()
        $msTime = $stopwatch.ElapsedMilliseconds
        Write-Host "Request $i: $msTime ms"
        $totalTime += $msTime
    }
    catch {
        Write-Host "Request $i: FAILED" -ForegroundColor Red
    }
}

$avgTime = [math]::Round($totalTime / $numRequests, 2)
Write-Host ""
Write-Host "Average Response Time: $avgTime ms"

if ($avgTime -lt 500) {
    Write-Host "✓ PASSED - Response time is within standard" -ForegroundColor Green
} else {
    Write-Host "✗ FAILED - Response time exceeds 500ms standard" -ForegroundColor Red
}

Write-Host ""
Write-Host ""

# Test 2: Concerts API Response Time
Write-Host "Test 2: Concerts API Response Time" -ForegroundColor Yellow
Write-Host "-----------------------------------"
Write-Host "Standard: < 1000ms"
Write-Host ""

$totalTime = 0

for ($i = 1; $i -le 5; $i++) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/api/concerts" -UseBasicParsing -TimeoutSec 10
        $stopwatch.Stop()
        $msTime = $stopwatch.ElapsedMilliseconds
        Write-Host "Request $i: $msTime ms"
        $totalTime += $msTime
    }
    catch {
        Write-Host "Request $i: FAILED" -ForegroundColor Red
    }
}

$avgTime = [math]::Round($totalTime / $numRequests, 2)
Write-Host ""
Write-Host "Average Response Time: $avgTime ms"

if ($avgTime -lt 1000) {
    Write-Host "✓ PASSED - Response time is within standard" -ForegroundColor Green
} else {
    Write-Host "✗ FAILED - Response time exceeds 1000ms standard" -ForegroundColor Red
}

Write-Host ""
Write-Host ""

# Test 3: Concurrent Requests
Write-Host "Test 3: Concurrent Requests Handling" -ForegroundColor Yellow
Write-Host "-------------------------------------"
Write-Host "Standard: Handle at least 10 concurrent requests"
Write-Host ""

$successCount = 0
$failedCount = 0
$jobs = @()

# Send 10 concurrent requests
for ($i = 1; $i -le 10; $i++) {
    $jobs += Start-Job -ScriptBlock {
        param($url)
        try {
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
            return $response.StatusCode
        }
        catch {
            return 0
        }
    } -ArgumentList "$baseUrl/api/concerts"
}

# Wait for all jobs to complete
$jobs | Wait-Job | Out-Null

# Count successful requests
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    if ($result -eq 200) {
        $successCount++
    } else {
        $failedCount++
    }
    Remove-Job -Job $job
}

Write-Host "Successful requests: $successCount/10"
Write-Host "Failed requests: $failedCount/10"
Write-Host ""

if ($successCount -eq 10) {
    Write-Host "✓ PASSED - All concurrent requests handled successfully" -ForegroundColor Green
} elseif ($successCount -ge 8) {
    Write-Host "⚠ WARNING - Most requests succeeded but some failed" -ForegroundColor Yellow
} else {
    Write-Host "✗ FAILED - Too many failed requests" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Performance Testing Complete" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
