# Plan Bloque 1: catch (_) + lints + documentación

## Archivos a modificar

### 1. Eliminar `catch (_)` silenciosos (6 archivos)

| Archivo | Línea | Contexto | Solución |
|---------|-------|----------|----------|
| `lib/features/examenes/data/examenes_repo.dart` | 57 | `_loadSupabase` falla -> null | Agregar `error, stackTrace` + `debugPrint` |
| `lib/features/opiniones/data/opiniones_reviews_repository.dart` | 74 | Cleanup de storage falla | Agregar `_` -> `error` + `debugPrint` |
| `lib/features/opiniones/widgets/review_composer_sheets.dart` | 32 | Fetch review inicial falla | Agregar `error` + `debugPrint` |
| `lib/features/opiniones/widgets/review_composer_sheets.dart` | 71 | Fetch teacher review falla | Agregar `error` + `debugPrint` |
| `lib/shared/utils/text_sanitize.dart` | 12 | `_repairLatin1Utf8` falla | Agregar `error` + `debugPrint` |
| `lib/shared/notifications/push_notifications_service.dart` | 271 | Payload malformed | Agregar `error` + `debugPrint` |

### 2. Agregar reglas de lints en `analysis_options.yaml`

### 3. Actualizar `IMPROVEMENTS.md` con nuevos hallazgos