import { Slide } from "@revealjs/react";
import { Badge } from "@/shared/badge";
import { colors as C } from "@/shared/colors";
import {
  FeatureCard,
  FeatureCardCompact,
  FeatureCardCompactSmall,
} from "@/shared/feature-cards";
import { NumberedItem } from "@/shared/numbered-item";
import { PresentationDeck } from "@/shared/presentation-deck";
import { SlideWrap } from "@/shared/slide-wrap";
import { StatCard } from "@/shared/stat-cards";
import { ThanksSlide } from "@/shared/thanks-slide";

const baseUrl = import.meta.env.BASE_URL.replace(/\/$/, "");

const IMG_COMPARISON_FLOW = `${baseUrl}/rest-vs-graphql/comparison-flow.png`;
const IMG_REST_ARCH = `${baseUrl}/rest-vs-graphql/rest-architecture.png`;
const IMG_GRAPHQL_ARCH = `${baseUrl}/rest-vs-graphql/graphql-architecture.png`;
const IMG_E1_API = `${baseUrl}/rest-vs-graphql/e1-rest-api.png`;
const IMG_E3_API = `${baseUrl}/rest-vs-graphql/e3-graphql-api.png`;
const IMG_E3_CONSOLE = `${baseUrl}/rest-vs-graphql/e3-graphql-console.png`;

/* ─── PORTADA ─── */
function Cover() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Sistemas Distribuidos · Grupo C"
        variant="decorated"
        className="justify-center flex flex-col items-center h-full py-8 text-center"
      >
        <h1 className="mt-2 text-7xl!">
          <span style={{ color: C.teal }}>REST</span>{" "}
          <span className="text-gray-500 font-light">vs</span>{" "}
          <span style={{ color: C.teal }}>GraphQL</span>
        </h1>
        <p className="mt-3 text-2xl text-gray-400 max-w-3xl text-pretty">
          Diseño, implementación y comparación de rendimiento de servicios
          distribuidos
        </p>
        <div className="mt-6">
          <p className="text-xl font-semibold uppercase tracking-[0.2em] text-gray-500">
            Integrantes
          </p>
          <p className="mt-1.5 text-2xl text-gray-300 font-light max-w-4xl text-pretty">
            Bedregal Pérez, Daniel · Jara Mamani, Mariel Alisson · Mestas
            Zegarra, Christian Raúl · Noa Camino, Yenaro Joel · Sequeiros
            Condori, Luis Gustavo
          </p>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── OBJETIVO ─── */
function Objetivo() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Objetivo"
        variant="decorated"
        className="justify-center flex flex-col gap-6 w-full mx-auto"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-5xl! text-balance max-w-4xl text-center">
            Comparar{" "}
            <span style={{ color: C.teal }}>REST</span> y{" "}
            <span style={{ color: C.teal }}>GraphQL</span> en un mismo dominio
          </h1>
          <p className="mt-2 text-xl text-gray-400 max-w-3xl text-center text-pretty">
            Implementar el mismo catálogo de libros con tres stacks tecnológicos
            distintos y medir rendimiento bajo carga real.
          </p>
        </div>

        <div className="grid grid-cols-3 gap-3">
          {[
            {
              l: "Mismo dominio",
              d: "Catálogo de libros con operaciones CRUD completas en cada implementación.",
            },
            {
              l: "Carga real",
              d: "Pruebas con k6 escalando de 10 a 100 usuarios virtuales durante 90 segundos.",
            },
            {
              l: "Métricas clave",
              d: "Latencia, throughput, tamaño de payload, estabilidad y escalabilidad.",
            },
          ].map((i) => (
            <FeatureCard
              key={i.l}
              label={i.l}
              description={i.d}
              color={C.teal}
              variant="decorated"
            />
          ))}
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── ENTORNO DE PRUEBA ─── */
function EntornoPrueba() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Metodología"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Entorno de <span style={{ color: C.teal }}>prueba</span>
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <div className="flex flex-col gap-3">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Implementaciones
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="pb-2 text-lg font-semibold text-gray-400">
                      Componente
                    </th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>
                      REST (E1)
                    </th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>
                      GraphQL (E3)
                    </th>
                  </tr>
                </thead>
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1.5">Runtime</td>
                    <td className="py-1.5">Java 21</td>
                    <td className="py-1.5">Bun 1.3</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5">Framework</td>
                    <td className="py-1.5">Spring Boot 3</td>
                    <td className="py-1.5">Hono + graphql-yoga</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5">Base de datos</td>
                    <td className="py-1.5">SQLite (JPA)</td>
                    <td className="py-1.5">Array en memoria</td>
                  </tr>
                  <tr>
                    <td className="py-1.5">Datos semilla</td>
                    <td className="py-1.5">15 libros</td>
                    <td className="py-1.5">15 libros</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div className="flex flex-col gap-3">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Configuración k6
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Herramienta</td>
                    <td className="py-1.5">k6 (Grafana Labs)</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Duración</td>
                    <td className="py-1.5">90s por prueba</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Ramp-up</td>
                    <td className="py-1.5">10s → 10 VUs</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Estado estable</td>
                    <td className="py-1.5">30s @ 50 VUs</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Carga pico</td>
                    <td className="py-1.5">10s @ 100 VUs</td>
                  </tr>
                  <tr>
                    <td className="py-1.5 font-semibold text-gray-400">Ramp-down</td>
                    <td className="py-1.5">10s → 0 VUs</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── FLUJO DE COMPARACIÓN ─── */
