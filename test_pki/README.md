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

## Estructura de Directorios
*   `bin/`: Contiene los binarios `step` y `step-ca`.
*   `pki/`: Contiene la base de datos de la CA, configuración y claves.
*   `scripts/`: Scripts de ayuda para las operaciones.
*   `certs/`: Almacena los certificados emitidos.
