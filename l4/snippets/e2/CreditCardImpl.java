import java.rmi.server.UnicastRemoteObject;
// START-SNIPPET,card-impl
public class CreditCardImpl extends UnicastRemoteObject implements CreditCardInterface {
    private String cardNumber;
    private String ownerName;
    private double balance;
    private double creditLimit;

    public CreditCardImpl(String cardNumber, String ownerName, double creditLimit) throws Exception {
        super();
        this.cardNumber = cardNumber;
        this.ownerName = ownerName;
        this.creditLimit = creditLimit;
        this.balance = 0.0;
    }

    @Override
    public boolean processPayment(double amount) throws Exception {
        if (this.balance + amount <= this.creditLimit) {
            this.balance += amount;
            return true;
        }
        return false;
    }

    @Override
    public double getBalance() throws Exception {
        return this.balance;
    }

    @Override
    public String getCardDetails() throws Exception {
        return "Tarjeta: " + cardNumber + " | Titular: " + ownerName + " | Límite: " + creditLimit;
    }
}
// END-SNIPPET
