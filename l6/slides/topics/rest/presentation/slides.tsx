import { Slide } from "@revealjs/react";
import { Badge } from "@/shared/badge";
import { colors as C } from "@/shared/colors";
import { FeatureCard, FeatureCardCompact } from "@/shared/feature-cards";
import { NumberedItem } from "@/shared/numbered-item";
import { PresentationDeck } from "@/shared/presentation-deck";
import { SlideWrap } from "@/shared/slide-wrap";
import { StatCard } from "@/shared/stat-cards";
import { ThanksSlide } from "@/shared/thanks-slide";

const baseUrl = import.meta.env.BASE_URL.replace(/\/$/, "");
const asset = (name: string) => `${baseUrl}/rest/${name}`;

const IMG_REST_ARCH = asset("rest-architecture.png");
const IMG_GRAPHQL_ARCH = asset("graphql-architecture.png");
const IMG_E1_CREATE_FORM = asset("e1-create-form.png");
const IMG_E1_REST_API = asset("e1-rest-api.png");
const IMG_E2_CREATE_FORM_FILLED = asset("e2-create-form-filled.png");
const IMG_E2_CREATE_RESULT = asset("e2-create-result.png");
const IMG_E2_DELETE_RESULT = asset("e2-delete-result.png");
const IMG_E3_CONSOLE = asset("e3-graphql-console.png");
const IMG_COMPARISON = asset("comparison-flow.png");

const P = C.purple;

/* ─── BLOQUE DE CÓDIGO ─── */
function CodeBlock({ code, lang }: { code: string; lang: string }) {
  return (
    <div className="rounded-xl border border-white/10 bg-black/40 overflow-hidden h-auto max-h-[500px]">
      <div
        className="flex gap-1.5 px-3 py-1.5 border-b border-white/10 items-center"
        style={{ background: `${P}12` }}
      >
        <span className="size-2 rounded-full bg-red-400/60" />
        <span className="size-2 rounded-full bg-amber-400/60" />
        <span className="size-2 rounded-full bg-green-400/60" />
        <span
          className="ml-2 text-sm font-semibold uppercase tracking-widest"
          style={{ color: P }}
        >
          {lang}
        </span>
      </div>
      <pre className="text-base leading-snug overflow-x-auto">
        <code className="text-sm font-mono text-gray-300 whitespace-pre">
          {code}
        </code>
      </pre>
    </div>
  );
}

/* ─── IMAGEN CON MARCO CLARO (para capturas de UI/diagramas) ─── */
function FramedImage({
  src,
  alt,
  caption,
  className = "",
}: {
  src: string;
  alt: string;
  caption?: string;
  className?: string;
}) {
  return (
    <div className="flex flex-col items-center gap-1.5">
      <img
        src={src}
        alt={alt}
        className={`object-contain rounded-xl bg-white/95 p-1.5 shadow-md ${className}`}
      />
      {caption && (
        <p className="text-lg text-gray-400 text-center text-pretty">
          {caption}
        </p>
      )}
    </div>
  );
}

