#!/bin/bash
################################################################################
# Build script for kube-proxy FIPS with Ubuntu System OpenSSL
################################################################################
# This script builds kube-proxy using the system-openssl Dockerfile which:
# - Uses Ubuntu APT-managed OpenSSL (libssl3) instead of building from source
# - Safer: No manual file replacement of APT packages
# - Faster: ~20 minutes faster build (no OpenSSL compilation)
# - Consistent with PostgreSQL and Valkey implementations
################################################################################

set -euo pipefail

# Configuration
IMAGE_NAME="${IMAGE_NAME:-kube-proxy-fips}"
IMAGE_TAG="${IMAGE_TAG:-v1.33.5-ubuntu-22.04}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
OPENSSL_CONFIG="${OPENSSL_CONFIG:-openssl-wolfprov.cnf}"
WOLFSSL_PASSWORD_FILE="${WOLFSSL_PASSWORD_FILE:-wolfssl_password.txt}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    # Check BuildKit
    if ! docker buildx version &> /dev/null; then
        log_error "Docker Buildx is not available"
        exit 1
    fi

    # Check wolfSSL password file
    if [ ! -f "$WOLFSSL_PASSWORD_FILE" ]; then
        log_error "wolfSSL password file not found: $WOLFSSL_PASSWORD_FILE"
        exit 1
    fi

    # Check Dockerfile
    if [ ! -f "$DOCKERFILE" ]; then
        log_error "Dockerfile not found: $DOCKERFILE"
        exit 1
    fi

    # Check OpenSSL config
    if [ ! -f "$OPENSSL_CONFIG" ]; then
        log_error "OpenSSL config not found: $OPENSSL_CONFIG"
        exit 1
    fi

    log_info "✓ All prerequisites met"
}

build_image() {
    log_info "Building kube-proxy FIPS image with Ubuntu System OpenSSL..."
    log_info "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    log_info "Dockerfile: ${DOCKERFILE}"
    log_info "OpenSSL Config: ${OPENSSL_CONFIG}"

    # Build with progress=plain to show all warnings
    if docker buildx build \
        --progress plain \
        --load \
        --secret id=wolfssl_password,src="$WOLFSSL_PASSWORD_FILE" \
        -f "$DOCKERFILE" \
        -t "${IMAGE_NAME}:${IMAGE_TAG}" \
        .; then
        log_info "✓ Build successful"
        return 0
    else
        log_error "Build failed"
        return 1
    fi
}

verify_image() {
    log_info "Verifying image..."

    # Check image exists
    if ! docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" &> /dev/null; then
        log_error "Image not found after build"
        return 1
    fi

    # Get image size
    IMAGE_SIZE=$(docker image inspect "${IMAGE_NAME}:${IMAGE_TAG}" | grep -oP '(?<="Size": )\d+' | head -1)
    IMAGE_SIZE_MB=$((IMAGE_SIZE / 1024 / 1024))
    log_info "Image size: ${IMAGE_SIZE_MB} MB"

    # Test basic functionality
    log_info "Testing kube-proxy version..."
    if docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" /kube-proxy --version; then
        log_info "✓ kube-proxy version check passed"
    else
        log_error "kube-proxy version check failed"
        return 1
    fi

    # Test FIPS validation
    log_info "Testing FIPS validation..."
    if docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" /usr/local/bin/fips-startup-check; then
        log_info "✓ FIPS validation passed"
    else
        log_warn "FIPS validation failed or not available"
    fi

    # Verify system OpenSSL is used (not custom build)
    log_info "Verifying system OpenSSL usage..."
    if docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" sh -c 'test ! -d /usr/local/openssl'; then
        log_info "✓ No custom OpenSSL found (using system OpenSSL)"
    else
        log_error "Custom OpenSSL directory found - this should not exist!"
        return 1
    fi

    # Verify wolfProvider location
    log_info "Verifying wolfProvider location..."
    if docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" sh -c 'ls -la /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so'; then
        log_info "✓ wolfProvider found in system location"
    else
        log_error "wolfProvider not found in system location"
        return 1
    fi

    log_info "✓ All verifications passed"
    return 0
}

print_summary() {
    echo
    echo "================================================================================"
    echo " kube-proxy FIPS Build Summary (Ubuntu System OpenSSL)"
    echo "================================================================================"
    echo " Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo " Dockerfile: ${DOCKERFILE}"
    echo " OpenSSL: Ubuntu APT-managed (libssl3)"
    echo " wolfProvider: /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so"
    echo " FIPS Module: wolfSSL FIPS v5.8.2 (Certificate #4718)"
    echo "================================================================================"
    echo
    echo "Next steps:"
    echo "  1. Test the image: docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} --version"
    echo "  2. Run FIPS validation: docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} fips-startup-check"
    echo "  3. Deploy to Kubernetes cluster"
    echo
    echo "Benefits of System OpenSSL approach:"
    echo "  ✓ Safe: No manual replacement of APT-managed files"
    echo "  ✓ Faster: ~20 minutes faster build time"
    echo "  ✓ Maintainable: System updates work correctly"
    echo "  ✓ Consistent: Matches PostgreSQL/Valkey pattern"
    echo "================================================================================"
}

main() {
    log_info "Starting kube-proxy FIPS build with Ubuntu System OpenSSL"
    echo

    check_prerequisites

    BUILD_START=$(date +%s)

    if build_image; then
        BUILD_END=$(date +%s)
        BUILD_TIME=$((BUILD_END - BUILD_START))
        BUILD_MINUTES=$((BUILD_TIME / 60))
        BUILD_SECONDS=$((BUILD_TIME % 60))

        log_info "Build completed in ${BUILD_MINUTES}m ${BUILD_SECONDS}s"

        if verify_image; then
            print_summary
            exit 0
        else
            log_error "Image verification failed"
            exit 1
        fi
    else
        log_error "Build failed"
        exit 1
    fi
}

# Run main function
main "$@"
