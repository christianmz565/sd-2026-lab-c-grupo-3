import { MicrophotoPresentation } from "@topics/microphoto/presentation/slides";
import { RestVsGraphqlPresentation } from "@topics/rest-vs-graphql/presentation/slides";

export const presentations = [
  {
    slug: "microphoto",
    path: "/presentations/microphoto",
    title: "Microphoto",
    description:
      "Procesamiento paralelo de imágenes sobre una arquitectura de sistemas distribuidos",
    component: MicrophotoPresentation,
  },
  {
    slug: "rest-vs-graphql",
    path: "/presentations/rest-vs-graphql",
    title: "REST vs GraphQL",
    description:
      "Comparación de rendimiento entre APIs REST y GraphQL con el mismo dominio de catálogo de libros",
    component: RestVsGraphqlPresentation,
  },
];
