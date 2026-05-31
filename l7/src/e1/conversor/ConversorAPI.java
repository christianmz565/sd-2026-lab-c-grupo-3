package lab7.e1.conversor;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(targetNamespace = "http://lab7.e1.conversor/")
public interface ConversorAPI {
  // START-SNIPPET,interface
  @WebMethod
  double cToF(double c);

  @WebMethod
  double fToC(double f);
  // END-SNIPPET
}
