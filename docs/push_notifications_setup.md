# Push de verificación

Este proyecto quedó preparado para un flujo de notificaciones push reales cuando:

- una verificación nueva entra en revisión para admins
- una verificación pasa de `pendiente` a `aprobada` o `rechazada`

## Qué ya quedó armado

- `public.device_push_tokens` para guardar tokens FCM por `device_id`
- Edge Functions `notify-verification-submitted` y `notify-verification-reviewed`
- disparo automático al enviar una verificación nueva
- disparo automático desde el flujo de aprobar/rechazar en la app admin
- permiso Android `POST_NOTIFICATIONS`

## Qué falta para prenderlo de verdad

### 1. Configurar Firebase para Android

1. Crear o reutilizar un proyecto en Firebase.
2. Registrar la app Android `ar.maillet.correlativas_historia`.
3. Descargar `google-services.json` y guardarlo en `android/app/google-services.json`.
4. Correr `flutterfire configure` para generar `lib/firebase_options.dart`.

### 2. Agregar el cliente FCM en Flutter

Dependencias esperadas:

- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`

La app tiene que:

1. inicializar Firebase al arrancar
2. pedir permiso de notificaciones
3. obtener el token FCM
4. guardar o actualizar ese token en `public.device_push_tokens`

## Secrets que necesita la Edge Function

Guardar estos secrets en Supabase:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`

La `FIREBASE_PRIVATE_KEY` debe cargarse con saltos de línea reales o usando `\\n`.

## Qué hacen las Edge Functions

Cuando una verificación nueva se envía:

1. busca la solicitud por `requestId`
2. obtiene los `device_id` habilitados en `admin_devices`
3. resuelve los tokens FCM habilitados de esos admins
4. manda la notificación a Firebase Cloud Messaging

Cuando una verificación se revisa:

1. busca la solicitud por `requestId`
2. obtiene los tokens FCM habilitados del `device_id`
3. arma el mensaje según el estado final
4. manda la notificación a Firebase Cloud Messaging

## Payload esperado

La notificación manda estos datos:

- `screen: verification`
- `requestId`
- `matterId`
- `status`

Para admins también viaja:

- `screen: admin_verification`
- `careerId`
- `sourceDeviceId`

Con eso, después se puede abrir la pantalla de `Verificación` o incluso enfocar la materia correspondiente.

## Notas

- Si no hay tokens o faltan secrets, la Edge Function devuelve `202` y no rompe el flujo admin.
- La app ya mantiene el aviso interno en `Tus solicitudes`, pero eso no reemplaza el push del dispositivo.
