#!/bin/bash

# Performance Test Script for Concert Ticket System
# Tests: Response Time and Concurrent Requests

echo "=================================="
echo "Performance Testing"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000"

# Test 1: Health Check Response Time
echo "Test 1: Health Check API Response Time"
echo "---------------------------------------"
echo "Standard: < 500ms"
echo ""

total_time=0
num_requests=5

for i in {1..5}; do
    response_time=$(curl -o /dev/null -s -w '%{time_total}\n' $BASE_URL/health)
    # Convert to milliseconds
    ms_time=$(echo "$response_time * 1000" | bc)
    echo "Request $i: ${ms_time} ms"
    total_time=$(echo "$total_time + $ms_time" | bc)
done

avg_time=$(echo "scale=2; $total_time / $num_requests" | bc)
echo ""
echo "Average Response Time: ${avg_time} ms"

if (( $(echo "$avg_time < 500" | bc -l) )); then
    echo -e "${GREEN}✓ PASSED${NC} - Response time is within standard"
else
    echo -e "${RED}✗ FAILED${NC} - Response time exceeds 500ms standard"
fi

echo ""
echo ""

# Test 2: Concerts API Response Time
echo "Test 2: Concerts API Response Time"
echo "-----------------------------------"
echo "Standard: < 1000ms"
echo ""

total_time=0
num_requests=5

for i in {1..5}; do
    response_time=$(curl -o /dev/null -s -w '%{time_total}\n' $BASE_URL/api/concerts)
    # Convert to milliseconds
    ms_time=$(echo "$response_time * 1000" | bc)
    echo "Request $i: ${ms_time} ms"
    total_time=$(echo "$total_time + $ms_time" | bc)
done

avg_time=$(echo "scale=2; $total_time / $num_requests" | bc)
echo ""
echo "Average Response Time: ${avg_time} ms"

if (( $(echo "$avg_time < 1000" | bc -l) )); then
    echo -e "${GREEN}✓ PASSED${NC} - Response time is within standard"
else
    echo -e "${RED}✗ FAILED${NC} - Response time exceeds 1000ms standard"
fi

echo ""
echo ""

# Test 3: Concurrent Requests
echo "Test 3: Concurrent Requests Handling"
echo "-------------------------------------"
echo "Standard: Handle at least 10 concurrent requests"
echo ""

success_count=0
failed_count=0

# Create a temporary directory for concurrent test results
temp_dir=$(mktemp -d)

# Send 10 concurrent requests
for i in {1..10}; do
    (
        status_code=$(curl -o /dev/null -s -w '%{http_code}\n' $BASE_URL/api/concerts)
        echo "$status_code" > "$temp_dir/result_$i.txt"
    ) &
done

# Wait for all background jobs to complete
wait

# Count successful requests
for i in {1..10}; do
    if [ -f "$temp_dir/result_$i.txt" ]; then
        status=$(cat "$temp_dir/result_$i.txt")
        if [ "$status" = "200" ]; then
            ((success_count++))
        else
            ((failed_count++))
        fi
    fi
done

# Cleanup
rm -rf "$temp_dir"

echo "Successful requests: $success_count/10"
echo "Failed requests: $failed_count/10"
echo ""

if [ $success_count -eq 10 ]; then
    echo -e "${GREEN}✓ PASSED${NC} - All concurrent requests handled successfully"
elif [ $success_count -ge 8 ]; then
    echo -e "${YELLOW}⚠ WARNING${NC} - Most requests succeeded but some failed"
else
    echo -e "${RED}✗ FAILED${NC} - Too many failed requests"
fi

echo ""
echo "=================================="
echo "Performance Testing Complete"
echo "=================================="
