package lab7.e1.conversor;

import javax.xml.ws.Endpoint;

public class PublishService {
  // START-SNIPPET,publish
  public static void main(String[] args) {
    Endpoint.publish("http://localhost:8080/conversor", new ConversorSOAP());
  }
  // END-SNIPPET
}
