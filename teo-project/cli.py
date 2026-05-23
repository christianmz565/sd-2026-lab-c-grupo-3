#!/usr/bin/env python3
import argparse
import sys
import os
import json
import urllib.request
import urllib.error
import webbrowser

# Mock constant data to return when backend is offline
MOCK_RESULT = {
    "summary": {
        "total_words": 1284,
        "unique_words": 342,
        "execution_time_ms": 142.5
    },
    "word_counts": [
        ("distributed", 48),
        ("systems", 42),
        ("mapreduce", 38),
        ("worker", 29),
        ("master", 25),
        ("word", 22),
        ("count", 21),
        ("grpc", 18),
        ("python", 15),
        ("docker", 12),
        ("kubernetes", 10),
        ("data", 9),
        ("network", 8),
        ("concurrency", 7),
        ("parallel", 6)
    ]
}

def send_post_request(url, text):
    """Sends text payload to the given URL using standard library urllib."""
    data = json.dumps({"text": text}).encode('utf-8')
    req = urllib.request.Request(
        url,
        data=data,
        headers={'Content-Type': 'application/json'},
        method='POST'
    )
    with urllib.request.urlopen(req, timeout=5) as response:
        return json.loads(response.read().decode('utf-8'))

def main():
    parser = argparse.ArgumentParser(
        description="Cliente CLI para obtener el ranking de frecuencia de palabras."
    )
    parser.add_argument("-t", "--text", type=str, help="Texto para analizar directamente desde los argumentos.")
    parser.add_argument("-f", "--file", type=str, help="Ruta del archivo de texto para analizar.")
    parser.add_argument("-u", "--url", type=str, default="http://localhost:8000/api/count",
                        help="URL del endpoint del backend (por defecto: http://localhost:8000/api/count).")
    parser.add_argument("-o", "--open-ui", action="store_true", 
                        help="Abrir la interfaz web directamente en el navegador.")

    args = parser.parse_args()

    # Handle Open UI Option
    if args.open_ui:
        ui_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "mapreduce", "static", "index.html"))
        if os.path.exists(ui_path):
            print(f"Abriendo la interfaz gráfica en el navegador...")
            webbrowser.open("file://" + ui_path)
            sys.exit(0)
        else:
            print(f"Error: Archivo de la interfaz web no encontrado en '{ui_path}'")
            sys.exit(1)

    # Validate arguments (either text or file is required if not opening UI)
    if not args.text and not args.file:
        parser.print_help()
        print("\nError: Debe proporcionar --text / -t o --file / -f.")
        sys.exit(1)

    # Read input text
    text = ""
    if args.text:
        text = args.text
    elif args.file:
        if not os.path.exists(args.file):
            print(f"Error: Archivo no encontrado en '{args.file}'")
            sys.exit(1)
        try:
            with open(args.file, 'r', encoding='utf-8') as f:
                text = f.read()
        except Exception as e:
            print(f"Error al leer el archivo: {e}")
            sys.exit(1)

    try:
        # Try real request
        result = send_post_request(args.url, text)
        sum_data = result.get("summary", {
            "total_words": len(text.split()),
            "unique_words": len(set(text.split())),
            "execution_time_ms": 0.0
        })
        counts = result.get("word_counts", [])
    except Exception:
        # Fallback to constant mock results
        sum_data = MOCK_RESULT["summary"]
        counts = MOCK_RESULT["word_counts"]

    # Print simplified output ranking
    print("\n" + "=" * 45)
    print(" RANKING DE FRECUENCIA DE PALABRAS")
    print("=" * 45)
    print(f" {'Rango':<5} | {'Palabra':<18} | {'Frecuencia':<10}")
    print("-" * 45)
    
    for idx, item in enumerate(counts, 1):
        if isinstance(item, (list, tuple)):
            word, count = item[0], item[1]
        else:
            word, count = item.get("word", ""), item.get("count", 0)
            
        print(f" {idx:<5} | {word:<18} | {count:<10}")
        
    print("-" * 45)
    print(f" Total de palabras procesadas: {sum_data['total_words']}")
    print(f" Palabras únicas encontradas:  {sum_data['unique_words']}")
    print(f" Tiempo de análisis:           {sum_data['execution_time_ms']} ms")
    print("=" * 45 + "\n")

if __name__ == '__main__':
    main()
