package e2;

// Representa el monitor compartido que garantiza el acceso mutuo.
public class CubbyHole {

  private int contents;
  private boolean available = false;

  // Usa "synchronized" para que solo un hilo acceda a obtener el dato a la vez.
  public synchronized int get() {
    // Patrón de espera condicional: el consumidor espera (wait) 
    // hasta que el producto esté disponible. El while previene 
    // que despierte erróneamente.
    while (available == false) {
      try {
        wait();
      } catch (InterruptedException e) {}
    }
    available = false;
    // Notifica y despierta a los otros hilos que esperan sobre este monitor.
    notifyAll();
    return contents;
  }

  // Uso de exclusión mutua para el método de depositar producto.
  public synchronized void put(int value) {
    // Si el contenido no se ha consumido, el productor debe esperar.
    while (available == true) {
      try {
        wait();
      } catch (InterruptedException e) {}
    }
    contents = value;
    available = true;
    
    // Notifica que un nuevo dato ha sido añadido y está listo para leer.
    notifyAll();
  }
}
