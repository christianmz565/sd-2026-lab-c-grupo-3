package lab7.e1;

import java.net.URL;
import java.util.Arrays;
import java.util.List;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class UserClient {
  // START-SNIPPET,client
  public static void main(String[] args) throws Exception {
    URL wsdlUrl = new URL("http://localhost:1516/WS/Users?wsdl");
    QName serviceName = new QName("http://e1.lab7/", "SOAPImplService");
    Service service = Service.create(wsdlUrl, serviceName);
    SOAPI soap = service.getPort(SOAPI.class);

    List<User> users = soap.getUsers();
    System.out.println("Lista de usuarios: " + Arrays.toString(users.toArray()));

    soap.addUser(new User("Pablo Ruiz", "pruiz"));
    System.out.println("Lista actualizada: " + Arrays.toString(soap.getUsers().toArray()));
  }
  // END-SNIPPET
}
