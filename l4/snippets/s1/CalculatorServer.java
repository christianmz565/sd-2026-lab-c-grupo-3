import java.rmi.Naming;

public class CalculatorServer {
    public CalculatorServer() {
        try {
            Calculator c = new CalculatorImpl();
            // START-SNIPPET,server-bind
            Naming.rebind("rmi://localhost:1099/CalculatorService", c);
            System.out.println("Calculator Service is ready.");
// END-SNIPPET
        } catch (Exception e) {
            System.out.println("Trouble: " + e);
        }
    }

    public static void main(String args[]) {
        new CalculatorServer();
    }
}
