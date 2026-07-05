# Ejercicio 3: GraphQL API - Yoga + Hono (Bun)

## Descripción

API GraphQL para gestión de libros utilizando **GraphQL Yoga** + **Hono** como framework HTTP, ejecutada sobre **Bun**.

## Tecnologías

- **Runtime**: Bun
- **HTTP Framework**: Hono
- **GraphQL Server**: graphql-yoga
- **Lenguaje**: TypeScript

## Ejecución

```bash
# Instalar dependencias
bun install

# Ejecutar servidor
bun run dev
```

El servidor inicia en `http://localhost:3000`

- **GraphQL Playground**: `http://localhost:3000/graphql`
- **Cliente HTML**: `http://localhost:3000/`

## Endpoints

| Método | Ruta      | Descripción         |
| ------ | --------- | ------------------- |
| POST   | `/graphql` | Endpoint GraphQL    |
| GET    | `/`        | Cliente HTML        |

## Operaciones GraphQL

### Queries

```graphql
# Listar todos los libros
query {
  books {
    id
    title
    author
    isbn
    description
    imageUrl
  }
}

# Buscar por ID
query {
  book(id: "1") {
    id
    title
    author
  }
}
```

### Mutations

```graphql
# Crear libro
mutation {
  createBook(input: {
    title: "Nuevo Libro"
    author: "Autor"
    isbn: "978-1234567890"
  }) {
    id
    title
  }
}

# Actualizar libro
mutation {
  updateBook(id: "1", input: {
    title: "Título Actualizado"
  }) {
    id
    title
  }
}

# Eliminar libro
mutation {
  deleteBook(id: "1")
}
```

## Comparativa con Ejercicios Anteriores

| Característica | E1: Spring Boot | E2: Flask | E3: Yoga+Hono |
| -------------- | --------------- | --------- | ------------- |
| Lenguaje | Java | Python | TypeScript |
| Runtime | JVM | CPython | Bun |
| Paradigma | RESTful | RESTful | GraphQL |
| Endpoints | Múltiples | Múltiples | Único (`/graphql`) |
| Over-fetching | Sí | Sí | No |
| Under-fetching | Sí | Sí | No |
| Documentación | Swagger externa | Externa | Introspection |
