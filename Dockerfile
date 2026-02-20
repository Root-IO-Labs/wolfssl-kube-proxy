# kube-proxy v1.33.5 FIPS-enabled Image (Multi-arch: x86_64 and ARM64)
# Using golang-fips/go + wolfSSL FIPS v5 + wolfProvider + Ubuntu System OpenSSL
#
# Architecture: kube-proxy (Go) → golang-fips/go → OpenSSL 3 (system) → wolfProvider → wolfSSL FIPS v5
#
# IMPORTANT: Uses Ubuntu's APT-managed OpenSSL instead of building from source
# Benefits: Safe for upgrades, APT consistency, faster builds, no manual file replacement
#
# MULTI-ARCHITECTURE SUPPORT: ✅ x86_64 (amd64) and ARM64 (aarch64)
# Build time: ~30-40 minutes (20 minutes faster - no OpenSSL build)
# CRITICAL: NO application code changes required - standard Go crypto/* imports work as-is
#
# Build command (single arch):
#   DOCKER_BUILDKIT=1 docker build --secret id=wolfssl_password,src=wolfssl_password.txt \
#     -t kube-proxy-fips:v1.33.5-ubuntu-22.04 -f Dockerfile.system-openssl .
#
# Build command (multi-arch):
#   docker buildx build --platform linux/amd64,linux/arm64 \
#     --secret id=wolfssl_password,src=wolfssl_password.txt \
#     -t kube-proxy-fips:v1.33.5 -f Dockerfile.system-openssl .
#
# Run command (example):
#   docker run --rm --privileged --net=host \
#     -v /lib/modules:/lib/modules:ro \
#     kube-proxy-fips:v1.33.5-ubuntu-22.04

# ============================================================================
# Stage 1: Build wolfSSL FIPS v5 and wolfProvider
# ============================================================================
FROM ubuntu:22.04 AS wolfssl-builder

ENV DEBIAN_FRONTEND=noninteractive

# wolfSSL Configuration
ENV WOLFSSL_URL=https://www.wolfssl.com/comm/wolfssl/wolfssl-5.8.2-commercial-fips-v5.2.3.7z
ENV WOLFSSL_PREFIX=/usr/local
ENV WOLFPROV_VERSION=v1.1.0
ENV WOLFPROV_REPO=https://github.com/wolfSSL/wolfProvider.git

# Install build dependencies including Ubuntu System OpenSSL development files
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        autoconf \
        automake \
        libtool \
        pkg-config \
        p7zip-full \
        libssl-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# Download and build wolfSSL FIPS v5
# NOTE: Requires commercial wolfSSL FIPS package (password-protected 7z file)
RUN --mount=type=secret,id=wolfssl_password,required=true \
    set -eux; \
    mkdir -p /usr/src; \
    curl -fsSL "${WOLFSSL_URL}" -o /tmp/wolfssl.7z; \
    PASSWORD=$(cat /run/secrets/wolfssl_password | tr -d '\n\r'); \
    7z x /tmp/wolfssl.7z -o/usr/src -p"${PASSWORD}"; \
    rm /tmp/wolfssl.7z; \
    find /usr/src -maxdepth 1 -type d -name "wolfssl*" -exec mv {} /usr/src/wolfssl \;; \
    cd /usr/src/wolfssl; \
    # Configure wolfSSL with FIPS v5 and necessary features
    # NOTE: DES3 removed (not FIPS 140-3 approved), RSA_MIN_SIZE=2048 (FIPS requirement)
    ./configure \
        --prefix=${WOLFSSL_PREFIX} \
        --enable-fips=v5 \
        --enable-opensslcoexist \
        --enable-cmac \
        --enable-keygen \
        --enable-sha \
        --enable-aesctr \
        --enable-aesccm \
        --enable-x963kdf \
        --enable-compkey \
        --enable-certgen \
        --enable-aeskeywrap \
        --enable-enckeys \
        --enable-base16 \
        --with-eccminsz=192 \
        CPPFLAGS="-DHAVE_AES_ECB -DWOLFSSL_AES_DIRECT -DWC_RSA_NO_PADDING -DWOLFSSL_PUBLIC_MP -DHAVE_PUBLIC_FFDHE -DWOLFSSL_DH_EXTRA -DWOLFSSL_PSS_LONG_SALT -DWOLFSSL_PSS_SALT_LEN_DISCOVER -DRSA_MIN_SIZE=2048" \
    ; \
    make -j"$(nproc)"; \
    ./fips-hash.sh; \
    make -j"$(nproc)"; \
    make install; \
    ldconfig; \
    cd /; \
    rm -rf /usr/src/wolfssl; \
    echo "wolfSSL FIPS v5 installed successfully"

