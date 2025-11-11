#!/bin/bash
# Simple test runner scripts using Docker

echo "==================================="
echo "Docker Test Runner"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to run test in Docker
run_test() {
    local test_name=$1
    local test_script=$2
    local need_docker_socket=$3

    echo -e "${BLUE}Running $test_name...${NC}"
    echo ""

    if [ "$need_docker_socket" = "true" ]; then
        # Need Docker socket for availability and scalability tests
        docker run --rm \
            --network="host" \
            -v "${SCRIPT_DIR}:/scripts" \
            -v /var/run/docker.sock:/var/run/docker.sock \
            ubuntu:22.04 \
            bash -c "apt-get update > /dev/null 2>&1 && \
                     apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && \
                     bash /scripts/$test_script"
    else
        # Performance test doesn't need Docker socket
        docker run --rm \
            --network="host" \
            -v "${SCRIPT_DIR}:/scripts" \
            ubuntu:22.04 \
            bash -c "apt-get update > /dev/null 2>&1 && \
                     apt-get install -y curl bc jq > /dev/null 2>&1 && \
                     bash /scripts/$test_script"
    fi

    return $?
}

# Main menu
if [ $# -eq 0 ]; then
    echo "Usage: $0 [performance|availability|scalability|all]"
    echo ""
    echo "Examples:"
    echo "  $0 performance    # Run performance tests only"
    echo "  $0 availability   # Run availability tests only"
    echo "  $0 scalability    # Run scalability tests only"
    echo "  $0 all           # Run all tests"
    echo ""
    exit 1
fi

case "$1" in
    performance)
        run_test "Performance Tests" "performance-test.sh" "false"
        ;;
    availability)
        run_test "Availability Tests" "availability-test.sh" "true"
        ;;
    scalability)
        run_test "Scalability Tests" "scalability-test.sh" "true"
        ;;
    all)
        run_test "All Tests" "run-all-tests.sh" "true"
        ;;
    *)
        echo -e "${RED}Invalid option: $1${NC}"
        echo "Use: performance, availability, scalability, or all"
        exit 1
        ;;
esac

exit $?
