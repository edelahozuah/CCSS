#!/bin/bash
set -e

# Configuration
STEP_VERSION="0.24.4"
STEP_CA_VERSION="0.24.2"
ARCH="arm64" # Detected as arm64
PLATFORM="darwin"
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$BASE_DIR/bin"
PKI_DIR="$BASE_DIR/pki"
PASSWORD_FILE="$BASE_DIR/password.txt"

# Create directories
mkdir -p "$BIN_DIR"

# Download step CLI
if [ ! -f "$BIN_DIR/step" ]; then
    echo "Downloading step CLI..."
    curl -L "https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_${PLATFORM}_${STEP_VERSION}_${ARCH}.tar.gz" -o step.tar.gz
    tar -xzf step.tar.gz
    mv "step_${STEP_VERSION}/bin/step" "$BIN_DIR/"
    rm -rf step.tar.gz "step_${STEP_VERSION}"
    echo "step CLI installed."
fi

# Download step-ca
if [ ! -f "$BIN_DIR/step-ca" ]; then
    echo "Downloading step-ca..."
    curl -L "https://github.com/smallstep/certificates/releases/download/v${STEP_CA_VERSION}/step-ca_${PLATFORM}_${STEP_CA_VERSION}_${ARCH}.tar.gz" -o step-ca.tar.gz
    tar -xzf step-ca.tar.gz
    mv "step-ca_${STEP_CA_VERSION}/step-ca" "$BIN_DIR/"
    rm -rf step-ca.tar.gz "step-ca_${STEP_CA_VERSION}"
    echo "step-ca installed."
fi

# Setup Environment
export STEPPATH="$PKI_DIR"

# Initialize PKI if not exists
if [ ! -d "$PKI_DIR" ]; then
    echo "Initializing PKI..."
    # Generate a random password
    openssl rand -base64 32 > "$PASSWORD_FILE"
    
    "$BIN_DIR/step" ca init \
        --name "Test PKI" \
        --dns "localhost" \
        --address ":8443" \
        --provisioner "admin" \
        --password-file "$PASSWORD_FILE" \
        --with-ca-url "https://localhost:8443" \
        --deployment-type standalone

    echo "PKI initialized in $PKI_DIR"
    echo "Root Fingerprint: $("$BIN_DIR/step" certificate fingerprint "$PKI_DIR/certs/root_ca.crt")"
else
    echo "PKI already initialized."
fi

chmod +x "$BIN_DIR/step" "$BIN_DIR/step-ca"
