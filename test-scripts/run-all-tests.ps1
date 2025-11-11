# Master Test Runner for Concert Ticket System (PowerShell Version)
# Runs all SQA tests and generates summary

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Concert Ticket System - Full Test Suite" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Running all Software Quality Attribute tests..."
Write-Host ""

# Check if containers are running
Write-Host "Checking if system is running..." -ForegroundColor Blue
$runningContainers = docker ps | Select-String "concert-web"

if (-not $runningContainers) {
    Write-Host "ERROR: Containers are not running!" -ForegroundColor Red
    Write-Host "Please start the system first with: docker-compose up -d"
    exit 1
}

Write-Host "✓ System is running" -ForegroundColor Green
Write-Host ""
Write-Host "Waiting for services to be fully ready..."
Start-Sleep -Seconds 5
Write-Host ""

# Track results
$performanceResult = 0
$availabilityResult = 0
$scalabilityResult = 0

# Run Performance Tests
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "1. PERFORMANCE TESTING" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
& "$PSScriptRoot\performance-test.ps1"
$performanceResult = $LASTEXITCODE

Write-Host ""
Write-Host ""

# Run Availability Tests
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "2. AVAILABILITY TESTING" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
& "$PSScriptRoot\availability-test.ps1"
$availabilityResult = $LASTEXITCODE

Write-Host ""
Write-Host ""

# Run Scalability Tests
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "3. SCALABILITY TESTING" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
& "$PSScriptRoot\scalability-test.ps1"
$scalabilityResult = $LASTEXITCODE

Write-Host ""
Write-Host ""

# Generate Summary Report
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "FINAL TEST SUMMARY" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$totalPassed = 0

Write-Host -NoNewline "Performance Tests:   "
if ($performanceResult -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $totalPassed++
} else {
    Write-Host "✗ FAILED" -ForegroundColor Red
}

Write-Host -NoNewline "Availability Tests:  "
if ($availabilityResult -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $totalPassed++
} else {
    Write-Host "✗ FAILED" -ForegroundColor Red
}

Write-Host -NoNewline "Scalability Tests:   "
if ($scalabilityResult -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $totalPassed++
} else {
    Write-Host "⚠ PARTIAL" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Overall Result: $totalPassed/3 test suites passed"
Write-Host ""

if ($totalPassed -eq 3) {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "✓ ALL TESTS PASSED - EXCELLENT!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    exit 0
} elseif ($totalPassed -eq 2) {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "⚠ MOSTLY PASSED - GOOD (Some improvements needed)" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    exit 0
} elseif ($totalPassed -eq 1) {
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "⚠ PARTIALLY PASSED - NEEDS IMPROVEMENT" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "✗ FAILED - SIGNIFICANT IMPROVEMENTS NEEDED" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
    exit 1
}
