from zeep import Client

WSDL_URL = "http://localhost:1516/WS/Store?wsdl"


# START-SNIPPET,python-client
def main() -> None:
    client = Client(WSDL_URL)

    # Ver inventario
    items = client.service.getItems()
    for item in items:
        print(f"Producto: {item.nombre}, Stock: {item.cantidad}, Precio: {item.costo}")

    # Comprar producto
    resultado = client.service.buyItem("Gaseosa", 2)
    print(f"Resultado compra: {resultado}")


# END-SNIPPET