/* ─── TABLA DE RESULTADOS ─── */
function ResultsTable({
  rows,
}: {
  rows: {
    metric: string;
    rest: string;
    graphql: string;
    diff: string;
    highlight?: boolean;
  }[];
}) {
  return (
    <table className="w-full border-collapse">
      <thead>
        <tr>
          <th
            className="pb-2 text-left text-lg font-semibold uppercase tracking-widest"
            style={{ color: P }}
          >
            Métrica
          </th>
          <th
            className="pb-2 text-right text-lg font-semibold uppercase tracking-widest"
            style={{ color: P }}
          >
            REST
          </th>
          <th
            className="pb-2 text-right text-lg font-semibold uppercase tracking-widest"
            style={{ color: P }}
          >
            GraphQL
          </th>
          <th
            className="pb-2 text-right text-lg font-semibold uppercase tracking-widest"
            style={{ color: P }}
          >
            Diferencia
          </th>
        </tr>
      </thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.metric} className="border-t border-white/10">
            <td className="py-2.5 text-2xl text-gray-300">{r.metric}</td>
            <td className="py-2.5 text-2xl text-right text-gray-400">
              {r.rest}
            </td>
            <td className="py-2.5 text-2xl text-right text-gray-400">
              {r.graphql}
            </td>
            <td
              className="py-2.5 text-2xl text-right font-semibold"
              style={{ color: r.highlight ? P : "#9ca3af" }}
            >
              {r.diff}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/* ─── PORTADA + INTEGRANTES ─── */
function Cover() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Sistemas Distribuidos · Grupo 3 · Laboratorio 06"
        variant="decorated"
        className="justify-center flex flex-col items-center h-full py-8 text-center"
      >
        <p
          className="text-2xl font-semibold uppercase tracking-[0.25em]"
          style={{ color: P }}
        >
          Diseño de APIs en Sistemas Distribuidos
        </p>
        <h1 className="mt-3 text-7xl!">
          <span style={{ color: P }}>REST</span>{" "}
          <span className="text-gray-500 font-light">vs</span> GraphQL
        </h1>
        <p className="mt-2 text-2xl text-gray-400 max-w-3xl text-pretty">
          Análisis empírico de rendimiento entre paradigmas de arquitectura de
          APIs para un catálogo de libros
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

/* ─── MOTIVACIÓN ─── */
function Motivation() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="¿Por qué comparar paradigmas de API?"
        variant="decorated"
        className="justify-center flex flex-col gap-6 w-full mx-auto"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-5xl! text-balance max-w-4xl text-center">
            Dos paradigmas dominantes para{" "}
            <span style={{ color: P }}>exponer datos</span>
          </h1>
          <p className="mt-2 text-xl text-gray-400 max-w-4xl text-center text-pretty">
            REST organiza recursos vía URIs y métodos HTTP estándar; GraphQL
            expone un único endpoint donde el cliente especifica exactamente los
            datos que necesita. Ambos se implementaron sobre el mismo dominio de
            catálogo de libros para permitir una comparación directa.
          </p>
        </div>

        <div className="grid grid-cols-3 gap-3">
          {[
            {
              l: "Implementaciones equivalentes",
              d: "APIs RESTful con Spring Boot y Flask, y un servidor GraphQL con Bun/GraphQL-Yoga sobre el mismo dominio.",
            },
            {
              l: "Carga controlada con k6",
              d: "Mediciones de latencia, tamaño de payload, throughput y estabilidad en lectura y escritura.",
            },
            {
              l: "Compromisos arquitectónicos",
              d: "Directrices prácticas para elegir entre REST y GraphQL en sistemas distribuidos modernos.",
            },
          ].map((i) => (
            <FeatureCard
              key={i.l}
              label={i.l}
              description={i.d}
              color={P}
              variant="decorated"
            />
          ))}
        </div>

        <div className="flex flex-wrap items-center justify-center gap-3">
          <span className="text-xl font-semibold uppercase tracking-[0.15em] text-gray-500">
            El problema de REST
          </span>
          {["Sobre-fetching", "Under-fetching", "Múltiples endpoints"].map(
            (f) => (
              <Badge key={f} label={f} color={P} />
            ),
          )}
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── FUNDAMENTOS: REST ─── */
function RestFundamentals() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Marco Teórico · REST y RESTful"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <div className="flex flex-col gap-3">
            <h1 className="text-4xl! font-semibold tracking-tight">
              Un estilo arquitectónico,{" "}
              <span style={{ color: P }}>no un protocolo</span>
            </h1>
            <p className="text-xl text-gray-400 leading-snug">
              Fielding define REST mediante restricciones clave:
              cliente-servidor, sin estado (stateless), cacheable, interfaz
              uniforme y sistema por capas. RESTful es el adjetivo para el
              servicio que cumple estas restricciones — usar HTTP no basta para
              serlo.
            </p>
            <div className="flex flex-wrap gap-2">
              {[
                "Cliente-servidor",
                "Sin estado",
                "Cacheable",
                "Interfaz uniforme",
                "Sistema por capas",
              ].map((b) => (
                <Badge key={b} label={b} color={P} />
              ))}
            </div>
          </div>
          <div className="flex items-center justify-center">
            <FramedImage
              src={IMG_REST_ARCH}
              alt="Arquitectura REST: cliente-servidor con comunicación stateless sobre recursos identificados por URIs"
              caption="Cliente-servidor stateless mediante métodos HTTP sobre recursos con URI"
              className="w-full max-w-xl"
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── FUNDAMENTOS: GRAPHQL ─── */
function GraphqlFundamentals() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Marco Teórico · GraphQL"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <div className="flex items-center justify-center">
            <FramedImage
              src={IMG_GRAPHQL_ARCH}
              alt="Arquitectura GraphQL: único endpoint con esquema tipado que permite al cliente especificar campos exactos"
              caption="Único endpoint con esquema tipado y resolvers"
              className="w-full max-w-xl"
            />
          </div>
          <div className="flex flex-col gap-3">
            <h1 className="text-4xl! font-semibold tracking-tight">
              El cliente <span style={{ color: P }}>define qué recibe</span>
            </h1>
            <p className="text-xl text-gray-400 leading-snug">
              GraphQL expone un único punto de acceso a través del cual el
              cliente especifica exactamente los campos que necesita mediante
              consultas y mutaciones tipadas, eliminando el sobre-fetching y el
              under-fetching propios de REST.
            </p>
            <p className="text-xl text-gray-400 leading-snug">
              A cambio, introduce complejidad adicional en caché, seguridad y
              procesamiento de consultas del lado del servidor.
            </p>
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── DIVISOR: IMPLEMENTACIONES ─── */
function ImplementationsDivider() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Diseño e Implementación"
        variant="decorated"
        className="justify-center items-center flex flex-col gap-5"
      >
        <h1 className="text-6xl! font-semibold tracking-tight text-center">
          Un dominio, <span style={{ color: P }}>tres implementaciones</span>
        </h1>
        <p className="text-xl text-gray-400 max-w-2xl text-center text-pretty">
          El mismo catálogo de libros (y un registro estudiantil) implementado
          con tres stacks distintos para una comparación directa entre
          paradigmas.
        </p>
        <div className="grid grid-cols-3 gap-3 self-stretch">
          {[
            {
              l: "E1 · Spring Boot",
              d: "API RESTful de gestión bibliotecaria en Java 21.",
            },
            {
              l: "E2 · Flask",
              d: "API RESTful de registro estudiantil, ligera y minimalista.",
            },
            {
              l: "E3 · GraphQL",
              d: "Extensión con Bun, Hono y GraphQL-Yoga para comparar paradigmas.",
            },
          ].map((i) => (
            <FeatureCardCompact
              key={i.l}
              label={i.l}
              description={i.d}
              color={P}
              variant="decorated"
            />
          ))}
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E1: SPRING BOOT (CÓDIGO) ─── */
function E1SpringBoot() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 1 · API RESTful con Spring Boot"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <CodeBlock
            lang="Java · Entidad JPA"
            code={`@Entity
@Table(name = "books")
public class Book {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String author;

    @Column(unique = true, nullable = false)
    private String isbn;

    private String description;
    private String imageUrl;
}`}
          />
          <div className="flex flex-col gap-3">
            <h1 className="text-3xl! font-semibold tracking-tight">
              Gestión bibliotecaria{" "}
              <span style={{ color: P }}>profesional</span>
            </h1>
            <NumberedItem
              num="1"
              title="Patrón en capas"
              description="Spring Boot 4.0.6 con Java 21, siguiendo controller-repository-model bajo /api/books."
              color={P}
            />
            <NumberedItem
              num="2"
              title="CRUD completo"
              description="Listado, obtención por id, creación, actualización y eliminación, semánticamente correctos."
              color={P}
            />
            <NumberedItem
              num="3"
              title="Multipart y persistencia"
              description="Registro de portada como imagen binaria; unicidad de ISBN validada; persistencia en SQLite vía JPA/Hibernate."
              color={P}
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E1: EVIDENCIA ─── */
function E1Evidence() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 1 · Evidencia"
        variant="decorated"
        className="w-full flex flex-col gap-2 items-center justify-center"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-4xl! text-balance text-center">
            Panel y formulario de{" "}
            <span className="font-semibold" style={{ color: P }}>
              registro de libros
            </span>
          </h1>
          <p className="mt-1 text-xl text-gray-400 text-pretty text-center max-w-4xl">
            Dashboard con operaciones GET, POST, PUT y DELETE, y formulario de
            alta de un nuevo libro con validación de campos.
          </p>
        </div>
        <div className="grid grid-cols-2 gap-4 self-stretch justify-items-center">
          <FramedImage
            src={IMG_E1_REST_API}
            alt="Panel de la API RESTful de gestión bibliotecaria con Spring Boot"
            caption="Panel con endpoints CRUD y colección de libros"
            className="w-lg"
          />
          <FramedImage
            src={IMG_E1_CREATE_FORM}
            alt="Formulario de registro de un nuevo libro"
            caption="Formulario de alta con título, autor, ISBN y portada"
            className="w-lg"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E2: FLASK (CÓDIGO) ─── */
function E2Flask() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 2 · API RESTful con Flask"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <div className="flex flex-col gap-3">
            <h1 className="text-3xl! font-semibold tracking-tight">
              Registro estudiantil <span style={{ color: P }}>ligero</span>
            </h1>
            <NumberedItem
              num="1"
              title="Enfoque minimalista"
              description="Flask y SQLAlchemy, un enfoque más ligero frente a Spring Boot, ideal para prototipado rápido."
              color={P}
            />
            <NumberedItem
              num="2"
              title="CRUD con filtrado"
              description="Listado con búsqueda, creación validada, actualización parcial y eliminación con manejo de errores."
              color={P}
            />
            <NumberedItem
              num="3"
              title="Panel administrativo"
              description="Dashboard con estadísticas, búsqueda por nombre, matrícula o carrera, y filtros por estado."
              color={P}
            />
          </div>
          <CodeBlock
            lang="Python · Ruta Flask"
            code={`@app.route("/api/estudiantes", methods=["GET"])
def listar_estudiantes():
    busqueda = request.args.get("busqueda", "")
    query = Estudiante.query
    if busqueda:
        query = query.filter(
            Estudiante.nombre.contains(busqueda)
        )
    return jsonify(
        [e.to_dict() for e in query.all()]
    )`}
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E2: EVIDENCIA ─── */
function E2Evidence() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 2 · Evidencia"
        variant="decorated"
        className="w-full flex flex-col gap-3 items-center justify-center"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-4xl! text-balance text-center">
            Ciclo CRUD completo en el{" "}
            <span className="font-semibold" style={{ color: P }}>
              registro estudiantil
            </span>
          </h1>
          <p className="mt-1 text-xl text-gray-400 text-pretty text-center max-w-4xl">
            Un mismo estudiante recorriendo alta, confirmación y baja sobre la
            misma API RESTful.
          </p>
        </div>
        <div className="grid grid-cols-3 gap-3 self-stretch justify-items-center">
          <FramedImage
            src={IMG_E2_CREATE_FORM_FILLED}
            alt="Formulario de registro de estudiante completado"
            caption="1. Formulario completado"
            className="max-h-[320px]"
          />
          <FramedImage
            src={IMG_E2_CREATE_RESULT}
            alt="Resultado tras la creación del estudiante"
            caption="2. Resultado tras creación (POST)"
            className="max-h-[320px]"
          />
          <FramedImage
            src={IMG_E2_DELETE_RESULT}
            alt="Resultado tras la eliminación del estudiante"
            caption="3. Resultado tras eliminación (DELETE)"
            className="max-h-[320px]"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E3: GRAPHQL (CÓDIGO) ─── */
function E3Graphql() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 3 · Extensión GraphQL"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <CodeBlock
            lang="GraphQL · Esquema"
            code={`type Book {
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
  createBook(
    title: String!
    author: String!
    isbn: String!
  ): Book!
}`}
          />
          <div className="flex flex-col gap-3">
            <h1 className="text-3xl! font-semibold tracking-tight">
              Más allá del taller:{" "}
              <span style={{ color: P }}>comparar paradigmas</span>
            </h1>
            <NumberedItem
              num="1"
              title="Stack moderno"
              description="Bun 1.3 como runtime, framework HTTP Hono y servidor GraphQL-Yoga sobre el mismo dominio de libros."
              color={P}
            />
            <NumberedItem
              num="2"
              title="Un único endpoint"
              description="Todas las operaciones —consultas y mutaciones— se resuelven a través de un solo punto de acceso tipado."
              color={P}
            />
            <NumberedItem
              num="3"
              title="Resolvers en memoria"
              description="Los resolvers acceden a datos en arrays, ejecutando exactamente lo que el cliente solicita."
              color={P}
            />
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── E3: EVIDENCIA ─── */
function E3Evidence() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Ejercicio 3 · Evidencia"
        variant="decorated"
        className="w-full flex flex-col gap-2 items-center justify-center"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-4xl! text-balance text-center">
            Consola interactiva de{" "}
            <span className="font-semibold" style={{ color: P }}>
              consultas GraphQL
            </span>
          </h1>
          <p className="mt-1 text-xl text-gray-400 text-pretty text-center max-w-4xl">
            Editor de consultas con validación de sintaxis y ejecución en tiempo
            real contra el endpoint único /graphql.
          </p>
        </div>
        <FramedImage
          src={IMG_E3_CONSOLE}
          alt="Consola interactiva de GraphQL con editor de consultas y resultados en tiempo real"
          className="w-xl"
        />
      </SlideWrap>
    </Slide>
  );
}

