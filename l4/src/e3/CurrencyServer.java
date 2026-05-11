
import java.rmi.Naming;
public class CurrencyServer {
    public static void main(String[] args) {
        System.setProperty("java.rmi.server.hostname", "127.0.0.1");
        try {
            CurrencyImpl converter = new CurrencyImpl();
            Naming.rebind("rmi://localhost:1099/CURRENCY", converter);
            System.out.println("El servidor conversor de monedas está listo.");
        } catch (Exception e) {
            System.out.println("Excepción del servidor: " + e);
        }
    }
}
