# Supabase Hardening + Smoke Test (Pre-Release)

## Cuando correrlo
- Siempre antes de cada release.
- En este proyecto, la publicacion debe salir por `shorebird`.

## Checklist de hardening final
1. Confirmar proyecto y entorno correctos (`drluybtjvmnggleqcbgf`, produccion).
2. Confirmar migraciones locales = remotas (`supabase_migrations.schema_migrations`).
3. Verificar corpus IA:
- `assistant_documents >= 2`
- `assistant_chunks >= 300`
- `faq_refs = 0` (sin `lib/features/faq`).
4. Verificar hardening de `assistant_*`:
- indice trigram en `assistant_chunks.chunk_text`
- indice `(status, created_at)` en `assistant_queries`
- constraint `assistant_documents_source_type_check`
- constraint `assistant_queries_status_check`.
5. Verificar function `ask-situated-assistant` en `ACTIVE`.
6. Smoke test E2E:
- caso con evidencia => `status=ok`, `sources[]` con elementos.
- caso fuera de corpus => `status=no_evidence`.
7. Verificar que las consultas se registren en `assistant_queries`.
8. Recién despues: release con `shorebird`.

## Script automatico
Archivo: `scripts/supabase_pre_release_smoke.ps1`

Ejemplo (PowerShell):
```powershell
./scripts/supabase_pre_release_smoke.ps1 -DbPassword "TU_DB_PASSWORD"
```

Opcional (si ya tenes URL completa):
```powershell
./scripts/supabase_pre_release_smoke.ps1 -DbUrl "postgresql://..."

## Fuzz de preguntas IA (anti-respuesta generica)

Archivo: `scripts/supabase_assistant_fuzz.ps1`

Ejemplo rapido:

```powershell
./scripts/supabase_assistant_fuzz.ps1 -Iterations 80 -MaxGenericRate 0.20
```

Modo continuo (sin parar, cortar con `Ctrl + C`):

```powershell
./scripts/supabase_assistant_fuzz.ps1 -Continuous -Iterations 100
```

El script:
- genera preguntas variadas (curriculares, ambiguas, saludos, ruido),
- llama a `ask-situated-assistant`,
- mide tasa de respuestas genericas y aclaraciones,
- falla con exit code `1` si `generic_rate` supera el umbral,
- guarda reporte JSON en `RUIDO/assistant_fuzz_report.json`.
```

## Nota de seguridad
- No commitear passwords, tokens ni DB URLs con credenciales.
- Si alguna credencial se expone en chat/logs, rotarla en Supabase.
