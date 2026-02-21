import 'package:flutter/material.dart';

class TarjetaLeyendaMapa extends StatelessWidget {
  const TarjetaLeyendaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget colorCard(String label, String desc, Color bg, Color border, Color textC) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(
                  color: textC,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: textC.withValues(alpha: 0.8),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget chipRow(String label, String desc, Color bg, Color fg) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: bg == const Color(0xFFE5E7EB)
                        ? Colors.grey.shade300
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desc,
                style: tt.bodySmall?.copyWith(color: cs.onSurface, height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: theme.shadowColor.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            maintainState: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            backgroundColor: isDark ? cs.surface : Colors.white,
            collapsedBackgroundColor: isDark ? cs.surface : Colors.white,
            shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
            iconColor: cs.primary,
            collapsedIconColor: cs.onSurfaceVariant,
            title: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 22, color: cs.primary),
                const SizedBox(width: 12),
                Text(
                  'Guía de Referencias',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 34.0, top: 2),
              child: Text(
                'Entendé los colores y etiquetas del mapa.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            children: [
              Divider(color: isDark ? cs.outlineVariant : Colors.grey.shade200),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'COLORES DE LAS MATERIAS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colorCard('General', 'Formación común y transversal.', const Color(0xFFE0E7FF),
                      const Color(0xFFC7D2FE), const Color(0xFF1E40AF)),
                  colorCard('Específica', 'Propia de la especialidad.', const Color(0xFFD1FAE5),
                      const Color(0xFFA7F3D0), const Color(0xFF065F46)),
                  colorCard('Práctica', 'Vinculación profesional.', const Color(0xFFEDE9FE),
                      const Color(0xFFDDD6FE), const Color(0xFF6D28D9)),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ETIQUETAS Y FORMATOS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              chipRow('Asignatura', 'Materia regular teórica/práctica.', const Color(0xFFE0E7FF),
                  const Color(0xFF1D4ED8)),
              chipRow('Seminario', 'Estudio intensivo de un tema específico.', const Color(0xFFD1FAE5),
                  const Color(0xFF065F46)),
              chipRow('Taller', 'Espacio práctico de producción.', const Color(0xFFFDEAD7),
                  const Color(0xFF9A3412)),
              chipRow('Sem-Taller', 'Combinación aplicada de seminario.', const Color(0xFFEDE9FE),
                  const Color(0xFF6B7280)),
              chipRow('Variable', 'Definido por la institución (UDI).', const Color(0xFFE5E7EB),
                  const Color(0xFF374151)),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: isDark ? cs.outlineVariant : Colors.grey.shade100,
              ),
              const SizedBox(height: 16),
              chipRow('ABC', 'Abreviatura del nombre de la materia.', const Color(0xFFFEF3C7),
                  const Color(0xFF92400E)),
              chipRow('Especial', 'Requisito especial (ej. tener todas aprobadas).', const Color(0xFFE0E7FF),
                  const Color(0xFF1D4ED8)),
            ],
          ),
        ),
      ),
    );
  }
}