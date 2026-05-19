package com.lab05.ep1;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class CalculatorClient {
  public static void main(String[] args) {
    try {
      // START-SNIPPET,client-logic
      Registry registry = LocateRegistry.getRegistry("localhost", 1099);
      ICalculator calculator = (ICalculator) registry.lookup(
        "CalculatorService"
      );
      double result = calculator.add(5, 3);
      System.out.println("Sum Result: " + result);
      result = calculator.power(2, 10);
      System.out.println("Power Result: " + result);
      // END-SNIPPET
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
