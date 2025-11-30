#!/bin/bash
# Source this file to set up your environment
# usage: source scripts/02_client_env.sh

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$BASE_DIR/bin:$PATH"
export STEPPATH="$BASE_DIR/pki"

echo "Environment configured."
echo "STEPPATH set to: $STEPPATH"
echo "step binary added to PATH"
