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
  public boolean addItem(Item item) {
    return Item.addItem(item);
  }

  @Override
  public boolean setItem(String name, int cantidad, double precio) {
    return Item.setItem(name, cantidad, precio);
  }
<<<<<<< HEAD:l7/src/e1/store/soap/SOAPImpl.java
=======

  @Override
  public boolean deleteItem(String name) {
    return Item.deleteItem(name);
  }
>>>>>>> d6f0f7942d435d51f5bcbac034ff1dd2d63c8cb3:l7/src/e2/lab7/e2/soap/SOAPImpl.java
  // END-SNIPPET
}
