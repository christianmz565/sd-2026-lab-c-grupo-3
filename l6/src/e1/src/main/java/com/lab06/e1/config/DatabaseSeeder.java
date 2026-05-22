package com.lab06.e1.config;

import com.lab06.e1.model.Book;
import com.lab06.e1.repository.BookRepository;
import java.io.File;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

@Component
public class DatabaseSeeder implements CommandLineRunner {

  private final BookRepository bookRepository;
  private final ObjectMapper objectMapper;

  @Autowired
  public DatabaseSeeder(BookRepository bookRepository, ObjectMapper objectMapper) {
    this.bookRepository = bookRepository;
    this.objectMapper = objectMapper;
  }

  @Override
  public void run(String... args) throws Exception {
    File seedFile = new File("seed/data.json");

    if (!seedFile.exists()) {
      System.out.println(
        "Seeder: seed/data.json file not found at " +
          seedFile.getAbsolutePath() +
          ". Skipping database seeding."
      );
      return;
    }

    System.out.println(
      "Seeder: Found seed file at " + seedFile.getAbsolutePath() + ". Starting seeding process..."
    );

    try {
      List<Map<String, Object>> seedBooks = objectMapper.readValue(
        seedFile,
        new TypeReference<List<Map<String, Object>>>() {}
      );

      int seededCount = 0;
      for (Map<String, Object> map : seedBooks) {
        String isbn = (String) map.get("isbn");
        if (isbn != null && !isbn.trim().isEmpty()) {
          isbn = isbn.trim();
          if (bookRepository.findByIsbn(isbn).isEmpty()) {
            Book book = new Book();
            book.setIsbn(isbn);
            book.setTitle(((String) map.get("title")).trim());
            book.setAuthor(((String) map.get("author")).trim());

            String description = (String) map.get("description");
            book.setDescription(description != null ? description.trim() : null);

            String imageUrl = (String) map.get("image_url");
            book.setImageUrl(imageUrl != null ? imageUrl.trim() : null);

            bookRepository.save(book);
            seededCount++;
          }
        }
      }

      System.out.println(
        "Seeder: Seeding process finished. Added " + seededCount + " new books to the database."
      );
    } catch (Exception e) {
      System.err.println("Seeder: Error occurred during seeding process: " + e.getMessage());
      e.printStackTrace();
    }
  }
}
