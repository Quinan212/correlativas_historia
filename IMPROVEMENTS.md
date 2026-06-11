# Sugerencias de Mejora - Correlativas

## 1. Arquitectura y Código

### 1.1 Separar UI de lógica de negocio
**Problema:** Archivos como `student_access_screen.dart` (>1500 líneas) mezclan UI, lógica de negocio y llamadas a API.
**Solución:** Aplicar Clean Architecture con capas bien definidas: `data/` (repositories, DTOs), `domain/` (entidades, casos de uso), `presentation/` (widgets, estados).

### 1.2 Modelos con código generado
**Problema:** Los modelos (`materia.dart`, `student_access_models.dart`) tienen `fromJson`/`fromMap` escritos a mano.
**Solución:** Usar `freezed` + `json_serializable` para generar modelos con:
- Inmutabilidad
- Métodos de copia (`copyWith`)
- Serialización/deserialización automática
- Diferencia de igualdad (==, hashCode)

### 1.3 Usar AutoDispose en providers
**Problema:** Muchos providers no usan `autoDispose`, lo que mantiene recursos en memoria innecesariamente.
**Solución:** Migrar a `.autoDispose` donde sea posible, especialmente en providers de filtros y búsqueda.

### 1.4 Tipado de analytics events
**Problema:** Los eventos de analytics se envían como strings sin tipado (`matter_navigation_analytics_repository.dart`).
**Solución:** Crear clases selladas para eventos de analytics, mejorando autocompletado y evitando errores tipográficos.

### 1.5 Riverpod families para params
**Problema:** Providers como `filteredMateriasProvider` dependen de múltiples providers individuales.
**Solución:** Usar `family` con un objeto parámetro para hacerlos más testables y reducir providers atomizados.

### 1.6 Navegación acoplada a BuildContext
**Problema:** 98 usos de `Navigator.of(context)` y 53 de `ScaffoldMessenger.of(context)` acoplan los widgets al contexto de navegación. Ya existe `appNavigatorKey` en el proyecto pero no se usa consistentemente.
**Solución:** Usar `appNavigatorKey` para navegación sin contexto, especialmente en callbacks asíncronos y repositorios.

### 1.7 Variables `late` sin inicialización segura
**Problema:** Múltiples variables `late` en varios screens que podrían causar errores en tiempo de ejecución si se acceden antes de inicializar.
**Solución:** Preferir inicialización temprana en `initState` o usar valores nullable con null-safety.

### 1.8 `catch (_)` que silencian errores
**Estado:** ✅ **REPARADO** (6 archivos)
**Problema original:** 6 casos de `catch (_)` que descartaban errores sin ningún logging.
**Archivos reparados:**
- `lib/features/examenes/data/examenes_repo.dart` - Error cargando desde Supabase
- `lib/features/opiniones/data/opiniones_reviews_repository.dart` - Cleanup de storage
- `lib/features/opiniones/widgets/review_composer_sheets.dart` (x2) - Fetch de reviews
- `lib/shared/utils/text_sanitize.dart` - Reparación de mojibake
- `lib/shared/notifications/push_notifications_service.dart` - Payload malformed

### 1.9 Feature flags hardcodeados
**Problema:** `OCULTAR_TODO_EXAMENES` en `examenes_visibility.dart` es un flag booleano hardcodeado.
**Solución:** Implementar un sistema de feature flags (ej: `firebase_remote_config` o un provider centralizado).

## 2. Testing

### 2.1 Tests de unidad faltantes
**Problema:** Solo hay 2 tests. La lógica de `evaluateCourse` (app_state.dart:498-638) y `sanitizeText` son críticas y no tienen tests.
**Solución:** Agregar tests unitarios para:
- `evaluateCourse` (todos los escenarios: sin correlativas, A pendientes, R pendientes, todo aprobado)
- `sanitizeText` (mojibake, acentos, espacios)
- `_normalize`, `_matchesPDIV`, `_matchesPDIII`
- `getDependents`, `getTodasCorrelativas`
- `_applyInstitutionOverrides`
- Modelos (`Materia.fromMap`, `CorrelativaDetallada.fromMap`)

