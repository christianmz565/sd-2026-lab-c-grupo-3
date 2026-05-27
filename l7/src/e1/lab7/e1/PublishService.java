package lab7.e1;

import javax.xml.ws.Endpoint;

public class PublishService {
  // START-SNIPPET,publish
  public static void main(String[] args) {
    Endpoint.publish("http://localhost:1516/WS/Users", new SOAPImpl());
  }
  // END-SNIPPET
}
