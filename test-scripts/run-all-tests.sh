#!/bin/bash

# Master Test Runner for Concert Ticket System
# Runs all SQA tests and generates summary

echo "=========================================="
echo "Concert Ticket System - Full Test Suite"
echo "=========================================="
echo ""
echo "Running all Software Quality Attribute tests..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if containers are running
echo -e "${BLUE}Checking if system is running...${NC}"
if ! docker ps | grep -q "concert-web"; then
    echo -e "${RED}ERROR: Containers are not running!${NC}"
    echo "Please start the system first with: docker-compose up -d"
    exit 1
fi

echo -e "${GREEN}✓ System is running${NC}"
echo ""
echo "Waiting for services to be fully ready..."
sleep 5
echo ""

# Make scripts executable
chmod +x test-scripts/*.sh

# Track results
performance_result=0
availability_result=0
scalability_result=0

# Run Performance Tests
echo ""
echo "=========================================="
echo -e "${BLUE}1. PERFORMANCE TESTING${NC}"
echo "=========================================="
echo ""
bash test-scripts/performance-test.sh
performance_result=$?

echo ""
echo ""

# Run Availability Tests
echo "=========================================="
echo -e "${BLUE}2. AVAILABILITY TESTING${NC}"
echo "=========================================="
echo ""
bash test-scripts/availability-test.sh
availability_result=$?

echo ""
echo ""

# Run Scalability Tests
echo "=========================================="
echo -e "${BLUE}3. SCALABILITY TESTING${NC}"
echo "=========================================="
echo ""
bash test-scripts/scalability-test.sh
scalability_result=$?

echo ""
echo ""

# Generate Summary Report
echo "=========================================="
echo -e "${BLUE}FINAL TEST SUMMARY${NC}"
echo "=========================================="
echo ""

total_passed=0

echo "Performance Tests:   $([ $performance_result -eq 0 ] && echo -e "${GREEN}✓ PASSED${NC}" || echo -e "${RED}✗ FAILED${NC}")"
[ $performance_result -eq 0 ] && ((total_passed++))

echo "Availability Tests:  $([ $availability_result -eq 0 ] && echo -e "${GREEN}✓ PASSED${NC}" || echo -e "${RED}✗ FAILED${NC}")"
[ $availability_result -eq 0 ] && ((total_passed++))

echo "Scalability Tests:   $([ $scalability_result -eq 0 ] && echo -e "${GREEN}✓ PASSED${NC}" || echo -e "${YELLOW}⚠ PARTIAL${NC}")"
[ $scalability_result -eq 0 ] && ((total_passed++))

echo ""
echo "Overall Result: $total_passed/3 test suites passed"
echo ""

if [ $total_passed -eq 3 ]; then
    echo -e "${GREEN}=========================================="
    echo "✓ ALL TESTS PASSED - EXCELLENT!"
    echo "==========================================${NC}"
    exit 0
elif [ $total_passed -eq 2 ]; then
    echo -e "${YELLOW}=========================================="
    echo "⚠ MOSTLY PASSED - GOOD (Some improvements needed)"
    echo "==========================================${NC}"
    exit 0
elif [ $total_passed -eq 1 ]; then
    echo -e "${YELLOW}=========================================="
    echo "⚠ PARTIALLY PASSED - NEEDS IMPROVEMENT"
    echo "==========================================${NC}"
    exit 1
else
    echo -e "${RED}=========================================="
    echo "✗ FAILED - SIGNIFICANT IMPROVEMENTS NEEDED"
    echo "==========================================${NC}"
    exit 1
fi
