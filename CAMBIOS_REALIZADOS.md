# Cambios realizados

## Cambio de perfil

- El detector trabaja sobre todos los documentos accesibles y prioriza `/pregase/index.php`.
- Busca el avatar mediante `button.btn-user` y selectores equivalentes.
- Comprueba si el panel de perfiles está realmente visible.
- Si está cerrado, pulsa el avatar y vuelve a inspeccionar después de que el DOM se actualice.
- Resuelve radios, labels asociados mediante `for`/`control` y elementos con `role="radio"`.
- El clic se programa con `setTimeout(..., 0)` para que la evaluación JavaScript pueda devolver el resultado antes de que SAGE destruya el contexto durante la recarga.
- La confirmación se realiza en Dart después de la recarga, mediante la portada propia de Agente, la portada propia de Alumnos o el radio activo.
- Los errores ahora distinguen entre avatar ausente, panel cerrado, perfil no encontrado, control no activable y cambio no confirmado.

## Menú superior Docente

- La portada Agente ahora extrae por separado el shell superior de `/pregase/index.php` y el contenido central de `iframe#Main`.
- Detecta y muestra `L.U.P.` y `L.U.A.` sin confundirlos con las tarjetas centrales.
- La detección de la portada Agente exige la presencia real de `Legajo Único Personal` en la portada central, evitando clasificar el perfil Alumnos como Agente por la mera existencia de L.U.A. en el shell.

## L.U.A. y Legajo Alumnos

- Se agregó una pantalla Flutter propia para `Legajo Único Alumno`.
- Extrae las opciones reales del dropdown L.U.A. y deduplica las variantes desktop/mobile.
- Se agregó un ejecutor específico que limita la búsqueda al shell superior y al menú L.U.A.
- `Legajo Alumnos` se selecciona por texto exacto dentro del grupo L.U.A.; `/dic/Listar2.php` queda como dato secundario.
- Después del clic, el flujo vuelve a utilizar los extractores y pantallas existentes de legajo, secciones, Escolares e Historial.

## Prevención de interferencias

- La selección de perfil ya no se reinicia al abrir cualquier enlace interno.
- El detector de `Legajo Único Personal` ignora los dropdowns ocultos del shell superior y exige una subpantalla visible.
- La pantalla de L.U.A. se mantiene aislada de la detección automática de la portada y de L.U.P.
- Desde las portadas principales puede regresarse al selector de perfil sin cerrar la sesión.

## Validación realizada en esta preparación

- Se verificó el balance estructural de llaves, paréntesis, corchetes y cadenas de todos los archivos entregados.
- Se validó la sintaxis de 13 bloques JavaScript mediante `node --check`.
- Se contrastaron los selectores de shell con la auditoría disponible: `button.btn-user`, `button.menuItem`, `button.menuItemMobile`, `L.U.A.` y `Legajo Alumnos`.

No se ejecutó Flutter ni una sesión SAGE real en este entorno. La validación funcional final corresponde a la prueba manual indicada por el usuario.
