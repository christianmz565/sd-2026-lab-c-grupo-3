package s1;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(targetNamespace = "http://lab7.docente/")
public interface CalculadoraAPI {
  @WebMethod
  public int sumar(int a, int b);
}
