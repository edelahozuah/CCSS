#!/bin/bash

# Nombre del directorio del repositorio
REPO_DIR="omnitech-lab-repo"

echo "🔨 Creando estructura del repositorio en '$REPO_DIR'..."

# 1. Crear directorios
mkdir -p $REPO_DIR/config
mkdir -p $REPO_DIR/pki/public
mkdir -p $REPO_DIR/pki/private
mkdir -p $REPO_DIR/attacker_workspace/leaked_data

# 2. Generar docker-compose.yml
cat > $REPO_DIR/docker-compose.yml <<EOF
version: '3.8'

services:
  # --- SERVIDOR LEGÍTIMO (INTRANET) ---
  intranet-server:
    image: nginx:alpine
    container_name: omnitech-intranet
    networks:
      omnitech-net:
        ipv4_address: 172.20.0.10
    volumes:
      - ./config/intranet.conf:/etc/nginx/conf.d/default.conf
      - ./pki/public/intranet.crt:/etc/nginx/certs/intranet.crt
      - ./pki/private/intranet.key:/etc/nginx/certs/intranet.key

  # --- SERVIDOR DEL ATACANTE (Cebo) ---
  attacker-server:
    image: nginx:alpine
    container_name: omnitech-attacker
    networks:
      omnitech-net:
        ipv4_address: 172.20.0.66
    volumes:
      - ./config/attacker.conf:/etc/nginx/conf.d/default.conf
      # Mapeamos el workspace del alumno para que Nginx coja los certs falsos
      - ./attacker_workspace:/etc/nginx/certs
    restart: always

  # --- VÍCTIMA (FIREFOX) ---
  victim-desktop:
    image: lscr.io/linuxserver/firefox:latest
    container_name: omnitech-victim
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Madrid
      - TITLE=OmniTech Employee PC
    ports:
      - 3000:3000
    shm_size: "1gb"
    networks:
      omnitech-net:
    volumes:
      # Inyectamos la Root CA estática
      - ./pki/public/root-ca.crt:/usr/local/share/ca-certificates/root-ca.crt
      # Inyectamos la política de confianza
      - ./config/policies.json:/usr/lib/firefox/distribution/policies.json
    depends_on:
      - intranet-server

networks:
  omnitech-net:
    ipam:
      config:
        - subnet: 172.20.0.0/24
EOF

# 3. Generar Configuración de Firefox (policies.json)
cat > $REPO_DIR/config/policies.json <<EOF
{
  "policies": {
    "Certificates": {
      "ImportEnterpriseRoots": true,
      "Install": [ "/usr/local/share/ca-certificates/root-ca.crt" ]
    },
    "DisableAppUpdate": true,
    "Homepage": {
      "StartPage": "homepage",
      "URL": "https://portal-ceo.omnitech.corp"
    }
  }
}
EOF

# 4. Generar Configuración Nginx (Intranet)
cat > $REPO_DIR/config/intranet.conf <<EOF
server {
    listen 443 ssl;
    server_name portal-ceo.omnitech.corp;
    ssl_certificate /etc/nginx/certs/intranet.crt;
    ssl_certificate_key /etc/nginx/certs/intranet.key;
    location / {
        return 200 'Bienvenido al Portal Seguro del CEO. (Firma: OmniTech Secure Web CA)';
        add_header Content-Type text/plain;
    }
}
EOF

# 5. Generar Configuración Nginx (Atacante)
cat > $REPO_DIR/config/attacker.conf <<EOF
server {
    listen 443 ssl;
    server_name portal-ceo.omnitech.corp;
    # Estos archivos NO existen aun, el alumno debe crearlos con esos nombres
    ssl_certificate /etc/nginx/certs/fake.crt;
    ssl_certificate_key /etc/nginx/certs/fake.pem;
    location / {
        add_header Content-Type text/html;
        return 200 '<html><body style="background-color:darkred; color:white; text-align:center;"><h1>⚠️ SITIO COMPROMETIDO ⚠️</h1><h2>Si ves el candado verde, la PKI ha fallado.</h2></body></html>';
    }
}
EOF

# 6. --- GENERACIÓN DE LA PKI (ESTÁTICA) ---
echo "🔐 Generando claves y certificados..."
PKI_DIR="$REPO_DIR/pki"

# CA RAÍZ (G2)
openssl genrsa -out $PKI_DIR/private/root-ca.key 4096 2>/dev/null
openssl req -x509 -new -nodes -key $PKI_DIR/private/root-ca.key -sha256 -days 3650 \
    -out $PKI_DIR/public/root-ca.crt \
    -subj "/C=ES/O=OmniTech Global Solutions S.A./CN=OmniTech Global Root CA G2" 2>/dev/null

# CA POLICY
openssl genrsa -out $PKI_DIR/private/policy-ca.key 4096 2>/dev/null
openssl req -new -key $PKI_DIR/private/policy-ca.key -out $PKI_DIR/policy-ca.csr \
    -subj "/C=ES/O=OmniTech Global Solutions S.A./OU=Trust Services/CN=OmniTech Corporate Trust CA" 2>/dev/null
openssl x509 -req -in $PKI_DIR/policy-ca.csr -CA $PKI_DIR/public/root-ca.crt -CAkey $PKI_DIR/private/root-ca.key -CAcreateserial \
    -out $PKI_DIR/public/policy-ca.crt -days 1825 -sha256 -extfile <(echo "basicConstraints=critical,CA:TRUE,pathlen:1") 2>/dev/null

