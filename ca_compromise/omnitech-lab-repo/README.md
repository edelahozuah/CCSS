# Laboratorio: OmniTech PKI Breach

Este entorno simula una infraestructura de clave pública (PKI) comprometida.
El objetivo es demostrar cómo la pérdida de una clave privada de una Sub-CA permite la suplantación total de identidad.

## Sobre OmniTech
**OmniTech Corp.** es una corporación tecnológica multinacional ficticia que sirve como objetivo en este escenario. La compañía cuenta con una infraestructura de seguridad interna estricta, pero arrastra deuda técnica de sistemas heredados que no han sido decomisados correctamente.

## Estructura
* **Víctima:** Un escritorio Linux con Firefox pre-configurado para confiar en la CA de OmniTech.
* **Intranet:** Servidor legítimo (`portal-ceo.omnitech.corp`).
* **Atacante:** Espacio de trabajo donde depositarás tus certificados falsos.

## Instrucciones para el Alumno

1. **Arrancar el entorno:**
   `docker-compose up -d`

2. **Acceder a la víctima:**
   Abre tu navegador en `http://localhost:3000`. Verás que `portal-ceo.omnitech.corp` carga correctamente con candado verde.

3. **La Misión:**
   **Contexto de la Filtración:**
   Un antiguo ingeniero de DevOps de OmniTech subió accidentalmente un archivo `backup_pki_legacy.zip` a un repositorio público en GitHub.
   
   Al analizar el contenido, los atacantes descubrieron la clave privada de la **OmniTech Legacy CA**. Aunque esta CA estaba teóricamente en desuso, **nunca fue revocada** y sigue estando presente en el almacén de confianza de todos los equipos corporativos (incluido el de la víctima) para mantener compatibilidad con sistemas antiguos.
   
   Esto significa que, con esta clave, puedes generar certificados válidos para *cualquier* dominio de `omnitech.corp` que serán aceptados ciegamente por los empleados.
   
   Los archivos recuperados se encuentran en `attacker_workspace/leaked_data`.
   
   **Pasos detallados en XCA:**
   1.  Accede al escritorio del atacante en `http://localhost:3001`.
   2.  Abre la aplicación **XCA**.
   3.  **Importar Claves:** Ve a la pestaña **Private Keys** > **Import**. Navega a `/config/Desktop/LEAKED_DATA` y selecciona `legacy-ca.key`.
   4.  **Importar Certificados:** Ve a la pestaña **Certificates** > **Import**. Selecciona todos los archivos `.crt` de la misma carpeta.
   5.  **Verificar:** Asegúrate de que el certificado `OmniTech Legacy CA` tiene un icono indicando que la clave privada está disponible.
   6.  **Crear Certificado Falso:**
       *   Usa la `OmniTech Legacy CA` para firmar un nuevo certificado.
       *   Subject: `CN=portal-ceo.omnitech.corp`.
       *   Extensiones: Asegúrate de incluir `Subject Alternative Name` (DNS: portal-ceo.omnitech.corp).
   7.  **Exportar:**
       *   Exporta el certificado creado como `fake.crt` (PEM) en `/config/Desktop/OUTPUT_TO_SERVER`.
       *   Exporta la clave privada correspondiente como `fake.pem` (PEM private) en la misma carpeta.
   
4. **Ejecutar el ataque:**
   Reinicia el contenedor atacante para que Nginx cargue los nuevos certificados:
   ```bash
   docker restart omnitech-attacker-nginx
   ```
   
   **Configurar la Víctima:**
   1.  Averigua la IP del contenedor atacante:
       ```bash
       docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' omnitech-attacker-nginx
       ```
   2.  En el escritorio víctima (`http://localhost:3000`), abre una terminal.
   3.  Edita `/etc/hosts` (usando `sudo nano /etc/hosts` o similar) y apunta el dominio `portal-ceo.omnitech.corp` a la IP que obtuviste en el paso anterior.
   4.  ¡Recarga Firefox y observa el candado verde!

