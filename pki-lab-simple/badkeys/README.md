# Badkeys: Detección de Claves Comprometidas

El proyecto **Badkeys** mantiene repositorios con miles de claves SSH y TLS que se sabe que son inseguras (filtradas, generadas con entropía débil, etc.).

En este ejercicio, verificaremos si una clave utilizada en nuestro laboratorio está comprometida.

## Instrucciones

### 1. Preparación
En el **Firefox virtual** del laboratorio, abre una nueva pestaña.

### 2. Buscar en el Repositorio de Claves
Vamos a utilizar el repositorio de claves filtradas de Fortinet como ejemplo.
Accede a la siguiente URL:
👉 [https://github.com/badkeys/fortikeys](https://github.com/badkeys/fortikeys)

Este repositorio contiene claves privadas reales que han sido filtradas.
Entra en la carpeta `keys`. Verás cientos de archivos.

### 3. Identificar la Clave
¿Cómo sabemos si nuestra clave está en esa lista?

**Método 1: Búsqueda por Módulo (Difícil)**
Podrías intentar buscar el módulo de tu certificado en la barra de búsqueda del repositorio, pero a veces la búsqueda de código hexadecimal en GitHub falla.

**Método 2: Comprobación Directa (Didáctico)**
Para esta demostración, sospechamos que la clave coincide con el archivo `1003.key`.
1.  Ve directamente a: [https://github.com/badkeys/fortikeys/blob/main/keys/1003.key](https://github.com/badkeys/fortikeys/blob/main/keys/1003.key)
2.  Verás el contenido empezando por `-----BEGIN RSA PRIVATE KEY-----`.
3.  ¡Es una clave privada! Pero necesitamos confirmar que es la que usa nuestro servidor.

### 4. Cotejo Profesional (Match de Fingerprint)
Para confirmar científicamente sin comparar caracteres a ojo, calcularemos el **Hash SHA256** de la clave pública del servidor (SPKI) y lo buscaremos en la lista de huellas del repositorio.

1.  **Calcula el fingerprint** en tu terminal:

    ```bash
    echo | openssl s_client -connect forti.lab:443 2>/dev/null \
        | openssl x509 -noout -pubkey \
        | openssl pkey -pubin -outform DER \
        | openssl dgst -sha256
    ```
    *Explicación:* Extraemos la clave pública -> La convertimos a formato binario (DER) -> Calculamos su hash SHA256.

2.  **Obtén el resultado**, por ejemplo: `(stdin)= 1e928...`

3.  **Busca el hash**:
    *   Vuelve a Firefox y ve al archivo de huellas: [fingerprints/sha256.txt](https://github.com/badkeys/fortikeys/blob/main/fingerprints/sha256.txt)
    *   Pulsa `Ctrl+F` y pega el hash que obtuviste en la terminal.

Si aparece en la lista, **¡la clave está comprometida!**

---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
