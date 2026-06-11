# Skills Instaladas para Codex CLI

> Generado el: 10/06/2026
> Repositorio: `softaworks/agent-toolkit`
> Método de instalación: `npx skills add softaworks/agent-toolkit --skill <nombre>`
> Ruta base: `.agents/skills/` (relativo a este proyecto)

---

## Resumen

Se instalaron **13 skills** de las 14 solicitadas. La skill `codebase-pattern-finder` **no existe** en el repositorio `softaworks/agent-toolkit` (repositorio contiene 43 skills, ninguna con ese nombre).

---

## Skills Instaladas

### 1. codex
- **Propósito:** Ejecutar Codex CLI (`codex exec`, `codex resume`) para análisis de código, refactoring y edición automatizada con GPT-5.2.
- **Cuándo usarla:** Cuando necesites que Codex realice tareas de ingeniería de software (análisis, refactorización, edición batch).
- **Seguridad:** Usa sandbox modes (`read-only`, `workspace-write`, `danger-full-access`). Requiere confirmación para modo peligroso.

### 2. gepetto
- **Propósito:** Crear planes de implementación detallados y seccionizados mediante investigación, entrevistas simulación de stakeholders y revisión multi-LLM.
- **Cuándo usarla:** Antes de implementar features complejas que requieran análisis profundo previo.
- **Seguridad:** Solo genera documentos, no ejecuta cambios en el código.

### 3. requirements-clarity
- **Propósito:** Clarificar requisitos ambiguos mediante preguntas enfocadas (YAGNI + KISS) antes de implementar.
- **Cuándo usarla:** Cuando los requisitos no estén claros, features tomen >2 días, o involucren coordinación cross-team.
- **Seguridad:** Solo diálogo estructurado, sin acceso a código.

### 4. react-dev
- **Propósito:** Patrones tipados para React 18-19 con TypeScript, hooks, eventos, y routing (TanStack Router, React Router).
- **Cuándo usarla:** Al construir componentes React con TypeScript, tipar hooks, manejar eventos.
- **Seguridad:** Bajo riesgo. Solo guías de código.

### 5. react-useeffect
- **Propósito:** Mejores prácticas de useEffect según docs oficiales de React. Cuándo usarlo y cuándo NO usarlo.
- **Cuándo usarla:** Al escribir/revisar useEffect, useState para valores derivados, data fetching o sincronización de estado.
- **Seguridad:** Bajo riesgo. Solo guías de código.

### 6. database-schema-designer
- **Propósito:** Diseñar schemas de bases de datos SQL y NoSQL con guías de normalización, estrategias de indexing, migraciones y optimización.
- **Cuándo usarla:** Al diseñar modelos de datos, esquemas relacionales o document stores.
- **Seguridad:** Bajo riesgo. Solo documentación de diseño.

### 7. openapi-to-typescript
- **Propósito:** Convertir especificaciones OpenAPI 3.0 (JSON/YAML) a interfaces TypeScript y type guards.
- **Cuándo usarla:** Al generar tipos desde OpenAPI, convertir schemas a TS, crear interfaces de API.
- **Seguridad:** Bajo riesgo. Solo genera archivos TypeScript.

### 8. qa-test-planner
- **Propósito:** Generar planes de test, casos de prueba manuales, suites de regresión y bug reports. Incluye integración con Figma MCP.
- **Cuándo usarla:** Cuando necesites planificar testing, documentar casos de prueba o reportar bugs.
- **Seguridad:** Riesgo Medio. Contiene scripts bash (`scripts/create_bug_report.sh`, `scripts/generate_test_cases.sh`) que podrían ejecutarse. No ejecutar sin revisar.

### 9. reducing-entropy
- **Propósito:** Minimizar el tamaño total del codebase. Skill manual: solo se activa cuando el usuario lo solicita explícitamente.
- **Cuándo usarla:** Solo cuando solicites explícitamente reducir el tamaño del código.
- **Seguridad:** Puede eliminar código. Solo activar bajo demanda explícita.

### 10. session-handoff
- **Propósito:** Crear documentos de handoff para transferencias de sesión entre agentes AI. Incluye scripts Python de utilidad.
- **Cuándo usarla:** Al solicitar handoff/guardar contexto, cuando el contexto se acerque al límite, al completar hitos, al pausar sesión.
- **Seguridad:** Contiene scripts Python (`scripts/create_handoff.py`, `scripts/validate_handoff.py`, `scripts/list_handoffs.py`, `scripts/check_staleness.py`, `evals/setup_test_env.py`). No ejecutar sin revisar.

### 11. crafting-effective-readmes
- **Propósito:** Escribir o mejorar archivos README con templates y guías según audiencia y tipo de proyecto.
- **Cuándo usarla:** Al crear o mejorar READMEs de proyectos.
- **Seguridad:** Bajo riesgo. Solo genera documentación.

