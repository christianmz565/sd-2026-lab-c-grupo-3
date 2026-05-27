package lab7.e2.client;

import java.util.Arrays;
import java.util.List;
import lab7.e2.model.Item;

public class UserClient {
  public static void main(String[] args) {
    List<Item> items = Item.getItems();
    System.out.println("Lista de productos: " + Arrays.toString(items.toArray()));

    Item.addItem(new Item("Chicle", 20, 1.4));
    System.out.println("Lista actualizada: " + Arrays.toString(items.toArray()));

    System.out.println("Actualizando stock de Galletas");
    Item.setItem("Galletas", 18, 2.4);
    System.out.println("Lista final: " + Arrays.toString(items.toArray()));
  }
}
