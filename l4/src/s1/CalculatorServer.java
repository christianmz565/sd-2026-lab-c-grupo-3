import java.rmi.Naming;

public class CalculatorServer {
    public CalculatorServer() {
        try {
            Calculator c = new CalculatorImpl();
            Naming.rebind("rmi://localhost:1099/CalculatorService", c);
            System.out.println("Calculator Service is ready.");
        } catch (Exception e) {
            System.out.println("Trouble: " + e);
        }
    }

    public static void main(String args[]) {
        System.setProperty("java.rmi.server.hostname", "127.0.0.1");
        new CalculatorServer();
    }
}
