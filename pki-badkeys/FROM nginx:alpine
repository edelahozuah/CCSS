FROM nginx:alpine

# Herramientas para generar certificados
RUN apk add --no-cache openssl

# Copiamos el script de generación
COPY setup_pki.sh /docker-entrypoint.d/99-setup_pki.sh
RUN chmod +x /docker-entrypoint.d/99-setup_pki.sh

# El entrypoint original de nginx-alpine ejecutará nuestro script