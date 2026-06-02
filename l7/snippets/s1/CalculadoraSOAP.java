package s1;

import javax.jws.WebService;

// START-SNIPPET,implementation
@WebService(
  endpointInterface = "s1.CalculadoraAPI",
  serviceName = "CalculadoraSOAPService",
  portName = "CalculadoraSOAPPort",
  targetNamespace = "http://lab7.docente/"
)
public class CalculadoraSOAP implements CalculadoraAPI {

  @Override
  public int sumar(int a, int b) {
    return a + b;
  }
}
// END-SNIPPET
