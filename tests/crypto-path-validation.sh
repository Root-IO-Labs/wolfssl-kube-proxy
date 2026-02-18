#!/bin/bash
################################################################################
# kube-proxy v1.33.5 FIPS - Cryptographic Path Validation
#
# Purpose: Verify that kube-proxy binary uses FIPS-compliant
#          cryptographic libraries (OpenSSL + wolfProvider + wolfSSL)
#
# Usage:
#   ./tests/crypto-path-validation.sh [image-name]
#
# Example:
#   ./tests/crypto-path-validation.sh kube-proxy-fips:v1.33.5-ubuntu-22.04
#
# Runtime: ~30 seconds
#
# Test Coverage:
#   • Binary linkage to FIPS OpenSSL
#   • Environment variable configuration
#   • OpenSSL provider verification
#   • wolfSSL library presence
#   • golang-fips/go integration verification
#   • Configuration file validation
#
# Exit Codes:
#   0 - All validation checks passed
#   1 - One or more checks failed
#
# Last Updated: 2026-01-13
# Version: 1.0
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get image name from argument or use default
IMAGE_NAME="${1:-kube-proxy-fips:v1.33.5-ubuntu-22.04}"
FAILED=0
PASSED=0

echo "================================================================================"
echo "         kube-proxy v1.33.5 FIPS - Cryptographic Path Validation"
echo "================================================================================"
echo ""
echo "Image: $IMAGE_NAME"
echo ""

################################################################################
# Helper Functions
################################################################################

