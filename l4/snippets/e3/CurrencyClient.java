import java.rmi.Naming;
import java.util.Scanner;
// START-SNIPPET,currency-client
public class CurrencyClient {
    public static void main(String[] args) {
        try {
            CurrencyInterface converter = (CurrencyInterface) Naming.lookup("rmi://localhost:1099/CURRENCY");
            System.out.println("Conectado al servidor conversor de monedas");
            
            Scanner sc = new Scanner(System.in);
            System.out.print("Ingrese monto en soles: ");
            double soles = sc.nextDouble();
            
            System.out.println("1. Convertir a Dolares");
            System.out.println("2. Convertir a Euros");
            System.out.print("Seleccione opcion: ");
            int opcion = sc.nextInt();
            
            if (opcion == 1) {
                System.out.printf("Monto en Dolares: %.2f\n", converter.convertirADolares(soles));
            } else if (opcion == 2) {
                System.out.printf("Monto en Euros: %.2f\n", converter.convertirAEuros(soles));
            } else {
                System.out.println("Opcion no valida");
            }
            sc.close();
        } catch (Exception e) {
            System.out.println("Excepción del cliente: " + e);
        }
    }
}
// END-SNIPPET