/* ─── METODOLOGÍA EXPERIMENTAL ─── */
function Methodology() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Resultados Experimentales · Entorno de Prueba"
        variant="decorated"
        className="w-full flex items-center justify-center"
      >
        <div className="grid grid-cols-2 gap-6 w-full items-center text-left">
          <CodeBlock
            lang="JavaScript · Escenario k6"
            code={`export const options = {
  stages: [
    { duration: "10s", target: 10 },  // ramp-up
    { duration: "30s", target: 50 },  // estable
    { duration: "10s", target: 100 }, // pico
    { duration: "30s", target: 50 },  // sostenido
    { duration: "10s", target: 0 },   // ramp-down
  ],
  thresholds: {
    http_req_duration: ["p(95)<50"],
    http_req_failed: ["rate<0.01"],
  },
};`}
          />
          <div className="flex flex-col gap-3">
            <h1 className="text-3xl! font-semibold tracking-tight">
              Carga controlada con <span style={{ color: P }}>k6</span>
            </h1>
            <p className="text-xl text-gray-400 leading-snug">
              Duración total de 90 segundos por escenario: ramp-up a 10 VUs,
              estado estable a 50 VUs, pico de 100 VUs, pico sostenido a 50 VUs
              y ramp-down.
            </p>
            <div className="flex flex-wrap gap-2">
              {[
                "Latencia",
                "Tamaño de payload",
                "Throughput",
                "Tasa de error",
              ].map((b) => (
                <Badge key={b} label={b} color={P} />
              ))}
            </div>
          </div>
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── PAYLOAD ─── */
function PayloadComparison() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Resultados · Tamaño del Payload"
        variant="decorated"
        className="w-full flex flex-col gap-2 justify-center items-center"
      >
        <div className="flex flex-col items-center">
          <h1 className="text-4xl! text-balance text-center">
            Consultas selectivas:{" "}
            <span style={{ color: P }}>menos bytes por respuesta</span>
          </h1>
          <p className="text-xl text-gray-400 text-pretty text-center max-w-4xl">
            Sobre-fetching de REST frente a la consulta selectiva de campos de
            GraphQL para la misma solicitud del cliente.
          </p>
        </div>
        <img
          src={IMG_COMPARISON}
          alt="Flujo comparativo del sobre-fetching de REST versus la consulta selectiva de GraphQL"
          className="w-3xl max-w-5xl rounded-xl bg-white/95 p-2 shadow-md"
        />
        <div className="grid grid-cols-3 gap-3 self-stretch">
          <StatCard
            value="78%"
            label="Menos bytes con campos selectivos"
            color={P}
            variant="decorated"
          />
          <StatCard
            value="12.7%"
            label="Menos datos en lectura individual"
            color={P}
            variant="decorated"
          />
          <StatCard
            value="76.2%"
            label="Reducción combinada (título + autor)"
            color={P}
            variant="decorated"
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── RESULTADOS: LECTURA (LISTADO) ─── */
function ReadAllResults() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Resultados · Lectura: Listado Completo"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          GET de listado a{" "}
          <span style={{ color: P }}>100 usuarios virtuales</span>
        </h1>
        <ResultsTable
          rows={[
            {
              metric: "Total de Solicitudes",
              rest: "40,470",
              graphql: "40,775",
              diff: "+0.75%",
            },
            {
              metric: "Latencia Promedio",
              rest: "2.73ms",
              graphql: "2.24ms",
              diff: "−17.9%",
              highlight: true,
            },
            {
              metric: "Latencia P95",
              rest: "4.86ms",
              graphql: "4.62ms",
              diff: "−4.9%",
              highlight: true,
            },
            {
              metric: "Latencia Máxima",
              rest: "26.82ms",
              graphql: "23.67ms",
              diff: "−11.7%",
              highlight: true,
            },
            {
              metric: "Throughput",
              rest: "449 RPS",
              graphql: "453 RPS",
              diff: "+0.8%",
            },
            { metric: "Tasa de Error", rest: "0%", graphql: "0%", diff: "—" },
          ]}
        />
        <p className="text-xl text-gray-400 text-center text-pretty">
          La mejora de GraphQL es consistente en todas las métricas de latencia,
          manteniendo throughput y tasa de error equivalentes.
        </p>
      </SlideWrap>
    </Slide>
  );
}

