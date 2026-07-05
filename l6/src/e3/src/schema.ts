export const typeDefs = `
  type Book {
    id: ID!
    title: String!
    author: String!
    isbn: String!
    description: String
    imageUrl: String
  }

  type Query {
    books: [Book!]!
    book(id: ID!): Book
  }

  type Mutation {
    createBook(input: CreateBookInput!): Book!
    updateBook(id: ID!, input: UpdateBookInput!): Book
    deleteBook(id: ID!): Boolean
  }

  input CreateBookInput {
    title: String!
    author: String!
    isbn: String!
    description: String
    imageUrl: String
  }

  input UpdateBookInput {
    title: String
    author: String
    isbn: String
    description: String
    imageUrl: String
  }
`;
