#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <common_name>"
    exit 1
fi

CN="$1"
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$BASE_DIR/bin"
PKI_DIR="$BASE_DIR/pki"

export STEPPATH="$PKI_DIR"

# Ensure certs directory exists
mkdir -p "$BASE_DIR/certs"

echo "Issuing certificate for $CN..."
"$BIN_DIR/step" ca certificate "$CN" "$BASE_DIR/certs/$CN.crt" "$BASE_DIR/certs/$CN.key" \
    --ca-url "https://localhost:8443" \
    --root "$PKI_DIR/certs/root_ca.crt" \
    --provisioner "admin" \
    --provisioner-password-file "$BASE_DIR/password.txt"

echo "Certificate issued: $BASE_DIR/certs/$CN.crt"
echo "Private Key: $BASE_DIR/certs/$CN.key"