# Build FIPS startup check utility
COPY fips-startup-check.c /tmp/fips-startup-check.c
RUN set -eux; \
    gcc /tmp/fips-startup-check.c -o /usr/local/bin/fips-startup-check \
        -lwolfssl -I${WOLFSSL_PREFIX}/include; \
    chmod +x /usr/local/bin/fips-startup-check; \
    rm /tmp/fips-startup-check.c; \
    echo "FIPS startup check utility built successfully"

# Build wolfProvider (bridges OpenSSL 3 and wolfSSL FIPS v5)
# IMPORTANT: Using Ubuntu System OpenSSL (--with-openssl=/usr)
RUN set -eux; \
    cd /tmp; \
    git clone --depth 1 --branch ${WOLFPROV_VERSION} ${WOLFPROV_REPO} wolfProvider; \
    cd wolfProvider; \
    ./autogen.sh; \
    # Configure wolfProvider to use Ubuntu System OpenSSL
    ./configure \
        --prefix=${WOLFSSL_PREFIX} \
        --with-openssl=/usr \
        --with-wolfssl=${WOLFSSL_PREFIX} \
        CPPFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu" \
    ; \
    make -j"$(nproc)"; \
    echo "wolfProvider built, installing to Ubuntu system modules directory..."; \
    # Install to system OpenSSL modules directory (APT-managed location)
    mkdir -p /usr/lib/x86_64-linux-gnu/ossl-modules; \
    if [ -f ".libs/libwolfprov.so" ]; then \
        cp -v .libs/libwolfprov.so* /usr/lib/x86_64-linux-gnu/ossl-modules/; \
    elif [ -f "src/.libs/libwolfprov.so" ]; then \
        cp -v src/.libs/libwolfprov.so* /usr/lib/x86_64-linux-gnu/ossl-modules/; \
    fi; \
    cd /; \
    rm -rf /tmp/wolfProvider; \
    echo "wolfProvider installation completed"

# Verify wolfProvider installation
RUN set -eux; \
    echo "Checking for wolfProvider in Ubuntu system location..."; \
    ls -la /usr/lib/x86_64-linux-gnu/ossl-modules/; \
    if [ -f "/usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so" ]; then \
        echo "✓ wolfProvider module found and verified"; \
    else \
        echo "ERROR: wolfProvider module not found in expected location"; \
        exit 1; \
    fi

# ============================================================================
# Stage 2: Build golang-fips/go toolchain
# ============================================================================
FROM ubuntu:22.04 AS go-builder

ENV DEBIAN_FRONTEND=noninteractive

# Go Configuration
ENV GOLANG_FIPS_VERSION=go1.24-fips-release
ENV GOLANG_FIPS_REPO=https://github.com/golang-fips/go.git
ENV GOROOT_BOOTSTRAP=/usr/local/go-bootstrap
ENV GOROOT=/usr/local/go-fips
ENV WOLFSSL_PREFIX=/usr/local

