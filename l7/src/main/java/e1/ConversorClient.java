package e1;

import java.net.URI;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class ConversorClient {

  public static void main(String[] args) throws Exception {
    URL wsdlUrl = new URI("http://localhost:8080/conversor?wsdl").toURL();
    QName serviceName = new QName(
      "http://lab7.e1.conversor/",
      "ConversorSOAPService"
    );
    Service service = Service.create(wsdlUrl, serviceName);
    ConversorAPI api = service.getPort(ConversorAPI.class);

    System.out.println("30C -> " + api.cToF(30));
    System.out.println("86F -> " + api.fToC(86));
    System.out.println("10m -> " + api.mToFt(10) + "ft");
    System.out.println("10kg -> " + api.kgToLb(10) + "lb");
  }
}
