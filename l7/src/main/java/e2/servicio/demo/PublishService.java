package e2.servicio.demo;

import e2.servicio.soap.SOAPImpl;
import javax.xml.ws.Endpoint;

public class PublishService {

  public static void main(String[] args) {
    Endpoint.publish("http://localhost:1516/WS/Store", new SOAPImpl());
  }
}
