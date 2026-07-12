import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartido/componentes/etiqueta_opcion_carrera.dart';
import '../../../../compartido/proveedores/estado_app.dart';
import '../../../../modelos/materia.dart';
import '../tema/estilos_calculadora.dart';

class BloqueSelectoresCalculadora extends ConsumerWidget {
  const BloqueSelectoresCalculadora({
    super.key,
    required this.materiasYear,
  });

  final List<Materia> materiasYear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final year = ref.watch(proveedorAnioEvaluacion);
    final selectedId = ref.watch(proveedorIdMateriaCalculadoraSeleccionada);
    final currentCareer = ref.watch(proveedorCarreraSeleccionadaONula);
    final hasSelectedCareer = ref.watch(proveedorTieneCarreraSeleccionada);

    Text label(String text) => Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: EstilosCalculadora.textoPrincipal(context),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label('Carrera de referencia'),
        const SizedBox(height: 6),
        Builder(
          builder: (_) {
            final careers = ref.watch(proveedorCarreras);

            return DropdownButtonFormField<String?>(
              key: ValueKey('career_${currentCareer?.id ?? 'null'}'),
              initialValue: currentCareer?.id,
              isExpanded: true,
              decoration: EstilosCalculadora.decoracionInput(context),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              dropdownColor: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 420,
              itemHeight: 48,
              style: TextStyle(
                fontSize: 15,
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
              items: careers
                  .map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: EtiquetaOpcionCarrera(c),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null || v == currentCareer?.id) return;
                ref.read(proveedorIdCarreraSeleccionada.notifier).state = v;
                ref.read(proveedorAnioEvaluacion.notifier).state = 2;
                ref
                    .read(proveedorIdMateriaCalculadoraSeleccionada.notifier)
                    .state = null;
                ref.read(proveedorMapaEstadosCorrelativas.notifier).clear();
              },
            );
          },
        ),
        const SizedBox(height: 16),
        label('Tramo del plan'),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          key: ValueKey('year_$year'),
          initialValue: year,
          isExpanded: true,
          decoration: EstilosCalculadora.decoracionInput(context),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 360,
          itemHeight: 48,
          style: TextStyle(
            fontSize: 15,
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: const [1, 2, 3, 4]
              .map((y) => DropdownMenuItem(value: y, child: Text('$y° año')))
              .toList(),
          onChanged: !hasSelectedCareer
              ? null
              : (v) {
                  if (v == null) return;
                  ref.read(proveedorAnioEvaluacion.notifier).state = v;
                  ref
                      .read(proveedorIdMateriaCalculadoraSeleccionada.notifier)
                      .state = null;
                  ref.read(proveedorMapaEstadosCorrelativas.notifier).clear();
                },
        ),
        const SizedBox(height: 16),
        label('Materia a poner en contexto'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          key: ValueKey('materia_${selectedId ?? 'null'}'),
          initialValue: selectedId,
          isExpanded: true,
          decoration: EstilosCalculadora.decoracionInput(
            context,
            hint: '-- Seleccioná una materia --',
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: isDark ? cs.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 420,
          itemHeight: 48,
          style: TextStyle(
            fontSize: 15,
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: [
            const DropdownMenuItem<String?>(
              child: Text('-- Seleccioná una materia --'),
            ),
            ...materiasYear.map(
              (m) => DropdownMenuItem<String?>(
                value: m.id,
                child: Text(
                  '${m.codigo} - ${m.nombre}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: !hasSelectedCareer
              ? null
              : (v) {
                  ref
                      .read(proveedorIdMateriaCalculadoraSeleccionada.notifier)
                      .state = v;
                  ref.read(proveedorMapaEstadosCorrelativas.notifier).clear();
                },
        ),
      ],
    );
  }
}
