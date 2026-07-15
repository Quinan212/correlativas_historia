# Diagnóstico real de reportes SAGE — V2

Fecha: 2026-07-13. Entorno: `emulator-5554`. Instrumentación temporal, sin bloqueo de APIs, sin URLs construidas y sin ampliar la allowlist.

## Resultado

La reproducción correcta requiere doble clic sobre una celda de la primera fila —se usó la celda de tipo DNI—, luego `Escolares` y `Nivel Superior - Historial`. Con ese recorrido se alcanzó la pantalla final, se expandió la carrera y se pulsaron los tres controles.

El fallo queda reproducido: en los tres intentos el flujo llega a `click_dispatched`, pero no llega ningún mensaje de reporte y termina en `timeout=true`.

La evidencia decisiva es el inventario de funciones oficiales en `escolares`: las tres funciones existen y contienen `location.href`; no contienen `window.open`, `form.submit`, `requestSubmit`, `fetch`, AJAX ni `setTimeout`.

## Reportes

| Reporte | Callback | Mecanismo | Contexto | Control | Resultado | Endpoint |
|---|---|---|---|---|---|---|
| Situación académica | Ejecutado | `location navigation` mediante `location.href` | `escolares` | `td`, sin id, sin inline onclick, 1 handler jQuery | `open`: no; `form_submit`: no; `anchor_click`: no; `location_change`: no; XHR/fetch de reporte: no | No detectado |
| Analítico | Ejecutado | `location navigation` mediante `location.href` | `escolares` | `td`, sin id, sin inline onclick, 1 handler jQuery | `open`: no; `form_submit`: no; `anchor_click`: no; `location_change`: no; XHR/fetch de reporte: no | No detectado |
| Libreta | Ejecutado | `location navigation` mediante `location.href` | `escolares` | `td`, sin id, sin inline onclick, 1 handler jQuery | `open`: no; `form_submit`: no; `anchor_click`: no; `location_change`: no; XHR/fetch de reporte: no | No detectado |

No se descargó ningún documento; los clics fueron diagnósticos y no generaron descargas.

## Inventario sanitizado

| Contexto | Función | Existe | Longitud | Hash | `location.href` | Otros mecanismos |
|---|---|---:|---:|---|---:|---|
| root | `imprimir_estado_alumno` | no | 0 | — | no | no |
| root | `imprimir_analitico` | no | 0 | — | no | no |
| root | `imprimir_examenes_rendidos` | no | 0 | — | no | no |
| Main | las tres funciones | no | 0 | — | no | no |
| `frm_alumnos` | las tres funciones | no | 0 | — | no | no |
| `frm_alumnos_escolares` | `imprimir_estado_alumno` | sí | 228 | `3ef0b38a` | sí | no |
| `frm_alumnos_escolares` | `imprimir_analitico` | sí | 212 | `83025641` | sí | no |
| `frm_alumnos_escolares` | `imprimir_examenes_rendidos` | sí | 228 | `fe038b3` | sí | no |

No se guardó ni se entregó el cuerpo de ninguna función.

## Handler real

Los tres botones presentan el mismo patrón:

```text
element_tag=td
element_id_present=false
onclick_present=false
jquery_click_handlers_count=1
delegated_handler_present=false
parent_handler_present=false
function_owner=escolares
bridge_patched=4
click_dispatched=true
timeout=true
```

La activación real fue el handler jQuery del `td`; no se combinaron `button.click()` y `jQuery.trigger()`.

## Frames y tráfico

En la pantalla final se confirmó `Main → frm_alumnos → frm_alumnos_escolares`. Los cuatro contextos quedaron instrumentados y el canal fue `object` desde root, Main, alumnos y escolares; se emitieron probes inocuos desde cada contexto.

Durante la carga normal se observó `GET` a `NS_historial_alumnado_B2.php` desde `escolares`. También hubo telemetría a `z.clarity.ms/collect` y navegación ordinaria a `tabs.php`, pero ninguna quedó correlacionada con los tres reportes.

No se detectó una solicitud de `NS_reporte_estado_alumno_carrera.php`, `NS_reporte_analitico.php` ni `NS_reporte_examenes_rendidos.php`. No se agregaron endpoints a la allowlist.

## Causa confirmada y límite

La hipótesis V2 de `window.open` es incorrecta. SAGE ejecuta callbacks jQuery en `escolares` que asignan `location.href`, pero en esta sesión esa navegación no produjo un cambio de pathname observable ni una solicitud de reporte. Por eso el puente no recibe URL: el wrapper de `window.open` no puede capturar este mecanismo.

La causa más profunda de por qué la asignación a `location.href` no desemboca en un endpoint observable queda pendiente de inspección del valor calculado por SAGE. No se imprimió el cuerpo ni valores personales para forzar una conclusión no verificada.

## Validación

```text
flutter analyze --no-pub (3 archivos diagnósticos): No issues found
flutter test --no-pub test/sage_historial/extractor_historial_sage_test.dart: All 8 tests passed
```

La sesión de `flutter run` fue detenida. No se hizo commit, push, APK/AAB de entrega ni corrección V3.
