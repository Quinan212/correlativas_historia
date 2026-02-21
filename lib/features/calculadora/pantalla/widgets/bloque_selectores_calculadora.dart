import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../../../models/materia.dart';
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

    final year = ref.watch(evalYearProvider);
    final selectedId = ref.watch(selectedCalcMateriaIdProvider);

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
        label('Carrera:'),
        const SizedBox(height: 6),
        Builder(builder: (_) {
          final careers = ref.watch(careersProvider);
          final currentC = ref.watch(selectedCareerInfoProvider);

          return DropdownButtonFormField<String>(
            key: ValueKey('career_${currentC.id}'),
            initialValue: currentC.id,
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
                  (c) => DropdownMenuItem<String>(
                value: c.id,
                child: Text(c.nombre, overflow: TextOverflow.ellipsis),
              ),
            )
                .toList(),
            onChanged: (v) {
              if (v == null || v == currentC.id) return;
              ref.read(selectedCareerIdProvider.notifier).state = v;
              ref.read(evalYearProvider.notifier).state = 2;
              ref.read(selectedCalcMateriaIdProvider.notifier).state = null;
              ref.read(correlativaStatusMapProvider.notifier).clear();
            },
          );
        }),
        const SizedBox(height: 16),
        label('Año:'),
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
              .map((y) => DropdownMenuItem(value: y, child: Text('$y° Año')))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            ref.read(evalYearProvider.notifier).state = v;
            ref.read(selectedCalcMateriaIdProvider.notifier).state = null;
            ref.read(correlativaStatusMapProvider.notifier).clear();
          },
        ),
        const SizedBox(height: 16),
        label('Materia:'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          key: ValueKey('materia_${selectedId ?? 'null'}'),
          initialValue: selectedId,
          isExpanded: true,
          decoration: EstilosCalculadora.decoracionInput(
            context,
            hint: '-- Elige una materia --',
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
              value: null,
              child: Text('-- Elige una materia --'),
            ),
            ...materiasYear.map(
                  (m) => DropdownMenuItem<String?>(
                value: m.id,
                child: Text(
                  '${m.codigo} — ${m.nombre}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (v) {
            ref.read(selectedCalcMateriaIdProvider.notifier).state = v;
            ref.read(correlativaStatusMapProvider.notifier).clear();
          },
        ),
      ],
    );
  }
}