package lab7.e1.store.soap;

import java.util.List;
import javax.jws.WebService;
import lab7.e1.store.model.Item;

@WebService(
    endpointInterface = "lab7.e1.store.soap.SOAPI",
    serviceName = "StoreSOAPService",
    targetNamespace = "http://lab7.e1.store/"
)
public class SOAPImpl implements SOAPI {
  // START-SNIPPET,impl
  @Override
  public List<Item> getItems() {
    return Item.getItems();
  }

  @Override
  public String buyItem(String name, int cantidad) {
    return Item.buyItem(name, cantidad);
  }

  @Override
  public void addItem(Item item) {
    Item.addItem(item);
  }

  @Override
  public void setItem(String name, int cantidad, double precio) {
    Item.setItem(name, cantidad, precio);
  }
  // END-SNIPPET
}
