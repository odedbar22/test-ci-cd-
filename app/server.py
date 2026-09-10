import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

VERSION = os.environ.get("APP_VERSION", "0.1.0")
PORT = int(os.environ.get("PORT", "8080"))


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            body = f"<h1>CI/CD Lab</h1><p>Version: {VERSION}</p>".encode()
            content_type = "text/html; charset=utf-8"
            status = 200
        elif self.path == "/health":
            body = json.dumps({"status": "ok", "version": VERSION}).encode()
            content_type = "application/json"
            status = 200
        else:
            body = b"Not found\n"
            content_type = "text/plain"
            status = 404

        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


print(f"Starting version={VERSION} port={PORT}", flush=True)
ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
