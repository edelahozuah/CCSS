# Laboratorio de PKI en Docker

Laboratorio completo para trabajar con infraestructuras de clave pública (PKI) en un entorno aislado con Docker.

Este zip incluye la estructura base del escenario (`pki-lab/`) con:
- `docker-compose.yml`
- Configuración de Nginx fuerte y débil
- DNS interno con CAA (CoreDNS)
- Cliente de pruebas con openssl, curl, badkeys y Python
- Carpeta para materiales del laboratorio (certificados, claves públicas, etc.)

⚠️ Importante:
- Las carpetas `db-data/` y `ejbca-persistent/` se rellenarán la primera vez que arranques EJBCA.
- Los certificados y claves dentro de `nginx/certs`, `nginx-weak/certs` y `lab-material/keys` deberás generarlos y copiarlos tú siguiendo la guía que hemos comentado.

Para usarlo:
1. Coloca este directorio `pki-lab/` donde quieras trabajar.
2. Completa los certificados y materiales que falten.
3. Ejecuta:

   docker compose up -d

4. Entra en el cliente:

   docker exec -it pki-client bash

El README detallado del laboratorio (enunciado largo) puedes pegarlo aquí o tenerlo aparte para el alumnado.