### 12. mermaid-diagrams
- **Propósito:** Guía completa para crear diagramas de software con sintaxis Mermaid (class, sequence, flowchart, ERD, C4, state, etc.).
- **Cuándo usarla:** Al necesitar diagramar, visualizar, modelar arquitectura, flujos, o diseño de sistemas.
- **Seguridad:** Bajo riesgo. Solo genera sintaxis Mermaid.

### 13. commit-work
- **Propósito:** Crear commits de alta calidad: revisar/stagear cambios, dividir en commits lógicos, escribir mensajes claros (Conventional Commits).
- **Cuándo usarla:** Al hacer commit, preparar mensajes, stagear cambios, o dividir trabajo en múltiples commits.
- **Seguridad:** Opera con git. Solo actúa sobre cambios ya stageados.

---

## Ruta de Instalación

Todas las skills se instalaron en modo `project` (no global):

```
C:\Users\alanm\Desktop\StudioProjects\correlativas_historia\.agents\skills\
```

Estructura:
```
.agents/skills/
├── codex/
├── commit-work/
├── crafting-effective-readmes/
├── database-schema-designer/
├── gepetto/
├── mermaid-diagrams/
├── openapi-to-typescript/
├── qa-test-planner/
├── react-dev/
├── react-useeffect/
├── reducing-entropy/
├── requirements-clarity/
└── session-handoff/
```

Cada skill contiene su archivo `SKILL.md` con las instrucciones completas.

Las skills son accesibles desde: Antigravity, Cline, Codex, Cursor, Gemini CLI, GitHub Copilot y OpenCode.

---

## Scripts Detectados (NO EJECUTAR sin revisión)

### qa-test-planner
| Script | Lenguaje | Propósito |
|--------|----------|-----------|
| `scripts/create_bug_report.sh` | Bash | Crear reportes de bug |
| `scripts/generate_test_cases.sh` | Bash | Generar casos de prueba (302 líneas, interactivo) |

### session-handoff
| Script | Lenguaje | Propósito |
|--------|----------|-----------|
| `scripts/create_handoff.py` | Python | Crear documento de handoff |
| `scripts/validate_handoff.py` | Python | Validar documento de handoff |
| `scripts/list_handoffs.py` | Python | Listar handoffs existentes |
| `scripts/check_staleness.py` | Python | Verificar handoffs desactualizados |
| `evals/setup_test_env.py` | Python | Configurar entorno de testing |

**⚠️ Ninguno se ejecutó durante la instalación.** Revisar antes de ejecutar.

---

## No Instaladas

| Skill | Motivo |
|-------|--------|
| `codebase-pattern-finder` | No existe en el repositorio `softaworks/agent-toolkit` |

---

## Comandos de Mantenimiento

### Listar skills instaladas
```bash
npx skills list
```

### Listar skills en formato JSON
```bash
npx skills list --json
```

### Actualizar todas las skills
```bash
npx skills update -y
```

### Actualizar skills globales
```bash
npx skills update -g -y
```

### Actualizar una skill específica
```bash
npx skills update <nombre-skill>
```

### Reinstalar una skill
```bash
npx skills add softaworks/agent-toolkit --skill <nombre> -y
```

### Remover una skill
```bash
npx skills remove <nombre-skill>
```

### Remover todas las skills del proyecto
```bash
npx skills remove --all -y
```

---

## Advertencias de Seguridad

1. **Skills con High Risk:** `codex`, `gepetto` y `qa-test-planner` tienen clasificación "High Risk" por GenAI y "Med Risk" por Snyk. Revisar su SKILL.md antes de activarlas.
2. **Ejecución de scripts:** Las skills de `qa-test-planner` y `session-handoff` contienen scripts bash y Python. No ejecutar scripts de skills sin revisar su contenido primero.
3. **Sandbox modes:** La skill `codex` puede ejecutar comandos en modos `danger-full-access`. Siempre preferir `read-only` o `workspace-write`.
4. **Reducing-entropy:** Puede eliminar código permanentemente. Solo activar cuando sea explícitamente solicitado.
5. **Revisión periódica:** Las skills se ejecutan con permisos completos del agente. Revisar actualizaciones del repositorio origen antes de actualizar.

---

## Notas Técnicas

- **Codex CLI:** No se encontró `codex` como comando global en este entorno. La skill `codex` está instalada por si se instala Codex CLI en el futuro.
- **Node.js:** v24.15.0
- **npm:** 11.12.1
- **Herramienta skills:** v1.5.10 (vía `npx skills`)
- **Repositorio origen:** https://github.com/softaworks/agent-toolkit.git
- **Sistema:** Windows 11
- **Shell:** PowerShell 7.6.2