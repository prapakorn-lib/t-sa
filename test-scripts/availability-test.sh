#!/bin/bash

# Availability Test Script for Concert Ticket System
# Tests: Health Checks, Auto-restart, Service Dependencies

echo "=================================="
echo "Availability Testing"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Container Health Checks
echo "Test 1: Container Health Check Status"
echo "--------------------------------------"
echo "Standard: All containers must have health checks configured"
echo ""

web_health=$(docker inspect concert-web --format='{{.State.Health.Status}}' 2>/dev/null)
db_health=$(docker inspect concert-db --format='{{.State.Health.Status}}' 2>/dev/null)

echo "Web Container Health: $web_health"
echo "DB Container Health: $db_health"
echo ""

if [ "$web_health" = "healthy" ] && [ "$db_health" = "healthy" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - All containers are healthy"
    test1_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Some containers are not healthy"
    test1_pass=false
fi

echo ""
echo ""

# Test 2: Health Check Endpoints
echo "Test 2: Application Health Endpoint"
echo "------------------------------------"
echo "Standard: /health endpoint must return 200 OK"
echo ""

response=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/health)

echo "Health endpoint response code: $response"
echo ""

if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Health endpoint is working"

    # Get detailed health info
    health_data=$(curl -s http://localhost:3000/health)
    echo "Health Details:"
    echo "$health_data" | jq '.' 2>/dev/null || echo "$health_data"
    test2_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Health endpoint is not responding correctly"
    test2_pass=false
fi

echo ""
echo ""

# Test 3: Auto-restart Configuration
echo "Test 3: Container Auto-restart Configuration"
echo "---------------------------------------------"
echo "Standard: Containers must have restart policy configured"
echo ""

web_restart=$(docker inspect concert-web --format='{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)
db_restart=$(docker inspect concert-db --format='{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null)

echo "Web Container Restart Policy: $web_restart"
echo "DB Container Restart Policy: $db_restart"
echo ""

if [ "$web_restart" = "unless-stopped" ] && [ "$db_restart" = "unless-stopped" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Restart policies are properly configured"
    test3_pass=true
else
    echo -e "${YELLOW}⚠ WARNING${NC} - Restart policies might not be optimal"
    test3_pass=false
fi

echo ""
echo ""

# Test 4: Service Dependency (requires interactive confirmation)
echo "Test 4: Service Dependency Check"
echo "---------------------------------"
echo "Standard: Web service must wait for DB to be healthy"
echo ""

# Check docker-compose.yml for depends_on configuration
if grep -q "depends_on:" docker-compose.yml && grep -q "condition: service_healthy" docker-compose.yml; then
    echo -e "${GREEN}✓ PASSED${NC} - Service dependencies are properly configured"
    echo "Web service has proper dependency on DB service"
    test4_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Service dependencies are not properly configured"
    test4_pass=false
fi

echo ""
echo ""

# Test 5: Database Connection Availability
echo "Test 5: Database Connection Test"
echo "---------------------------------"
echo "Standard: Application must successfully connect to database"
echo ""

# Test database connection through the application
db_status=$(curl -s http://localhost:3000/health | jq -r '.database' 2>/dev/null)

echo "Database connection status: $db_status"
echo ""

if [ "$db_status" = "connected" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Database connection is established"
    test5_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Database connection failed"
    test5_pass=false
fi

echo ""
echo ""

# Summary
echo "=================================="
echo "Availability Test Summary"
echo "=================================="
echo ""

passed=0
total=5

[ "$test1_pass" = true ] && ((passed++))
[ "$test2_pass" = true ] && ((passed++))
[ "$test3_pass" = true ] && ((passed++))
[ "$test4_pass" = true ] && ((passed++))
[ "$test5_pass" = true ] && ((passed++))

echo "Tests Passed: $passed/$total"
echo ""

if [ $passed -eq $total ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    exit 0
elif [ $passed -ge 3 ]; then
    echo -e "${YELLOW}⚠ PARTIALLY PASSED${NC} - Some tests failed"
    exit 1
else
    echo -e "${RED}✗ FAILED${NC} - Most tests failed"
    exit 1
fi
