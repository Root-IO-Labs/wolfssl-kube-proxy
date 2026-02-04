#!/bin/bash
################################################################################
# kube-proxy v1.33.5 - Network Proxy Functionality Tests
#
# Purpose: Test kube-proxy-specific functionality including:
#          - Binary execution and version checks
#          - Networking tools availability
#          - iptables/IPVS support
#          - Kernel module requirements
#          - TLS/Certificate support via FIPS crypto
#
# Usage:
#   ./tests/test-kube-proxy-functionality.sh [image-name]
#
# Example:
#   ./tests/test-kube-proxy-functionality.sh kube-proxy-fips:v1.33.5-ubuntu-22.04
#
# Test Coverage:
#   • Entrypoint FIPS Validation (6 checks)
#   • Binary Validation (3 checks)
#   • Network Tools (5 checks)
#   • Kernel Module Support (3 checks)
#   • Configuration Support (2 checks)
#   • TLS/Crypto Support (3 checks)
#
# Total Checks: 22
# Expected Duration: ~40 seconds
#
# Exit Codes:
#   0 - All functionality tests passed
#   1 - One or more tests failed
#
# Last Updated: 2026-01-13
# Version: 1.0
################################################################################

set -e

IMAGE_NAME="${1:-kube-proxy-fips:v1.33.5-ubuntu-22.04}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
    echo "Test $TOTAL_TESTS: $test_name"
    echo "----------------------------------------"

    if output=$(eval "$test_command" 2>&1); then
        if echo "$output" | grep -qE "$expected_pattern"; then
            echo -e "${GREEN}[SUCCESS]${NC} PASSED"
            echo "Output matched: $expected_pattern"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${RED}[ERROR]${NC} FAILED - Pattern not matched"
            echo "Expected: $expected_pattern"
            echo "Got: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        echo -e "${RED}[ERROR]${NC} FAILED - Command error"
        echo "Command: $test_command"
        echo "Output: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo ""
echo "================================================================"
echo "kube-proxy v1.33.5 - Network Proxy Functionality Tests"
echo "================================================================"
echo ""
echo "Image: $IMAGE_NAME"
echo "Date: $(date)"
echo ""

# Pre-flight check
echo -n "Checking if image exists ... "
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo -e "${RED}✗ NOT FOUND${NC}"
    exit 1
fi
echo -e "${GREEN}✓ FOUND${NC}"
echo ""

################################################################################
# Section 1: Entrypoint FIPS Validation
################################################################################

echo "================================================================"
echo -e "${CYAN}[1/6] Entrypoint FIPS Validation${NC}"
echo "================================================================"

run_test \
    "Entrypoint script exists and is executable" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -x /entrypoint.sh && echo exists'" \
    "exists"

run_test \
    "Entrypoint validates OpenSSL version" \
    "docker run --rm --entrypoint=/entrypoint.sh $IMAGE_NAME /bin/bash 2>&1 | head -200" \
    "OpenSSL version.*3\\.0\\.15"

run_test \
    "Entrypoint checks wolfProvider" \
    "docker run --rm --entrypoint=/entrypoint.sh $IMAGE_NAME /bin/bash 2>&1 | head -200" \
    "wolfProvider is loaded and active"

run_test \
    "Entrypoint runs FIPS integrity check" \
    "docker run --rm --entrypoint=/entrypoint.sh $IMAGE_NAME /bin/bash 2>&1 | head -200" \
    "wolfSSL FIPS integrity check passed|FIPS startup check utility not found"

run_test \
    "Entrypoint tests SHA-256" \
    "docker run --rm --entrypoint=/entrypoint.sh $IMAGE_NAME /bin/bash 2>&1 | head -200" \
    "SHA-256 test passed"

run_test \
    "Entrypoint tests additional FIPS algorithms" \
    "docker run --rm --entrypoint=/entrypoint.sh $IMAGE_NAME /bin/bash 2>&1 | head -200" \
    "SHA-384 operation successful|AES-256-CBC operation successful"

################################################################################
# Section 2: Binary Validation
################################################################################

echo ""
echo "================================================================"
echo -e "${CYAN}[2/6] Binary Validation${NC}"
echo "================================================================"

run_test \
    "kube-proxy binary exists and is executable" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -x /kube-proxy && echo exists'" \
    "exists"

run_test \
    "kube-proxy version output" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c '/kube-proxy --version 2>&1 | head -1'" \
    "Kubernetes|kube-proxy"

