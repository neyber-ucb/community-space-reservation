# Sistema de Reserva de Espacios Comunitarios

Una aplicación API de Ruby on Rails 8 construida con arquitectura hexagonal para gestionar reservas de espacios comunitarios.

## Visión General de la Arquitectura

Esta aplicación sigue la arquitectura hexagonal (puertos y adaptadores) con la siguiente estructura:

```
app/
├── controllers/                # Adaptadores primarios (interfaz HTTP)
├── domain/                     # Modelos de dominio central y lógica de negocio
│   ├── entities/               # Entidades de dominio
│   ├── repositories/           # Interfaces de repositorio (puertos)
│   └── services/               # Servicios de dominio
├── application/                # Capa de aplicación
│   ├── use_cases/              # Casos de uso que orquestan la lógica de dominio
│   └── commands/               # Objetos de comando para casos de uso
├── infrastructure/             # Adaptadores secundarios
│   ├── repositories/           # Implementaciones de repositorio
│   ├── notifications/          # Servicios de notificación
│   └── persistence/            # Código específico de base de datos
└── interfaces/                 # Puertos
    ├── controllers/            # Controladores HTTP
    └── api/                    # Definiciones de API
```

## Atributos de Calidad

1. **Mantenibilidad**: La arquitectura hexagonal asegura la separación de preocupaciones, haciendo que el sistema sea más fácil de mantener y modificar.
2. **Testabilidad**: La lógica de dominio está aislada de dependencias externas, facilitando las pruebas.
3. **Flexibilidad**: La arquitectura permite el fácil reemplazo de componentes de infraestructura sin afectar la lógica de negocio central.

## Primeros Pasos

### Prerrequisitos

- Ruby 3.3+
- PostgreSQL
- Rails 8.0.2+

### Configuración

1. Clonar el repositorio
2. Ejecutar `bundle install`
3. Configurar la base de datos: `rails db:create db:migrate`
4. Iniciar el servidor: `rails server`

## Documentación de la API

La documentación de la API estará disponible en `/api/docs` cuando el servidor esté en funcionamiento.

Cosas que podrías querer cubrir:

* Versión de Ruby

* Dependencias del sistema

* Configuración

* Creación de base de datos

* Inicialización de base de datos

* Cómo ejecutar el conjunto de pruebas

* Servicios (colas de trabajo, servidores de caché, motores de búsqueda, etc.)

* Instrucciones de despliegue

* ...