### 2.2 Tests de widgets
**Problema:** Sin tests de widgets para las pantallas principales.
**Solución:** Agregar tests con `ProviderScope` para:
- BottomNav (cambio de pestañas)
- Login card (validación de campos)
- Calculadora (flujo básico)

### 2.3 Tests de integración
**Solución:** Agregar tests que verifiquen la carga de planes HTML/JSON y la correcta transformación a `Materia`.

## 3. Performance

### 3.1 Lazy loading de datos
**Problema:** `planProvider` carga todo el plan de estudios al seleccionar una carrera, incluso si solo se ve el mapa.
**Solución:** Implementar carga perezosa con `family(autoDispose)` y chunking para carreras grandes.

### 3.2 Memoización de cálculos
**Problema:** `getTodasCorrelativas` (app_state.dart:399-418) se recalcula en cada rebuild.
**Solución:** Usar `Provider` con `select` o `family` + caché para evitar recalcular la misma materia múltiples veces.

### 3.3 Imágenes optimizadas
**Problema:** Assets PNG sin optimizar.
**Solución:** Usar `flutter_launcher_icons` para generar variantes, y WebP para assets decorativos.

### 3.4 Uso intensivo de BuildContext (Theme.of, MediaQuery.of)
**Problema:** 368 usos de `Theme.of(context)`, 38 de `MediaQuery.of(context)` directamente en el árbol de widgets, lo que puede causar rebuilds innecesarios.
**Solución:** Extraer valores antes del build en `ConsumerWidget`/`ConsumerStatefulWidget`, especialmente los que no cambian frecuentemente.

### 3.5 Archivos HTML estáticos en assets
**Problema:** 12 archivos HTML estáticos (`Artes_visuales.html`, `Biologia.html`, etc.) que contienen datos de planes de estudio.
**Solución:** Migrar a formato JSON estructurado o cargar desde Supabase para mejor mantenimiento y actualización.

## 4. UX/UI

### 4.1 Estados de carga
**Problema:** Algunas pantallas muestran solo texto "Cargando..." sin esqueletos (skeleton loaders).
**Solución:** Agregar shimmer/skeleton widgets para todas las pantallas con carga asíncrona.

### 4.2 Manejo de errores
**Estado:** ✅ **EN PROGRESO** (AppSnackbar creado + refactor parcial)
**Problema:** Los errores se muestran como textos crudos (ej: `'$error'`) con ~110 SnackBars manuales e inconsistentes en toda la app.
**Solución implementada:**
- `lib/shared/widgets/app_snackbar.dart` - Sistema centralizado con:
  - `AppSnackbar.show()` - SnackBar con estilo configurable (success/error/warning/info)
  - `AppSnackbar.showError()` - Error con `debugPrint` automático
  - `AppSnackbar.showSuccess()` / `showWarning()` - Atajos semánticos
  - `showIfMounted()` / `showErrorIfMounted()` - Versiones seguras para callbacks asíncronos
  - Colores adaptativos para modo claro/oscuro
  - Floating SnackBars con border radius consistente
- **Refactorizado:** `verification_submit_screen.dart` (4 SnackBars migrados)
- **Pendiente:** Migrar ~106 SnackBars restantes en otros archivos

### 4.3 Feedback táctil
**Problema:** Faltan haptics en acciones importantes (login, guardar).
**Solución:** Usar `HapticFeedback` de Flutter en acciones clave.

### 4.4 Accesibilidad
**Solución:** Agregar `Semantics` y `semanticLabel` a widgets interactivos. Verificar contraste de colores en modo oscuro. Considerar:
- Soporte para lectores de pantalla (TalkBack, VoiceOver)
- Contraste suficiente en todos los modos
- Labels descriptivos en `IconButton`s
- Áreas táctiles de tamaño adecuado

## 5. Mantenibilidad