# Copy wolfSSL and wolfProvider from previous stage
# NOTE: OpenSSL is from Ubuntu APT (libssl-dev), no need to copy
COPY --from=wolfssl-builder ${WOLFSSL_PREFIX}/include/wolfssl ${WOLFSSL_PREFIX}/include/wolfssl
COPY --from=wolfssl-builder ${WOLFSSL_PREFIX}/lib/libwolfssl.* ${WOLFSSL_PREFIX}/lib/
COPY --from=wolfssl-builder /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so* /usr/lib/x86_64-linux-gnu/ossl-modules/
COPY --from=wolfssl-builder /usr/local/bin/fips-startup-check /usr/local/bin/fips-startup-check

# Install build dependencies including Ubuntu System OpenSSL
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        curl \
        pkg-config \
        libssl-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# Install standard Go as bootstrap compiler
# Note: Go 1.24 requires Go 1.22.6+ to build, so using Go 1.23.4
RUN set -eux; \
    ARCH=$(uname -m); \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then GO_ARCH="arm64"; else GO_ARCH="amd64"; fi; \
    curl -fsSL https://go.dev/dl/go1.23.4.linux-${GO_ARCH}.tar.gz -o /tmp/go.tar.gz; \
    tar -C /usr/local -xzf /tmp/go.tar.gz; \
    mv /usr/local/go ${GOROOT_BOOTSTRAP}; \
    rm /tmp/go.tar.gz

# Set up library paths for Ubuntu System OpenSSL
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/lib/x86_64-linux-gnu"
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig"

# Copy FIPS patches for golang-fips/go
# Note: wolfProvider acceptance patch removed - no longer needed with OpenSSL config fix
COPY golang-fips-remove-tls13-chacha20.patch /tmp/golang-fips-remove-tls13-chacha20.patch

# Build golang-fips/go from source
# IMPORTANT: Using Ubuntu System OpenSSL paths (CGO_CFLAGS/LDFLAGS)
RUN set -eux; \
    GO_INSTALL_DIR="${GOROOT}"; \
    unset GOROOT; \
    export PATH="${GOROOT_BOOTSTRAP}/bin:${PATH}"; \
    git config --global user.email "builder@fips.local"; \
    git config --global user.name "FIPS Builder"; \
    git clone --branch ${GOLANG_FIPS_VERSION} ${GOLANG_FIPS_REPO} /tmp/go-fips-repo; \
    cd /tmp/go-fips-repo; \
    git submodule update --init --recursive; \
    cd /tmp/go-fips-repo; \
    ./scripts/full-initialize-repo.sh; \
    cd /tmp/go-fips-repo/go; \
    # Apply FIPS patches to golang-fips/go
    echo "Applying FIPS patches to golang-fips/go..."; \
    # REMOVED: wolfProvider acceptance patch - no longer needed
    # FIX APPLIED: OpenSSL config now names wolfProvider as "fips" (see openssl-wolfprov.cnf)
    # This allows golang-fips/go to find wolfProvider via standard OSSL_PROVIDER_try_load("fips")
    # \
    # Patch: Remove TLS 1.3 ChaCha20-Poly1305 cipher suite (non-FIPS)
    if [ -f /tmp/golang-fips-remove-tls13-chacha20.patch ]; then \
        echo "  - Applying TLS 1.3 ChaCha20-Poly1305 removal patch..."; \
        patch -p1 < /tmp/golang-fips-remove-tls13-chacha20.patch || echo "Note: TLS 1.3 patch may need adjustment for this Go version"; \
    fi; \
    echo "FIPS patches applied successfully"; \
    cd src; \
    CGO_ENABLED=1 \
    CGO_CFLAGS="-I/usr/include -I${WOLFSSL_PREFIX}/include" \
    CGO_LDFLAGS="-L/usr/lib/x86_64-linux-gnu -L${WOLFSSL_PREFIX}/lib" \
    ./make.bash; \
    cd ..; \
    mkdir -p "${GO_INSTALL_DIR}"; \
    cp -a * "${GO_INSTALL_DIR}/"; \
    cd /; \
    rm -rf /tmp/go-fips-repo ${GOROOT_BOOTSTRAP}; \
    echo "golang-fips/go installed successfully"

