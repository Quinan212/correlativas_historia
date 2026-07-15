# Primera etapa — navegación nativa inicial de SAGE

## Alcance implementado

Se agregaron las capas nativas para:

1. Módulos posteriores al login.
2. Submódulos de Legajo Único Alumno.

El login, el historial, los reportes V3, la extracción B1/B2, el visor PDF y la WebView existente permanecen en sus recorridos actuales.

## Integración

- Se reutiliza el único `Timer.periodic` de dos segundos existente en `PantallaSage`.
- La detección general se ejecuta dentro de `_probeHistory()`, usando el mismo guard de sondeo.
- La WebView queda montada con `maintainState: true` y solo se oculta visualmente cuando aparece una capa nativa.
- Los enlaces se buscan recursivamente en frames accesibles del mismo origen.
- La acción se ejecuta con `anchor.click()` sobre el enlace oficial encontrado; no se usa `loadRequest()` ni se fabrican URLs o parámetros.
- El historial mantiene prioridad visual sobre módulos y submódulos.

## Señales del detector

El detector conserva un documento independiente por ventana/frame: host, pathname, id/nombre del frame, profundidad, visibilidad, encabezados funcionales y enlaces visibles. Solo conserva texto funcional y pathnames sanitizados; no captura inputs, cookies, query parameters ni filas personales.

Las rutas posteriores (`/dic/Listar2.php`, `/dic/tabs.php`, `/alumnos_v2/` y `/alumnosAdminPanel/`) bloquean módulos y submódulos aunque otro frame conserve enlaces antiguos. Encabezado y enlaces deben pertenecer al mismo documento.

Estados implementados:

- `desconocido`
- `login`
- `modulos`
- `submodulosLegajoUnico`
- `otraPagina`
- `sesionVencida`
- `error`

## Archivos creados

- `lib/funcionalidades/acceso_estudiante/sage_navegacion/modelos_navegacion_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_navegacion/detector_navegacion_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_navegacion/pantalla_modulos_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_navegacion/pantalla_submodulos_sage.dart`
- `test/sage_navegacion/detector_navegacion_sage_test.dart`

## Archivo modificado

- `lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart`

No se modificó la copia de `sage_historial/pantalla_sage.dart`, ni los archivos de reportes V3, extractor, historial o visor PDF.

## Verificación automática

- `flutter test --no-pub`: 38 tests pasaron.
- `flutter analyze --no-pub --no-fatal-infos`: completado correctamente.
- Análisis dirigido de los archivos nuevos y de la pantalla activa: `No issues found!`.

## Verificación de ejecución

- Emulador `emulator-5554`: la app compiló, instaló y arrancó mediante `flutter run`.
- Samsung: estuvo conectado durante el arranque y hot reload, pero ADB perdió la conexión antes de completar el recorrido manual.
- Por ese motivo quedan pendientes la permanencia de 6 segundos en `/dic/Listar2.php`, las capturas de las dos pantallas nativas y la comprobación manual completa login → módulos → submódulos → Legajo Alumnos → historial.

No se ejecutaron inscripciones, confirmaciones ni envíos. No se hizo commit, push ni publicación.
