import java.rmi.Naming;
// START-SNIPPET,currency-server
public class CurrencyServer {
    public static void main(String[] args) {
        try {
            CurrencyImpl converter = new CurrencyImpl();
            Naming.rebind("rmi://localhost:1099/CURRENCY", converter);
            System.out.println("El servidor conversor de monedas está listo.");
        } catch (Exception e) {
            System.out.println("Excepción del servidor: " + e);
        }
    }
}
// END-SNIPPET
