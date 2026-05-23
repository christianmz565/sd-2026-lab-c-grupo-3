#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.request
import webbrowser

DEFAULT_SERVER_URL = "http://localhost:8000"


def send_post_request(url, text):
    data = json.dumps({"text": text}).encode("utf-8")
    req = urllib.request.Request(
        url, data=data, headers={"Content-Type": "application/json"}, method="POST"
    )
    with urllib.request.urlopen(req, timeout=5) as response:
        return json.loads(response.read().decode("utf-8"))


def main():
    parser = argparse.ArgumentParser(
        description="Cliente CLI para obtener el ranking de frecuencia de palabras."
    )
    parser.add_argument(
        "-t",
        "--text",
        type=str,
        help="Texto para analizar directamente desde los argumentos.",
    )
    parser.add_argument(
        "-f", "--file", type=str, help="Ruta del archivo de texto para analizar."
    )
    parser.add_argument(
        "-u",
        "--url",
        type=str,
        default=f"${DEFAULT_SERVER_URL}/api/count",
        help=f"URL del endpoint del backend (por defecto: ${DEFAULT_SERVER_URL}/api/count).",
    )
    parser.add_argument(
        "-o",
        "--open-ui",
        action="store_true",
        help="Abrir la interfaz web directamente en el navegador.",
    )

    args = parser.parse_args()

    if args.open_ui:
        print(
            f"\033[92mAbriendo la interfaz gráfica en el navegador:\033[0m ${DEFAULT_SERVER_URL}"
        )
        webbrowser.open(DEFAULT_SERVER_URL)
        sys.exit(0)

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
            with open(args.file, "r", encoding="utf-8") as f:
                text = f.read()
        except Exception as e:
            print(f"Error al leer el archivo: {e}")
            sys.exit(1)

    # Attempt connection to server
    try:
        result = send_post_request(args.url, text)
        sum_data = result.get("summary", {})
        counts = result.get("word_counts", [])
    except Exception:
        print(f"\033[91mError: El servidor no está disponible en {args.url}\033[0m")
        sys.exit(1)

    # Print output ranking
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
    print(f" Total de palabras procesadas: {sum_data.get('total_words', 0)}")
    print(f" Palabras únicas encontradas:  {sum_data.get('unique_words', 0)}")
    print(f" Tiempo de análisis:           {sum_data.get('execution_time_ms', 0.0)} ms")
    print("=" * 45 + "\n")


if __name__ == "__main__":
    main()
