from zeep import Client


WSDL_URL = "http://localhost:1516/WS/Store?wsdl"


def obtener_entrada(mensaje, tipo=str, obligatorio=True):
    """Auxiliar para obtener entrada validada del usuario."""
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
        print("--- GESTIÓN DE TIENDA ---")
        print("1. Ver inventario")
        print("2. Comprar producto")
        print("3. Agregar nuevo producto")
        print("4. Actualizar producto")
        print("5. Eliminar producto")
        print("6. Salir")
        
        opcion = input("\nSeleccione una opción (1-6): ").strip()

        if opcion == "1":
            try:
                items = client.service.getItems()
                if not items:
                    print("\nEl inventario está vacío.")
                else:
                    print("\n{:<20} | {:>8} | {:>12}".format("Producto", "Stock", "Precio (S/.)"))
                    print("-" * 46)
                    for item in items:
                        print("{:<20} | {:>8} | {:>12.2f}".format(
                            item.nombre, item.cantidad, item.costo
                        ))
            except Exception as e:
                print(f"\nError al obtener el inventario: {e}")
            print()

        elif opcion == "2":
            print("\n--- COMPRA ---")
            nombre = obtener_entrada("Nombre del producto: ")
            cantidad = obtener_entrada("Cantidad a comprar: ", int)
            try:
                resultado = client.service.buyItem(nombre, cantidad)
                print(f"Resultado: {resultado}")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "3":
            print("\n--- NUEVO PRODUCTO ---")
            nombre = obtener_entrada("Nombre: ")
            cantidad = obtener_entrada("Stock inicial: ", int)
            costo = obtener_entrada("Precio: ", float)
            try:
                exito = client.service.addItem({"nombre": nombre, "cantidad": cantidad, "costo": costo})
                if exito:
                    print(f"Producto '{nombre}' agregado correctamente.")
                else:
                    print(f"No se pudo agregar '{nombre}'. Verifique si ya existe o si los datos son válidos.")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "4":
            print("\n--- ACTUALIZAR PRODUCTO ---")
            nombre = obtener_entrada("Nombre del producto a actualizar: ")
            cantidad = obtener_entrada("Nuevo stock: ", int)
            costo = obtener_entrada("Nuevo precio: ", float)
            try:
                exito = client.service.setItem(nombre, cantidad, costo)
                if exito:
                    print(f"Producto '{nombre}' actualizado correctamente.")
                else:
                    print(f"Producto '{nombre}' no encontrado.")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "5":
            print("\n--- ELIMINAR PRODUCTO ---")
            nombre = obtener_entrada("Nombre del producto a eliminar: ")
            try:
                exito = client.service.deleteItem(nombre)
                if exito:
                    print(f"Producto '{nombre}' eliminado (stock puesto en 0).")
                else:
                    print(f"Producto '{nombre}' no encontrado.")
            except Exception as e:
                print(f"Error: {e}")
            print()

        elif opcion == "6":
            print("¡Hasta luego!")
            break
        else:
            print("Opción no válida. Intente de nuevo.")


if __name__ == "__main__":
    main()
