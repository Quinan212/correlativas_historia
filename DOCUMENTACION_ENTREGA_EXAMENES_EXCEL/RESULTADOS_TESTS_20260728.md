# Resultados de tests

## Tests del módulo

Resultado previo a la corrección de compatibilidad visual: **5 tests aprobados**.

La corrección posterior solo añadió un import directo del modelo y sustituyó un icono no disponible; debe repetirse el comando cuando el lockfile del SDK quede liberado:

```powershell
flutter test --no-pub test/laboratorio_mesas_excel
```

## Validación estática del Excel

- Hojas esperadas: OK.
- Filas académicas resueltas: 143.
- Eventos finales: 140.
- Hipervínculos/actas asociadas: 76.
- Continuaciones fusionadas: 1.
- Duplicados fusionados: 2.
- Errores de parseo: 0.
- UTF-8 y mojibake: OK.

