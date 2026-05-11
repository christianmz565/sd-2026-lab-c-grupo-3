import java.rmi.server.UnicastRemoteObject;
// START-SNIPPET,currency-impl
public class CurrencyImpl extends UnicastRemoteObject implements CurrencyInterface {
    private static final double TASA_DOLAR = 3.50;
    private static final double TASA_EURO = 4.10;

    public CurrencyImpl() throws Exception {
        super();
    }

    @Override
    public double convertirADolares(double monto) throws Exception {
        return monto / TASA_DOLAR;
    }

    @Override
    public double convertirAEuros(double monto) throws Exception {
        return monto / TASA_EURO;
    }
}
// END-SNIPPET
