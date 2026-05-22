package com.lab06.e1.controller;

import com.lab06.e1.model.Book;
import com.lab06.e1.repository.BookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/books")
@CrossOrigin(origins = "*")
public class BookApiController {

    private final BookRepository bookRepository;
    private final Path rootPath = Paths.get("uploads");

    @Autowired
    public BookApiController(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
        try {
            if (!Files.exists(rootPath)) {
                Files.createDirectories(rootPath);
            }
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize folder for upload!", e);
        }
    }

    @GetMapping
    public List<Book> getAllBooks() {
        return bookRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        return bookRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping(consumes = {"multipart/form-data"})
    public ResponseEntity<?> registerBook(
            @RequestParam("title") String title,
            @RequestParam("author") String author,
            @RequestParam("isbn") String isbn,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "imageUrl", required = false) String imageUrl,
            @RequestParam(value = "image", required = false) MultipartFile image) {

        if (title == null || title.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Title is required");
        }
        if (author == null || author.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Author is required");
        }
        if (isbn == null || isbn.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("ISBN is required");
        }

        // Check if ISBN already exists
        if (bookRepository.findByIsbn(isbn.trim()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Book with this ISBN is already registered");
        }

        Book book = new Book();
        book.setTitle(title.trim());
        book.setAuthor(author.trim());
        book.setIsbn(isbn.trim());
        book.setDescription(description != null ? description.trim() : null);

        if (image != null && !image.isEmpty()) {
            try {
                String originalFilename = image.getOriginalFilename();
                String cleanFilename = originalFilename != null ? originalFilename.replaceAll("[^a-zA-Z0-9.-]", "_") : "image";
                String fileName = UUID.randomUUID().toString() + "_" + cleanFilename;
                
                Files.copy(image.getInputStream(), this.rootPath.resolve(fileName));
                book.setImageUrl("/uploads/" + fileName);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Could not upload the image: " + e.getMessage());
            }
        } else if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            book.setImageUrl(imageUrl.trim());
        }

        Book savedBook = bookRepository.save(book);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedBook);
    }

    @PutMapping(value = "/{id}", consumes = {"multipart/form-data"})
    public ResponseEntity<?> updateBook(
            @PathVariable Long id,
            @RequestParam("title") String title,
            @RequestParam("author") String author,
            @RequestParam("isbn") String isbn,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam(value = "imageUrl", required = false) String imageUrl,
            @RequestParam(value = "image", required = false) MultipartFile image) {

        Optional<Book> bookOptional = bookRepository.findById(id);
        if (bookOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Book book = bookOptional.get();

        if (title == null || title.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Title is required");
        }
        if (author == null || author.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("Author is required");
        }
        if (isbn == null || isbn.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("ISBN is required");
        }

        // Check if ISBN is taken by another book
        Optional<Book> existingIsbn = bookRepository.findByIsbn(isbn.trim());
        if (existingIsbn.isPresent() && !existingIsbn.get().getId().equals(id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Book with this ISBN is already registered");
        }

        book.setTitle(title.trim());
        book.setAuthor(author.trim());
        book.setIsbn(isbn.trim());
        book.setDescription(description != null ? description.trim() : null);

        if (image != null && !image.isEmpty()) {
            // Case A: New file uploaded. Remove old disk image if there was one.
            deleteLocalImage(book.getImageUrl());
            try {
                String originalFilename = image.getOriginalFilename();
                String cleanFilename = originalFilename != null ? originalFilename.replaceAll("[^a-zA-Z0-9.-]", "_") : "image";
                String fileName = UUID.randomUUID().toString() + "_" + cleanFilename;
                
                Files.copy(image.getInputStream(), this.rootPath.resolve(fileName));
                book.setImageUrl("/uploads/" + fileName);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Could not upload the image: " + e.getMessage());
            }
        } else if (imageUrl != null) {
            String trimmedUrl = imageUrl.trim();
            if (trimmedUrl.isEmpty()) {
                // User explicitly cleared the cover image
                deleteLocalImage(book.getImageUrl());
                book.setImageUrl(null);
            } else if (!trimmedUrl.equals(book.getImageUrl())) {
                // Case B: A new public URL is specified, remove old local image
                deleteLocalImage(book.getImageUrl());
                book.setImageUrl(trimmedUrl);
            }
        }

        Book updatedBook = bookRepository.save(book);
        return ResponseEntity.ok(updatedBook);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBook(@PathVariable Long id) {
        Optional<Book> bookOptional = bookRepository.findById(id);
        if (bookOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Book book = bookOptional.get();
        deleteLocalImage(book.getImageUrl());
        bookRepository.delete(book);
        return ResponseEntity.ok().body("Book deleted successfully");
    }

    private void deleteLocalImage(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/uploads/")) {
            String filename = imageUrl.substring("/uploads/".length());
            try {
                Path filePath = this.rootPath.resolve(filename);
                Files.deleteIfExists(filePath);
            } catch (IOException e) {
                System.err.println("Could not delete file " + filename + ": " + e.getMessage());
            }
        }
    }
}
