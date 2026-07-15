# Cambios — Selector, salida y cambio de perfil SAGE

## Archivos modificados

```text
lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart
lib/funcionalidades/acceso_estudiante/sage_perfiles/pantalla_selector_perfil_sage.dart
```

## Correcciones aplicadas

### Flecha de regreso en “Elegí tu acceso”

- Se agregó una flecha explícita en la barra superior.
- La acción vuelve a la pantalla inicial general de la aplicación.
- El botón físico Atrás de Android ejecuta la misma salida cuando el selector está visible.
- La barra inferior conserva “Atrás” deshabilitado porque el selector sigue siendo la raíz interna del recorrido SAGE.

### Cambio de perfil desde cualquier pantalla

El botón inferior `Cambiar perfil` ahora limpia el recorrido visual actual y abre el selector sin conservar pantallas del perfil anterior.

Al elegir un perfil:

```text
pantalla interna
→ Elegí tu acceso
→ pantalla de carga
→ portada inicial del perfil elegido
```

Destinos:

```text
Estudiante → portada inicial de módulos de Alumno
Docente → portada inicial del perfil Agente
```

No se intenta encontrar una pantalla equivalente dentro del perfil opuesto.

### Protección contra carga infinita

- El despacho del cambio de perfil tiene un límite de 8 segundos.
- La confirmación completa tiene un límite máximo de 16 segundos.
- Si SAGE no confirma el cambio, la app regresa al selector.
- Se informa que el perfil anterior continúa activo.
- Se puede reintentar sin cerrar sesión.

### Cancelación de transiciones anteriores

Cada cambio recibe un identificador propio. Las respuestas tardías de una navegación anterior quedan descartadas y no pueden restaurar una pantalla vieja.

Al abrir el selector se cancelan:

- carga del historial;
- acciones de navegación pendientes;
- estados de Legajo, Escolares e Historial;
- transiciones pendientes;
- pantallas del perfil anterior.

### Selección del perfil ya activo

Si se toca el perfil actualmente activo, la app no intenta cambiarlo en SAGE. Abre directamente la portada inicial correspondiente.

## Elementos preservados

No se modificaron:

- detectores y ejecutores DOM;
- flujo de acceso y login;
- recorrido de Alumno;
- recorrido de Agente;
- L.U.A.;
- Legajo Alumnos;
- Escolares;
- Historial;
- reportes y PDFs;
- WebView persistente;
- cookies y sesión;
- diseño de las demás pantallas.