function FlujoComparacion() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Metodología · Flujo"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="flex flex-col items-center gap-4">
          <h1 className="text-4xl! font-semibold tracking-tight text-center">
            Flujo de{" "}
            <span style={{ color: C.teal }}>comparación</span>
          </h1>
          <img
            src={IMG_COMPARISON_FLOW}
            alt="Diagrama de flujo de la comparación REST vs GraphQL"
            className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[480px]"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── ARQUITECTURA REST ─── */
function ArquitecturaRest() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Arquitectura · REST API"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left px-4">
          <div className="flex flex-col gap-4">
            <h1 className="text-4xl! font-semibold tracking-tight">
              REST API{" "}
              <span style={{ color: C.teal }}>(Spring Boot)</span>
            </h1>
            <div className="flex flex-col gap-2">
              <NumberedItem
                num="1"
                title="Endpoints múltiples"
                description="/api/books, /api/books/{id} — cada recurso tiene su URI dedicada."
                color={C.teal}
              />
              <NumberedItem
                num="2"
                title="HTTP semántico"
                description="GET, POST, PUT, DELETE mapean directamente a operaciones CRUD."
                color={C.teal}
              />
              <NumberedItem
                num="3"
                title="Persistencia JPA"
                description="SQLite con Hibernate; entidades mapeadas con anotaciones Jakarta."
                color={C.teal}
              />
            </div>
            <div className="flex flex-wrap gap-2">
              {["Java 21", "Spring Boot 3", "SQLite", "JPA"].map((t) => (
                <Badge key={t} label={t} color={C.teal} />
              ))}
            </div>
          </div>
          <div className="flex items-center justify-center">
            <img
              src={IMG_REST_ARCH}
              alt="Arquitectura de la REST API"
              className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[420px]"
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── ARQUITECTURA GRAPHQL ─── */
function ArquitecturaGraphql() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Arquitectura · GraphQL API"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left px-4">
          <div className="flex items-center justify-center">
            <img
              src={IMG_GRAPHQL_ARCH}
              alt="Arquitectura de la GraphQL API"
              className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[420px]"
            />
          </div>
          <div className="flex flex-col gap-4">
            <h1 className="text-4xl! font-semibold tracking-tight">
              GraphQL API{" "}
              <span style={{ color: C.teal }}>(Bun + Yoga)</span>
            </h1>
            <div className="flex flex-col gap-2">
              <NumberedItem
                num="1"
                title="Endpoint único"
                description="/graphql — un solo punto de entrada para todas las operaciones."
                color={C.teal}
              />
              <NumberedItem
                num="2"
                title="Schema tipado"
                description="SDL define tipos, queries y mutations con validación automática."
                color={C.teal}
              />
              <NumberedItem
                num="3"
                title="Resolvers"
                description="Funciones que resuelven cada campo; datos en array en memoria."
                color={C.teal}
              />
            </div>
            <div className="flex flex-wrap gap-2">
              {["TypeScript", "Bun", "graphql-yoga", "Hono"].map((t) => (
                <Badge key={t} label={t} color={C.teal} />
              ))}
            </div>
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── EVIDENCIAS: REST API ─── */
function EvidenciaRest() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Evidencias · REST API"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="flex flex-col items-center gap-4">
          <h1 className="text-4xl! font-semibold tracking-tight text-center">
            REST API en{" "}
            <span style={{ color: C.teal }}>acción</span>
          </h1>
          <img
            src={IMG_E1_API}
            alt="Interfaz de la REST API - Spring Boot"
            className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[460px]"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── EVIDENCIAS: GRAPHQL API ─── */
