# Escenario: PKI Badkeys (Fortinet Leak)

Este escenario se centra en la detección y explotación de claves criptográficas débiles o comprometidas, específicamente simulando la vulnerabilidad de claves SSH/TLS predecibles en dispositivos Fortinet (CVE-2016-1909).

## Arquitectura del Laboratorio

El entorno consta de:

*   **`web-pki` (Nginx)**: Servidor web que aloja el dominio vulnerable `forti.lab`.
*   **`dns-attacker` (Dnsmasq)**: Servidor DNS interno (Subred `10.60.0.0/24`).
*   **`gui-client` (Firefox)**: Cliente para realizar las pruebas.

## Dominios

| Dominio | Descripción |
| :--- | :--- |
| **`https://valido.lab`** | **Control**. Configuración correcta para verificar que la CA está instalada. |
| **`https://forti.lab`** | **Vulnerable**. Utiliza un certificado cuya clave privada ha sido comprometida y es pública. |

## Instrucciones de Uso

### 1. Iniciar el Laboratorio
```bash
docker-compose up -d
```

### 2. Acceder al Cliente
Abre [http://localhost:3000](http://localhost:3000) para acceder al escritorio VNC con Firefox.

### 3. Instalar la Root CA
Importa `/shared_certs/Laboratorio_RootCA.crt` en Firefox para confiar en la CA del laboratorio.

### 4. El Reto (Badkeys)
1.  Navega a `https://forti.lab`. Verás que funciona correctamente.
2.  Tu objetivo es demostrar que la clave es insegura.
3.  Ve al directorio `badkeys/` dentro de este escenario y sigue las instrucciones del [README](./badkeys/README.md).
    *   Tendrás que usar la herramienta `badkeys` para detectar la vulnerabilidad.
    *   Encontrarás la clave privada "filtrada" en `/shared_certs/darkweb_db.txt` (simulado).

---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
