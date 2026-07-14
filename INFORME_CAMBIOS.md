# Informe de cambios - Correlativas v1.3.130726+756

## Pantallas SAGE

### Barra de navegacion inferior oculta en SAGE
- **`estado_app.dart`** - Nuevo provider `proveedorSageActivo`
- **`acceso_estudiante_pantalla.dart`** - Activa/desactiva al abrir/cerrar SAGE
- **`main.dart`** - `showNavBar` ahora requiere `!sageActivo`

### Encabezados azules en todas las pantallas SAGE
- AppBars con fondo `#0E5E86` (mismo azul que Trayectorias) y texto blanco
- Archivos: `pantalla_modulos_sage.dart`, `pantalla_submodulos_sage.dart`, `pantalla_historial_sage.dart`, `pantalla_sage.dart` (2 archivos)

### Pantalla de Modulos (`pantalla_modulos_sage.dart`)
- AppBar cambiada de "SAGE" a "Servicios academicos"
- Eliminado titulo "Servicios academicos" duplicado del body
- Tarjeta "Legajo Unico Alumno" intacta

### Pantalla de Submodulos (`pantalla_submodulos_sage.dart`)
- Rediseno completo: sin cards/contenedores, solo filas con divisores
- AppBar dice "Legajo Unico Alumno" (movido del body)
- Iconos en negro sin colores, flecha `>` al extremo derecho
- Estilo compacto con lineas divisorias entre opciones
- Funciones `onSelect` y `onBack` intactas

### Pantalla de Historial (`pantalla_historial_sage.dart`)
Rediseno visual completo, logica intacta:

- **Tarjeta de Resolucion** - Degradado azul (`#0E5E86` -> `#0A3D5C`), icono de documento, muestra la resolucion en grande
- **Tarjeta de Institucion** - Degradado rojo (`#E53935` -> `#B71C1C`), icono de escuela, inicio/estado, badge "Nivel superior"
- **Metricas** - Grid de 3 columnas con numeros de colores (verde=aprobadas, naranja=regulares, azul=cursando)
- **Botones PDF** - Pildoras con icono PDF rojo y scroll horizontal (Situacion academica, Analitico, Libreta)
- **Filtros** - Redisenados como pildoras con check y borde azul
- **Lista de materias** - Tarjetas redondeadas con colores por estado
- **Selector de carrera** - Dropdown compacto con padding reducido
- **Normalizacion de texto** - Funcion `_titulo()` que convierte MAYUSCULAS de SAGE a formato legible (primera letra mayuscula, conectores en minuscula, siglas preservadas)
- **Normalizacion de espaciado** - Funcion `_normalizarTexto()` que agrega espacios despues de comas y puntos en abreviaturas
- Filtro case-insensitive en `modelos_historial_sage.dart`

## Banner de acceso a SAGE

### `panel_estudiante.dart` - `_SageAccessBanner`
- Imagen `sage_banner.png` en vez del icono original
- Fondo con degradado azul (`#0E5E86` -> `#0A3D5C`) con sombra
- Texto: "Accede a tu estado" en blanco
- Barra divisora blanca entre imagen y texto
- Flecha chevron blanca al extremo derecho
- Bordes completamente redondeados, altura compacta

## Banner de Mesas y Fechas

### `panel_estudiante.dart` - `_ExamShortcutBanner`
- Icono de calendario sin fondo circular
- Flecha diagonal `north_east` de 18px alineada con la de SAGE
- Bordes redondeados completos (30px)
- Colores originales mantenidos

## Permisos Android

### `AndroidManifest.xml`
- Agregado `tools:node="remove"` para eliminar permisos mergeados de `image_picker`:
  - `READ_MEDIA_IMAGES`
  - `READ_MEDIA_VIDEO`
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`

## Assets

- `assets/sage_banner.png` - Imagen del banner de acceso a SAGE

## Version

- `1.3.130726` (version code 756)

---

**Commit:** `5866787` en rama `principal`
