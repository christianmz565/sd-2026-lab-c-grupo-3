package com.lab05.ep1;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class CalculatorClient {
    public static void main(String[] args) {
        try {
            double a = 5;
            double b = 3;
            Registry registry = LocateRegistry.getRegistry("localhost", 1099);
            ICalculator calculator =
                                (ICalculator) registry.lookup(
                                        "CalculatorService"
                                );
            double result = calculator.add(a, b);
            System.out.println("Sum Result: " + result);
            result = calculator.multiply(a, b);
            System.out.println("Product Result: " + result);
            result = calculator.divide(a, b);
            System.out.println("Division Result: " + result);
            result = calculator.subtract(a, b);
            System.out.println("Subtraction Result: " + result);
            result = calculator.power(a, b);
            System.out.println("Power Result: " + result);

        } catch (RemoteException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
