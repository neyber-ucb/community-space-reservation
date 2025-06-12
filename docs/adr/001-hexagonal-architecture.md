# ADR 001: Adopción de la Arquitectura Hexagonal

## Estado
Aceptado

## Fecha
2025-06-11

## Contexto
Necesitamos implementar un Sistema de Reserva de Espacios Comunitarios como una API de Ruby on Rails 8. El sistema debe soportar registro de usuarios, visualización de disponibilidad de espacios, creación de reservas con notificaciones por correo electrónico y gestión de reservas por parte de administradores. La arquitectura debe asegurar:

1. Modularidad y componentes independientes
2. Clara separación de la lógica de negocio de las preocupaciones de infraestructura
3. Capacidad de prueba de las reglas de negocio de forma aislada
4. Flexibilidad para adaptarse a requisitos cambiantes
5. Mantenibilidad a lo largo del tiempo

## Decisión
Adoptaremos el patrón de Arquitectura Hexagonal (también conocido como Puertos y Adaptadores) para esta aplicación, en lugar de la arquitectura MVC tradicional de Rails.

La aplicación se estructurará en las siguientes capas:

1. **Capa de Dominio**: Contiene entidades de negocio, interfaces de repositorio y servicios de dominio
   - Entidades: Usuario, Espacio, Reserva, Notificación
   - Interfaces de repositorio: UserRepository, SpaceRepository, BookingRepository, NotificationRepository
   - Servicios de dominio: BookingService, NotificationService

2. **Capa de Aplicación**: Contiene casos de uso que orquestan objetos de dominio
   - Casos de uso: RegisterUser, AuthenticateUser, ListSpaces, CreateBooking, ConfirmBooking, CancelBooking, ListBookings

3. **Capa de Infraestructura**: Contiene implementaciones de repositorios y servicios externos
   - Repositorios ActiveRecord: ActiveRecordUserRepository, ActiveRecordSpaceRepository, etc.
   - Servicios: EmailNotificationService

4. **Capa de Interfaces**: Contiene controladores y endpoints de API
   - Controladores: UsersController, AuthenticationController, SpacesController, BookingsController

## Consecuencias

### Positivas
1. **Mejora de la Testabilidad**: La lógica de negocio puede ser probada de forma aislada sin dependencias de infraestructura
2. **Mejor Separación de Preocupaciones**: Límites claros entre la lógica de negocio y la infraestructura
3. **Flexibilidad**: Mayor facilidad para reemplazar componentes (por ejemplo, base de datos, sistema de notificaciones) sin afectar la lógica de negocio
4. **Diseño Dirigido por el Dominio**: Enfoque en modelar el dominio de negocio con precisión
5. **Mantenibilidad**: Una organización de código más clara hace que el sistema sea más fácil de entender y mantener

### Negativas
1. **Mayor Complejidad**: Más capas e indirección en comparación con el MVC estándar de Rails
2. **Curva de Aprendizaje**: Los desarrolladores familiarizados con las convenciones de Rails necesitan adaptarse a esta arquitectura
3. **Código Repetitivo**: Se necesita más código para interfaces, implementaciones y mapeos
4. **Sobrecarga de Rendimiento**: Mapeo adicional entre entidades de dominio y modelos ActiveRecord

## Notas de Implementación
- Las entidades de dominio se implementan como objetos Ruby simples (POROs)
- Las interfaces de repositorio definen contratos que las implementaciones deben cumplir
- Los casos de uso orquestan objetos de dominio y repositorios para cumplir con los requisitos de negocio
- ActiveRecord se utiliza solo en la capa de infraestructura
- Los controladores son ligeros y delegan en casos de uso
