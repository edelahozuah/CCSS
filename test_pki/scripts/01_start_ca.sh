#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$BASE_DIR/bin"
PKI_DIR="$BASE_DIR/pki"
PASSWORD_FILE="$BASE_DIR/password.txt"

export STEPPATH="$PKI_DIR"

echo "Starting step-ca on https://localhost:8443..."
"$BIN_DIR/step-ca" "$PKI_DIR/config/ca.json" --password-file "$PASSWORD_FILE"
