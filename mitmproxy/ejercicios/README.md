# Ejercicios Prácticos - Escenario Mitmproxy

Este directorio contiene una serie de ejercicios prácticos para aprender a capturar y analizar tráfico HTTP/HTTPS utilizando mitmproxy.

## 📚 Índice de Ejercicios

### [Ejercicio 0: Primer Contacto - El Error del Certificado](#ejercicio-0-primer-contacto---el-error-del-certificado)
**Dificultad**: ⭐ Muy Básico  
**Duración**: 5-10 minutos

Aprende a:
- Entender por qué se necesita un certificado CA
- Ver el error del navegador antes de instalar el certificado
- Comprender el funcionamiento básico del proxy

### [Ejercicio 1: Captura Básica de Tráfico HTTP](#ejercicio-1-captura-básica-de-tráfico-http)
**Dificultad**: ⭐ Principiante  
**Duración**: 15-20 minutos

Aprende a:
- Iniciar el escenario mitmproxy
- Capturar tráfico HTTP básico
- Visualizar requests y responses en mitmweb
- Identificar headers y contenido

### [Ejercicio 2: Análisis de Tráfico HTTPS](#ejercicio-2-análisis-de-tráfico-https)
**Dificultad**: ⭐⭐ Intermedio  
**Duración**: 20-30 minutos

Aprende a:
- Instalar el certificado CA de mitmproxy
- Interceptar tráfico HTTPS
- Entender la diferencia entre HTTP y HTTPS en la captura
- Analizar certificados SSL/TLS

### [Ejercicio 3: Detección de Credenciales en Claro](#ejercicio-3-detección-de-credenciales-en-claro)
**Dificultad**: ⭐⭐ Intermedio  
**Duración**: 25-35 minutos

Aprende a:
- Usar el addon `credential_detector.py`
- Identificar envío de credenciales por HTTP
- Comparar seguridad HTTP vs HTTPS
- Entender riesgos de autenticación no cifrada

### [Ejercicio 4: Modificación de Tráfico](#ejercicio-4-modificación-de-tráfico)
**Dificultad**: ⭐⭐⭐ Avanzado  
**Duración**: 30-40 minutos

Aprende a:
- Usar el addon `modify_response.py`
- Modificar respuestas HTML en tiempo real
- Inyectar contenido en páginas web
- Entender ataques MITM activos

### [Ejercicio 5: Exportación y Análisis de Flows](#ejercicio-5-exportación-y-análisis-de-flows)
**Dificultad**: ⭐⭐ Intermedio  
**Duración**: 20-30 minutos

Aprende a:
- Exportar flujos capturados en formato HAR
- Analizar archivos HAR
- Usar logs estructurados del addon traffic_logger
- Generar reportes de tráfico

---

## Ejercicio 0: Primer Contacto - El Error del Certificado

### Objetivos de Aprendizaje
- Entender **por qué** se necesita instalar un certificado CA
- Ver el error de seguridad que muestra el navegador
- Comprender que mitmproxy actúa como intermediario (Man-In-The-Middle)

### Requisitos Previos
- Escenario mitmproxy instalado (ver README.md)
- Ningún certificado instalado aún

### Contexto
Cuando mitmproxy intercepta tráfico HTTPS, actúa como un "hombre en el medio" (MITM). Para hacer esto, genera certificados SSL/TLS "falsos" para cada sitio que visitas. Firefox detecta que estos certificados no son emitidos por una autoridad de certificación conocida y muestra un error de seguridad. Este es el comportamiento correcto y esperado para protegerte.

### Pasos

#### 1. Iniciar el escenario
```bash
./scripts/start.sh
```

#### 2. Acceder a Firefox
1. Abre en tu navegador: http://localhost:5800
2. Espera a que Firefox cargue completamente

#### 3. Intentar acceder a un sitio HTTPS (SIN certificado instalado)
En el Firefox del contenedor, navega a cualquier sitio HTTPS, por ejemplo:
- https://example.com
- https://www.google.com
- https://github.com

#### 4. Observar el error de certificado

Deberías ver una **advertencia de seguridad** similar a:

```
⚠️ Advertencia: Riesgo potencial de seguridad a continuación

Firefox detectó una posible amenaza de seguridad y no continuó a example.com
porque este sitio web requiere una conexión segura.

¿Qué puede hacer al respecto?

example.com tiene una política de seguridad denominada HTTP Strict Transport 
Security (HSTS), lo cual significa que Firefox solo puede conectarse a él de 
forma segura. No puede añadir una excepción para visitar este sitio.

El problema probablemente esté en el sitio web y no hay nada que pueda hacer 
para solucionarlo.
```