/* ─── RESULTADOS: LECTURA (INDIVIDUAL) ─── */
function ReadSingleResults() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Resultados · Lectura: Libro Individual"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          GET individual a{" "}
          <span style={{ color: P }}>100 usuarios virtuales</span>
        </h1>
        <ResultsTable
          rows={[
            {
              metric: "Total de Solicitudes",
              rest: "40,661",
              graphql: "40,950",
              diff: "+0.7%",
            },
            {
              metric: "Latencia Promedio",
              rest: "2.46ms",
              graphql: "2.08ms",
              diff: "−15.4%",
              highlight: true,
            },
            {
              metric: "Latencia P95",
              rest: "4.52ms",
              graphql: "4.19ms",
              diff: "−7.3%",
              highlight: true,
            },
            {
              metric: "Latencia Máxima",
              rest: "22.38ms",
              graphql: "18.52ms",
              diff: "−17.2%",
              highlight: true,
            },
            {
              metric: "Throughput",
              rest: "451 RPS",
              graphql: "455 RPS",
              diff: "+0.9%",
            },
            {
              metric: "Datos Recibidos",
              rest: "21.3 MB",
              graphql: "18.6 MB",
              diff: "−12.7%",
              highlight: true,
            },
          ]}
        />
        <p className="text-xl text-gray-400 text-center text-pretty">
          Con consultas selectivas de título y autor, la latencia baja a 2.17ms
          y la transferencia se reduce en un 76.2% frente a REST.
        </p>
      </SlideWrap>
    </Slide>
  );
}

