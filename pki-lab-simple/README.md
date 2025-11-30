# Laboratorio Simplificado de PKI y Certificados

Este escenario proporciona un entorno controlado para experimentar con errores comunes de configuración en servidores web HTTPS, jerarquías de confianza (PKI) y vulnerabilidades de claves.

## Arquitectura del Laboratorio

El entorno se despliega mediante Docker Compose y consta de los siguientes servicios:

*   **`web-pki` (Nginx)**: Un servidor web que aloja múltiples dominios virtuales, cada uno con una configuración TLS diferente (correcta, rota, débil, etc.). Los certificados se generan automáticamente al construir la imagen mediante el script `setup_pki.sh`.
*   **`dns-attacker` (Dnsmasq)**: Un servidor DNS interno que resuelve los dominios del laboratorio (`.lab`) hacia el servidor web o el atacante.
*   **`attacker-mitm` (Mitmproxy)**: Un proxy para interceptar tráfico (usado en ejercicios avanzados).
*   **`gui-client` (Firefox)**: Un navegador web accesible vía VNC/navegador para realizar las pruebas desde "dentro" de la red del laboratorio.

## Dominios y Escenarios

El servidor web está configurado para responder a los siguientes dominios, cada uno ilustrando un concepto diferente:

| Dominio | Descripción del Escenario |
| :--- | :--- |
| **`https://valido.lab`** | **Configuración Correcta**. El servidor envía el certificado final y la cadena completa (CA Intermedia). El navegador debería confiar en él si se importa la Root CA. |
| **`https://roto.lab`** | **Cadena Incompleta**. El servidor envía solo su certificado final, olvidando la CA Intermedia. Esto provoca el error `SEC_ERROR_UNKNOWN_ISSUER` en muchos clientes. |
| **`https://forti.lab`** | **Clave Comprometida**. Utiliza una clave expuesta: un atacante podría derivar la clave privada a partir de la pública. (Ver ejercicio `badkeys`). |
| **`https://banco-seguro.com`** | **Phishing / Nombre Incorrecto**. El servidor presenta un certificado válido pero para un dominio diferente, o autofirmado por una CA no confiable. |

## Instrucciones de Uso

### 1. Iniciar el Laboratorio
```bash
docker-compose up -d
```

### 2. Acceder al Cliente (Firefox)
Abre tu navegador en tu máquina host y ve a:
👉 [http://localhost:3000](http://localhost:3000)

Esto abrirá una sesión de Firefox que corre dentro de la red Docker.

### 3. Instalar la Root CA (Confianza)
Para que los ejercicios funcionen como se espera, primero debes confiar en la "Autoridad de Certificación del Laboratorio".
1.  En el Firefox virtual, ve a `Settings` -> `Privacy & Security` -> `Certificates` -> `View Certificates`.
2.  Importa el archivo `/shared_certs/Laboratorio_RootCA.crt`.
3.  Marca la casilla para confiar en él para identificar sitios web.

### 4. Realizar Pruebas
Navega a los diferentes dominios (`https://valido.lab`, `https://roto.lab`, etc.) y observa cómo reacciona el navegador.

## Ejercicios Adicionales
*   **Badkeys**: Revisa la carpeta `badkeys/` para un ejercicio sobre detección de claves comprometidas.

---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
