#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <serial_number>"
    echo "You can find the serial number using: step certificate inspect certs/example.crt"
    exit 1
fi

SERIAL="$1"
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$BASE_DIR/bin"
PKI_DIR="$BASE_DIR/pki"

export STEPPATH="$PKI_DIR"

echo "Generating revocation token..."
TOKEN=$("$BIN_DIR/step" ca token "$SERIAL" --revoke \
    --ca-url "https://localhost:8443" \
    --root "$PKI_DIR/certs/root_ca.crt" \
    --provisioner "admin" \
    --provisioner-password-file "$BASE_DIR/password.txt")

echo "Revoking certificate with serial: $SERIAL..."
"$BIN_DIR/step" ca revoke "$SERIAL" \
    --token "$TOKEN" \
    --ca-url "https://localhost:8443" \
    --root "$PKI_DIR/certs/root_ca.crt"

echo "Certificate revoked."
