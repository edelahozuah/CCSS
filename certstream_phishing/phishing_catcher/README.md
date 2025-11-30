# Phishing Catcher (Fork Adaptado)

Este proyecto es un **fork** del repositorio original [phishing_catcher](https://github.com/x0rz/phishing_catcher), el cual ha sido modificado para funcionar en un entorno local donde consumimos datos de una instancia propia de **CertStream**.

## Descripción

Detecta posibles dominios de phishing en tiempo casi real observando las emisiones de certificados TLS reportadas al [Certificate Transparency Log (CTL)](https://www.certificate-transparency.org/) a través de la API de CertStream. Las emisiones "sospechosas" son aquellas cuyo nombre de dominio obtiene una puntuación superior a un cierto umbral basado en un archivo de configuración.

Este escenario está diseñado para probar la detección sobre un log de transparencia de certificados que consultamos mediante una instancia local de `certstream`.

![Screencast of example usage.](https://i.imgur.com/4BGuXkR.gif)

## ¿Qué es Certificate Transparency?

**Certificate Transparency (CT)** es un estándar abierto y un ecosistema diseñado para corregir deficiencias estructurales en el sistema de certificados SSL/TLS. Permite monitorizar y auditar la emisión de certificados en tiempo real.

Su funcionamiento se basa en **logs públicos de solo anexado** (append-only logs) donde las Autoridades de Certificación (CAs) registran cada certificado que emiten. Esto hace imposible que una CA emita un certificado para un dominio sin que este hecho sea público y visible, permitiendo a los propietarios de dominios detectar emisiones no autorizadas o maliciosas rápidamente.

## Instalación y Uso con Docker (Recomendado)

Este escenario está preparado para ejecutarse utilizando **Docker Compose**, lo que levanta tanto la instancia local de CertStream como el servicio de Phishing Catcher.

Para iniciar el escenario completo:

```sh
docker-compose up -d --build
```

Esto iniciará:
1.  **certstream**: Un servidor local de CertStream escuchando en el puerto 8080.
2.  **phishing_catcher**: El script de detección de phishing configurado para conectarse al servicio `certstream` local.

### Ver logs

Para ver la salida de la detección de phishing:

```sh
docker-compose logs -f phishing_catcher
```

## Configuración

Phishing Catcher utiliza un archivo de configuración YAML simple para asignar una puntuación numérica a cadenas que se pueden encontrar en el nombre común (CN) o en el campo SAN de un certificado TLS.

El archivo de configuración principal es [`suspicious.yaml`](suspicious.yaml), que viene con valores predeterminados razonables. Puedes ajustar o añadir cadenas y puntuaciones editando el archivo de anulación [`external.yaml`](external.yaml).

Ambos archivos contienen dos diccionarios YAML: `keywords` (palabras clave) y `tlds` (dominios de nivel superior).

Ejemplo:

```yaml
keywords:
    'login': 25
```

En este ejemplo, se añade una puntuación de `25` si la palabra clave `login` se encuentra en el nombre de dominio.

### Umbrales de Puntuación

Para ser reportado como sospechoso, la puntuación debe cumplir con los siguientes umbrales:

| Puntuación | Reportado como |
| ---------: | -------------- |
|         65 | `Potential`    |
|         80 | `Likely`       |
|         90 | `Suspicious`   |

> :bulb: Consulta la función `score_domain()` en el código fuente para más detalles sobre el algoritmo de puntuación.

## Instalación Manual (Sin Docker)

Si prefieres ejecutar el script manualmente (asegúrate de tener acceso a una instancia de CertStream):

El script funciona con Python 2 o Python 3. Instala los requisitos:

```sh
pip install -r requirements.txt
```

Y ejecuta el script:

```sh
./catch_phishing.py
```

*Nota: Por defecto intentará conectarse a `wss://certstream:8080`. Puedes cambiar esto con la variable de entorno `CERTSTREAM_URL`.*

## Licencia

GNU GPLv3

Si esta herramienta te ha sido útil, siéntete libre de agradecer al autor original (x0rz).

[![Coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoff.ee/x0rz)


---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
