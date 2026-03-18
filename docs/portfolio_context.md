# 🚀 KudoApp - Contexto para Portafolio Profesional

## 📌 Contexto General del Proyecto
**KudoApp** es una plataforma integral de evaluación, votación y retroalimentación ("kudos") diseñada específicamente para eventos, ferias de ciencias, hackathons y exposiciones de proyectos universitarios o corporativos. 

El ecosistema de la aplicación consta de tres componentes principales:
1. **Un Backend (API REST):** Que maneja toda la lógica de negocio, seguridad y persistencia de votos, usuarios, proyectos y comentarios.
2. **Una Aplicación Móvil (App):** Orientada a los asistentes, jueces y evaluadores del evento.
3. **Una Plataforma Web (Dashboard):** Enfocada en la administración, visualización de proyectos, métricas en tiempo real y ranking de los mejores evaluados.

---

## ⚠️ El Problema
Durante los eventos de exposición de proyectos (como ferias tecnológicas o hackathons), el proceso de evaluación y votación suele ser caótico, desorganizado y poco interactivo. 
- Los jueces o asistentes suelen evaluar usando papel o formularios genéricos y tediosos.
- No hay retroalimentación (feedback) estructurada, instantánea ni anónima para los creadores.
- Consolidar los resultados toma demasiado tiempo, impidiendo premiar o mostrar un "leaderboard" (ranking) en tiempo real transparente.
- Falta una manera rápida de enlazar físicamente el stand de un proyecto con su información digital detallada.

---

## 💡 La Solución
Se desarrolló **KudoApp**, un sistema moderno que digitaliza y gamifica el proceso de evaluación mediante el uso de códigos QR.
- **Acceso Inmediato:** Cada proyecto registrado cuenta con un Código QR único impreso en su stand. Los evaluadores usan la aplicación móvil para escanearlo y acceder instantáneamente a la ficha técnica del proyecto (descripción, rol del creador, tecnologías usadas, galería de imágenes, video demostrativo y resultados).
- **Votación Dinámica:** Una vez escaneado, el usuario evalúa el proyecto asignando de 1 a 5 estrellas, dejando comentarios (feedback valioso) y etiquetas (tags) destacando fuentes como "Innovador", "Buen Diseño", etc.
- **Visualización y Rankings en Tiempo Real:** La plataforma web sirve como un *dashboard* administrativo e interactivo donde se puede ver el estado global del evento y una pantalla de "Ranking" que actualiza las posiciones de los proyectos basada en sus puntajes ponderados y cantidad de "kudos" recibidos, creando un ambiente emocionante de competencia sana.

---

## 🛠️ Tecnologías y Stack Implementado

El proyecto está construido bajo una arquitectura moderna dividida en tres repositorios o módulos principales:

### 1. 📱 Frontend Móvil (Kudo App)
Aplicación nativa compilada para múltiples plataformas, enfocada en la experiencia ágil del usuario (escanear y votar).
- **Framework:** Flutter (Dart)
- **Librerías Destacadas:** 
  - `mobile_scanner`: Para la lectura rápida de códigos QR.
  - `flutter_rating_bar`: Para la interfaz intuitiva de calificación por estrellas.
  - `provider`: Para la gestión reactiva del estado de la aplicación.
  - `shared_preferences` / `http`: Para persistencia local y consumo de la API REST.

### 2. 💻 Frontend Web (Kudo Dashboard)
Plataforma web responsiva y rápida, enfocada en la administración y muestra de resultados.
- **Librería / Framework:** React 19
- **Herramienta de Construcción:** Vite (con plugin SWC para compilación ultra-rápida y HMR).
- **Enrutamiento:** React Router DOM (v7).
- **Estilos:** CSS Modules y diseño modularizado.

### 3. ⚙️ Backend y API (Kudo Api)
Arquitectura robusta, segmentada mediante patrones de diseño tipo *Clean Architecture* (Core, Domain, Application, Infrastructure).
- **Framework:** .NET Core / ASP.NET 8 (C#)
- **Base de Datos / ORM:** Entity Framework Core.
- **Patrones y Prácticas:** 
  - Controladores RESTful (`ProjectsController`, `VotesController`, `ReviewsController`, etc.).
  - Inyección de dependencias y servicios orientados a dominio (Manejo de rutas para QR, evaluación de votos, seguridad).
  - Docker: Incluye un `Dockerfile` configurado para su contenerización y despliegue agnóstico.
