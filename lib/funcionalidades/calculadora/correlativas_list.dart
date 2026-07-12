// correlativas_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../compartido/proveedores/estado_app.dart';
import '../../modelos/materia.dart';

class CorrelativasList extends ConsumerWidget {
  const CorrelativasList({
    super.key,
    required this.course,
    this.preferSpecialBanner = false,
  });

  final Materia course;
  final bool preferSpecialBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(proveedorPlan).maybeWhen(
          data: (p) => p.materias,
          orElse: () => const <Materia>[],
        );

    final det = course.correlativasDetalladas;

    // Rama "Especial" (solo cuando lo pedís)
    if (preferSpecialBanner) {
      final specials = det.where((c) => c.isSpecial == true).toList();
      if (specials.isNotEmpty) {
        final s = specials.first;
        final tipoRaw = s.type.trim();
        final tipo = tipoRaw.isEmpty ? '' : ' ($tipoRaw)';
        final texto = (s.nombre?.trim().isNotEmpty == true)
            ? s.nombre!.trim()
            : 'Requisito especial';
        return _especialBlock('$texto$tipo');
      }
    }

    // Si no hay nada, texto simple
    if (det.isEmpty && course.correlativas.isEmpty) {
      return const Text(
        'No es correlativa con otras materias.',
        style: TextStyle(color: Color(0xFF9CA3AF)),
      );
    }

    // IMPORTANTE: se elimina la "ventana amarilla".
    // Dejamos solo una lista limpia (sin container de fondo).
    return _plainList(det, all);
  }

  Widget _especialBlock(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Text(
              'Especial',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainList(List<CorrelativaDetallada> det, List<Materia> all) {
    // dedup por lo que se ve (título + tipo)
    final seen = <String>{};
    final items = <CorrelativaDetallada>[];

    for (final c in det) {
      final tipo = c.type.toUpperCase();
      final fallbackId = c.id.trim();
      final title =
          (c.isSpecial == true && (c.nombre?.trim().isNotEmpty == true))
              ? c.nombre!.trim()
              : (_nombreMateria(all, c.id) ??
                      (fallbackId.isEmpty ? 'Requisito' : fallbackId))
                  .trim();

      final key = '${title.toLowerCase()}|$tipo';
      if (seen.add(key)) items.add(c);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((c) {
        final tipo = c.type.toUpperCase();
        final fallbackId = c.id.trim();
        final title =
            (c.isSpecial == true && (c.nombre?.trim().isNotEmpty == true))
                ? c.nombre!.trim()
                : (_nombreMateria(all, c.id) ??
                    (fallbackId.isEmpty ? 'Requisito' : fallbackId));

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _amberChip(title),
              const Spacer(),
              Text(
                tipo.isEmpty ? '' : '($tipo)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _amberChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEAD7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF92400E),
          ),
        ),
      );

  String? _nombreMateria(List<Materia> all, String id) {
    final m = all.where((x) => x.id == id);
    if (m.isEmpty) return null;
    return '${m.first.codigo} — ${m.first.nombre}';
  }
}