function EvidenciaGraphql() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Evidencias · GraphQL API"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center px-4">
          <div className="flex items-center justify-center">
            <img
              src={IMG_E3_API}
              alt="Interfaz de la GraphQL API"
              className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[400px]"
            />
          </div>
          <div className="flex items-center justify-center">
            <img
              src={IMG_E3_CONSOLE}
              alt="Consola GraphQL Playground"
              className="object-contain rounded-xl bg-white/95 p-2 shadow-md max-h-[400px]"
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── TAMAÑO DE PAYLOAD ─── */
function TamanoPayload() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Payload"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          GraphQL reduce el payload{" "}
          <span style={{ color: C.teal }}>78%</span>
        </h1>
        <div className="grid grid-cols-3 gap-4">
          <StatCard
            value="4,654 B"
            label="REST (todos los campos)"
            color={C.teal}
            variant="decorated"
          />
          <StatCard
            value="4,703 B"
            label="GraphQL (todos los campos)"
            color={C.teal}
            variant="decorated"
          />
          <StatCard
            value="1,019 B"
            label="GraphQL (selective: title+author)"
            color={C.green}
            variant="decorated"
          />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <FeatureCardCompact
            label="Selectividad"
            description="El cliente elige exactamente qué campos necesita; no paga por datos innecesarios."
            color={C.teal}
            variant="decorated"
          />
          <FeatureCardCompact
            label="Impacto móvil"
            description="78% menos datos = menor latencia y uso de datos en conexiones limitadas."
            color={C.teal}
            variant="decorated"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── RENDIMIENTO DE LECTURA (GET ALL) ─── */
