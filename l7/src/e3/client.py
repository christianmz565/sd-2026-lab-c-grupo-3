# pyrefly: ignore [missing-import]
from zeep import Client

def main():
    wsdl_url = "http://localhost:1516/WS/Store?wsdl"
    print(f"Conectando al servicio SOAP en: {wsdl_url}...")
    try:
        client = Client(wsdl_url)
        print("¡Conexión establecida con éxito!\n")
    except Exception as e:
        print(f"Error al conectar al servicio SOAP: {e}")
        return

    while True:
        print("=======================================")
        print("          MENÚ DE OPERACIONES SOAP     ")
        print("=======================================")
        print("1. Listar todos los productos (getItems)")
        print("2. Comprar un producto (buyItem)")
        print("3. Registrar nuevo producto (addItem)")
        print("4. Actualizar stock y precio (setItem)")
        print("5. Eliminar producto (deleteItem)")
        print("6. Salir")
        print("=======================================")
        
        opcion = input("Seleccione una opción (1-6): ").strip()
        
        if opcion == "1":
            print("\n--- LISTA DE PRODUCTOS ---")
            try:
                items = client.service.getItems()
                if not items:
                    print("No hay productos disponibles.")
                else:
                    for item in items:
                        print(f"- Producto: {item.nombre:15} | Stock: {item.cantidad:5} | Costo: S/. {item.costo:.2f}")
            except Exception as e:
                print(f"Error al listar productos: {e}")
            print()
            
        elif opcion == "2":
            print("\n--- COMPRAR PRODUCTO ---")
            name = input("Nombre del producto: ").strip()
            if not name:
                print("Nombre inválido.")
                continue
            try:
                cantidad = int(input("Cantidad a comprar: "))
                resultado = client.service.buyItem(name, cantidad)
                print(f"Resultado: {resultado}")
            except ValueError:
                print("Por favor, ingrese una cantidad numérica válida.")
            except Exception as e:
                print(f"Error al realizar la compra: {e}")
            print()

        elif opcion == "3":
            print("\n--- REGISTRAR NUEVO PRODUCTO ---")
            name = input("Nombre del producto: ").strip()
            if not name:
                print("Nombre inválido.")
                continue
            try:
                cantidad = int(input("Cantidad inicial: "))
                costo = float(input("Costo/Precio: "))
                nuevo_item = {"nombre": name, "cantidad": cantidad, "costo": costo}
                bool =client.service.addItem(nuevo_item)
                if(bool):
                    print(f"Producto '{name}' registrado exitosamente.")
                else:
                    print(f'Hubo un problema y el Producto {name} no se pudo registrar')
            except ValueError:
                print("Por favor, ingrese valores numéricos válidos.")
            except Exception as e:
                print(f"Error al registrar producto: {e}")
            print()

        elif opcion == "4":
            print("\n--- ACTUALIZAR PRECIO Y STOCK ---")
            name = input("Nombre del producto a actualizar: ").strip()
            if not name:
                print("Nombre inválido.")
                continue
            try:
                cantidad = int(input("Nueva cantidad (stock): "))
                costo = float(input("Nuevo costo/precio: "))
                bool = client.service.setItem(name, cantidad, costo)
                if(bool):
                    print(f"Producto '{name}' actualizado exitosamente.")
                else:
                    print(f'Hubo un problema y el Producto {name} no se pudo actualizar')
            except ValueError:
                print("Por favor, ingrese valores numéricos válidos.")
            except Exception as e:
                print(f"Error al actualizar producto: {e}")
            print()

        elif opcion == "5":
            print("\n--- ELIMINAR PRODUCTO (Baja lógica) ---")
            name = input("Nombre del producto a eliminar: ").strip()
            if not name:
                print("Nombre inválido.")
                continue
            try:
                bool = client.service.deleteItem(name)
                if(bool):
                    print(f"Producto '{name}' eliminado lógicamente (stock establecido en 0).")
                else:
                    print(f'Hubo un problema y el Producto {name} no se pudo eliminar')
            except Exception as e:
                print(f"Error al eliminar producto: {e}")
            print()

        elif opcion == "6":
            print("\nSaliendo del cliente interactivo. ¡Adiós!")
            break
        else:
            print("\nOpción no válida. Intente nuevamente.\n")

if __name__ == "__main__":
    main()

