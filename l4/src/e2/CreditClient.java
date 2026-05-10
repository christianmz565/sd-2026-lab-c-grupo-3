
import java.rmi.Naming;
import java.util.Scanner;
public class CreditClient {
    public static void main(String[] args) {
        System.setProperty("java.rmi.server.hostname", "127.0.0.1");
        try {
            CreditCardInterface card = (CreditCardInterface) Naming.lookup("rmi://localhost:1099/CREDITCARD");
            System.out.println("Conectado al servidor de tarjetas de crédito");
            System.out.println(card.getCardDetails());
            
            Scanner sc = new Scanner(System.in);
            System.out.println("Saldo actual: " + card.getBalance());
            System.out.print("Ingrese el monto a cargar: ");
            double amount = sc.nextDouble();
            
            if (card.processPayment(amount)) {
                System.out.println("Pago procesado exitosamente.");
            } else {
                System.out.println("Pago fallido: Límite de crédito excedido.");
            }
            System.out.println("Saldo actualizado: " + card.getBalance());
            sc.close();
        } catch (Exception e) {
            System.out.println("Excepción del cliente: " + e);
        }
    }
}
