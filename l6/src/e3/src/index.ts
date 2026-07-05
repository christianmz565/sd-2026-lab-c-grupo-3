import { Hono } from "hono";
import { createYoga } from "graphql-yoga";
import { createSchema } from "graphql-yoga";
import { typeDefs } from "./schema";
import { resolvers } from "./resolvers";

const app = new Hono();
const port = Number(process.env.PORT) || 3000;

const yoga = createYoga({
  schema: createSchema({ typeDefs, resolvers }),
  graphqlEndpoint: "/graphql",
});

app.on(["GET", "POST", "OPTIONS"], "/graphql", async (c) => {
  const response = await yoga.handle(c.req.raw, {});
  return new Response(response.body, {
    status: response.status,
    headers: Object.fromEntries(response.headers.entries()),
  });
});

app.get("/*", async (c) => {
  const path = c.req.path === "/" ? "/index.html" : c.req.path;
  const file = Bun.file(`./public${path}`);
  if (await file.exists()) {
    return new Response(file);
  }
  return c.notFound();
});

console.log(`Servidor GraphQL+Hono corriendo en http://localhost:${port}`);
console.log(`GraphQL Playground: http://localhost:${port}/graphql`);

export default {
  port,
  fetch: app.fetch,
};
