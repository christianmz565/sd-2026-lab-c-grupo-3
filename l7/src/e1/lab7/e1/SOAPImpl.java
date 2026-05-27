package lab7.e1;

import java.util.List;
import javax.jws.WebService;

@WebService(endpointInterface = "lab7.e1.SOAPI")
public class SOAPImpl implements SOAPI {
  // START-SNIPPET,impl
  @Override
  public List<User> getUsers() {
    return User.getUsers();
  }

  @Override
  public void addUser(User user) {
    User.getUsers().add(user);
  }
  // END-SNIPPET
}
