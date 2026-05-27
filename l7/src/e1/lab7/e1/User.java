package lab7.e1;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class User implements Serializable {
  private static final long serialVersionUID = 1L;

  // START-SNIPPET,model
  private String name;
  private String username;

  private static final List<User> USERS = new ArrayList<>(Arrays.asList(
      new User("Rosa Marfil", "rmarfil"),
      new User("Pepito Grillo", "pgrillo"),
      new User("Manuela Rio", "mrio")
  ));

  public User() {
  }

  public User(String name, String username) {
    this.name = name;
    this.username = username;
  }

  public static List<User> getUsers() {
    return USERS;
  }

  public String getName() {
    return name;
  }

  public String getUsername() {
    return username;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void setUsername(String username) {
    this.username = username;
  }
  // END-SNIPPET

  @Override
  public String toString() {
    return "User{name='" + name + "', username='" + username + "'}";
  }
}
