#import "@preview/mmdr:0.2.2": mermaid

#set par(justify: true)

= Actividad 2: Diseño de Autenticación Segura

Para LogiMarket Perú S.A.C., se diseña una arquitectura de autenticación que aborde los incidentes de accesos no autorizados y credenciales compartidas, siguiendo las directrices del NIST Cybersecurity Framework @nist2024csf y el patrón de autenticación a nivel de borde (edge-level) recomendado por @owasp2024microservices.

== Arquitectura Propuesta

#figure(
  box(width: 90%)[
    #mermaid(
      "
  flowchart TD
      %% Subgraphs
      subgraph Clientes[\"Clientes\"]
          WEB[\"Portal Web\"]
          MOB[\"Aplicación Móvil\"]
      end

      subgraph Auth[\"Capa de Autenticación\"]
          GW[\"API Gateway<br>Rate Limiting + TLS\"]
          IDP[\"Servicio de Autenticación<br>Identity Provider\"]
          MFA[\"Servicio MFA<br>TOTP / OTP\"]
          ID[\"Gestión de Identidades<br>RBAC\"]
          PWD[\"Gestión de Contraseñas<br>Argon2 / bcrypt\"]
      end

      subgraph Token[\"Generación de Token\"]
          JWT[\"JWT<br>RS256 - 15min exp\"]
      end

      subgraph Services[\"Microservicios\"]
          INV[\"Inventario\"]
          PAG[\"Pagos\"]
          LOG[\"Logística\"]
      end

      %% Flow Relationships
      WEB --> GW
      MOB --> GW
      GW --> IDP
      IDP --> PWD
      IDP --> ID
      IDP --> MFA
      MFA -->|2FA válido| JWT
      JWT --> GW
      GW -->|token validado| INV
      GW -->|token validado| PAG
      GW -->|token validado| LOG
  ",
    )
  ],
  caption: [Diagrama de arquitectura de autenticación para LogiMarket Perú S.A.C.],
) <fig-auth-arch>

== Componentes Principales

=== 1. Portal Web y Aplicación Móvil

Son los puntos de acceso de los usuarios a la plataforma. Desde estos clientes se envían las solicitudes de autenticación y posteriormente se consumen los servicios de negocio disponibles en la arquitectura de microservicios. Cada cliente implementa flujos de autenticación seguros que incluyen validación de certificados TLS y protección contra replay attacks.

=== 2. API Gateway

Actúa como punto de entrada único para todas las solicitudes provenientes de los clientes, siguiendo el patrón de API Gateway documentado por @owasp2024microservices. Su función principal es canalizar las peticiones hacia el Servicio de Autenticación y posteriormente hacia los microservicios correspondientes, permitiendo centralizar aspectos de seguridad y control. Implementa rate limiting para proteger contra ataques de fuerza bruta y DDoS.

=== 3. Servicio de Autenticación (Identity Provider)

Es el componente encargado de validar las credenciales de los usuarios y gestionar el proceso completo de autenticación. Coordina la interacción con los servicios de gestión de identidades, contraseñas y autenticación multifactor. Utiliza el flujo OAuth 2.0 con PKCE para garantizar un alto nivel de seguridad @owasp2023api.

=== 4. Gestión de Identidades (RBAC)

Administra la información de usuarios, roles y permisos dentro de la organización. Permite aplicar controles de acceso basados en roles (RBAC), garantizando que cada usuario tenga acceso únicamente a los recursos que le corresponden según sus funciones. Los roles definidos incluyen: admin, user y guest, con permisos jerárquicos.

=== 5. Gestión de Contraseñas

Se encarga del almacenamiento seguro de las credenciales utilizando algoritmos de hash como Argon2 o bcrypt. Implementa políticas de complejidad (mínimo 12 caracteres, combinación de mayúsculas, números y símbolos), recuperación de contraseñas por email y mecanismos para prevenir el uso de credenciales débiles o comprometidas @bugcrowd2025mfa.

=== 6. Servicio MFA

Implementa la autenticación multifactor mediante códigos TOTP (Time-Based One-Time Password) compatible con aplicaciones como Google Authenticator y Authy. El segundo factor añade una capa adicional de seguridad que reduce significativamente el riesgo de accesos no autorizados, incluso cuando las credenciales primarias son comprometidas @rsa2026mfa.

=== 7. JWT (JSON Web Token)

Una vez completada la autenticación, el sistema genera un token JWT firmado digitalmente con el algoritmo RS256 que contiene información sobre la identidad y permisos del usuario. El token incluye claims estándar (sub, iss, exp, iat, roles) y tiene una expiración de 15 minutos para tokens de acceso y 7 días para refresh tokens.

== Flujo de Autenticación

1. El usuario ingresa credenciales en el Portal Web o Aplicación Móvil.
2. La solicitud es enviada al Servicio de Autenticación a través del API Gateway.
3. El Servicio de Autenticación valida las credenciales mediante la Gestión de Contraseñas.
4. Se verifica la identidad y los permisos del usuario mediante la Gestión de Identidades.
5. Se solicita y valida el segundo factor de autenticación mediante el Servicio MFA.
6. Una vez completada la validación, se genera un token JWT con expiración controlada.
7. El usuario utiliza el token para acceder a los microservicios de Inventario, Pagos y Logística.

La combinación de estos mecanismos mitiga los vectores de ataque identificados en la matriz de riesgos, incluyendo broken authentication (API2), credential stuffing y ataques de fuerza bruta, como se documenta en el OWASP API Security Top 10 @owasp2023api.
