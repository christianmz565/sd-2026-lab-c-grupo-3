package e1;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(targetNamespace = "http://lab7.e1.conversor/")
public interface ConversorAPI {
  @WebMethod
  double cToF(double c);

  @WebMethod
  double fToC(double f);

  @WebMethod
  double mToFt(double m);

  @WebMethod
  double ftToM(double ft);

  @WebMethod
  double kgToLb(double kg);

  @WebMethod
  double lbToKg(double lb);
}
