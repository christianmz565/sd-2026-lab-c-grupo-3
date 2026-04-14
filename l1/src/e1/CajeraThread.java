package e1;

// Extender Thread permite crear múltiples instancias de esta clase 
// que pueden ejecutarse simultáneamente en paralelo
public class CajeraThread extends Thread {

  private String nombre;
  private Cliente cliente;
  private long initialTime;

  public CajeraThread() {}

  public CajeraThread(String nombre, Cliente cliente, long initialTime) {
    this.nombre = nombre;
    this.cliente = cliente;
    this.initialTime = initialTime;
  }

  public String getNombre() {
    return nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
  }

  public long getInitialTime() {
    return initialTime;
  }

  public void setInitialTime(long initialTime) {
    this.initialTime = initialTime;
  }

  public Cliente getCliente() {
    return cliente;
  }

  public void setCliente(Cliente cliente) {
    this.cliente = cliente;
  }

  // Sobrescribir el método run es el paso esencial para definir 
  // qué tarea ejecutará este nuevo hilo. Al llamar al método start() 
  // sobre la instancia de esta clase, el código dentro de run() iniciará.
  @Override
  public void run() {
    System.out.println(
      "La cajera " +
        this.nombre +
        " COMIENZA A PROCESAR LA COMPRA DEL CLIENTE " +
        this.cliente.getNombre() +
        " EN EL TIEMPO: " +
        (System.currentTimeMillis() - this.initialTime) / 1000 +
        "seg"
    );

    for (int i = 0; i < this.cliente.getCarroCompra().length; i++) {
      this.esperarXsegundos(cliente.getCarroCompra()[i]);
      System.out.println(
        "Procesado el producto " +
          (i + 1) +
          " del cliente " +
          this.cliente.getNombre() +
          "->Tiempo: " +
          (System.currentTimeMillis() - this.initialTime) / 1000 +
          "seg"
      );
    }
    System.out.println(
      "La cajera " +
        this.nombre +
        " HA TERMINADO DE PROCESAR " +
        this.cliente.getNombre() +
        " EN EL TIEMPO: " +
        (System.currentTimeMillis() - this.initialTime) / 1000 +
        "seg"
    );
  }

  private void esperarXsegundos(int segundos) {
    try {
      Thread.sleep(segundos * 1000);
    } catch (InterruptedException ex) {
      Thread.currentThread().interrupt();
    }
  }
}
