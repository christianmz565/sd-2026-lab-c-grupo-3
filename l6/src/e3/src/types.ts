export interface Book {
  id: string;
  title: string;
  author: string;
  isbn: string;
  description?: string;
  imageUrl?: string;
}

export interface CreateBookInput {
  title: string;
  author: string;
  isbn: string;
  description?: string;
  imageUrl?: string;
}

export interface UpdateBookInput {
  title?: string;
  author?: string;
  isbn?: string;
  description?: string;
  imageUrl?: string;
}