/* ─── RESULTADOS: ESCRITURA ─── */
function WriteResults() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Resultados · Escritura: Creación de Libros"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          POST de creación a{" "}
          <span style={{ color: P }}>20 usuarios virtuales</span>
        </h1>
        <ResultsTable
          rows={[
            {
              metric: "Latencia Promedio",
              rest: "1.69ms",
              graphql: "2.34ms",
              diff: "+38.5%",
            },
            {
              metric: "Latencia P95",
              rest: "2.69ms",
              graphql: "3.86ms",
              diff: "+43.5%",
            },
            {
              metric: "Latencia Máxima",
              rest: "31.22ms",
              graphql: "7.35ms",
              diff: "−76.5%",
              highlight: true,
            },
            {
              metric: "Throughput",
              rest: "48.4 RPS",
              graphql: "48.4 RPS",
              diff: "0%",
            },
            {
              metric: "Datos Enviados",
              rest: "655 KB",
              graphql: "1.01 MB",
              diff: "+54%",
            },
          ]}
        />
        <p className="text-xl text-gray-400 text-center text-pretty">
          REST gana en latencia promedio de escritura, pero GraphQL es más
          predecible bajo carga pico: su latencia máxima es 4.2 veces menor.
        </p>
      </SlideWrap>
    </Slide>
  );
}

