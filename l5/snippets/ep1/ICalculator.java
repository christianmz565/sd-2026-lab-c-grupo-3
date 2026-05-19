package com.lab05.ep1;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface ICalculator extends Remote {
  // START-SNIPPET,calculator-interface
  double multiply(double a, double b) throws RemoteException;
  double divide(double a, double b) throws RemoteException;
  double add(double a, double b) throws RemoteException;
  double subtract(double a, double b) throws RemoteException;
  double power(double a, double b) throws RemoteException;
  // END-SNIPPET
}
