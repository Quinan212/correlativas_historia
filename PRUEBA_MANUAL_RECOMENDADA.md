# Prueba manual recomendada

1. Iniciar SAGE desde la app y esperar el selector Flutter.
2. Con `Agente` activo en la web, pulsar `Docente` y confirmar que entra sin error.
3. Volver al selector y pulsar `Estudiante`.
4. Confirmar que aparece `Cambiando a Estudiante…` y luego la portada de alumno.
5. Volver al selector y pulsar `Docente`.
6. Confirmar que la portada Docente muestra `Accesos superiores`.
7. Confirmar que aparece `Legajo Único Alumno` y la sigla `L.U.A.`.
8. Abrir `Legajo Único Alumno`.
9. Confirmar que aparece `Legajo Alumnos`.
10. Abrir `Legajo Alumnos`.
11. Seleccionar un alumno en la pantalla existente.
12. Abrir `Escolares`.
13. Abrir `Nivel Superior - Historial`.
14. Expandir una carrera y verificar las materias.
15. Verificar la presencia de Situación Académica, Analítico y Libreta.

## Logs útiles

En caso de fallo, copiar desde Logcat las líneas que comiencen con:

```text
[SAGE perfil]
[SAGE agente]
[SAGE navegación]
[SAGE acción]
[SAGE legajo]
[SAGE historial]
```

El mensaje visible del selector debe indicar la fase exacta que falló.
