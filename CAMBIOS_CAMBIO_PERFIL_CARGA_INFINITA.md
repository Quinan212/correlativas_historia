# Corrección — Cambio de perfil bloqueado en “Preparando tus servicios académicos”

## Problema observado

Con el perfil `Agente` activo, al elegir `Estudiante` desde `Elegí tu acceso`, SAGE iniciaba la recarga, pero la interfaz quedaba indefinidamente en:

```text
Preparando tus servicios académicos…
```

## Causa corregida

El ciclo periódico que inspecciona el DOM y confirma la pantalla de destino se cancelaba al iniciar el cambio de perfil y no se reactivaba. Además, el modo de navegación manual impedía que una recarga tardía sustituyera la pantalla de carga por la portada nueva.

Una recarga que comenzara después de la confirmación podía volver a activar el loader sin que quedara un observador capaz de retirarlo.

## Cambios aplicados

- El observador periódico de SAGE permanece activo durante el cambio de perfil.
- Después de una recarga, se programan nuevas inspecciones a los 250, 800, 1600 y 3000 ms.
- Al confirmar un perfil, el flujo vuelve a permitir que el detector real del DOM estabilice la portada.
- La pantalla de carga ya no bloquea las inspecciones necesarias para completar la transición.
- Se agregó un watchdog de 22 segundos como última protección.
- Si el cambio no termina, la app vuelve a `Elegí tu acceso` con un error recuperable.
- Si una recarga tardía comienza después de un fallo, el selector permanece visible y no vuelve a quedar tapado por un loader infinito.
- Durante el cambio se conserva el mensaje específico `Cambiando a Estudiante…` o `Cambiando a Docente…`.
- La inspección del historial queda suspendida mientras se cambia o se selecciona un perfil, evitando que reaparezca contenido del perfil anterior.

## Archivo reemplazado

```text
lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart
```

No se modificaron extractores, ejecutores, pantallas visuales, historial, reportes ni navegación interna.
