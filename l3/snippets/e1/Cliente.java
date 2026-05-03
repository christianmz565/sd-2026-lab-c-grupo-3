import java.io.*;
import java.net.*;

public class Cliente {
    static final String HOST = "localhost";
    static final int PUERTO = 5000;
    
    public Cliente() {
        // START-SNIPPET,client-connect
        try {
            Socket skCliente = new Socket(HOST, PUERTO);
            InputStream aux = skCliente.getInputStream();
            DataInputStream flujo = new DataInputStream(aux);
            System.out.println(flujo.readUTF());
            skCliente.close();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        // END-SNIPPET
    }
    
    public static void main(String[] arg) {
        new Cliente();
    }
}