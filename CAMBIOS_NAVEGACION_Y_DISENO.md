# Cambios aplicados — navegación persistente y diseño SAGE

## Interfaz

- Las pantallas Docente, Legajo Único Personal y Legajo Único Alumno usan una lista vertical con iconos, flechas y separadores, siguiendo el patrón visual de la pantalla de módulos de Alumno.
- Se eliminaron las tarjetas grandes de esas pantallas.

## Navegación inferior

Se agregó una barra persistente con:

- `Atrás`: vuelve una etapa del recorrido Flutter.
- `Inicio`: regresa a la portada del perfil activo.
- `Cambiar perfil`: vuelve al selector Estudiante/Docente sin cerrar la sesión ni destruir la WebView.

La barra aparece sobre todas las pantallas Flutter internas de SAGE, incluido Historial y los estados de carga.

## Estado y WebView

- La WebView se conserva viva.
- El perfil activo queda registrado para decidir el inicio correcto.
- Cuando el usuario vuelve mediante la barra, se conserva temporalmente la pantalla Flutter elegida para evitar que el sondeo periódico la reemplace inmediatamente por el estado profundo de la WebView.
- Al pulsar una opción real, el seguimiento automático vuelve a activarse.

## Prueba manual prioritaria

1. Abrir SAGE y elegir Docente.
2. Confirmar la lista vertical de servicios.
3. Abrir L.U.A. y revisar la lista con separadores.
4. Entrar en Legajo Alumnos, Escolares e Historial.
5. Probar Atrás en cada nivel.
6. Probar Inicio desde Historial.
7. Probar Cambiar perfil y volver a Estudiante.
