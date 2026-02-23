import 'package:flutter/material.dart';
import '../../../shared/providers/app_state.dart';
import 'panel_estilos.dart';

class PanelResultado {
  static Widget build(BuildContext context, EvalResult res) {
    final cs = Theme.of(context).colorScheme;
    final dark = EstilosPanel.isDark(context);

    Color colorFor(String label) {
      switch (label) {
        case 'No puede cursar':
          return const Color(0xFFDC2626);
        case 'Cursada condicional':
        case 'Cursa con restricciones':
          return const Color(0xFFF59E0B);
        case 'Puede cursar sin restricciones':
          return const Color(0xFF16A34A);
        default:
          return dark ? cs.onSurface : const Color(0xFF374151);
      }
    }

    Widget cap(String title, bool on, {bool restricted = false}) {
      final bg = on
          ? (restricted
          ? (dark
          ? EstilosPanel.darken(const Color(0xFFF59E0B), 0.78)
          : const Color(0xFFFEF3C7))
          : (dark
          ? EstilosPanel.darken(const Color(0xFF16A34A), 0.78)
          : const Color(0xFFD1FAE5)))
          : (dark ? EstilosPanel.darken(cs.surface, 0.30) : const Color(0xFFF3F4F6));

      final fg = on
          ? (restricted ? const Color(0xFFF59E0B) : const Color(0xFF16A34A))
          : (dark ? cs.onSurfaceVariant : const Color(0xFF6B7280));

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: EstilosPanel.border(context)),
        ),
        child: Text(
          title,
          style: EstilosPanel.gf(size: 12, weight: FontWeight.w600, color: fg, height: 1.0),
        ),
      );
    }

    String stripLeadBullet(String? s) {
      if (s == null) return '';
      var t = s.trimLeft();
      while (t.startsWith('•') || t.startsWith('-') || t.startsWith('–') || t.startsWith('—')) {
        t = t.substring(1).trimLeft();
      }
      return t;
    }

    final noteColor = dark ? cs.onSurface : const Color(0xFF111827);
    final muted = dark ? cs.onSurfaceVariant : const Color(0xFF4B5563);

    final explanation = res.detailedExplanation?.trim();
    final strategy = res.strategy?.trim();
    final hasExplanation = explanation != null && explanation.isNotEmpty;
    final hasStrategy = strategy != null && strategy.isNotEmpty;

    final noteWidgets = <Widget>[];
    for (final raw in res.notes) {
      final clean = stripLeadBullet(raw);
      if (clean.trim().isEmpty) continue;

      noteWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: EstilosPanel.gf(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: noteColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  clean,
                  style: EstilosPanel.gf(
                    size: 13.5,
                    weight: FontWeight.w400,
                    color: noteColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          res.overallLabel,
          style: EstilosPanel.gf(
            size: 18,
            weight: FontWeight.w500,
            color: colorFor(res.overallLabel),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            cap('Actividades', res.activities, restricted: res.activitiesRestricted),
            cap('Parciales', res.exams, restricted: res.examsRestricted),
            cap('Promoción', res.promotion, restricted: false),
          ],
        ),
        if (noteWidgets.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...noteWidgets,
        ],
        if (hasExplanation) ...[
          const SizedBox(height: 8),
          Text(
            explanation,
            style: EstilosPanel.gf(
              size: 13.5,
              weight: FontWeight.w400,
              color: muted,
              height: 1.35,
            ),
          ),
        ],
        if (hasStrategy) ...[
          const SizedBox(height: 10),
          Text(
            'Estrategia: $strategy',
            style: EstilosPanel.gf(
              size: 13.5,
              weight: FontWeight.w600,
              color: noteColor,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }
}