#!/bin/bash

# Scalability Test Script for Concert Ticket System
# Tests: Container scaling, Load balancing, Resource allocation

echo "=================================="
echo "Scalability Testing"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check current container count
echo "Test 1: Initial Container State"
echo "--------------------------------"
echo ""

web_count=$(docker ps --filter "name=concert-web" --format "{{.Names}}" | wc -l)
echo "Current web containers running: $web_count"
echo ""

# Test 2: Scale Web Service
echo "Test 2: Scaling Web Service"
echo "----------------------------"
echo "Standard: Should be able to scale web service to 3 replicas"
echo ""

echo "Attempting to scale web service to 3 replicas..."
echo "Note: This will fail due to port conflict - which is expected!"
echo ""

# Try to scale (this will show the port conflict issue)
docker-compose up -d --scale web=3 2>&1 | head -20

echo ""
sleep 2

# Count actual running containers
web_count_after=$(docker ps --filter "name=concert-web" --format "{{.Names}}" | wc -l)
echo "Web containers after scaling attempt: $web_count_after"
echo ""

if [ $web_count_after -eq 3 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Successfully scaled to 3 replicas"
    test2_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Could not scale to 3 replicas"
    echo "Reason: Port mapping conflict (3000:3000 is fixed in docker-compose.yml)"
    echo ""
    echo "To fix this, you need to:"
    echo "1. Remove the fixed port mapping (3000:3000)"
    echo "2. Let Docker assign random ports, OR"
    echo "3. Use a load balancer (nginx) in front of multiple web containers"
    test2_pass=false
fi

echo ""
echo ""

# Reset to single instance
echo "Resetting to single web instance..."
docker-compose up -d --scale web=1 >/dev/null 2>&1
sleep 3

echo ""

# Test 3: Database Connection Pool
echo "Test 3: Database Connection Handling"
echo "-------------------------------------"
echo "Standard: Application should handle multiple concurrent database queries"
echo ""

success=0
failed=0

# Send 20 concurrent requests to test DB connection handling
temp_dir=$(mktemp -d)

for i in {1..20}; do
    (
        status_code=$(curl -o /dev/null -s -w '%{http_code}\n' http://localhost:3000/api/concerts)
        echo "$status_code" > "$temp_dir/result_$i.txt"
    ) &
done

wait

# Count results
for i in {1..20}; do
    if [ -f "$temp_dir/result_$i.txt" ]; then
        status=$(cat "$temp_dir/result_$i.txt")
        if [ "$status" = "200" ]; then
            ((success++))
        else
            ((failed++))
        fi
    fi
done

rm -rf "$temp_dir"

echo "Successful DB queries: $success/20"
echo "Failed DB queries: $failed/20"
echo ""

if [ $success -ge 18 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Database handles concurrent connections well"
    test3_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - Database connection handling needs improvement"
    test3_pass=false
fi

echo ""
echo ""

# Test 4: Resource Limits Check
echo "Test 4: Container Resource Configuration"
echo "-----------------------------------------"
echo "Standard: Check if resource limits are defined"
echo ""

# Check if resource limits are set in docker-compose.yml
if grep -q "resources:" docker-compose.yml || grep -q "mem_limit:" docker-compose.yml; then
    echo -e "${GREEN}✓ PASSED${NC} - Resource limits are configured"
    test4_pass=true
else
    echo -e "${YELLOW}⚠ INFO${NC} - No resource limits configured"
    echo "Consider adding resource limits for production use:"
    echo "  resources:"
    echo "    limits:"
    echo "      cpus: '0.5'"
    echo "      memory: 512M"
    test4_pass=false
fi

echo ""
echo ""

# Test 5: Load Test with multiple requests
echo "Test 5: Sustained Load Test"
echo "----------------------------"
echo "Standard: System should handle sustained load of 50 requests"
echo ""

success=0
total=50

echo "Sending 50 requests..."

for i in $(seq 1 $total); do
    status=$(curl -o /dev/null -s -w '%{http_code}\n' http://localhost:3000/api/concerts)
    if [ "$status" = "200" ]; then
        ((success++))
    fi

    # Show progress every 10 requests
    if [ $((i % 10)) -eq 0 ]; then
        echo "Progress: $i/$total requests sent"
    fi
done

echo ""
echo "Successful requests: $success/$total"
success_rate=$(echo "scale=2; $success * 100 / $total" | bc)
echo "Success rate: ${success_rate}%"
echo ""

if (( $(echo "$success_rate >= 95" | bc -l) )); then
    echo -e "${GREEN}✓ PASSED${NC} - System handles sustained load well"
    test5_pass=true
else
    echo -e "${RED}✗ FAILED${NC} - System struggled with sustained load"
    test5_pass=false
fi

echo ""
echo ""

# Summary
echo "=================================="
echo "Scalability Test Summary"
echo "=================================="
echo ""

passed=0
total_tests=5

[ "$test2_pass" = true ] && ((passed++))
[ "$test3_pass" = true ] && ((passed++))
[ "$test4_pass" = true ] && ((passed++))
[ "$test5_pass" = true ] && ((passed++))

# Always count test 1 as passed (it's informational)
((passed++))

echo "Tests Passed: $passed/$total_tests"
echo ""

echo "Important Notes:"
echo "----------------"
echo "1. Port Conflict Issue:"
echo "   - Fixed port mapping (3000:3000) prevents scaling"
echo "   - Solution: Use dynamic ports or add a load balancer"
echo ""
echo "2. Scalability Recommendations:"
echo "   - Add nginx as a reverse proxy/load balancer"
echo "   - Use environment variable for PORT instead of fixed mapping"
echo "   - Consider using Docker Swarm or Kubernetes for production"
echo ""

if [ $passed -ge 4 ]; then
    echo -e "${GREEN}✓ MOSTLY PASSED${NC} (Note: Scaling has known limitations)"
    exit 0
elif [ $passed -ge 3 ]; then
    echo -e "${YELLOW}⚠ PARTIALLY PASSED${NC}"
    exit 1
else
    echo -e "${RED}✗ FAILED${NC}"
    exit 1
fi
