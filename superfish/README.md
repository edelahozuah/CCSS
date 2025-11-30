# Superfish Vulnerability Recreation

Este escenario recrea la infame vulnerabilidad **Superfish** (2014-2015), donde un software preinstalado en portátiles Lenovo (VisualDiscovery) instalaba una **Root CA propia** y utilizaba la **misma clave privada** en todos los dispositivos para interceptar tráfico SSL/TLS e inyectar publicidad.

## ¿Qué simula este laboratorio?

1.  **Víctima (`superfish-victim`)**: Un contenedor que confía en la CA de "Superfish". Tiene un script en Python (`superfish_service.py`) que actúa como el software adware:
    *   Descifra la clave privada de la CA usando una contraseña hardcodeada (`komodia`).
    *   Levanta un proxy transparente (`mitmproxy`) usando esa clave.
2.  **Objetivo (`superfish-target`)**: Un servidor web seguro (`https://secure.bank.com`) que representa un sitio legítimo.

## Funcionamiento

El tráfico de la víctima hacia `secure.bank.com` es interceptado por el proxy local. Como el proxy tiene la clave de la CA raíz en la que confía el sistema, puede generar certificados falsos "al vuelo" para cualquier dominio.

El navegador (o `curl` en este caso) ve un candado verde válido, pero el certificado ha sido firmado por "Superfish", no por una CA legítima.

## Instrucciones de Uso

1.  **Iniciar el entorno:**
    ```bash
    docker-compose up -d
    ```

2.  **Verificar la intercepción:**
    Accede al contenedor de la víctima y realiza una petición al banco:
    ```bash
    docker exec -it superfish-victim bash
    curl -v https://secure.bank.com
    ```

3.  **Análisis:**
    Observa la salida de `curl`. Verás que el `Issuer` del certificado es `Superfish`, a pesar de que estás conectando a `secure.bank.com`.

    ```text
    * Server certificate:
    *  subject: CN=secure.bank.com
    *  start date: ...
    *  expire date: ...
    *  issuer: C=US; ST=CA; L=San Francisco; O=Superfish Inc.; CN=Superfish Root CA
    ```

## Lección Aprendida

Este escenario demuestra el peligro de:
1.  Instalar CAs raíz de terceros en los almacenes de confianza.
2.  Reutilizar claves privadas en múltiples dispositivos.
3.  Proteger claves privadas con contraseñas débiles o hardcodeadas.
