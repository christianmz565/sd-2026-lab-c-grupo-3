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
<<<<<<< HEAD:l7/src/e1/store/soap/SOAPI.java
  void setItem(String name, int cantidad, double precio);
=======
  boolean setItem(String name, int cantidad, double precio);

  @WebMethod
  boolean deleteItem(String name);
>>>>>>> d6f0f7942d435d51f5bcbac034ff1dd2d63c8cb3:l7/src/e2/lab7/e2/soap/SOAPI.java
  // END-SNIPPET
}
