package e1;

import javax.jws.WebService;

@WebService(
  endpointInterface = "e1.ConversorAPI",
  serviceName = "ConversorSOAPService",
  targetNamespace = "http://l7.e1.conversor/"
)
public class ConversorSOAP implements ConversorAPI {

  @Override
  public double cToF(double c) {
    return ((c * 9.0) / 5.0) + 32.0;
  }

  @Override
  public double fToC(double f) {
    return ((f - 32.0) * 5.0) / 9.0;
  }
}
