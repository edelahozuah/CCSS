# PKI Teaching Scenario (step-ca)

This scenario provides a self-contained Public Key Infrastructure (PKI) using `step-ca`. It is designed for educational purposes to demonstrate certificate issuance and revocation.

## Prerequisites
- macOS (arm64/Apple Silicon)
- Terminal

## Setup
The environment is already set up with the necessary binaries in `bin/` and the PKI initialized in `pki/`.

To configure your shell environment for using the tools, run:
```bash
source scripts/02_client_env.sh
```

## Operations

### 1. Start the CA
The Certificate Authority (CA) server must be running to issue or revoke certificates.
Open a new terminal tab, source the environment, and run:
```bash
./scripts/01_start_ca.sh
```
Keep this terminal open. The CA listens on `https://localhost:8443`.

### 2. Issue a Certificate
To request and issue a new certificate for a service (e.g., `myservice.local`):
```bash
./scripts/03_issue_cert.sh myservice.local
```
This will generate:
- `certs/myservice.local.crt`: The certificate.
- `certs/myservice.local.key`: The private key.

You can inspect the certificate using:
```bash
step certificate inspect certs/myservice.local.crt
```

### 3. Revoke a Certificate
To revoke a certificate, you need its Serial Number.
Find the serial number:
```bash
step certificate inspect certs/myservice.local.crt --format json | grep serial
```
Or just look at the text output of `inspect`.

Run the revocation script:
```bash
./scripts/04_revoke_cert.sh <serial_number>
```

## Directory Structure
- `bin/`: Contains `step` and `step-ca` binaries.
- `pki/`: Contains the CA database, configuration, and keys.
- `scripts/`: Helper scripts for operations.
- `certs/`: Stores issued certificates.
