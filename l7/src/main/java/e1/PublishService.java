package e1;

import javax.xml.ws.Endpoint;

public class PublishService {

  public static void main(String[] args) {
    Endpoint.publish("http://localhost:8080/conversor", new ConversorSOAP());
  }
}
