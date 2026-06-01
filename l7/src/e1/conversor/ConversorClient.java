package l7.e1.conversor;

import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class ConversorClient {
  // START-SNIPPET,client
  public static void main(String[] args) throws Exception {
    URL wsdlUrl = new URL("http://localhost:8080/conversor?wsdl");
    QName serviceName = new QName("http://l7.e1.conversor/", "ConversorSOAPService");
    Service service = Service.create(wsdlUrl, serviceName);
    ConversorAPI api = service.getPort(ConversorAPI.class);

    System.out.println("30C -> " + api.cToF(30));
    System.out.println("86F -> " + api.fToC(86));
  }
  // END-SNIPPET
}
