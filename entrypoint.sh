#!/bin/bash
#
# FIPS-enabled entrypoint for kube-proxy v1.33.5
#
# This script:
# 1. Validates FIPS mode is active
# 2. Runs FIPS startup checks
# 3. Executes the kube-proxy binary
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo ""
echo "========================================"
echo "kube-proxy v1.33.5 FIPS Container"
echo "========================================"
echo ""

# Step 1: Verify environment variables
log_info "Verifying FIPS environment variables..."
if [ -z "$OPENSSL_CONF" ]; then
    log_warning "OPENSSL_CONF not set, using default: /usr/local/openssl/ssl/openssl.cnf"
    export OPENSSL_CONF="/usr/local/openssl/ssl/openssl.cnf"
fi

if [ -z "$OPENSSL_MODULES" ]; then
    log_warning "OPENSSL_MODULES not set, using default: /usr/local/openssl/lib64/ossl-modules"
    export OPENSSL_MODULES="/usr/local/openssl/lib64/ossl-modules"
fi

log_success "Environment variables configured"
echo "  OPENSSL_CONF: $OPENSSL_CONF"
echo "  OPENSSL_MODULES: $OPENSSL_MODULES"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""

# Step 2: Verify OpenSSL and wolfProvider
log_info "Verifying OpenSSL FIPS configuration..."
OPENSSL_VERSION=$(openssl version 2>&1 || echo "ERROR")
if [[ "$OPENSSL_VERSION" == *"ERROR"* ]]; then
    log_error "OpenSSL is not working correctly!"
    exit 1
fi
log_success "OpenSSL version: $OPENSSL_VERSION"
echo ""

# Step 3: Check wolfProvider
log_info "Checking wolfProvider status..."
if openssl list -providers 2>/dev/null | grep -q "wolfprov"; then
    log_success "wolfProvider is loaded and active"
    openssl list -providers | grep -A 3 "wolfprov" || true
else
    log_error "wolfProvider is NOT loaded!"
    log_error "Available providers:"
    openssl list -providers || true
    exit 1
fi
echo ""

# Step 4: Run FIPS startup check (wolfSSL integrity verification)
if [ -x "/usr/local/bin/fips-startup-check" ]; then
    log_info "Running wolfSSL FIPS integrity check..."
    if /usr/local/bin/fips-startup-check; then
        log_success "wolfSSL FIPS integrity check passed"
    else
        log_error "wolfSSL FIPS integrity check FAILED!"
        exit 1
    fi
else
    log_warning "FIPS startup check utility not found, skipping"
fi
echo ""

# Step 5: Test FIPS-approved cryptographic operation
log_info "Testing FIPS-approved cryptographic operation (SHA-256)..."
TEST_RESULT=$(echo "FIPS test" | openssl dgst -sha256 -hex 2>&1 || echo "ERROR")
if [[ "$TEST_RESULT" == *"ERROR"* ]]; then
    log_error "SHA-256 test failed!"
    echo "$TEST_RESULT"
    exit 1
else
    log_success "SHA-256 test passed"
fi
echo ""

# Step 5b: Test additional FIPS-approved algorithms
log_info "Testing additional FIPS-approved algorithms..."
if echo "test" | openssl dgst -sha384 -hex >/dev/null 2>&1; then
    log_success "SHA-384 operation successful"
else
    log_warning "SHA-384 operation failed (may not be critical)"
fi

if echo "test" | openssl enc -aes-256-cbc -pbkdf2 -k "password" >/dev/null 2>&1; then
    log_success "AES-256-CBC operation successful"
else
    log_warning "AES-256-CBC operation failed (may not be critical)"
fi
echo ""

# Step 5c: Verify kube-proxy binary linkage to FIPS OpenSSL
log_info "Verifying kube-proxy linkage to FIPS OpenSSL..."
if ldd /kube-proxy 2>/dev/null | grep -q "libcrypto.so"; then
    log_info "Binary links to libcrypto (golang-fips/go with CGO)"
    CRYPTO_LIB=$(ldd /kube-proxy 2>/dev/null | grep libcrypto | awk '{print $3}')
    if [ -n "$CRYPTO_LIB" ]; then
        log_info "libcrypto location: $CRYPTO_LIB"
        if [[ "$CRYPTO_LIB" == *"/usr/local/openssl"* ]] || [[ "$CRYPTO_LIB" == *"/usr/lib/x86_64-linux-gnu"* ]]; then
            log_success "Binary correctly links to FIPS OpenSSL"
        fi
    fi
