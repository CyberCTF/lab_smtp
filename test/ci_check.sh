#!/bin/bash

# CI Check Script for Acme Logistics SMTP Lab
# Ensures no real flags are committed to the repository

echo "🔍 Running CI checks for Acme Logistics SMTP Lab..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED_CHECKS=0
TOTAL_CHECKS=0

# Function to run a check
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    echo ""
    echo -e "${YELLOW}[CHECK $((TOTAL_CHECKS + 1))]${NC} $check_name"
    
    TOTAL_CHESKS=$((TOTAL_CHECKS + 1))
    
    if eval "$check_command" >/dev/null 2>&1; then
        echo -e "${RED}❌ FAILED${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    else
        echo -e "${GREEN}✓ PASSED${NC}"
        return 0
    fi
}

# Check 1: No FLAG{ patterns in repository
run_check "No FLAG{ patterns in repository" \
    "grep -r 'FLAG{' . --exclude-dir=.git --exclude-dir=.github --exclude=flag.txt --exclude=flag_inject.example"

# Check 2: No real flag file committed
run_check "No real flag.txt committed" \
    "git ls-files | grep -q '^flag\.txt$'"

# Check 3: Flag example file exists
run_check "Flag example file exists" \
    "test ! -f flag_inject.example"

# Check 4: No hardcoded passwords in source
run_check "No hardcoded passwords in source" \
    "grep -r 'password.*=.*['\''\"].*['\''\"]' build/ --exclude=*.pyc"

# Check 5: No sensitive data in logs
run_check "No sensitive data in logs" \
    "find . -name '*.log' -exec grep -l 'password\|secret\|key' {} \;"

# Check 6: Docker secrets properly configured
run_check "Docker secrets properly configured" \
    "grep -q 'secrets:' deploy/docker-compose.yml"

# Check 7: Flag injection documented
run_check "Flag injection documented" \
    "grep -q 'DOCKER_BUILDKIT' README.md"

# Show summary
echo ""
echo "=========================================="
echo "           CI CHECK SUMMARY"
echo "=========================================="
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$((TOTAL_CHECKS - FAILED_CHECKS))${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🎉 All CI checks passed! Repository is secure.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some CI checks failed. Please review the issues above.${NC}"
    echo ""
    echo "Common issues:"
    echo "- Remove any FLAG{ patterns from source code"
    echo "- Ensure flag.txt is in .gitignore"
    echo "- Check for hardcoded credentials"
    echo "- Verify Docker secrets configuration"
    exit 1
fi 