# Cambios — Cambio de perfil desde Historial

## Problema corregido

Al pulsar `Cambiar perfil` desde Historial, la WebView continuaba posicionada en el documento profundo del historial. El cambio de grupo se iniciaba desde ese estado y SAGE no reconstruía de manera estable la portada del perfil elegido.

## Nuevo procedimiento

```text
Historial
→ Volviendo al inicio de SAGE…
→ activación del enlace oficial Inicio
→ confirmación de /pregase/menuprincipal_nuevo.php
→ Elegí tu acceso
→ selección de perfil
→ portada inicial del perfil elegido
```

La app utiliza el enlace `Inicio` existente en el breadcrumb de SAGE. No fabrica una URL ni altera la sesión.

## Recuperación

- Retorno al inicio con límite de 14 segundos.
- Sin carga indefinida.
- Si SAGE no confirma el inicio, aparece el selector con un error recuperable.
- El historial anterior y sus cargas automáticas quedan descartados.
- Los extractores de historial no pueden restaurar la pantalla anterior durante el cambio.
- La WebView, las cookies y la sesión se conservan.

- El botón `Reintentar` vuelve a ejecutar el retorno real al inicio de SAGE; ya no se limita a releer los perfiles mientras la WebView permanece en Historial.

## Archivo reemplazado

```text
lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart
```
