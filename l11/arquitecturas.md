# 1. Arquitectura de Autenticación

## Introducción

La arquitectura de autenticación propuesta para LogiMarket Perú S.A.C. tiene como objetivo garantizar un acceso seguro a los servicios de la plataforma mediante la centralización de la autenticación, la gestión de identidades, la protección de credenciales y la implementación de autenticación multifactor. Esta solución permite que los usuarios accedan al Portal Web y a la Aplicación Móvil de manera segura antes de interactuar con los microservicios de Inventario, Pagos y Logística.

## Componentes utilizados

### 1. Portal Web y Aplicación Móvil

Son los puntos de acceso de los usuarios a la plataforma. Desde estos clientes se envían las solicitudes de autenticación y posteriormente se consumen los servicios de negocio disponibles en la arquitectura de microservicios.

### 2. API Gateway

Actúa como punto de entrada único para todas las solicitudes provenientes de los clientes. Su función principal es canalizar las peticiones hacia el Servicio de Autenticación y posteriormente hacia los microservicios correspondientes, permitiendo centralizar aspectos de seguridad y control.

### 3. Servicio de Autenticación (Identity Provider)

Es el componente encargado de validar las credenciales de los usuarios y gestionar el proceso completo de autenticación. Además, coordina la interacción con los servicios de gestión de identidades, contraseñas y autenticación multifactor.

### 4. Gestión de Identidades

Administra la información de usuarios, roles y permisos dentro de la organización. Permite aplicar controles de acceso basados en roles (RBAC), garantizando que cada usuario tenga acceso únicamente a los recursos que le corresponden según sus funciones.

### 5. Gestión de Contraseñas

Se encarga del almacenamiento seguro de las credenciales utilizando algoritmos de hash como Argon2 o bcrypt. También implementa políticas de complejidad, recuperación de contraseñas y mecanismos para prevenir el uso de credenciales débiles o comprometidas.

### 6. Servicio MFA

Implementa la autenticación multifactor mediante códigos OTP, aplicaciones autenticadoras o métodos similares. Este segundo factor añade una capa adicional de seguridad que reduce significativamente el riesgo de accesos no autorizados.

### 7. JWT (JSON Web Token)

Una vez completada la autenticación, el sistema genera un token JWT que contiene información sobre la identidad y permisos del usuario. Este token será utilizado para acceder de forma segura a los distintos microservicios.

### 8. Microservicios de Inventario, Pagos y Logística

Representan los servicios de negocio protegidos por la arquitectura de autenticación. Solo aceptan solicitudes provenientes de usuarios autenticados y autorizados mediante tokens válidos.

## Flujo resumido

1. El usuario accede desde el Portal Web o la Aplicación Móvil.
2. La solicitud es enviada al Servicio de Autenticación a través del API Gateway.
3. El Servicio de Autenticación valida las credenciales mediante la Gestión de Contraseñas.
4. Se verifica la identidad y los permisos del usuario mediante la Gestión de Identidades.
5. Se solicita y valida el segundo factor de autenticación mediante el Servicio MFA.
6. Una vez completada la validación, se genera un token JWT.
7. El usuario utiliza el token para acceder a los microservicios de Inventario, Pagos y Logística.

# 2. Arquitectura de Seguridad para APIs Empresariales

## Introducción

La arquitectura segura para APIs empresariales de LogiMarket Perú S.A.C. está diseñada para proteger la comunicación entre clientes y microservicios mediante mecanismos modernos de autenticación, autorización y control de tráfico. La solución utiliza OAuth 2.0 para la autorización, JWT para la gestión de sesiones, un API Gateway como punto central de acceso y Rate Limiting para proteger los recursos frente a abusos o ataques.

## Componentes utilizados

### 1.Portal Web y Aplicación Móvil

Son los clientes que consumen los servicios empresariales. Desde estos sistemas los usuarios realizan operaciones relacionadas con compras, pagos, inventario y seguimiento logístico.

### 2. Servidor OAuth 2.0

Es el componente responsable de autenticar a los usuarios y otorgar autorización para acceder a los recursos protegidos. Se recomienda utilizar el flujo Authorization Code con PKCE para proporcionar un alto nivel de seguridad tanto en aplicaciones web como móviles.

### 3. JWT (JSON Web Token)

Después de una autenticación exitosa, el servidor OAuth 2.0 genera un token JWT firmado digitalmente. Este token contiene información sobre la identidad, roles, permisos y tiempo de expiración del usuario, permitiendo que los servicios validen la autorización sin necesidad de mantener sesiones centralizadas.

### 4. API Gateway

Funciona como punto único de entrada para todas las solicitudes dirigidas a los microservicios. Centraliza las políticas de seguridad, controla el tráfico y simplifica la administración de la infraestructura.

### 5. Validación de JWT

Este componente verifica la autenticidad, integridad y vigencia de los tokens recibidos. Solo las solicitudes que presentan tokens válidos pueden acceder a los servicios internos.

### 6. Rate Limiting

Controla la cantidad de solicitudes permitidas por usuario o aplicación durante un periodo de tiempo determinado. Su objetivo es evitar abusos, proteger la infraestructura y garantizar una distribución equilibrada de los recursos.

### 7. Logging y Monitoreo

Registra todas las solicitudes y eventos relevantes para facilitar la auditoría, el diagnóstico de problemas y la detección de comportamientos sospechosos dentro de la plataforma.

### 8. Enrutamiento

Dirige las solicitudes autorizadas hacia el microservicio correspondiente según el recurso solicitado, permitiendo una comunicación organizada dentro de la arquitectura.

### 9. Microservicios de Inventario, Pagos y Logística

Procesan la lógica de negocio principal de la empresa. Cada servicio opera de manera independiente y atiende únicamente las solicitudes previamente validadas por el API Gateway.

### 10. Bases de Datos

Almacenan la información utilizada por los microservicios. En una arquitectura de microservicios madura, cada servicio puede disponer de su propia base de datos para mantener independencia y reducir el acoplamiento.

## Flujo resumido

1. El usuario accede desde el Portal Web o la Aplicación Móvil.
2. El cliente solicita autenticación al Servidor OAuth 2.0.
3. El servidor valida las credenciales y genera un JWT.
4. El cliente envía solicitudes incluyendo el token JWT.
5. El API Gateway recibe la solicitud y valida el token.
6. Se aplican las políticas de Rate Limiting.
7. La solicitud es registrada mediante los mecanismos de Logging y Monitoreo.
8. El Gateway enruta la petición hacia el microservicio correspondiente.
9. El microservicio accede a su base de datos y procesa la operación.
10. La respuesta es devuelta al cliente.
