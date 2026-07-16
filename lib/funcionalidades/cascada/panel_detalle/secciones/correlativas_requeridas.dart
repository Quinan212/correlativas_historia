// secciones/correlativas_requeridas.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:correlativas_historia/modelos/materia.dart';

import '../utilidades/reglas_practicas_detalle.dart';
import '../componentes/fila_interactiva.dart';
import '../componentes/bloque_especial.dart';

Widget seccionCorrelativasRequeridas({
  required BuildContext context,
  required WidgetRef ref,
  required List<Materia> all,
  required Materia m,
  required String careerId,
  bool showTitle = true,
}) {
  final cs = Theme.of(context).colorScheme;

  final det = m.correlativasDetalladas;
  final specials = det.where((c) => c.isSpecial == true).toList();
  final onlySpecials = det.isNotEmpty && specials.length == det.length;

  Widget header() {
    if (!showTitle) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correlativas Requeridas',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  if (esPracticaIV(m)) {
    final label = etiquetaEspecialPd4(det) ??
        'Todas las UC de 1°, 2° y 3° año (APROBADAS)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(),
        bloqueEspecial(context, label),
      ],
    );
  }

  if (esPracticaIII(m)) {
    final baseDet = det.where((c) => c.isSpecial != true).toList();
    final ov =
        overridesPd3Ids(careerId, all).where((rec) => rec.$1 != m.id).toList();
    final entries = mergePd3(baseDet, ov);

    final items = entries.map((tuple) {
      final id = tuple.$1;
      final type = tuple.$2;

      final mat = all.firstWhere(
        (x) => x.id == id,
        orElse: () => Materia(
          id: id,
          codigo: id,
          nombre: id,
          anio: 0,
          tipo: '',
          formato: '',
          correlativas: const [],
          correlativasDetalladas: const [],
        ),
      );
      return (mat, type);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(),
        ...items.asMap().entries.map((entry) {
          final e = entry.value;

          final mat = e.$1;
          final type = e.$2;
          final abbr = abreviaturaMateria(mat);

          return filaInteractivaMateria(
            context: context,
            ref: ref,
            targetMateria: mat.nombre == mat.id ? null : mat,
            abbr: abbr,
            name: nombreDetalleTexto(mat.nombre),
            statusType: type,
            isYellow: true,
          );
        }),
        if (items.isEmpty)
          Text('—', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        bloqueEspecial(context, 'Todas las UC de Primer año (APROBADAS)'),
      ],
    );
  }

  if (onlySpecials) {
    final s = specials.first;
    final stype = (s.type).trim().toUpperCase();
    final tipo = stype.isEmpty
        ? ''
        : stype == 'A'
            ? ' (APROBADAS)'
            : stype == 'R'
                ? ' (REGULARIZADAS)'
                : ' ($stype)';
    final texto = (s.nombre?.trim().isNotEmpty ?? false)
        ? s.nombre!.trim()
        : 'Requisito especial';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(),
        bloqueEspecial(context, '$texto$tipo'),
      ],
    );
  }

  final entries = det.map<(String, String)>((c) {
    final t = (c.type.toUpperCase() == 'A') ? 'A' : 'R';
    return (c.id, t);
  }).toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      header(),
      ...entries.asMap().entries.map((entry) {
        final tuple = entry.value;

        final id = tuple.$1;
        final type = tuple.$2;

        final mat = all.firstWhere(
          (x) => x.id == id,
          orElse: () => Materia(
            id: id,
            codigo: id,
            nombre: 'Desconocida',
            anio: 0,
            tipo: '',
            formato: '',
            correlativas: const [],
            correlativasDetalladas: const [],
          ),
        );

        return filaInteractivaMateria(
          context: context,
          ref: ref,
          targetMateria: mat.nombre == 'Desconocida' ? null : mat,
          abbr: abreviaturaMateria(mat),
          name: nombreDetalleTexto(mat.nombre),
          statusType: type,
          isYellow: true,
        );
      }),
      if (entries.isEmpty)
        Text('—', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
    ],
  );
}
