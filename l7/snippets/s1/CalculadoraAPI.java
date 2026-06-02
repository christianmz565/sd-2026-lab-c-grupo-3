package s1;

import javax.jws.WebMethod;
import javax.jws.WebService;

// START-SNIPPET,interface
@WebService(targetNamespace = "http://lab7.docente/")
public interface CalculadoraAPI {
  @WebMethod
  public int sumar(int a, int b);
}
// END-SNIPPET
