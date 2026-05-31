package lab7.e2.soap;

import java.util.List;
import javax.jws.WebMethod;
import javax.jws.WebService;
import lab7.e2.model.Item;

@WebService
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
