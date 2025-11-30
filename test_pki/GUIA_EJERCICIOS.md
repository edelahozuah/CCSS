# Guía de Ejercicios: Infraestructura de Clave Pública (PKI)

Esta guía te acompañará en el uso de una infraestructura PKI básica para entender cómo funcionan los certificados digitales, las Autoridades de Certificación (CA) y los procesos de emisión y revocación.

## Preparación

Asegúrate de tener cargado el entorno:
```bash
source scripts/02_client_env.sh
```

Y de que la CA esté en ejecución (en otra terminal):
```bash
./scripts/01_start_ca.sh
```

---

## Ejercicio 1: Análisis de la Jerarquía de Confianza

**Objetivo:** Entender la cadena de confianza desde la Root CA hasta la CA Intermedia.

1.  **Identifica los certificados de la CA:**
    Navega al directorio `pki/certs`. Deberías ver `root_ca.crt` y `intermediate_ca.crt`.

2.  **Inspecciona la Root CA:**
    Utiliza el comando `step` para ver los detalles del certificado raíz:
    ```bash
    step certificate inspect pki/certs/root_ca.crt
    ```
    *Pregunta:* ¿Quién es el emisor (`Issuer`) y quién es el sujeto (`Subject`)? ¿Coinciden? (Esto indica que es autofirmado).

3.  **Inspecciona la CA Intermedia:**
    ```bash
    step certificate inspect pki/certs/intermediate_ca.crt
    ```
    *Pregunta:* ¿Quién firmó este certificado? Verifica que el `Issuer` coincida con el `Subject` de la Root CA.

---

## Ejercicio 2: Emisión de Certificados

**Objetivo:** Solicitar y obtener un certificado digital para un servidor web.

1.  **Emite un certificado:**
    Imagina que administras el servidor `web.seguridad.local`. Genera su certificado:
    ```bash
    ./scripts/03_issue_cert.sh web.seguridad.local
    ```

2.  **Analiza el resultado:**
    Revisa los archivos generados en el directorio `certs/`.
    - `.crt`: El certificado público.
    - `.key`: La clave privada (¡nunca debe compartirse!).

3.  **Inspecciona tu certificado:**
    ```bash
    step certificate inspect certs/web.seguridad.local.crt
    ```
    *Pregunta:* ¿Cuál es el periodo de validez? ¿Qué algoritmo de firma se utilizó?

---

## Ejercicio 3: Verificación de la Cadena

**Objetivo:** Comprobar matemáticamente que un certificado es válido y confiable.

1.  **Verificación manual:**
    Utiliza `step` para verificar que el certificado de tu servidor fue firmado correctamente por la Root CA (a través de la intermedia):
    ```bash
    step certificate verify certs/web.seguridad.local.crt --roots pki/certs/root_ca.crt
    ```
    Si no hay salida o dice "ok", es válido.

---

## Ejercicio 4: Revocación

**Objetivo:** Invalidar un certificado antes de que expire (por ejemplo, por compromiso de clave).

1.  **Obtén el número de serie:**
    Necesitas el identificador único del certificado para revocarlo.
    ```bash
    step certificate inspect certs/web.seguridad.local.crt --format json
    ```
    Busca el campo `serial`.

2.  **Revoca el certificado:**
    Ejecuta el script de revocación con el número de serie:
    ```bash
    ./scripts/04_revoke_cert.sh <TU_NUMERO_DE_SERIE>
    ```

3.  **Comprobación (Avanzado):**
    Intentar verificar un certificado revocado debería fallar si el verificador comprueba el estado. (Nota: La verificación simple offline puede no detectar la revocación sin consultar a la CA o una CRL/OCSP).

---

## Ejercicio 5: Automatización con ACME

**Objetivo:** Utilizar el protocolo ACME (el mismo que usa Let's Encrypt) para obtener certificados de forma automatizada.

1.  **Reinicia la CA:**
    Para que la CA reconozca el nuevo provisionador ACME que hemos configurado, debes reiniciarla.
    *   Ve a la terminal donde corre `./scripts/01_start_ca.sh`.
    *   Presiona `Ctrl+C` para detenerla.
    *   Vuelve a ejecutar `./scripts/01_start_ca.sh`.

2.  **Solicita un certificado vía ACME:**
    En lugar de usar una contraseña, usaremos el protocolo ACME. El cliente `step` simulará ser un cliente ACME (como certbot):
    ```bash
    ./bin/step ca certificate acme.ejemplo.local certs/acme.crt certs/acme.key --provisioner acme
    ```
    *Nota:* Observa que no te pide contraseña. La autenticación se realiza mediante "retos" (challenges) que la CA envía al cliente para verificar que controla el identificador.

3.  **Inspecciona el certificado:**
    ```bash
    step certificate inspect certs/acme.crt
    ```
    Verifica que el emisor sigue siendo tu CA intermedia.

---

## Conclusión

Has recorrido el ciclo de vida completo de un certificado:
1.  Confianza en la Raíz.
2.  Emisión por una CA delegada (Manual y ACME).
3.  Uso y Verificación.
4.  Revocación.
