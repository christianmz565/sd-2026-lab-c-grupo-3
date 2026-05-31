package lab7.e1.conversor;

import javax.jws.WebService;

@WebService(
    endpointInterface = "lab7.e1.conversor.ConversorAPI",
    serviceName = "ConversorSOAPService",
    targetNamespace = "http://lab7.e1.conversor/"
)
public class ConversorSOAP implements ConversorAPI {
  // START-SNIPPET,impl
  @Override
  public double cToF(double c) {
    return (c * 9.0 / 5.0) + 32.0;
  }

  @Override
  public double fToC(double f) {
    return (f - 32.0) * 5.0 / 9.0;
  }
  // END-SNIPPET
}
