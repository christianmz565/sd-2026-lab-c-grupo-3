package lab7.e1.store.client;

import java.net.URL;
import java.util.Arrays;
import java.util.List;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import lab7.e1.store.model.Item;
import lab7.e1.store.soap.SOAPI;

public class StoreClient {
  // START-SNIPPET,client
  public static void main(String[] args) throws Exception {
    URL wsdlUrl = new URL("http://localhost:1516/WS/Store?wsdl");
    QName serviceName = new QName("http://lab7.e1.store/", "StoreSOAPService");
    Service service = Service.create(wsdlUrl, serviceName);
    SOAPI store = service.getPort(SOAPI.class);

    List<Item> items = store.getItems();
    System.out.println("Lista de productos: " + Arrays.toString(items.toArray()));

    store.addItem(new Item("Chicle", 20, 1.4));
    System.out.println("Lista actualizada: " + Arrays.toString(store.getItems().toArray()));

    String recibo = store.buyItem("Galletas", 2);
    System.out.println("Recibo: " + recibo);

    store.setItem("Galletas", 18, 2.4);
    System.out.println("Lista final: " + Arrays.toString(store.getItems().toArray()));
  }
  // END-SNIPPET
}
