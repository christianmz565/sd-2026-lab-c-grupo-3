package e2.servicio.soap;

import e2.servicio.model.Item;
import java.util.List;
import javax.jws.WebMethod;
import javax.jws.WebService;

// START-SNIPPET,interface
@WebService(targetNamespace = "http://lab7.e2.servicio.soap/")
public interface SOAPI {
  @WebMethod
  public List<Item> getItems();

  @WebMethod
  public String buyItem(String name, int cantidad);

  @WebMethod
  public boolean addItem(Item item);

  @WebMethod
  public boolean setItem(String name, int cantidad, double precio);

  @WebMethod
  public boolean deleteItem(String name);
}
// END-SNIPPET
