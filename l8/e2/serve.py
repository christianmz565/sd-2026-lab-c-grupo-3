#!/usr/bin/env python3
"""Servidor HTTP simple para ejecutar el simulador front-end del Ejercicio 2.

Uso:
    python src/e2/serve.py
"""
import http.server
import socketserver
import webbrowser
import os
import sys
from pathlib import Path

PORT = 8080
FRONT_DIR = Path(__file__).resolve().parent / "front"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(FRONT_DIR), **kwargs)

def main():
    if not FRONT_DIR.exists():
        print(f"Error: La carpeta front no existe en {FRONT_DIR}")
        return 1

    os.chdir(str(FRONT_DIR))
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        url = f"http://localhost:{PORT}/index.html"
        print("====================================================")
        print("  BNC - Simulador de Transacciones Distribuidas (2PC) ")
        print("====================================================")
        print(f"Servidor iniciado en: {url}")
        print("Presiona Ctrl+C para detener el servidor.")
        print("====================================================")
        
        # Intentar abrir el navegador automáticamente
        try:
            webbrowser.open(url)
        except Exception:
            pass
            
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServidor detenido. ¡Hasta luego!")
            
    return 0

if __name__ == "__main__":
    sys.exit(main())
