package l7.e1.store.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Item implements Serializable {
  private static final long serialVersionUID = 1L;

  // START-SNIPPET,model
  private String name;
  private int cantidad;
  private double costo;

  private static final List<Item> ITEMS = new ArrayList<>(Arrays.asList(
      new Item("Gaseosa", 15, 5.2),
      new Item("Galletas", 10, 1.6),
      new Item("Celular", 12, 900.0)));

  public Item() {
  }

  public Item(String name, int cantidad, double costo) {
    this.name = name;
    this.cantidad = cantidad;
    this.costo = costo;
  }

  public static List<Item> getItems() {
    return ITEMS;
  }

  public static boolean addItem(Item item) {
    if (item.name == null || item.name.isEmpty() || item.cantidad <= 0 || item.costo <= 0) {
      return false;
    }
    ITEMS.add(item);
    return true;
  }

  public static String buyItem(String name, int cantidad) {
    if (cantidad <= 0) {
      return "Invalid Quantity";
    }
    for (Item item : ITEMS) {
      if (item.name.equalsIgnoreCase(name)) {
        if (item.cantidad - cantidad < 0) {
          return "Not enough items";
        }
        item.cantidad -= cantidad;
        return "Producto: " + item.name + " Cantidad: " + cantidad
            + " Total: " + String.format(java.util.Locale.US, "%.2f", (cantidad * item.costo));
      }
    }
    return "Item no match";
  }

  public static boolean setItem(String name, int cantidad, double costo) {
    if (name == null || name.isEmpty() || cantidad <= 0 || costo <= 0) {
      return false;
    }
    for (Item item : ITEMS) {
      if (item.name.equalsIgnoreCase(name)) {
        item.cantidad = cantidad;
        item.costo = costo;
        return true;
      }
    }
    return false;
  }

  public static boolean deleteItem(String name) {
    if (name == null || name.isEmpty()) {
      return false;
    }
    for (Item item : ITEMS) {
      if (item.name.equalsIgnoreCase(name)) {
        item.cantidad = 0;
        return true;
      }
    }
    return false;
  }

  public String getNombre() {
    return name;
  }

  public void setNombre(String name) {
    this.name = name;
  }

  public int getCantidad() {
    return cantidad;
  }

  public void setCantidad(int cantidad) {
    this.cantidad = cantidad;
  }

  public double getCosto() {
    return costo;
  }

  public void setCosto(double costo) {
    this.costo = costo;
  }
  // END-SNIPPET

  @Override
  public String toString() {
    return "Item{name='" + name + "', cantidad=" + cantidad + ", costo=" + costo + "}";
  }
}