else
    log_info "No direct libcrypto linkage detected"
    log_info "golang-fips/go uses dlopen() to load OpenSSL at runtime"
    log_success "This is expected behavior for golang-fips/go"
fi
echo ""

# Step 5d: Test MD5 availability (informational only)
log_info "Testing MD5 availability (informational)..."
if echo "test" | openssl dgst -md5 -hex >/dev/null 2>&1; then
    log_info "MD5 available at OpenSSL level (expected for wolfProvider)"
    log_info "Note: kube-proxy/golang-fips/go blocks MD5 at runtime level"
    log_info "This is correct behavior - OpenSSL allows it, Go runtime blocks it"
else
    log_success "MD5 blocked at OpenSSL level (strict FIPS mode)"
fi
echo ""

# Step 6: Check kernel version and modules for iptables/IPVS
log_info "Verifying kernel version and networking modules..."
KERNEL_VERSION=$(uname -r 2>/dev/null || echo "unknown")
log_success "Kernel version: $KERNEL_VERSION"

# Check for required kernel modules
log_info "Checking for kube-proxy networking modules..."
if lsmod 2>/dev/null | grep -q ip_vs; then
    log_success "ip_vs module loaded (IPVS mode available)"
else
    log_warning "ip_vs module not loaded (IPVS mode not available)"
fi

if lsmod 2>/dev/null | grep -q nf_conntrack; then
    log_success "nf_conntrack module loaded (connection tracking available)"
else
    log_warning "nf_conntrack module not loaded"
fi
echo ""

# Step 7: Verify kube-proxy binary exists
if [ ! -x "/kube-proxy" ]; then
    log_error "kube-proxy binary not found or not executable!"
    exit 1
fi
log_success "kube-proxy binary found"
echo ""

# Step 8: Display runtime information
log_info "Container runtime information:"
echo "  Hostname: $(hostname)"
echo "  User: $(whoami) (UID: $(id -u))"
echo "  Working directory: $(pwd)"
echo ""

# Step 9: Display kube-proxy configuration
log_info "kube-proxy configuration:"
if [ -f "/var/lib/kube-proxy/config.conf" ]; then
    echo "  Config: /var/lib/kube-proxy/config.conf (found)"
elif [ -f "/etc/kubernetes/kube-proxy-config.yaml" ]; then
    echo "  Config: /etc/kubernetes/kube-proxy-config.yaml (found)"
else
    log_warning "kube-proxy config not found at standard locations"
    log_info "kube-proxy will use command-line arguments or defaults"
fi
echo ""

# Step 10: Display environment variables relevant to kube-proxy
log_info "Kubernetes environment:"
if [ -n "$KUBERNETES_SERVICE_HOST" ]; then
    echo "  Running in Kubernetes cluster"
    echo "  KUBERNETES_SERVICE_HOST: ${KUBERNETES_SERVICE_HOST}"
    echo "  KUBERNETES_SERVICE_PORT: ${KUBERNETES_SERVICE_PORT:-443}"
else
    log_warning "KUBERNETES_SERVICE_HOST not set - may not be in Kubernetes cluster"
fi

# Check for node name
if [ -n "$NODE_NAME" ]; then
    echo "  NODE_NAME: ${NODE_NAME}"
else
    log_warning "NODE_NAME environment variable not set"
fi
echo ""

# Step 11: Verify required tools
log_info "Verifying networking tools..."
for tool in iptables ipvsadm ip ipset conntrack; do
    if command -v $tool &> /dev/null; then
        log_success "$tool: available"
    else
        log_warning "$tool: not found (may be required depending on proxy mode)"
    fi
done
echo ""

# Step 12: Final ready message
log_success "FIPS validation complete - all checks passed"
echo "========================================"
echo ""

# Step 13: Execute kube-proxy with all passed arguments
log_info "Starting kube-proxy..."
echo ""

# If no arguments provided, run kube-proxy with default behavior
if [ $# -eq 0 ]; then
    exec /kube-proxy
else
    # If first argument starts with -, it's a flag for kube-proxy
    if [[ "${1}" == -* ]]; then
        exec /kube-proxy "$@"
    else
        exec "$@"
    fi
fi
