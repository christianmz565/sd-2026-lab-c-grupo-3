package l7.e1.store.demo;

import javax.xml.ws.Endpoint;
import l7.e1.store.soap.SOAPImpl;

public class PublishService {
  // START-SNIPPET,publish
  public static void main(String[] args) {
    Endpoint.publish("http://localhost:1516/WS/Store", new SOAPImpl());
  }
  // END-SNIPPET
}