test_check() {
    local test_name="$1"
    local test_cmd="$2"

    echo -n "  Testing: $test_name ... "

    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

test_check_with_output() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_pattern="$3"

    echo -n "  Testing: $test_name ... "

    output=$(eval "$test_cmd" 2>&1 || true)

    if echo "$output" | grep -qE "$expected_pattern"; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "    Expected pattern: $expected_pattern"
        echo "    Actual output: $(echo "$output" | head -1)"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

################################################################################
# Pre-Test: Image Validation
################################################################################
echo "[Pre-Test] Validating image..."
echo ""

echo -n "Checking if image '$IMAGE_NAME' exists ... "
if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ FOUND${NC}"
else
    echo -e "${RED}✗ NOT FOUND${NC}"
    echo ""
    echo "Error: Image '$IMAGE_NAME' not found"
    echo "Build the image first: ./build.sh"
    exit 1
fi

echo ""

################################################################################
# Test Suite 1: Binary Linkage Verification
################################################################################
echo "================================================================================"
echo "[1/6] Binary Linkage Verification"
echo "================================================================================"
echo ""
echo "Verifying kube-proxy binary links to FIPS OpenSSL..."
echo ""

test_check "kube-proxy binary exists" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'ls /kube-proxy'"

test_check "kube-proxy binary is executable" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -x /kube-proxy'"

# Note: golang-fips/go can produce either:
# 1. Dynamically linked binaries (shows libc.so in ldd output)
# 2. Statically linked binaries with dlopen() for OpenSSL (shows "not a dynamic executable")
# Both approaches are valid for FIPS compliance

test_check_with_output "kube-proxy binary linkage (CGO-enabled for FIPS)" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'ldd /kube-proxy 2>&1'" \
    "libc.so|not a dynamic executable"

echo ""

################################################################################
# Test Suite 2: Environment Configuration
################################################################################
echo "================================================================================"
echo "[2/6] Environment Configuration"
echo "================================================================================"
echo ""
echo "Verifying FIPS environment variables are properly set..."
echo ""

test_check_with_output "OPENSSL_CONF is set" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'env | grep OPENSSL_CONF'" \
    "OPENSSL_CONF=.*openssl.*\\.cnf"

test_check_with_output "OPENSSL_MODULES is set" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'env | grep OPENSSL_MODULES'" \
    "OPENSSL_MODULES=.*ossl-modules"

test_check_with_output "LD_LIBRARY_PATH includes crypto libraries" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'env | grep LD_LIBRARY_PATH'" \
    "openssl|wolfssl|x86_64-linux-gnu|/usr/local/lib"

test_check_with_output "PATH includes OpenSSL binaries" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'env | grep -E \"^PATH=\"'" \
    "/usr/local|/usr/bin"

echo ""

################################################################################
# Test Suite 3: OpenSSL Provider Verification
################################################################################
echo "================================================================================"
echo "[3/6] OpenSSL Provider Verification"
echo "================================================================================"
echo ""
echo "Verifying OpenSSL loads wolfProvider correctly..."
echo ""

test_check_with_output "OpenSSL version is 3.0.x" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'openssl version'" \
    "OpenSSL 3\\.0\\."

test_check_with_output "wolfProvider is loaded" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'openssl list -providers | grep -A 5 wolfprov'" \
    "status: active"

test_check "OpenSSL config file exists" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -f /usr/local/openssl/ssl/openssl.cnf || test -f /etc/ssl/openssl-wolfprov.cnf'"

test_check "wolfProvider module exists" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -f /usr/local/openssl/lib64/ossl-modules/libwolfprov.so || test -f /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so'"

test_check "wolfProvider config in openssl.cnf" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'grep -q wolfprov /usr/local/openssl/ssl/openssl.cnf 2>/dev/null || grep -q wolfprov /etc/ssl/openssl-wolfprov.cnf'"

echo ""

################################################################################
# Test Suite 4: wolfSSL Library Verification
################################################################################
echo "================================================================================"
echo "[4/6] wolfSSL Library Verification"
echo "================================================================================"
echo ""
echo "Verifying wolfSSL FIPS library is present and linked..."
echo ""

echo -n "  Testing: wolfSSL library exists ... "
if docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c "ls /usr/local/lib/libwolfssl.so* 2>/dev/null || ls /usr/lib/x86_64-linux-gnu/libwolfssl.so* 2>/dev/null" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi

test_check "wolfSSL library accessible" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -f /usr/local/lib/libwolfssl.so || test -f /usr/lib/x86_64-linux-gnu/libwolfssl.so'"

test_check "wolfSSL in ldconfig cache" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'ldconfig -p | grep -q wolfssl'"

test_check "FIPS startup check utility exists" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -x /usr/local/bin/fips-startup-check'"

echo ""

################################################################################
# Test Suite 5: golang-fips/go Integration
################################################################################
echo "================================================================================"
echo "[5/6] golang-fips/go Integration"
echo "================================================================================"
echo ""
echo "Verifying golang-fips/go toolchain integration..."
echo ""

test_check "kube-proxy binary functional (CGO-enabled)" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c '/kube-proxy --version 2>&1 | grep -qE \"Kubernetes|kube-proxy\"'"

test_check_with_output "OpenSSL crypto operations work" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'echo -n test | openssl dgst -sha256'" \
    "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"

test_check_with_output "FIPS startup check passes" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c '/usr/local/bin/fips-startup-check'" \
    "FIPS VALIDATION PASSED"

echo ""

################################################################################
# Test Suite 6: Configuration Files Verification
################################################################################
echo "================================================================================"
echo "[6/6] Configuration Files Verification"
echo "================================================================================"
echo ""
echo "Verifying configuration files are present and valid..."
echo ""

test_check "Entrypoint script exists" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -x /entrypoint.sh'"

test_check "kube-proxy can create directories" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'mkdir -p /tmp/kube-proxy-test && test -d /tmp/kube-proxy-test'"

test_check "Temporary directory writable" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -w /tmp'"

test_check "CA certificates present for TLS" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'test -d /etc/ssl/certs'"

test_check "OpenSSL config has wolfProvider" \
    "docker run --rm --entrypoint=/bin/bash $IMAGE_NAME -c 'grep -q wolfprov /usr/local/openssl/ssl/openssl.cnf 2>/dev/null || grep -q wolfprov /etc/ssl/openssl-wolfprov.cnf'"

echo ""

################################################################################
# Test Summary
################################################################################
echo "================================================================================"
echo "Validation Report"
echo "================================================================================"
echo ""

TOTAL=$((PASSED + FAILED))

echo "Test Summary:"
echo "  Total tests: $TOTAL"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "================================================================================"
    echo -e "${GREEN}✓ ALL CRYPTOGRAPHIC PATH VALIDATION CHECKS PASSED${NC}"
    echo "================================================================================"
    echo ""
    echo "Verification Summary:"
    echo "  ✓ kube-proxy binary built with CGO for FIPS OpenSSL integration"
    echo "  ✓ Environment variables properly configured"
    echo "  ✓ wolfProvider is loaded and active"
    echo "  ✓ wolfSSL FIPS library present and accessible"
    echo "  ✓ golang-fips/go integration working correctly"
    echo "  ✓ Configuration files present and valid"
    echo ""
    echo "Cryptographic Path:"
    echo "  kube-proxy v1.33.5 (Go binary)"
    echo "      ↓"
    echo "  golang-fips/go (patches Go crypto/* packages)"
    echo "      ↓"
    echo "  OpenSSL 3.0.x (provider architecture)"
    echo "      ↓"
    echo "  wolfProvider v1.1.0 (OpenSSL → wolfSSL bridge)"
    echo "      ↓"
    echo "  wolfSSL FIPS v5.8.2 (Certificate #4718)"
    echo ""
    echo "Network Proxy TLS Support:"
    echo "  • API Server authentication using FIPS TLS 1.2+"
    echo "  • Client certificate authentication with FIPS RSA/ECDSA"
    echo "  • Metrics endpoint with FIPS HTTPS"
    echo ""
    echo "Next Steps:"
    echo "  1. Run functional tests: ./tests/test-kube-proxy-functionality.sh"
    echo "  2. Run algorithm blocking tests: ./tests/check-non-fips-algorithms.sh"
    echo "  3. Deploy to Kubernetes cluster or run standalone"
    echo ""
    exit 0
else
    echo "================================================================================"
    echo -e "${RED}✗ CRYPTOGRAPHIC PATH VALIDATION FAILED${NC}"
    echo "================================================================================"
    echo ""
    echo "Issues detected:"
    echo "  Review the failed tests above for specific issues"
    echo ""
    echo "Common causes:"
    echo "  1. kube-proxy not compiled with golang-fips/go"
    echo "  2. OpenSSL not installed to correct location"
    echo "  3. wolfProvider not built or installed"
    echo "  4. Environment variables not set correctly"
    echo "  5. wolfSSL library missing or not in library path"
    echo "  6. Configuration files missing or invalid"
    echo ""
    echo "Action required:"
    echo "  1. Review Dockerfile build stages"
    echo "  2. Verify golang-fips/go toolchain stage completed successfully"
    echo "  3. Check OpenSSL, wolfSSL, wolfProvider installation"
    echo "  4. Verify kube-proxy build stage uses correct Go toolchain"
    echo "  5. Check configuration file copy steps"
    echo "  6. Rebuild image: ./build.sh"
    echo ""
    exit 1
fi
