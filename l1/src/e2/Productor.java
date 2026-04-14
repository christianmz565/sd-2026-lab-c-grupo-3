package e2;

// Representa a la entidad que produce elementos, extendiendo Thread
// para ejecutarse en su propia pila.
public class Productor extends Thread {

  private CubbyHole cubbyhole;
  private int numero;

  public Productor(CubbyHole c, int numero) {
    cubbyhole = c;
    this.numero = numero;
  }

  public void run() {
    for (int i = 0; i < 10; i++) {
      // Solicita ingresar el número en el espacio compartido
      cubbyhole.put(i);
      System.out.println("Productor #" + this.numero + "pone:" + i);
      
      // Introduce un retraso pseudoaleatorio que puede causar 
      // cambios en la intercalación de mensajes al ejecutar.
      try {
        sleep((int) (Math.random() * 100));
      } catch (InterruptedException e) {}
    }
  }
}
