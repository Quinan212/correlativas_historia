# Auditoría de Copias dentro de `lib/`

**Proyecto:** C:\Users\alanm\Desktop\StudioProjects\Correlativas  
**Fecha:** 21/07/2026  
**Fase:** 1 — Auditoría sin borrado

---

## Resumen

| Métrica | Valor |
|---|---|
| Cantidad total de archivos revisados | 4 |
| Cantidad de sospechosos | 4 |
| Copias temporales confirmadas | 4 |
| Duplicados exactos | 0 |
| Versiones anteriores | 4 |
| Archivos activos legítimos | 0 (no incluidos en esta auditoría) |
| Código legacy preservado | 0 |
| Casos dudosos | 0 |

---

## Archivo activo de referencia

| Propiedad | Valor |
|---|---|
| Ruta | `lib/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart` |
| Tamaño | 23887 bytes |
| SHA-256 | `E857BB0270DA01D317598453725D63AE0798482920DCB706268FB1FC32CD3868` |
| Última modificación | 21/07/2026 (versión V4 aplicada) |

---

## Tabla detallada

| # | Ruta | Categoría | Archivo activo relacionado | Hash igual | Referencias | Acción sugerida |
|---|---|---|---|---|---|---|
| 1 | `lib/.../inicio_trayectoria_atlassian.dart.pre_ajuste_tarjetas` | B. Backup pre-reemplazo | `inicio_trayectoria_atlassian.dart` | NO | Ninguna | Eliminar |
| 2 | `lib/.../inicio_trayectoria_atlassian.dart.pre_sugerencias_v2` | B. Backup pre-reemplazo | `inicio_trayectoria_atlassian.dart` | NO | Ninguna | Eliminar |
| 3 | `lib/.../inicio_trayectoria_atlassian.dart.pre_sugerencias_v3` | B. Backup pre-reemplazo | `inicio_trayectoria_atlassian.dart` | NO | Ninguna | Eliminar |
| 4 | `lib/.../inicio_trayectoria_atlassian.dart.pre_sugerencias_v4` | B. Backup pre-reemplazo | `inicio_trayectoria_atlassian.dart` | NO | Ninguna | Eliminar |

---

## Archivo 1 — `inicio_trayectoria_atlassian.dart.pre_ajuste_tarjetas`

