package lab7.e2.soap;

import java.util.List;
import javax.jws.WebService;
import lab7.e2.model.Item;

@WebService(endpointInterface = "lab7.e2.soap.SOAPI")
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

  @Override
  public void deleteItem(String name) {
    Item.deleteItem(name);
  }
  // END-SNIPPET
}
