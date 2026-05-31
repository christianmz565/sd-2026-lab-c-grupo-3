package lab7.docente.calculadora;

import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class ClienteSOAP {
  // START-SNIPPET,client
  public static void main(String[] args) throws Exception {
    URL url = new URL("http://localhost:8080/calculadora?wsdl");
    QName qname = new QName("http://lab7.docente/", "CalculadoraSOAPService");
    Service service = Service.create(url, qname);
    CalculadoraSOAP calc = service.getPort(CalculadoraSOAP.class);
    System.out.println(calc.sumar(10, 20));
  }
  // END-SNIPPET
}
