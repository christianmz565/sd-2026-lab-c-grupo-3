package lab7.e2.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Item implements Serializable {
  private static final long serialVersionUID = 1L;

  // START-SNIPPET,model
  private String nombre;
  private int cantidad;
  private double costo;

  private static final List<Item> ITEMS = new ArrayList<>(Arrays.asList(
      new Item("Gaseosa", 15, 5.2),
      new Item("Galletas", 10, 1.6),
      new Item("Celular", 12, 900.0)
  ));

  public Item() {
  }

  public Item(String nombre, int cantidad, double costo) {
    this.nombre = nombre;
    this.cantidad = cantidad;
    this.costo = costo;
  }

  public static List<Item> getItems() {
    return ITEMS;
  }

  public static void addItem(Item item) {
    ITEMS.add(item);
  }

  public static String buyItem(String name, int cantidad) {
    for (Item item : ITEMS) {
      if (item.nombre.equalsIgnoreCase(name)) {
        if (item.cantidad - cantidad < 0) {
          return "Not enough items";
        }
        item.cantidad -= cantidad;
        return "Producto: " + item.nombre + " Cantidad: " + cantidad
            + " Total: " + (cantidad * item.costo);
      }
    }
    return "Item no match";
  }

  public static void setItem(String name, int cantidad, double costo) {
    for (Item item : ITEMS) {
      if (item.nombre.equalsIgnoreCase(name)) {
        item.cantidad = cantidad;
        item.costo = costo;
      }
    }
  }

  public static void deleteItem(String name) {
    for (Item item : ITEMS) {
      if (item.nombre.equalsIgnoreCase(name)) {
        item.cantidad = 0;
      }
    }
  }

  public String getNombre() {
    return nombre;
  }

  public void setNombre(String nombre) {
    this.nombre = nombre;
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
    return "Item{nombre='" + nombre + "', cantidad=" + cantidad + ", costo=" + costo + "}";
  }
}
