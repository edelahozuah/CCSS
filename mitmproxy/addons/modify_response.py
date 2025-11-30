"""
Response Modifier Addon for Mitmproxy
======================================

Este addon educativo demuestra cómo modificar respuestas HTTP en tiempo real.
Útil para entender ataques MITM y para testing de aplicaciones.

Ejemplos incluidos:
- Inyección de banners en páginas HTML
- Modificación de headers
- Redirección de responses
- Modificación de contenido JSON

⚠️  ADVERTENCIA: Solo para fines educativos en entornos de laboratorio.
No usar en tráfico real o de terceros sin autorización explícita.

Uso:
    mitmweb -s modify_response.py

Autor: Escenario didáctico CCSS
"""

from mitmproxy import http, ctx


class ResponseModifier:
    """Addon para modificar respuestas HTTP/HTTPS con fines educativos"""
    
    def __init__(self):
        self.modification_count = 0
        
    def load(self, loader):
        """Configuración inicial del addon"""
        ctx.log.info("Response Modifier addon loaded")
        ctx.log.warn("⚠️  Educational purposes only - modifying traffic!")
        
        # Añadir opciones configurables
        loader.add_option(
            name="modify_html",
            typespec=bool,
            default=True,
            help="Enable HTML content modification"
        )
        loader.add_option(
            name="inject_banner",
            typespec=bool,
            default=True,
            help="Inject educational banner in HTML pages"
        )
        loader.add_option(
            name="modify_headers",
            typespec=bool,
            default=False,
            help="Add custom headers to responses"
        )
    
    def response(self, flow: http.HTTPFlow):
        """Modifica las respuestas HTTP"""
        
        # Solo modificar responses exitosas
        if flow.response is None:
            return
        
        # Obtener content type
        content_type = flow.response.headers.get("content-type", "").lower()
        
        # 1. Modificar páginas HTML
        if ctx.options.modify_html and "text/html" in content_type:
            self._modify_html(flow)
        
        # 2. Modificar responses JSON
        elif "application/json" in content_type:
            self._modify_json(flow)
        
        # 3. Añadir headers personalizados
        if ctx.options.modify_headers:
            self._add_custom_headers(flow)
    
    def _modify_html(self, flow: http.HTTPFlow):
        """Modifica contenido HTML"""
        try:
            html = flow.response.text
            
            if not html:
                return
            
            # Banner educativo para inyectar
            if ctx.options.inject_banner:
                banner = """
                <div style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    right: 0;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 15px;
                    text-align: center;
                    font-family: Arial, sans-serif;
                    z-index: 999999;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.3);
                    border-bottom: 3px solid #f59e0b;
                ">
                    <strong>⚠️ AVISO EDUCATIVO</strong> | 
                    Esta página ha sido modificada por mitmproxy | 
                    Escenario didáctico CCSS |
                    <small style="opacity: 0.8;">URL: """ + flow.request.pretty_url + """</small>
                </div>
                <div style="height: 60px;"></div>
                """
                
                # Inyectar después del <body> tag
                if "<body" in html:
                    html = html.replace("<body>", f"<body>{banner}", 1)
                    # Si tiene atributos
                    import re
                    html = re.sub(r'(<body[^>]*>)', rf'\1{banner}', html, count=1)
                else:
                    # Si no hay body tag, inyectar al principio
                    html = banner + html
                
                flow.response.text = html
                self.modification_count += 1
                
                ctx.log.info(f"✏️  Modified HTML page: {flow.request.host}{flow.request.path}")
        
        except Exception as e:
            ctx.log.error(f"Error modifying HTML: {e}")
    
    def _modify_json(self, flow: http.HTTPFlow):
        """Ejemplo de modificación de JSON response"""
        try:
            import json
            
            data = json.loads(flow.response.text)
            
            # Añadir campo indicando que fue modificado
            if isinstance(data, dict):
                data["_mitmproxy_modified"] = True
                data["_modification_note"] = "This response was modified for educational purposes"
                
                flow.response.text = json.dumps(data, indent=2)
                self.modification_count += 1
                
                ctx.log.info(f"✏️  Modified JSON response: {flow.request.host}{flow.request.path}")
        
        except json.JSONDecodeError:
            pass  # No es JSON válido
        except Exception as e:
            ctx.log.error(f"Error modifying JSON: {e}")
    
    def _add_custom_headers(self, flow: http.HTTPFlow):
        """Añade headers personalizados a las respuestas"""
        # Header educativo
        flow.response.headers["X-Modified-By"] = "mitmproxy-educational-addon"
        flow.response.headers["X-CCSS-Lab"] = "Traffic Analysis Scenario"
        
        # Eliminar algunos headers de seguridad para demostración
        # (en un escenario educativo, para mostrar la importancia de estos headers)
        if "strict-transport-security" in flow.response.headers:
            original_hsts = flow.response.headers["strict-transport-security"]
            ctx.log.warn(f"⚠️  Removed HSTS header (was: {original_hsts})")
            del flow.response.headers["strict-transport-security"]
    
    def done(self):
        """Llamado cuando mitmproxy se cierra"""
        ctx.log.info(f"Response Modifier session ended. Total modifications: {self.modification_count}")


# Ejemplo adicional: Redirección condicional
class ConditionalRedirector:
    """Ejemplo de redirección condicional basada en patrones"""
    
    def __init__(self):
        self.redirect_map = {
            # Ejemplo: redirigir example.com a example.org
            # "example.com": "https://example.org"
        }
    
    def request(self, flow: http.HTTPFlow):
        """Redirige requests que coincidan con ciertos patrones"""
        host = flow.request.host
        
        if host in self.redirect_map:
            target = self.redirect_map[host]
            
            ctx.log.info(f"🔀 Redirecting {host} -> {target}")
            
            # Crear response de redirección
            flow.response = http.Response.make(
                302,  # Status code
                b"",  # Body
                {"Location": target}  # Headers
            )


# Registrar addons
# Comenta/descomenta según los que quieras activar
addons = [
    ResponseModifier(),
    # ConditionalRedirector(),  # Desactivado por defecto
]
