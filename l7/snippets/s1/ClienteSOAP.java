package s1;

import java.net.URI;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

// START-SNIPPET,client
public class ClienteSOAP {

  public static void main(String[] args) throws Exception {
    URL url = new URI("http://localhost:8080/calculadora?wsdl").toURL();
    QName qname = new QName("http://lab7.docente/", "CalculadoraSOAPService");
    Service service = Service.create(url, qname);
    CalculadoraAPI calc = service.getPort(CalculadoraAPI.class);
    System.out.println(calc.sumar(10, 20));
  }
}
// END-SNIPPET
