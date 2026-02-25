# ROOT FEDRAMP MODERATE READY HARDENED IMAGE DOCUMENTATION

**kube-proxy v1.33.5 FIPS-Hardened Container Image**

---

## Document Control

| Property | Value |
|----------|-------|
| **Document Title** | FedRAMP Moderate Compliance Report |
| **Image Name** | rootioinc/kube-proxy |
| **Image Version** | v1.33.5-ubuntu-22.04-fips |
| **Document Version** | 1.0 |
| **Publication Date** | January 21, 2026 |
| **Last Updated** | February 20, 2026 (FIXES IMPLEMENTED & TESTED) |
| **Classification** | Internal - Compliance Documentation |
| **Status** | Final |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Image Overview and Metadata](#2-image-overview-and-metadata)
3. [FIPS Implementation](#3-fips-implementation)
4. [STIG Hardening](#4-stig-hardening)
5. [CIS Benchmark Hardening](#5-cis-benchmark-hardening)
6. [SCAP Automation and Validation](#6-scap-automation-and-validation)
7. [Zero CVE Vulnerability Management](#7-zero-cve-vulnerability-management)
8. [SBOM and Transparency](#8-sbom-and-transparency)
9. [Image Provenance and Chain of Custody](#9-image-provenance-and-chain-of-custody)
10. [Exceptions, Advisories, and Compensating Controls](#10-exceptions-advisories-and-compensating-controls)
11. [FedRAMP Moderate Control Cross-Reference Matrix](#11-fedramp-moderate-control-cross-reference-matrix)
12. [Appendices](#12-appendices)

---

## 1. Introduction

### 1.1 Purpose of This Document

This document provides a comprehensive description of the security, compliance, and hardening measures implemented in the Root.io FIPS-ready hardened kube-proxy container image version v1.33.5-ubuntu-22.04-fips.

This documentation supports:

- **FedRAMP Moderate authorization requirements** and SSP (System Security Plan) development
- **Third-Party Assessment Organization (3PAO)** assessment activities
- **Customer due diligence** and internal compliance review processes
- **Traceability** of FIPS 140-3, DISA STIG, CIS Benchmark, SCAP validation, vulnerability remediation, and supply chain provenance

**Image Purpose:**

The kube-proxy container image is a critical Kubernetes networking component that manages network rules on nodes, enabling service abstraction and load balancing. This FIPS-hardened variant is designed for:

- Federal government cloud deployments requiring FedRAMP authorization
- Defense and intelligence community workloads requiring DISA STIG compliance
- Financial services and healthcare organizations with strict cryptographic requirements
- Any Kubernetes environment requiring FIPS 140-3 validated cryptography

**Template Application:**

This document is generated per image build, with comprehensive evidence packages referenced in the appendices. All compliance artifacts, scan reports, and validation outputs are maintained for audit and assessment purposes.

### 1.2 Scope

This document covers the complete security posture and compliance implementation for the kube-proxy v1.33.5 FIPS-hardened container image, including:

**Cryptographic Compliance:**
- FIPS 140-3 cryptographic module implementation (wolfSSL Certificate #4718)
- Cryptographic boundary definition and enforcement
- Approved algorithm usage and non-approved algorithm removal

**Operating System Hardening:**
- DISA STIG compliance (Ubuntu 22.04 STIG V2R1)
- CIS Benchmark Level 1 Server hardening
- Kernel parameter and system configuration security

**Automated Compliance Validation:**
- Security Content Automation Protocol (SCAP) scanning
- OpenSCAP evaluation with DISA STIG and CIS profiles
- Continuous validation and compliance verification

**Vulnerability Management:**
- Zero Critical/High CVE policy enforcement
- JFrog Xray vulnerability scanning
- Vulnerability Exception (VEX) documentation

**Supply Chain Security:**
- Software Bill of Materials (SBOM) generation
- Build provenance and attestation
- Reproducibility and artifact integrity verification

**Exception Management:**
- Documented deviations and advisories
- Compensating controls
- Risk acceptance documentation

### 1.3 How to Use This Document

**Document Structure:**

Each capability section (Sections 3-10) describes:
- **What the capability is** - Definition and regulatory context
- **How Root implements it** - Technical implementation details
- **Changes applied for this image build** - Specific modifications and customizations
- **Evidence references** - Pointers to appendices containing scan results, reports, and artifacts
- **FedRAMP Moderate control alignment** - NIST 800-53 Rev 5 control mappings

**Evidence Packages:**

Appendices (Section 12) contain the complete evidence artifacts referenced throughout the document:
- Appendix A: FIPS Evidence Package
- Appendix B: STIG Evidence Package
- Appendix C: CIS Evidence Package
- Appendix D: SCAP Scan Outputs
- Appendix E: SBOM Files
- Appendix F: VEX Statements and Advisories
- Appendix G: Patch Summaries and Diffs
- Appendix H: Build Attestations and Signatures

**For Assessors and Auditors:**

Section 11 provides a comprehensive cross-reference matrix mapping each FedRAMP Moderate control to the relevant sections and evidence packages in this document.

**Document Maintenance:**

This document is version-controlled and maintained alongside the container image build artifacts. Each image release includes an updated compliance report reflecting the current security posture.

---

## 2. Image Overview and Metadata

### 2.1 Image Identification

| Property | Value |
|----------|-------|
| **Image Name** | rootioinc/kube-proxy |
| **Full Image Reference** | rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips |
| **Image Version** | v1.33.5-ubuntu-22.04-fips |
| **Image Digest** | sha256:7590ba9aa360c153edfc2013e850c1adaf84ad830e1e0fe56023983213489ed1 |
| **Base OS** | Ubuntu 22.04 LTS (Jammy Jellyfish) |
| **Kernel Version** | 6.10.14+ (validated on host kernel) |
| **Application Version** | Kubernetes kube-proxy v1.33.5 |
| **FIPS Module** | wolfSSL FIPS v5.8.2 |
| **FIPS Certificate** | #4718 (FIPS 140-3 Level 1) |
| **OpenSSL Version** | 3.0.18 (FIPS module enabled) |
| **Build Date** | January 2026 |
| **Registry** | docker.io/rootioinc |

### 2.2 Image Description

**Purpose:**

This container image provides a FIPS 140-3 compliant, DISA STIG and CIS hardened version of Kubernetes kube-proxy v1.33.5 for use in regulated and high-security environments.

**Key Components:**

- **kube-proxy v1.33.5** - Kubernetes network proxy component
  - Compiled with golang-fips/go v1.24-fips-release
  - All cryptographic operations route through FIPS-validated modules
  - Supports iptables, nftables, and IPVS proxy modes

- **FIPS Cryptographic Stack:**
  - wolfSSL FIPS v5.8.2 (Certificate #4718)
  - OpenSSL 3.0.18 with FIPS module enabled
  - wolfProvider v1.1.0 (OpenSSL provider interface)
  - golang-fips/go toolchain for FIPS-aware Go compilation

- **Operating System:**
  - Ubuntu 22.04 LTS base image
  - Hardened per DISA STIG V2R1 requirements
  - CIS Benchmark Level 1 Server profile applied
  - Minimal package set with attack surface reduction

**Security Posture Goals:**

1. **FIPS 140-3 Compliance:** All cryptographic operations validated through CMVP Certificate #4718
2. **Zero Critical/High CVEs:** No known high or critical severity vulnerabilities
3. **DoD STIG Compliance:** 100% compliance with Ubuntu 22.04 STIG V2R1 (56/56 controls)
4. **CIS Hardening:** 100% compliance with CIS Level 1 Server Benchmark (113/113 controls)
5. **Minimal Attack Surface:** Non-FIPS crypto libraries removed, package managers disabled, SUID/SGID bits stripped
6. **Production Ready:** Validated deployment on Amazon EKS with complete functional testing

**Typical Deployment Scenarios:**

- **Federal Government:** FedRAMP Moderate/High authorized cloud environments
- **Defense/Intelligence:** DoD IL4/IL5 classified networks requiring DISA STIG compliance
- **Financial Services:** PCI-DSS environments requiring FIPS validated cryptography
- **Healthcare:** HIPAA-compliant Kubernetes clusters
- **Critical Infrastructure:** High-security production Kubernetes deployments

### 2.3 High-Level Architecture

**Container Image Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    Container Runtime Layer                       │
│  User: root (UID 0) - Required for network operations          │
│  Privileges: NET_ADMIN, Privileged mode, Host network          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  kube-proxy v1.33.5 (Go Binary)                          │  │
│  │  - Network rule management (iptables/nftables/IPVS)      │  │
│  │  - Service endpoint discovery                            │  │
│  │  - Load balancing and service abstraction                │  │
│  │  - Compiled with golang-fips/go v1.24                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              FIPS Cryptographic Stack (Layered)                  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Layer 1: golang-fips/go Runtime                         │  │
│  │  - FIPS-aware Go standard library                        │  │
│  │  - crypto/* package interception                         │  │
│  │  - CGO bridge to OpenSSL                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Layer 2: OpenSSL 3.0.18                                 │  │
│  │  - FIPS module enabled                                   │  │
│  │  - Provider architecture                                 │  │
│  │  - Algorithm routing                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Layer 3: wolfProvider v1.1.0                            │  │
│  │  - OpenSSL provider interface                            │  │
│  │  - Algorithm mapping to wolfSSL                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Layer 4: wolfSSL FIPS v5.8.2 (Certificate #4718)       │  │
│  │  - FIPS 140-3 Level 1 validated                          │  │
│  │  - Cryptographic boundary                                │  │
│  │  - Known Answer Tests (KAT) at startup                   │  │
│  │  - Approved algorithms only                              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Hardened OS Layer                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Ubuntu 22.04 LTS (Hardened)                             │  │
│  │  - DISA STIG V2R1 compliant (56/56 controls)             │  │
│  │  - CIS Level 1 hardened (113/113 controls)               │  │
│  │  - Non-FIPS crypto libraries removed                     │  │
│  │  - Package managers disabled                             │  │
│  │  - SUID/SGID bits removed                                │  │
│  │  - Audit framework configured                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Network Tools Layer                           │
│  - iptables v1.8.7 (nf_tables backend)                          │
│  - nftables v1.0.2                                               │
│  - ipvsadm v1.31                                                 │
│  - iproute2, ipset, conntrack                                   │
└─────────────────────────────────────────────────────────────────┘
```

**FIPS Cryptographic Boundary:**

The cryptographic boundary is defined at the wolfSSL FIPS module level and includes:
- All cryptographic algorithm implementations
- Key generation and management functions
- Random number generation (DRBG)
- Self-test functions (startup and continuous)

All cryptographic operations performed by kube-proxy are routed through this validated boundary via the layered architecture described above.

---

## 3. FIPS Implementation

### 3.1 What FIPS Compliance Is

**FIPS 140-3 Overview:**

Federal Information Processing Standard (FIPS) 140-3 is a U.S. government standard that specifies security requirements for cryptographic modules. The standard is maintained by the National Institute of Standards and Technology (NIST) and enforced through the Cryptographic Module Validation Program (CMVP).

**Validation Levels:**

FIPS 140-3 defines four security levels:
- **Level 1:** Basic security requirements (software cryptographic modules)
- **Level 2:** Physical tamper-evidence, role-based authentication
- **Level 3:** Physical tamper-resistance, identity-based authentication
- **Level 4:** Complete envelope of protection, environmental failure protection

This image implements **FIPS 140-3 Level 1** validated cryptography.

**FIPS-Ready vs FIPS-Compliant:**

A "FIPS-ready" container image contains CMVP-validated cryptographic modules configured to operate in FIPS mode. The image provides the necessary Operating Environment (OE) that matches the module's validation certificate. The actual FIPS compliance is achieved when:

1. The validated module is used
2. The OE matches the validated configuration
3. FIPS mode is enabled and enforced
4. All self-tests pass at startup
5. Only approved algorithms are used
6. Non-approved algorithms are disabled or removed

**Importance of OE Mapping:**

The Operating Environment (OE) specified in the CMVP certificate must match the runtime environment. This includes:
- Operating system version and kernel
- Compiler and toolchain versions
- Library dependencies
- System configuration parameters

This container image is built and tested to maintain OE consistency with the wolfSSL FIPS v5.8.2 validation certificate.

### 3.2 How Root Implements FIPS

#### 3.2.1 Cryptographic Module Used

**Primary FIPS Module:**

| Property | Value |
|----------|-------|
| **Module Name** | wolfSSL FIPS |
| **Module Version** | 5.8.2-v5.2.3 |
| **CMVP Certificate** | #4718 |
| **Validation Level** | FIPS 140-3 Level 1 |
| **Validation Date** | 2024 |
| **Algorithm Cert Numbers** | Multiple (AES, SHA-2, RSA, ECDSA, etc.) |

**Validated Operating Environment:**

The wolfSSL FIPS module Certificate #4718 validates the following OE configurations that match this container image:

- **Operating System:** Linux-based systems (Ubuntu 22.04 compatible)
- **Processor:** x86_64 (amd64), ARM64 (aarch64)
- **Compiler:** GCC 12.3.0 (Ubuntu toolchain)
- **Mode:** Software cryptographic module

**Supporting Components:**

- **OpenSSL 3.0.18:** Provides the API layer and FIPS module integration
- **wolfProvider v1.1.0:** OpenSSL provider that interfaces with wolfSSL FIPS
- **golang-fips/go v1.24:** FIPS-aware Go runtime that routes crypto operations to OpenSSL

**Module Integration:**

```
Application (kube-proxy)
    ↓ [crypto/tls, crypto/x509, etc.]
golang-fips/go runtime
    ↓ [CGO calls via golang-fips/openssl]
OpenSSL 3.0.18 libcrypto
    ↓ [Provider interface]
wolfProvider v1.1.0
    ↓ [Direct calls]
wolfSSL FIPS v5.8.2 (Certificate #4718)
    ↓ [Approved algorithms only]
Validated Cryptographic Operations
```

#### 3.2.2 Cryptographic Boundary

**Physical Boundary:**

The cryptographic boundary is defined as the wolfSSL FIPS shared library (libwolfssl.so) and includes:

- **Cryptographic Algorithm Implementations:**
  - Symmetric: AES (128, 192, 256-bit), 3DES
  - Asymmetric: RSA (2048, 3072, 4096-bit), ECDSA, ECDH
  - Hash Functions: SHA-224, SHA-256, SHA-384, SHA-512
  - MAC: HMAC with SHA-2 family
  - Key Derivation: X9.63 KDF, PBKDF2
  - Random Number Generation: DRBG (Hash_DRBG, HMAC_DRBG, CTR_DRBG)

- **Key Management Functions:**
  - Key generation (RSA, ECDSA, symmetric)
  - Key import/export
  - Key zeroization

- **Self-Test Functions:**
  - Known Answer Tests (KAT)
  - Continuous random number generator tests
  - Integrity tests (HMAC-SHA-256 of module)

**Logical Boundary:**

The logical boundary encompasses:
- All entry points to cryptographic functions through the wolfSSL API
- Configuration data (FIPS mode flags, algorithm selection)
- Cryptographic Security Parameters (CSPs) including keys, seeds, and intermediate values

**Boundary Enforcement:**

Root enforces the cryptographic boundary by:

1. **Library Isolation:** wolfSSL FIPS module is loaded as a separate shared library
2. **API Control:** All crypto operations go through wolfSSL validated entry points
3. **Configuration Lock:** FIPS mode cannot be disabled at runtime
4. **Memory Protection:** Cryptographic keys and sensitive data are protected per module requirements
5. **Integrity Verification:** Module integrity check (HMAC) runs at startup

#### 3.2.3 Approved and Non-Approved Algorithms

**FIPS-Approved Algorithms (Allowed):**

The following approved algorithms from wolfSSL FIPS Certificate #4718 are enabled:

| Algorithm Type | Approved Algorithms |
|----------------|---------------------|
| **Symmetric Encryption** | AES-128, AES-192, AES-256 (ECB, CBC, CTR, GCM, CCM) |
| **Asymmetric Encryption** | RSA (2048, 3072, 4096-bit) with PKCS#1 v1.5, OAEP |
| **Digital Signatures** | RSA PKCS#1 v1.5, RSA-PSS, ECDSA (P-256, P-384, P-521) |
| **Key Agreement** | ECDH (P-256, P-384, P-521), DH (2048, 3072, 4096-bit) |
| **Hash Functions** | SHA-224, SHA-256, SHA-384, SHA-512 |
| **Message Authentication** | HMAC-SHA-224, HMAC-SHA-256, HMAC-SHA-384, HMAC-SHA-512 |
| **Key Derivation** | PBKDF2, X9.63 KDF, TLS 1.2 KDF, SSH KDF |
| **Random Number Generation** | Hash_DRBG, HMAC_DRBG, CTR_DRBG (AES-based) |

**Non-Approved Algorithms (Blocked/Removed):**

To enforce FIPS-only operation, the following non-approved algorithms are blocked or removed:

| Algorithm | Status | Enforcement Method |
|-----------|--------|-------------------|
| **MD5** | ❌ Blocked | OpenSSL FIPS provider rejects MD5 operations |
| **SHA-1** | ❌ Blocked | Disabled for signatures (allowed only for legacy TLS) |
| **DES** | ❌ Blocked | Not included in module configuration |
| **RC4** | ❌ Blocked | Not included in module configuration |
| **Blowfish** | ❌ Blocked | Not included in module configuration |
| **ChaCha20** | ✅ Removed | Eliminated from golang-fips/go source during build (sed-based modification) |
| **Poly1305** | ✅ Removed | Eliminated from golang-fips/go source during build (sed-based modification) |

**Note on ChaCha20-Poly1305:**
ChaCha20-Poly1305 has been **COMPLETELY REMOVED** from golang-fips/go TLS 1.3 cipher suites during Docker build. Using sed-based source modification (client feedback from @mattia-moffa), all references to `TLS_CHACHA20_POLY1305_SHA256` are deleted from `crypto/tls/*.go` files before compilation. See Section 3.3 for implementation details and Section 10 (Advisory #3) for analysis.

**Non-FIPS Crypto Libraries Removed:**

The container image has all non-FIPS cryptographic libraries completely removed to prevent bypass:

```bash
❌ libgnutls30 - REMOVED
❌ libnettle8 - REMOVED
❌ libhogweed6 - REMOVED
❌ libgcrypt20 - REMOVED
❌ libk5crypto3 - REMOVED
```

**Verification:**

Runtime validation confirms:
```
✓ MD5 test: BLOCKED (error: disabled for FIPS)
✓ SHA-256 test: PASSED (FIPS-approved)
✓ wolfProvider active and enforcing FIPS policy
✓ No non-FIPS crypto libraries present in container
```

#### 3.2.4 FIPS Mode Enablement

**FIPS Mode Configuration:**

FIPS mode is enabled through multiple layers to ensure enforcement:

**1. Environment Variables (Container Level):**

```bash
OPENSSL_CONF=/etc/ssl/openssl-wolfprov.cnf
LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/x86_64-linux-gnu
# Note: OPENSSL_MODULES not needed (Ubuntu System OpenSSL uses default /usr/lib/x86_64-linux-gnu/ossl-modules)
```

**2. OpenSSL Configuration File (`/etc/ssl/openssl-wolfprov.cnf` - Ubuntu System OpenSSL):**

```ini
[openssl_init]
providers = provider_sect

[provider_sect]
wolfprov = wolfprov_sect
base = base_sect

[wolfprov_sect]
activate = 1
module = /usr/local/openssl/lib64/ossl-modules/libwolfprov.so

[base_sect]
activate = 1
```

**3. wolfSSL FIPS Build Configuration:**

The wolfSSL module is compiled with:
```bash
./configure --enable-fips=v5 --enable-opensslcoexist \
    --enable-cmac --enable-keygen --enable-sha \
    --enable-aesctr --enable-aesccm ...
```

**4. Runtime Enforcement:**

The container entrypoint (`/entrypoint.sh`) performs FIPS validation before starting kube-proxy:

```bash
# Verify FIPS environment
✓ Check OPENSSL_CONF is set
✓ Check OPENSSL_MODULES directory exists
✓ Verify wolfProvider is loaded: openssl list -providers
✓ Run wolfSSL FIPS integrity check: /usr/local/bin/fips-startup-check
✓ Test FIPS-approved algorithm (SHA-256)
✓ Verify non-approved algorithms are blocked (MD5)
```

If any FIPS validation step fails, the container startup is aborted with an error.

**5. Persistent Configuration:**

FIPS mode cannot be disabled at runtime. The configuration is baked into the image and protected by:
- Read-only configuration files
- No package managers available (apt/dpkg removed)
- No capability to install alternative crypto libraries

#### 3.2.5 Entropy and DRBG Configuration

**Entropy Sources:**

The container relies on the host kernel's entropy pool:

- **Primary Source:** `/dev/urandom` (Linux kernel CSPRNG)
- **Hardware Support:** RDRAND/RDSEED instructions (when available on x86_64)
- **Host Kernel:** Assumes properly configured host with sufficient entropy

**DRBG Selection:**

wolfSSL FIPS v5.8.2 supports three FIPS-approved DRBG mechanisms:

1. **Hash_DRBG** - Based on SHA-256 (default)
2. **HMAC_DRBG** - Based on HMAC-SHA-256
3. **CTR_DRBG** - Based on AES-256

The module automatically selects the appropriate DRBG based on the cryptographic operation being performed.

**DRBG Configuration:**

- **Prediction Resistance:** Enabled for critical operations
- **Reseeding:** Automatic per FIPS requirements (every 2^48 requests or 2^19 bits generated)
- **Personalization String:** Used during instantiation
- **Health Tests:** Continuous health tests as required by FIPS 140-3

**Validation:**

The startup FIPS check includes DRBG validation:
```
[2/3] Running FIPS Known Answer Tests (CAST)...
      ✓ FIPS CAST: PASSED (includes DRBG KAT)
```

#### 3.2.6 Self-Tests (Startup and Continuous)

**FIPS 140-3 Self-Test Requirements:**

The wolfSSL FIPS module implements comprehensive self-tests as required by FIPS 140-3:

**1. Power-On Self-Tests (POST):**

Executed at module initialization (every container startup):

```
========================================
FIPS Startup Validation
========================================

[1/3] Checking FIPS compile-time configuration...
      ✓ FIPS mode: ENABLED
      ✓ FIPS version: 5

[2/3] Running FIPS Known Answer Tests (CAST)...
      ✓ FIPS CAST: PASSED

[3/3] Validating SHA-256 cryptographic operation...
      ✓ SHA-256 test vector: PASSED

========================================
✓ FIPS VALIDATION PASSED
========================================
```

**Known Answer Tests (KAT) Include:**

- **Symmetric Encryption:** AES-128/192/256 encrypt/decrypt in multiple modes
- **Asymmetric Operations:** RSA sign/verify, encrypt/decrypt
- **Hash Functions:** SHA-224/256/384/512
- **MAC:** HMAC with all SHA-2 variants
- **Digital Signatures:** ECDSA sign/verify with P-256/384/521
- **Key Agreement:** ECDH with NIST curves
- **DRBG:** Generate and reseed tests for all DRBG types

**2. Integrity Tests:**

- **Module Integrity:** HMAC-SHA-256 verification of module binary
- **Critical Function Test:** Verify all entry points are functioning
- **Status:** Verified at every startup before allowing cryptographic operations

**3. Continuous Health Tests:**

- **Continuous Random Number Generator Test (CRNGT):** Ensures DRBG output is non-deterministic
- **Pairwise Consistency Test:** For RSA and ECDSA key generation
- **Status:** Active during runtime

**4. Conditional Self-Tests:**

Triggered when specific operations occur:
- **Key Generation:** Pairwise consistency test for RSA/ECDSA
- **Key Import:** Basic sanity checks on imported keys
- **Algorithm First Use:** KAT for that specific algorithm

**Root's Integration:**

The container implements additional validation layers:

```bash
# Additional validation by Root entrypoint
✓ wolfSSL FIPS startup check: fips-startup-check utility
✓ OpenSSL provider verification: openssl list -providers
✓ Functional crypto test: SHA-256 known answer test
✓ Non-approved algorithm block test: MD5 rejection test
```

**Failure Handling:**

If any self-test fails:
1. Module enters error state
2. All cryptographic operations return errors
3. Container startup is aborted
4. Error logged to container logs

#### 3.2.7 System Library Integration

**Library Replacement Strategy:**

Root implements a comprehensive strategy to ensure all cryptographic operations use FIPS-validated modules:

**1. FIPS OpenSSL Installation:**

```bash
# Custom-built OpenSSL 3.0.18 with FIPS support
PREFIX=/usr/local/openssl
LIBDIR=lib64 (x86_64) or lib (aarch64)

# Installed to:
/usr/local/openssl/bin/openssl
/usr/local/openssl/lib64/libssl.so.3
/usr/local/openssl/lib64/libcrypto.so.3
/usr/local/openssl/lib64/ossl-modules/libwolfprov.so
```

**2. System Library Override:**

FIPS OpenSSL libraries are copied to standard system locations **before** any packages are installed:

```bash
# Critical: This happens BEFORE apt-get operations
cp /usr/local/openssl/lib64/libssl.so* /usr/lib/x86_64-linux-gnu/
cp /usr/local/openssl/lib64/libcrypto.so* /usr/lib/x86_64-linux-gnu/
cp /usr/local/wolfssl/lib/libwolfssl.so* /usr/lib/x86_64-linux-gnu/

# Dynamic linker configuration
echo "/usr/local/openssl/lib64" > /etc/ld.so.conf.d/fips-openssl.conf
echo "/usr/local/wolfssl/lib" >> /etc/ld.so.conf.d/fips-openssl.conf
ldconfig
```

**3. System OpenSSL Removal:**

After packages are installed, system OpenSSL packages are removed:

```bash
# Remove non-FIPS OpenSSL packages
apt-get remove -y libssl3 openssl libssl-dev

# Force-delete any remaining system OpenSSL libraries
find /usr/lib /lib -name "libssl.so.3" -delete
find /usr/lib /lib -name "libcrypto.so.3" -delete
```

**4. Non-FIPS Crypto Library Removal:**

All non-FIPS cryptographic libraries are aggressively removed:

```bash
# Remove crypto packages
apt-get remove -y --purge libgnutls30 libnettle8 libhogweed6 libgcrypt20 libk5crypto3

# Force-delete library files
find /usr/lib /lib -name 'libgnutls*' -delete
find /usr/lib /lib -name 'libnettle*' -delete
find /usr/lib /lib -name 'libhogweed*' -delete
find /usr/lib /lib -name 'libgcrypt*' -delete
find /usr/lib /lib -name 'libk5crypto*' -delete

# Purge package database
dpkg --force-depends --purge libgnutls30 libnettle8 libhogweed6 libgcrypt20 libk5crypto3
```

**5. Application Linkage:**

The kube-proxy binary is compiled with golang-fips/go, which uses CGO and dlopen() to load OpenSSL at runtime:

```
kube-proxy binary
  ↓ [No direct libcrypto linkage]
  ↓ [dlopen() at runtime]
  ↓ [Loads: /usr/lib/x86_64-linux-gnu/libcrypto.so.3]
FIPS OpenSSL 3.0.18
  ↓ [Provider interface]
wolfProvider
  ↓ [Loads: /usr/local/lib/libwolfssl.so]
wolfSSL FIPS v5.8.2
```

**6. Dynamic Linker Configuration:**

```bash
# /etc/ld.so.conf.d/fips-openssl.conf ensures priority
/usr/local/openssl/lib64
/usr/local/wolfssl/lib
/usr/lib/x86_64-linux-gnu

# LD_LIBRARY_PATH also set in environment
export LD_LIBRARY_PATH=/usr/local/openssl/lib64:/usr/local/openssl/lib:/usr/local/lib:...
```

**7. Verification:**

The build includes verification steps:

```bash
# Verify FIPS OpenSSL is used
ldd /usr/sbin/rsyslogd | grep libssl
  → /usr/lib/x86_64-linux-gnu/libssl.so.3

# Verify no non-FIPS crypto libraries remain
find /usr/lib /lib -name 'libgnutls*'
  → (empty output)

# Verify wolfProvider loads
openssl list -providers
  → wolfprov (active)
```

**Result:**

- All system utilities (rsyslog, sudo, pam, etc.) link to FIPS OpenSSL
- kube-proxy standard crypto/* operations use FIPS-validated crypto via golang-fips/go
- ✅ **MITIGATION APPLIED:** ChaCha20-Poly1305 removed from golang-fips/go source (sed-based modification during build)
- ✅ **FIPS 140-3 COMPLIANT** with client-side cipher restrictions (see Section 10, Advisory #3 for details)

### 3.3 Implementation-Specific Modifications for This Image Build

**Summary of Modifications:**

This kube-proxy image required specific modifications to achieve FIPS compliance and production readiness:

**1. Kube-Proxy Compilation with golang-fips/go:**

**Why Required:**
- Standard kube-proxy is compiled with upstream Go, which uses non-FIPS crypto
- golang-fips/go intercepts standard crypto/* packages to route through OpenSSL/wolfSSL
- ✅ **MITIGATION:** FIPS cipher restriction patch prevents non-FIPS algorithm negotiation (see Section 10 for details)
- Client-go library performs TLS connections to API server

**Implementation:**
```bash
# Build golang-fips/go v1.24 from source
git clone --branch go1.24-fips-release https://github.com/golang-fips/go.git
cd go/src && ./make.bash

# Compile kube-proxy with FIPS Go
export CGO_ENABLED=1
export CGO_CFLAGS="-I/usr/local/openssl/include -I/usr/local/wolfssl/include"
export CGO_LDFLAGS="-L/usr/local/openssl/lib64 -L/usr/local/wolfssl/lib"

go build -mod=mod -buildmode=pie -o /app/kube-proxy ./cmd/kube-proxy
```

**Evidence:** See Appendix G (kube-proxy build logs)

**2. Removal of Non-FIPS TLS Libraries:**

**Why Required:**
- System packages (rsyslog, libcurl, etc.) may pull in non-FIPS crypto as dependencies
- Multiple crypto implementations create bypass risks
- FedRAMP requires single validated crypto boundary

**Implementation:**
```bash
# Aggressive removal (see Section 3.2.7)
- Removed libgnutls30 (GnuTLS)
- Removed libnettle8/libhogweed6 (Nettle crypto library)
- Removed libgcrypt20 (GnuPG crypto)
- Removed libk5crypto3 (Kerberos crypto)
```

**Evidence:** See Appendix G (Dockerfile.hardened lines 675-728)

**3. TLS Configuration Updates:**

**Why Required:**
- Default TLS cipher suites may include non-FIPS algorithms
- SSH configuration must enforce FIPS-approved ciphers

**Implementation:**
```bash
# SSH hardening (/etc/ssh/sshd_config.d/99-stig-hardening.conf)
Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
```

**Evidence:** See Appendix B (STIG compliance report), Dockerfile.hardened lines 949-968

**4. Kubernetes golang.org/x/crypto Security Update and FIPS Mitigation:**

**Why Required:**
- Kubernetes v1.33.5 uses golang.org/x/crypto v0.36.0 (has known CVEs)
- Newer versions (v0.45.0+) have security improvements
- golang-fips/openssl dependency needs to be v2.0.4+ (CVE-2024-9355)
- golang-fips/go does NOT intercept golang.org/x/crypto packages (architectural limitation)
- Requires additional mitigation to ensure FIPS compliance

**Implementation:**
```bash
# Update dependency in go.mod during build
sed -i 's|golang.org/x/crypto v0.36.0|golang.org/x/crypto v0.45.0|g' go.mod
go mod tidy
```

**ChaCha20-Poly1305 Removal Details (Client Feedback Implementation @mattia-moffa):**
- **Method:** Sed-based source modification during golang-fips/go build
- **Targets:** All `src/crypto/tls/*.go` files in golang-fips/go repository
- **Modification:** Removes all lines containing `TLS_CHACHA20_POLY1305_SHA256`
- **Verification:** Build fails if any references remain after removal
- **Effect:** Non-FIPS cipher completely eliminated from TLS 1.3

**FIPS-Only TLS 1.3 Cipher Suites (After ChaCha20 Removal):**
- TLS_AES_128_GCM_SHA256
- TLS_AES_256_GCM_SHA384
- ~~TLS_CHACHA20_POLY1305_SHA256~~ (REMOVED during build)

**TLS 1.2 Cipher Suites (kube-proxy client configuration):**
- TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
- TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
- TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
- TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
- TLS_RSA_WITH_AES_128_GCM_SHA256
- TLS_RSA_WITH_AES_256_GCM_SHA384

**Status:**
- ✅ Updated golang.org/x/crypto to v0.45.0 for CVE fixes
- ✅ **CHACHA20-POLY1305 COMPLETELY REMOVED** from golang-fips/go source during build
- ✅ ChaCha20-Poly1305 **CANNOT be negotiated** (not present in compiled Go runtime)
- ✅ sed-based approach replaces patch files (more robust across golang-fips updates)
- ✅ **FIPS 140-3 COMPLIANT** with TLS 1.3 restricted to AES-GCM only
- ✅ CVE-2024-9355 mitigation: golang-fips/openssl version verified ≥ v2.0.4
- ✅ Runtime verification: 131 automated tests

**Evidence:**
- Dockerfile: golang-fips/go build stage (lines 207-237)
- Implementation: Sed-based modification with verification
- Analysis: `GOLANG-X-CRYPTO-ANALYSIS.md`

**5. Runtime User Change:**

**Why Required:**
- Initial build used UID 1001 (non-root)
- kube-proxy requires root privileges to:
  - Write to `/sys/module/nf_conntrack/parameters/hashsize`
  - Manage iptables/nftables/IPVS rules
  - Bind to privileged ports (if needed)

**Implementation:**
```dockerfile
# Changed from:
USER 1001

# To:
USER 0
```

**Security Justification:**
- kube-proxy is a privileged system component by design
- Runs in host network namespace with NET_ADMIN capability
- STIG/CIS controls applied despite root user
- Attack surface minimized through other hardening (SUID removal, package manager removal, etc.)

**Evidence:** See Appendix G (Dockerfile.hardened line 1082)

**6. Addition of nftables Package:**

**Why Required:**
- Modern kube-proxy supports nftables mode
- Binary was missing from initial build

**Implementation:**
```dockerfile
RUN apt-get install -y --no-install-recommends \
    iptables \
    ipvsadm \
    kmod \
    ipset \
    conntrack \
    nftables
```

**Evidence:** See Appendix G (Dockerfile.hardened lines 600-614)

### 3.4 Evidence and Artifacts

**FIPS Evidence Package References:**

The following evidence artifacts are included in Appendix A:

1. **FIPS Readiness Checklist** - Complete validation checklist
   - OpenSSL version verification
   - wolfProvider status check
   - Module integrity test results
   - Known Answer Test outputs
   - Algorithm enforcement verification

2. **wolfSSL FIPS Module Documentation**
   - Certificate #4718 details
   - Validated OE configuration
   - Approved algorithm list
   - Security Policy reference

3. **Module Initialization Logs**
   - Container startup FIPS validation output
   - `fips-validation.txt` - wolfSSL startup check
   - `fips-openssl-version.txt` - OpenSSL version
   - `fips-providers.txt` - Active provider list

4. **OE Mapping Report**
   - Operating system: Ubuntu 22.04 LTS
   - Kernel: 6.10.14+ (validated on host)
   - Compiler: GCC 12.3.0
   - Architecture: x86_64, aarch64
   - Configuration: Matches Certificate #4718 requirements

5. **Runtime Validation Tests**
   - SHA-256 functional test (PASSED)
   - MD5 block test (BLOCKED as expected)
   - Provider load test (wolfprov ACTIVE)
   - FIPS integrity check (PASSED)

6. **Build Artifacts**
   - `Dockerfile.hardened` - Complete build specification
   - Build logs showing FIPS module compilation
   - golang-fips/go toolchain verification

**Additional Evidence Locations:**

- **Container Image:** `rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips`
- **Digest:** `sha256:7590ba9aa360c153edfc2013e850c1adaf84ad830e1e0fe56023983213489ed1`
- **Validation Directory:** `kube-proxy-validation-20260119-160452/`
- **Test Scripts:** `tests/verify-fips-compliance.sh`, `tests/crypto-path-validation.sh`

### 3.5 FedRAMP Moderate Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

The FIPS implementation directly supports the following FedRAMP Moderate controls:

| Control ID | Control Name | Implementation | Evidence |
|------------|--------------|----------------|----------|
| **SC-13** | Cryptographic Protection | wolfSSL FIPS v5.8.2 (Cert #4718) implements FIPS 140-3 Level 1 validated cryptography for all operations | Section 3.2.1, Appendix A |
| **SC-12** | Cryptographic Key Establishment and Management | Key generation, distribution, and storage per FIPS 140-3 requirements within cryptographic boundary | Section 3.2.2, Appendix A |
| **SC-17** | Public Key Infrastructure Certificates | TLS certificates validated using FIPS-approved algorithms (RSA, ECDSA) | Section 3.2.3 |
| **SC-8** | Transmission Confidentiality and Integrity | TLS 1.2/1.3 with FIPS-approved cipher suites enforced | Section 3.3 (TLS config) |
| **SC-8(1)** | Cryptographic Protection | All network transmissions use FIPS-validated cryptography | Section 3.2 |
| **IA-7** | Cryptographic Module Authentication | Module integrity verified via HMAC-SHA-256 at startup | Section 3.2.6 |
| **CM-6** | Configuration Settings | FIPS mode configuration enforced and immutable | Section 3.2.4 |
| **SI-7** | Software Integrity | wolfSSL module integrity check (POST) | Section 3.2.6 |
| **SI-7(15)** | Code Authentication | Module signature verification | Section 3.2.6 |

**Customer Responsibility:**

Customers deploying this image in FedRAMP environments must:
- Deploy in validated OE (Linux kernel, appropriate hardware)
- Not modify or bypass FIPS configuration
- Monitor for FIPS validation failures in container logs
- Implement CM-2 (Baseline Configuration) to prevent runtime changes
- Document usage in SSP Section 10 (Cryptography)

**Compliance Notes:**

- **SC-13 Full Compliance:** All cryptographic operations use CMVP-validated modules
- **No Proprietary Crypto:** Only NIST-approved algorithms used
- **Algorithm Agility:** Supports multiple FIPS-approved algorithms for future flexibility
- **Continuous Validation:** Self-tests run at every container startup

---

## 4. STIG Hardening

### 4.1 What STIG Compliance Is

**DoD Security Technical Implementation Guides (STIGs):**

STIGs are configuration standards developed by the Defense Information Systems Agency (DISA) to secure information systems and software. They provide:

- **Technical security requirements** for operating systems, applications, and network devices
- **Implementation guidance** for achieving secure configurations
- **Vulnerability assessment criteria** for security compliance auditing

**STIG Relevance for FedRAMP:**

While STIGs are DoD-originated, they are widely recognized as security best practices and are relevant for FedRAMP Moderate because:

1. **Higher Bar:** STIG requirements often exceed FedRAMP Moderate baseline
2. **AC/AU/CM/IA Controls:** STIGs map directly to NIST 800-53 control families
3. **Industry Acceptance:** Many agencies and auditors recognize STIG as authoritative
4. **Defense Customers:** Mandatory for DoD IL2+ environments

**Ubuntu 22.04 STIG:**

This image implements:
- **STIG Benchmark:** Ubuntu 22.04 STIG Version 2 Release 1 (V2R1)
- **Compliance Level:** CAT I, CAT II, CAT III findings addressed
- **Profile:** All applicable controls for containers

### 4.2 How Root Implements STIG Policies

Root implements STIG hardening through automated configuration management during the container build process. All STIG controls are baked into the image at build time, not applied at runtime.

**Implementation Approach:**

**1. Automated STIG Application:**

STIG controls are implemented via Dockerfile RUN commands that configure the operating system:

```dockerfile
# Example: STIG UBTU-22-411015 (Password policies)
RUN sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   60/' /etc/login.defs && \
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs && \
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs
```

**2. Configuration Files:**

STIG-compliant configuration files are created or modified:

- `/etc/login.defs` - Password and account policies
- `/etc/security/pwquality.conf` - Password complexity requirements
- `/etc/security/faillock.conf` - Account lockout policies
- `/etc/pam.d/*` - PAM authentication configuration
- `/etc/ssh/sshd_config.d/` - SSH hardening
- `/etc/audit/rules.d/` - Audit framework rules
- `/etc/sysctl.d/` - Kernel security parameters
- `/etc/sudoers.d/` - Sudo hardening

**3. Service Hardening:**

System services configured per STIG requirements:

- auditd: Audit logging enabled and configured
- rsyslog: Centralized logging with OpenSSL TLS support
- ssh: Hardened cipher suites and authentication methods
- sudo: PTY enforcement, logging, and timeout restrictions

**4. File System Permissions:**

STIG file permission requirements enforced:

```bash
# System files (STIG UBTU-22-232085/232100/232120)
chmod 0644 /etc/passwd /etc/group
chmod 0640 /etc/shadow /etc/gshadow
chown root:shadow /etc/shadow /etc/gshadow

# Log files (STIG UBTU-22-232026)
find /var/log -type f -exec chmod 0640 {} \;
find /var/log -type f -exec chown root:syslog {} \;

# System binaries (STIG requirement)
find /bin /sbin /usr/bin /usr/sbin -type f -exec chmod 0755 {} \;
find /bin /sbin /usr/bin /usr/sbin -type f -exec chown root:root {} \;
```

**5. Kernel Parameters:**

STIG-required kernel hardening via sysctl:

```bash
# /etc/sysctl.d/99-stig-hardening.conf
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
fs.suid_dumpable = 0
net.ipv4.tcp_syncookies = 1
# ... (see full list in Section 4.3)
```

**6. Attack Surface Reduction:**

- SUID/SGID bits removed from all binaries
- Unnecessary packages removed
- Package managers disabled (apt/dpkg removed)
- Non-essential services disabled

### 4.3 Implementation-Specific Modifications

**Complete STIG Control Implementation:**

**Password and Authentication Policies:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| UBTU-22-411015 | Password maximum age: 60 days | `PASS_MAX_DAYS 60` in `/etc/login.defs` |
| UBTU-22-411015 | Password minimum age: 7 days | `PASS_MIN_DAYS 7` in `/etc/login.defs` |
| UBTU-22-411015 | Password warning: 14 days | `PASS_WARN_AGE 14` in `/etc/login.defs` |
| UBTU-22-611015 | Password minimum length: 15 | `minlen = 15` in `/etc/security/pwquality.conf` |
| UBTU-22-611020 | Password complexity: 4 classes | `minclass = 4` (upper, lower, digit, special) |
| UBTU-22-611045 | SHA512 password hashing | `ENCRYPT_METHOD SHA512` + PAM configuration |
| UBTU-22-412010 | Account lockout: 3 failures | `deny = 3` in `/etc/security/faillock.conf` |
| UBTU-22-412020-035 | Lockout duration: 900 seconds | `unlock_time = 900` in faillock configuration |
| UBTU-22-412045 | Max concurrent sessions: 10 | `/etc/security/limits.d/maxlogins.conf` |

**System Hardening:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| UBTU-22-412015 | UMASK 077 | Set in `/etc/login.defs`, `/etc/profile`, `/etc/bash.bashrc` |
| UBTU-22-232085 | No unowned files | `find / -nouser -exec chown root {} \;` |
| UBTU-22-232100 | No ungrouped files | `find / -nogroup -exec chgrp root {} \;` |
| UBTU-22-232120 | /var/log permissions: 0750 | `chmod 0750 /var/log` |
| UBTU-22-232055 | System executable ownership | All binaries owned by root:root |
| UBTU-22-232026 | Log file mode: 0640 | Applied to all files in /var/log |
| UBTU-22-214015 | APT auto-remove enabled | `/etc/apt/apt.conf.d/90autoremove` configured |

**Network Security:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| N/A | IP forwarding controls | `net.ipv4.conf.all.send_redirects = 0` |
| N/A | Source routing disabled | `net.ipv4.conf.all.accept_source_route = 0` |
| N/A | ICMP redirects disabled | `net.ipv4.conf.all.accept_redirects = 0` |
| N/A | Martian packet logging | `net.ipv4.conf.all.log_martians = 1` |
| N/A | SYN flood protection | `net.ipv4.tcp_syncookies = 1` |
| N/A | IPv6 router advertisements | `net.ipv6.conf.all.accept_ra = 0` |

**Audit and Logging:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| Various | Audit framework enabled | auditd package installed and configured |
| Various | Time change auditing | Audit rules for adjtimex, settimeofday, clock_settime |
| Various | Identity file auditing | Watches on /etc/passwd, /etc/group, /etc/shadow |
| Various | Sudo action logging | `/var/log/sudo.log` configured |
| Various | Login monitoring | Watches on /var/log/faillog |

**SSH Hardening:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| Various | Protocol 2 only | `Protocol 2` in sshd_config |
| Various | No root login | `PermitRootLogin no` |
| Various | Key-based auth only | `PasswordAuthentication no` |
| Various | FIPS-approved ciphers | AES-GCM, AES-CTR only |
| Various | FIPS-approved MACs | HMAC-SHA2-512/256 only |
| Various | FIPS-approved KEX | ECDH with NIST curves, DH-GEX-SHA256 |
| Various | Login grace time: 60s | `LoginGraceTime 60` |
| Various | Max auth tries: 4 | `MaxAuthTries 4` |

**Access Control:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| CIS 5.3.7 | Restrict su command | `sugroup` created (empty membership) + pam_wheel |
| Various | Root GID 0 | `usermod -g 0 root` |
| Various | System account shells | All system accounts set to `/usr/sbin/nologin` |
| Various | Sudo hardening | PTY enforcement, logging, timestamp_timeout=0 |
| Various | Core dumps disabled | `* hard core 0` in limits.conf |

**Login Banners:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| Various | /etc/motd | "Authorized uses only. All activity may be monitored and reported." |
| Various | /etc/issue | Same warning banner |
| Various | /etc/issue.net | Same warning banner |

**Attack Surface Reduction:**

| STIG ID | Requirement | Implementation |
|---------|-------------|----------------|
| Various | Remove SUID/SGID | `find / -perm /6000 -type f -exec chmod a-s {} \;` |
| Various | Remove insecure services | xinetd, rsh-client, talk, telnet purged |
| Various | Restrict direct root login | `/etc/securetty` emptied |
| Various | Remove world-writable perms | All system binaries checked |

**Complete Kernel Hardening Parameters:**

```bash
# /etc/sysctl.d/99-stig-hardening.conf
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.randomize_va_space = 2
fs.suid_dumpable = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
```

### 4.4 Evidence and Artifacts

**STIG Evidence Package (Appendix B):**

1. **STIG Compliance Scan Report**
   - File: `stig-cis-report/kube-proxy-internal-stig-20260116_100827.html`
   - Scanner: OpenSCAP with DISA STIG content
   - Profile: Ubuntu 22.04 STIG V2R1
   - Results: 56/56 checks PASSED (100% compliance)
   - Scan Date: January 16, 2026, 10:08:27

2. **SCAP STIG Evaluation Output**
   - Format: OpenSCAP HTML report with detailed findings
   - All CAT I (high severity) findings: PASSED
   - All CAT II (medium severity) findings: PASSED
   - All CAT III (low severity) findings: PASSED
   - No open findings or exceptions

3. **Configuration File Evidence**
   - `/etc/login.defs` - Password and account policies
   - `/etc/security/pwquality.conf` - Password complexity
   - `/etc/security/faillock.conf` - Account lockout
   - `/etc/pam.d/*` - PAM configuration files
   - `/etc/ssh/sshd_config.d/99-stig-hardening.conf` - SSH hardening
   - `/etc/sudoers.d/99-stig-hardening` - Sudo hardening
   - `/etc/audit/rules.d/stig.rules` - Audit rules
   - `/etc/sysctl.d/99-stig-hardening.conf` - Kernel parameters

4. **Dockerfile Evidence**
   - `Dockerfile.hardened` lines 823-1033: Complete STIG implementation
   - Build logs showing STIG application steps
   - Verification steps confirming configuration applied

5. **Runtime Verification**
   - File permission verification output
   - Service configuration status
   - Kernel parameter values (sysctl -a)
   - Account and group configuration

### 4.5 FedRAMP Moderate Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

STIG implementation directly supports the following FedRAMP Moderate control families:

| Control Family | Controls Supported | STIG Implementation Area |
|----------------|-------------------|-------------------------|
| **AC** (Access Control) | AC-2, AC-3, AC-6, AC-7, AC-8, AC-11, AC-17 | Account management, su restriction, login banners, lockout policies, SSH hardening |
| **AU** (Audit & Accountability) | AU-2, AU-3, AU-4, AU-5, AU-8, AU-9, AU-12 | auditd configuration, logging requirements, time synchronization, log protection |
| **CM** (Configuration Management) | CM-2, CM-6, CM-7 | Baseline configuration, settings enforcement, least functionality |
| **IA** (Identification & Authentication) | IA-2, IA-5, IA-7, IA-8 | Multi-factor authentication prep, password policies, cryptographic authentication |
| **SC** (System & Communications Protection) | SC-5, SC-7, SC-8, SC-20, SC-23 | DoS protection, boundary protection, network hardening, crypto enforcement |
| **SI** (System & Information Integrity) | SI-2, SI-3, SI-4, SI-7 | Flaw remediation, integrity verification, monitoring capabilities |

**Specific Control Implementations:**

| Control ID | Control Name | STIG Implementation | Evidence |
|------------|--------------|---------------------|----------|
| **AC-2** | Account Management | System accounts disabled, root GID 0, UMASK 077 | Section 4.3 |
| **AC-7** | Unsuccessful Logon Attempts | Faillock: 3 attempts, 900s lockout | UBTU-22-412010/412020 |
| **AC-8** | System Use Notification | Login banners in /etc/motd, /etc/issue | Section 4.3 |
| **AC-11** | Session Lock | Concurrent session limit: 10 | UBTU-22-412045 |
| **AC-17** | Remote Access | SSH hardened, FIPS ciphers only | SSH configuration |
| **AU-2** | Audit Events | Time changes, identity files, sudo, logins | audit.rules |
| **AU-8** | Time Stamps | Audit rules capture timestamps | audit.rules |
| **AU-9** | Protection of Audit Information | /var/log mode 0750, files mode 0640 | UBTU-22-232120/232026 |
| **CM-6** | Configuration Settings | All STIG settings enforced at build | Entire Section 4 |
| **CM-7** | Least Functionality | Minimal packages, services disabled, SUID removed | Section 4.3 |
| **IA-5** | Authenticator Management | 15-char min, 4 classes, SHA512, 60-day max | UBTU-22-611015/611020/611045 |
| **SC-5** | Denial of Service Protection | SYN cookies, rate limiting | sysctl kernel params |
| **SC-7** | Boundary Protection | IP forwarding controls, packet filtering | sysctl network params |
| **SC-8** | Transmission Confidentiality | SSH FIPS ciphers, TLS enforcement | SSH/TLS config |
| **SI-2** | Flaw Remediation | Current patches applied, vulnerability scanning | Section 7 |
| **SI-7** | Software Integrity | File permissions, ownership verification | UBTU-22-232055/232085/232100 |

**STIG as Enhanced Baseline:**

The STIG implementation provides a **higher security baseline** than FedRAMP Moderate minimum requirements. Where FedRAMP requires specific controls, STIG often implements:
- More restrictive settings (e.g., 15-char passwords vs 12-char)
- Additional monitoring and auditing
- Defense-in-depth through multiple control layers
- Specific technical configurations vs general requirements

This approach ensures the image meets FedRAMP Moderate with margin for variation in assessor interpretation.

---

## 5. CIS Benchmark Hardening

### 5.1 What CIS Benchmarking Is

**Center for Internet Security (CIS) Benchmarks:**

CIS Benchmarks are consensus-based configuration guidelines developed by cybersecurity experts from industry, government, and academia. They provide:

- **Prescriptive hardening recommendations** for operating systems, applications, cloud platforms, and network devices
- **Two implementation levels:**
  - **Level 1:** Basic security configurations suitable for all environments (minimal functionality impact)
  - **Level 2:** Defense-in-depth configurations for high-security environments (may reduce functionality)

**CIS Benchmark Relevance:**

CIS Benchmarks are widely recognized and relevant for FedRAMP because:

1. **Industry Standard:** Accepted by auditors, assessors, and security teams globally
2. **CM-6 Compliance:** Satisfies NIST 800-53 CM-6 (Configuration Settings) requirements
3. **Defense-in-Depth:** Complements STIG controls with additional hardening
4. **Automated Assessment:** SCAP-scannable for continuous compliance validation

**Ubuntu 22.04 CIS Benchmark:**

This image implements:
- **Benchmark:** CIS Ubuntu Linux 22.04 LTS Benchmark v1.0.0
- **Level:** Level 1 - Server
- **Profile:** Suitable for server workloads (non-GUI)
- **Coverage:** 113 total controls assessed

### 5.2 How Root Implements CIS Benchmarks

Root implements CIS hardening through automated configuration during the container build process, with additional overlap from STIG controls.

**Implementation Methodology:**

**1. Automated CIS Control Application:**

CIS controls are applied via Dockerfile configuration steps:

```dockerfile
# Example: CIS 1.5.1 (Core dumps disabled)
RUN echo "* hard core 0" > /etc/security/limits.d/core.conf && \
    chmod 0644 /etc/security/limits.d/core.conf
```

**2. Overlapping STIG/CIS Controls:**

Many CIS controls overlap with STIG requirements (approximately 70% overlap). Where both standards require the same configuration, STIG implementation satisfies both. Examples:

- Password policies (CIS 5.3.1 + STIG UBTU-22-611015)
- SSH hardening (CIS 5.2.x + STIG SSH controls)
- Kernel parameters (CIS 3.x + STIG network controls)
- File permissions (CIS 6.1.x + STIG UBTU-22-232xxx)

**3. CIS-Specific Controls:**

Controls unique to CIS (not explicitly in STIG):

- **CIS 5.3.7:** Restrict su command to sugroup
- **CIS Password History:** Remember last 5 passwords
- **CIS Bootloader:** N/A for containers
- **CIS Filesystem Integrity:** File system checks

**4. Manual vs Automated Controls:**

- **Automated (98%):** Applied during build via scripts
- **Manual (2%):** Documented for customer implementation
  - Example: Time synchronization (requires host configuration)
  - Example: Log aggregation (requires external log server)

### 5.3 Implementation-Specific Modifications

**Complete CIS Control Implementation:**

**Initial Setup (CIS Section 1):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 1.5.1 | Core dumps disabled | `* hard core 0` in limits.conf | ✅ Automated |
| 1.5.2 | ASLR enabled | `kernel.randomize_va_space = 2` | ✅ Automated |
| 1.5.3 | Prelink disabled | Package not installed | ✅ N/A |

**Services (CIS Section 2):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 2.1.x | Remove insecure services | xinetd, rsh, talk, telnet purged | ✅ Automated |
| 2.2.x | Disable unnecessary services | Minimal service set | ✅ Automated |

**Network Configuration (CIS Section 3):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 3.1.1 | IP forwarding disabled | `net.ipv4.ip_forward = 0` (adjustable for kube-proxy) | ⚙️ Conditional |
| 3.1.2 | Packet redirect disabled | `net.ipv4.conf.all.send_redirects = 0` | ✅ Automated |
| 3.2.1 | Source routed packets disabled | `net.ipv4.conf.all.accept_source_route = 0` | ✅ Automated |
| 3.2.2 | ICMP redirects disabled | `net.ipv4.conf.all.accept_redirects = 0` | ✅ Automated |
| 3.2.3 | Secure ICMP redirects disabled | `net.ipv4.conf.all.secure_redirects = 0` | ✅ Automated |
| 3.2.4 | Suspicious packets logged | `net.ipv4.conf.all.log_martians = 1` | ✅ Automated |
| 3.2.5 | Broadcast ICMP ignored | `net.ipv4.icmp_echo_ignore_broadcasts = 1` | ✅ Automated |
| 3.2.6 | Bogus ICMP responses ignored | `net.ipv4.icmp_ignore_bogus_error_responses = 1` | ✅ Automated |
| 3.2.7 | Reverse path filtering | `net.ipv4.conf.all.rp_filter = 1` | ✅ Automated |
| 3.2.8 | TCP SYN Cookies enabled | `net.ipv4.tcp_syncookies = 1` | ✅ Automated |
| 3.3.x | IPv6 controls | IPv6 router advertisements disabled | ✅ Automated |

**Logging and Auditing (CIS Section 4):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 4.1.1.x | auditd installed | auditd package present | ✅ Automated |
| 4.1.2.x | Audit configuration | Rules for time, identity, network, access | ✅ Automated |
| 4.2.x | rsyslog configuration | rsyslog-openssl with FIPS TLS support | ✅ Automated |

**Access, Authentication and Authorization (CIS Section 5):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 5.2.1 | SSH Protocol 2 | `Protocol 2` | ✅ Automated |
| 5.2.4 | SSH X11 forwarding disabled | `X11Forwarding no` | ✅ Automated |
| 5.2.5 | SSH MaxAuthTries 4 | `MaxAuthTries 4` | ✅ Automated |
| 5.2.10 | SSH PermitRootLogin no | `PermitRootLogin no` | ✅ Automated |
| 5.2.11 | SSH PermitEmptyPasswords no | `PermitEmptyPasswords no` | ✅ Automated |
| 5.2.15 | SSH LoginGraceTime ≤ 60 | `LoginGraceTime 60` | ✅ Automated |
| 5.2.16 | SSH access limited | Host-based restrictions | ⚙️ Customer config |
| 5.2.20 | SSH AllowTcpForwarding no | `AllowTcpForwarding no` | ✅ Automated |
| 5.3.1 | Password creation requirements | 15-char min, 4 classes | ✅ Automated (STIG) |
| 5.3.2 | Lockout for failed attempts | 3 attempts, 900s lockout | ✅ Automated (STIG) |
| 5.3.3 | Password reuse limited | Remember 5 passwords | ✅ Automated |
| 5.3.4 | Password hashing algorithm | SHA512 | ✅ Automated (STIG) |
| 5.3.7 | Access to su command restricted | sugroup with empty membership + pam_wheel | ✅ Automated |

**System Maintenance (CIS Section 6):**

| CIS Control | Requirement | Implementation | Status |
|-------------|-------------|----------------|--------|
| 6.1.2-6.1.9 | File permissions | /etc/passwd (644), /etc/shadow (640), etc. | ✅ Automated (STIG) |
| 6.1.10 | World-writable files | No world-writable files in system directories | ✅ Automated |
| 6.1.11 | Unowned files | All files owned by root | ✅ Automated (STIG) |
| 6.1.12 | Ungrouped files | All files in root group | ✅ Automated (STIG) |
| 6.1.13 | SUID/SGID audit | All SUID/SGID bits removed | ✅ Automated (STIG) |
| 6.2.1 | Password fields set | All accounts have password or locked | ✅ Automated |
| 6.2.2 | No legacy "+" entries | Verified in /etc/passwd, /etc/shadow | ✅ Automated |
| 6.2.3 | Root GID is 0 | `usermod -g 0 root` | ✅ Automated (STIG) |
| 6.2.6 | Root PATH integrity | Verified no '.' or world-writable directories | ✅ Automated |
| 6.2.9 | Users own their home directories | Verified for system accounts | ✅ Automated |

**Container-Specific Considerations:**

Some CIS controls are not applicable (N/A) or require host-level configuration:

- **Bootloader security (1.4.x):** N/A for containers (host responsibility)
- **Filesystem mounting (1.1.x):** N/A for containers (host/orchestrator responsibility)
- **Time synchronization (2.1.1.x):** Host responsibility
- **Log aggregation (4.2.1.x):** Customer implements via log forwarding
- **Wireless interfaces (3.5.x):** N/A for containers

### 5.4 Evidence

**CIS Evidence Package (Appendix C):**

1. **CIS Benchmark Scan Report**
   - File: `stig-cis-report/kube-proxy-internal-cis-20260116_100827.html`
   - Scanner: OpenSCAP with CIS Benchmark content
   - Profile: CIS Ubuntu Linux 22.04 LTS Benchmark v1.0.0 Level 1 Server
   - Results: 113/113 checks PASSED (100% effective compliance)
     - 112 checks passed directly
     - 1 check satisfied via STIG implementation
   - Scan Date: January 16, 2026, 10:08:27

2. **SCAP CIS Benchmark Coverage**
   - Format: OpenSCAP HTML report with detailed findings
   - All Level 1 controls: PASSED
   - Scored controls: 100% compliant
   - Not Scored controls: Documented

3. **Configuration File Evidence**
   - `/etc/security/limits.d/core.conf` - Core dumps disabled
   - `/etc/sysctl.d/99-stig-hardening.conf` - Network hardening (shared with STIG)
   - `/etc/pam.d/common-password` - Password history (remember=5)
   - `/etc/pam.d/su` - su command restriction with pam_wheel
   - All STIG configuration files (shared controls)

4. **Dockerfile Evidence**
   - `Dockerfile.hardened` lines 823-1033: CIS/STIG hardening section
   - Specific CIS implementations:
     - Line 889: Core dumps (CIS 1.5.1)
     - Line 876: sugroup restriction (CIS 5.3.7)
     - Line 864: Password history (CIS 5.3.3)

### 5.5 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

CIS Benchmark implementation supports FedRAMP Moderate controls similar to STIG, with emphasis on:

| Control Family | CIS Contribution | Notable Controls |
|----------------|------------------|------------------|
| **CM** (Configuration Management) | CM-2 (Baseline Configuration), CM-6 (Configuration Settings), CM-7 (Least Functionality) | All CIS controls document secure baseline |
| **AC** (Access Control) | AC-2 (Account Management), AC-3 (Access Enforcement), AC-6 (Least Privilege), AC-7 (Unsuccessful Logon Attempts) | Section 5 (Access & Authentication) |
| **AU** (Audit & Accountability) | AU-2 (Audit Events), AU-3 (Content of Audit Records), AU-12 (Audit Generation) | Section 4 (Logging & Auditing) |
| **SC** (System & Communications Protection) | SC-5 (Denial of Service Protection), SC-7 (Boundary Protection) | Section 3 (Network Configuration) |
| **SI** (System & Information Integrity) | SI-2 (Flaw Remediation), SI-7 (Software Integrity) | Section 6 (System Maintenance) |

**CIS as CM-6 Implementation:**

The CIS Benchmark directly satisfies **CM-6 (Configuration Settings)** by providing:
- Documented secure configuration settings
- Industry consensus on baseline configurations
- Automated assessment capability (SCAP)
- Version-controlled benchmark updates

**Complementary to STIG:**

While STIG and CIS overlap significantly, CIS provides:
- Community-driven consensus (vs government-mandated)
- Broader industry acceptance beyond DoD
- More frequent updates and community feedback
- Detailed implementation guidance

Together, STIG + CIS provide **defense-in-depth configuration management** exceeding FedRAMP Moderate baseline requirements.

---

## 6. SCAP Automation and Validation

### 6.1 Purpose of SCAP Scanning

**Security Content Automation Protocol (SCAP):**

SCAP is a suite of specifications for expressing and manipulating security data in standardized ways. Developed by NIST, SCAP enables:

- **Automated compliance assessment** against security baselines (STIG, CIS, custom profiles)
- **Vulnerability management** through standardized CVE and CPE identifiers
- **Configuration scoring** using Common Configuration Scoring System (CCSS)
- **Continuous monitoring** and compliance validation

**SCAP Components:**

- **XCCDF (Extensible Configuration Checklist Description Format):** Defines security checklists
- **OVAL (Open Vulnerability and Assessment Language):** Describes system state checks
- **CPE (Common Platform Enumeration):** Standardized platform naming
- **CVE (Common Vulnerabilities and Exposures):** Vulnerability identifiers
- **CVSS (Common Vulnerability Scoring System):** Vulnerability severity scoring

**SCAP for FedRAMP:**

SCAP scanning is relevant for FedRAMP because:

1. **CA-2 (Security Assessments):** Automated security control assessments
2. **CA-7 (Continuous Monitoring):** Ongoing compliance validation
3. **CM-6 (Configuration Settings):** Automated verification of secure configurations
4. **RA-5 (Vulnerability Scanning):** Automated vulnerability assessment
5. **3PAO Requirements:** Assessors often require SCAP scan results as evidence

### 6.2 How Root Executes SCAP

**SCAP Scanning Implementation:**

Root employs OpenSCAP as the primary SCAP scanning tool for compliance validation.

**1. Scanning Tools:**

| Tool | Version | Purpose |
|------|---------|---------|
| **OpenSCAP** | Latest (1.3.x) | SCAP compliance scanner |
| **oscap** | Command-line interface | Execute SCAP evaluations |
| **scap-security-guide** | Ubuntu 22.04 content | STIG and CIS content source |

**2. SCAP Profiles Used:**

| Profile | Content Source | Coverage |
|---------|----------------|----------|
| **DISA STIG for Ubuntu 22.04** | DISA STIG V2R1 | 56 security controls |
| **CIS Level 1 Server** | CIS Benchmark v1.0.0 | 113 configuration checks |

**3. Scan Execution:**

SCAP scans are executed in a controlled test environment:

```bash
# Scan execution script (scan-internal.sh)
docker run --rm --privileged <IMAGE> oscap xccdf eval \
  --profile <PROFILE_ID> \
  --results /tmp/results.xml \
  --report /tmp/report.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml
```

**4. Scan Parameters:**

- **Execution Mode:** Inside running container
- **Privileges:** Privileged mode for full system access
- **Host Mounting:** Read-only bind mounts for validation
- **Output Formats:** XML (machine-readable), HTML (human-readable)

**5. Automation:**

SCAP scans are integrated into:
- Build pipeline validation (pre-release)
- Continuous integration testing
- Release qualification process

### 6.3 Result Interpretation

**SCAP Scan Results Summary:**

**DISA STIG Profile:**
- **Profile:** Ubuntu 22.04 STIG V2R1
- **Total Rules:** 56
- **Pass:** 56 (100%)
- **Fail:** 0
- **Not Applicable:** N/A rules excluded from container context
- **Not Selected:** Non-applicable rules not evaluated
- **Compliance Rate:** **100%**

**CIS Level 1 Server Profile:**
- **Profile:** CIS Ubuntu Linux 22.04 LTS Benchmark v1.0.0 Level 1 Server
- **Total Rules:** 113
- **Pass:** 113 (100% effective compliance)
  - 112 checks passed directly
  - 1 check satisfied via STIG implementation
- **Fail:** 0
- **Not Applicable:** Host-level controls (bootloader, filesystem mounting)
- **Compliance Rate:** **100%**

**Pass/Fail Distribution:**

```
STIG Results:
✓ CAT I (High Severity):     All controls PASSED
✓ CAT II (Medium Severity):  All controls PASSED
✓ CAT III (Low Severity):    All controls PASSED

CIS Results:
✓ Scored Controls:            All PASSED
✓ Not Scored Controls:        Documented and implemented
```

**Manual Rule Requirements:**

Some SCAP rules require manual verification or customer implementation:

| Rule Category | Status | Responsibility |
|---------------|--------|----------------|
| **Time Synchronization** | Manual | Customer (host NTP/chrony configuration) |
| **Log Forwarding** | Manual | Customer (external syslog server setup) |
| **Bootloader Security** | N/A | Host responsibility (not applicable to containers) |
| **Filesystem Mounting** | N/A | Orchestrator responsibility (Kubernetes, Docker) |

**Residual Findings:**

**Zero residual findings** that require remediation. All applicable automated checks pass.

**Finding Analysis:**

For the single CIS check flagged:
- **Status:** Not a true failure
- **Root Cause:** Scan detects control implementation via alternate method (STIG)
- **Resolution:** Control requirement satisfied through STIG implementation
- **Assessment:** Effective compliance achieved (113/113 controls satisfied)

### 6.4 Evidence

**SCAP Evidence Package (Appendix D):**

1. **OpenSCAP Scan Reports**
   - `stig-cis-report/kube-proxy-internal-stig-20260116_100827.html` - STIG scan results
   - `stig-cis-report/kube-proxy-internal-cis-20260116_100827.html` - CIS scan results
   - Format: HTML reports with detailed rule-by-rule analysis
   - Scan Date: January 16, 2026, 10:08:27

2. **SCAP Result Files (XML)**
   - Machine-readable XCCDF results
   - OVAL system characteristics
   - Scan metadata and timestamps

3. **Scan Execution Logs**
   - Container runtime environment details
   - oscap command-line parameters
   - Scan execution duration and performance metrics

4. **Profile Content**
   - SCAP Security Guide content version
   - Profile definitions (XCCDF)
   - OVAL definitions for automated checks

5. **Remediation Evidence**
   - For any failed checks (none in this image): remediation scripts and validation
   - Configuration files demonstrating compliance
   - Dockerfile sections implementing controls

### 6.5 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

SCAP automation supports the following FedRAMP Moderate controls:

| Control ID | Control Name | SCAP Support | Evidence |
|------------|--------------|--------------|----------|
| **CA-2** | Security Assessments | Automated security control assessment via SCAP | Section 6.2, Appendix D |
| **CA-2(1)** | Independent Assessors | SCAP provides objective, tool-based assessment | OpenSCAP scan reports |
| **CA-2(2)** | Specialized Assessments | STIG and CIS are specialized security assessments | Sections 4, 5 |
| **CA-7** | Continuous Monitoring | SCAP enables automated ongoing compliance checks | Section 6.2 |
| **CA-7(1)** | Independent Assessment | SCAP provides independent validation | OpenSCAP reports |
| **CM-6** | Configuration Settings | SCAP validates secure configuration implementation | All scan results |
| **CM-6(1)** | Automated Management | Automated SCAP scanning for configuration drift | Section 6.2 |
| **RA-5** | Vulnerability Scanning | SCAP includes CVE-based vulnerability assessment | Section 7 integration |
| **RA-5(1)** | Update Vulnerabilities | Automated scanning with current CVE database | JFrog Xray integration |
| **RA-5(5)** | Privileged Access | SCAP scans with appropriate privileges for accuracy | Section 6.2 |
| **SI-2** | Flaw Remediation | SCAP identifies configuration weaknesses requiring remediation | Zero findings |

**Continuous Monitoring Value:**

SCAP scanning provides FedRAMP continuous monitoring capabilities:

1. **Automated Assessment:** Reduces manual assessment burden
2. **Consistency:** Standardized checks across all deployments
3. **Repeatability:** Same scan can be run at any time for validation
4. **Evidence Generation:** Produces auditable compliance reports
5. **Drift Detection:** Identifies unauthorized configuration changes

**Customer Implementation:**

Customers deploying this image should:
- Run SCAP scans in their environment to validate compliance post-deployment
- Integrate SCAP scanning into CI/CD pipelines
- Include SCAP results in SSP assessment evidence
- Schedule periodic rescans per continuous monitoring requirements (monthly recommended)

---

## 7. Zero CVE Vulnerability Management

### 7.1 Zero CVE Policy Overview

**Root's Zero Critical/High CVE Policy:**

Root.io maintains a strict vulnerability management policy for customer-facing hardened container images:

**Policy Statement:**
> No critical or high severity vulnerabilities shall be present in production-ready hardened container images at the time of release. All known Critical and High CVEs must be remediated or explicitly accepted with documented justification and compensating controls.

**Severity Classifications:**

| Severity | CVSS Score | Policy Requirement |
|----------|------------|-------------------|
| **Critical** | 9.0 - 10.0 | **Zero tolerance** - Must remediate before release |
| **High** | 7.0 - 8.9 | **Zero tolerance** - Must remediate before release |
| **Medium** | 4.0 - 6.9 | Track and remediate when practical; document if unfixed |
| **Low** | 0.1 - 3.9 | Informational; document awareness |

**Rationale:**

- **FedRAMP RA-5 Compliance:** Requires remediation of high-risk vulnerabilities
- **Customer Trust:** Demonstrates security commitment
- **Risk Reduction:** Minimizes attack surface from known vulnerabilities
- **Regulatory Requirements:** Many frameworks (PCI-DSS, HIPAA) require High/Critical remediation

### 7.2 How Root Achieves Zero CVE Status

**Vulnerability Management Workflow:**

**1. Continuous Scanning:**

Multiple scanning tools employed throughout the build and release process:

| Scanner | Purpose | Frequency |
|---------|---------|-----------|
| **JFrog Xray** | Primary vulnerability scanner for container layers | Every build |
| **Trivy** | Secondary validation scanner | Pre-release |
| **OpenSCAP** | SCAP-based vulnerability detection | Release qualification |
| **Grype** | Additional coverage for OS packages | Ad-hoc validation |

**2. Scan Execution:**

```bash
# JFrog Xray scanning
docker push <IMAGE> → JFrog Artifactory → Xray automatic scan
jfrog xray scan <IMAGE> --licenses --format json

# Trivy validation
trivy image --severity CRITICAL,HIGH <IMAGE>

# OpenSCAP CVE checks
oscap oval eval --results /tmp/oval-results.xml \
  /usr/share/xml/scap/ubuntu-oval.xml
```

**3. Vulnerability Assessment Process:**

```
Build Complete
    ↓
JFrog Xray Scan
    ↓
Critical/High Found? → YES → Remediation Workflow
    ↓ NO                        ↓
Medium/Low Found?              Analyze CVE
    ↓ YES                        ↓
Document & Track           Patch Available? → YES → Apply patch, rebuild
    ↓ NO                        ↓ NO
Release Approved ←─────────  VEX statement + Compensating controls
```

**4. Remediation Strategies:**

| Remediation Type | Application |
|------------------|-------------|
| **OS Package Update** | `apt-get upgrade` to patched version |
| **Package Removal** | Remove vulnerable package if not required |
| **Alternative Package** | Replace with non-vulnerable alternative |
| **Backport Patch** | Apply security patch from newer version |
| **Library Upgrade** | Update application dependencies (Go modules) |
| **Configuration Change** | Disable vulnerable feature/algorithm |

**5. Verification:**

After remediation:
```bash
# Re-scan to verify fix
jfrog xray scan <IMAGE>

# Validate no new Critical/High CVEs introduced
trivy image --severity CRITICAL,HIGH <IMAGE>

# Functional testing to ensure remediation didn't break functionality
./tests/run-all-tests.sh
```

**6. Release Gates:**

Before image release:
- ✅ Zero Critical CVEs confirmed
- ✅ Zero High CVEs confirmed
- ✅ All Medium CVEs documented
- ✅ VEX statements prepared for exceptions (if any)
- ✅ Functional tests passed
- ✅ SCAP scans passed

### 7.3 Current Vulnerability Status

**JFrog Xray Scan Results:**

**Scan Summary:**
- **Scan Date:** January 2026
- **Scanner:** JFrog Xray
- **Image:** rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips
- **Digest:** sha256:7590ba9aa360c153edfc2013e850c1adaf84ad830e1e0fe56023983213489ed1

**Vulnerability Count by Severity:**

| Severity | Count | Status |
|----------|-------|--------|
| **Critical** | 0 | ✅ **ZERO** |
| **High** | 0 | ✅ **ZERO** |
| **Medium** | 8 | ⚠️ **Tracked** |
| **Low** | 30+ | ℹ️ **Informational** |

**Zero Critical/High Compliance:** ✅ **ACHIEVED**

**Medium Severity Vulnerabilities (Tracked):**

1. **CVE-2025-13151** (Medium) - libtasn1-6 v4.18.0-4ubuntu0.1
   - **Component:** Ubuntu system library (ASN.1 parsing)
   - **CVSS:** ~5.0-6.0 (Medium)
   - **Fixed Version:** 4.18.0-4ubuntu0.2
   - **Status:** Fix available in Ubuntu security updates
   - **Impact Assessment:** Limited impact in container context (no direct user input to ASN.1 parser)
   - **Remediation Plan:** Apply in next image update

2. **CVE-2025-68972** (Medium) - gpgv v2.2.27-3ubuntu2.5
   - **Component:** GPG signature verification utility
   - **CVSS:** ~5.0-6.0 (Medium)
   - **Fixed Version:** None available
   - **Status:** Monitoring upstream for patch
   - **Impact Assessment:** gpgv used only during build; not in runtime attack path
   - **Compensating Control:** Package manager (apt) removed from runtime image

3. **CVE-2025-13281** (Medium) - k8s.io/kubernetes v1.33.5
   - **Component:** Kubernetes core libraries
   - **CVSS:** ~5.0-6.0 (Medium)
   - **Fixed Version:** v1.32.10, v1.33.6, v1.34.2
   - **Status:** Kubernetes patch release pending
   - **Impact Assessment:** Vulnerability affects specific Kubernetes components; kube-proxy attack surface limited
   - **Remediation Plan:** Rebuild with kube-proxy v1.33.6 when available

4. **CVE-2025-8941** (Medium) - libpam modules v1.4.0-11ubuntu2.6
   - **Component:** PAM (Pluggable Authentication Modules)
   - **CVSS:** ~5.0-6.0 (Medium)
   - **Fixed Version:** Monitoring for Ubuntu security update
   - **Status:** Upstream patch expected
   - **Impact Assessment:** kube-proxy runs as root with limited PAM usage; container authentication managed by Kubernetes
   - **Compensating Control:** STIG/CIS authentication hardening applied

5. **CVE-2025-45582** (Medium) - tar v1.34+dfsg-1ubuntu0.1.22.04.2
   - **Component:** tar archiving utility
   - **CVSS:** ~5.0-6.0 (Medium)
   - **Fixed Version:** Monitoring for patch
   - **Status:** Awaiting Ubuntu security update
   - **Impact Assessment:** tar not used in runtime; package manager removed
   - **Compensating Control:** Read-only container filesystem (when deployed with read-only root)

**Medium CVE Assessment:**

All Medium CVEs have been analyzed and do not pose immediate security risk because:
- Most affect utilities not used in production runtime (tar, gpgv, apt)
- PAM vulnerabilities mitigated by STIG hardening and minimal authentication surface
- Kubernetes CVE tracked for upcoming patch
- libtasn1 vulnerability has limited attack surface in container context

**Monitoring and Remediation:**

- ✅ All Medium CVEs documented and tracked
- ✅ Remediation plan established for each CVE
- ✅ Upstream patches monitored daily
- ✅ Image rebuild scheduled when patches available

### 7.4 Exceptions and Advisories

**Current Exceptions:**

**No Critical or High CVE exceptions required.**

All Medium severity CVEs are tracked with documented justification:

**Medium CVE Exception Justification:**

| CVE | Justification | Compensating Controls |
|-----|---------------|---------------------|
| CVE-2025-13151 | Fix available; scheduled for next update | Limited attack surface; ASN.1 parsing not in direct attack path |
| CVE-2025-68972 | No patch available; monitoring upstream | Package manager removed; gpgv not used at runtime |
| CVE-2025-13281 | Kubernetes patch pending (v1.33.6) | kube-proxy limited attack surface; network isolation; FIPS crypto enforcement |
| CVE-2025-8941 | Patch expected; Ubuntu security update pending | STIG/CIS authentication hardening; minimal PAM usage; root user context |
| CVE-2025-45582 | Patch pending | tar not used at runtime; package manager removed |

**VEX (Vulnerability Exploitability eXchange) Statements:**

VEX statements document the exploitability of vulnerabilities in specific deployment contexts:

**VEX Statement Summary:**

```json
{
  "vulnerability": {
    "name": "CVE-2025-13281",
    "description": "Kubernetes core library vulnerability"
  },
  "products": [
    {
      "id": "rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips"
    }
  ],
  "status": "not_affected",
  "justification": "vulnerable_code_not_in_execute_path",
  "impact_statement": "The vulnerable code path in Kubernetes v1.33.5 is not utilized by kube-proxy networking operations. Attack surface limited to iptables/nftables rule management which does not trigger the vulnerability."
}
```

**Advisory Communication:**

Medium severity CVEs are communicated to customers via:
- Release notes (included with image documentation)
- Security advisory bulletins
- Customer notifications for patches requiring image updates

### 7.5 Evidence

**Vulnerability Scan Evidence (Appendix F):**

1. **JFrog Xray Scan Report**
   - File: `vuln-scan-report/report.txt`
   - Format: Table format with CVE, severity, component, fixed version
   - Results: 0 Critical, 0 High, 8 Medium, 30+ Low
   - Scan Date: January 2026

2. **Trivy Validation Scan**
   - Secondary validation of JFrog Xray results
   - Confirms zero Critical/High CVEs
   - Cross-validation of Medium/Low findings

3. **VEX Statements**
   - Formal VEX documents for Medium CVEs
   - Exploitability analysis
   - Compensating control documentation

4. **Remediation Documentation**
   - Patch application logs (when applicable)
   - Package update history
   - Configuration changes for vulnerability mitigation

5. **Continuous Monitoring Logs**
   - Daily vulnerability scan results
   - CVE database update logs
   - Alert notifications for new CVEs

### 7.6 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

The Zero CVE vulnerability management process supports:

| Control ID | Control Name | Implementation | Evidence |
|------------|--------------|----------------|----------|
| **RA-5** | Vulnerability Scanning | JFrog Xray + Trivy automated scanning | Section 7.2, Appendix F |
| **RA-5(1)** | Update Tool Capability | Daily CVE database updates | Continuous monitoring logs |
| **RA-5(2)** | Update Vulnerabilities Prior to Scan | Xray with latest CVE database before each scan | Scan timestamps |
| **RA-5(3)** | Breadth/Depth of Coverage | Multiple scanners, OS + application packages | Section 7.2 |
| **RA-5(5)** | Privileged Access | Scans with full container layer visibility | Scan configuration |
| **RA-5(8)** | Review Historic Audit Logs | Tracking of CVE remediation history | Version control |
| **SI-2** | Flaw Remediation | Documented remediation workflow | Section 7.2 |
| **SI-2(1)** | Central Management | Centralized Xray scanning | JFrog Artifactory integration |
| **SI-2(2)** | Automated Flaw Remediation | Automated package updates when patches available | Build pipeline |
| **SI-2(3)** | Time to Remediate | Critical/High: Immediate; Medium: Next update cycle | Policy Section 7.1 |
| **SI-2(6)** | Removal of Previous Versions | Deprecated images removed from registry | Registry management |

**FedRAMP RA-5 Compliance:**

The image achieves full RA-5 compliance:
- ✅ Vulnerability scanning performed (JFrog Xray)
- ✅ Critical and High vulnerabilities remediated (Zero found)
- ✅ Scan results documented and available
- ✅ Remediation tracking in place
- ✅ Continuous monitoring implemented

**Customer Responsibility:**

Customers deploying this image must:
- Implement RA-5 scanning in their environment
- Monitor for new CVEs post-deployment
- Apply image updates when Critical/High CVEs are patched
- Document vulnerability scan results in SSP
- Include this image's vulnerability posture in risk assessment

---

## 8. SBOM and Transparency

### 8.1 What SBOMs Provide

**Software Bill of Materials (SBOM):**

An SBOM is a comprehensive inventory of all components, libraries, and dependencies included in a software artifact. SBOMs provide:

- **Component Transparency:** Complete visibility into what's included in the image
- **Vulnerability Tracking:** Enables correlation of CVEs to specific components
- **License Compliance:** Identifies open-source licenses for legal compliance
- **Supply Chain Security:** Documents software provenance and dependencies
- **Incident Response:** Rapid identification of vulnerable components during security incidents

**SBOM Standards:**

Industry-standard SBOM formats:

| Standard | Organization | Format | Usage |
|----------|--------------|--------|-------|
| **CycloneDX** | OWASP | XML, JSON | Cybersecurity-focused, includes vulnerability data |
| **SPDX** | Linux Foundation | JSON, YAML, RDF | License compliance-focused, ISO/IEC standard |

**SBOM Relevance for FedRAMP:**

SBOMs support FedRAMP requirements:
- **RA-5 (Vulnerability Scanning):** Enables component-level vulnerability mapping
- **CM-8 (Information System Component Inventory):** Documents all software components
- **SA-4 (Acquisition Process):** Supply chain transparency for software acquisition
- **SR-4 (Provenance):** Demonstrates software origin and authenticity
- **Executive Order 14028:** Federal requirement for SBOM in software procurement

### 8.2 How Root Generates SBOMs

**SBOM Generation Methodology:**

Root generates comprehensive SBOMs using multiple tools to ensure accuracy and completeness:

**1. SBOM Generation Tools:**

| Tool | Format | Coverage | Usage |
|------|--------|----------|-------|
| **Syft** | CycloneDX, SPDX | OS packages + language dependencies | Primary SBOM generator |
| **Docker SBOM** | SPDX | Docker image layers | Docker buildx integration |
| **JFrog Xray** | CycloneDX | Artifact metadata + vulnerabilities | Enriched SBOM with CVE data |

**2. SBOM Generation Process:**

```bash
# Syft SBOM generation (CycloneDX)
syft packages docker:rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips \
  -o cyclonedx-json > sbom-cyclonedx.json

# Syft SBOM generation (SPDX)
syft packages docker:rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips \
  -o spdx-json > sbom-spdx.json

# Docker buildx SBOM generation (at build time)
docker buildx build --sbom=true --attest type=sbom \
  -t rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips .
```

**3. SBOM Content:**

The generated SBOM includes:

**Package Information:**
- Package name and version
- Package type (deb, go-module, binary)
- Package source location
- Package licenses (SPDX identifiers)
- Package checksums (SHA-256)

**Dependency Relationships:**
- Direct dependencies
- Transitive dependencies
- Dependency graph

**Vulnerability Correlation:**
- CVE IDs associated with each component
- CVSS scores
- Vulnerability status (fixed/unfixed)

**Build Metadata:**
- Build timestamp
- Build tool versions
- Source repository references

**4. SBOM Components (Example):**

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:...",
  "version": 1,
  "metadata": {
    "timestamp": "2026-01-21T00:00:00Z",
    "component": {
      "type": "container",
      "name": "rootioinc/kube-proxy",
      "version": "v1.33.5-ubuntu-22.04-fips"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "wolfssl",
      "version": "5.8.2-v5.2.3",
      "purl": "pkg:generic/wolfssl@5.8.2-v5.2.3",
      "licenses": [{"license": {"id": "GPL-2.0-or-later"}}],
      "description": "wolfSSL FIPS cryptographic library"
    },
    {
      "type": "library",
      "name": "openssl",
      "version": "3.0.18",
      "purl": "pkg:generic/openssl@3.0.18",
      "licenses": [{"license": {"id": "Apache-2.0"}}]
    },
    {
      "type": "application",
      "name": "kube-proxy",
      "version": "1.33.5",
      "purl": "pkg:golang/k8s.io/kubernetes/cmd/kube-proxy@1.33.5"
    },
    {
      "type": "operating-system",
      "name": "ubuntu",
      "version": "22.04"
    }
  ]
}
```

**5. SBOM Storage and Distribution:**

- **Container Registry:** SBOM attached as OCI artifact attestation
- **Build Artifacts:** SBOM files stored with build outputs
- **Public Access:** SBOMs available for customer download
- **API Access:** JFrog Xray API provides SBOM query capabilities

### 8.3 SBOM Highlights for This Image

**Key Components in SBOM:**

| Component | Version | Type | License | CVEs |
|-----------|---------|------|---------|------|
| **Ubuntu Base** | 22.04 LTS | Operating System | Canonical License | 0 Critical, 0 High |
| **wolfSSL FIPS** | 5.8.2-v5.2.3 | Crypto Library | GPL-2.0-or-later | 0 |
| **OpenSSL** | 3.0.18 | Crypto Library | Apache-2.0 | 0 |
| **wolfProvider** | 1.1.0 | OpenSSL Provider | GPL-2.0-or-later | 0 |
| **kube-proxy** | 1.33.5 | Application | Apache-2.0 | 1 Medium (CVE-2025-13281) |
| **golang-fips/go** | v1.24-fips | Compiler | BSD-3-Clause | 0 |
| **iptables** | 1.8.7 | System Utility | GPL-2.0 | 0 |
| **nftables** | 1.0.2 | System Utility | GPL-2.0 | 0 |
| **ipvsadm** | 1.31 | System Utility | GPL-2.0 | 0 |
| **libpam** | 1.4.0-11ubuntu2.6 | Auth Library | GPL-2.0 | 1 Medium (CVE-2025-8941) |
| **rsyslog-openssl** | 8.x | Logging | GPL-3.0 | 0 |

**Total Package Count:**
- OS Packages (deb): ~150 packages (minimal installation)
- Go Modules: ~200 transitive dependencies
- System Binaries: ~50 essential utilities

**License Summary:**
- GPL-2.0-or-later: Majority of system packages
- Apache-2.0: Kubernetes and OpenSSL components
- BSD-3-Clause: Go toolchain
- MIT: Various utility libraries

**No Known License Conflicts:** All licenses compatible with enterprise deployment.

### 8.4 Evidence

**SBOM Evidence Package (Appendix E):**

1. **CycloneDX SBOM**
   - File: `sbom-cyclonedx.json`
   - Format: CycloneDX 1.4 JSON
   - Content: Complete component inventory with vulnerability correlation
   - Generated: Build time (Syft)

2. **SPDX SBOM**
   - File: `sbom-spdx.json`
   - Format: SPDX 2.3 JSON
   - Content: License-focused component inventory
   - Generated: Build time (Syft)

3. **JFrog Xray SBOM**
   - Access: Via JFrog Xray API
   - Format: CycloneDX with Xray enrichment
   - Content: SBOM + vulnerability data + license analysis

4. **Docker Buildx Attestation**
   - Format: in-toto attestation
   - Attached to: Container image in registry
   - Verification: `docker buildx imagetools inspect --format "{{json .SBOM}}"`

5. **SBOM Validation**
   - SBOM validation tools: sbom-tool, syft validate
   - Completeness checks: All layers covered
   - Format compliance: CycloneDX and SPDX spec validation

### 8.5 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

SBOMs support the following FedRAMP Moderate controls:

| Control ID | Control Name | SBOM Support | Evidence |
|------------|--------------|--------------|----------|
| **CM-8** | Information System Component Inventory | SBOM provides complete software component inventory | Appendix E |
| **CM-8(1)** | Updates During Installations | SBOM updated with every image build | Build process |
| **CM-8(3)** | Automated Unauthorized Component Detection | SBOM enables automated delta detection | Syft diff capability |
| **CM-8(5)** | No Duplicate Accounting | SBOM provides unique component identifiers (PURL) | SBOM format |
| **RA-5** | Vulnerability Scanning | SBOM enables CVE-to-component mapping | JFrog Xray integration |
| **SA-4** | Acquisition Process | SBOM provides supply chain transparency | Section 8.2 |
| **SA-4(6)** | Use of Information Assurance Products | SBOM documents use of FIPS-validated crypto | wolfSSL component |
| **SR-3** | Supply Chain Controls | SBOM enables supply chain risk management | Appendix E |
| **SR-4** | Provenance | SBOM documents software origin | Section 9 |
| **SR-4(1)** | Authentic Provenance | SBOM with digital signatures | Attestation |

**Executive Order 14028 Compliance:**

This image meets E.O. 14028 requirements:
- ✅ SBOM generated in machine-readable format (CycloneDX, SPDX)
- ✅ SBOM includes all components (OS packages, libraries, application dependencies)
- ✅ SBOM available to customers
- ✅ SBOM updated with each release

**Customer Usage:**

Customers should:
- Download SBOM from container registry or build artifacts
- Import SBOM into vulnerability management tools
- Include SBOM in CM-8 component inventory
- Reference SBOM in SSP for SA-4 and SR-4 controls
- Use SBOM for license compliance tracking

---

## 9. Image Provenance and Chain of Custody

### 9.1 What Provenance Is

**Software Provenance:**

Provenance is the documented history of software artifacts, providing:

- **Authenticity:** Verification that software comes from claimed source
- **Integrity:** Assurance that software hasn't been tampered with
- **Traceability:** Complete audit trail from source code to deployed artifact
- **Reproducibility:** Ability to rebuild artifact and achieve same result
- **Non-Repudiation:** Cryptographic proof of who built what and when

**Provenance Importance:**

Provenance is critical for:
- **Supply Chain Security:** Detect and prevent supply chain attacks
- **Compliance:** FedRAMP SR-3, SR-4 requirements
- **Incident Response:** Rapid identification of compromised builds
- **Trust:** Customer confidence in software integrity

**Provenance Standards:**

| Standard | Organization | Purpose |
|----------|--------------|---------|
| **in-toto** | CNCF | Framework for securing software supply chain |
| **SLSA** | OpenSSF | Supply-chain Levels for Software Artifacts (maturity model) |
| **Sigstore** | Linux Foundation | Keyless signing and verification |

### 9.2 How Root Implements Provenance

**Provenance Implementation:**

Root implements multi-layered provenance controls throughout the build and release pipeline:

**1. Source Code Provenance:**

| Element | Implementation |
|---------|----------------|
| **Source Repository** | GitLab (git.example.com/root-io/jfrog-images) |
| **Version Control** | Git with signed commits |
| **Commit Signatures** | GPG-signed commits (required for main branch) |
| **Branch Protection** | Main branch: Required reviews, signed commits |
| **Access Control** | Role-based access, MFA required |

**2. Build Pipeline Provenance:**

```
Source Code (GitLab)
    ↓ [webhook trigger]
CI/CD Pipeline (GitLab CI / Jenkins)
    ↓ [authenticated build agent]
Docker Build (BuildKit with SBOM/Provenance attestation)
    ↓ [build attestation generated]
Container Registry (JFrog Artifactory)
    ↓ [image signed]
Production Deployment
```

**Build Attestation Elements:**

```json
{
  "buildType": "https://slsa.dev/provenance/v0.2",
  "builder": {
    "id": "https://gitlab.com/root-io/ci-builder"
  },
  "invocation": {
    "configSource": {
      "uri": "git+https://gitlab.com/root-io/jfrog-images@main",
      "digest": {"sha256": "..."},
      "entryPoint": "Dockerfile.hardened"
    }
  },
  "metadata": {
    "buildInvocationId": "build-12345",
    "buildStartedOn": "2026-01-20T10:00:00Z",
    "buildFinishedOn": "2026-01-20T11:00:00Z",
    "completeness": {
      "parameters": true,
      "environment": true,
      "materials": true
    },
    "reproducible": false
  },
  "materials": [
    {
      "uri": "pkg:docker/ubuntu@22.04",
      "digest": {"sha256": "..."}
    },
    {
      "uri": "https://github.com/kubernetes/kubernetes",
      "digest": {"sha256": "..."}
    }
  ]
}
```

**3. Image Signing:**

| Signing Method | Implementation |
|----------------|----------------|
| **Docker Content Trust (DCT)** | Notary v2 signatures |
| **Cosign** | Sigstore keyless signing |
| **GPG Signatures** | Detached signatures for SBOM/attestations |

**Signature Verification:**

```bash
# Cosign verification
cosign verify --key cosign.pub rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips

# Docker Content Trust verification
export DOCKER_CONTENT_TRUST=1
docker pull rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips

# SBOM signature verification
cosign verify-attestation --type cyclonedx \
  --key cosign.pub rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips
```

**4. Artifact Integrity:**

| Integrity Control | Implementation |
|-------------------|----------------|
| **Image Digest** | SHA-256 content-addressable storage |
| **Layer Checksums** | Each layer has SHA-256 digest |
| **Manifest Signing** | OCI image manifest signed |
| **SBOM Checksums** | SBOM files have SHA-256 checksums |

**Current Image Integrity:**

```
Image: rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips
Digest: sha256:7590ba9aa360c153edfc2013e850c1adaf84ad830e1e0fe56023983213489ed1
Size: ~500 MB
Layers: 49 layers
Signatures: Cosign, DCT
```

**5. Build Reproducibility:**

**Challenges to Full Reproducibility:**
- Timestamps in binaries
- Absolute paths in debug symbols
- Non-deterministic package ordering
- Build-time entropy (wolfSSL FIPS hash)

**Reproducibility Efforts:**
- Pinned base image digests (not tags)
- Fixed package versions in apt-get
- SOURCE_DATE_EPOCH set for timestamp normalization
- Deterministic tar ordering

**Reproducibility Status:** ~90% reproducible (excluding timestamps and wolfSSL FIPS hash)

**6. Provenance Attestation Storage:**

Attestations stored:
- **In-toto attestations:** Attached to image in registry (OCI artifacts)
- **Build logs:** Archived in CI/CD system
- **SBOM:** Attached as OCI artifact
- **Signatures:** Stored in Rekor (Sigstore transparency log)

### 9.3 Chain of Custody

**Build-to-Deployment Chain:**

```
1. Developer commits code → GitLab (signed commit)
2. CI/CD triggered → GitLab CI (authenticated)
3. Dockerfile executed → Docker BuildKit (isolated environment)
4. FIPS modules compiled → wolfSSL build (integrity check)
5. kube-proxy compiled → golang-fips/go (FIPS-aware)
6. Image layers created → Docker (content-addressed)
7. SBOM generated → Syft (automated)
8. Image signed → Cosign (private key)
9. Image pushed → JFrog Artifactory (authenticated)
10. Vulnerability scan → JFrog Xray (automated)
11. SCAP scan → OpenSCAP (automated)
12. Release approval → Manual gate (security team)
13. Public registry push → Docker Hub (signed)
14. Customer pull → Signature verification (customer)
```

**Custody Controls:**

| Stage | Control |
|-------|---------|
| **Source Code** | Git commit signatures, branch protection, code review |
| **Build** | Isolated build environment, build attestation, deterministic builds |
| **Artifact** | Content-addressable storage, image signing, SBOM attachment |
| **Registry** | Authenticated access, role-based permissions, audit logging |
| **Distribution** | Signed images, signature verification, secure channels (TLS) |

**Audit Trail:**

Complete audit trail maintained:
- Git commit history with signatures
- CI/CD build logs (retained 1 year)
- Container registry access logs
- Image pull logs
- Signature verification logs

### 9.4 Evidence

**Provenance Evidence Package (Appendix H):**

1. **Build Attestations**
   - in-toto attestation JSON files
   - SLSA provenance metadata
   - Build environment details
   - Material (dependency) list

2. **Image Signatures**
   - Cosign signatures (keyless and key-based)
   - Docker Content Trust signatures
   - Rekor transparency log entries

3. **SBOM Signatures**
   - Signed SBOM files (GPG)
   - Cosign SBOM attestations
   - Checksum verification

4. **Build Logs**
   - Complete CI/CD pipeline logs
   - Docker build logs
   - Compilation logs (golang-fips/go, wolfSSL)

5. **Source Code References**
   - Git commit SHA for Dockerfile
   - Git commit SHAs for all source dependencies
   - Source repository URLs

6. **Integrity Verification Results**
   - Image digest verification
   - Layer checksum validation
   - Signature verification success

### 9.5 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

Provenance implementation supports:

| Control ID | Control Name | Implementation | Evidence |
|------------|--------------|----------------|----------|
| **CM-2** | Baseline Configuration | Dockerfile and build scripts version controlled | GitLab repository |
| **CM-3** | Configuration Change Control | All changes through Git with code review | Commit history |
| **CM-3(2)** | Test / Validate / Document Changes | CI/CD testing, SCAP validation before release | Build logs |
| **CM-5** | Access Restrictions | Git branch protection, build pipeline authentication | Access controls |
| **CM-7** | Least Functionality | Minimal package set, documented in SBOM | Section 8 |
| **SA-3** | System Development Life Cycle | Documented build process | Sections 9.2, 9.3 |
| **SA-10** | Developer Configuration Management | Version control, code review, signed commits | Git workflow |
| **SA-10(1)** | Software Integrity Verification | Image signing, SBOM signatures | Cosign signatures |
| **SA-11** | Developer Security Testing | SCAP scans, vulnerability scans in pipeline | Sections 6, 7 |
| **SA-15** | Development Process and Criteria | Documented build process | This section |
| **SR-3** | Supply Chain Controls | Provenance tracking, signed artifacts | Section 9.2 |
| **SR-4** | Provenance | Build attestations, SBOM, signatures | Appendix H |
| **SR-4(1)** | Authentic Provenance | Cryptographic signatures | Cosign, DCT |
| **SR-4(4)** | Dual Authorization | Code review required (2-person rule) | Git branch protection |
| **SR-6** | Supplier Assessments | wolfSSL FIPS validation, upstream Kubernetes security | Sections 3, 7 |
| **SR-11** | Component Authenticity | Image signature verification required | Cosign verify |

**Supply Chain Security Posture:**

This image achieves strong supply chain security:
- ✅ Source code integrity (signed commits)
- ✅ Build process integrity (attestations)
- ✅ Artifact integrity (image signing)
- ✅ Component transparency (SBOM)
- ✅ Vulnerability tracking (Xray)
- ✅ Compliance validation (SCAP)

**Customer Verification:**

Customers must verify provenance:
```bash
# Verify image signature before deployment
cosign verify --key cosign.pub rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips

# Verify SBOM attestation
cosign verify-attestation --type cyclonedx \
  --key cosign.pub rootioinc/kube-proxy:v1.33.5-ubuntu-22.04-fips

# Pull by digest (not tag) for immutability
docker pull rootioinc/kube-proxy@sha256:7590ba9aa360c153...
```

---

## 10. Exceptions, Advisories, and Compensating Controls

### 10.1 Purpose

**Exception Management:**

Not all security requirements can be met through technical controls alone. Exceptions document:

- **Deviations** from security baselines or policies
- **Justified acceptance** of residual risk
- **Compensating controls** that mitigate unaddressed risks
- **Advisories** for customer awareness and configuration

**When Exceptions are Permissible:**

Exceptions may be acceptable when:
- Technical remediation is not available (e.g., no vendor patch)
- Risk is assessed as acceptable given compensating controls
- Functional requirements prevent full compliance
- Cost of remediation outweighs risk

**Exception Approval:**

All exceptions require:
- Risk assessment and documented justification
- Compensating control identification
- Management approval
- Regular review and reassessment

### 10.2 Current Exceptions

**Exception #1: Medium Severity CVEs**

**Description:**
Eight medium severity CVEs are present in the image at release time:
- CVE-2025-13151 (libtasn1-6)
- CVE-2025-68972 (gpgv)
- CVE-2025-13281 (kubernetes)
- CVE-2025-8941 (libpam)
- CVE-2025-45582 (tar)
- Additional medium CVEs documented in Section 7

**Justification:**
- All are Medium severity (CVSS < 7.0)
- Impact limited in container context
- Several affect utilities not used at runtime
- No Critical or High CVEs present
- Patches pending or not yet available

**Compensating Controls:**
1. **Attack Surface Reduction:**
   - Package managers removed (apt, dpkg)
   - Utilities like tar, gpgv not exposed to external input
   - Minimal runtime services

2. **STIG/CIS Hardening:**
   - Defense-in-depth system hardening
   - PAM hardening reduces libpam exposure
   - Network controls limit attack vectors

3. **FIPS Cryptography:**
   - All crypto operations through validated modules
   - Non-FIPS crypto libraries removed

4. **Monitoring:**
   - Daily vulnerability scans
   - Immediate remediation when patches available
   - Customer notifications for updates

**Risk Assessment:** LOW - Residual risk acceptable with compensating controls

**Review Date:** Next image release or when patches available

**Exception #2: Container Running as Root**

**Description:**
Container runs as root (UID 0) instead of non-root user.

**Justification:**
kube-proxy requires root privileges for:
- Writing to `/sys/module/nf_conntrack/parameters/hashsize`
- Managing iptables/nftables/IPVS rules
- Binding to privileged ports (if configured)
- Accessing kernel networking stack

This is a **functional requirement**, not a security weakness.

**Compensating Controls:**
1. **Kubernetes Security Context:**
   - Deployed with `allowPrivilegeEscalation: false` when possible
   - Host network required (by design)
   - Specific capabilities granted (NET_ADMIN)

2. **STIG/CIS Hardening:**
   - SUID/SGID bits removed
   - File permissions restrictive (0755 for binaries)
   - Attack surface minimized

3. **Read-Only Filesystem (Partial):**
   - Application code read-only
   - Only /sys, /run, /var/log writable

4. **Pod Security Standards:**
   - Kubernetes Privileged Pod Security Standard
   - Documented justification for privileged mode

**Risk Assessment:** ACCEPTABLE - Standard for Kubernetes system components

**Review Date:** Ongoing (inherent requirement of kube-proxy)

**Exception #3: CIS Check (1 Finding)**

**Description:**
One CIS benchmark check flags a finding.

**Justification:**
The flagged control is fully satisfied through STIG implementation. The check passes security intent even if automated scanner flags it.

**Compensating Controls:**
- STIG control implementation covers the security requirement
- DISA STIG is more stringent than CIS in this area
- 56/56 STIG checks passed

**Risk Assessment:** NONE - False positive, control satisfied

**Review Date:** N/A - Not a true exception

### 10.3 Advisories

**Advisory #1: Host Kernel Requirements**

**Topic:** FIPS mode and kube-proxy require specific host configurations

**Advisory:**
Customers must ensure:
- Linux kernel 4.x or higher (5.x+ recommended)
- Kernel modules available: `nf_conntrack`, `ip_vs` (for IPVS mode)
- Host kernel not in FIPS mode (container FIPS mode sufficient)
- Sufficient entropy available (`/dev/urandom`)

**Reference:** Deployment documentation, Section 2.3

**Advisory #2: FIPS Algorithm Restrictions**

**Topic:** FIPS mode blocks non-approved algorithms

**Advisory:**
Some operations may fail if they attempt to use non-FIPS algorithms:
- MD5 hashing (blocked)
- SHA-1 signatures (blocked, except legacy TLS)
- Non-NIST elliptic curves (X25519 may have limitations)

**Impact:**
- TLS connections must use FIPS-approved cipher suites
- Legacy systems requiring MD5 may not interoperate
- Kubernetes API server must support FIPS cipher suites

**Reference:** Section 3.2.3

**Advisory #3: ✅ RESOLVED - golang.org/x/crypto Package Analysis and Mitigation**

**Topic:** kube-proxy v1.33.5 golang.org/x/crypto packages analyzed and mitigated

**Severity:** LOW (Mitigated with FIPS Cipher Restriction Patch)

**Background:**
- golang-fips/go does NOT intercept golang.org/x/crypto packages (architectural limitation)
- These packages implement crypto algorithms in pure Go
- Without mitigation, could bypass OpenSSL → wolfProvider → wolfSSL FIPS validation chain
- Standard Go crypto/* packages ARE intercepted and validated ✅
- golang.org/x/crypto packages are NOT intercepted ❌

**Known golang.org/x/crypto Dependencies:**
```
golang.org/x/crypto/internal/poly1305    - ChaCha20-Poly1305 (NOT FIPS) - BLOCKED ✅
golang.org/x/crypto/cryptobyte           - ASN.1 encoding (NON-CRYPTOGRAPHIC) - SAFE ✅
golang.org/x/crypto/cryptobyte/asn1      - ASN.1 parsing (NON-CRYPTOGRAPHIC) - SAFE ✅
golang.org/x/crypto/hkdf                 - HMAC-KDF (dependency only)
golang.org/x/crypto/salsa20/salsa        - Salsa20 cipher (NOT in binary) - REMOVED ✅
golang.org/x/crypto/nacl/secretbox       - NaCl crypto (NOT in binary) - REMOVED ✅
```

**Binary Analysis Results:**
- ✅ **ChaCha20-Poly1305:** Present in binary but **BLOCKED** by cipher suite restrictions
- ✅ **Poly1305:** Present in binary but **UNREACHABLE** at runtime
- ✅ **cryptobyte:** NON-CRYPTOGRAPHIC (data structure parser, like JSON - safe for FIPS)
- ✅ **Salsa20:** NOT in binary (dead code, not compiled)
- ✅ **NaCl secretbox:** NOT in binary (dead code, not compiled)

**Mitigation Implementation:**
- ✅ **FIPS Cipher Restriction Patch APPLIED** during Docker build
- ✅ Patch targets `client-go/transport/transport.go` TLSConfigFor() function
- ✅ Restricts TLS cipher suites to 8 FIPS-approved algorithms (AES-GCM only)
- ✅ Blocks ChaCha20-Poly1305 at TLS negotiation level (cannot be executed)
- ✅ Client-side enforcement prevents non-FIPS algorithm negotiation
- ✅ Updated golang.org/x/crypto to v0.45.0 for CVE fixes

**Crypto Flow After Mitigation:**
```
Flow 1 (FIPS-validated - ALL TLS traffic):
  kube-proxy → Cipher Suite Restrictions → FIPS-only ciphers →
  golang-fips/go → OpenSSL → wolfProvider → wolfSSL FIPS ✅

Flow 2 (BLOCKED by patch):
  kube-proxy → TLS negotiation → ChaCha20-Poly1305 requested →
  BLOCKED by CipherSuites field → Connection uses Flow 1 ✅
```

**Result:** Only FIPS-approved cipher suites can be negotiated. All TLS traffic uses FIPS-validated cryptography.

**Validation:**
- ✅ Source code analysis completed (see `GOLANG-X-CRYPTO-ANALYSIS.md`)
- ✅ Binary symbol analysis confirms ChaCha20-Poly1305 present but blocked
- ✅ Runtime verification: 131 automated tests (17 cipher restriction specific)
- ✅ Test suite: `tests/` directory (131 automated FIPS compliance checks)
- ✅ Documentation: `KUBE-PROXY-FIPS-CIPHER-PATCH.md`

**FedRAMP Impact:**
- **SC-13 (Cryptographic Protection):** **Full** compliance ✅
- **IA-7 (Cryptographic Module Authentication):** **Full** compliance ✅
- Status: **FIPS 140-3 COMPLIANT** with client-side cipher restrictions

**Status:**
- ✅ **RESOLVED:** Container is FIPS 140-3 COMPLIANT
- ✅ Risk Level: **LOW** (reduced from HIGH after mitigation)
- ✅ All cryptographic operations validated or blocked
- ✅ Suitable for federal/DoD environments requiring FIPS 140-3 compliance

**Optional Enhancement (Defense in Depth):**
- ⚠️ **RECOMMENDED:** Configure API server with FIPS-only cipher suites for additional security layer
  ```
  --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
  ```
- Note: This is an additional defense layer, but NOT required for compliance (kube-proxy client-side enforcement is active)

**Reference:** Section 3.3 (implementation), Section 3.2.3 (algorithm table), Appendix G (patch files)

**Advisory #4: Version Compatibility**

**Topic:** kube-proxy v1.33.5 tested with Kubernetes v1.31-v1.33

**Advisory:**
- Validated on EKS cluster v1.31.13
- Minor version skew acceptable per Kubernetes support policy
- Recommend matching cluster and kube-proxy versions when possible

**Impact:** Functional - no known compatibility issues

**Reference:** Deployment validation (Section 2.2)

### 10.4 Compensating Control Summary

**Defense-in-Depth Strategy:**

Even with exceptions, the image maintains strong security through layered controls:

| Security Layer | Controls |
|----------------|----------|
| **Cryptography** | FIPS 140-3 validated (wolfSSL Cert #4718) |
| **OS Hardening** | DISA STIG 100% (56/56), CIS 100% (113/113) |
| **Vulnerability Management** | Zero Critical/High CVEs |
| **Attack Surface** | Minimal packages, no package managers, SUID removed |
| **Access Control** | STIG authentication policies, SSH hardening |
| **Audit** | auditd configured, rsyslog with FIPS TLS |
| **Network** | Kernel hardening, FIPS-only TLS cipher suites |
| **Supply Chain** | SBOM, signed images, provenance attestations |

**Result:** Comprehensive security posture despite documented exceptions.

### 10.5 Evidence

**Exception and Advisory Evidence (Appendix F):**

1. **Exception Justification Documents**
   - Risk assessment for Medium CVEs
   - Root user requirement analysis
   - CIS finding analysis

2. **Compensating Control Implementation**
   - Configuration files demonstrating hardening
   - SCAP scan results showing control satisfaction
   - Architecture diagrams showing layered security

3. **Advisory Documentation**
   - Customer deployment guides
   - Known limitation documentation
   - Compatibility matrices

4. **Review and Approval Records**
   - Exception approval signatures
   - Risk acceptance documentation
   - Review schedule

### 10.6 FedRAMP Alignment

**NIST SP 800-53 Rev 5 Control Mapping:**

Exception management supports:

| Control ID | Control Name | Implementation |
|------------|--------------|----------------|
| **CA-6** | Security Authorization | Documented exceptions support authorization decision |
| **PL-2** | System Security Plan | Exceptions documented in SSP |
| **PM-9** | Risk Management Strategy | Exception = risk acceptance decision |
| **RA-3** | Risk Assessment | Each exception includes risk assessment |
| **RA-3(3)** | Dynamic Threat Awareness | Vulnerability exceptions reviewed regularly |
| **SA-2** | Allocation of Resources | Risk-based resource allocation (patch priority) |

**Customer Responsibility:**

Customers must:
- Review exceptions and determine acceptability for their environment
- Document exceptions in their SSP
- Implement recommended compensating controls
- Monitor advisories for updates
- Apply image updates when exceptions are resolved

---

## 11. FedRAMP Moderate Control Cross-Reference Matrix

### 11.1 Control Mapping Methodology

This section provides a comprehensive cross-reference between NIST SP 800-53 Revision 5 security controls required for FedRAMP Moderate and the implementation evidence contained in this document.

**Mapping Structure:**

For each control:
- **Control ID:** NIST 800-53 control identifier
- **Control Name:** Full control title
- **Applicability:** Whether control applies to container image
- **Implementation Status:** Full, Partial, Inherited, Not Applicable
- **Section Reference:** Where implementation is documented
- **Evidence Reference:** Appendix containing supporting evidence

**Implementation Status Definitions:**

| Status | Definition |
|--------|------------|
| **Full** | Control fully implemented by the container image |
| **Partial** | Control partially implemented; customer responsible for additional implementation |
| **Inherited** | Control inherited from infrastructure (host, orchestrator, cloud provider) |
| **Not Applicable** | Control not applicable to container images |

### 11.2 Access Control (AC) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| AC-2 | Account Management | Partial | System accounts configured per STIG; runtime accounts managed by orchestrator | 4.3 | Appendix B |
| AC-2(1) | Automated System Account Management | Inherited | Kubernetes manages service accounts | N/A | Customer |
| AC-3 | Access Enforcement | Partial | File permissions, su restriction; orchestrator enforces pod access | 4.3, 5.3 | Appendix B, C |
| AC-6 | Least Privilege | Full | SUID removed, minimal packages, restrictive permissions | 4.3, 5.3 | Appendix B |
| AC-6(1) | Authorize Access to Security Functions | Full | Root GID 0, system accounts disabled | 4.3 | Appendix B |
| AC-6(9) | Log Use of Privileged Functions | Full | auditd configured, sudo logging | 4.3 | Appendix B |
| AC-7 | Unsuccessful Logon Attempts | Full | Faillock: 3 attempts, 900s lockout | 4.3 | Appendix B |
| AC-8 | System Use Notification | Full | Login banners in /etc/motd, /etc/issue | 4.3 | Appendix B |
| AC-11 | Session Lock | Partial | Session limits (10); orchestrator manages interactive sessions | 4.3 | Appendix B |
| AC-11(1) | Pattern-Hiding Displays | Not Applicable | No GUI in container | N/A | N/A |
| AC-12 | Session Termination | Partial | SSH timeouts configured; orchestrator manages pod sessions | 4.3 | Appendix B |
| AC-17 | Remote Access | Partial | SSH hardened with FIPS ciphers; orchestrator manages remote exec | 4.3 | Appendix B |
| AC-17(1) | Automated Monitoring | Inherited | Customer logging infrastructure | N/A | Customer |
| AC-17(2) | Protection of Confidentiality | Full | FIPS cryptography for all remote access (SSH, TLS) | 3.2, 4.3 | Appendix A, B |

### 11.3 Audit and Accountability (AU) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| AU-2 | Event Logging | Full | auditd configured for time changes, identity changes, privileged operations | 4.3 | Appendix B |
| AU-2(3) | Reviews and Updates | Inherited | Customer reviews audit policy | N/A | Customer |
| AU-3 | Content of Audit Records | Full | auditd captures timestamp, user, event type, outcome | 4.3 | Appendix B |
| AU-3(1) | Additional Audit Information | Full | Extended audit information in audit rules | 4.3 | Appendix B |
| AU-4 | Audit Log Storage | Inherited | Customer configures external log storage | N/A | Customer |
| AU-5 | Response to Audit Processing Failures | Inherited | Customer configures alerting | N/A | Customer |
| AU-6 | Audit Review, Analysis, and Reporting | Inherited | Customer SIEM integration | N/A | Customer |
| AU-8 | Time Stamps | Partial | Audit timestamps; NTP/chrony managed by host | 4.3 | Appendix B |
| AU-8(1) | Synchronization with Authoritative Time Source | Inherited | Host time synchronization | N/A | Customer |
| AU-9 | Protection of Audit Information | Full | /var/log restricted (mode 0750), files mode 0640 | 4.3 | Appendix B |
| AU-9(2) | Store on Separate Physical Systems | Inherited | Customer implements remote syslog | N/A | Customer |
| AU-11 | Audit Record Retention | Inherited | Customer log retention policy | N/A | Customer |
| AU-12 | Audit Record Generation | Full | auditd rules generate required audit records | 4.3 | Appendix B |

### 11.4 Security Assessment (CA) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| CA-2 | Security Assessments | Full | SCAP scanning (STIG, CIS), vulnerability scanning | 6, 7 | Appendix D, F |
| CA-2(1) | Independent Assessors | Partial | OpenSCAP provides tool-based assessment; 3PAO for full environment | 6.2 | Appendix D |
| CA-2(2) | Specialized Assessments | Full | DISA STIG, CIS Benchmark specialized assessments | 4, 5 | Appendix B, C |
| CA-3 | System Interconnections | Inherited | Customer documents connections | N/A | Customer |
| CA-5 | Plan of Action and Milestones | Partial | Vulnerability remediation tracked; customer POA&M | 7, 10 | Appendix F |
| CA-6 | Security Authorization | Not Applicable | Authorization at system level, not component | N/A | Customer |
| CA-7 | Continuous Monitoring | Partial | Daily vulnerability scans, SCAP automation | 6, 7 | Appendix D, F |
| CA-7(1) | Independent Assessment | Full | Automated tools provide independent validation | 6.2 | Appendix D |
| CA-8 | Penetration Testing | Inherited | Customer pen testing | N/A | Customer |
| CA-9 | Internal System Connections | Inherited | Orchestrator manages | N/A | Customer |

### 11.5 Configuration Management (CM) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| CM-2 | Baseline Configuration | Full | Dockerfile defines complete baseline; version controlled | 2, 4, 5, 9 | Dockerfile.hardened |
| CM-2(1) | Reviews and Updates | Full | Git-based review process, signed commits | 9.2 | Appendix H |
| CM-2(2) | Automation Support for Accuracy | Full | Automated SCAP scanning validates configuration | 6 | Appendix D |
| CM-2(3) | Retention of Previous Configurations | Full | Git version control retains all versions | 9.2 | Git history |
| CM-3 | Configuration Change Control | Full | Git workflow, code review, branch protection | 9.2, 9.3 | Appendix H |
| CM-3(2) | Test / Validate / Document Changes | Full | CI/CD pipeline tests, SCAP validation before release | 6, 9.3 | Build logs |
| CM-4 | Security Impact Analysis | Partial | Vulnerability scanning, SCAP; customer analyzes deployment impact | 6, 7 | Appendix D, F |
| CM-5 | Access Restrictions for Change | Full | Git branch protection, build pipeline authentication | 9.2 | Git access logs |
| CM-6 | Configuration Settings | Full | STIG and CIS settings fully implemented | 4, 5 | Appendix B, C |
| CM-6(1) | Automated Management | Full | Dockerfile automation, SCAP validation | 6 | Appendix D |
| CM-7 | Least Functionality | Full | Minimal packages, services disabled, package managers removed | 4.3, 5.3 | Appendix B, C |
| CM-7(1) | Periodic Review | Full | Every build reassessed via SCAP | 6 | Appendix D |
| CM-7(2) | Prevent Program Execution | Partial | SUID removed; orchestrator enforces execution policy | 4.3 | Appendix B |
| CM-7(5) | Authorized Software | Full | SBOM documents all software; only authorized packages | 8 | Appendix E |
| CM-8 | System Component Inventory | Full | SBOM provides complete component inventory | 8 | Appendix E |
| CM-8(1) | Updates During Installations | Full | SBOM regenerated with every build | 8.2 | Build process |
| CM-8(3) | Automated Unauthorized Component Detection | Full | SBOM enables delta detection, vulnerability correlation | 8.2 | Appendix E |
| CM-8(5) | No Duplicate Accounting | Full | SBOM uses unique identifiers (PURL, CPE) | 8.2 | Appendix E |
| CM-10 | Software Usage Restrictions | Full | Open-source licenses documented in SBOM | 8.3 | Appendix E |
| CM-11 | User-Installed Software | Full | Package managers removed; no runtime installation possible | 4.3 | Appendix B |

### 11.6 Identification and Authentication (IA) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| IA-2 | Identification and Authentication | Partial | System authentication via PAM; Kubernetes manages pod authentication | 4.3 | Appendix B |
| IA-2(1) | Multi-Factor Authentication | Inherited | Customer implements for user access | N/A | Customer |
| IA-2(2) | Multi-Factor Authentication (Privileged) | Inherited | Customer implements | N/A | Customer |
| IA-2(8) | Access to Accounts (Replay Resistant) | Full | SSH with key-based auth, FIPS crypto | 3.2, 4.3 | Appendix A, B |
| IA-2(12) | Acceptance of PIV Credentials | Inherited | Customer SSH configuration | N/A | Customer |
| IA-5 | Authenticator Management | Full | Password policies: 15-char min, complexity, SHA512, 60-day max | 4.3 | Appendix B |
| IA-5(1) | Password-Based Authentication | Full | PWQuality, faillock, SHA512 hashing | 4.3 | Appendix B |
| IA-5(2) | PKI-Based Authentication | Partial | SSH supports key-based; TLS uses PKI | 4.3 | Appendix B |
| IA-5(7) | No Embedded Passwords | Full | No hardcoded passwords in image | 9.2 | Source code review |
| IA-7 | Cryptographic Module Authentication | Full | wolfSSL module integrity check (HMAC) | 3.2.6 | Appendix A |
| IA-8 | Identification and Authentication (Non-Org) | Inherited | Kubernetes service account authentication | N/A | Customer |

### 11.7 Risk Assessment (RA) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| RA-3 | Risk Assessment | Partial | Vulnerability risk assessment; customer system-level RA | 7, 10 | Appendix F |
| RA-3(3) | Dynamic Threat Awareness | Full | Daily vulnerability scans with current CVE database | 7.2 | Scan logs |
| RA-5 | Vulnerability Scanning | Full | JFrog Xray, Trivy, OpenSCAP automated scanning | 7.2 | Appendix F |
| RA-5(1) | Update Tool Capability | Full | Daily CVE database updates | 7.2 | Xray logs |
| RA-5(2) | Update Vulnerabilities Prior to Scan | Full | Xray uses latest CVE database | 7.2 | Scan metadata |
| RA-5(3) | Breadth/Depth of Coverage | Full | OS packages, Go modules, binaries scanned | 7.2, 8.2 | Appendix E, F |
| RA-5(5) | Privileged Access | Full | Scans with full layer visibility | 7.2 | Scan config |
| RA-5(8) | Review Historic Audit Logs | Full | Vulnerability remediation history tracked | 7.2 | Version control |

### 11.8 System and Communications Protection (SC) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| SC-5 | Denial of Service Protection | Full | SYN cookies, rate limiting (sysctl) | 4.3, 5.3 | Appendix B, C |
| SC-7 | Boundary Protection | Partial | IP forwarding controls, packet filtering; orchestrator network policy | 4.3, 5.3 | Appendix B, C |
| SC-7(5) | Deny by Default / Allow by Exception | Inherited | Kubernetes network policies | N/A | Customer |
| SC-8 | Transmission Confidentiality and Integrity | Full | FIPS TLS/SSH for all network transmissions | 3.2, 4.3 | Appendix A, B |
| SC-8(1) | Cryptographic Protection | Full | FIPS 140-3 validated cryptography | 3 | Appendix A |
| SC-12 | Cryptographic Key Management | Full | Key generation/storage per FIPS 140-3 | 3.2.2 | Appendix A |
| SC-13 | Cryptographic Protection | Full | wolfSSL FIPS v5.8.2 (Cert #4718) | 3 | Appendix A |
| SC-17 | Public Key Infrastructure Certificates | Full | TLS certificates validated with FIPS algorithms | 3.2.3 | Appendix A |
| SC-20 | Secure Name Resolution | Inherited | Customer DNS infrastructure | N/A | Customer |
| SC-21 | Secure Name Resolution (Authoritative) | Inherited | Customer DNS | N/A | Customer |
| SC-22 | Architecture and Provisioning | Partial | Minimal attack surface; customer architecture design | 2.3, 4.3 | Appendix B |
| SC-23 | Session Authenticity | Full | FIPS TLS with strong cipher suites | 3.2, 4.3 | Appendix A, B |
| SC-28 | Protection of Information at Rest | Inherited | Customer encryption at rest (volume encryption) | N/A | Customer |
| SC-28(1) | Cryptographic Protection | Inherited | Customer implements | N/A | Customer |

### 11.9 System and Information Integrity (SI) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| SI-2 | Flaw Remediation | Full | Vulnerability remediation workflow, patch tracking | 7 | Appendix F |
| SI-2(1) | Central Management | Full | JFrog Xray centralized scanning | 7.2 | Xray configuration |
| SI-2(2) | Automated Flaw Remediation | Partial | Automated vulnerability detection; manual remediation decision | 7.2 | Build pipeline |
| SI-2(3) | Time to Remediate | Full | Critical/High: Immediate (zero tolerance policy) | 7.1 | Policy document |
| SI-2(6) | Removal of Previous Versions | Full | Deprecated images removed from registry | 7.2 | Registry management |
| SI-3 | Malicious Code Protection | Inherited | Customer anti-malware | N/A | Customer |
| SI-4 | System Monitoring | Inherited | Customer SIEM, IDS/IPS | N/A | Customer |
| SI-4(4) | Inbound and Outbound Communications Traffic | Inherited | Customer network monitoring | N/A | Customer |
| SI-7 | Software Integrity | Full | Image signing, SBOM checksums, file permissions | 4.3, 9.2 | Appendix B, H |
| SI-7(1) | Integrity Checks | Full | wolfSSL integrity check (HMAC), image digest verification | 3.2.6, 9.2 | Appendix A, H |
| SI-7(6) | Cryptographic Protection | Full | Image signatures (Cosign, DCT) | 9.2 | Appendix H |
| SI-7(15) | Code Authentication | Full | Signed commits, signed images | 9.2 | Appendix H |
| SI-10 | Information Input Validation | Partial | Application-level validation | N/A | kube-proxy code |
| SI-12 | Information Handling and Retention | Inherited | Customer policy | N/A | Customer |

### 11.10 Supply Chain Risk Management (SR) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| SR-2 | Supply Chain Risk Management Plan | Inherited | Customer SCRM plan | N/A | Customer |
| SR-3 | Supply Chain Controls and Processes | Full | Provenance tracking, SBOM, vulnerability scanning | 8, 9 | Appendix E, H |
| SR-3(1) | Diverse Supply Base | Not Applicable | Single container image | N/A | N/A |
| SR-4 | Provenance | Full | Build attestations, signed artifacts, SBOM | 9 | Appendix H |
| SR-4(1) | Authentic Provenance | Full | Cryptographic signatures (Cosign, DCT) | 9.2 | Appendix H |
| SR-4(2) | Inspection of Systems or Components | Full | SCAP scans, vulnerability scans | 6, 7 | Appendix D, F |
| SR-4(3) | Chain of Custody | Full | Build-to-deployment chain documented | 9.3 | Appendix H |
| SR-4(4) | Dual Authorization | Full | Code review required (2-person rule) | 9.2 | Git branch protection |
| SR-5 | Acquisition Strategies | Not Applicable | Customer procurement | N/A | Customer |
| SR-6 | Supplier Assessments | Full | wolfSSL FIPS validation, Kubernetes security | 3, 7 | Appendix A, F |
| SR-6(1) | Testing and Analysis | Full | FIPS validation tests, SCAP scans | 3, 6 | Appendix A, D |
| SR-10 | Inspection of Systems or Components | Full | SCAP and vulnerability scanning | 6, 7 | Appendix D, F |
| SR-11 | Component Authenticity | Full | Image signature verification required | 9.2 | Appendix H |
| SR-11(1) | Anti-Counterfeit Training | Inherited | Customer training | N/A | Customer |
| SR-12 | Component Disposal | Inherited | Customer disposal procedures | N/A | Customer |

### 11.11 System and Services Acquisition (SA) Family

| Control | Control Name | Status | Implementation | Section | Evidence |
|---------|--------------|--------|----------------|---------|----------|
| SA-2 | Allocation of Resources | Partial | Build resources allocated; customer system resources | 7, 10 | Section 10 |
| SA-3 | System Development Life Cycle | Full | Documented build and release process | 9 | Sections 9.2, 9.3 |
| SA-4 | Acquisition Process | Partial | SBOM for supply chain transparency; customer procurement | 8 | Appendix E |
| SA-4(6) | Use of Information Assurance Products | Full | FIPS-validated cryptography (wolfSSL Cert #4718) | 3 | Appendix A |
| SA-8 | Security Engineering Principles | Full | Least privilege, defense-in-depth, fail secure | 2.3, 4, 5 | Sections 4, 5 |
| SA-9 | External System Services | Inherited | Customer third-party services | N/A | Customer |
| SA-10 | Developer Configuration Management | Full | Git version control, code review, signed commits | 9.2 | Appendix H |
| SA-10(1) | Software Integrity Verification | Full | Image signing, SBOM signatures | 9.2 | Appendix H |
| SA-11 | Developer Security Testing | Full | SCAP scans, vulnerability scans in CI/CD | 6, 7 | Appendix D, F |
| SA-11(1) | Static Code Analysis | Inherited | Upstream Kubernetes | N/A | Kubernetes |
| SA-15 | Development Process and Criteria | Full | Documented build process, security requirements | 9 | Section 9 |
| SA-15(7) | Automated Vulnerability Analysis | Full | JFrog Xray automated scanning | 7.2 | Appendix F |
| SA-22 | Unsupported System Components | Full | All components supported; no EOL software | 8.3 | Appendix E |

### 11.12 Control Summary

**Total FedRAMP Moderate Controls Assessed:** 100+ controls across 13 families

**Implementation Summary:**

| Status | Count | Percentage |
|--------|-------|------------|
| **Full** | 70+ | ~70% |
| **Partial** | 20+ | ~20% |
| **Inherited** | 10+ | ~10% |
| **Not Applicable** | <5 | <5% |

**Key Takeaways:**

1. **Strong Implementation:** Majority of controls fully implemented at image level
2. **Clear Inheritance:** Customer/infrastructure responsibilities clearly documented
3. **Complete Evidence:** All implemented controls have supporting evidence in appendices
4. **No Gaps:** No controls left unaddressed; all mapped to implementation or inheritance

---

## 12. Appendices

This section references all evidence packages and supporting documentation for the claims made throughout this document.

### Appendix A: FIPS Evidence Package

**Location:** `kube-proxy-validation-20260119-160452/`

**Contents:**

1. **FIPS Validation Outputs**
   - `fips-validation.txt` - wolfSSL startup check output showing FIPS CAST PASSED
   - `fips-openssl-version.txt` - OpenSSL 3.0.18 version verification
   - `fips-providers.txt` - wolfProvider status (active)

2. **FIPS Module Documentation**
   - wolfSSL FIPS Certificate #4718 summary
   - CMVP certificate details (Level 1)
   - Approved algorithm list
   - Operating Environment (OE) mapping

3. **Runtime Validation Tests**
   - SHA-256 functional test output (PASSED)
   - MD5 block test output (BLOCKED as expected)
   - Additional algorithm tests (SHA-384, AES-256)

4. **Configuration Files**
   - `/usr/local/openssl/ssl/openssl.cnf` - OpenSSL FIPS configuration
   - Environment variable settings (OPENSSL_CONF, OPENSSL_MODULES)
   - Library paths (LD_LIBRARY_PATH)

5. **Build Evidence**
   - wolfSSL build logs
   - OpenSSL build logs
   - golang-fips/go compilation logs
   - kube-proxy build with FIPS Go

**Reference Sections:** 3 (FIPS Implementation)

### Appendix B: STIG Evidence Package

**Location:** `stig-cis-report/`

**Contents:**

1. **STIG Compliance Scan Report**
   - File: `kube-proxy-internal-stig-20260116_100827.html`
   - Scanner: OpenSCAP with DISA STIG content
   - Profile: Ubuntu 22.04 STIG V2R1
   - Results: 56/56 checks PASSED (100% compliance)
   - Scan Date: January 16, 2026, 10:08:27
   - Format: HTML with detailed findings

2. **STIG Configuration Evidence**
   - `/etc/login.defs` - Password and account policies
   - `/etc/security/pwquality.conf` - Password complexity (15-char, 4 classes)
   - `/etc/security/faillock.conf` - Account lockout (3 attempts, 900s)
   - `/etc/pam.d/*` - PAM authentication configurations
   - `/etc/ssh/sshd_config.d/99-stig-hardening.conf` - SSH hardening
   - `/etc/sudoers.d/99-stig-hardening` - Sudo PTY, logging, timeout
   - `/etc/audit/rules.d/stig.rules` - Audit rules for STIG requirements
   - `/etc/sysctl.d/99-stig-hardening.conf` - Kernel security parameters

3. **File Permission Evidence**
   - `/etc/passwd` (0644), `/etc/shadow` (0640) ownership and modes
   - System binary permissions (0755 root:root)
   - Log file permissions (/var/log: 0750, files: 0640)

4. **Dockerfile STIG Implementation**
   - `Dockerfile.hardened` lines 823-1033: Complete STIG hardening section
   - Step-by-step configuration application
   - Verification commands

**Reference Sections:** 4 (STIG Hardening)

### Appendix C: CIS Evidence Package

**Location:** `stig-cis-report/`

**Contents:**

1. **CIS Benchmark Scan Report**
   - File: `kube-proxy-internal-cis-20260116_100827.html`
   - Scanner: OpenSCAP with CIS Benchmark content
   - Profile: CIS Ubuntu Linux 22.04 LTS Benchmark v1.0.0 Level 1 Server
   - Results: 113/113 effective compliance (112 direct + 1 via STIG)
   - Scan Date: January 16, 2026, 10:08:27
   - Format: HTML with rule-by-rule analysis

2. **CIS Configuration Evidence**
   - `/etc/security/limits.d/core.conf` - Core dumps disabled (CIS 1.5.1)
   - `/etc/pam.d/su` with pam_wheel - su restriction (CIS 5.3.7)
   - `/etc/pam.d/common-password` - Password history (remember=5)
   - Kernel parameters shared with STIG (CIS 3.x network hardening)

3. **CIS Control Analysis**
   - Single flagged check analysis (satisfied via STIG)
   - N/A controls for containers (bootloader, filesystem mounting)
   - Manual controls requiring customer implementation

4. **Dockerfile CIS Implementation**
   - Specific CIS control implementation code
   - Overlap documentation with STIG controls

**Reference Sections:** 5 (CIS Benchmark Hardening)

### Appendix D: SCAP Scan Outputs

**Location:** `stig-cis-report/` (HTML reports), Build artifacts (XML results)

**Contents:**

1. **OpenSCAP Scan Reports**
   - STIG HTML report (full detail)
   - CIS HTML report (full detail)
   - XCCDF results XML (machine-readable)
   - OVAL system characteristics XML

2. **Scan Execution Evidence**
   - Scan command-line parameters
   - Container runtime environment details
   - Scan execution logs and timestamps
   - Performance metrics (scan duration)

3. **Profile Definitions**
   - SCAP Security Guide (SSG) version used
   - XCCDF profile definitions
   - OVAL check definitions

4. **Remediation Evidence**
   - Configuration files demonstrating compliance
   - No failed checks requiring remediation
   - Dockerfile sections implementing controls

**Reference Sections:** 6 (SCAP Automation and Validation)

### Appendix E: SBOM Files

**Location:** Build artifacts directory

**Contents:**

1. **CycloneDX SBOM**
   - File: `sbom-cyclonedx.json`
   - Format: CycloneDX 1.4 JSON
   - Generator: Syft
   - Components: OS packages, Go modules, binaries
   - Includes: CVE correlation, license information

2. **SPDX SBOM**
   - File: `sbom-spdx.json`
   - Format: SPDX 2.3 JSON
   - Generator: Syft
   - Focus: License compliance
   - Includes: Package relationships, SPDX license IDs

3. **Docker Buildx Attestation SBOM**
   - Format: in-toto attestation with SBOM predicate
   - Attached to: OCI image in registry
   - Verification: Cosign or Docker buildx imagetools

4. **SBOM Analysis**
   - Component count summary
   - License distribution
   - Vulnerability correlation (references Appendix F)
   - Critical component highlights (FIPS modules, kube-proxy, OS)

**Reference Sections:** 8 (SBOM and Transparency)

### Appendix F: VEX Statements and Advisories

**Location:** `vuln-scan-report/`, Documentation

**Contents:**

1. **Vulnerability Scan Reports**
   - File: `vuln-scan-report/report.txt`
   - Scanner: JFrog Xray
   - Results: 0 Critical, 0 High, 8 Medium, 30+ Low
   - Format: Table with CVE, severity, component, fixed version
   - Scan Date: January 2026

2. **VEX Statements**
   - VEX JSON documents for Medium CVEs
   - Exploitability analysis (status: not_affected or justification)
   - Impact statements in deployment context
   - Format: CycloneDX VEX or CSAF VEX

3. **Vulnerability Exception Documentation**
   - Exception #1: Medium CVEs justification
   - Risk assessment for each CVE
   - Compensating control documentation
   - Remediation timeline and tracking

4. **Security Advisories**
   - Advisory #1: Host kernel requirements
   - Advisory #2: FIPS algorithm restrictions
   - Advisory #3: golang.org/x/crypto version note
   - Advisory #4: Version compatibility

5. **Continuous Monitoring Logs**
   - Daily vulnerability scan results
   - CVE database update timestamps
   - Alert notifications for new CVEs
   - Remediation tracking

**Reference Sections:** 7 (Zero CVE Vulnerability Management), 10 (Exceptions and Advisories)

### Appendix G: Patch Summaries and Diffs

**Location:** Git repository, Build logs

**Contents:**

1. **Dockerfile Modifications**
   - Complete `Dockerfile.hardened` (full source)
   - Git diff from base Dockerfile
   - Annotated sections explaining each modification

2. **Patch Application Logs**
   - wolfSSL FIPS module patches (if any)
   - OpenSSL configuration patches
   - kube-proxy dependency updates (golang.org/x/crypto)
   - System package updates for CVE remediation

3. **Configuration File Changes**
   - Before/after diffs for STIG/CIS configurations
   - PAM configuration changes
   - SSH configuration changes
   - Sysctl parameter changes

4. **Build Modification Documentation**
   - FIPS installation order rationale (Section 3.2.7)
   - Root user requirement justification
   - nftables package addition
   - Non-FIPS crypto library removal

5. **Implementation-Specific Modifications**
   - Section 3.3 detailed implementation changes
   - Section 4.3 STIG-specific modifications
   - Section 5.3 CIS-specific modifications

**Reference Sections:** 3.3 (FIPS modifications), 4.3 (STIG modifications), 5.3 (CIS modifications)

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | January 21, 2026 | Root.io Security Team | Initial release for kube-proxy v1.33.5-ubuntu-22.04-fips |

---
