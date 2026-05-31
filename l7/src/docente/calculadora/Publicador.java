package lab7.docente.calculadora;

import javax.xml.ws.Endpoint;

public class Publicador {
  // START-SNIPPET,publish
  public static void main(String[] args) {
    Endpoint.publish("http://localhost:8080/calculadora", new CalculadoraSOAP());
    System.out.println("Servicio SOAP activo");
  }
  // END-SNIPPET
}
