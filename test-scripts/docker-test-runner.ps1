# Docker Test Runner (PowerShell)
# Simple test runner scripts using Docker

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("performance", "availability", "scalability", "all")]
    [string]$TestType
)

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Docker Test Runner" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Function to run test in Docker
function Run-Test {
    param(
        [string]$TestName,
        [string]$TestScript,
        [bool]$NeedDockerSocket
    )

    Write-Host "Running $TestName..." -ForegroundColor Blue
    Write-Host ""

    if ($NeedDockerSocket) {
        # Need Docker socket for availability and scalability tests
        docker run --rm `
            --network="host" `
            -v "${scriptDir}:/scripts" `
            -v /var/run/docker.sock:/var/run/docker.sock `
            ubuntu:22.04 `
            bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/$TestScript"
    } else {
        # Performance test doesn't need Docker socket
        docker run --rm `
            --network="host" `
            -v "${scriptDir}:/scripts" `
            ubuntu:22.04 `
            bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq > /dev/null 2>&1 && bash /scripts/$TestScript"
    }

    return $LASTEXITCODE
}

# Run tests based on type
switch ($TestType) {
    "performance" {
        $exitCode = Run-Test "Performance Tests" "performance-test.sh" $false
    }
    "availability" {
        $exitCode = Run-Test "Availability Tests" "availability-test.sh" $true
    }
    "scalability" {
        $exitCode = Run-Test "Scalability Tests" "scalability-test.sh" $true
    }
    "all" {
        $exitCode = Run-Test "All Tests" "run-all-tests.sh" $true
    }
}

exit $exitCode
