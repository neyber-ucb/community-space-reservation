# ADR 002: Autenticación y Autorización Basada en JWT

## Estado
Aceptado

## Fecha
2025-06-11

## Contexto
El Sistema de Reserva de Espacios Comunitarios requiere un mecanismo de autenticación seguro para los usuarios que acceden a la API. Necesitamos:

1. Permitir a los usuarios registrarse e iniciar sesión
2. Asegurar los endpoints de la API solo para usuarios autenticados
3. Diferenciar entre usuarios regulares y administradores
4. Mantener una arquitectura de API sin estado
5. Asegurar que se sigan las mejores prácticas de seguridad

## Decisión
Implementaremos un sistema de autenticación basado en JWT (JSON Web Token) con las siguientes características:

1. **Autenticación Basada en Tokens**: Los usuarios recibirán un JWT tras un inicio de sesión exitoso
2. **Autenticación Sin Estado**: Sin almacenamiento de sesiones en el servidor
3. **Autorización Basada en Roles**: El JWT contendrá información sobre el rol del usuario (usuario/administrador)
4. **Expiración de Tokens**: Los JWT tendrán un tiempo de expiración configurable (por defecto 24 horas)
5. **Almacenamiento Seguro de Tokens**: Almacenamiento del lado del cliente en cookies HTTP-only seguras o almacenamiento local seguro

El flujo de autenticación será:

1. El usuario se registra con correo electrónico y contraseña (contraseña almacenada con bcrypt)
2. El usuario inicia sesión con credenciales y recibe un JWT
3. El JWT se incluye en el encabezado de Autorización para solicitudes posteriores
4. El servidor valida la firma del JWT y la expiración para cada solicitud
5. Los roles de usuario se extraen del JWT para las comprobaciones de autorización

## Consecuencias

### Positivas
1. **Arquitectura Sin Estado**: No hay necesidad de almacenamiento de sesiones en el servidor, mejorando la escalabilidad
2. **Autenticación Entre Servicios**: El JWT puede ser validado a través de diferentes servicios
3. **Reducción de Consultas a la Base de Datos**: La información del usuario puede extraerse del token
4. **Flexibilidad**: Puede usarse con varios clientes (web, móvil, etc.)
5. **Seguridad**: Hash de contraseñas con bcrypt y tokens firmados

### Negativas
1. **Tamaño del Token**: Los JWT pueden ser más grandes que los ID de sesión
2. **Revocación de Tokens**: Difícil invalidar tokens antes de su expiración
3. **Gestión de Secretos**: Necesidad de gestionar de forma segura el secreto de firma JWT
4. **Almacenamiento del Lado del Cliente**: Necesidad de manejar el almacenamiento de tokens de forma segura en el cliente

## Notas de Implementación
- Uso de la gema `jwt` para la generación y validación de tokens
- Clave secreta JWT almacenada en variables de entorno
- Middleware de autenticación para validar tokens en rutas protegidas
- Contraseñas de usuario hasheadas usando bcrypt
- Comprobaciones de autorización basadas en roles en los controladores
- Expiración de tokens establecida en 24 horas por defecto
- Secretos JWT específicos del entorno (desarrollo vs producción)

## Alternativas Consideradas
1. **Autenticación basada en sesiones**: Rechazada debido a la naturaleza con estado y preocupaciones de escalabilidad
2. **OAuth**: Considerado demasiado complejo para los requisitos actuales
3. **Claves API**: No es amigable para el usuario para el público objetivo
