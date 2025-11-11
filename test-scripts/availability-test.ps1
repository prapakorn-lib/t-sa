# Availability Test Script for Concert Ticket System (PowerShell Version)
# Tests: Health Checks, Auto-restart, Service Dependencies

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Availability Testing" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Container Health Checks
Write-Host "Test 1: Container Health Check Status" -ForegroundColor Yellow
Write-Host "--------------------------------------"
Write-Host "Standard: All containers must have health checks configured"
Write-Host ""

try {
    $webHealth = docker inspect concert-web --format='{{.State.Health.Status}}' 2>$null
    $dbHealth = docker inspect concert-db --format='{{.State.Health.Status}}' 2>$null

    Write-Host "Web Container Health: $webHealth"
    Write-Host "DB Container Health: $dbHealth"
    Write-Host ""

    if ($webHealth -eq "healthy" -and $dbHealth -eq "healthy") {
        Write-Host "✓ PASSED - All containers are healthy" -ForegroundColor Green
        $test1Pass = $true
    } else {
        Write-Host "✗ FAILED - Some containers are not healthy" -ForegroundColor Red
        $test1Pass = $false
    }
}
catch {
    Write-Host "✗ FAILED - Could not inspect containers" -ForegroundColor Red
    $test1Pass = $false
}

Write-Host ""
Write-Host ""

# Test 2: Health Check Endpoints
Write-Host "Test 2: Application Health Endpoint" -ForegroundColor Yellow
Write-Host "------------------------------------"
Write-Host "Standard: /health endpoint must return 200 OK"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 10
    $statusCode = $response.StatusCode

    Write-Host "Health endpoint response code: $statusCode"
    Write-Host ""

    if ($statusCode -eq 200) {
        Write-Host "✓ PASSED - Health endpoint is working" -ForegroundColor Green

        # Get detailed health info
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "Health Details:"
        Write-Host "  Status: $($healthData.status)"
        Write-Host "  Database: $($healthData.database)"
        Write-Host "  Timestamp: $($healthData.timestamp)"
        $test2Pass = $true
    } else {
        Write-Host "✗ FAILED - Health endpoint is not responding correctly" -ForegroundColor Red
        $test2Pass = $false
    }
}
catch {
    Write-Host "✗ FAILED - Could not reach health endpoint: $_" -ForegroundColor Red
    $test2Pass = $false
}

Write-Host ""
Write-Host ""

# Test 3: Auto-restart Configuration
Write-Host "Test 3: Container Auto-restart Configuration" -ForegroundColor Yellow
Write-Host "---------------------------------------------"
Write-Host "Standard: Containers must have restart policy configured"
Write-Host ""

try {
    $webRestart = docker inspect concert-web --format='{{.HostConfig.RestartPolicy.Name}}' 2>$null
    $dbRestart = docker inspect concert-db --format='{{.HostConfig.RestartPolicy.Name}}' 2>$null

    Write-Host "Web Container Restart Policy: $webRestart"
    Write-Host "DB Container Restart Policy: $dbRestart"
    Write-Host ""

    if ($webRestart -eq "unless-stopped" -and $dbRestart -eq "unless-stopped") {
        Write-Host "✓ PASSED - Restart policies are properly configured" -ForegroundColor Green
        $test3Pass = $true
    } else {
        Write-Host "⚠ WARNING - Restart policies might not be optimal" -ForegroundColor Yellow
        $test3Pass = $false
    }
}
catch {
    Write-Host "✗ FAILED - Could not check restart policies" -ForegroundColor Red
    $test3Pass = $false
}

Write-Host ""
Write-Host ""

# Test 4: Service Dependency
Write-Host "Test 4: Service Dependency Check" -ForegroundColor Yellow
Write-Host "---------------------------------"
Write-Host "Standard: Web service must wait for DB to be healthy"
Write-Host ""

$dependsOn = Get-Content docker-compose.yml | Select-String "depends_on:" -Context 0,3
$hasHealthCondition = Get-Content docker-compose.yml | Select-String "condition: service_healthy"

if ($dependsOn -and $hasHealthCondition) {
    Write-Host "✓ PASSED - Service dependencies are properly configured" -ForegroundColor Green
    Write-Host "Web service has proper dependency on DB service"
    $test4Pass = $true
} else {
    Write-Host "✗ FAILED - Service dependencies are not properly configured" -ForegroundColor Red
    $test4Pass = $false
}

Write-Host ""
Write-Host ""

# Test 5: Database Connection Availability
Write-Host "Test 5: Database Connection Test" -ForegroundColor Yellow
Write-Host "---------------------------------"
Write-Host "Standard: Application must successfully connect to database"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 10
    $healthData = $response.Content | ConvertFrom-Json
    $dbStatus = $healthData.database

    Write-Host "Database connection status: $dbStatus"
    Write-Host ""

    if ($dbStatus -eq "connected") {
        Write-Host "✓ PASSED - Database connection is established" -ForegroundColor Green
        $test5Pass = $true
    } else {
        Write-Host "✗ FAILED - Database connection failed" -ForegroundColor Red
        $test5Pass = $false
    }
}
catch {
    Write-Host "✗ FAILED - Could not check database connection" -ForegroundColor Red
    $test5Pass = $false
}

Write-Host ""
Write-Host ""

# Summary
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Availability Test Summary" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$passed = 0
$total = 5

if ($test1Pass) { $passed++ }
if ($test2Pass) { $passed++ }
if ($test3Pass) { $passed++ }
if ($test4Pass) { $passed++ }
if ($test5Pass) { $passed++ }

Write-Host "Tests Passed: $passed/$total"
Write-Host ""

if ($passed -eq $total) {
    Write-Host "✓ ALL TESTS PASSED" -ForegroundColor Green
    exit 0
} elseif ($passed -ge 3) {
    Write-Host "⚠ PARTIALLY PASSED - Some tests failed" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✗ FAILED - Most tests failed" -ForegroundColor Red
    exit 1
}
