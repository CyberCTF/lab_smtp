#!/bin/bash

# SMTP CTF Lab Test Script
# Tests comprehensive SMTP functionality

echo "=========================================="
echo "       SMTP CTF Lab Test Suite"
echo "=========================================="

SMTP_HOST=${SMTP_HOST:-"localhost"}
SMTP_PORT=${SMTP_PORT:-25}
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo ""
    echo -e "${BLUE}[TEST $((TOTAL_TESTS + 1))]${NC} $test_name"
    echo "Command: $test_command"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Execute test with timeout
    if timeout 10 bash -c "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "success" ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            TEST_RESULTS+=("PASS: $test_name")
        else
            echo -e "${RED}✗ FAILED${NC} (unexpected success)"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            TEST_RESULTS+=("FAIL: $test_name - unexpected success")
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${GREEN}✓ PASSED${NC} (expected failure)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            TEST_RESULTS+=("PASS: $test_name - expected failure")
        else
            echo -e "${RED}✗ FAILED${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            TEST_RESULTS+=("FAIL: $test_name")
        fi
    fi
}

# Function to test basic SMTP connectivity
test_basic_connectivity() {
    echo ""
    echo -e "${YELLOW}=== Testing Basic Connectivity ===${NC}"
    
    # Test 1: Basic TCP connection
    run_test "Basic TCP Connection" \
        "nc -z $SMTP_HOST $SMTP_PORT" \
        "success"
    
    # Test 2: SMTP Banner
    run_test "SMTP Banner Response" \
        "echo 'QUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '220'" \
        "success"
}

# Function to test SMTP commands
test_smtp_commands() {
    echo ""
    echo -e "${YELLOW}=== Testing SMTP Commands ===${NC}"
    
    # Test 3: HELO command
    run_test "HELO Command" \
        "echo -e 'HELO test.com\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250'" \
        "success"
    
    # Test 4: EHLO command
    run_test "EHLO Command" \
        "echo -e 'EHLO test.com\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250'" \
        "success"
    
    # Test 5: MAIL FROM command
    run_test "MAIL FROM Command" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <test@test.com>\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250 OK'" \
        "success"
    
    # Test 6: RCPT TO command (authorized domain)
    run_test "RCPT TO Authorized Domain" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <test@test.com>\r\nRCPT TO: <user@ctf.local>\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250 OK'" \
        "success"
    
    # Test 7: VRFY command
    run_test "VRFY Command" \
        "echo -e 'VRFY ctf\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250'" \
        "success"
}

# Function to test authentication
test_authentication() {
    echo ""
    echo -e "${YELLOW}=== Testing Authentication ===${NC}"
    
    # Test 8: AUTH LOGIN support
    run_test "AUTH LOGIN Support" \
        "echo -e 'EHLO test.com\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q 'AUTH'" \
        "success"
    
    # Test 9: Valid authentication (ctf user)
    # Base64 encoded: ctf = Y3Rm, ctf_password_2024 = Y3RmX3Bhc3N3b3JkXzIwMjQ=
    run_test "Valid Authentication" \
        "echo -e 'EHLO test.com\r\nAUTH LOGIN Y3Rm\r\nY3RmX3Bhc3N3b3JkXzIwMjQ=\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '235'" \
        "success"
    
    # Test 10: Invalid authentication
    run_test "Invalid Authentication" \
        "echo -e 'EHLO test.com\r\nAUTH LOGIN d3Jvbmc=\r\ncGFzc3dvcmQ=\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '535'" \
        "success"
}

# Function to test email relay
test_email_relay() {
    echo ""
    echo -e "${YELLOW}=== Testing Email Relay ===${NC}"
    
    # Test 11: Relay to authorized domain
    run_test "Relay to Authorized Domain" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <sender@test.com>\r\nRCPT TO: <user@ctf.local>\r\nDATA\r\nSubject: Test\r\n\r\nTest message\r\n.\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250 Message accepted'" \
        "success"
    
    # Test 12: Relay to unauthorized domain (should fail without auth)
    run_test "Relay to Unauthorized Domain" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <sender@test.com>\r\nRCPT TO: <user@unauthorized.com>\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '550'" \
        "success"
}

