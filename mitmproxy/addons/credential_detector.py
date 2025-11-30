"""
Credential Detector Addon for Mitmproxy
========================================

Este addon educativo detecta y alerta sobre credenciales enviadas en claro,
útil para ejercicios de seguridad y concienciación sobre riesgos.

Detecta:
- Autenticación HTTP Basic
- Passwords en URLs
- Passwords en formularios (POST data)
- API keys y tokens en headers o URLs
- Credenciales en cookies

Uso:
    mitmweb -s credential_detector.py

⚠️  NOTA: Solo para fines educativos. No usar en tráfico de producción.

Autor: Escenario didáctico CCSS
"""

import re
import base64
from datetime import datetime
from pathlib import Path
from mitmproxy import http, ctx


class CredentialDetector:
    """Addon para detectar credenciales en tráfico no cifrado"""
    
    def __init__(self):
        self.alerts_file = None
        self.alert_count = 0
        
        # Patrones de búsqueda
        self.password_patterns = [
            r'password["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
            r'passwd["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
            r'pwd["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
        ]
        
        self.token_patterns = [
            r'api[_-]?key["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
            r'token["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
            r'access[_-]?token["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
            r'auth[_-]?token["\']?\s*[:=]\s*["\']?([^"\'&\s]+)',
        ]
        
    def load(self, loader):
        """Configuración inicial del addon"""
        # Directorio para alertas
        alerts_dir = Path.home() / ".mitmproxy" / "alerts"
        alerts_dir.mkdir(parents=True, exist_ok=True)
        
        # Archivo de alertas con timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.alerts_file = alerts_dir / f"credentials_{timestamp}.txt"
        
        ctx.log.info(f"Credential Detector initialized. Alerts will be saved to: {self.alerts_file}")
        
        # Escribir header en el archivo
        self._write_alert("=" * 80)
        self._write_alert("CREDENTIAL DETECTION LOG")
        self._write_alert("Educational purpose only - CCSS Cybersecurity Course")
        self._write_alert(f"Started: {datetime.now().isoformat()}")
        self._write_alert("=" * 80)
        self._write_alert("")
    
    def request(self, flow: http.HTTPFlow):
        """Analiza cada request en busca de credenciales"""
        
        # 1. Detectar HTTP Basic Authentication
        if self._check_basic_auth(flow):
            return
        
        # 2. Detectar credenciales en URL
        if self._check_url_credentials(flow):
            return
        
        # 3. Detectar credenciales en POST data
        if flow.request.method == "POST":
            self._check_post_credentials(flow)
        
        # 4. Detectar tokens/API keys en headers
        self._check_header_credentials(flow)
        
        # 5. Detectar credenciales en cookies
        self._check_cookie_credentials(flow)
    
    def _check_basic_auth(self, flow: http.HTTPFlow) -> bool:
        """Detecta autenticación HTTP Basic"""
        auth_header = flow.request.headers.get('authorization', '')
        
        if auth_header.lower().startswith('basic '):
            # Decodificar credenciales
            try:
                encoded = auth_header[6:]  # Remove 'Basic '
                decoded = base64.b64decode(encoded).decode('utf-8')
                username, password = decoded.split(':', 1)
                
                self.alert_count += 1
                alert_msg = f"""
[ALERT #{self.alert_count}] HTTP BASIC AUTHENTICATION DETECTED
Time: {datetime.now().isoformat()}
URL: {flow.request.pretty_url}
Scheme: {flow.request.scheme.upper()}
Username: {username}
Password: {'*' * len(password)} ({len(password)} chars)
⚠️  Risk: {'HIGH - Unencrypted HTTP' if flow.request.scheme == 'http' else 'MEDIUM - Encrypted HTTPS'}
"""
                self._write_alert(alert_msg)
                
                # Log to mitmproxy console
                risk = "🔴 HIGH RISK" if flow.request.scheme == 'http' else "🟡 MEDIUM RISK"
                ctx.log.warn(f"{risk} - Basic Auth detected: {flow.request.pretty_url}")
                
                return True
                
            except Exception as e:
                ctx.log.error(f"Error decoding Basic Auth: {e}")
        
        return False
    
    def _check_url_credentials(self, flow: http.HTTPFlow) -> bool:
        """Detecta credenciales en la URL"""
        url = flow.request.pretty_url.lower()
        found = False
        
        # Buscar passwords en URL
        for pattern in self.password_patterns:
            matches = re.findall(pattern, url, re.IGNORECASE)
            if matches:
                self.alert_count += 1
                alert_msg = f"""
[ALERT #{self.alert_count}] PASSWORD IN URL DETECTED
Time: {datetime.now().isoformat()}
URL: {flow.request.pretty_url}
Scheme: {flow.request.scheme.upper()}
Pattern: {pattern}
⚠️  Risk: {'CRITICAL - Password in HTTP URL' if flow.request.scheme == 'http' else 'HIGH - Password in URL'}
"""
                self._write_alert(alert_msg)
                ctx.log.error(f"🔴 CRITICAL - Password in URL: {flow.request.host}")
                found = True
        
        return found
    
    def _check_post_credentials(self, flow: http.HTTPFlow):
        """Detecta credenciales en datos POST"""
        try:
            if flow.request.text:
                text = flow.request.text.lower()
                
                # Buscar passwords
                for pattern in self.password_patterns:
                    matches = re.findall(pattern, text, re.IGNORECASE)
                    if matches:
                        self.alert_count += 1
                        alert_msg = f"""
[ALERT #{self.alert_count}] PASSWORD IN POST DATA DETECTED
Time: {datetime.now().isoformat()}
URL: {flow.request.pretty_url}
Method: POST
Scheme: {flow.request.scheme.upper()}
Content-Type: {flow.request.headers.get('content-type', 'unknown')}
⚠️  Risk: {'HIGH - Unencrypted HTTP' if flow.request.scheme == 'http' else 'LOW - Encrypted HTTPS (OK)'}
"""
                        self._write_alert(alert_msg)
                        
                        if flow.request.scheme == 'http':
                            ctx.log.warn(f"🔴 HIGH RISK - Password in unencrypted POST: {flow.request.host}")
                        else:
                            ctx.log.info(f"🟢 Password in POST over HTTPS (secure): {flow.request.host}")
        except:
            pass
    
    def _check_header_credentials(self, flow: http.HTTPFlow):
        """Detecta tokens y API keys en headers"""
        suspicious_headers = ['x-api-key', 'api-key', 'apikey', 'x-auth-token', 'x-access-token']
        
        for header in suspicious_headers:
            if header in [h.lower() for h in flow.request.headers.keys()]:
                value = flow.request.headers.get(header, '')
                
                self.alert_count += 1
                alert_msg = f"""
[ALERT #{self.alert_count}] API KEY/TOKEN IN HEADER DETECTED
Time: {datetime.now().isoformat()}
URL: {flow.request.pretty_url}
Header: {header}
Scheme: {flow.request.scheme.upper()}
Value Length: {len(value)} chars
⚠️  Risk: {'HIGH - Unencrypted HTTP' if flow.request.scheme == 'http' else 'LOW - Encrypted HTTPS (OK)'}
"""
                self._write_alert(alert_msg)
                
                if flow.request.scheme == 'http':
                    ctx.log.warn(f"🟡 API Key/Token over HTTP: {flow.request.host}")
    
    def _check_cookie_credentials(self, flow: http.HTTPFlow):
        """Detecta credenciales en cookies"""
        cookie_header = flow.request.headers.get('cookie', '')
        
        if cookie_header:
            suspicious_cookies = ['password', 'pwd', 'passwd', 'token', 'api_key', 'apikey', 'access_token']
            cookie_lower = cookie_header.lower()
            
            for suspicious in suspicious_cookies:
                if suspicious in cookie_lower:
                    self.alert_count += 1
                    alert_msg = f"""
[ALERT #{self.alert_count}] SUSPICIOUS COOKIE DETECTED
Time: {datetime.now().isoformat()}
URL: {flow.request.pretty_url}
Scheme: {flow.request.scheme.upper()}
Suspicious keyword: {suspicious}
⚠️  Risk: {'HIGH - Unencrypted HTTP' if flow.request.scheme == 'http' else 'LOW - Encrypted HTTPS (OK)'}
"""
                    self._write_alert(alert_msg)
                    
                    if flow.request.scheme == 'http':
                        ctx.log.warn(f"🟡 Suspicious cookie over HTTP: {flow.request.host}")
    
    def _write_alert(self, message: str):
        """Escribe una alerta en el archivo de log"""
        try:
            with open(self.alerts_file, 'a', encoding='utf-8') as f:
                f.write(message + '\n')
        except Exception as e:
            ctx.log.error(f"Error writing alert: {e}")
    
    def done(self):
        """Llamado cuando mitmproxy se cierra"""
        summary = f"""
{'=' * 80}
SUMMARY
Total alerts: {self.alert_count}
Session ended: {datetime.now().isoformat()}
{'=' * 80}
"""
        self._write_alert(summary)
        ctx.log.info(f"Credential Detector session ended. Total alerts: {self.alert_count}")


# Registrar el addon
addons = [CredentialDetector()]
