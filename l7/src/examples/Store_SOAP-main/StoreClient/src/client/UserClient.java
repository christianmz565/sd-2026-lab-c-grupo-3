package client;

import java.rmi.RemoteException;
import java.util.Arrays;
import javax.xml.rpc.ServiceException;

import soap.Item;
import soap.SOAPI;
import soap.SOAPImplServiceLocator;


public class UserClient {
	public static void main(String[] args) {
		SOAPImplServiceLocator locator = new SOAPImplServiceLocator();
		try {
			SOAPI storeService = locator.getSOAPImplPort();

			// Se muestra la lista de usuarios
			System.out.println("Lista de productos: \n" + Arrays.toString(storeService.getItems()).toString());

			/*
			storeService.addItem(new Item(10, 1.4,"Chicle"));
			*/
			
			/*
			System.out.println("Comprando productos:\n");
			String recibo = storeService.buyItem("Galletas", 2);
			System.out.println("Recibo compra: \n" + recibo);
			*/
			
			
			System.out.println("Actualizando stock de un producto");
			storeService.setItem("Galletas", 10, 2.4);
		
			System.out.println("Lista de productos: \n" + Arrays.toString(storeService.getItems()).toString());
			

		} catch (ServiceException e) {
			e.printStackTrace();
		} catch (RemoteException e) {
			e.printStackTrace();
		}
	}
}
