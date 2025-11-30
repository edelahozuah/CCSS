# Soluciones - Ejercicios Mitmproxy

Este directorio contiene scripts de ayuda y soluciones para los ejercicios prácticos.

## 📁 Contenido

### `analyze_har.py`
Script Python para analizar archivos HAR exportados.

**Uso:**
```bash
python3 analyze_har.py ../captures/flows_XXXXXX.har
```

### `analyze_traffic_logs.py`
Script para analizar los logs generados por el addon traffic_logger.

**Uso:**
```bash
# Copiar logs desde el contenedor
docker-compose exec mitmproxy cat /home/mitmproxy/.mitmproxy/logs/traffic_*.jsonl > traffic.jsonl

# Analizar
python3 analyze_traffic_logs.py traffic.jsonl
```

### `generate_report.py`
Genera un reporte HTML completo del tráfico capturado.

**Uso:**
```bash
python3 generate_report.py traffic.jsonl -o report.html
```

### `test_login.html`
Página de login de prueba para el Ejercicio 3.

### `custom_detector.py`
Ejemplo de addon personalizado que detecta patrones adicionales.

---

## 💡 Consejos Generales

### Ejercicio 1: Captura Básica
- Usa `Ctrl+F` en mitmweb para buscar flows específicos
- El filtro `~d example.com` muestra solo tráfico de ese dominio
- `~m POST` filtra por método HTTP

### Ejercicio 2: HTTPS
- Si Firefox se queja del certificado, verifica que lo instalaste correctamente
- Algunos sitios con HSTS pueden requerir limpiar la caché de Firefox
- El certificado CA se regenera si borras `mitmproxy-data/`

### Ejercicio 3: Credenciales
- El addon credential_detector es solo educativo
- En producción, usa herramientas profesionales como Burp Suite o OWASP ZAP
- Recuerda: HTTPS cifra el contenido, pero mitmproxy puede descifrarlo porque instalaste su CA

### Ejercicio 4: Modificación
- Ten cuidado al modificar headers de seguridad
- CSP (Content Security Policy) puede bloquear scripts inyectados
- Algunos sitios usan Certificate Pinning que previene MITM incluso con CA instalada

### Ejercicio 5: Exportación
- Los archivos HAR pueden ser muy grandes
- Usa filtros en mitmweb antes de exportar
- Los logs en JSON Lines son más eficientes para análisis programático

---

## 🐍 Instalación de Dependencias Python

Si quieres usar los scripts de análisis:

```bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

---

## ❓ Preguntas Frecuentes

### ¿Cómo reinicio un ejercicio?
```bash
./scripts/clean.sh
./scripts/start.sh
```

### ¿Puedo usar mis propios addons?
Sí, colócalos en el directorio `addons/` y ejecútalos con:
```bash
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  -s /home/mitmproxy/.mitmproxy/addons/tu_addon.py
```

### ¿Cómo exporto los flows guardados en mitmproxy?
Usa el script de exportación o accede directamente:
```bash
# Copiar archivo de flows
docker-compose cp mitmproxy:/home/mitmproxy/.mitmproxy/flows ./flows.mitm

# Convertir a HAR
mitmdump -r flows.mitm --set hardump=flows.har
```

---

## 📚 Recursos Adicionales

- [Documentación de mitmproxy scripting](https://docs.mitmproxy.org/stable/addons-overview/)
- [Ejemplos oficiales de addons](https://github.com/mitmproxy/mitmproxy/tree/main/examples/addons)
- [HAR Specification](http://www.softwareishard.com/blog/har-12-spec/)
- [HTTP/2 en mitmproxy](https://docs.mitmproxy.org/stable/concepts-protocols/#http-2)

---

## 🎓 Evaluación

Para evaluar tu comprensión, intenta completar estos desafíos adicionales:

1. **Desafío 1**: Crea un addon que detecte y registre todos los códigos de error (4xx, 5xx)
2. **Desafío 2**: Modifica el addon traffic_logger para incluir geolocalización basada en IPs
3. **Desafío 3**: Implementa un sistema de replay de requests capturados
4. **Desafío 4**: Crea un dashboard web en tiempo real que muestre estadísticas del tráfico
5. **Desafío 5**: Desarrolla un addon que implemente rate limiting por dominio

---

**¿Dudas?** Consulta el README principal o revisa los logs de mitmproxy.
