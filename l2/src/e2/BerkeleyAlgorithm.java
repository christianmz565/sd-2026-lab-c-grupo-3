import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class BerkeleyAlgorithm {

  static class Node {

    private final String name;
    private long offsetMillis;

    Node(String name, long offsetMillis) {
      this.name = name;
      this.offsetMillis = offsetMillis;
    }

    synchronized long getLocalTimeMillis() {
      return System.currentTimeMillis() + offsetMillis;
    }

    synchronized long getOffsetMillis() {
      return offsetMillis;
    }

    synchronized void adjustOffset(long adjustmentMillis) {
      offsetMillis += adjustmentMillis;
    }

    String getName() {
      return name;
    }
  }

  static class Coordinator {

    private final Node master;
    private final List<Node> nodes;
    private final Random random;

    Coordinator(Node master, List<Node> nodes) {
      this.master = master;
      this.nodes = nodes;
      this.random = new Random();
    }

    private void simulateNetworkDelay() {
      try {
        Thread.sleep(40 + random.nextInt(110));
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }

    void synchronize() {
      List<Long> observedOffsets = new ArrayList<>();
      long masterTime = master.getLocalTimeMillis();

      System.out.println("Estado inicial:");
      for (Node node : nodes) {
        System.out.println(
          node.getName() +
            " -> offset=" +
            node.getOffsetMillis() +
            " ms, localTime=" +
            node.getLocalTimeMillis()
        );
      }

      for (Node node : nodes) {
        simulateNetworkDelay();
        long nodeTime = node.getLocalTimeMillis();
        long difference = nodeTime - masterTime;
        observedOffsets.add(difference);
      }

      long total = 0;
      for (long diff : observedOffsets) {
        total += diff;
      }
      long averageDifference = total / observedOffsets.size();

      for (int i = 0; i < nodes.size(); i++) {
        Node node = nodes.get(i);
        long nodeDiff = observedOffsets.get(i);
        long adjustment = averageDifference - nodeDiff;
        node.adjustOffset(adjustment);
        System.out.println("Ajuste para " + node.getName() + ": " + adjustment + " ms");
      }

      System.out.println("\nEstado final:");
      for (Node node : nodes) {
        System.out.println(
          node.getName() +
            " -> offset=" +
            node.getOffsetMillis() +
            " ms, localTime=" +
            node.getLocalTimeMillis()
        );
      }
    }
  }

  public static void main(String[] args) {
    Node master = new Node("Master", 500);
    List<Node> nodes = new ArrayList<>();

    nodes.add(master);
    nodes.add(new Node("Nodo-1", -1800));
    nodes.add(new Node("Nodo-2", 2200));
    nodes.add(new Node("Nodo-3", 900));
    nodes.add(new Node("Nodo-4", -600));

    Coordinator coordinator = new Coordinator(master, nodes);
    coordinator.synchronize();
  }
}
