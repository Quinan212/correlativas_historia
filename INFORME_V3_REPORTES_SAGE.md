# Informe V3 — reportes SAGE

## Resultado

La causa confirmada era que SAGE no usaba `window.open`: los tres handlers jQuery ejecutaban funciones oficiales dentro de `frm_alumnos_escolares` que asignaban `location.href`. Por eso el interceptor V2 no recibía ningún enlace.

La V3 envuelve esas funciones, conserva la expresión original que calcula la URL y reemplaza solamente la asignación final por un mensaje al puente Flutter. No se reconstruyen URLs ni parámetros.

## Funciones transformadas

- Situación académica — `imprimir_estado_alumno` — hash observado: `3ef0b38a`.
- Analítico — `imprimir_analitico` — hash observado: `83025641`.
- Libreta — `imprimir_examenes_rendidos` — hash observado: `fe038b3`.

Transformación segura: sí; una asignación compatible por función.
Compilación en `frm_alumnos_escolares`: sí.
Handler jQuery preservado: sí.
URL construida manualmente: no.
Navegación efectiva mediante `location.href`: no; se entregó el valor calculado al puente.

## Validación real

La ejecución V3 válida se realizó en `emulator-5554`, usando únicamente el proceso de esa ejecución. Los tres controles produjeron mensaje `sage_report_url`, URI permitida, descarga autenticada HTTP 200 y visor PDF abierto.

| Reporte | Función V3 | Mensaje | Descarga | HTTP | PDF | Timeout | 404 |
|---|---|---|---|---:|---|---|---|
| Situación académica | sí | sí | sí | 200 | sí | no | no |
| Analítico | sí | sí | sí | 200 | sí | no | no |
| Libreta | sí | sí | sí | 200 | sí | no | no |

No se inició una segunda descarga por reporte en esta corrida. No se expusieron URLs completas, query parameters, cookies, PDF ni datos personales.

## Compatibilidad y estados

Se conserva el fallback V2 basado en `window.open`, el puente `SageReportBridge`, la validación estricta de esquema/host/ruta, el flujo con `Completer` y la resolución multicarrera.

Estados específicos agregados:

- `report_function_missing`
- `report_function_structure_changed`
- `report_function_transform_unsafe`
- `report_function_compile_blocked`
- `report_function_patch_failed`

El flujo de reportes ya no usa `history.back()` ni inicia navegación del iframe. La instalación es idempotente y vuelve a detectar funciones originales si el iframe es recreado.

## Pruebas

- `flutter test --no-pub test/sage_historial/sage_report_function_transformer_test.dart test/sage_historial/extractor_historial_sage_test.dart`: todas las pruebas pasaron, 12 tests.
- `flutter analyze --no-pub`: encontró 231 avisos informativos preexistentes y ningún error; el comando terminó con código 1 por la política de severidad del proyecto.
- Análisis dirigido de los archivos V3: `No issues found!`.

Las pruebas sintéticas cubren asignaciones simples y ternarias, strings con punto y coma, comentarios, múltiples asignaciones, ausencia de asignación, mecanismos rechazados e instalación idempotente.

## Cobertura pendiente

La validación real documentada cubre los tres botones nativos de Flutter. La prueba manual de los tres controles desde “Ver página original”, multicarrera, recreación deliberada del iframe, sesión vencida, endpoint rechazado y mensaje mal formado no se ejecutó en esta corrida; quedan como escenarios de regresión, no como resultados confirmados.

## Archivos modificados

- `lib/funcionalidades/acceso_estudiante/sage_historial/modelos_historial_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_historial/sage_report_function_transformer.dart`
- `lib/funcionalidades/acceso_estudiante/sage_historial/controlador_historial_sage.dart`
- `lib/funcionalidades/acceso_estudiante/sage_historial/pantalla_sage.dart`
- `lib/funcionalidades/acceso_estudiante/pantallas/pantalla_sage.dart`
- `test/sage_historial/sage_report_function_transformer_test.dart`

No se generó AAB, no se hizo commit y no se hizo push.
