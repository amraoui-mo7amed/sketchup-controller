"""
Mock Bridge Server for testing Desktop UI & MCP when SketchUp is closed.
Simulates SketchUp 2026 responses on http://127.0.0.1:9876
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class MockSketchUpHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(204)

    def do_GET(self):
        if self.path == '/api/status':
            self._set_headers(200)
            data = {
                "status": "online",
                "app_version": "26.0.485 (Mock)",
                "model_name": "Loft Apartment (Simulation)",
                "units": "Meters",
                "counts": {
                    "entities": 142,
                    "faces": 48,
                    "edges": 94,
                    "groups": 6,
                    "components": 4,
                    "scenes": 3,
                    "layers": 5
                },
                "bounds": {
                    "width_m": 12.5,
                    "depth_m": 8.4,
                    "height_m": 3.2
                }
            }
            self.wfile.write(json.dumps(data).encode('utf-8'))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"status": "not_found"}).encode('utf-8'))

    def do_POST(self):
        content_len = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_len)
        try:
            payload = json.loads(body.decode('utf-8'))
        except Exception:
            payload = {}

        self._set_headers(200)
        resp = {"status": "success", "executed": self.path, "params": payload}
        self.wfile.write(json.dumps(resp).encode('utf-8'))

def run():
    server = HTTPServer(('127.0.0.1', 9876), MockSketchUpHandler)
    print("✓ Mock SketchUp Bridge running on http://127.0.0.1:9876")
    print("Press Ctrl+C to stop.")
    server.serve_forever()

if __name__ == '__main__':
    run()
