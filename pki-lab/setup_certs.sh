#!/bin/bash
set -e

# Directorios de destino
STRONG_DIR="./nginx/certs"
WEAK_DIR="./nginx-weak/certs"

mkdir -p "$STRONG_DIR"
mkdir -p "$WEAK_DIR"

echo "=== Generando PKI Fuerte (LabRootCA -> LabSubCA -> nginx.lab) ==="

# 1. Root CA Fuerte
openssl req -x509 -newkey rsa:4096 -keyout "$STRONG_DIR/root_ca.key" -out "$STRONG_DIR/root_ca.crt" -days 3650 -nodes -subj "/CN=LabRootCA/O=Lab PKI/C=ES"

# 2. Intermediate CA
openssl req -newkey rsa:4096 -keyout "$STRONG_DIR/sub_ca.key" -out "$STRONG_DIR/sub_ca.csr" -nodes -subj "/CN=LabSubCA/O=Lab PKI/C=ES"
openssl x509 -req -in "$STRONG_DIR/sub_ca.csr" -CA "$STRONG_DIR/root_ca.crt" -CAkey "$STRONG_DIR/root_ca.key" -CAcreateserial -out "$STRONG_DIR/sub_ca.crt" -days 1825 -extfile <(echo "basicConstraints=CA:TRUE,pathlen:0")

# 3. Servidor Nginx (nginx.lab)
openssl req -newkey rsa:2048 -keyout "$STRONG_DIR/server.key" -out "$STRONG_DIR/server.csr" -nodes -subj "/CN=nginx.lab/O=Lab Services/C=ES"
openssl x509 -req -in "$STRONG_DIR/server.csr" -CA "$STRONG_DIR/sub_ca.crt" -CAkey "$STRONG_DIR/sub_ca.key" -CAcreateserial -out "$STRONG_DIR/server.crt" -days 365 -extfile <(echo "subjectAltName=DNS:nginx.lab")

# 4. Bundles
cat "$STRONG_DIR/server.crt" "$STRONG_DIR/sub_ca.crt" > "$STRONG_DIR/server-fullchain.crt"
cat "$STRONG_DIR/sub_ca.crt" "$STRONG_DIR/root_ca.crt" > "$STRONG_DIR/ca-chain.crt"

echo "PKI Fuerte generada en $STRONG_DIR"

echo "=== Generando PKI Débil (WeakRootCA -> weak-nginx) ==="

# 1. Root CA Débil (RSA 1024 para simular debilidad, aunque openssl moderno podría quejarse, usamos 2048 pero nombre explícito)
openssl req -x509 -newkey rsa:2048 -keyout "$WEAK_DIR/weak_root_ca.key" -out "$WEAK_DIR/WeakRootCA.crt" -days 3650 -nodes -subj "/CN=WeakRootCA/O=Weak Corp/C=XX"

# 2. Servidor Weak Nginx (weak-nginx)
openssl req -newkey rsa:2048 -keyout "$WEAK_DIR/weak-nginx.key" -out "$WEAK_DIR/weak-nginx.csr" -nodes -subj "/CN=weak-nginx/O=Weak Services/C=XX"
openssl x509 -req -in "$WEAK_DIR/weak-nginx.csr" -CA "$WEAK_DIR/WeakRootCA.crt" -CAkey "$WEAK_DIR/weak_root_ca.key" -CAcreateserial -out "$WEAK_DIR/weak-nginx.crt" -days 365 -extfile <(echo "subjectAltName=DNS:weak-nginx")

# 3. Bundles
cat "$WEAK_DIR/weak-nginx.crt" "$WEAK_DIR/WeakRootCA.crt" > "$WEAK_DIR/weak-nginx-fullchain.crt"

echo "PKI Débil generada en $WEAK_DIR"

# Limpieza de CSRs y serials
rm -f "$STRONG_DIR"/*.csr "$STRONG_DIR"/*.srl "$WEAK_DIR"/*.csr "$WEAK_DIR"/*.srl

echo "=== ¡Certificados listos! ==="
