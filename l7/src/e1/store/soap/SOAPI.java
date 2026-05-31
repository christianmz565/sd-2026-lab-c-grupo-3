package lab7.e1.store.soap;

import java.util.List;
import javax.jws.WebMethod;
import javax.jws.WebService;
import lab7.e1.store.model.Item;

@WebService(targetNamespace = "http://lab7.e1.store/")
public interface SOAPI {
  // START-SNIPPET,interface
  @WebMethod
  List<Item> getItems();

  @WebMethod
  String buyItem(String name, int cantidad);

  @WebMethod
  boolean addItem(Item item);

  @WebMethod
  boolean setItem(String name, int cantidad, double precio);

  @WebMethod
  boolean deleteItem(String name);
  // END-SNIPPET
}
