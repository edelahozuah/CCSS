#!/bin/bash
set -e

# Create certs directory if it doesn't exist
mkdir -p certs

# --- 1. Superfish CA (The "Malicious" Root) ---
echo "Generating Superfish Root CA (Encrypted Key)..."
# Generate encrypted private key
openssl genrsa -aes256 -passout pass:komodia -out certs/superfish.enc.key 2048
# Generate certificate using the encrypted key
openssl req -x509 -new -key certs/superfish.enc.key -passin pass:komodia -out certs/superfish.crt -days 3650 -subj "/C=US/ST=CA/L=PaloAlto/O=Superfish Inc./CN=Superfish, Inc. CA"

# Note: We do NOT generate superfish.pem here. 
# The victim service will decrypt the key and generate the PEM at runtime.

# --- 2. Real CA (The "Legitimate" Root) ---
echo "Generating Real Root CA..."
openssl req -x509 -new -nodes -keyout certs/real_ca.key -out certs/real_ca.crt -days 3650 -subj "/C=US/ST=NY/L=NewYork/O=Global Trust/CN=Global Trust Root CA"

# --- 3. Real Certificate for secure.bank.com ---
# This is what the actual server will use.
echo "Generating legitimate certificate for secure.bank.com..."
openssl req -new -newkey rsa:2048 -nodes -keyout certs/real_site.key -out certs/real_site.csr -subj "/C=US/ST=NY/L=NewYork/O=Bank of Security/CN=secure.bank.com"

# Sign with Real CA
openssl x509 -req -in certs/real_site.csr -CA certs/real_ca.crt -CAkey certs/real_ca.key -CAcreateserial -out certs/real_site.crt -days 365

echo "Certificates generated in certs/"
ls -l certs/
