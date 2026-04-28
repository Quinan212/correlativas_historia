import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/providers/app_state.dart';
import '../../../../shared/widgets/institution_option_label.dart';
import 'estado_requiere_carrera.dart';
import 'institution_selection_overlay.dart';
import '../utils/tipos_carrera.dart';

class BarraControlesUnaLinea extends ConsumerStatefulWidget {
  const BarraControlesUnaLinea({
    super.key,
    required this.inputDecorationBuilder,
  });

  final InputDecoration Function(BuildContext, {String? hint})
      inputDecorationBuilder;

  @override
  ConsumerState<BarraControlesUnaLinea> createState() =>
      _BarraControlesUnaLineaState();
}

class _BarraControlesUnaLineaState
    extends ConsumerState<BarraControlesUnaLinea> {
  static const double _h = 44;
  static const double _wTipo = 210;
  static const double _wCarrera = 280;
  static const double _wInstitucion = 280;

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

  void _clearCareerSelection() {
    ref.read(selectedCareerIdProvider.notifier).state = null;
    ref.read(selectedInstitutionIdProvider.notifier).state = null;
    _resetMapState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careers = ref.watch(careersProvider);
    final currentCareer = ref.watch(selectedCareerInfoOrNullProvider);
    final hasSelectedCareer = ref.watch(hasSelectedCareerProvider);
    final institutions = ref.watch(institutionsForSelectedCareerProvider);
    final currentInstitution = ref.watch(selectedInstitutionInfoProvider);
    final searchValue = ref.watch(searchTermProvider);
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);
    final downloadUrl = ref.watch(careerDownloadUrlProvider);

    final availableTypes = tiposDisponibles(careers);
    final filteredCareers = _selectedType == null
        ? const <CareerInfo>[]
        : carrerasDeTipo(careers, _selectedType!);
    final initialCareer = currentCareer != null &&
            filteredCareers.any((career) => career.id == currentCareer.id)
        ? currentCareer.id
        : null;

    final searchCtrl = TextEditingController(text: searchValue)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: searchValue.length),
      );

    const tipos = <String>[
      'todos',
      'Formación General',
      'Formación Específica',
      'Práctica Profesional',
    ];
    const anios = <int>[1, 2, 3, 4];

    InputDecoration ddDecoration() {
      return InputDecoration(
        filled: true,
        fillColor: isDark
            ? cs.surface.withValues(alpha: 120 / 255)
            : const Color(0xFFF3F4F6),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      );
    }

    Widget squareIconButton({
      required IconData icon,
      required VoidCallback onTap,
      String? tooltip,
    }) {
      final btn = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(icon, size: 20, color: cs.onSurface),
          ),
        ),
      );
      return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
    }

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withValues(alpha: 0.8),
    );

    final inlinePrompt = Container(
      height: _h,
      decoration: BoxDecoration(
        color: isDark ? cs.surface.withValues(alpha: 120 / 255) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.school_outlined,
            size: 18,
            color: cs.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Seleccioná una carrera para habilitar institución, búsqueda, filtros y descarga.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: _wTipo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo de carrera', style: labelStyle),
                const SizedBox(height: 4),
                DropdownButtonFormField<TipoCarrera?>(
                  key: ValueKey('tipo_${_selectedType?.name ?? 'null'}'),
                  initialValue: _selectedType,
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surface : Colors.white,
                  decoration: widget.inputDecorationBuilder(
                    context,
                    hint: 'Seleccioná el tipo',
                  ),
                  borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: _wCarrera,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Carrera', style: labelStyle),
                const SizedBox(height: 4),
                DropdownButtonFormField<String?>(
                  key: ValueKey(
                    'career_${_selectedType?.name ?? 'null'}_${initialCareer ?? 'null'}',
                  ),
                  initialValue: initialCareer,
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surface : Colors.white,
                  decoration: widget.inputDecorationBuilder(
                    context,
                    hint: _selectedType == null
                        ? 'Elegí primero el tipo'
                        : 'Seleccioná tu carrera',
                  ),
                  borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CambioEstadoCarrera(
              activo: hasSelectedCareer,
              placeholder: inlinePrompt,
              child: Row(
                children: [
                  if (institutions.isNotEmpty) ...[
                    SizedBox(
                      width: _wInstitucion,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Institución', style: labelStyle),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String?>(
                            key: ValueKey(
                              'institution_${currentCareer?.id ?? 'null'}_${currentInstitution?.id ?? 'null'}',
                            ),
                            initialValue: currentInstitution?.id,
                            isExpanded: true,
                            itemHeight: 48,
                            dropdownColor: isDark ? cs.surface : Colors.white,
                            decoration: widget.inputDecorationBuilder(
                              context,
                              hint: 'Seleccioná la institución',
                            ),
                            borderRadius: BorderRadius.circular(12),
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
                              if (value == null ||
                                  value == currentInstitution?.id) {
                                return;
                              }
                              InstitutionInfo? nextInstitution;
                              for (final institution in institutions) {
                                if (institution.id == value) {
                                  nextInstitution = institution;
                                  break;
                                }
                              }
                              ref
                                  .read(selectedInstitutionIdProvider.notifier)
                                  .state = value;
                              _resetMapState();
                              if (nextInstitution != null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
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
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: _h,
                      child: TextField(
                        controller: searchCtrl,
                        onChanged: (value) =>
                            ref.read(searchTermProvider.notifier).state = value,
                        decoration: widget
                            .inputDecorationBuilder(
                              context,
                              hint: 'Buscar materia...',
                            )
                            .copyWith(
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: searchValue.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        ref
                                            .read(searchTermProvider.notifier)
                                            .state = '';
                                        searchCtrl.clear();
                                      },
                                    )
                                  : null,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 44,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('tipoFiltro_$tipo'),
                          initialValue: tipo == 'todos' ? null : tipo,
                          hint: const Text('Tipos'),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor:
                              isDark ? theme.colorScheme.surface : Colors.white,
                          decoration: ddDecoration(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: tipos
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item == 'todos' ? 'Todos' : item,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => ref
                              .read(filtroTipoProvider.notifier)
                              .state = value ?? 'todos',
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        height: 44,
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey('anioFiltro_${anio ?? -1}'),
                          initialValue: anio ?? -1,
                          hint: const Text('Años'),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor:
                              isDark ? theme.colorScheme.surface : Colors.white,
                          decoration: ddDecoration(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: <DropdownMenuItem<int?>>[
                            const DropdownMenuItem<int?>(
                              value: -1,
                              child: Text('Todos'),
                            ),
                            ...anios.map(
                              (year) => DropdownMenuItem<int?>(
                                value: year,
                                child: Text('$year° Año'),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            ref.read(filtroAnioProvider.notifier).state =
                                value == -1 ? null : value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      squareIconButton(
                        icon: Icons.download_rounded,
                        tooltip: 'Descargar',
                        onTap: downloadUrl.isEmpty
                            ? () {}
                            : () async {
                                final uri = Uri.parse(downloadUrl);
                                if (!await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                )) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo abrir: $uri',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          squareIconButton(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            onTap: () {
              final current = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
    );
  }
}
