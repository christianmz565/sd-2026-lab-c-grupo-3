package lab7.docente.calculadora;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(serviceName = "CalculadoraSOAPService", targetNamespace = "http://lab7.docente/")
public class CalculadoraSOAP {
  // START-SNIPPET,service
  @WebMethod
  public int sumar(int a, int b) {
    return a + b;
  }
  // END-SNIPPET
}
