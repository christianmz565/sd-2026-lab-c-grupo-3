package lab7.e2.demo;

import javax.xml.ws.Endpoint;
import lab7.e2.soap.SOAPImpl;

public class PublishService {
  // START-SNIPPET,publish
  public static void main(String[] args) {
    Endpoint.publish("http://localhost:1516/WS/Store", new SOAPImpl());
  }
  // END-SNIPPET
}
 