# RAMA SEGURA (Secure Web CA)
openssl genrsa -out $PKI_DIR/private/secure-ca.key 2048 2>/dev/null
openssl req -new -key $PKI_DIR/private/secure-ca.key -out $PKI_DIR/secure-ca.csr \
    -subj "/C=ES/O=OmniTech Global Solutions S.A./OU=Web Infrastructure/CN=OmniTech Secure Web CA" 2>/dev/null
openssl x509 -req -in $PKI_DIR/secure-ca.csr -CA $PKI_DIR/public/policy-ca.crt -CAkey $PKI_DIR/private/policy-ca.key -CAcreateserial \
    -out $PKI_DIR/public/secure-ca.crt -days 1000 -sha256 -extfile <(echo "basicConstraints=critical,CA:TRUE,pathlen:0") 2>/dev/null

# RAMA VULNERABLE (Legacy Dev CA)
openssl genrsa -out $PKI_DIR/private/legacy-ca.key 2048 2>/dev/null
openssl req -new -key $PKI_DIR/private/legacy-ca.key -out $PKI_DIR/legacy-ca.csr \
    -subj "/C=ES/O=OmniTech Global Solutions S.A./OU=Development Labs/CN=OmniTech Legacy Dev CA" 2>/dev/null
openssl x509 -req -in $PKI_DIR/legacy-ca.csr -CA $PKI_DIR/public/policy-ca.crt -CAkey $PKI_DIR/private/policy-ca.key -CAcreateserial \
    -out $PKI_DIR/public/legacy-ca.crt -days 3650 -sha256 -extfile <(echo "basicConstraints=critical,CA:TRUE,pathlen:0") 2>/dev/null

# CERTIFICADO FINAL (INTRANET REAL)
openssl genrsa -out $PKI_DIR/private/intranet.key 2048 2>/dev/null
openssl req -new -key $PKI_DIR/private/intranet.key -out $PKI_DIR/intranet.csr \
    -subj "/C=ES/O=OmniTech Global Solutions S.A./CN=portal-ceo.omnitech.corp" 2>/dev/null
openssl x509 -req -in $PKI_DIR/intranet.csr -CA $PKI_DIR/public/secure-ca.crt -CAkey $PKI_DIR/private/secure-ca.key -CAcreateserial \
    -out $PKI_DIR/public/intranet.crt -days 365 -sha256 2>/dev/null

# 7. Preparar los datos para el alumno ("El LEAK")
echo "📦 Empaquetando datos filtrados..."
# Copiamos TODOS los certificados públicos (necesarios para construir la cadena en XCA)
cp $PKI_DIR/public/*.crt $REPO_DIR/attacker_workspace/leaked_data/
# Copiamos SOLO la clave privada vulnerable
cp $PKI_DIR/private/legacy-ca.key $REPO_DIR/attacker_workspace/leaked_data/

# 8. LIMPIEZA DE SEGURIDAD (Simulación)
# Borramos las claves privadas Root y Policy para que NO estén en el repo
# Así el alumno ve que es una infraestructura "segura" salvo por el fallo.
rm $PKI_DIR/private/root-ca.key
rm $PKI_DIR/private/policy-ca.key
# Borramos CSRs y archivos temporales
find $PKI_DIR -name "*.csr" -type f -delete
find $PKI_DIR -name "*.srl" -type f -delete

# 9. Crear README.md
cat > $REPO_DIR/README.md <<EOF
# Laboratorio: OmniTech PKI Breach

Este entorno simula una infraestructura de clave pública (PKI) comprometida.
El objetivo es demostrar cómo la pérdida de una clave privada de una Sub-CA permite la suplantación total de identidad.

## Estructura
* **Víctima:** Un escritorio Linux con Firefox pre-configurado para confiar en la CA de OmniTech.
* **Intranet:** Servidor legítimo (\`portal-ceo.omnitech.corp\`).
* **Atacante:** Espacio de trabajo donde depositarás tus certificados falsos.

## Instrucciones para el Alumno

1. **Arrancar el entorno:**
   \`docker-compose up -d\`

2. **Acceder a la víctima:**
   Abre tu navegador en \`http://localhost:3000\`. Verás que \`portal-ceo.omnitech.corp\` carga correctamente con candado verde.

3. **La Misión:**
   Has encontrado una filtración de datos en la carpeta \`attacker_workspace/leaked_data\`.
   * Importa estos datos en **XCA**.
   * Crea un certificado falso para \`portal-ceo.omnitech.corp\`.
   * Exporta el certificado como \`fake.crt\` y la clave como \`fake.pem\` en la carpeta \`attacker_workspace\`.
   
4. **Ejecutar el ataque:**
   Reinicia el contenedor atacante: \`docker restart omnitech-attacker\`.
   En el escritorio víctima, modifica \`/etc/hosts\` para apuntar el dominio a \`172.20.0.66\`.
   ¡Recarga Firefox y observa!

EOF

# 10. Crear .gitignore
cat > $REPO_DIR/.gitignore <<EOF
# Ignorar claves privadas EXCEPTO las que son parte del escenario docente
*.key
*.pem
!pki/private/intranet.key
!pki/private/secure-ca.key
!pki/private/legacy-ca.key
!attacker_workspace/leaked_data/*.key
EOF

echo "✅ ¡Repositorio listo en la carpeta '$REPO_DIR'!"
echo "👉 Pasos siguientes:"
echo "   cd $REPO_DIR"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit PKI Lab'"
echo "   (Subir a GitHub)"
