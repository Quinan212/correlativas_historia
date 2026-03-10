import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../../../shared/widgets/career_option_label.dart';
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
    final currentCareer = ref.watch(selectedCareerInfoOrNullProvider);
    final hasSelectedCareer = ref.watch(hasSelectedCareerProvider);

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
                    child: CareerOptionLabel(c),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null || v == currentCareer?.id) return;
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
          onChanged: !hasSelectedCareer
              ? null
              : (v) {
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
          onChanged: !hasSelectedCareer
              ? null
              : (v) {
                  ref.read(selectedCalcMateriaIdProvider.notifier).state = v;
                  ref.read(correlativaStatusMapProvider.notifier).clear();
                },
        ),
      ],
    );
  }
}