O:

```
⚠️ Su conexión no es privada

Los atacantes podrían estar intentando robar su información de example.com
(por ejemplo, contraseñas, mensajes o tarjetas de crédito).

NET::ERR_CERT_AUTHORITY_INVALID
```

#### 5. Examinar los detalles del certificado

1. Click en "Avanzado" o "Advanced"
2. Observa el mensaje que indica que el certificado no es de confianza
3. **NO hagas click en "Aceptar el riesgo" todavía**

#### 6. Ver el certificado en mitmweb

1. Abre http://localhost:8081 en tu navegador host
2. Introduce la contraseña: `mitm1234`
3. Observa que aunque Firefox bloqueó la conexión, mitmweb **sí intentó** interceptar el request inicial

### Preguntas para Reflexionar

1. **¿Por qué aparece este error?**
   - Porque Firefox no confía en los certificados generados por mitmproxy

2. **¿Es esto un problema real o esperado?**
   - Es el comportamiento esperado. Firefox te está protegiendo correctamente.

3. **¿Qué nos dice esto sobre la seguridad HTTPS?**
   - HTTPS protege contra intermediarios no autorizados, incluso si son proxies como mitmproxy.

4. **¿Cómo puede mitmproxy interceptar HTTPS si está cifrado?**
   - Mitmproxy descifra y re-cifra el tráfico, actuando como "hombre en el medio". Por eso necesitamos instalar su certificado CA - para autorizarlo explícitamente.

5. **En un escenario real, ¿deberías aceptar este certificado?**
   - ¡NO! En la vida real, este error indica un posible ataque MITM. Solo en nuestro laboratorio controlado es seguro continuar.

### Lo que has aprendido

✅ HTTPS protege tu conexión contra interceptación  
✅ Los navegadores verifican la autenticidad de los certificados  
✅ Mitmproxy necesita que confíes en su CA para funcionar  
✅ Este es exactamente el error que verías ante un ataque MITM real  

### Próximo Paso

En el **Ejercicio 2**, aprenderás a instalar el certificado CA de mitmproxy para que Firefox confíe en él. Esto te permitirá interceptar tráfico HTTPS con fines educativos y de análisis en tu laboratorio controlado.

> **⚠️ IMPORTANTE**: Solo instala certificados CA en entornos de laboratorio controlados. Nunca instales certificados CA desconocidos en tu navegador personal o de trabajo.

---

## Ejercicio 1: Captura Básica de Tráfico HTTP

### Objetivos de Aprendizaje
- Familiarizarte con la interfaz de mitmweb
- Capturar y analizar tráfico HTTP básico
- Identificar componentes de requests/responses

### Requisitos Previos
- Escenario mitmproxy instalado (ver README.md)
- Navegador web en tu máquina host

### Pasos

#### 1. Iniciar el escenario
```bash
./scripts/start.sh
```

Verifica que puedes acceder a:
- Firefox: http://localhost:5800
- Mitmweb: http://localhost:8081

#### 2. Acceder a mitmweb
1. Abre en tu navegador: http://localhost:8081
2. Introduce la contraseña: `mitm1234`
3. Familiarízate con la interfaz:
   - Lista de flows a la izquierda
   - Detalles del flow seleccionado a la derecha
   - Pestañas: Request, Response, Detail

#### 3. Generar tráfico HTTP
1. Abre Firefox en http://localhost:5800
2. Navega a sitios HTTP (no HTTPS):
   - http://example.com
   - http://neverssl.com (útil para pruebas)
   - http://info.cern.ch (primer sitio web de la historia)

#### 4. Analizar el tráfico capturado
En mitmweb, selecciona un flow y examina:

**Request:**
- Método HTTP (GET, POST, etc.)
- URL completa
- Headers (Host, User-Agent, Accept, etc.)
- Query parameters (si los hay)

**Response:**
- Status code (200, 404, etc.)
- Headers (Content-Type, Server, etc.)
- Body/contenido de la respuesta

### Preguntas para Reflexionar
1. ¿Qué información puedes ver en los headers del request?
2. ¿Qué revela el header `User-Agent`?
3. ¿Cuál es la diferencia entre los métodos GET y POST?
4. ¿Qué sitios web modernos todavía usan HTTP en lugar de HTTPS?

### Tarea
Captura al menos 5 requests diferentes y documenta:
- URL
- Método HTTP
- Status code de la respuesta
- Content-Type de la respuesta

---

## Ejercicio 2: Análisis de Tráfico HTTPS

### Objetivos de Aprendizaje
- Instalar el certificado CA de mitmproxy
- Interceptar y analizar tráfico HTTPS
- Comprender el proceso de intercepción SSL/TLS

