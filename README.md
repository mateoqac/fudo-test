# Fudo Test

Este es un proyecto de prueba que implementa una API REST para gestionar productos. La API incluye autenticación JWT y operaciones CRUD básicas para productos.

## Requisitos

- Ruby 3.3.4
- Docker y Docker Compose (opcional)

## Configuración del Entorno

### Variables de Entorno

El proyecto requiere variables de entorno para funcionar correctamente. Para configurarlas:

1. Copia el archivo de ejemplo de variables de entorno:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus valores:
   ```bash
   # Token secreto para JWT
   TOKEN_SECRET=tu_token_secreto_aqui
   ```

> **Nota**: El archivo `.env` no debe subirse al repositorio Git. Asegúrate de que esté en el `.gitignore`.

## Instalación

### Sin Docker

1. Clona el repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd fudo-test
   ```

2. Instala las dependencias:
   ```bash
   bundle install
   ```

3. Inicia el servidor:
   ```bash
   bundle exec rackup
   ```

### Con Docker

1. Clona el repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd fudo-test
   ```

2. Asegúrate de tener el archivo `.env` configurado (ver sección "Configuración del Entorno")

3. Construye y ejecuta el contenedor:
   ```bash
   docker compose up
   ```

El servidor estará disponible en `http://localhost:9292`.

## Uso de la API

### Autenticación

Para obtener un token JWT, realiza una solicitud POST a `/auth`:

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -d '{"user":"admin","password":"secret"}'
```

### Crear un Producto

```bash
curl -X POST http://localhost:9292/products \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name":"Producto de prueba"}'
```

### Listar Productos

```bash
curl http://localhost:9292/products \
  -H "Authorization: Bearer <token>"
```

### Obtener Producto por ID

```bash
curl http://localhost:9292/products/<id> \
  -H "Authorization: Bearer <token>"
```

### Compresión Gzip

La API soporta compresión gzip para todas las respuestas. Para solicitar una respuesta comprimida, incluye el header `Accept-Encoding: gzip` en tu petición:

```bash
curl http://localhost:9292/products \
  -H "Authorization: Bearer <token>" \
  -H "Accept-Encoding: gzip"
```

## Notas sobre la Implementación

### Arquitectura Modular

La aplicación sigue un patrón de arquitectura MVC (Modelo-Vista-Controlador) modularizado:

1. **Modelos**: Encapsulan la lógica de negocio y el acceso a datos.
   - `Product`: Representa un producto con validaciones.
   - `ProductStore`: Almacena productos en memoria y maneja concurrencia.

2. **Controladores**: Procesan las solicitudes HTTP y coordinan la respuesta.
   - `AuthController`: Maneja la autenticación.
   - `ProductsController`: Gestiona las operaciones CRUD de productos.
   - `StaticController`: Sirve archivos estáticos con configuraciones de caché.

3. **Router**: Enruta las solicitudes a los controladores apropiados.
   - Define rutas basadas en patrones de URL.
   - Soporta rutas con parámetros dinámicos.

4. **Middleware**:
   - `AuthMiddleware`: Verifica tokens JWT para rutas protegidas.

Esta arquitectura facilita:
- Mantenibilidad: Cada componente tiene una responsabilidad clara.
- Escalabilidad: Es fácil añadir nuevos controladores o modelos.
- Testabilidad: Cada componente puede ser probado de forma independiente.

### Uso de Mutex en lugar de Base de Datos

En este proyecto, hemos optado por utilizar un `Mutex` y almacenamiento en memoria en lugar de una base de datos por las siguientes razones:

1. **Simplicidad para el Challenge**:
   - El uso de un Mutex nos permite implementar la funcionalidad básica sin la complejidad adicional de configurar y mantener una base de datos.
   - Es suficiente para demostrar la lógica de negocio y el manejo de concurrencia.

2. **Rendimiento en Desarrollo**:
   - No hay sobrecarga de configuración de base de datos.
   - Inicio más rápido del servidor.
   - Más fácil de probar y depurar.

3. **Limitaciones**:
   - Los datos se pierden al reiniciar el servidor.
   - No es adecuado para producción.
   - Limitado a un solo servidor.

4. **Manejo de Concurrencia**:
   - El Mutex asegura que las operaciones de escritura sean atómicas.
   - Previene condiciones de carrera en operaciones simultáneas.
   - Demuestra buenas prácticas de programación concurrente.

En un entorno de producción, se recomendaría usar una base de datos real como PostgreSQL o MongoDB para persistencia y escalabilidad.

## Tests

Para ejecutar los tests:

```bash
bundle exec rspec
```

Los tests están organizados siguiendo la misma estructura que el código:

```
spec/
├── controllers/              # Tests de controladores
│   ├── auth_controller_spec.rb
│   ├── products_controller_spec.rb
│   └── static_controller_spec.rb
├── models/                   # Tests de modelos
│   └── product_store_spec.rb
└── router_spec.rb            # Tests del router
```

## Estructura del Proyecto

La aplicación sigue un patrón de arquitectura MVC (Modelo-Vista-Controlador) modularizado:

```
.
├── Dockerfile
├── Gemfile
├── README.md
├── config.ru
├── docker-compose.yml
├── public/
│   ├── AUTHORS
│   └── openapi.yaml
└── lib/
    ├── app.rb                      # Aplicación principal
    ├── router.rb                   # Enrutador de peticiones
    ├── auth_middleware.rb          # Middleware de autenticación
    ├── config.rb                   # Configuración de la aplicación
    ├── controllers/                # Controladores
    │   ├── auth_controller.rb      # Controlador de autenticación
    │   ├── products_controller.rb  # Controlador de productos
    │   └── static_controller.rb    # Controlador de archivos estáticos
    └── models/                     # Modelos
        ├── product.rb              # Modelo de producto
        └── product_store.rb        # Almacén de productos en memoria
```

## Endpoints
- **Autenticación**: POST /auth
- **Crear producto**: POST /products
- **Listar productos**: GET /products
- **Obtener producto por ID**: GET /products/{id}
- **OpenAPI**: GET /openapi.yaml
- **Autores**: GET /AUTHORS

## Recursos y Documentación

- [Documentación de Rack](https://github.com/rack/rack)
- [Documentación de RSpec](https://rspec.info/)

## Mejoras de Seguridad Sugeridas

Para un entorno de producción, se recomiendan las siguientes mejoras de seguridad:

1. **Rate Limiting**: Implementar límites de tasa para prevenir ataques de fuerza bruta, especialmente en el endpoint de autenticación.
2. **Headers de Seguridad**: Agregar headers de seguridad estándar como X-Content-Type-Options, X-Frame-Options, etc.
3. **JWT Mejorado**: Implementar expiración de tokens y refresh tokens para mejorar la seguridad de la autenticación.

Estas mejoras son opcionales y pueden implementarse según las necesidades específicas del proyecto.

## Ejemplos
Autenticación:
```bash
curl -X POST -H "Content-Type: application/json" \
-d '{"user":"admin","password":"secret"}' http://localhost:9292/auth