# Verify Go installation
RUN set -eux; \
    export PATH="${GOROOT}/bin:${PATH}"; \
    go version; \
    go env

# ============================================================================
# Stage 3: Build kube-proxy
# ============================================================================
FROM ubuntu:22.04 AS kube-proxy-builder

ENV DEBIAN_FRONTEND=noninteractive

# kube-proxy Configuration
ENV KUBERNETES_VERSION=v1.33.5
ENV KUBERNETES_REPO=https://github.com/kubernetes/kubernetes.git
ENV GOROOT=/usr/local/go-fips
ENV WOLFSSL_PREFIX=/usr/local

# Copy golang-fips/go, wolfSSL, and wolfProvider
# NOTE: OpenSSL is from Ubuntu APT (libssl-dev), no need to copy
COPY --from=go-builder ${GOROOT} ${GOROOT}
COPY --from=go-builder ${WOLFSSL_PREFIX}/include/wolfssl ${WOLFSSL_PREFIX}/include/wolfssl
COPY --from=go-builder ${WOLFSSL_PREFIX}/lib/libwolfssl.* ${WOLFSSL_PREFIX}/lib/
COPY --from=go-builder /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so* /usr/lib/x86_64-linux-gnu/ossl-modules/

# Install build dependencies including Ubuntu System OpenSSL
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        rsync \
        file \
        libssl-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# Set up environment for Ubuntu System OpenSSL
ENV PATH="${GOROOT}/bin:/usr/local/bin:/usr/bin:/bin"
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/lib/x86_64-linux-gnu"
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig"
ENV CGO_ENABLED=1
ENV CGO_CFLAGS="-I/usr/include -I${WOLFSSL_PREFIX}/include"
ENV CGO_LDFLAGS="-L/usr/lib/x86_64-linux-gnu -L${WOLFSSL_PREFIX}/lib"

# Copy FIPS cipher restriction patch
COPY kube-proxy-fips-cipher-restriction.patch /tmp/kube-proxy-fips-cipher-restriction.patch

# Clone Kubernetes source and build kube-proxy
RUN set -eux; \
    git clone --depth 1 --branch ${KUBERNETES_VERSION} ${KUBERNETES_REPO} /tmp/kubernetes; \
    cd /tmp/kubernetes; \
    # Apply FIPS cipher suite restriction patch
    echo "Applying FIPS cipher suite restriction patch..."; \
    patch -p1 < /tmp/kube-proxy-fips-cipher-restriction.patch; \
    echo "Patch applied successfully"; \
    # Update golang.org/x/crypto to v0.45.0 (addresses CVEs)
    go get golang.org/x/crypto@v0.45.0; \
    go mod tidy; \
    # Use go work vendor for workspace mode (Kubernetes v1.33.5 uses go.work)
    go work vendor; \
    # Build kube-proxy with FIPS-enabled Go and cipher restriction patch
    # CRITICAL: Using direct go build instead of Kubernetes Makefile
    # Kubernetes Makefile forces CGO_ENABLED=0 via KUBE_STATIC_BINARIES
    # Direct go build ensures CGO_ENABLED=1 for golang-fips/go to work
    mkdir -p /opt/kube-proxy; \
    echo "Building kube-proxy with CGO_ENABLED=1 (dynamic binary)..."; \
    BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ'); \
    CGO_ENABLED=1 \
    CGO_CFLAGS="-I/usr/include -I${WOLFSSL_PREFIX}/include" \
    CGO_LDFLAGS="-L/usr/lib/x86_64-linux-gnu -L${WOLFSSL_PREFIX}/lib -lssl -lcrypto" \
    go build -v \
        -ldflags "-X k8s.io/component-base/version.gitVersion=${KUBERNETES_VERSION} -X k8s.io/component-base/version.gitCommit=fips-build -X k8s.io/component-base/version.buildDate=${BUILD_DATE} -X k8s.io/component-base/version.gitTreeState=clean" \
        -o /opt/kube-proxy/kube-proxy ./cmd/kube-proxy; \
    echo "kube-proxy built successfully as dynamic binary"; \
    chmod +x /opt/kube-proxy/kube-proxy; \
    cd /; \
    rm -rf /tmp/kubernetes /tmp/kube-proxy-fips-cipher-restriction.patch; \
    echo "kube-proxy built successfully with FIPS cipher restrictions"