/* ─── DISCUSIÓN: CUÁNDO ELEGIR REST ─── */
function WhenRest() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Discusión · Cuándo Elegir REST"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          Simplicidad operativa y{" "}
          <span style={{ color: P }}>caché nativa de HTTP</span>
        </h1>
        <div className="grid grid-cols-2 gap-3">
          {[
            {
              l: "Caché HTTP nativa",
              d: "Cacheable mediante headers ETag y Cache-Control, sin infraestructura adicional.",
            },
            {
              l: "APIs públicas documentadas",
              d: "Ecosistema maduro de herramientas: OpenAPI/Swagger generan documentación y clientes.",
            },
            {
              l: "Operaciones CRUD simples",
              d: "Ideal para servicios orientados a recursos con requisitos de datos estables.",
            },
            {
              l: "Menor overhead de escritura",
              d: "Latencia de escritura más baja; adecuado para comunicación servidor-a-servidor.",
            },
          ].map((i) => (
            <FeatureCardCompact
              key={i.l}
              label={i.l}
              description={i.d}
              color={P}
              variant="decorated"
            />
          ))}
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── DISCUSIÓN: CUÁNDO ELEGIR GRAPHQL ─── */
function WhenGraphql() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Discusión · Cuándo Elegir GraphQL"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-4xl! font-semibold tracking-tight text-center">
          Flexibilidad del cliente y{" "}
          <span style={{ color: P }}>ahorro de ancho de banda</span>
        </h1>
        <div className="grid grid-cols-2 gap-3">
          {[
            {
              l: "Aplicaciones móviles",
              d: "Reducción de hasta 78% en payload, crítica para redes con ancho de banda limitado.",
            },
            {
              l: "Datos complejos relacionados",
              d: "Resuelve múltiples entidades en una sola solicitud, evitando llamadas secuenciales.",
            },
            {
              l: "Necesidades diversas de cliente",
              d: "Distintos consumidores solicitan distintos subconjuntos de los mismos datos.",
            },
            {
              l: "Endpoint único y evolución",
              d: "Simplifica el versionado; habilita suscripciones para aplicaciones en tiempo real.",
            },
          ].map((i) => (
            <FeatureCardCompact
              key={i.l}
              label={i.l}
              description={i.d}
              color={P}
              variant="decorated"
            />
          ))}
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── COMPROMISOS ARQUITECTÓNICOS ─── */
function Tradeoffs() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Discusión · Compromisos Arquitectónicos"
        variant="decorated"
        className="justify-center flex flex-col gap-4"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Simplicidad operativa{" "}
          <span className="text-gray-500 font-light">o</span>{" "}
          <span style={{ color: P }}>flexibilidad del cliente</span>
        </h1>
        <div className="grid grid-cols-2 gap-3">
          <NumberedItem
            num="1"
            title="RESTful ≠ solo usar HTTP"
            description="Endpoints orientados a acciones (/getUsers) rompen la interfaz uniforme y la cacheabilidad, limitando la escalabilidad."
            color={P}
          />
          <NumberedItem
            num="2"
            title="El framework también importa"
            description="Spring Boot, Flask o Bun/GraphQL-Yoga impactan tanto en la experiencia de desarrollo como en el rendimiento."
            color={P}
          />
          <NumberedItem
            num="3"
            title="Curvas de aprendizaje distintas"
            description="REST se adopta con solo conocer HTTP; GraphQL exige definir esquema y resolvers, inversión que se amortiza con múltiples consumidores."
            color={P}
          />
          <NumberedItem
            num="4"
            title="Ningún paradigma es universal"
            description="La elección se reduce a priorizar simplicidad operativa (REST) o flexibilidad dirigida por el cliente (GraphQL)."
            color={P}
          />
        </div>
      </SlideWrap>
    </Slide>
  );
}

