#!/bin/sh
mkdir -p /etc/nginx/certs
cd /etc/nginx/certs

echo "--- [1/4] Generando ROOT CA ---"
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 \
    -out rootCA.crt -subj "/C=ES/O=Academia PKI/CN=Laboratorio Root CA"

# Copiar RootCA a la carpeta compartida para el estudiante
cp rootCA.crt /shared_certs/Laboratorio_RootCA.crt
chmod 644 /shared_certs/Laboratorio_RootCA.crt

echo "--- [2/4] Generando INTERMEDIATE CA ---"
openssl genrsa -out interCA.key 2048
openssl req -new -key interCA.key -out interCA.csr -subj "/C=ES/O=Academia PKI/CN=Intermediate CA"
cat > ca.ext << EOF
basicConstraints=critical,CA:TRUE
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
openssl x509 -req -in interCA.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial \
    -out interCA.crt -days 1000 -sha256 -extfile ca.ext

echo "--- [3/4] Generando Certificados de Servidor ---"

# A. VALIDO (Cadena Completa)
openssl genrsa -out valido.key 2048
openssl req -new -key valido.key -out valido.csr -subj "/CN=valido.lab"
echo "subjectAltName=DNS:valido.lab" > v.ext
openssl x509 -req -in valido.csr -CA interCA.crt -CAkey interCA.key -CAcreateserial \
    -out valido.crt -days 365 -sha256 -extfile v.ext
cat valido.crt interCA.crt > valido_fullchain.pem

# B. ROTO (Falta Intermedia)
openssl genrsa -out roto.key 2048
openssl req -new -key roto.key -out roto.csr -subj "/CN=roto.lab"
echo "subjectAltName=DNS:roto.lab" > r.ext
openssl x509 -req -in roto.csr -CA interCA.crt -CAkey interCA.key -CAcreateserial \
    -out roto.crt -days 365 -sha256 -extfile r.ext
# NO concatenamos la intermedia. Error intencionado.

# C. PHISHING (Nombre incorrecto)
openssl genrsa -out wrong.key 2048
openssl req -new -key wrong.key -out wrong.csr -subj "/CN=banco-seguro.com"
echo "subjectAltName=DNS:banco-seguro.com" > w.ext
openssl x509 -req -in wrong.csr -CA interCA.crt -CAkey interCA.key -CAcreateserial \
    -out wrong.crt -days 365 -sha256 -extfile w.ext
cat wrong.crt interCA.crt > wrong_fullchain.pem

echo "--- [5/4] ESCENARIO REAL: BADKEY (Fortinet Leak) ---"

# 1. Inyectamos la clave REAL comprometida (Fuente: badkeys/fortikeys/1003.key)
# Esta clave es PÚBLICA en GitHub. Cualquiera la tiene.
cat > forti_compromised.key <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQDSV4/sJqa/84JtKgM9rjoIcF0aC18+PxK/o+8j3kHOJzZPtWQM
jMvj0PDmsvljo9eALFPCxV/KUE+60oT1zZmnO1Cyn/0D9swQeY2Q8daMoxv+rR5e
Lq+FCNsq+O0u9OPO9gqOEk8bTPOWPC5CmnO08zJOvvfvZ9F6tQMq9O+WcQIDAQAB
AoGAY/2iBv7iKy9Y28Hw2fK2T5/NMOQfFL8Oa0w0sD4cQZ/q84+63683VSCW46bT
n01247CmnCGLv47OvbG26N6aX5XFkMv/TmfX5vM4lYCR5w3o8l6O42hmnlTptO6a
gS4w+oHHy3w+zSsxVPOKPCqQcvdDvvVvv/PtOJ+U103jT8ECQQD1X06sX6p/s2gC
m0K9+6Zt2rP/ToxuN24v1F5O4+OJM3i61zPPVQM+0Aoh1y6nCgDVB2vOIO5C6K20
echo "--- [4/4] Configurando NGINX ---"
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 443 ssl default_server;
    server_name _;
    # Certificado por defecto (Phishing/Wrong) para atrapar tráfico desviado
    ssl_certificate /etc/nginx/certs/wrong_fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/wrong.key;
    location / { 
        add_header Content-Type text/html;
        return 200 '<h1>Sitio Interceptado / Phishing</h1><p>Certificado: banco-seguro.com</p>'; 
    }
}
server {
    listen 443 ssl;
    server_name valido.lab;
    ssl_certificate /etc/nginx/certs/valido_fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/valido.key;
    location / { 
        add_header Content-Type text/html;
        return 200 '<h1>Correcto</h1><p>Soy valido.lab con cadena completa.</p>'; 
    }
}
server {
    listen 443 ssl;
    server_name roto.lab;
    ssl_certificate /etc/nginx/certs/roto.crt;
    ssl_certificate_key /etc/nginx/certs/roto.key;
    location / { 
        add_header Content-Type text/html;
        return 200 '<h1>Error de Cadena</h1><p>Soy roto.lab y falta la CA intermedia.</p>'; 
    }
}
EOF