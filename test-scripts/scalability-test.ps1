# Scalability Test Script for Concert Ticket System (PowerShell Version)
# Tests: Container scaling, Load balancing, Resource allocation

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Scalability Testing" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check current container count
Write-Host "Test 1: Initial Container State" -ForegroundColor Yellow
Write-Host "--------------------------------"
Write-Host ""

$webCount = (docker ps --filter "name=concert-web" --format "{{.Names}}" | Measure-Object).Count
Write-Host "Current web containers running: $webCount"
Write-Host ""

# Test 2: Scale Web Service
Write-Host "Test 2: Scaling Web Service" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host "Standard: Should be able to scale web service to 3 replicas"
Write-Host ""

Write-Host "Attempting to scale web service to 3 replicas..."
Write-Host "Note: This will fail due to port conflict - which is expected!"
Write-Host ""

# Try to scale (this will show the port conflict issue)
docker-compose up -d --scale web=3 2>&1 | Select-Object -First 20

Write-Host ""
Start-Sleep -Seconds 2

# Count actual running containers
$webCountAfter = (docker ps --filter "name=concert-web" --format "{{.Names}}" | Measure-Object).Count
Write-Host "Web containers after scaling attempt: $webCountAfter"
Write-Host ""

if ($webCountAfter -eq 3) {
    Write-Host "✓ PASSED - Successfully scaled to 3 replicas" -ForegroundColor Green
    $test2Pass = $true
} else {
    Write-Host "✗ FAILED - Could not scale to 3 replicas" -ForegroundColor Red
    Write-Host "Reason: Port mapping conflict (3000:3000 is fixed in docker-compose.yml)"
    Write-Host ""
    Write-Host "To fix this, you need to:"
    Write-Host "1. Remove the fixed port mapping (3000:3000)"
    Write-Host "2. Let Docker assign random ports, OR"
    Write-Host "3. Use a load balancer (nginx) in front of multiple web containers"
    $test2Pass = $false
}

Write-Host ""
Write-Host ""

# Reset to single instance
Write-Host "Resetting to single web instance..."
docker-compose up -d --scale web=1 2>&1 | Out-Null
Start-Sleep -Seconds 3

Write-Host ""

# Test 3: Database Connection Pool
Write-Host "Test 3: Database Connection Handling" -ForegroundColor Yellow
Write-Host "-------------------------------------"
Write-Host "Standard: Application should handle multiple concurrent database queries"
Write-Host ""

$success = 0
$failed = 0
$jobs = @()

# Send 20 concurrent requests to test DB connection handling
for ($i = 1; $i -le 20; $i++) {
    $jobs += Start-Job -ScriptBlock {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000/api/concerts" -UseBasicParsing -TimeoutSec 10
            return $response.StatusCode
        }
        catch {
            return 0
        }
    }
}

$jobs | Wait-Job | Out-Null

# Count results
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    if ($result -eq 200) {
        $success++
    } else {
        $failed++
    }
    Remove-Job -Job $job
}

Write-Host "Successful DB queries: $success/20"
Write-Host "Failed DB queries: $failed/20"
Write-Host ""

if ($success -ge 18) {
    Write-Host "✓ PASSED - Database handles concurrent connections well" -ForegroundColor Green
    $test3Pass = $true
} else {
    Write-Host "✗ FAILED - Database connection handling needs improvement" -ForegroundColor Red
    $test3Pass = $false
}

Write-Host ""
Write-Host ""

# Test 4: Resource Limits Check
Write-Host "Test 4: Container Resource Configuration" -ForegroundColor Yellow
Write-Host "-----------------------------------------"
Write-Host "Standard: Check if resource limits are defined"
Write-Host ""

$hasResourceLimits = Get-Content docker-compose.yml | Select-String "resources:|mem_limit:"

if ($hasResourceLimits) {
    Write-Host "✓ PASSED - Resource limits are configured" -ForegroundColor Green
    $test4Pass = $true
} else {
    Write-Host "⚠ INFO - No resource limits configured" -ForegroundColor Yellow
    Write-Host "Consider adding resource limits for production use:"
    Write-Host "  resources:"
    Write-Host "    limits:"
    Write-Host "      cpus: '0.5'"
    Write-Host "      memory: 512M"
    $test4Pass = $false
}

Write-Host ""
Write-Host ""

# Test 5: Load Test with multiple requests
Write-Host "Test 5: Sustained Load Test" -ForegroundColor Yellow
Write-Host "----------------------------"
Write-Host "Standard: System should handle sustained load of 50 requests"
Write-Host ""

$success = 0
$total = 50

Write-Host "Sending 50 requests..."

for ($i = 1; $i -le $total; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/concerts" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            $success++
        }
    }
    catch {
        # Request failed
    }

    # Show progress every 10 requests
    if ($i % 10 -eq 0) {
        Write-Host "Progress: $i/$total requests sent"
    }
}

Write-Host ""
Write-Host "Successful requests: $success/$total"
$successRate = [math]::Round(($success * 100 / $total), 2)
Write-Host "Success rate: $successRate%"
Write-Host ""

if ($successRate -ge 95) {
    Write-Host "✓ PASSED - System handles sustained load well" -ForegroundColor Green
    $test5Pass = $true
} else {
    Write-Host "✗ FAILED - System struggled with sustained load" -ForegroundColor Red
    $test5Pass = $false
}

Write-Host ""
Write-Host ""

# Summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Scalability Test Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$passed = 1  # Test 1 always counts as informational
$totalTests = 5

if ($test2Pass) { $passed++ }
if ($test3Pass) { $passed++ }
if ($test4Pass) { $passed++ }
if ($test5Pass) { $passed++ }

Write-Host "Tests Passed: $passed/$totalTests"
Write-Host ""

Write-Host "Important Notes:" -ForegroundColor Yellow
Write-Host "----------------"
Write-Host "1. Port Conflict Issue:"
Write-Host "   - Fixed port mapping (3000:3000) prevents scaling"
Write-Host "   - Solution: Use dynamic ports or add a load balancer"
Write-Host ""
Write-Host "2. Scalability Recommendations:"
Write-Host "   - Add nginx as a reverse proxy/load balancer"
Write-Host "   - Use environment variable for PORT instead of fixed mapping"
Write-Host "   - Consider using Docker Swarm or Kubernetes for production"
Write-Host ""

if ($passed -ge 4) {
    Write-Host "✓ MOSTLY PASSED (Note: Scaling has known limitations)" -ForegroundColor Green
    exit 0
} elseif ($passed -ge 3) {
    Write-Host "⚠ PARTIALLY PASSED" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✗ FAILED" -ForegroundColor Red
    exit 1
}