/* ─── CONCLUSIONES ─── */
function Conclusions() {
  return (
    <Slide className="h-full">
      <SlideWrap
        color={P}
        tag="Conclusiones"
        variant="decorated"
        className="w-full flex flex-col gap-3 justify-center"
      >
        <h1 className="text-5xl! font-semibold tracking-tight text-center">
          Ningún paradigma es{" "}
          <span style={{ color: P }}>universalmente superior</span>
        </h1>
        <div className="grid grid-cols-3 gap-4">
          {[
            {
              n: "1",
              l: "Ventaja de lectura en GraphQL",
              d: "15–18% menor latencia y hasta 78% menos payload mediante consultas selectivas de campos.",
            },
            {
              n: "2",
              l: "Ventaja de escritura en REST",
              d: "Menor latencia promedio de escritura y capacidades superiores de caché nativo de HTTP.",
            },
            {
              n: "3",
              l: "Cuello de botella compartido",
              d: "Throughput similar bajo carga comparable: la base de datos, más que el protocolo, es el límite principal.",
            },
          ].map((i) => (
            <div
              key={i.n}
              className="rounded-xl border border-white/10 bg-white/5 p-3"
            >
              <div className="flex items-center gap-2">
                <span
                  className="flex size-5 shrink-0 items-center justify-center rounded-full text-base font-semibold"
                  style={{ backgroundColor: `${P}25`, color: P }}
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
        <p className="text-center text-xl text-gray-400">
          Recomendamos <span className="font-semibold text-white">REST</span>{" "}
          para CRUD simple y microservicios internos, y{" "}
          <span className="font-semibold text-white">GraphQL</span> para APIs
          orientadas al cliente con requisitos diversos de datos — o enfoques
          híbridos que combinen ambas fortalezas.
        </p>
      </SlideWrap>
    </Slide>
  );
}

/* ─── DECK ─── */
export function RestPresentation() {
  return (
    <PresentationDeck config={{ slideNumber: "c/t", transition: "slide" }}>
      <Cover />
      <Motivation />

      <RestFundamentals />
      <GraphqlFundamentals />

      <ImplementationsDivider />
      <E1SpringBoot />
      <E1Evidence />
      <E2Flask />
      <E2Evidence />
      <E3Graphql />
      <E3Evidence />

      <Methodology />
      <PayloadComparison />
      <ReadAllResults />
      <ReadSingleResults />
      <WriteResults />

      <WhenRest />
      <WhenGraphql />
      <Tradeoffs />

      <Conclusions />
      <ThanksSlide color={P} variant="decorated" />
    </PresentationDeck>
  );
}
