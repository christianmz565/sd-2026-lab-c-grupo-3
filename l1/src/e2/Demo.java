package e2;

public class Demo {

  public static void main(String[] args) {
    CubbyHole cub = new CubbyHole();
    
    // Tanto productor como consumidor referencian a la misma
    // instancia de "CubbyHole", operando concurrentemente
    // sobre los mismos datos.
    Consumidor cons = new Consumidor(cub, 1);
    Productor prod = new Productor(cub, 1);
    
    prod.start();
    cons.start();
  }
}