### 5.1 Constantes mágicas
**Problema:** Colores hardcodeados como `Color(0xFF0E5E86)` aparecen en múltiples archivos.
**Solución:** Centralizar colores en `app_theme.dart` con nombres semánticos. Actualmente el tema define colores base, pero hay ~200+ ocurrencias de `Color(0x...)` en toda la app.

### 5.2 Strings hardcodeados
**Problema:** Textos en español hardcodeados en widgets.
**Solución:** Usar `AppLocalizations` de Flutter i18n (ARB files) para facilitar traducciones futuras.

### 5.3 Cobertura de análisis estático
**Estado:** ✅ **ACTUALIZADO**
**Problema original:** `analysis_options.yaml` usaba `flutter_lints` sin reglas adicionales.
**Solución aplicada:** Se agregaron reglas: `prefer_const_constructors`, `avoid_print`, `prefer_single_quotes`, `unawaited_futures`, `avoid_dynamic_calls`, `always_specify_types`, `directives_ordering`, `sort_child_properties_last`, entre otras.

### 5.4 Logging
**Solución:** Reemplazar `debugPrint` por un logger estructurado (ej: `logging` package o `talker_flutter`) con niveles (info, warning, error).

## 6. CI/CD

### 6.1 GitHub Actions
**Solución:** Agregar workflow para:
- `flutter analyze` en cada PR
- `flutter test` con cobertura
- `flutter build` para Android y Web

### 6.2 Code push
**Problema:** Shorebird configurado pero sin versión en CI.
**Solución:** Automatizar releases con Shorebird desde GitHub Actions.

## 7. Dependencias

### 7.1 Dependencias no utilizadas
Verificar si todas las dependencias en `pubspec.yaml` se usan. Considerar remover:
- `video_player_win` (solo Windows, verificar si es necesario)
- `crop_your_image` (verificar uso real)

### 7.2 Actualizar versiones
- `flutter_riverpod: ^2.5.1` -> `^2.6.x` (verificar changelog)
- `supabase_flutter: ^2.9.1` -> última estable

## 8. Seguridad

### 8.1 Certificate pinning
**Solución:** Implementar certificate pinning para producción, especialmente en las comunicaciones con Supabase y Firebase.

### 8.2 Ofuscación de código
**Solución:** Usar `flutter build --obfuscate --split-debug-info` para releases, dificultando la ingeniería inversa.

## Resumen de prioridades

| Prioridad | Mejora | Esfuerzo | Estado |
|-----------|--------|----------|--------|
| 🔴 Alta | Tests unitarios para lógica crítica | 1-2 días | ✅ **AMPLIADO** (41 tests) |
| 🔴 Alta | AutoDispose en providers | 1 día | ✅ **PARCIAL** (6 providers locales) |
| 🔴 Alta | Manejo de errores consistente | 2-3 días | ✅ **EN PROGRESO** (AppSnackbar + 1 archivo refactorizado) |
| 🟡 Media | Extraer Theme.of/MediaQuery.of antes del build | 1-2 días | ❌ Pendiente |
| 🟡 Media | GitHub Actions (analyze + test) | 1 día | ✅ **LISTO** (`.github/workflows/ci.yml`) |
| 🟡 Media | Fix theme oscuro (pantallas con fondo blanco fijo) | 1 día | ✅ **PARCIAL** (Scaffold principal + _StudentDataScreen) |
| 🟡 Media | Reemplazar catch (_) silenciosos | ✅ **REPARADO** | ✅ |
| 🟡 Media | Sistema de feature flags | 1 día | ❌ Pendiente |
| 🟡 Media | Navegación con appNavigatorKey | 1-2 días | ❌ Pendiente |
| 🟢 Baja | Shimmer loaders | 2-3 días | ❌ Pendiente |
| 🟢 Baja | Migrar HTMLs estáticos a JSON/Supabase | 3-5 días | ❌ Pendiente |
| 🟢 Baja | i18n / ARB | 3-5 días | ❌ Pendiente |
| 🟢 Baja | Certificate pinning + ofuscación | 1-2 días | ❌ Pendiente |
| 🟢 Baja | freezed para modelos | 2-3 días | ❌ Pendiente |
