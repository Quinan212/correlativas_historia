import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../compartido/proveedores/estado_app.dart';
import '../../../../compartido/componentes/etiqueta_opcion_institucion.dart';
import 'capa_seleccion_institucion.dart';
import '../utilidades/tipos_carrera.dart';

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
  static const double _wTipo = 190;
  static const double _wCarrera = 260;
  static const double _wFiltro = 140;

  TipoCarrera? _selectedType;

  @override
  void initState() {
    super.initState();
    final currentCareer = ref.read(proveedorCarreraSeleccionadaONula);
    _selectedType =
        currentCareer == null ? null : tipoCarreraDeId(currentCareer.id);
  }

  void _resetMapState() {
    ref.read(proveedorTerminoBusqueda.notifier).state = '';
    ref.read(filtroTipoProvider.notifier).state = 'todos';
    ref.read(filtroAnioProvider.notifier).state = null;
    ref.read(proveedorIdMateriaSeleccionada.notifier).state = null;
    ref.read(proveedorZoom.notifier).state = 1.0;
    final tc = ref.read(proveedorControladorTransformacion);
    tc.value = Matrix4.identity();
  }

  void _clearCareerSelection() {
    ref.read(proveedorIdCarreraSeleccionada.notifier).state = null;
    ref.read(proveedorIdInstitucionSeleccionada.notifier).state = null;
    _resetMapState();
  }

  void _applyCareerChange(String careerId) {
    final institutions = ref
        .read(proveedorInstituciones)
        .where((institution) => institution.careerId == careerId)
        .toList(growable: false);

    ref.read(proveedorIdCarreraSeleccionada.notifier).state = careerId;
    ref.read(proveedorIdInstitucionSeleccionada.notifier).state =
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

    final careers = ref.watch(proveedorCarreras);
    final currentCareer = ref.watch(proveedorCarreraSeleccionadaONula);
    final hasSelectedCareer = ref.watch(proveedorTieneCarreraSeleccionada);
    final institutions = ref.watch(proveedorInstitucionesCarreraSeleccionada);
    final currentInstitution = ref.watch(proveedorInstitucionSeleccionada);
    final searchValue = ref.watch(proveedorTerminoBusqueda);
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);
    final downloadUrl = ref.watch(proveedorUrlDescargaCarrera);

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
            ? cs.surface.withOpacity(120 / 255)
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

    final inlinePrompt = Container(
      height: _h,
      decoration: BoxDecoration(
        color: isDark ? cs.surface.withOpacity(120 / 255) : Colors.white,
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
            color: theme.shadowColor.withOpacity(0.12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1180;

          Widget typeDropdown = SizedBox(
            width: _wTipo,
            child: DropdownButtonFormField<TipoCarrera?>(
              key: const ValueKey('tipo_'),
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
                ref.read(proveedorTipoCarreraSeleccionada.notifier).state =
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
          );

          Widget careerDropdown = SizedBox(
            width: _wCarrera,
            child: DropdownButtonFormField<String?>(
              key: const ValueKey('career__'),
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
          );

          Widget institutionDropdown = institutions.isNotEmpty
              ? DropdownButtonFormField<String?>(
                  key: const ValueKey('institution__'),
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
                        (institution) => EtiquetaOpcionInstitucion(
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
                          child: EtiquetaOpcionInstitucion(
                            institution,
                            iconSize: 30,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null || value == currentInstitution?.id) {
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
                        .read(proveedorIdInstitucionSeleccionada.notifier)
                        .state = value;
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
                )
              : const SizedBox.shrink();

          Widget searchField = TextField(
            controller: searchCtrl,
            onChanged: (value) =>
                ref.read(proveedorTerminoBusqueda.notifier).state = value,
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
                            ref.read(proveedorTerminoBusqueda.notifier).state =
                                '';
                            searchCtrl.clear();
                          },
                        )
                      : null,
                ),
          );

          Widget tipoFiltro = SizedBox(
            width: _wFiltro,
            height: 44,
            child: DropdownButtonFormField<String>(
              key: const ValueKey('tipoFiltro_'),
              initialValue: tipo == 'todos' ? null : tipo,
              hint: const Text('Tipos'),
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: isDark ? theme.colorScheme.surface : Colors.white,
              decoration: ddDecoration(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: tipos
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item == 'todos' ? 'Todos' : item),
                    ),
                  )
                  .toList(),
              onChanged: (value) => ref
                  .read(filtroTipoProvider.notifier)
                  .state = value ?? 'todos',
            ),
          );

          Widget anioFiltro = SizedBox(
            width: _wFiltro,
            height: 44,
            child: DropdownButtonFormField<int?>(
              key: const ValueKey('anioFiltro_'),
              initialValue: anio ?? -1,
              hint: const Text('Años'),
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: isDark ? theme.colorScheme.surface : Colors.white,
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
          );

          Widget actionButtons = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                                content: Text('No se pudo abrir: '),
                              ),
                            );
                          }
                        }
                      },
              ),
              const SizedBox(width: 8),
              squareIconButton(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
                onTap: () {
                  final current = ref.read(proveedorModoTema);
                  ref.read(proveedorModoTema.notifier).state =
                      current == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                },
              ),
            ],
          );

          if (isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    typeDropdown,
                    const SizedBox(width: 12),
                    careerDropdown,
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: institutionDropdown,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: _h,
                        child: searchField,
                      ),
                    ),
                    const SizedBox(width: 12),
                    tipoFiltro,
                    const SizedBox(width: 12),
                    anioFiltro,
                    const SizedBox(width: 12),
                    actionButtons,
                  ],
                ),
                if (!hasSelectedCareer) ...[
                  const SizedBox(height: 12),
                  inlinePrompt,
                ],
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  typeDropdown,
                  careerDropdown,
                  institutionDropdown,
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 470,
                    height: _h,
                    child: searchField,
                  ),
                  tipoFiltro,
                  anioFiltro,
                  actionButtons,
                ],
              ),
              if (!hasSelectedCareer) ...[
                const SizedBox(height: 12),
                inlinePrompt,
              ],
            ],
          );
        },
      ),
    );
  }
}
