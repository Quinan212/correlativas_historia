# Prueba manual — Cambio de Agente a Estudiante

## Caso principal

```text
1. Iniciar sesión con Agente activo.
2. Llegar a “Elegí tu acceso”.
3. Pulsar Estudiante.
4. Verificar que aparezca “Cambiando a Estudiante…”.
5. Esperar la reconstrucción de SAGE.
6. Confirmar que aparece la portada inicial de Estudiante.
```

La transición no debe permanecer indefinidamente en `Preparando tus servicios académicos…`.

## Caso inverso

```text
1. Abrir Cambiar perfil.
2. Pulsar Docente.
3. Confirmar que aparece la portada inicial de Docente.
```

## Recuperación

Si SAGE no confirma el cambio en aproximadamente 22 segundos:

- debe desaparecer la pantalla de carga;
- debe volver `Elegí tu acceso`;
- debe aparecer un mensaje de error;
- debe permitirse reintentar;
- debe mantenerse marcado el perfil realmente activo.

## Regresión visual

Comprobar también que:

- la página web no aparece de fondo;
- la barra inferior sigue estable;
- `Atrás`, `Inicio` y `Cambiar perfil` continúan funcionando;
- no reaparece el Historial del perfil anterior.
