# Detección de Phishing con CertStream

Este escenario simula un entorno de monitorización de **Certificate Transparency (CT)** para detectar dominios sospechosos de phishing en tiempo real.

Utiliza **CertStream** para agregar logs de CT y una herramienta personalizada (`phishing_catcher`) para analizar el flujo de certificados y puntuar dominios basándose en palabras clave sospechosas.

## Componentes

El escenario se compone de dos servicios Docker:

1.  **`certstream`**: Un servidor local de CertStream (escrito en Go) que actúa como agregador de logs. En un entorno real, esto se conectaría a múltiples logs de CT públicos. Aquí simula el stream de datos.
2.  **`phishing_catcher`**: Un cliente en Python que se conecta al WebSocket de `certstream`, recibe los metadatos de los certificados emitidos y analiza los nombres de dominio buscando patrones de phishing (ej. "paypal-login", "secure-bank", etc.).

## Instrucciones de Uso

### 1. Iniciar el Escenario
```bash
docker-compose up -d --build
```

### 2. Observar la Detección
El contenedor `phishing_catcher` analizará el tráfico y mostrará en sus logs los dominios que superen el umbral de sospecha.

Para ver la detección en tiempo real:
```bash
docker-compose logs -f phishing_catcher
```

### 3. Configuración
Puedes ajustar las palabras clave y puntuaciones en el directorio `phishing_catcher/`, editando los archivos `suspicious.yaml` o `external.yaml`.

Para más detalles sobre la lógica de detección, consulta el [README de phishing_catcher](./phishing_catcher/README.md).

---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