- **Ruta completa:** `C:\Users\alanm\Desktop\StudioProjects\Correlativas\lib\funcionalidades\laboratorio_atlassian\componentes\inicio_trayectoria_atlassian.dart.pre_ajuste_tarjetas`
- **Nombre:** `inicio_trayectoria_atlassian.dart.pre_ajuste_tarjetas`
- **Tamaño:** 22346 bytes
- **Fecha de modificación:** 20/07/2026 22:15:19
- **Extensión real:** `.pre_ajuste_tarjetas`
- **Archivo activo relacionado:** `inicio_trayectoria_atlassian.dart`
- **Motivo por el que parece una copia:** Tiene extensión `.pre_ajuste_tarjetas`, es un backup previo al primer ajuste de tarjetas (antes de V1).
- **Contenido idéntico al archivo activo:** NO
- **SHA-256:** `1979094B04CCA461AFD25056E98E9D335C0DF9C5728A47400D1A3FDDA02415BD`
- **SHA-256 del archivo activo:** `E857BB0270DA01D317598453725D63AE0798482920DCB706268FB1FC32CD3868`
- **Importado por otro archivo:** NO
- **Referenciado por tests:** NO
- **Referenciado por pubspec:** NO
- **Compila como Dart:** NO (extensión `.pre_ajuste_tarjetas`, ignorada por Flutter)
- **Categoría propuesta:** B. Backup pre-reemplazo confirmado
- **Acción sugerida:** Eliminar (respaldos conservados en `C:\Users\alanm\Desktop\RESPALDOS_SAGE\`)

**Diferencias principales con el activo:**
- No tenía `pinnedAlignmentOffset` ni `cardsPinnedAlignmentOffset` (anterior a V3/V4)
- Usaba `Row/Expanded` en lugar de `Center` para el título
- No tenía `_cardsTopAdjustment`

---

## Archivo 2 — `inicio_trayectoria_atlassian.dart.pre_sugerencias_v2`

- **Ruta completa:** `C:\Users\alanm\Desktop\StudioProjects\Correlativas\lib\funcionalidades\laboratorio_atlassian\componentes\inicio_trayectoria_atlassian.dart.pre_sugerencias_v2`
- **Nombre:** `inicio_trayectoria_atlassian.dart.pre_sugerencias_v2`
- **Tamaño:** 22516 bytes
- **Fecha de modificación:** 21/07/2026 02:15:50
- **Extensión real:** `.pre_sugerencias_v2`
- **Archivo activo relacionado:** `inicio_trayectoria_atlassian.dart`
- **Motivo por el que parece una copia:** Backup generado antes de aplicar V2.
- **Contenido idéntico al archivo activo:** NO
- **SHA-256:** `BC31D726B572C3F9F55135AE3DCA3B716485B95DFD0D7BA70C4B941F04C9B78E`
- **SHA-256 del archivo activo:** `E857BB0270DA01D317598453725D63AE0798482920DCB706268FB1FC32CD3868`
- **Importado por otro archivo:** NO
- **Referenciado por tests:** NO
- **Referenciado por pubspec:** NO
- **Compila como Dart:** NO
- **Categoría propuesta:** B. Backup pre-reemplazo confirmado
- **Acción sugerida:** Eliminar

**Diferencias principales con el activo:**
- `_sectionTopPadding = 72.0` (no 16.0)
- Sin `_cardsTopAdjustment`, sin `_pinnedAlignmentOffset`
- Sin `_mobileMenuTop`, `_mobileMenuSize`

---

## Archivo 3 — `inicio_trayectoria_atlassian.dart.pre_sugerencias_v3`

- **Ruta completa:** `C:\Users\alanm\Desktop\StudioProjects\Correlativas\lib\funcionalidades\laboratorio_atlassian\componentes\inicio_trayectoria_atlassian.dart.pre_sugerencias_v3`
- **Nombre:** `inicio_trayectoria_atlassian.dart.pre_sugerencias_v3`
- **Tamaño:** 22617 bytes
- **Fecha de modificación:** 21/07/2026 02:26:11
- **Extensión real:** `.pre_sugerencias_v3`
- **Archivo activo relacionado:** `inicio_trayectoria_atlassian.dart`
- **Motivo por el que parece una copia:** Backup generado antes de aplicar V3.
- **Contenido idéntico al archivo activo:** NO
- **SHA-256:** `CA6E247A683320582D530F37869786549B02251A62D39371E51F1C229A8FE0A8`
- **SHA-256 del archivo activo:** `E857BB0270DA01D317598453725D63AE0798482920DCB706268FB1FC32CD3868`
- **Importado por otro archivo:** NO
- **Referenciado por tests:** NO
- **Referenciado por pubspec:** NO
- **Compila como Dart:** NO
- **Categoría propuesta:** B. Backup pre-reemplazo confirmado
- **Acción sugerida:** Eliminar

**Diferencias principales con el activo:**
- Tenía `_cardsTopAdjustment = 20.0`
- Sin `_mobileAlignmentOffset`, sin `_cardsPinnedAlignmentOffset`
- Usaba `_pinnedAlignmentOffset(context, shrinkOffset)` (interpolado)

---

## Archivo 4 — `inicio_trayectoria_atlassian.dart.pre_sugerencias_v4`

- **Ruta completa:** `C:\Users\alanm\Desktop\StudioProjects\Correlativas\lib\funcionalidades\laboratorio_atlassian\componentes\inicio_trayectoria_atlassian.dart.pre_sugerencias_v4`
- **Nombre:** `inicio_trayectoria_atlassian.dart.pre_sugerencias_v4`
- **Tamaño:** 23614 bytes
- **Fecha de modificación:** 21/07/2026 02:44:49
- **Extensión real:** `.pre_sugerencias_v4`
- **Archivo activo relacionado:** `inicio_trayectoria_atlassian.dart`
- **Motivo por el que parece una copia:** Backup generado antes de aplicar V4.
- **Contenido idéntico al archivo activo:** NO
- **SHA-256:** `0D70E4A846865F079F7EB2C6677F3835C55192CE0D7DF16D3661A362F6795B29`
- **SHA-256 del archivo activo:** `E857BB0270DA01D317598453725D63AE0798482920DCB706268FB1FC32CD3868`
- **Importado por otro archivo:** NO
- **Referenciado por tests:** NO
- **Referenciado por pubspec:** NO
- **Compila como Dart:** NO
- **Categoría propuesta:** B. Backup pre-reemplazo confirmado
- **Acción sugerida:** Eliminar

**Diferencias principales con el activo:**
- Tenía `_pinnedAlignmentOffset` (interpolado para título y tarjetas)
- No tenía `_mobileAlignmentOffset`, `_cardsPinnedAlignmentOffset`, `fixedHeaderAlignmentOffset`

---

## Lista propuesta para eliminación (Fase 2)

| # | Ruta |
|---|---|
| 1 | `lib/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart.pre_ajuste_tarjetas` |
| 2 | `lib/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart.pre_sugerencias_v2` |
| 3 | `lib/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart.pre_sugerencias_v3` |
| 4 | `lib/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart.pre_sugerencias_v4` |

**Total: 4 archivos**

---

## Lista que debe conservarse

Ninguno de los archivos auditados corresponde a las categorías E, F, G o H. Todos son backups temporales pre-reemplazo.

---

## Notas adicionales

- Los 4 archivos son backups generados por el agente antes de cada reemplazo del archivo activo.
- Ninguno tiene extensión `.dart`, por lo que Flutter los ignora completamente en compilación.
- No existe ninguna referencia (import, part, ruta, test, pubspec) hacia ninguno de ellos.
- Los respaldos completos de cada versión ya se conservan en `C:\Users\alanm\Desktop\RESPALDOS_SAGE\`.
- El archivo activo `inicio_trayectoria_atlassian.dart` (V4) está verificado, compila y funciona correctamente.
- No se encontraron archivos con extensiones `.bak`, `.backup`, `.old`, `.orig`, `.tmp`, `.temp`, `.copy`, `.copia` en `lib/`.
- No se encontraron archivos con nombres conteniendo `_v1`, `_v2`, `_v3`, `_v4` (excepto estos backups).
