# Corrección selector y flujo Agente SAGE

Fecha: 2026-07-14

## Problemas corregidos

- El selector de perfil ahora puede detectar controles aunque el panel de perfil esté cerrado, recorriendo documentos accesibles y buscando avatar, radio, label y `role="radio"`.
- El cambio de perfil resuelve correctamente input, label asociado por `for`/`control` y radio accesible. No se fabrica un POST.
- `activated` ya no equivale a éxito: el cambio requiere `found`, `dispatched`, `activated` y `confirmed`.
- La confirmación espera radio marcado o firma de portada. Para Agente exige `Legajo Único Personal`; para Alumnos exige `Legajo Alumnos`.
- La selección se conserva durante el flujo y no se reinicia al activar enlaces internos.
- La portada Agente se extrae dinámicamente del documento que contiene el módulo `Módulos` y `Legajo Único Personal`; no usa el DOM residual de subpantallas.
- La pantalla Docente separa Módulos, Submódulos e Informes. Los informes se toman del DOM y no se fija el período.
- Se agregó una pantalla separada para `Legajo Único Personal` con las opciones observadas disponibles.

## Archivos nuevos

- `lib/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/detector_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/ejecutor_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/pantalla_selector_perfil_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/modelos_agente_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/extractor_agente_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/pantalla_portada_agente_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/pantalla_legajo_personal_sage.dart`
- `test/sage_perfiles/perfiles_sage_test.dart`
- `test/sage_perfiles/ejecutor_perfiles_sage_test.dart`

## Archivos modificados

- `lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_navegacion/modelos_navegacion_sage.dart`

## Flujo y reutilización

La misma WebView, sesión, cookies, extractor de Legajo, Escolares, historial, materias y reportes siguen siendo compartidos. La opción `Alumnos por Docente Nivel Superior` se activa mediante el enlace oficial y el localizador global existente, priorizando texto exacto antes que pathname compartido.

## Pruebas

- Tests dirigidos de perfiles: 3/3 aprobados.
- Suite completa `flutter test --no-pub`: 56/56 aprobados.
- Formateo Dart completado.
- El análisis dirigido quedó iniciado pero el proceso de análisis no entregó una salida final en esta ejecución; los tests compilaron todos los archivos nuevos y no mostraron errores de compilación.

## Validación manual pendiente

Todavía debe probarse con sesión SAGE real el recorrido completo Docente: selección del alumno, Secciones, Escolares, Nivel Superior - Historial, carreras, materias y reportes. No se declara cerrado ese criterio hasta ejecutar esa prueba. El flujo Estudiante conserva la suite automática aprobada.

No se usó Git, commit, push, APK ni AAB. No se modificaron cookies, reportes V3, descarga autenticada, visor PDF ni el extractor/controlador/pantalla de historial.
