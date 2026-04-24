import java.util.ArrayList;
import java.util.List;

public class LamportClock {

  // START-SNIPPET,clock-rules
  private int clock;

  public LamportClock() {
    this.clock = 0;
  }

  public synchronized int tick() {
    this.clock++;
    return this.clock;
  }

  public synchronized void update(int receivedTime) {
    this.clock = Math.max(this.clock, receivedTime) + 1;
  }
  // END-SNIPPET

  public int getTime() {
    return this.clock;
  }

  public static void main(String[] args) {
    List<Thread> threads = new ArrayList<>();
    LamportClock clock = new LamportClock();
    for (int i = 0; i < 5; i++) {
      Thread thread = new Thread(
        new Runnable() {
          @Override
          public void run() {
            // START-SNIPPET,event-core
            int time = clock.tick();

            System.out.println(
              "Thread " +
                Thread.currentThread().threadId() +
                " created event with Lamport time " +
                time
            );
            try {
              Thread.sleep((long) (Math.random() * 1000));
            } catch (InterruptedException e) {
              e.printStackTrace();
            }

            int receivedTime = clock.tick();
            System.out.println(
              "Thread " +
                Thread.currentThread().threadId() +
                " received event with Lamport time " +
                receivedTime
            );
            clock.update(receivedTime);
            // END-SNIPPET
          }
        }
      );
      threads.add(thread);
      thread.start();
    }
    // START-SNIPPET,join-and-final-time
    for (Thread thread : threads) {
      try {
        thread.join();
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    System.out.println("Final Lamport time: " + clock.getTime());
    // END-SNIPPET
  }
}
