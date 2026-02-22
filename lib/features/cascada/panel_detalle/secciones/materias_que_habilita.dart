// secciones/materias_que_habilita.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:correlativas_historia/models/materia.dart';

import '../utils/reglas_practicas_detalle.dart';
import '../componentes/fila_interactiva.dart';

Widget seccionMateriasQueHabilita({
  required BuildContext context,
  required WidgetRef ref,
  required List<Materia> dependents,
}) {
  final cs = Theme.of(context).colorScheme;

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
      if (dependents.isEmpty)
        Text(
          'No es correlativa con otras materias.',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        )
      else
        ...dependents.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;

          return filaInteractivaMateria(
            context: context,
            ref: ref,
            targetMateria: d,
            abbr: abreviaturaMateria(d),
            name: nombreDetalleTexto(d.nombre),
            statusType: null,
            isYellow: false,
          )
              .animate()
              .fadeIn(delay: (i * 18).ms, duration: 200.ms)
              .slideY(
            begin: 0.05,
            end: 0,
            delay: (i * 18).ms,
            duration: 240.ms,
            curve: Curves.easeOutCubic,
          );
        }),
    ],
  );
}