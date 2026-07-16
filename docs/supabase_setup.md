# Supabase setup

Proyecto configurado para:

- `project id`: `drluybtjvmnggleqcbgf`
- `default url`: `https://drluybtjvmnggleqcbgf.supabase.co`

## 1. Obtener la anon key

En Supabase:

1. `Project Settings`
2. `API`
3. copiar `Project URL` y `Publishable key`

## 2. Ejecutar Flutter con las variables

```powershell
flutter run --dart-define=SUPABASE_URL=https://drluybtjvmnggleqcbgf.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY
```

Si no pasas `SUPABASE_URL`, la app usa por defecto la URL armada desde el project id.

## 3. Seguridad

- `SUPABASE_PUBLISHABLE_KEY`: si
- `service_role key`: nunca dentro de la app
- `secret key`: nunca dentro de la app

## 4. Estado actual

La app ya intenta inicializar Supabase al arrancar.
Si falta la publishable key, abre igual y muestra un aviso arriba para que sea visible durante el desarrollo.
