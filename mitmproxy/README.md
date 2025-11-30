# Escenario de Captura de Tráfico con Mitmproxy

Este repositorio contiene un escenario completo y listo para usar que permite realizar captura y análisis de tráfico HTTP/HTTPS utilizando **mitmproxy** con un navegador Firefox preconfigurado, todo ejecutándose en contenedores Docker.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Acceso a las Interfaces](#acceso-a-las-interfaces)
- [Instalación del Certificado CA](#instalación-del-certificado-ca)
- [Scripts de Automatización](#scripts-de-automatización)
- [Addons Personalizados](#addons-personalizados)
- [Ejercicios Prácticos](#ejercicios-prácticos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Troubleshooting](#troubleshooting)

## ✨ Características

- 🔍 **Captura de tráfico HTTP/HTTPS** con interfaz web intuitiva (mitmweb)
- 🦊 **Firefox preconfigurado** con proxy automático y acceso vía navegador (noVNC)
- 📦 **Sin instalación** de software adicional (todo en contenedores Docker)
- 💾 **Persistencia** de certificados CA y configuración de Firefox
- 🔧 **Addons personalizados** para logging, detección de credenciales y modificación de tráfico
- 📚 **Ejercicios prácticos** para aprendizaje guiado
- 🚀 **Scripts de automatización** para facilitar el uso

## 📦 Requisitos Previos

- **Docker** (versión 20.10 o superior)
- **Docker Compose** (versión 1.29 o superior)
- Puertos disponibles: `5800`, `8080`, `8081`

### Verificar instalación

```bash
docker --version
docker-compose --version
```

## 🚀 Instalación

### Opción 1: Setup automático (recomendado)

```bash
# Clonar o descargar este repositorio
cd mitmproxy

# Ejecutar script de instalación
chmod +x scripts/*.sh
./scripts/setup.sh
```

### Opción 2: Setup manual

```bash
# Iniciar los contenedores
docker-compose up -d

# Verificar que los contenedores están ejecutándose
docker-compose ps
```

## 🎮 Uso

### Iniciar el escenario

```bash
./scripts/start.sh
```

O manualmente:

```bash
docker-compose up -d
```

### Detener el escenario

```bash
./scripts/stop.sh
```

O manualmente:

```bash
docker-compose down
```

### Limpiar datos capturados

```bash
./scripts/clean.sh
```

## 🌐 Acceso a las Interfaces

Una vez iniciados los contenedores, puedes acceder a:

| Servicio | URL | Descripción | Credenciales |
|----------|-----|-------------|--------------|
| **Firefox (noVNC)** | http://localhost:5800 | Navegador Firefox con interfaz gráfica | - |
| **Mitmweb** | http://localhost:8081 | Interfaz web de mitmproxy para análisis de tráfico | Password: `mitm1234` |

### Flujo de trabajo típico

1. **Acceder a Firefox**: Abre http://localhost:5800 en tu navegador
2. **Navegar**: En el Firefox del contenedor, navega a cualquier sitio web
3. **Analizar**: Abre http://localhost:8081 para ver el tráfico capturado en tiempo real
4. **Exportar**: Usa los scripts o la interfaz de mitmweb para exportar los flujos

## 🔐 Instalación del Certificado CA

Para poder interceptar tráfico HTTPS, es necesario instalar el certificado de autoridad (CA) de mitmproxy en Firefox.

### Método automático (recomendado)

El certificado se descarga automáticamente al iniciar Firefox por primera vez y se encuentra en:
```
firefox-config/downloads/mitmproxy-ca-cert.pem
```

### Instalación manual en Firefox

1. En el Firefox del contenedor (http://localhost:5800):
   - Ve a `about:preferences#privacy`
   - Desplázate hasta "Certificados" → Click en "Ver certificados"
   - Pestaña "Autoridades"
   - Click en "Importar"
   
2. Navega a `/config/downloads/` y selecciona `mitmproxy-ca-cert.pem`

3. Marca las opciones:
   - ✅ Confiar en esta CA para identificar sitios web
   - ✅ Confiar en esta CA para identificar usuarios de correo
   
4. Click en "OK"

### Verificación

Intenta acceder a `https://example.com` en Firefox. Si puedes ver el tráfico HTTPS en mitmweb, el certificado está correctamente instalado.

## 🔧 Scripts de Automatización

| Script | Descripción |
|--------|-------------|
| `scripts/setup.sh` | Instalación y configuración inicial completa |
| `scripts/start.sh` | Inicia el escenario y muestra URLs de acceso |
| `scripts/stop.sh` | Detiene el escenario de forma limpia |
| `scripts/clean.sh` | Limpia datos capturados y reset del escenario |
| `scripts/export-flows.sh` | Exporta flujos capturados en diferentes formatos |

### Ejemplos de uso

```bash
# Exportar flujos capturados como HAR
./scripts/export-flows.sh --format har --output captures/

# Ver logs de mitmproxy
docker-compose logs -f mitmproxy
```

## 🎯 Addons Personalizados

El escenario incluye varios addons de mitmproxy para casos de uso específicos:

### Traffic Logger (`addons/traffic_logger.py`)

Registra todo el tráfico en formato estructurado:

```bash
# Iniciar mitmproxy con el addon
docker-compose exec mitmproxy mitmweb \
  --listen-port 8080 \
  --web-port 8081 \
  --web-host 0.0.0.0 \
  -s /home/mitmproxy/.mitmproxy/addons/traffic_logger.py
```

### Credential Detector (`addons/credential_detector.py`)

Detecta y alerta sobre credenciales enviadas en claro (útil para ejercicios de seguridad).

### Response Modifier (`addons/modify_response.py`)

Ejemplo educativo de cómo modificar respuestas HTTP en tiempo real.

## 📚 Ejercicios Prácticos

El directorio `ejercicios/` contiene una serie de ejercicios guiados:

1. **Ejercicio 1**: Captura básica de tráfico HTTP
2. **Ejercicio 2**: Análisis de tráfico HTTPS
3. **Ejercicio 3**: Detección de credenciales en claro
4. **Ejercicio 4**: Modificación de tráfico con addons
5. **Ejercicio 5**: Exportación y análisis de flows

Consulta [ejercicios/README.md](ejercicios/README.md) para instrucciones detalladas.

## 📁 Estructura del Proyecto

```
mitmproxy/
├── docker-compose.yml          # Configuración de servicios Docker
├── .env.example               # Variables de entorno configurables
├── .gitignore                 # Archivos a ignorar en git
├── README.md                  # Este archivo
├── README_EN.md              # Documentación en inglés
├── scripts/                   # Scripts de automatización
│   ├── setup.sh
│   ├── start.sh
│   ├── stop.sh
│   ├── clean.sh
│   └── export-flows.sh
├── addons/                    # Addons personalizados de mitmproxy
│   ├── traffic_logger.py
│   ├── credential_detector.py
│   └── modify_response.py
├── ejercicios/               # Ejercicios prácticos
│   ├── README.md
│   └── soluciones/
├── mitmproxy-data/           # Certificados CA (persistente)
├── firefox-config/           # Configuración de Firefox (persistente)
└── test-server/             # Servidor web de prueba (opcional)
    ├── index.html
    └── Dockerfile
```

## 🔧 Troubleshooting

### Los contenedores no arrancan

```bash
# Verificar logs
docker-compose logs

# Verificar que los puertos no están en uso
lsof -i :5800
lsof -i :8080
lsof -i :8081
```

### No se captura tráfico HTTPS

- Verifica que el certificado CA está instalado en Firefox (ver sección anterior)
- Algunos sitios con HSTS pueden requerir configuración adicional

### Firefox va lento

Aumenta la memoria compartida en `docker-compose.yml`:

```yaml
shm_size: "4g"  # En lugar de 2g
```

### No puedo acceder a mitmweb

- Verifica que el contenedor está ejecutándose: `docker-compose ps`
- La contraseña por defecto es: `mitm1234`
- Revisa los logs: `docker-compose logs mitmproxy`

### Resetear completamente el escenario

```bash
# Detener y eliminar contenedores, volúmenes y red
docker-compose down -v

# Limpiar directorios de datos
./scripts/clean.sh

# Reiniciar desde cero
./scripts/setup.sh
```

## 🔒 Consideraciones de Seguridad

⚠️ **IMPORTANTE**: Este escenario es para fines educativos y de laboratorio.

- No uses este setup en entornos de producción
- El certificado CA generado debe mantenerse privado
- La contraseña de mitmweb está en el `docker-compose.yml` por simplicidad - cámbiala en entornos compartidos
- No captures tráfico de terceros sin su consentimiento explícito

## 📖 Recursos Adicionales

- [Documentación oficial de mitmproxy](https://docs.mitmproxy.org/)
- [Mitmproxy Addon API](https://docs.mitmproxy.org/stable/addons-overview/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)

## 📝 Licencia

Este material es de uso educativo.

---

**¿Preguntas o problemas?** Consulta la sección de [Troubleshooting](#troubleshooting) o revisa los logs de los contenedores.
