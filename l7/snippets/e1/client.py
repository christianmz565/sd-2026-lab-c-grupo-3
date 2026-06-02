from zeep import Client

WSDL_URL = "http://localhost:8080/conversor?wsdl"


# START-SNIPPET,python-client
def main():
    print(f"\nConectando a: {WSDL_URL}")
    try:
        client = Client(WSDL_URL)
        print("Conexión establecida con éxito.\n")
    except Exception as e:
        print(f"Error al conectar: {e}")
        return

    while True:
        print("--- CONVERSOR DE UNIDADES ---")
        # ... (opciones del menú)
        opcion = input("\nSeleccione una opción (1-7): ").strip()

        if opcion == "1":
            valor = float(input("Grados Celsius: "))
            try:
                resultado = client.service.cToF(valor)
                print(f"Resultado: {valor}°C = {resultado:.2f}°F")
            except Exception as e:
                print(f"Error: {e}")


# END-SNIPPET
