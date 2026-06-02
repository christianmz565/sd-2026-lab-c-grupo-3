const fastify = require("fastify")({ logger: true });
import { createClientAsync } from "soap";

// START-SNIPPET,proxy
const SOAP_URL = "http://localhost:1516/WS/Store?wsdl";

fastify.get("/api/items", async () => {
  const client = await createClientAsync(SOAP_URL);
  const [result] = await client.getItemsAsync({});
  return normalizeItems(result);
});

fastify.post("/api/items/:nombre/buy", async (request) => {
  const { nombre } = request.params;
  const { cantidad } = request.body || {};
  const client = await createClientAsync(SOAP_URL);
  const [result] = await client.buyItemAsync({
    arg0: nombre,
    arg1: cantidad,
  });
  return { result: result?.return ?? "" };
});
// END-SNIPPET