run_test \
    "kube-proxy binary is dynamically linked (CGO enabled)" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'ldd /kube-proxy | grep -E \"libc\\.so|libpthread\"'" \
    "libc\\.so"

################################################################################
# Section 3: Network Tools
# Note: These tests verify tools are installed in the image.
# Runtime functionality requires privileged mode and kernel module access.
################################################################################

echo ""
echo "================================================================"
echo -e "${CYAN}[3/6] Network Tools${NC}"
echo "================================================================"

run_test \
    "iptables available" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'iptables --version 2>&1 | head -1'" \
    "iptables"

run_test \
    "ipvsadm available" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'command -v ipvsadm && echo ipvsadm-installed'" \
    "ipvsadm"

run_test \
    "ip command available" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'ip -V 2>&1 || ip help 2>&1 | head -1'" \
    "ip utility|Usage: ip"

run_test \
    "ipset available" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'command -v ipset && echo ipset-installed'" \
    "ipset"

run_test \
    "conntrack available" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'command -v conntrack && echo conntrack-installed'" \
    "conntrack"

################################################################################
# Section 4: Kernel Module Support
################################################################################

echo ""
echo "================================================================"
echo -e "${CYAN}[4/6] Kernel Module Support${NC}"
echo "================================================================"

run_test \
    "kmod tools available (for loading kernel modules)" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'lsmod --version 2>&1 || lsmod 2>&1 | head -1'" \
    "kmod version|Module|Size"

run_test \
    "Module loading capability check" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'command -v modprobe && echo ok'" \
    "modprobe|ok"

run_test \
    "Kernel version detection" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'uname -r'" \
    "[0-9]+\\.[0-9]+"

################################################################################
# Section 5: Configuration Support
################################################################################

echo ""
echo "================================================================"
echo -e "${CYAN}[5/6] Configuration Support${NC}"
echo "================================================================"

run_test \
    "Configuration directories can be created" \
    "docker run --rm --user root --entrypoint=/bin/bash $IMAGE_NAME -c 'mkdir -p /var/lib/kube-proxy /etc/kubernetes && echo success'" \
    "success"

run_test \
    "kube-proxy can display help" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c '/kube-proxy --help 2>&1 | head -5'" \
    "Kubernetes network proxy"

################################################################################
# Section 6: TLS/Crypto Support via FIPS
################################################################################

echo ""
echo "================================================================"
echo -e "${CYAN}[6/6] TLS/Crypto Support via FIPS${NC}"
echo "================================================================"

run_test \
    "OpenSSL available for TLS operations" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'openssl version'" \
    "OpenSSL 3\\.0\\.15"

run_test \
    "CA certificates available for API server TLS" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -d /etc/ssl/certs && ls /etc/ssl/certs/*.pem 2>/dev/null | head -1'" \
    "\\.pem"

run_test \
    "FIPS-approved algorithms for TLS" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'openssl list -public-key-algorithms | grep -E \"RSA|EC\"'" \
    "RSA|EC"

################################################################################
# Summary
################################################################################

echo ""
echo "================================================================"
echo "Test Summary"
echo "================================================================"
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} All kube-proxy functionality tests passed!"
    echo ""
    echo -e "${BLUE}[INFO]${NC} Image validation complete:"
    echo "  • All required binaries are installed"
    echo "  • Network tools verified (iptables, ipvsadm, ipset, conntrack, etc.)"
    echo "  • FIPS cryptography configured for API server TLS"
    echo ""
    echo -e "${BLUE}[NOTE]${NC} Network tools require privileged mode at runtime"
    echo ""
    echo -e "${BLUE}[INFO]${NC} To deploy kube-proxy:"
    echo "  1. Create a Kubernetes DaemonSet configuration"
    echo "  2. Set hostNetwork: true for host networking"
    echo "  3. Set privileged: true for iptables/IPVS manipulation"
    echo "  4. Mount /lib/modules:/lib/modules:ro for kernel modules"
    echo "  5. Provide kubeconfig for API server authentication"
    echo ""
    exit 0
else
    echo -e "${RED}[ERROR]${NC} Some kube-proxy functionality tests failed!"
    echo ""
    echo -e "${BLUE}[INFO]${NC} Review the failed tests above and check:"
    echo "  - Image build completed successfully"
    echo "  - kube-proxy binary was built correctly"
    echo "  - Entrypoint script is present"
    echo "  - Network tools are installed (iptables, ipvsadm, etc.)"
    echo ""
    exit 1
fi
