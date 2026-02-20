# Guía de Componentes de Layout (KUDO Web)

Este documento detalla la lógica y funcionalidad de los componentes principales de layout en la aplicación web KUDO (`src/components/layout`). Esta guía tienen como objetivo servir de referencia para la implementación de la lógica equivalente en la plataforma móvil.

## Estructura de Directorios

La lógica de layout está organizada en `src/components/layout` y se divide principalmente en `header` y `body`.

```text
src/components/layout/
├── header/
│   └── TopBar/              # Barra de navegación superior (Landing)
├── body/
│   ├── authenticationscreen/# Lógica de Login y Registro
│   ├── dashboard/           # Panel principal de la aplicación (Post-Login)
│   └── introductionscreen/  # Landing page con efectos de scroll
```

---

## 1. AuthenticationScreen
**Ubicación:** `src/components/layout/body/authenticationscreen/AuthenticationScreen.jsx`

Maneja tanto el inicio de sesión como el registro de nuevos usuarios en una sola pantalla, alternando el estado local.

### Estado (State)
- `isRegistering` (bool): Controla si se muestra el formulario de registro (`true`) o login (`false`).
- `email`, `password`, `confirmPassword`: Campos de formulario.
- `firstName`, `firstSurname`: Campos adicionales para registro.
- `error` (string): Mensajes de error para mostrar al usuario.

### Lógica Clave
- **Servicio de Autenticación**: Utiliza `authService` (`src/services/authService`) para las llamadas a la API.
- **Login (`handleLogin`)**:
  - Llama a `authService.login(email, password)`.
  - Al éxito, guarda el objeto `user` completo en `localStorage` (clave: `'user'`).
  - Navega a `/dashboard`.
- **Registro (`handleRegister`)**:
  - Valida que `password === confirmPassword`.
  - Llama a `authService.register(userData)`.
  - Al éxito, guarda el usuario en `localStorage` y muestra alerta.
  - Cambia `isRegistering` a `false` para permitir el login inmediato (o flujo alternativo según UX).

---

## 2. Dashboard
**Ubicación:** `src/components/layout/body/dashboard/Dashboard.jsx`

Es el contenedor principal para el usuario autenticado. Gestiona la navegación interna entre las diferentes secciones funcionales sin cambiar la ruta del navegador (SPA interna).

### Estado (State)
- `activeTab` (string): Identificador de la vista actual. Valores posibles:
  - `'home'`: Vista principal.
  - `'projects'`: Lista de "Mis Proyectos".
  - `'settings'`: Configuración.
  - `'newproject'`: Formulario de creación de proyecto.

### Componentes Hijos
- **NavigationBar**: Menú lateral izquierdo. Recibe `activeTab` y `onTabChange`.
- **ControlPanel**: Panel superior/derecho (se oculta en `'newproject'`).
- **Main Content**: Renderizado condicional basado en `activeTab`.

### Lógica de Navegación
- La navegación se maneja actualizando el estado `activeTab`.
- El componente `NavigationBar` emite el evento `onTabChange` cuando se hace clic en un ítem.
- **Flujo de Nuevo Proyecto**:
  - Al hacer clic en "Nuevo Proyecto", `activeTab` cambia a `'newproject'`.
  - El componente `NewProject` recibe una prop `onCancel` que restablece `activeTab` a `'home'` para "salir" del modo creación.

---

## 3. IntroductionScreen (Landing)
**Ubicación:** `src/components/layout/body/introductionscreen/IntroductionScreen.jsx`

Landing page pública con lógica de animación basada en scroll (Parallax/Fade).

### Lógica de Scroll y Efectos
Utiliza un `useEffect` para escuchar el evento `window.scroll`.

- **Secciones Activas**: Determina qué sección está activa (`home`, `about`, `opportunities`, `objectives`) basándose en rangos de pixeles de `window.scrollY`.
- **Opacidad y Transformación**:
  - Calcula valores de opacidad (`0` a `1`) y traslación Y dinámicamente según la posición del scroll.
  - **Ejemplo**: La sección "About" aparece (fade in) entre 300px y 800px, y desaparece (fade out) después de 1100px.
  - Esto crea un efecto donde las secciones entran y salen suavemente mientras el usuario hace scroll.

---

## 4. TopBar
**Ubicación:** `src/components/layout/header/TopBar.jsx`

Barra de navegación para la Landing Page.

### Lógica
- Recibe `activeSection` desde `IntroductionScreen` para resaltar el botón actual.
- **Navegación**: Utiliza la función `onNavigate` (pasada por prop) para hacer scroll suave (`window.scrollTo({ behavior: 'smooth' })`) a las posiciones predefinidas de cada sección.
- **Botón de Perfil**: Redirige a `/login`.

---

## Notas para Desarrollo Mobile

1.  **Gestión de Estado**: La web usa `useState` local para formularios y navegación simple. En móvil, evalúen si necesitan un gestor de estado global si la complejidad aumenta.
2.  **Autenticación**:
    - Asegúrense de persistir el token/usuario de forma segura (e.g., `SecureStorage` en lugar de `localStorage`).
    - La lógica de `authService` debería ser reutilizable si comparte la misma API REST.
3.  **Animaciones**: La lógica de scroll de `IntroductionScreen` está muy acoplada a pixeles específicos del navegador web. Para móvil, se recomienda usar las primitivas de animación nativas de la plataforma (ej. `Animated` en RN o animaciones de Compose/SwiftUI) en lugar de escuchar el evento de scroll directamente para calcular opacidades, por rendimiento.
