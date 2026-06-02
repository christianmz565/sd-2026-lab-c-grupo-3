package s1;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(
  serviceName = "CalculadoraSOAPService",
  targetNamespace = "http://lab7.docente/"
)
public class CalculadoraSOAP {

  @WebMethod
  public int sumar(int a, int b) {
    return a + b;
  }
}
