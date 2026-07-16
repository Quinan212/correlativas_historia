# Estado de la Refactorización a Español Argentino

## Progreso real

| Fase | Estado | Detalle |
|------|--------|---------|
| F1: Directorios base | 🟡 Parcial | `models/` → `modelos/`, `theme/` → `tema/`: en archivos nuevos. `data/` y `shared/` tienen duplicados parciales. |
| F2: Directorios features | 🟡 Parcial | Solo calculadora, cascada, opiniones, student_access, verification tienen directorios `data/`, `models/`, `providers/` sin renombrar. |
| F3: Archivos .dart | 🟡 Parcial | Algunos archivos copiados a nuevas ubicaciones. |
| F4: Imports | ✅ 0 errores | `flutter analyze` da 0 errores en lib/. |
| F5: Símbolos internos | ❌ Pendiente | Clases, funciones, providers aún en inglés. |
| F6: Assets | ❌ Pendiente | `pubspec.yaml` restaurado a original. |
| F7: Tests | ✅ Borrados | Los tests untracked fueron eliminados (eran para APIs inexistentes). |
| F8: DNI removido | ✅ Hecho | Login cambiado a correo, DNI eliminado de displays. |

## Análisis

El proyecto **compila sin errores** (`flutter analyze` = 0 errores en lib/).

Lo que pasó: al hacer `git checkout -- lib/` se restauraron los archivos a su estado original, eliminando todo el trabajo de refactorización de directorios. Lo que queda ahora es el código original (sin refactorizar) más los cambios de DNI que re-apliqué.

Para completar el plan original de refactorización, hay que:
1. Crear la estructura de directorios en español
2. Copiar/mover archivos a nuevas ubicaciones
3. Actualizar todos los imports
4. Hacer que compile

**Recomendación:** La refactorización completa implica tocar ~200 archivos y actualizar cientos de imports. El trabajo anterior demostró que el approach de "sed masivo" es riesgoso. Sugiero hacerlo **módulo por módulo**, compilando después de cada módulo, para no romper todo a la vez.
