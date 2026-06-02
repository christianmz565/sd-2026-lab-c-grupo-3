from zeep import Client

WSDL_URL = "http://localhost:8080/conversor?wsdl"


def obtener_entrada(mensaje, tipo=float, obligatorio=True):
    while True:
        try:
            valor = input(mensaje).strip()
            if obligatorio and not valor:
                print("Error: Este campo es obligatorio.")
                continue
            return tipo(valor)
        except ValueError:
            etiqueta_tipo = {int: "entero", float: "decimal"}.get(tipo, "válido")
            print(f"Error: Por favor, ingrese un valor {etiqueta_tipo}.")


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
        print("1. Celsius a Fahrenheit")
        print("2. Fahrenheit a Celsius")
        print("3. Metros a Pies")
        print("4. Pies a Metros")
        print("5. Kilogramos a Libras")
        print("6. Libras a Kilogramos")
        print("7. Salir")

        opcion = input("\nSeleccione una opción (1-7): ").strip()

        if opcion == "1":
            valor = obtener_entrada("Grados Celsius: ")
            try:
                resultado = client.service.cToF(valor)
                print(f"Resultado: {valor}°C = {resultado:.2f}°F")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "2":
            valor = obtener_entrada("Grados Fahrenheit: ")
            try:
                resultado = client.service.fToC(valor)
                print(f"Resultado: {valor}°F = {resultado:.2f}°C")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "3":
            valor = obtener_entrada("Metros: ")
            try:
                resultado = client.service.mToFt(valor)
                print(f"Resultado: {valor} m = {resultado:.2f} ft")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "4":
            valor = obtener_entrada("Pies: ")
            try:
                resultado = client.service.ftToM(valor)
                print(f"Resultado: {valor} ft = {resultado:.2f} m")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "5":
            valor = obtener_entrada("Kilogramos: ")
            try:
                resultado = client.service.kgToLb(valor)
                print(f"Resultado: {valor} kg = {resultado:.2f} lb")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "6":
            valor = obtener_entrada("Libras: ")
            try:
                resultado = client.service.lbToKg(valor)
                print(f"Resultado: {valor} lb = {resultado:.2f} kg")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "7":
            print("¡Hasta luego!")
            break
        else:
            print("Opción no válida. Intente de nuevo.")


if __name__ == "__main__":
    main()
