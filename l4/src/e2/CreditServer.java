
import java.rmi.Naming;
public class CreditServer {
    public static void main(String[] args) {
        System.setProperty("java.rmi.server.hostname", "127.0.0.1");
        try {
            CreditCardImpl card = new CreditCardImpl("1234-5678-9012-3456", "Juan Perez", 5000.00);
            Naming.rebind("rmi://localhost:1099/CREDITCARD", card);
            System.out.println("El servidor de tarjetas de crédito está listo.");
        } catch (Exception e) {
            System.out.println("Excepción del servidor: " + e);
        }
    }
}
