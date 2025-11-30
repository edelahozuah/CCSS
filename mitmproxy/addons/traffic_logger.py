"""
Traffic Logger Addon for Mitmproxy
===================================

Este addon registra todo el tráfico HTTP/HTTPS que pasa por mitmproxy
en un formato estructurado para análisis posterior.

Características:
- Logging detallado de requests y responses
- Extracción de headers importantes
- Identificación de protocolo (HTTP/HTTPS)
- Guardado en formato JSON estructurado
- Timestamps precisos

Uso:
    mitmweb -s traffic_logger.py

Autor: Escenario didáctico CCSS
"""

import json
import logging
from datetime import datetime
from pathlib import Path
from mitmproxy import http, ctx


class TrafficLogger:
    """Addon para logging detallado de tráfico HTTP/HTTPS"""
    
    def __init__(self):
        self.log_file = None
        self.request_count = 0
        
    def load(self, loader):
        """Configuración inicial del addon"""
        # Directorio de logs
        log_dir = Path.home() / ".mitmproxy" / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        # Archivo de log con timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = log_dir / f"traffic_{timestamp}.jsonl"
        
        ctx.log.info(f"Traffic Logger initialized. Logging to: {self.log_file}")
    
    def request(self, flow: http.HTTPFlow):
        """Intercepta y registra cada request"""
        self.request_count += 1
        
        # Extraer información del request
        request_data = {
            "id": self.request_count,
            "timestamp": datetime.now().isoformat(),
            "type": "request",
            "method": flow.request.method,
            "scheme": flow.request.scheme,
            "host": flow.request.host,
            "port": flow.request.port,
            "path": flow.request.path,
            "url": flow.request.pretty_url,
            "http_version": flow.request.http_version,
            "headers": dict(flow.request.headers),
            "content_length": len(flow.request.content) if flow.request.content else 0,
            "content_type": flow.request.headers.get("content-type", ""),
        }
        
        # Si hay contenido y es texto, incluirlo
        if flow.request.content and self._is_text_content(request_data["content_type"]):
            try:
                request_data["body_preview"] = flow.request.text[:500]  # Primeros 500 chars
            except:
                request_data["body_preview"] = "<binary data>"
        
        # Detectar credenciales en claro
        if self._contains_credentials(flow.request):
            request_data["alert"] = "Possible credentials in plaintext"
            ctx.log.warn(f"⚠️  Credentials detected in {flow.request.pretty_url}")
        
        # Guardar en archivo
        self._write_log(request_data)
        
    def response(self, flow: http.HTTPFlow):
        """Intercepta y registra cada response"""
        
        # Extraer información del response
        response_data = {
            "id": self.request_count,
            "timestamp": datetime.now().isoformat(),
            "type": "response",
            "url": flow.request.pretty_url,
            "status_code": flow.response.status_code,
            "reason": flow.response.reason,
            "http_version": flow.response.http_version,
            "headers": dict(flow.response.headers),
            "content_length": len(flow.response.content) if flow.response.content else 0,
            "content_type": flow.response.headers.get("content-type", ""),
        }
        
        # Si hay contenido y es texto, incluir preview
        if flow.response.content and self._is_text_content(response_data["content_type"]):
            try:
                response_data["body_preview"] = flow.response.text[:500]
            except:
                response_data["body_preview"] = "<binary data>"
        
        # Información de timing
        if flow.response.timestamp_end and flow.request.timestamp_start:
            duration = flow.response.timestamp_end - flow.request.timestamp_start
            response_data["duration_ms"] = round(duration * 1000, 2)
        
        # Guardar en archivo
        self._write_log(response_data)
    
    def _write_log(self, data: dict):
        """Escribe una línea de log en formato JSON Lines"""
        try:
            with open(self.log_file, 'a', encoding='utf-8') as f:
                f.write(json.dumps(data, ensure_ascii=False) + '\n')
        except Exception as e:
            ctx.log.error(f"Error writing to log file: {e}")
    
    def _is_text_content(self, content_type: str) -> bool:
        """Determina si el content-type es texto"""
        text_types = [
            'text/', 'application/json', 'application/xml',
            'application/javascript', 'application/x-www-form-urlencoded'
        ]
        return any(t in content_type.lower() for t in text_types)
    
    def _contains_credentials(self, request: http.Request) -> bool:
        """Detecta posibles credenciales en el request"""
        # Buscar en URL
        url_lower = request.pretty_url.lower()
        if any(keyword in url_lower for keyword in ['password', 'passwd', 'pwd', 'token', 'api_key', 'apikey']):
            return True
        
        # Buscar en headers (Authorization básica)
        auth_header = request.headers.get('authorization', '')
        if auth_header.lower().startswith('basic'):
            return True
        
        # Buscar en body si es form data
        if request.text and 'password' in request.text.lower():
            return True
        
        return False


# Registrar el addon
addons = [TrafficLogger()]
