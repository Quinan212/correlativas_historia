import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../utils/decoraciones_mapa.dart';
import '../utils/tipos_carrera.dart';

class SelectorCarreraStandalone extends ConsumerStatefulWidget {
  const SelectorCarreraStandalone({super.key});

  @override
  ConsumerState<SelectorCarreraStandalone> createState() => _SelectorCarreraStandaloneState();
}

class _SelectorCarreraStandaloneState extends ConsumerState<SelectorCarreraStandalone> {
  TipoCarrera? _selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careers = ref.watch(careersProvider);
    final currentC = ref.watch(selectedCareerInfoProvider);

    final availableTypes = tiposDisponibles(careers);
    final filteredCareers =
    _selectedType == null ? const <CareerInfo>[] : carrerasDeTipo(careers, _selectedType!);

    final initialCareer =
    filteredCareers.any((c) => c.id == currentC.id) ? currentC.id : null;

    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withValues(alpha: 0.8),
    );

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B2A42) : const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF9CC7FF) : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Seleccioná la Carrera',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Seleccioná el tipo de carrera', style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<TipoCarrera?>(
            key: ValueKey('tipo_${_selectedType?.name ?? 'null'}'),
            initialValue: _selectedType,
            isExpanded: true,
            dropdownColor: isDark ? cs.surface : Colors.white,
            decoration: DecoracionesMapa.inputDecoration(context, hint: 'Tipo de carrera'),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 420,
            itemHeight: 48,
            items: availableTypes
                .map((t) => DropdownMenuItem<TipoCarrera?>(
              value: t,
              child: Text(labelTipoCarrera(t)),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Text('Seleccioná la carrera', style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            key: ValueKey('career_${_selectedType?.name ?? 'null'}_${initialCareer ?? 'null'}'),
            initialValue: initialCareer,
            isExpanded: true,
            dropdownColor: isDark ? cs.surface : Colors.white,
            decoration: DecoracionesMapa.inputDecoration(
              context,
              hint: _selectedType == null ? 'Elegí primero el tipo de carrera' : 'Carrera',
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 420,
            itemHeight: 48,
            items: filteredCareers
                .map((c) => DropdownMenuItem<String?>(
              value: c.id,
              child: Text(c.nombre, overflow: TextOverflow.ellipsis),
            ))
                .toList(),
            onChanged: _selectedType == null
                ? null
                : (v) {
              if (v == null || v == currentC.id) return;
              ref.read(selectedCareerIdProvider.notifier).state = v;
              ref.read(searchTermProvider.notifier).state = '';
              ref.read(filtroTipoProvider.notifier).state = 'todos';
              ref.read(filtroAnioProvider.notifier).state = null;
              ref.read(selectedMateriaIdProvider.notifier).state = null;
              ref.read(zoomProvider.notifier).state = 1.0;
              final tc = ref.read(transformationControllerProvider);
              tc.value = Matrix4.identity();
            },
          ),
        ],
      ),
    );
  }
}