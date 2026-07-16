# Publicador directo a producción — ar.maillet.correlativas_historia

Herramienta para Windows que compila el proyecto Flutter y envía el AAB como una nueva versión de producción mediante Google Play Developer API v3. No abre el navegador y no usa Fastlane.

## Configuración fijada

- Aplicación: `ar.maillet.correlativas_historia`
- Canal: `production`
- Estado de la versión: `completed`
- Distribución: lanzamiento completo, sujeto al procesamiento y revisión de Google Play

El publicador rechaza cualquier configuración que intente usar otro paquete, otro canal o un estado distinto.

## Qué ocurre al ejecutar el botón de publicación

1. Ejecuta `flutter pub get`.
2. Compila `flutter build appbundle --release`.
3. Asigna automáticamente un `versionCode` nuevo.
4. Sube `app-release.aab` a la aplicación `ar.maillet.correlativas_historia`.
5. Crea o actualiza la versión del canal `production` con estado `completed`.
6. Confirma la edición y la envía a Google Play.

Si la aplicación requiere revisión, la nueva versión queda enviada a revisión. Si está activada Publicación gestionada, Google puede aprobarla y mantenerla retenida hasta que se publique desde Play Console. Si faltan declaraciones, permisos o datos obligatorios, la API devuelve un error.

## Configuración única

### 1. Crear la cuenta de servicio

En Google Cloud:

1. Elegí o creá un proyecto.
2. Habilitá **Google Play Android Developer API**.
3. Entrá en IAM y administración → Cuentas de servicio.
4. Creá una cuenta de servicio.
5. En Claves, generá una clave JSON.
6. Guardala fuera del proyecto, por ejemplo:

```text
C:\Credenciales\google-play-service-account.json
```

La clave JSON es privada. No debe subirse a GitHub ni compartirse.

### 2. Dar acceso en Play Console

En Play Console → Usuarios y permisos:

1. Invitá el correo `client_email` que aparece en el JSON.
2. Limitá el acceso a la aplicación `ar.maillet.correlativas_historia`.
3. Concedé permisos para ver la aplicación y publicar en producción.

La aplicación y tu cuenta deben tener acceso habilitado al canal de producción.

### 3. Instalar la herramienta

Extraé `publicador_google_play_produccion` dentro de la raíz del proyecto Flutter:

```text
TU_PROYECTO_FLUTTER\
├── android\
├── lib\
├── pubspec.yaml
└── publicador_google_play_produccion\
```

Ejecutá una sola vez:

```text
1_CONFIGURAR_PRODUCCION.bat
```

Solo pide la ruta del JSON. El paquete y el canal ya están fijados.

## Uso cotidiano

Para compilar y enviar una nueva versión pública, ejecutá:

```text
2_COMPILAR_Y_PUBLICAR_PRODUCCION.bat
```

La consola permanece abierta y muestra el resultado. Los registros quedan en:

```text
publicador_google_play_produccion\logs\
```

## Comportamiento importante

- Cada ejecución exitosa intenta crear una nueva versión pública.
- El AAB se firma con la configuración release del proyecto Flutter.
- El `versionCode` se genera usando la hora Unix para evitar repeticiones.
- Si ya hay cambios en revisión, la herramienta se detiene para no interferir con ellos.
- Una carga aceptada por la API puede seguir pendiente de procesamiento o revisión.
- Si Google Play exige completar una declaración en la interfaz, esa parte puede requerir entrar manualmente a Play Console.

## Prueba de acceso

Para comprobar credenciales y permisos sin subir un AAB:

```text
PROBAR_CONEXION_PLAY.ps1
```