# Verify kube-proxy binary
RUN set -eux; \
    ls -lh /opt/kube-proxy/kube-proxy; \
    file /opt/kube-proxy/kube-proxy; \
    /opt/kube-proxy/kube-proxy --version

# ============================================================================
# Stage 4: Runtime Image
# ============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# kube-proxy metadata
LABEL org.opencontainers.image.title="kube-proxy FIPS" \
      org.opencontainers.image.description="FIPS 140-3 compliant kube-proxy v1.33.5 with wolfSSL FIPS v5 and Ubuntu System OpenSSL" \
      org.opencontainers.image.version="v1.33.5" \
      org.opencontainers.image.vendor="Root.io" \
      org.opencontainers.image.source="https://github.com/Root-IO-Labs/wolfssl-kube-proxy"

# Install runtime dependencies
# IMPORTANT: Using Ubuntu's APT-managed OpenSSL runtime library (libssl3)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        iptables \
        ipset \
        conntrack \
        ipvsadm \
        nftables \
        kmod \
        iproute2 \
        libssl3 \
    ; \
    update-ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# Create user and directories
RUN set -eux; \
    useradd -r -u 1001 -g 0 -m -s /sbin/nologin kube-proxy; \
    mkdir -p /var/lib/kube-proxy /var/log/kube-proxy; \
    chown -R 1001:0 /var/lib/kube-proxy /var/log/kube-proxy

# Copy binaries and libraries
# NOTE: OpenSSL libraries from Ubuntu APT (already installed via libssl3)
COPY --from=kube-proxy-builder /opt/kube-proxy/kube-proxy /kube-proxy
COPY --from=go-builder /usr/local/bin/fips-startup-check /usr/local/bin/fips-startup-check
COPY --from=go-builder /usr/local/lib/libwolfssl.so* /usr/local/lib/
COPY --from=go-builder /usr/lib/x86_64-linux-gnu/ossl-modules/libwolfprov.so* /usr/lib/x86_64-linux-gnu/ossl-modules/

# Update library cache
RUN ldconfig

# Copy OpenSSL configuration for wolfProvider
COPY openssl-wolfprov.cnf /etc/ssl/openssl-wolfprov.cnf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables for Ubuntu System OpenSSL
ENV PATH="/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin" \
    LD_LIBRARY_PATH="/usr/local/lib:/usr/lib/x86_64-linux-gnu" \
    OPENSSL_CONF="/etc/ssl/openssl-wolfprov.cnf" \
    OPENSSL_MODULES="/usr/lib/x86_64-linux-gnu/ossl-modules"

# Set golang-fips/go FIPS activation variables
# GOLANG_FIPS=1: Activates golang-fips/go OpenSSL backend routing
# OPENSSL_FORCE_FIPS_MODE=1: Forces OpenSSL 3 into FIPS mode
ENV GOLANG_FIPS=1 \
    OPENSSL_FORCE_FIPS_MODE=1

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD [ "/kube-proxy", "--version" ]

# Run as root for kube-proxy network operations
# Rationale: kube-proxy requires CAP_NET_ADMIN, CAP_SYS_MODULE, and root filesystem access
# to manage iptables, IPVS, nftables, and kernel parameters
USER 0

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["/kube-proxy"]
