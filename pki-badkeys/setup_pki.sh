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

# --- D. ESCENARIO CLAVE DÉBIL (forti.lab) ---
# 1. Generamos una clave ridículamente pequeña (1024 bits)
#    Esto simula una clave antigua o generada en un dispositivo IoT limitado.
#    (Nota: 512 bits es rechazado por Firefox, usamos 1024 para compatibilidad)
openssl genrsa -out forti.key 1024

# 2. Generamos el certificado firmado por nuestra CA
openssl req -new -key forti.key -out forti.csr -subj "/CN=forti.lab"
echo "subjectAltName=DNS:forti.lab" > f.ext
openssl x509 -req -in forti.csr -CA interCA.crt -CAkey interCA.key -CAcreateserial \
    -out forti.crt -days 365 -sha256 -extfile f.ext
cat forti.crt interCA.crt > forti_fullchain.pem

# 3. SIMULACIÓN DE "BADKEYS" / DATABASE LEAK
# Vamos a calcular el Hash del Módulo de esta clave (su "huella dactilar" matemática)
# y guardaremos la Clave Privada en un archivo público simulando una filtración.

MODULUS_HASH=$(openssl rsa -in forti.key -modulus -noout | openssl md5 | awk '{print $2}')

# Creamos el archivo "darkweb_db.txt" en la carpeta compartida
echo "--- BASE DE DATOS DE CLAVES COMPROMETIDAS (LEAK 2024) ---" > /shared_certs/darkweb_db.txt
echo "ID: a1b2c3d4... [REDACTED]" >> /shared_certs/darkweb_db.txt
echo "ID: $MODULUS_HASH KEY:" >> /shared_certs/darkweb_db.txt
# Volcamos la clave privada en una sola línea (base64) para que sea "recuperable"
cat forti.key | grep -v "-" | tr -d '\n' >> /shared_certs/darkweb_db.txt
echo "" >> /shared_certs/darkweb_db.txt

echo "--- [4/4] Configurando NGINX ---"
cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 443 ssl default_server;
    server_name _;
    # Certificado por defecto (valido) para evitar errores en otros dominios
    ssl_certificate /etc/nginx/certs/valido_fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/valido.key;
    location / { 
        default_type text/html;
        return 200 '<h1>PKI Lab Badkeys</h1><p>Servidor por defecto.</p>'; 
    }
}
server {
    listen 443 ssl;
    server_name valido.lab;
    ssl_certificate /etc/nginx/certs/valido_fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/valido.key;
    location / { 
        default_type text/html;
        return 200 '<h1>Correcto</h1><p>Soy valido.lab con cadena completa.</p>'; 
    }
}

server {
    listen 443 ssl;
    server_name forti.lab;
    ssl_certificate /etc/nginx/certs/forti_fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/forti.key;
    # Forzamos cifrados débiles para que sea más realista (opcional)
    ssl_ciphers DEFAULT@SECLEVEL=0;
    
    location / { 
        default_type text/html;
        return 200 '<h1>FortiGate Appliance</h1><p>System Online. Secure Connection Established.</p>'; 
    }
}
EOF