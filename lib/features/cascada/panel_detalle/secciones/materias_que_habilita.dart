// secciones/materias_que_habilita.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:correlativas_historia/models/materia.dart';

import '../utils/reglas_practicas_detalle.dart';
import '../componentes/fila_interactiva.dart';

Widget seccionMateriasQueHabilita({
  required BuildContext context,
  required WidgetRef ref,
  required List<Materia> dependents,
  bool showTitle = true,
}) {
  final cs = Theme.of(context).colorScheme;

  Widget header() {
    if (!showTitle) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materias que Habilita',
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

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      header(),
      if (dependents.isEmpty)
        Text(
          'No es correlativa con otras materias.',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        )
      else
        ...dependents.asMap().entries.map((entry) {
          final d = entry.value;

          return filaInteractivaMateria(
            context: context,
            ref: ref,
            targetMateria: d,
            abbr: abreviaturaMateria(d),
            name: nombreDetalleTexto(d.nombre),
            statusType: null,
            isYellow: false,
          );
        }),
    ],
  );
}
