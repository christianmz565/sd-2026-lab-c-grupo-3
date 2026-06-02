package e2.servicio.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// START-SNIPPET,logic
public class Item implements Serializable {
  private String nombre;
  private int cantidad;
  private double costo;

  private static final List<Item> ITEMS = new ArrayList<>(
    Arrays.asList(
      new Item("Gaseosa", 15, 5.2),
      new Item("Galletas", 10, 1.6),
      new Item("Celular", 12, 900.0)
    )
  );

  public static String buyItem(String name, int cantidad) {
    for (Item item : ITEMS) {
      if (item.nombre.equalsIgnoreCase(name)) {
        if (item.cantidad - cantidad < 0) {
          return "Not enough items";
        }
        item.cantidad -= cantidad;
        return "Producto: " + item.nombre + " Total: " + (cantidad * item.costo);
      }
    }
    return "Item no match";
  }
}
// END-SNIPPET