function RendimientoLectura() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Lectura GET All"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          Lectura de{" "}
          <span style={{ color: C.teal }}>todos los libros</span> (100 VUs)
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Comparación directa
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="pb-2 text-lg font-semibold text-gray-400">Métrica</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>GraphQL</th>
                    <th className="pb-2 text-lg font-semibold text-green-400">Δ</th>
                  </tr>
                </thead>
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1">Latencia avg</td>
                    <td className="py-1">2.73ms</td>
                    <td className="py-1">2.24ms</td>
                    <td className="py-1 text-green-400 font-semibold">-17.9%</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1">P95</td>
                    <td className="py-1">4.86ms</td>
                    <td className="py-1">4.62ms</td>
                    <td className="py-1 text-green-400 font-semibold">-4.9%</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1">Max</td>
                    <td className="py-1">26.82ms</td>
                    <td className="py-1">23.67ms</td>
                    <td className="py-1 text-green-400 font-semibold">-11.7%</td>
                  </tr>
                  <tr>
                    <td className="py-1">Throughput</td>
                    <td className="py-1">449 RPS</td>
                    <td className="py-1">453 RPS</td>
                    <td className="py-1 text-green-400 font-semibold">+0.8%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Datos recibidos
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">REST</td>
                    <td className="py-1.5">196.3 MB</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">GraphQL</td>
                    <td className="py-1.5">196.8 MB</td>
                  </tr>
                  <tr>
                    <td className="py-1.5 font-semibold text-gray-400">Error rate</td>
                    <td className="py-1.5">0% ambos</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <FeatureCardCompactSmall
              label="Conclusión parcial"
              description="GraphQL es ~18% más rápido en latencia promedio; throughput similar."
              color={C.teal}
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── LECTURA INDIVIDUAL ─── */
function LecturaIndividual() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Lectura GET One"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          Un solo{" "}
          <span style={{ color: C.teal }}>libro</span> (100 VUs)
        </h1>
        <div className="grid grid-cols-2 gap-4">
          <div className="rounded-xl border border-white/10 bg-white/5 p-4">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="pb-2 text-lg font-semibold text-gray-400">Métrica</th>
                  <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST</th>
                  <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>GraphQL</th>
                  <th className="pb-2 text-lg font-semibold text-green-400">Δ</th>
                </tr>
              </thead>
              <tbody className="text-lg text-gray-300">
                <tr className="border-b border-white/5">
                  <td className="py-1">Latencia avg</td>
                  <td className="py-1">2.46ms</td>
                  <td className="py-1">2.08ms</td>
                  <td className="py-1 text-green-400 font-semibold">-15.4%</td>
                </tr>
                <tr className="border-b border-white/5">
                  <td className="py-1">P95</td>
                  <td className="py-1">4.52ms</td>
                  <td className="py-1">4.19ms</td>
                  <td className="py-1 text-green-400 font-semibold">-7.3%</td>
                </tr>
                <tr className="border-b border-white/5">
                  <td className="py-1">Max</td>
                  <td className="py-1">22.38ms</td>
                  <td className="py-1">18.52ms</td>
                  <td className="py-1 text-green-400 font-semibold">-17.2%</td>
                </tr>
                <tr>
                  <td className="py-1">Throughput</td>
                  <td className="py-1">451 RPS</td>
                  <td className="py-1">455 RPS</td>
                  <td className="py-1 text-green-400 font-semibold">+0.9%</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div className="flex flex-col gap-3">
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1.5 font-semibold text-gray-400">Datos recibidos REST</td>
                    <td className="py-1.5">21.3 MB</td>
                  </tr>
                  <tr>
                    <td className="py-1.5 font-semibold text-gray-400">Datos recibidos GraphQL</td>
                    <td className="py-1.5">18.6 MB (-12.7%)</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <FeatureCardCompactSmall
              label="Ventaja GraphQL"
              description="15.4% menos latencia y 12.7% menos datos recibidos en consultas individuales."
              color={C.teal}
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── CAMPOS SELECTIVOS ─── */
function CamposSelectivos() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Campos Selectivos"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Selectividad:{" "}
          <span style={{ color: C.teal }}>solo pido lo que necesito</span>
        </h1>
        <div className="grid grid-cols-3 gap-4">
          <StatCard
            value="-76.2%"
            label="Datos recibidos vs REST"
            color={C.green}
            variant="decorated"
          />
          <StatCard
            value="-11.8%"
            label="Latencia promedio vs REST"
            color={C.green}
            variant="decorated"
          />
          <StatCard
            value="454 RPS"
            label="Throughput (similar a REST)"
            color={C.teal}
            variant="decorated"
          />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <FeatureCardCompact
            label="REST: todo o nada"
            description="El cliente recibe todos los campos del libro (id, title, author, isbn, description, imageUrl) siempre."
            color={C.teal}
            variant="decorated"
          />
          <FeatureCardCompact
            label="GraphQL: selectivo"
            description='El cliente define: query { books { title author } } — recibe solo 2 campos de 6.'
            color={C.green}
            variant="decorated"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── RENDIMIENTO DE ESCRITURA ─── */
