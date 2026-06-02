const fastify = require("fastify")({ logger: true });

import { createClientAsync } from "soap";

fastify.register(require("@fastify/cors"), {
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
});

const SOAP_URL = "http://localhost:1516/WS/Store?wsdl";
let soapClientPromise;

async function getSoapClient() {
  if (!soapClientPromise) {
    soapClientPromise = createClientAsync(SOAP_URL);
  }
  return soapClientPromise;
}

function normalizeItems(result) {
  const raw = result?.return ?? [];
  const list = Array.isArray(raw) ? raw : [raw];
  return list.filter(Boolean).map((item) => ({
    nombre: String(item.nombre ?? ""),
    cantidad: Number.parseInt(item.cantidad ?? 0, 10),
    costo: Number.parseFloat(item.costo ?? 0),
  }));
}

fastify.get("/api/health", async () => ({ ok: true }));

fastify.get("/api/items", async () => {
  const client = await getSoapClient();
  const [result] = await client.getItemsAsync({});
  return normalizeItems(result);
});

fastify.post("/api/items", async (request) => {
  const { nombre, cantidad, costo } = request.body || {};
  const client = await getSoapClient();
  const [result] = await client.addItemAsync({
    arg0: { nombre, cantidad, costo },
  });
  return { ok: String(result?.return) === "true" };
});

fastify.put("/api/items/:nombre", async (request) => {
  const { nombre } = request.params;
  const { cantidad, costo } = request.body || {};
  const client = await getSoapClient();
  const [result] = await client.setItemAsync({
    arg0: nombre,
    arg1: cantidad,
    arg2: costo,
  });
  return { ok: String(result?.return) === "true" };
});

fastify.delete("/api/items/:nombre", async (request) => {
  const { nombre } = request.params;
  const client = await getSoapClient();
  const [result] = await client.deleteItemAsync({
    arg0: nombre,
  });
  return { ok: String(result?.return) === "true" };
});

fastify.post("/api/items/:nombre/buy", async (request) => {
  const { nombre } = request.params;
  const { cantidad } = request.body || {};
  const client = await getSoapClient();
  const [result] = await client.buyItemAsync({
    arg0: nombre,
    arg1: cantidad,
  });
  return { result: result?.return ?? "" };
});

const port = Number.parseInt(process.env.PORT || "3001", 10);
fastify.listen({ port, host: "0.0.0.0" }).catch((err) => {
  fastify.log.error(err);
  process.exit(1);
});
