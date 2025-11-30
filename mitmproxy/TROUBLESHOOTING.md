# Notas de Troubleshooting

## Problema Resuelto: Healthcheck del Contenedor

### Síntoma
Al ejecutar `docker-compose up -d`, el contenedor `mitmproxy` aparece como "unhealthy" y Firefox no arranca con el error:
```
dependency failed to start: container mitmproxy is unhealthy
```

### Causa
La imagen oficial de mitmproxy no incluye ni `curl` ni `wget`, herramientas comúnmente usadas para healthchecks HTTP.

### Solución Aplicada
Se removió el healthcheck del servicio `mitmproxy` en `docker-compose.yml` y se simplificó la dependencia de Firefox para que use un `depends_on` simple sin condición de salud:

```yaml
# Antes (no funciona)
mitmproxy:
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8081"]
    # o
    test: ["CMD", "wget", "--spider", "-q", "http://localhost:8081"]

firefox:
  depends_on:
    mitmproxy:
      condition: service_healthy  # Esto falla

# Ahora (funciona)
mitmproxy:
  # Sin healthcheck
  
firefox:
  depends_on:
    - mitmproxy  # Dependencia simple
```

### Alternativa Futura
Si en el futuro se desea un healthcheck, se podría:
1. Crear una imagen personalizada que extienda `mitmproxy/mitmproxy:latest` e instale `curl`
2. Usar un script Python que verifique el puerto 8081
3. Compilar `wget` estáticamente y copiarlo al contenedor

Para el propósito educativo actual, la dependencia simple es suficiente ya que mitmproxy arranca rápidamente.

---

## Verificación de Funcionamiento

Después del fix, verificar que ambos servicios responden:

```bash
# Comprobar estado
docker-compose ps

# Verificar mitmweb
curl -I http://localhost:8081
# Debe responder (incluso con 405 Method Not Allowed es correcto)

# Verificar Firefox VNC
curl -I http://localhost:5800
# Debe responder 200 OK con server: nginx

# Acceder desde navegador
# - Firefox: http://localhost:5800
# - Mitmweb: http://localhost:8081 (password: mitm1234)
```

Todo debe funcionar correctamente.