function RendimientoEscritura() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Escritura POST"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          Creación de{" "}
          <span style={{ color: C.teal }}>libros</span> (20 VUs)
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <div className="rounded-xl border border-white/10 bg-white/5 p-4">
            <table className="w-full text-left">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="pb-2 text-lg font-semibold text-gray-400">Métrica</th>
                  <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST</th>
                  <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>GraphQL</th>
                  <th className="pb-2 text-lg font-semibold text-amber-400">Δ</th>
                </tr>
              </thead>
              <tbody className="text-lg text-gray-300">
                <tr className="border-b border-white/5">
                  <td className="py-1">Latencia avg</td>
                  <td className="py-1">1.69ms</td>
                  <td className="py-1">2.34ms</td>
                  <td className="py-1 text-amber-400 font-semibold">+38.5%</td>
                </tr>
                <tr className="border-b border-white/5">
                  <td className="py-1">P95</td>
                  <td className="py-1">2.69ms</td>
                  <td className="py-1">3.86ms</td>
                  <td className="py-1 text-amber-400 font-semibold">+43.5%</td>
                </tr>
                <tr className="border-b border-white/5">
                  <td className="py-1">Max</td>
                  <td className="py-1">31.22ms</td>
                  <td className="py-1">7.35ms</td>
                  <td className="py-1 text-green-400 font-semibold">-76.5%</td>
                </tr>
                <tr>
                  <td className="py-1">Throughput</td>
                  <td className="py-1">48.4 RPS</td>
                  <td className="py-1">48.4 RPS</td>
                  <td className="py-1 text-gray-400">0%</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div className="flex flex-col gap-3">
            <FeatureCardCompact
              label="REST: menor promedio"
              description="1.69ms vs 2.34ms — la sobrecarga del query GraphQL impacta en escritura."
              color={C.teal}
              variant="decorated"
            />
            <FeatureCardCompact
              label="GraphQL: más consistente"
              description="Max 7.35ms vs 31.22ms — GraphQL evita picos extremos bajo carga concurrente."
              color={C.green}
              variant="decorated"
            />
            <FeatureCardCompactSmall
              label="Error rate"
              description="1% en ambos — esperado por restricciones de unicidad de ISBN."
              color={C.teal}
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── ESTABILIDAD ─── */
function Estabilidad() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Resultados · Estabilidad"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Consistencia de{" "}
          <span style={{ color: C.teal }}>latencia</span>
        </h1>
        <p className="text-xl text-gray-400 text-center max-w-3xl mx-auto text-pretty">
          Ratio P95/Max — menor ratio indica latencia más predecible y estable.
        </p>
        <div className="grid grid-cols-3 gap-4">
          {[
            { op: "GET All", rest: "5.5x", graphql: "5.2x", winner: "graphql" },
            { op: "GET One", rest: "4.95x", graphql: "4.42x", winner: "graphql" },
            { op: "POST Create", rest: "11.6x", graphql: "1.91x", winner: "graphql" },
          ].map((r) => (
            <div
              key={r.op}
              className="rounded-xl border border-white/10 bg-white/5 p-4 flex flex-col gap-2"
            >
              <p className="text-xl font-semibold uppercase tracking-wider text-gray-400">
                {r.op}
              </p>
              <div className="flex items-center justify-between">
                <div className="text-center">
                  <p className="text-3xl font-bold" style={{ color: C.teal }}>
                    {r.rest}
                  </p>
                  <p className="text-sm text-gray-500">REST</p>
                </div>
                <span className="text-2xl text-gray-600">vs</span>
                <div className="text-center">
                  <p
                    className="text-3xl font-bold"
                    style={{ color: r.winner === "graphql" ? C.green : C.teal }}
                  >
                    {r.graphql}
                  </p>
                  <p className="text-sm text-gray-500">GraphQL</p>
                </div>
              </div>
            </div>
          ))}
        </div>
        <FeatureCardCompactSmall
          label="Key insight"
          description="En escritura, GraphQL es 6x más consistente que REST (1.91x vs 11.6x ratio P95/Max)."
          color={C.green}
        />
      </SlideWrap>
    </Slide>
  );
}

