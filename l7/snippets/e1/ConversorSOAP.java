package e1;

import javax.jws.WebService;

// START-SNIPPET,implementation
@WebService(
  endpointInterface = "e1.ConversorAPI",
  serviceName = "ConversorSOAPService",
  portName = "ConversorSOAPPort",
  targetNamespace = "http://lab7.e1.conversor/"
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

  @Override
  public double mToFt(double m) {
    return m * 3.28084;
  }

  @Override
  public double ftToM(double ft) {
    return ft / 3.28084;
  }

  @Override
  public double kgToLb(double kg) {
    return kg * 2.20462;
  }

  @Override
  public double lbToKg(double lb) {
    return lb / 2.20462;
  }
}
// END-SNIPPET
