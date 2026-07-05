import { Book, CreateBookInput, UpdateBookInput } from "./types";
import seedData from "../seed/data.json";

function loadSeed(): Book[] {
  return seedData.map((item: any, index: number) => ({
    id: String(index + 1),
    title: item.title,
    author: item.author,
    isbn: item.isbn,
    description: item.description,
    imageUrl: item.image_url,
  }));
}

let books: Book[] = loadSeed();
let nextId = books.length + 1;

export const resolvers = {
  Query: {
    books: () => books,
    book: (_: unknown, { id }: { id: string }) =>
      books.find((b) => b.id === id) || null,
  },

  Mutation: {
    createBook: (
      _: unknown,
      { input }: { input: CreateBookInput }
    ): Book => {
      if (books.some((b) => b.isbn === input.isbn)) {
        throw new Error("Ya existe un libro con ese ISBN");
      }

      const newBook: Book = {
        id: String(nextId++),
        title: input.title,
        author: input.author,
        isbn: input.isbn,
        description: input.description,
        imageUrl: input.imageUrl,
      };

      books.push(newBook);
      return newBook;
    },

    updateBook: (
      _: unknown,
      { id, input }: { id: string; input: UpdateBookInput }
    ): Book | null => {
      const index = books.findIndex((b) => b.id === id);
      if (index === -1) return null;

      if (input.isbn && input.isbn !== books[index].isbn) {
        if (books.some((b) => b.isbn === input.isbn)) {
          throw new Error("Ya existe un libro con ese ISBN");
        }
      }

      books[index] = { ...books[index], ...input };
      return books[index];
    },

    deleteBook: (_: unknown, { id }: { id: string }): boolean => {
      const index = books.findIndex((b) => b.id === id);
      if (index === -1) return false;

      books.splice(index, 1);
      return true;
    },
  },
};
