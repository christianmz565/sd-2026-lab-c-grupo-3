package e2.servicio.soap;

import e2.servicio.model.Item;
import java.util.List;
import javax.jws.WebService;

// START-SNIPPET,implementation
@WebService(
  endpointInterface = "e2.servicio.soap.SOAPI",
  serviceName = "SOAPImplService",
  portName = "SOAPImplPort",
  targetNamespace = "http://lab7.e2.servicio.soap/"
)
public class SOAPImpl implements SOAPI {

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

  @Override
  public boolean deleteItem(String name) {
    return Item.deleteItem(name);
  }
}
// END-SNIPPET
