package e2;

// Representa a la entidad que lee elementos secuencialmente.
public class Consumidor extends Thread {

  private CubbyHole cubbyhole;
  private int numero;

  public Consumidor(CubbyHole c, int numero) {
    cubbyhole = c;
    this.numero = numero;
  }

  public void run() {
    int value = 0;
    // Iteraciones para tomar datos que ha introducido el productor.
    for (int i = 0; i < 10; i++) {
      value = cubbyhole.get();
      System.out.println("Consumidor #" + this.numero + " obtiene:" + value);
    }
  }
}
