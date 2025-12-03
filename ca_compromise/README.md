# Escenario: Compromiso de CA (OmniTech Breach)

Este escenario simula un incidente crítico de seguridad en una infraestructura de clave pública (PKI): la filtración de la clave privada de una Autoridad de Certificación subordinada.

## Descripción del Escenario

La empresa ficticia **OmniTech Corp** tiene una jerarquía de PKI bien diseñada, con una Root CA offline y CAs intermedias para diferentes propósitos. Sin embargo, debido a un error humano (un backup olvidado), la clave privada de una antigua CA de desarrollo ("Legacy Dev CA") ha sido expuesta.

El objetivo del estudiante es actuar como un atacante que ha encontrado esta clave:
1.  Analizar la filtración.
2.  Importar la clave comprometida.
3.  Emitir certificados falsos que sean confiados por la organización.
4.  Realizar un ataque de Man-in-the-Middle (MITM) contra el portal del CEO.

## El Script `crear_repo.sh`

Este directorio contiene el script `crear_repo.sh`, que actúa como un **generador de laboratorios**.

Su función es crear desde cero una carpeta llamada `omnitech-lab-repo` con todo lo necesario para el ejercicio. No es necesario descargar archivos grandes ni claves pre-generadas; el script lo construye todo dinámicamente.

### ¿Qué hace exactamente el script?

1.  **Genera la PKI Completa**:
    *   Crea una **Root CA** y una **Policy CA** (simulando la jerarquía de confianza).
    *   Emite una **Secure Web CA** (para los servidores legítimos).
    *   Emite una **Legacy Dev CA** (la que será vulnerable).
    *   Emite el certificado legítimo para `portal-ceo.omnitech.corp`.

2.  **Configura Docker**:
    *   Genera el `docker-compose.yml` con la red, IPs y volúmenes.
    *   Crea las configuraciones de Nginx para el servidor legítimo y el servidor del atacante.
    *   Pre-configura un cliente Firefox para que confíe en la Root CA de OmniTech.

3.  **Simula la Filtración (The Leak)**:
    *   Copia la clave privada de la **Legacy Dev CA** a la carpeta `attacker_workspace/leaked_data`.
    *   Copia todos los certificados públicos necesarios para reconstruir la cadena de confianza.

4.  **Limpieza de Seguridad**:
    *   **Borra** las claves privadas de la Root CA y la Policy CA. Esto es crucial para el realismo: el atacante (alumno) solo tiene la clave de la Sub-CA comprometida, no las llaves maestras del reino.

## Instrucciones de Uso

1.  **Generar el Laboratorio**:
    ```bash
    ./crear_repo.sh
    ```

2.  **Entrar al Directorio Generado**:
    ```bash
    cd omnitech-lab-repo
    ```

3.  **Iniciar el Entorno**:
    Sigue las instrucciones del `README.md` que encontrarás dentro de esa carpeta.

---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
