package e1;

// Implementar Runnable es una alternativa a heredar de Thread, 
// permitiendo compartir el proceso principal en múltiples subprocesos 
// y manteniendo libre la capacidad de heredar de otra clase base si hiciera falta.
public class MainRunnable implements Runnable {

  private Cliente cliente;
  private Cajera cajera;
  private long initialTime;

  public MainRunnable(Cliente cliente, Cajera cajera, long initialTime) {
    this.cajera = cajera;
    this.cliente = cliente;
    this.initialTime = initialTime;
  }

  public static void main(String[] args) {
    Cliente cliente1 = new Cliente("Cliente 1", new int[] { 2, 2, 1, 5, 2, 3 });
    Cliente cliente2 = new Cliente("Cliente 2", new int[] { 1, 3, 5, 1, 1 });
    Cajera cajera1 = new Cajera("Cajera 1");
    Cajera cajera2 = new Cajera("Cajera 2");
    
    long initialTime = System.currentTimeMillis();
    
    Runnable proceso1 = new MainRunnable(cliente1, cajera1, initialTime);
    Runnable proceso2 = new MainRunnable(cliente2, cajera2, initialTime);
    
    // Al usar Runnable, es necesario crear una instancia de la clase Thread
    // pasándole como argumento al constructor el objeto Runnable para iniciar su ejecución.
    new Thread(proceso1).start();
    new Thread(proceso2).start();
  }

  // La funcionalidad que el hilo desarrollará, exigido por la interfaz Runnable.
  @Override
  public void run() {
    this.cajera.procesarCompra(this.cliente, this.initialTime);
  }
}
