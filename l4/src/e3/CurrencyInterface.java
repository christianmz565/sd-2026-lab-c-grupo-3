
import java.rmi.Remote;
public interface CurrencyInterface extends Remote {
    public double convertirADolares(double monto) throws Exception;
    public double convertirAEuros(double monto) throws Exception;
}
