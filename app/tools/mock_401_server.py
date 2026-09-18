"""Servidor local de demostración: responde 401 a GET /incidencias.

Ejecutar desde app/: python tools/mock_401_server.py
El emulador accede mediante http://10.0.2.2:4010.
"""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class UnauthorizedHandler(BaseHTTPRequestHandler):
    requests = 0

    def do_GET(self):
        type(self).requests += 1
        has_token = self.headers.get("Authorization", "").startswith("Bearer ")
        print(
            f"Solicitud #{self.requests}: {self.path} | "
            f"Authorization presente: {has_token} | respuesta: 401",
            flush=True,
        )
        body = b'{"message":"Unauthorized"}'
        self.send_response(401)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 4010), UnauthorizedHandler)
    print("Mock HTTP 401 escuchando en puerto 4010. Ctrl+C para detener.", flush=True)
    server.serve_forever()
