import java.util.ArrayList;
import java.util.List;
import java.util.Random;

class CristianAlgorithm {

  static class TimeServer {

    private final long serverOffsetMillis;

    TimeServer(long serverOffsetMillis) {
      this.serverOffsetMillis = serverOffsetMillis;
    }

    synchronized long getCurrentTimeMillis() {
      return System.currentTimeMillis() + serverOffsetMillis;
    }
  }

  static class ClientNode implements Runnable {

    private final String name;
    private final TimeServer server;
    private final Random random;
    private long localOffsetMillis;

    ClientNode(String name, TimeServer server, long initialOffsetMillis) {
      this.name = name;
      this.server = server;
      this.localOffsetMillis = initialOffsetMillis;
      this.random = new Random();
    }

    synchronized long localTimeMillis() {
      return System.currentTimeMillis() + localOffsetMillis;
    }

    synchronized void adjustClock(long adjustmentMillis) {
      localOffsetMillis += adjustmentMillis;
    }

    private void simulateNetworkDelay() {
      try {
        Thread.sleep(50 + random.nextInt(150));
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }

    void synchronizeClock() {
      long beforeSync = localTimeMillis();

      long requestTime = System.currentTimeMillis();
      simulateNetworkDelay();
      long serverTime = server.getCurrentTimeMillis();
      simulateNetworkDelay();
      long responseTime = System.currentTimeMillis();

      long roundTripTime = responseTime - requestTime;
      long estimatedServerTime = serverTime + (roundTripTime / 2);
      long adjustment = estimatedServerTime - localTimeMillis();

      adjustClock(adjustment);
      long afterSync = localTimeMillis();

      System.out.println(
        name +
          " | Antes: " +
          beforeSync +
          " | RTT: " +
          roundTripTime +
          " ms" +
          " | Ajuste: " +
          adjustment +
          " ms" +
          " | Despues: " +
          afterSync
      );
    }

    @Override
    public void run() {
      synchronizeClock();
    }
  }

  public static void main(String[] args) {
    TimeServer server = new TimeServer(0);
    List<Thread> threads = new ArrayList<>();

    ClientNode[] clients = new ClientNode[] {
      new ClientNode("Cliente-1", server, 1200),
      new ClientNode("Cliente-2", server, -900),
      new ClientNode("Cliente-3", server, 2000),
      new ClientNode("Cliente-4", server, -1500),
    };

    for (ClientNode client : clients) {
      Thread thread = new Thread(client);
      threads.add(thread);
      thread.start();
    }

    for (Thread thread : threads) {
      try {
        thread.join();
      } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
      }
    }

    System.out.println("Sincronizacion de Cristian completada.");
  }
}
