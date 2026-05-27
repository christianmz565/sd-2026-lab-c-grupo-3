package lab7.e1;

import java.util.List;
import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService
public interface SOAPI {
  // START-SNIPPET,interface
  @WebMethod
  List<User> getUsers();

  @WebMethod
  void addUser(User user);
  // END-SNIPPET
}
