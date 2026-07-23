# AGENTS.md — Regla específica anti-mojibake para Correlativas

## Proyecto

Ruta principal:

`C:\Users\alanm\Desktop\StudioProjects\Correlativas`

Este archivo complementa la regla global ubicada en:

`C:\Users\alanm\Desktop\StudioProjects\AGENTS.md`

Ante cualquier diferencia, aplicar la disposición que otorgue mayor protección al contenido Unicode y al texto visible de la aplicación.

## Regla permanente del proyecto

Todo archivo creado, leído, editado, reemplazado, generado o exportado dentro de `Correlativas` debe conservar UTF-8 de extremo a extremo.

La protección incluye especialmente:

- textos visibles de la interfaz Flutter;
- archivos Dart;
- `pubspec.yaml`;
- recursos JSON, YAML y ARB;
- manifestaciones Android;
- archivos Gradle y Kotlin;
- HTML, JavaScript y CSS;
- consultas SQL y configuraciones de Supabase;
- documentación Markdown;
- scripts PowerShell y Python;
- datos copiados desde SAGE, Google Docs, planillas, terminales o navegadores.

## Caracteres que deben preservarse

Prestar atención especial a:

- á, é, í, ó, ú;
- Á, É, Í, Ó, Ú;
- ü y Ü;
- ñ y Ñ;
- ¿ y ¡;
- comillas curvas;
- apóstrofos;
- guion largo y guion medio;
- símbolos académicos y matemáticos;
- emojis e iconografía textual.

## Procedimiento obligatorio para cada cambio

### Antes de editar

1. Identificar todos los archivos que serán modificados.
2. Confirmar que cada archivo puede leerse correctamente como UTF-8.
3. Revisar si ya existen signos de mojibake.
4. Registrar cualquier corrupción preexistente antes de tocar el archivo.
5. Hacer una copia de respaldo cuando se vaya a reemplazar el archivo completo o convertir su codificación.

### Durante la edición

1. Usar herramientas que permitan declarar UTF-8 de manera explícita.
2. Preferir parches localizados.
3. Mantener la codificación original cuando ya sea UTF-8 válida.
4. Mantener los saltos de línea del archivo.
5. Evitar conversiones automáticas realizadas por consolas, editores o scripts.
6. Evitar pegar texto a través de una cadena de herramientas que transforme caracteres.
7. Guardar archivos nuevos como UTF-8 sin BOM, excepto cuando el formato o una herramienta exijan otra variante de manera comprobada.

### Después de editar

1. Volver a abrir cada archivo como UTF-8.
2. Buscar estas secuencias: `�`, `Ã`, `Â`, `â€™`, `â€œ`, `â€`, `â€“`, `â€”`, `ðŸ`, `ï»¿`.
3. Revisar manualmente todos los textos visibles modificados.
4. Ejecutar `flutter analyze`.
5. Ejecutar las pruebas pertinentes cuando existan: `flutter test`.
6. Compilar o iniciar la aplicación cuando el cambio afecte interfaz, recursos, configuración o datos.
7. Verificar en pantalla textos con tildes, eñes, signos de apertura y símbolos.
8. Informar los archivos revisados y el resultado de la validación anti-mojibake.

## Reglas para PowerShell

En PowerShell 7 usar `Get-Content -LiteralPath $ruta -Raw -Encoding utf8` para leer y `Set-Content -LiteralPath $ruta -Value $contenido -Encoding utf8NoBOM` para escribir.

En Windows PowerShell 5.1 usar las API de .NET con `UTF8Encoding($false)` para leer y escribir sin BOM. Evitar escritura mediante redirecciones, `Out-File` o comandos sin `-Encoding`.

## Reglas para Python

Toda lectura y escritura debe declarar UTF-8. Para JSON usar `ensure_ascii=False`.

## Reglas para Dart y Flutter

- Mantener archivos `.dart`, `.yaml`, `.arb` y `.json` en UTF-8.
- Leer y escribir datos con `utf8` explícito cuando intervenga `dart:io`.
- Mantener textos de interfaz como Unicode directo.
- Revisar visualmente textos recuperados desde Supabase, SAGE o WebView.

## Reparación de un archivo ya dañado

Detener nuevas escrituras, crear una copia exacta, identificar la codificación original probable, reparar en una copia, comparar palabras con tildes y validar sintaxis y compilación antes de reemplazar el original.

## Prohibiciones específicas

- Eliminar tildes para evitar errores.
- Cambiar `ñ` por `n`.
- Sustituir caracteres dañados de forma global sin revisar contexto.
- Regenerar archivos completos con una herramienta que no garantice UTF-8.
- Aceptar un cambio porque la aplicación compila cuando los textos visibles quedaron corruptos.
- Mezclar datos UTF-8 con Windows-1252 en archivos, respuestas HTTP, scripts o tablas.
- Entregar un ZIP sin revisar que los archivos incluidos conserven UTF-8.

## Declaración obligatoria de cierre

> Validación anti-mojibake completada. Los archivos modificados fueron leídos nuevamente como UTF-8, se buscaron secuencias sospechosas y se revisaron los textos visibles afectados.
