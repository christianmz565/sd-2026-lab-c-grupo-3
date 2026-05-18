package com.lab05.ep1;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class CalculatorServer {

  public static void main(String[] args) {
    try {
      Calculator calculator = new Calculator();

      Registry registry = LocateRegistry.createRegistry(1099);

      registry.rebind("CalculatorService", calculator);

      System.out.println("Servidor RPC iniciado");
      while (true) {}
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
