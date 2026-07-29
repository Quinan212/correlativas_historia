# Validación del parche Exámenes desde Excel

Fecha: 2026-07-28

## Correcciones aplicadas

- `pantalla_inicio_mesas_excel_atlassian.dart` importa directamente `modelos_mesas_excel.dart`, donde se definen las extensiones `etiqueta`, `permiteMostrarDatos` y `estaComprobando`.
- `Icons.monitoring_outlined` fue reemplazado por `Icons.timeline_outlined`, disponible en el SDK Flutter instalado.

## Validaciones realizadas

- Validador estático del libro Excel: correcto.
- 143 filas académicas resueltas.
- 140 eventos finales.
- 76 hipervínculos y actas asociadas.
- 0 errores de parseo.
- Tests del módulo antes de esta corrección: 5/5 aprobados.
- Archivo corregido: UTF-8 válido y sin secuencias de mojibake.

## Bloqueo de validación Flutter

La compilación no pudo ejecutarse hasta código 0 porque el SDK Flutter quedó bloqueado por un archivo residual:

`C:\flutter\flutter\bin\cache\lockfile`

Resultado exacto de `flutter build apk --debug` mediante el snapshot Flutter:

```text
Flutter failed to open a file at "C:\flutter\flutter\bin\cache\lockfile". The flutter tool cannot access the file or directory.
Please ensure that the SDK and/or project is installed in a location that has read/write permissions for the current user.
DIRECT_BUILD_EXIT=1
```

Resultado exacto de `flutter run --debug` mediante el snapshot Flutter:

```text
Flutter failed to open a file at "C:\flutter\flutter\bin\cache\lockfile". The flutter tool cannot access the file or directory.
Please ensure that the SDK and/or project is installed in a location that has read/write permissions for the current user.
DIRECT_RUN_EXIT=1
```

La entrega queda pendiente de liberar ese lock del SDK y repetir ambos comandos con código 0. No se considera cerrado el parche.

## Restricciones respetadas

- No se ejecutó Git ni GitHub.
- No se modificaron las pantallas públicas protegidas.
- No se ejecutó `flutter run` con la aplicación porque el SDK no pudo abrir su lockfile.

