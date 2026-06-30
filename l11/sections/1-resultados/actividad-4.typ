#import "@preview/mmdr:0.2.2": mermaid

#set par(justify: true)

= Actividad 4: Protección de APIs

Para LogiMarket Perú S.A.C., se diseña una arquitectura segura para APIs empresariales que integra mecanismos de autenticación, autorización, control de tráfico y monitoreo, siguiendo las mejores prácticas documentadas por el OWASP API Security Top 10 @owasp2023api y las directrices de NIST para arquitecturas de microservicios @nist2024csf.

== Arquitectura Propuesta

#figure(
  box(width: 70%)[
    #mermaid("
    flowchart TD
    %% Subgraphs
    subgraph Clientes[\"Clientes\"]
    WEB[\"Portal Web\"]
    MOB[\"Aplicación Móvil\"]
    end

    subgraph Auth[\"Servidor OAuth 2.0\"]
    OAuth[\"Authorization Code<br>+ PKCE\"]
    JWT[\"JWT Firmado<br>RS256\"]
    end

    subgraph Gateway[\"API Gateway - Traefik\"]
    VAL[\"Validación JWT\"]
    RL[\"Rate Limiting<br>100 req/min\"]
    LOG_GW[\"Logging y<br>Monitoreo\"]
    end

    subgraph Backend[\"Microservicios\"]
    INV[\"Inventario\"]
    PAG[\"Pagos\"]
    LOGISTICS[\"Logística\"]
    end

    subgraph Storage[\"Almacenamiento\"]
    DB1[\"BD Inventario\"]
    DB2[\"BD Pagos\"]
    DB3[\"BD Logística\"]
    end

    %% Flow Relationships
    WEB --> OAuth
    MOB --> OAuth
    OAuth -->|credenciales| JWT
    JWT -->|Bearer token| VAL
    VAL -->|token válido| RL
    RL --> LOG_GW

    %% Fixed relationship routings
    LOG_GW --> INV
    LOG_GW --> PAG
    LOG_GW --> LOGISTICS

    INV --> DB1
    PAG --> DB2
    LOGISTICS --> DB3
    "),
  ],
  caption: [Diagrama de arquitectura segura para APIs empresariales de LogiMarket],
) <fig-api-arch>

== Componentes Principales

=== 1. Portal Web y Aplicación Móvil

Son los clientes que consumen los servicios empresariales. Desde estos sistemas los usuarios realizan operaciones relacionadas con compras, pagos, inventario y seguimiento logístico. Cada cliente implementa flujos de autenticación OAuth 2.0 con PKCE para garantizar la seguridad en la obtención de tokens.

=== 2. Servidor OAuth 2.0

Es el componente responsable de autenticar a los usuarios y otorgar autorización para acceder a los recursos protegidos. Se implementa el flujo Authorization Code con PKCE (Proof Key for Code Exchange) para proporcionar un alto nivel de seguridad tanto en aplicaciones web como móviles, eliminando la necesidad de almacenar secrets en el cliente @owasp2023api.

=== 3. JWT (JSON Web Token)

Después de una autenticación exitosa, el servidor OAuth 2.0 genera un token JWT firmado digitalmente con RS256. Este token contiene información sobre la identidad, roles, permisos y tiempo de expiración del usuario, permitiendo que los servicios validen la autorización sin necesidad de mantener sesiones centralizadas. Los tokens tienen una expiración de 15 minutos, con refresh tokens de 7 días @jwt2015rfc7519.

=== 4. API Gateway (Traefik)

Funciona como punto único de entrada para todas las solicitudes dirigidas a los microservicios, siguiendo el patrón documentado por @owasp2024microservices. Centraliza las políticas de seguridad, controla el tráfico y simplifica la administración de la infraestructura. Implementa middleware de autenticación, rate limiting y logging a nivel de infraestructura.

=== 5. Validación de JWT

Este componente verifica la autenticidad, integridad y vigencia de los tokens recibidos. Utiliza la clave pública del servidor de autenticación para verificar la firma RS256 y valida los claims de expiración, issuer y audience. Solo las solicitudes que presentan tokens válidos pueden acceder a los servicios internos.

=== 6. Rate Limiting

Controla la cantidad de solicitudes permitidas por usuario o aplicación durante un periodo de tiempo determinado. Se configuran límites de 100 requests por minuto por usuario con un burst de 50, evitando abusos, proteger la infraestructura y garantizando una distribución equilibrada de los recursos @owasp2023api.

=== 7. Logging y Monitoreo

Registra todas las solicitudes y eventos relevantes para facilitar la auditoría, el diagnóstico de problemas y la detección de comportamientos sospechosos dentro de la plataforma. Utiliza el stack Prometheus + Grafana + Loki para correlacionar métricas de rendimiento con logs de seguridad.

=== 8. Microservicios de Inventario, Pagos y Logística

Procesan la lógica de negocio principal de la empresa. Cada servicio opera de manera independiente y atiende únicamente las solicitudes previamente validadas por el API Gateway. Implementan autorización a nivel de servicio siguiendo el patrón de PDP/PEP documentado por @owasp2024microservices.

== Flujo de Seguridad

1. El usuario accede desde el Portal Web o la Aplicación Móvil.
2. El cliente solicita autenticación al Servidor OAuth 2.0 mediante Authorization Code + PKCE.
3. El servidor valida las credenciales, verifica el segundo factor y genera un JWT firmado.
4. El cliente envía solicitudes incluyendo el token JWT en el header `Authorization: Bearer`.
5. El API Gateway recibe la solicitud, valida el token JWT y verifica la firma.
6. Se aplican las políticas de Rate Limiting según el usuario y el endpoint.
7. La solicitud es registrada mediante los mecanismos de Logging y Monitoreo.
8. El Gateway enruta la petición hacia el microservicio correspondiente.
9. El microservicio realiza autorización a nivel de servicio (RBAC) y procesa la operación.
10. La respuesta es devuelta al cliente con los headers de seguridad correspondientes.

Esta arquitectura mitiga los vectores de ataque críticos: broken authentication (API2), broken access control (API5), unrestricted resource consumption (API4) y security misconfiguration (API8), proporcionando defensa en profundidad para la plataforma de LogiMarket @owasp2023api.