# Function to test advanced features
test_advanced_features() {
    echo ""
    echo -e "${YELLOW}=== Testing Advanced Features ===${NC}"
    
    # Test 13: Message size limit
    run_test "Large Message Handling" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <sender@test.com>\r\nRCPT TO: <user@ctf.local>\r\nDATA\r\nSubject: Large Test\r\n\r\n$(head -c 2000000 /dev/zero | tr '\0' 'A')\r\n.\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT" \
        "fail"
    
    # Test 14: RSET command
    run_test "RSET Command" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <sender@test.com>\r\nRSET\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT | grep -q '250 OK'" \
        "success"
    
    # Test 15: Multiple recipients
    run_test "Multiple Recipients" \
        "echo -e 'HELO test.com\r\nMAIL FROM: <sender@test.com>\r\nRCPT TO: <user1@ctf.local>\r\nRCPT TO: <user2@ctf.local>\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT" \
        "success"
}

# Function to test security features
test_security_features() {
    echo ""
    echo -e "${YELLOW}=== Testing Security Features ===${NC}"
    
    # Test 16: Connection limit (simulate multiple connections)
    run_test "Connection Limits" \
        "for i in {1..15}; do (echo 'HELO test\r\nQUIT' | nc $SMTP_HOST $SMTP_PORT &); done; wait" \
        "success"
    
    # Test 17: Session timeout (keep connection open)
    run_test "Session Timeout" \
        "echo 'HELO test.com' | nc $SMTP_HOST $SMTP_PORT & sleep 5; kill $!" \
        "success"
}

# Function to check mailbox
check_mailbox() {
    echo ""
    echo -e "${YELLOW}=== Checking Mailbox ===${NC}"
    
    # If running in container, check mailbox
    if [ -d "/home/ctf/smtp/mailbox/inbox" ]; then
        echo "Emails in mailbox:"
        ls -la /home/ctf/smtp/mailbox/inbox/
        echo ""
        echo "Total emails: $(ls /home/ctf/smtp/mailbox/inbox/*.eml 2>/dev/null | wc -l)"
    else
        echo "Mailbox not accessible from current location"
    fi
}

# Function to show test summary
show_summary() {
    echo ""
    echo "=========================================="
    echo "           TEST SUMMARY"
    echo "=========================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! SMTP CTF Lab is ready.${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Check the results above.${NC}"
        echo ""
        echo "Failed tests:"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == FAIL* ]]; then
                echo -e "${RED}- $result${NC}"
            fi
        done
        exit 1
    fi
}

# Main execution
main() {
    echo "Testing SMTP CTF Lab on $SMTP_HOST:$SMTP_PORT"
    echo "Timestamp: $(date)"
    
    # Check if SMTP server is running
    if ! nc -z $SMTP_HOST $SMTP_PORT 2>/dev/null; then
        echo -e "${RED}❌ SMTP server is not running on $SMTP_HOST:$SMTP_PORT${NC}"
        echo "Please start the server with: docker-compose up -d"
        exit 1
    fi
    
    echo -e "${GREEN}✓ SMTP server is running${NC}"
    
    # Run all test suites
    test_basic_connectivity
    test_smtp_commands
    test_authentication
    test_email_relay
    test_advanced_features
    test_security_features
    
    # Check mailbox if accessible
    check_mailbox
    
    # Show final summary
    show_summary
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "SMTP CTF Lab Test Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --host HOST    SMTP server host (default: localhost)"
        echo "  --port PORT    SMTP server port (default: 25)"
        echo "  --quick        Run quick test suite only"
        echo ""
        echo "Environment variables:"
        echo "  SMTP_HOST      SMTP server host"
        echo "  SMTP_PORT      SMTP server port"
        exit 0
        ;;
    "--host")
        SMTP_HOST="$2"
        shift 2
        ;;
    "--port")
        SMTP_PORT="$2"
        shift 2
        ;;
    "--quick")
        echo "Running quick test suite..."
        test_basic_connectivity
        test_smtp_commands
        show_summary
        ;;
    *)
        main "$@"
        ;;
esac 