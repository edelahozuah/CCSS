# Escenario de Enseñanza PKI (step-ca)

Este escenario proporciona una Infraestructura de Clave Pública (PKI) autocontenida utilizando **step-ca**. Está diseñado con fines educativos para demostrar la emisión y revocación de certificados de manera sencilla y moderna.

## ¿Qué es step-ca?

[`step-ca`](https://smallstep.com/docs/step-ca) es una autoridad de certificación (CA) privada, online y segura, desarrollada por **Smallstep**. A diferencia de las herramientas tradicionales basadas en OpenSSL (que suelen ser manuales y propensas a errores), `step-ca` está diseñada para la automatización y la seguridad moderna:

*   **Soporte ACME**: El mismo protocolo que usa Let's Encrypt, permitiendo automatización total.
*   **API REST**: Para integración programática.
*   **Efímera**: Fomenta el uso de certificados de corta duración para mejorar la seguridad.

En este laboratorio, utilizamos `step-ca` para simular una CA corporativa interna.

## Requisitos

*   macOS (compatible con Apple Silicon/Intel)
*   Terminal

## Configuración Inicial

El entorno ya está preparado con los binarios necesarios en `bin/` y la PKI inicializada en `pki/`.

Para configurar tu entorno de shell y poder usar las herramientas, ejecuta:

```bash
source scripts/02_client_env.sh
```

## Procedimientos de Operación

### 1. Iniciar la CA
El servidor de la Autoridad de Certificación debe estar en ejecución para poder emitir o revocar certificados.
Abre una **nueva pestaña** de terminal, carga el entorno (`source scripts/02_client_env.sh`) y ejecuta:

```bash
./scripts/01_start_ca.sh
```

Mantén esta terminal abierta. La CA escuchará en `https://localhost:8443`.

### 2. Emitir un Certificado
Para solicitar y emitir un nuevo certificado para un servicio (por ejemplo, `miservicio.local`):

```bash
./scripts/03_issue_cert.sh miservicio.local
```

Esto generará en la carpeta `certs/`:
*   `miservicio.local.crt`: El certificado público.
*   `miservicio.local.key`: La clave privada.

Puedes inspeccionar el certificado generado con:
```bash
step certificate inspect certs/miservicio.local.crt
```

### 3. Revocar un Certificado
Para revocar un certificado, necesitas su **Número de Serie**.

1.  Encuentra el número de serie:
    ```bash
    step certificate inspect certs/miservicio.local.crt --format json | grep serial
    ```
    (O simplemente mira la salida de texto del comando `inspect`).

2.  Ejecuta el script de revocación:
    ```bash
    ./scripts/04_revoke_cert.sh <NUMERO_DE_SERIE>
    ```

## Guía de Ejercicios
Para una guía paso a paso más detallada sobre los conceptos de PKI, consulta la [Guía de Ejercicios](./GUIA_EJERCICIOS.md).

## Estructura Detallada del Directorio `pki/`

El corazón de este escenario reside en el directorio `pki/`, que contiene todo el estado de la Autoridad de Certificación:

*   **`pki/certs/`**: Almacena los certificados públicos de la propia infraestructura.
    *   `root_ca.crt`: El certificado raíz (Root CA). Este es el que debes instalar en tus navegadores/sistemas para que confíen en todo lo emitido por esta PKI.
    *   `intermediate_ca.crt`: La CA intermedia que realmente firma los certificados finales.
*   **`pki/secrets/`**: **¡CRÍTICO!** Contiene las claves privadas.
    *   `root_ca_key`: La clave privada de la raíz. En un entorno real, esta clave estaría offline y protegida físicamente.
    *   `intermediate_ca_key`: La clave privada de la intermedia, usada por el servicio `step-ca` para firmar al vuelo.
*   **`pki/config/`**: Configuración del servidor CA.
    *   `ca.json`: Archivo principal de configuración. Define los provisionadores (quién puede pedir certificados), las direcciones de escucha, y las políticas.
    *   `defaults.json`: Valores por defecto para la inicialización.
*   **`pki/db/`**: Base de datos interna (BadgerDB) donde `step-ca` lleva el registro de los certificados emitidos y revocados.

## Personalización del Escenario

Si deseas adaptar este laboratorio para otros ejercicios, aquí tienes algunas pistas:

### Cambiar la duración de los certificados
Por defecto, `step-ca` emite certificados de corta duración (ej. 24 horas). Para cambiar esto, puedes modificar el archivo `pki/config/ca.json`. Busca la sección `claims` dentro de tu provisionador y añade o modifica:
```json
"claims": {
    "maxTLSCertDuration": "168h",
    "defaultTLSCertDuration": "24h"
}
```
*(Nota: Necesitarás reiniciar la CA tras los cambios)*.

### Añadir nuevos "Provisionadores"
Actualmente, la CA está configurada con un provisionador tipo JWK (basado en contraseña). Puedes añadir soporte para OIDC (Google, Azure AD) o ACME (para usar con certbot) editando la lista `provisioners` en `ca.json`.

### Resetear el entorno
Si quieres empezar de cero (borrar toda la PKI y crear una nueva), simplemente elimina el directorio `pki/` y vuelve a ejecutar el script de setup (si dispones de uno) o inicializa manualmente con `step ca init`.

