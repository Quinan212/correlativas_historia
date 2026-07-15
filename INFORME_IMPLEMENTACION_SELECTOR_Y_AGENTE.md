# Implementación selector de perfil y flujo Agente SAGE

Fecha: 2026-07-14

## Arquitectura aplicada

Se agregó una capa independiente `sage_perfiles` para centralizar:

- `PerfilSage.alumnos` y `PerfilSage.agente`.
- Normalización de etiquetas oficiales y aliases nativos Estudiante/Docente.
- Detección de controles disponibles y perfil activo.
- Cambio de perfil mediante el control oficial radio/label del DOM.
- Resultado explícito `found`, `dispatched` y `activated`.

Se agregó `sage_agente` para representar la portada Docente con las opciones observadas en la auditoría. La WebView existente se mantiene montada y las opciones se activan mediante el mismo ejecutor de enlaces oficiales de SAGE.

## Archivos creados

- `lib/funcionalidades/acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/detector_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/ejecutor_perfiles_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_perfiles/pantalla_selector_perfil_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/modelos_agente_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_agente/pantalla_portada_agente_sage.dart`
- `test/sage_perfiles/perfiles_sage_test.dart`
- `test/sage_perfiles/ejecutor_perfiles_sage_test.dart`

## Archivos modificados

- `lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_navegacion/modelos_navegacion_sage.dart`

## Flujo Estudiante

Se conserva la WebView, el detector existente, el recorrido de Legajo Alumnos, Escolares, Historial, materias y reportes. La suite completa continúa aprobando.

## Flujo Docente

La portada Agente se reconoce por la presencia conjunta de `Legajo Único Personal` y `Alumnos por Docente Nivel Superior` en los documentos accesibles. Flutter muestra las secciones Módulos, Submódulos e Informes. La opción prioritaria `Alumnos por Docente Nivel Superior` se ejecuta mediante el enlace oficial de SAGE, sin construir URLs.

## Selectores y mecanismos

- Avatar: `button[aria-label="Mi perfil"]` o `.btn-user`.
- Perfiles: controles radio, label o `role="radio"` con etiqueta exacta `Agente`/`Alumnos`.
- Cambio: click sobre el control oficial encontrado; no se ejecuta POST manual.
- Portada Agente: enlaces reales resueltos por el localizador global existente.

## Pruebas

- Tests dirigidos nuevos: 3/3 aprobados.
- Suite completa `flutter test --no-pub`: 56/56 aprobados.
- Se respetaron reportes V3, extractor/controlador/pantalla de historial, cookies, sesión, descarga autenticada y PDF.

## Validación manual y limitaciones

Queda pendiente validar con una sesión SAGE iniciada:

1. selector Estudiante/Docente;
2. reconstrucción de portada tras el cambio;
3. selección docente de alumno;
4. Escolares y Nivel Superior - Historial desde el perfil Agente;
5. compatibilidad final de `#list9`, materias y reportes.

No se ejecutaron inscripciones ni confirmaciones. No se generó APK/AAB. No se usó Git ni GitHub.
