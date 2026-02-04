# kube-proxy v1.33.5 - FIPS 140-3 Compliant

FIPS 140-3 compliant Docker image for kube-proxy v1.33.5 using wolfSSL FIPS v5 (Certificate #4718) via wolfProvider and golang-fips/go.

## Overview

This implementation provides a **fully FIPS 140-3 compliant** version of kube-proxy that:
- Provides Kubernetes Service networking with full FIPS 140-3 cryptographic compliance
- Uses **wolfSSL FIPS v5.8.2** (Certificate #4718) for all cryptographic operations
- Routes all Go `crypto/*` package calls through **golang-fips/go** → OpenSSL 3.0.15 → **wolfProvider** → wolfSSL FIPS
- **Removes ALL non-FIPS crypto libraries** (GnuTLS, Nettle, libgcrypt, etc.)
- Requires **NO application code changes** - standard Go code works as-is
- Supports **iptables**, **IPVS**, and **nftables** proxy modes with FIPS-compliant TLS for API server communication

### Architecture

```
kube-proxy v1.33.5 (Go binary)
        ↓
golang-fips/go (FIPS-patched Go toolchain)
        ↓
OpenSSL 3.0.15 (provider architecture)
        ↓
wolfProvider v1.1.0 (OpenSSL → wolfSSL bridge)
        ↓
wolfSSL FIPS v5.8.2 (Certificate #4718)
```

### Network Features with FIPS Cryptography

kube-proxy operations that benefit from FIPS compliance:
- **API Server TLS** - TLS 1.2+ with FIPS-approved cipher suites for authentication
- **Metrics Server TLS** - HTTPS endpoint for Prometheus metrics with FIPS TLS
- **Healthcheck TLS** - Secure healthcheck endpoints
- **Certificate Authentication** - Client certificate authentication with FIPS RSA/ECDSA

## Build Variants

Two Dockerfile variants are available:

1. **Dockerfile** - FIPS 140-3 compliant image
2. **Dockerfile.hardened** - FIPS 140-3 + DISA STIG/CIS hardened image

| Feature | Dockerfile | Dockerfile.hardened |
|---------|-----------|---------------------|
| FIPS 140-3 Compliance | Yes | Yes |
| wolfSSL FIPS v5.8.2 | Yes | Yes |
| OpenSSL 3.0.15/3.0.18 | 3.0.15 | 3.0.18 |
| DISA STIG V2R1 | No | Yes |
| CIS Level 1 Server | No | Yes |
| Password Policies | Basic | Enforced |
| Account Lockout | No | Yes |
| Audit Logging | No | Yes |
| SSH Hardening | No | Yes |
| Kernel Hardening | No | Yes |
| File Permissions | Standard | Restricted |
| Package Manager Removal | No | Yes |

## Requirements

### Build Requirements
- Docker 20.10+ with BuildKit support
- 8GB+ RAM available
- 20GB+ free disk space
- `wolfssl_password.txt` file (commercial wolfSSL FIPS package password)

### Required Files
- `Dockerfile` - Standard FIPS build
- `Dockerfile.hardened` - Hardened FIPS build with STIG/CIS controls
- `build-hardened.sh` - Build script for hardened variant
- `openssl-wolfprov.cnf` - OpenSSL configuration
- `fips-startup-check.c` - FIPS validation utility
- `entrypoint.sh` - Container startup script
- `wolfssl_password.txt` - wolfSSL FIPS package password (not committed)

### Runtime Requirements
- Linux kernel 3.10+ (4.19+ recommended for nftables)
- Host network mode (`hostNetwork: true`)
- Privileged container or NET_ADMIN capability
- Kernel modules: `ip_vs`, `nf_conntrack` (for IPVS mode)
- `/lib/modules` volume mount (read-only)

## Quick Start

### 1. Build the Image

#### Standard FIPS Build

```bash
# Basic build
./build.sh

# Build with custom tag
./build.sh --tag my-registry.com/kube-proxy-fips:v1.33.5

# Build and push to registry
./build.sh --push --registry my-registry.com
```

**Build time**: ~50-60 minutes (mostly golang-fips/go compilation)

#### Hardened FIPS Build (STIG/CIS)

```bash
# Build hardened variant with DISA STIG + CIS controls
./build-hardened.sh
```

**Build output**: `kube-proxy:v1.33.5-ubuntu-22.04-fips`  
**Includes**: FIPS 140-3 + DISA STIG V2R1 + CIS Level 1 Server hardening  
**Build artifacts**: Hardened runtime with security configurations in `/etc/security/`, `/etc/audit/`, `/etc/ssh/`, and audit rules. Package managers (apt, dpkg) are removed from the final image to prevent runtime modifications.

#### Manual Build

```bash
# Standard FIPS build
DOCKER_BUILDKIT=1 docker build \
  --secret id=wolfssl_password,src=wolfssl_password.txt \
  -t kube-proxy-fips:v1.33.5-ubuntu-22.04 \
  -f Dockerfile .

# Hardened FIPS build with STIG/CIS
DOCKER_BUILDKIT=1 docker build \
  --secret id=wolfssl_password,src=wolfssl_password.txt \
  -t kube-proxy-fips:v1.33.5-ubuntu-22.04-hardened \
  -f Dockerfile.hardened .
```

### 2. Verify FIPS Compliance

```bash
# Run quick smoke test (12 checks, ~20 seconds)
cd tests
./quick-test.sh

# Run comprehensive test suite (114 checks, ~3-4 minutes)
./run-all-tests.sh
```

### 3. Deploy kube-proxy

#### Kubernetes DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy-fips
  namespace: kube-system
  labels:
    k8s-app: kube-proxy
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      hostNetwork: true
      priorityClassName: system-node-critical
      nodeSelector:
        kubernetes.io/os: linux
      tolerations:
      - operator: Exists
        effect: NoSchedule
      serviceAccountName: kube-proxy
      containers:
      - name: kube-proxy
        image: kube-proxy-fips:v1.33.5-ubuntu-22.04
        command:
        - /kube-proxy
        - --config=/var/lib/kube-proxy/config.conf
        - --hostname-override=$(NODE_NAME)
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /var/lib/kube-proxy
          name: kube-proxy
        - mountPath: /run/xtables.lock
          name: xtables-lock
        - mountPath: /lib/modules
          name: lib-modules
          readOnly: true
      volumes:
      - name: kube-proxy
        configMap:
          name: kube-proxy
      - name: xtables-lock
        hostPath:
          path: /run/xtables.lock
          type: FileOrCreate
      - name: lib-modules
        hostPath:
          path: /lib/modules
```

#### Test Deployment (Standalone)

```bash
# Run with minimal configuration (for testing only)
docker run -d \
  --name kube-proxy-fips \
  --privileged \
  --net=host \
  -v /lib/modules:/lib/modules:ro \
  kube-proxy-fips:v1.33.5-ubuntu-22.04 \
  /kube-proxy --help
```

## Components

### Binary

**kube-proxy** - Kubernetes network proxy that:
- **Service Load Balancing** - Distributes traffic to Service endpoints
- **iptables Mode** - Uses iptables rules for packet forwarding (default)
- **IPVS Mode** - Uses IPVS for high-performance load balancing
- **nftables Mode** - Modern successor to iptables (Kubernetes 1.29+)
- **API Server Communication** - TLS authentication with client certificates
- **Metrics** - Prometheus metrics endpoint
- **Health Checks** - Liveness and readiness probes

### Configuration Files

**Common Files (both variants):**
- `openssl-wolfprov.cnf` - OpenSSL configuration loading wolfProvider
- `fips-startup-check.c` - C utility for runtime FIPS validation
- `entrypoint.sh` - Container startup script with FIPS validation
- `wolfssl_password.txt` - Password for commercial wolfSSL FIPS package (not committed)

**Hardened Variant Additional Files:**
- `/etc/security/pwquality.conf` - Password complexity requirements
- `/etc/security/faillock.conf` - Account lockout configuration
- `/etc/audit/rules.d/stig.rules` - Audit logging rules
- `/etc/ssh/sshd_config.d/99-stig-hardening.conf` - SSH hardening
- `/etc/sysctl.d/99-stig-hardening.conf` - Kernel hardening parameters
- `/etc/sudoers.d/99-stig-hardening` - Sudo logging configuration

## Build Process

Both Dockerfile variants follow the same multi-stage build process with differences in the runtime stage:

### Stage 1: OpenSSL with FIPS Module
- Downloads and compiles OpenSSL (3.0.15 for Dockerfile, 3.0.18 for Dockerfile.hardened)
- Enables FIPS provider support
- Installs to `/usr/local/openssl`

### Stage 2: wolfSSL FIPS v5.8.2
- Downloads commercial wolfSSL FIPS package (password-protected)
- Compiles with FIPS v5 validation
- Runs FIPS hash generation
- Installs to `/usr/local`

### Stage 3: wolfProvider v1.1.0
- Clones wolfProvider from GitHub
- Builds OpenSSL → wolfSSL bridge module
- Installs to OpenSSL modules directory

### Stage 4: golang-fips/go Toolchain
- Clones golang-fips/go repository
- Applies FIPS patches to Go standard library
- Compiles custom Go toolchain (Go 1.24)
- Routes crypto/* to OpenSSL via CGO

### Stage 5: kube-proxy v1.33.5
- Clones Kubernetes v1.33.5 from GitHub
- Builds kube-proxy with golang-fips/go (CGO_ENABLED=1)
- Creates binary: `/kube-proxy`

### Stage 6: FIPS-Compliant Runtime Image
- **CRITICAL**: Copies FIPS components BEFORE apt-get
- Installs runtime dependencies (iptables, ipvsadm, kmod, ipset, conntrack)
- **Hardened variant adds**: libpam-pwquality, auditd, rsyslog-openssl, sudo
- **Removes ALL non-FIPS crypto libraries** (3-step process)
- **Hardened variant applies**: STIG/CIS security configurations (password policies, PAM, audit rules, SSH/kernel hardening, file permissions)
- **Hardened variant removes**: Package managers (apt, dpkg) from runtime
- Verifies FIPS compliance at build time
- Configures entrypoint with validation

## FIPS Compliance Details

### Cryptographic Module
- **wolfSSL FIPS v5.8.2**
- **CMVP Certificate**: #4718
- **Validation Level**: FIPS 140-3
- **Algorithms**: AES, SHA-2, HMAC, RSA, ECDSA, DH, ECDH

### Compliance Verification

The image undergoes multiple FIPS validation stages:

1. **Build-time verification** (Dockerfile RUN commands)
   - wolfProvider loaded before package installation
   - FIPS libraries installed to system locations
   - Non-FIPS crypto libraries removed
   - OpenSSL provider status checked

2. **Runtime validation** (entrypoint.sh)
   - OpenSSL 3.0.15 version check
   - wolfProvider active status
   - wolfSSL FIPS integrity check (CAST)
   - SHA-256 cryptographic operation test

3. **Test suite validation** (tests/)
   - 114 automated checks
   - Binary linkage verification
   - Algorithm blocking tests
   - Complete crypto path validation
   - Network proxy functionality tests

### Non-FIPS Libraries Removed

The following non-FIPS cryptographic libraries are **completely removed**:
- GnuTLS (`libgnutls30`)
- Nettle (`libnettle8`)
- Hogweed (`libhogweed6`)
- libgcrypt (`libgcrypt20`)
- Kerberos crypto (`libk5crypto3`)

This ensures **100% FIPS compliance** with no bypass paths.

## Configuration

### Environment Variables

#### FIPS Configuration
- `OPENSSL_CONF` - Path to OpenSSL config (default: `/usr/local/openssl/ssl/openssl.cnf`)
- `OPENSSL_MODULES` - OpenSSL modules directory (default: `/usr/local/openssl/lib64/ossl-modules`)
- `LD_LIBRARY_PATH` - Includes FIPS OpenSSL and wolfSSL paths

#### kube-proxy Configuration
kube-proxy is configured via ConfigMap or command-line flags.

**Example kube-proxy ConfigMap:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-proxy
  namespace: kube-system
data:
  config.conf: |
    apiVersion: kubeproxy.config.k8s.io/v1alpha1
    kind: KubeProxyConfiguration
    mode: "iptables"  # or "ipvs" for IPVS mode
    clientConnection:
      kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
    clusterCIDR: "10.244.0.0/16"
    metricsBindAddress: "0.0.0.0:10249"
    healthzBindAddress: "0.0.0.0:10256"
```

**IPVS Mode Configuration:**
```yaml
mode: "ipvs"
ipvs:
  scheduler: "rr"  # Round-robin (also: lc, dh, sh, sed, nq)
  syncPeriod: "30s"
  minSyncPeriod: "5s"
```

## Testing

### Test Suites

1. **Quick Test** (`quick-test.sh`)
   - 12 core FIPS validation checks
   - ~20 seconds
   - Smoke test for FIPS compliance

2. **Comprehensive FIPS Compliance** (`verify-fips-compliance.sh`)
   - 51 detailed FIPS checks
   - Binary linkage analysis
   - wolfProvider validation
   - Algorithm testing
   - ~100 seconds

3. **kube-proxy Functionality** (`test-kube-proxy-functionality.sh`)
   - 16 network proxy-specific tests
   - Binary execution tests
   - Network tools availability
   - Kernel module support
   - TLS/Crypto capabilities
   - ~30 seconds

4. **Non-FIPS Algorithm Blocking** (`check-non-fips-algorithms.sh`)
   - 11 algorithm tests
   - Verifies MD5/MD4 blocked
   - Verifies SHA-256/384/512 work
   - Verifies AES encryption works
   - Library removal verification
   - ~15 seconds

5. **Cryptographic Path Validation** (`crypto-path-validation.sh`)
   - 24 crypto stack checks
   - CGO linkage verification
   - Environment validation
   - OpenSSL/wolfProvider/wolfSSL verification
   - ~30 seconds

### Running Tests

```bash
cd tests

# Run all tests
./run-all-tests.sh

# Run individual tests
./quick-test.sh
./verify-fips-compliance.sh
./test-kube-proxy-functionality.sh
./check-non-fips-algorithms.sh
./crypto-path-validation.sh
```

## Troubleshooting

### Build Failures

**wolfSSL package download fails:**
```bash
# Verify wolfssl_password.txt exists and is correct
cat wolfssl_password.txt
```

**golang-fips/go build fails:**
```bash
# Increase Docker memory allocation to 8GB+
# Check Docker Desktop → Settings → Resources → Memory
```

**Kubernetes source clone too slow:**
```bash
# Use a shallow clone (already configured in Dockerfile)
# If still slow, consider using a local copy or mirror
```

### Runtime Issues

**"wolfProvider is NOT loaded" error:**
```bash
# Verify environment variables
docker run --rm kube-proxy-fips:v1.33.5-ubuntu-22.04 env | grep OPENSSL

# Check wolfProvider module
docker run --rm kube-proxy-fips:v1.33.5-ubuntu-22.04 \
  ls -la /usr/local/openssl/lib64/ossl-modules/
```

**kube-proxy fails to start:**
```bash
# Check logs
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=100

# Verify kubeconfig is mounted
kubectl exec -n kube-system <kube-proxy-pod> -- ls -la /var/lib/kube-proxy/
```

**iptables rules not created:**
```bash
# Verify privileged mode
kubectl get daemonset -n kube-system kube-proxy -o yaml | grep privileged

# Check iptables availability
kubectl exec -n kube-system <kube-proxy-pod> -- iptables --version
```

**IPVS mode not working:**
```bash
# Check kernel modules
lsmod | grep ip_vs

# Load modules if missing
modprobe ip_vs
modprobe ip_vs_rr
modprobe nf_conntrack
```

## Performance Considerations

### FIPS Performance Impact

- **TLS operations**: ~10-15% overhead compared to non-FIPS OpenSSL
- **Certificate validation**: ~5-10% overhead for RSA, minimal for ECDSA
- **Service routing**: No measurable impact (iptables/IPVS unaffected)

### Optimization Tips

1. **Use IPVS mode** - Better performance than iptables for large clusters
2. **Adjust sync periods** - Balance between convergence speed and CPU usage
3. **Use ECDSA certificates** - Faster than RSA with FIPS compliance
4. **Enable connection pooling** - Reuse API server connections

## Security

### FIPS Validation

This image provides:
- **FIPS 140-3 Level 1** cryptographic module (wolfSSL FIPS)
- **CMVP Certificate #4718**
- **No non-FIPS bypass paths** - All crypto libraries removed
- **Runtime integrity checks** - Startup validation ensures FIPS mode

### Security Hardening (Dockerfile.hardened)

The hardened variant includes DISA STIG V2R1 and CIS Level 1 Server controls:

- **Password Policies**: 60-day expiration, 7-day minimum age, SHA512 hashing, 15-character minimum length, complexity requirements (STIG UBTU-22-411015, UBTU-22-611015, UBTU-22-611020, UBTU-22-611045)
- **Account Lockout**: 3 failed login attempts with 15-minute lockout, 4-second login delay (STIG UBTU-22-412010, UBTU-22-412020-035)
- **File Permissions**: System executables 0755, /etc/passwd 0644, /etc/shadow 0640, /var/log 0640, no unowned/ungrouped files (STIG UBTU-22-232026, UBTU-22-232055, UBTU-22-232085, UBTU-22-232100, UBTU-22-232120)
- **Kernel Hardening**: ASLR enabled, core dumps disabled, kernel pointer restrictions, TCP SYN cookies, IP forwarding controls (CIS 1.5.1, STIG kernel parameters)
- **Audit Logging**: System call auditing for time changes, identity modifications, privileged actions, login failures (STIG audit rules)
- **SSH Hardening**: Protocol 2 only, root login disabled, key-based authentication, FIPS-approved ciphers/MACs/KEX algorithms, verbose logging (STIG SSH configuration)

### Best Practices

1. **TLS Configuration**
   - Use TLS 1.2 or 1.3 for API server
   - Use FIPS-approved cipher suites
   - Rotate certificates regularly

2. **RBAC**
   - Use dedicated ServiceAccount for kube-proxy
   - Grant minimal RBAC permissions
   - Monitor proxy behavior

3. **Monitoring**
   - Monitor FIPS validation logs
   - Alert on cryptographic errors
   - Track certificate expiration

## License

- **kube-proxy**: Apache License 2.0 (part of Kubernetes)
- **wolfSSL FIPS**: Commercial license required (Certificate #4718)
- **OpenSSL**: Apache License 2.0
- **wolfProvider**: GPLv3

## References

- [Kubernetes kube-proxy Documentation](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
- [wolfSSL FIPS](https://www.wolfssl.com/products/wolfssl-fips/)
- [FIPS 140-3 Standard](https://csrc.nist.gov/publications/detail/fips/140/3/final)
- [golang-fips/go](https://github.com/golang-fips/go)
- [OpenSSL 3.0 Providers](https://www.openssl.org/docs/man3.0/man7/provider.html)

## Support

For issues with:
- **kube-proxy functionality**: [Kubernetes GitHub Issues](https://github.com/kubernetes/kubernetes/issues)
- **FIPS compliance**: Review test suite output and logs
- **Build process**: Check Docker BuildKit is enabled and memory allocation is sufficient
- **wolfSSL FIPS**: Contact wolfSSL support (commercial license holders)

## Changelog

### v1.33.5-fips (2026-02-04)
- Added Dockerfile.hardened with DISA STIG V2R1 + CIS Level 1 Server controls
- Added build-hardened.sh build script for hardened variant
- Hardened variant uses OpenSSL 3.0.18 (updated from 3.0.15)
- Hardened variant includes password policies, account lockout, audit logging, SSH/kernel hardening

### v1.33.5-fips (2026-01-13)
- Initial FIPS 140-3 compliant build
- kube-proxy v1.33.5 (Kubernetes latest stable)
- wolfSSL FIPS v5.8.2 (Certificate #4718)
- golang-fips/go with Go 1.24
- OpenSSL 3.0.15
- wolfProvider v1.1.0
- Ubuntu 22.04 base
- Comprehensive test suite (114 checks)
- Support for iptables, IPVS, and nftables modes
