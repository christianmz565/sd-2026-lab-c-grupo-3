
import java.rmi.Remote;
public interface CreditCardInterface extends Remote {
    public boolean processPayment(double amount) throws Exception;
    public double getBalance() throws Exception;
    public String getCardDetails() throws Exception;
}