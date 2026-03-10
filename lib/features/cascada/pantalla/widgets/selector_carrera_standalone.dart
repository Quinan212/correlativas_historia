import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../../../shared/widgets/institution_option_label.dart';
import 'institution_selection_overlay.dart';
import '../utils/decoraciones_mapa.dart';
import '../utils/tipos_carrera.dart';

class SelectorCarreraStandalone extends ConsumerStatefulWidget {
  const SelectorCarreraStandalone({super.key});

  @override
  ConsumerState<SelectorCarreraStandalone> createState() =>
      _SelectorCarreraStandaloneState();
}

class _SelectorCarreraStandaloneState
    extends ConsumerState<SelectorCarreraStandalone> {
  TipoCarrera? _selectedType;

  @override
  void initState() {
    super.initState();
    final currentCareer = ref.read(selectedCareerInfoOrNullProvider);
    _selectedType =
        currentCareer == null ? null : tipoCarreraDeId(currentCareer.id);
  }

  void _resetMapState() {
    ref.read(searchTermProvider.notifier).state = '';
    ref.read(filtroTipoProvider.notifier).state = 'todos';
    ref.read(filtroAnioProvider.notifier).state = null;
    ref.read(selectedMateriaIdProvider.notifier).state = null;
    ref.read(zoomProvider.notifier).state = 1.0;
    final tc = ref.read(transformationControllerProvider);
    tc.value = Matrix4.identity();
  }

  void _applyCareerChange(String careerId) {
    final institutions = ref
        .read(institutionsProvider)
        .where((institution) => institution.careerId == careerId)
        .toList(growable: false);

    ref.read(selectedCareerIdProvider.notifier).state = careerId;
    ref.read(selectedInstitutionIdProvider.notifier).state =
        institutions.isEmpty ? null : institutions.first.id;
    _resetMapState();
    if (institutions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showInstitutionSelectionOverlay(
          context,
          institution: institutions.first,
        );
      });
    }
  }

  void _clearCareerSelection() {
    ref.read(selectedCareerIdProvider.notifier).state = null;
    ref.read(selectedInstitutionIdProvider.notifier).state = null;
    _resetMapState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careers = ref.watch(careersProvider);
    final currentCareer = ref.watch(selectedCareerInfoOrNullProvider);
    final institutions = ref.watch(institutionsForSelectedCareerProvider);
    final currentInstitution = ref.watch(selectedInstitutionInfoProvider);

    final availableTypes = tiposDisponibles(careers);
    final filteredCareers = _selectedType == null
        ? const <CareerInfo>[]
        : carrerasDeTipo(careers, _selectedType!);

    final initialCareer = currentCareer != null &&
            filteredCareers.any((career) => career.id == currentCareer.id)
        ? currentCareer.id
        : null;

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
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
                  color: isDark
                      ? const Color(0xFF0B2A42)
                      : const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF9CC7FF)
                      : const Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Seleccioná la carrera',
                  style: theme.textTheme.titleSmall?.copyWith(
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
            decoration: DecoracionesMapa.inputDecoration(
              context,
              hint: 'Tipo de carrera',
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 420,
            itemHeight: 48,
            items: availableTypes
                .map(
                  (type) => DropdownMenuItem<TipoCarrera?>(
                    value: type,
                    child: Text(labelTipoCarrera(type)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
              ref.read(selectedCareerTypeProvider.notifier).state =
                  value == null
                      ? 'todas'
                      : value == TipoCarrera.profesorado
                          ? 'profesorado'
                          : 'grado';
              if (value == null ||
                  (currentCareer != null &&
                      tipoCarreraDeId(currentCareer.id) != value)) {
                _clearCareerSelection();
              }
            },
          ),
          const SizedBox(height: 12),
          Text('Seleccioná la carrera', style: labelStyle),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            key: ValueKey(
              'career_${_selectedType?.name ?? 'null'}_${initialCareer ?? 'null'}',
            ),
            initialValue: initialCareer,
            isExpanded: true,
            dropdownColor: isDark ? cs.surface : Colors.white,
            decoration: DecoracionesMapa.inputDecoration(
              context,
              hint: _selectedType == null
                  ? 'Elegí primero el tipo de carrera'
                  : 'Carrera',
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 420,
            itemHeight: 48,
            items: filteredCareers
                .map(
                  (career) => DropdownMenuItem<String?>(
                    value: career.id,
                    child: Text(
                      career.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: _selectedType == null
                ? null
                : (value) {
                    if (value == null) {
                      _clearCareerSelection();
                      return;
                    }
                    if (value == currentCareer?.id) return;
                    _applyCareerChange(value);
                  },
          ),
          if (institutions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Seleccioná la institución', style: labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              key: ValueKey(
                'institution_${currentCareer?.id ?? 'null'}_${currentInstitution?.id ?? 'null'}',
              ),
              initialValue: currentInstitution?.id,
              isExpanded: true,
              dropdownColor: isDark ? cs.surface : Colors.white,
              decoration: DecoracionesMapa.inputDecoration(
                context,
                hint: 'Institución',
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 420,
              itemHeight: 48,
              selectedItemBuilder: (context) => institutions
                  .map(
                    (institution) => InstitutionOptionLabel(
                      institution,
                      iconSize: 30,
                      enableMarquee: true,
                    ),
                  )
                  .toList(),
              items: institutions
                  .map(
                    (institution) => DropdownMenuItem<String?>(
                      value: institution.id,
                      child: InstitutionOptionLabel(
                        institution,
                        iconSize: 30,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null || value == currentInstitution?.id) return;
                InstitutionInfo? nextInstitution;
                for (final institution in institutions) {
                  if (institution.id == value) {
                    nextInstitution = institution;
                    break;
                  }
                }
                ref.read(selectedInstitutionIdProvider.notifier).state = value;
                _resetMapState();
                if (nextInstitution != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    showInstitutionSelectionOverlay(
                      context,
                      institution: nextInstitution!,
                    );
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
