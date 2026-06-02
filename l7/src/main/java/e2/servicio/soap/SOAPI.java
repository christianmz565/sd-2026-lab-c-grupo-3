package e2.servicio.soap;

import e2.servicio.model.Item;
import java.util.List;
import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(targetNamespace = "http://l7.e2.servicio.soap/")
public interface SOAPI {
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
}
