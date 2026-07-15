# Entrega SAGE — localizador global de pestañas

Fecha: 2026-07-14

## Corrección aplicada

El ejecutor de pestañas ya no limita la búsqueda a un documento elegido de antemano. Recorre recursivamente todos los documentos accesibles, resuelve candidatos funcionales por clave canónica exacta y ejecuta un único mecanismo oficial por acción. El resultado sanitizado informa `found`, `dispatched`, `activated`, cantidad de candidatos, frame, ruta, etiqueta, clase de pestaña, `onclick`, `href` y criterio de coincidencia.

El extractor también reúne las pestañas reales de todos los frames. La etapa Escolares solo se produce cuando se detecta una subpestaña secundaria real: `Historial del alumnado` o `Nivel Superior - Historial`. Ya no se inventa esa opción como fallback. La existencia o preparación del iframe hijo queda como señal adicional, no como prueba suficiente.

La transición al Historial sigue dependiendo exclusivamente del extractor de historial existente. No se construyen URLs, no se usa `history.back()` y no se modificaron reportes V3, PDF, cookies, sesión ni descarga autenticada.

## Archivos modificados

- `lib/funcionalidades/acceso_estudiante/sage_legajo/extractor_legajo_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_legajo/ejecutor_legajo_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_legajo/modelos_legajo_sage.dart`
- `lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart`
- `test/sage_legajo/ejecutor_legajo_sage_test.dart`
- `test/sage_legajo/modelos_legajo_sage_test.dart`

## Verificación automática

- Tests dirigidos: 6/6 aprobados.
- Suite completa `flutter test --no-pub`: 53/53 aprobados.
- Análisis dirigido de archivos modificados: sin issues.
- `flutter analyze --no-pub --no-fatal-infos`: 239 issues informativos/warnings globales preexistentes; la salida conserva tres warnings de métodos no referenciados en `acceso_estudiante_pantalla.dart` y múltiples infos de estilo/deprecaciones fuera de este alcance. No se detectaron errores nuevos en los archivos modificados.

## Validación manual

La validación manual completa sobre una sesión SAGE iniciada queda pendiente. No se automatizó el login, no se ejecutaron inscripciones ni confirmaciones y no se exportaron capturas con datos personales.

## Restricciones respetadas

No se usó Git ni GitHub. No se generaron APK/AAB, no se hizo commit/push y no se modificó la interfaz Flutter de historial, reportes V3, bridge, allowlist, cookies, sesión, descarga autenticada ni PDF.