/* ─── CACHÉ ─── */
function Cache() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Análisis · Caché"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Caché HTTP:{" "}
          <span style={{ color: C.teal }}>ventaja REST</span>
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <FeatureCard
            label="REST: nativo"
            description="ETag, Cache-Control, CDN support, cache del navegador — todo funciona out-of-the-box con HTTP estándar."
            color={C.green}
            variant="decorated"
          />
          <FeatureCard
            label="GraphQL: requiere setup"
            description="Queries van por POST (no se cachean automáticamente). Persisted queries y CDN requieren configuración adicional."
            color={C.amber}
            variant="decorated"
          />
        </div>
        <div className="rounded-xl border border-white/10 bg-white/5 p-4">
          <table className="w-full text-left">
            <thead>
              <tr className="border-b border-white/10">
                <th className="pb-2 text-lg font-semibold text-gray-400">Aspecto</th>
                <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST</th>
                <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>GraphQL</th>
              </tr>
            </thead>
            <tbody className="text-lg text-gray-300">
              <tr className="border-b border-white/5">
                <td className="py-1">HTTP Caching</td>
                <td className="py-1 text-green-400">Nativo (ETag, Cache-Control)</td>
                <td className="py-1 text-amber-400">Requiere configuración</td>
              </tr>
              <tr className="border-b border-white/5">
                <td className="py-1">CDN Support</td>
                <td className="py-1 text-green-400">Excelente</td>
                <td className="py-1 text-amber-400">Limitado</td>
              </tr>
              <tr>
                <td className="py-1">Browser Cache</td>
                <td className="py-1 text-green-400">Automático</td>
                <td className="py-1 text-amber-400">POST no se cachea</td>
              </tr>
            </tbody>
          </table>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── ESCALABILIDAD ─── */
function Escalabilidad() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Análisis · Escalabilidad"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Escalabilidad bajo{" "}
          <span style={{ color: C.teal }}>carga</span>
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <div className="flex flex-col gap-3">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Throughput por VUs
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="pb-2 text-lg font-semibold text-gray-400">VUs</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST RPS</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>GraphQL RPS</th>
                  </tr>
                </thead>
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1">10</td>
                    <td className="py-1">~50</td>
                    <td className="py-1">~50</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1">50</td>
                    <td className="py-1">~450</td>
                    <td className="py-1">~450</td>
                  </tr>
                  <tr>
                    <td className="py-1">100</td>
                    <td className="py-1">~450</td>
                    <td className="py-1">~450</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div className="flex flex-col gap-3">
            <h2 className="text-2xl font-semibold uppercase tracking-wider text-gray-400">
              Transferencia de datos
            </h2>
            <div className="rounded-xl border border-white/10 bg-white/5 p-4">
              <table className="w-full text-left">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="pb-2 text-lg font-semibold text-gray-400">Libros</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.teal }}>REST</th>
                    <th className="pb-2 text-lg font-semibold" style={{ color: C.green }}>GraphQL (selectivo)</th>
                    <th className="pb-2 text-lg font-semibold text-green-400">Ahorro</th>
                  </tr>
                </thead>
                <tbody className="text-lg text-gray-300">
                  <tr className="border-b border-white/5">
                    <td className="py-1">15</td>
                    <td className="py-1">4,654 B</td>
                    <td className="py-1">1,019 B</td>
                    <td className="py-1 text-green-400">78%</td>
                  </tr>
                  <tr className="border-b border-white/5">
                    <td className="py-1">100</td>
                    <td className="py-1">~31,000 B</td>
                    <td className="py-1">~6,800 B</td>
                    <td className="py-1 text-green-400">78%</td>
                  </tr>
                  <tr>
                    <td className="py-1">1000</td>
                    <td className="py-1">~310,000 B</td>
                    <td className="py-1">~68,000 B</td>
                    <td className="py-1 text-green-400">78%</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <FeatureCardCompactSmall
          label="Bottleneck"
          description="Ambas APIs escalan igual; el cuello de botella es la capa de base de datos, no el protocolo."
          color={C.teal}
        />
      </SlideWrap>
    </Slide>
  );
}