### Requisitos Previos
- Completar Ejercicio 1 correctamente
- Comprender diferencia básica entre HTTP y HTTPS

### Pasos

#### 1. Instalar el Certificado CA en Firefox

**En Firefox del contenedor (http://localhost:5800):**

1. Navega a: http://mitmdump.it/
2. Descarga el certificado para tu sistema (Download mitmproxy-ca-cert.pem)
3. Ve a: `about:preferences#privacy`
4. Scroll down hasta "Certificados" → "Ver certificados"
5. Pestaña "Autoridades"
6. Click en "Importar"
7. Selecciona el archivo descargado
8. Marca: ✅ "Confiar en esta CA para identificar sitios web"
9. Click "OK"

#### 2. Verificar la instalación
1. Navega a https://example.com
2. Deberías poder acceder sin advertencias de certificado
3. En mitmweb, deberías ver el tráfico HTTPS capturado

#### 3. Comparar HTTP vs HTTPS
Navega a ambos:
- http://example.com
- https://example.com

**Observa en mitmweb:**
- El esquema (http vs https)
- El puerto (80 vs 443)
- ¿Puedes ver el contenido en ambos casos?

#### 4. Analizar el handshake SSL/TLS
En mitmweb, selecciona un flow HTTPS y ve a la pestaña "Detail":
- Server certificate
- TLS version
- Cipher suite

### Preguntas para Reflexionar
1. ¿Por qué necesitamos instalar el certificado CA?
2. ¿Qué pasaría sin el certificado instalado?
3. ¿Qué información está cifrada en HTTPS?
4. ¿Los headers HTTP también están cifrados?

### Tarea
1. Navega a 3 sitios HTTPS populares (Google, GitHub, etc.)
2. Para cada uno, documenta:
   - Versión TLS usada
   - Cipher suite
   - Validez del certificado
   - Headers de seguridad (Strict-Transport-Security, etc.)

---

## Ejercicio 3: Detección de Credenciales en Claro

### Objetivos de Aprendizaje
- Usar addons personalizados de mitmproxy
- Identificar credenciales enviadas sin cifrado
- Entender riesgos de seguridad

### Requisitos Previos
- Ejercicios 1 y 2 completados
- Certificado CA instalado

### Pasos

#### 1. Crear página de login de prueba
Crea el archivo `test-server/login.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Test Login Page</title>
</head>
<body>
    <h1>Formulario de Login de Prueba</h1>
    <form method="POST" action="http://httpbin.org/post">
        <label>Usuario: <input type="text" name="username" value="testuser"></label><br>
        <label>Password: <input type="password" name="password" value="testpass123"></label><br>
        <button type="submit">Login (HTTP - inseguro)</button>
    </form>
    <hr>
    <form method="POST" action="https://httpbin.org/post">
        <label>Usuario: <input type="text" name="username" value="testuser"></label><br>
        <label>Password: <input type="password" name="password" value="testpass123"></label><br>
        <button type="submit">Login (HTTPS - seguro)</button>
    </form>
</body>
</html>
```

#### 2. Iniciar mitmproxy con el addon credential_detector
```bash
# Detener el escenario actual
./scripts/stop.sh

# Iniciar manualmente con el addon
docker-compose up -d mitmproxy firefox
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  --set web_password=mitm1234 \
  -s /home/mitmproxy/.mitmproxy/addons/credential_detector.py
```

#### 3. Generar tráfico con credenciales
1. En Firefox, abre el archivo `login.html` local o sirve con un servidor simple
2. Envía el formulario HTTP (inseguro)
3. Envía el formulario HTTPS (seguro)

#### 4. Revisar las alertas
Las alertas se guardan en:
```bash
docker-compose exec mitmproxy cat /home/mitmproxy/.mitmproxy/alerts/credentials_*.txt
```

### Preguntas para Reflexionar
1. ¿Qué diferencia hay entre enviar credenciales por HTTP vs HTTPS?
2. ¿El addon detecta credenciales en HTTPS? ¿Por qué?
3. ¿Qué otros tipos de información sensible podrían enviarse en claro?
4. ¿Qué mecanismos adicionales protegen las credenciales además de HTTPS?

### Tarea
Modifica el addon `credential_detector.py` para detectar también:
- Números de tarjeta de crédito (patrón básico)
- Direcciones de email en headers

---

## Ejercicio 4: Modificación de Tráfico

### Objetivos de Aprendizaje
- Modificar respuestas HTTP en tiempo real
- Comprender ataques MITM activos
- Inyectar contenido en páginas web

### Requisitos Previos
- Ejercicios anteriores completados
- Conocimientos básicos de HTML

### Pasos

#### 1. Iniciar con el addon modify_response
```bash
./scripts/stop.sh
docker-compose up -d
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  --set web_password=mitm1234 \
  -s /home/mitmproxy/.mitmproxy/addons/modify_response.py
```

#### 2. Navegar y observar modificaciones
1. En Firefox, navega a sitios HTTP o HTTPS
2. Observa el banner inyectado en la parte superior
3. En mitmweb, observa los logs de modificación

#### 3. Examinar el código del addon
Abre `addons/modify_response.py` y estudia:
- Cómo se detecta el tipo de contenido
- Cómo se modifica el HTML
- Qué headers se añaden/eliminan

#### 4. Experimentar con modificaciones
Edita `modify_response.py` para:
- Cambiar el color del banner
- Inyectar un script JavaScript
- Modificar el texto de la página

### ⚠️ Advertencia Ética
Este ejercicio es **solo con fines educativos**. La modificación de tráfico de terceros sin autorización es ilegal y no ético.

### Preguntas para Reflexionar
1. ¿Qué tipo de ataques podrían realizarse modificando tráfico?
2. ¿HTTPS previene completamente este tipo de ataques?
3. ¿Qué headers de seguridad ayudan a prevenir modificaciones?
4. ¿Cómo podría un usuario detectar que su tráfico está siendo modificado?

### Tarea
Implementa una modificación que:
1. Solo afecte a un dominio específico
2. Reemplace todas las imágenes por una imagen de advertencia
3. Registre las modificaciones en un log

---

## Ejercicio 5: Exportación y Análisis de Flows

### Objetivos de Aprendizaje
- Exportar flujos en diferentes formatos
- Analizar archivos HAR
- Generar reportes de tráfico

### Requisitos Previos
- Ejercicios anteriores completados
- Tráfico capturado disponible

### Pasos

#### 1. Generar tráfico variado
Navega a diferentes sitios para capturar tráfico diverso:
- Sitios con muchos recursos (imágenes, CSS, JS)
- APIs REST
- Formularios

#### 2. Exportar en formato HAR
```bash
./scripts/export-flows.sh --format har --output ./captures
```

#### 3. Analizar el archivo HAR
Los archivos HAR son JSON. Puedes:
- Abrirlos en un editor
- Importarlos en herramientas como HAR Viewer
- Analizarlos programáticamente

Ejemplo de análisis con Python:
```python
import json

with open('captures/flows_XXXXXX.har', 'r') as f:
    har = json.load(f)

# Analizar el tráfico
for entry in har['log']['entries']:
    request = entry['request']
    response = entry['response']
    print(f"{request['method']} {request['url']} -> {response['status']}")
```

#### 4. Usar el addon traffic_logger
Inicia mitmproxy con el logger:
```bash
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  --set web_password=mitm1234 \
  -s /home/mitmproxy/.mitmproxy/addons/traffic_logger.py
```

Los logs se guardan en formato JSON Lines:
```bash
docker-compose exec mitmproxy cat /home/mitmproxy/.mitmproxy/logs/traffic_*.jsonl
```

#### 5. Generar estadísticas
Crea un script para analizar los logs:
- Total de requests
- Distribución de status codes
- Tipos de contenido más comunes
- Dominios más visitados

### Tarea Final
Crea un script que:
1. Lea los logs de traffic_logger
2. Genere un reporte HTML con:
   - Total de requests/responses
   - Gráfico de status codes
   - Top 10 dominios visitados
   - Timeline de requests
   - Alertas de seguridad (credenciales, HTTP en lugar de HTTPS)

---

## 📂 Soluciones

Las soluciones y scripts de ayuda están disponibles en el directorio `soluciones/`.

## 💡 Recursos Adicionales

- [Documentación oficial de mitmproxy](https://docs.mitmproxy.org/)
- [Tutorial de Addons](https://docs.mitmproxy.org/stable/addons-overview/)
- [Formato HAR](http://www.softwareishard.com/blog/har-12-spec/)
- [HTTP en profundidad](https://developer.mozilla.org/es/docs/Web/HTTP)

## 🆘 ¿Problemas?

Si encuentras problemas, consulta la sección Troubleshooting del README principal o revisa los logs:
```bash
docker-compose logs -f
```

---

**¡Buena suerte con los ejercicios!** 🚀


---
*Nota: Para la elaboración de este contenido se han utilizado herramientas de IA, con un nivel 3, de acuerdo con la escala [AI Assessment Scale](https://aiassessmentscale.com/).*
