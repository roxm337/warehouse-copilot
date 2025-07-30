#!/usr/bin/env python3
"""
Simple HTTP server to serve the warehouse management web panel
"""

import http.server
import socketserver
import webbrowser
import os
import sys

def start_web_server(port=3000):
    """Start a simple HTTP server for the web panel"""
    web_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(web_dir)
    
    handler = http.server.SimpleHTTPRequestHandler
    
    class CustomHTTPRequestHandler(handler):
        def end_headers(self):
            # Add CORS headers
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')
            super().end_headers()
    
    try:
        with socketserver.TCPServer(("", port), CustomHTTPRequestHandler) as httpd:
            print(f"🌐 Web Panel Server starting on port {port}")
            print(f"📱 Open your browser and go to: http://localhost:{port}")
            print(f"🏭 Make sure your FastAPI server is running on http://localhost:8000")
            print(f"⏹️  Press Ctrl+C to stop the server")
            print("-" * 60)
            
            # Automatically open browser
            webbrowser.open(f'http://localhost:{port}')
            
            httpd.serve_forever()
            
    except KeyboardInterrupt:
        print("\n🛑 Web server stopped")
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"❌ Port {port} is already in use. Try a different port.")
            print(f"   Usage: python serve.py [port]")
        else:
            print(f"❌ Error starting server: {e}")

if __name__ == "__main__":
    port = 3000
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("❌ Invalid port number. Using default port 3000.")
    
    start_web_server(port)