/* ─── CUÁNDO USAR CADA UNO ─── */
function CuandoUsar() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Recomendaciones"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          ¿Cuándo usar{" "}
          <span style={{ color: C.teal }}>cada uno</span>?
        </h1>
        <div className="grid grid-cols-2 gap-6">
          <div className="rounded-xl border border-green-500/30 bg-green-500/5 p-5 flex flex-col gap-3">
            <h2 className="text-3xl font-semibold" style={{ color: C.green }}>
              REST
            </h2>
            <div className="flex flex-col gap-2">
              {[
                "CRUD simple y directo",
                "Caché HTTP es crítico",
                "APIs públicas",
                "Equipo familiar con REST",
                "Payload ya es pequeño",
              ].map((item) => (
                <div key={item} className="flex items-center gap-2">
                  <span className="text-green-400 text-xl">✓</span>
                  <span className="text-xl text-gray-300">{item}</span>
                </div>
              ))}
            </div>
          </div>
          <div className="rounded-xl border border-teal-500/30 bg-teal-500/5 p-5 flex flex-col gap-3">
            <h2 className="text-3xl font-semibold" style={{ color: C.teal }}>
              GraphQL
            </h2>
            <div className="flex flex-col gap-2">
              {[
                "Clientes móviles (bandwidth)",
                "Datos complejos / relacionados",
                "Iteración rápida del frontend",
                "Diferentes clientes, distintos datos",
                "Aplicaciones en tiempo real",
              ].map((item) => (
                <div key={item} className="flex items-center gap-2">
                  <span className="text-teal-400 text-xl">✓</span>
                  <span className="text-xl text-gray-300">{item}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── CONCLUSIONES ─── */
function Conclusiones() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={C.teal}
        tag="Conclusiones"
        variant="decorated"
        className="w-full flex flex-col gap-4 justify-center"
      >
        <h1 className="text-6xl! font-semibold tracking-tight text-center">
          Hallazgos{" "}
          <span style={{ color: C.teal }}>principales</span>
        </h1>
        <div className="grid grid-cols-3 gap-4">
          {[
            {
              n: "1",
              l: "Payload 78% menor",
              d: "GraphQL con campos selectivos reduce drásticamente la transferencia de datos — crítico para móviles.",
            },
            {
              n: "2",
              l: "Lectura: GraphQL ~18% más rápido",
              d: "Latencia promedio inferior en todas las operaciones de lectura, con throughput similar.",
            },
            {
              n: "3",
              l: "REST: mejor para caché",
              d: "HTTP nativo (ETag, Cache-Control) hace REST superior cuando el caching es prioridad.",
            },
          ].map((i) => (
            <div
              key={i.n}
              className="rounded-xl border border-white/10 bg-white/5 p-2"
            >
              <div className="flex items-center gap-2">
                <span
                  className="flex size-5 shrink-0 items-center justify-center rounded-full text-base font-semibold"
                  style={{ backgroundColor: `${C.teal}25`, color: C.teal }}
                >
                  {i.n}
                </span>
                <p className="text-xl font-semibold uppercase tracking-widest text-white">
                  {i.l}
                </p>
              </div>
              <p className="mt-0.5 text-xl text-left text-gray-400 leading-snug">
                {i.d}
              </p>
            </div>
          ))}
        </div>
        <div className="grid grid-cols-3 gap-4">
          <StatCard
            value="78%"
            label="Menos datos (selective)"
            color={C.green}
            variant="decorated"
          />
          <StatCard
            value="-18%"
            label="Menor latencia lectura"
            color={C.green}
            variant="decorated"
          />
          <StatCard
            value="~450"
            label="RPS (ambos)"
            color={C.teal}
            variant="decorated"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── DECK ─── */
export function RestVsGraphqlPresentation() {
  return (
    <PresentationDeck config={{ slideNumber: "c/t", transition: "slide" }}>
      <Cover />
      <Objetivo />
      <EntornoPrueba />
      <FlujoComparacion />

      <ArquitecturaRest />
      <ArquitecturaGraphql />

      <EvidenciaRest />
      <EvidenciaGraphql />

      <TamanoPayload />
      <RendimientoLectura />
      <LecturaIndividual />
      <CamposSelectivos />
      <RendimientoEscritura />
      <Estabilidad />

      <Cache />
      <Escalabilidad />

      <CuandoUsar />
      <Conclusiones />
      <ThanksSlide color={C.teal} variant="decorated" />
    </PresentationDeck>
  );
}
