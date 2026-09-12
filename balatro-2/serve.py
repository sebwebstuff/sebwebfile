#!/usr/bin/env python3
import http.server
import socketserver
import os
import mimetypes
import sys

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Set required headers for SharedArrayBuffer support
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cross-Origin-Resource-Policy', 'cross-origin')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

PORT = 8080

# Try to find an available port if 8080 is in use
while PORT < 8090:
    try:
        with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
            print(f"Balatro web server running at: http://127.0.0.1:{PORT}/Balatro/")
            print(f"Press Ctrl+C to stop the server")
            httpd.serve_forever()
        break
    except OSError as e:
        if e.errno == 10048 or "address already in use" in str(e).lower():
            print(f"Port {PORT} is already in use, trying {PORT + 1}...")
            PORT += 1
        else:
            print(f"Error starting server: {e}")
            sys.exit(1)
else:
    print("Could not find an available port between 8080-8089")
    sys.exit(1)