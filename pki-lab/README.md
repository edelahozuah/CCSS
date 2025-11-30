# Laboratorio de PKI en Docker

Laboratorio completo para trabajar con infraestructuras de clave pública (PKI) en un entorno aislado con Docker.

Este escenario viene **PRE-CONFIGURADO** para facilitar su uso inmediato.

## Contenido
- `docker-compose.yml`: Orquestación de servicios.
- **PKI Fuerte**: Certificados generados para `nginx.lab` (en `nginx/certs`).
- **PKI Débil**: Certificados generados para `weak-nginx` (en `nginx-weak/certs`).
- **EJBCA**: Servidor de CA completo (las bases de datos se inicializan al arrancar).
- **Cliente**: Contenedor con herramientas (`openssl`, `curl`, `badkeys`).

## Instrucciones de Uso

1.  **Arrancar el entorno:**
    ```bash
    docker compose up -d
    ```

2.  **Acceder al cliente:**
    ```bash
    docker exec -it pki-client bash
    ```

3.  **Realizar las pruebas:**
    Desde el cliente, puedes probar la conexión a los servidores seguros y analizar la confianza de los certificados.

    *   Conectar al sitio seguro:
        ```bash
        curl -v --cacert /lab/material/root_ca.crt https://nginx.lab:8444
        ```
    *   Conectar al sitio débil:
        ```bash
        curl -v --insecure https://weak-nginx:8445
        ```

## Notas
- Los certificados han sido generados automáticamente por el script `setup_certs.sh`.
- Si necesitas regenerarlos desde cero, puedes borrar el contenido de las carpetas `certs` y volver a ejecutar dicho script.



---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
