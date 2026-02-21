import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/providers/app_state.dart';
import '../utils/tipos_carrera.dart';

class BarraControlesUnaLinea extends ConsumerStatefulWidget {
  const BarraControlesUnaLinea({super.key, required this.inputDecorationBuilder});

  final InputDecoration Function(BuildContext, {String? hint}) inputDecorationBuilder;

  @override
  ConsumerState<BarraControlesUnaLinea> createState() => _BarraControlesUnaLineaState();
}

class _BarraControlesUnaLineaState extends ConsumerState<BarraControlesUnaLinea> {
  static const double _h = 44;
  static const double _wTipo = 220;
  static const double _wCarrera = 320;

  TipoCarrera? _selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careers = ref.watch(careersProvider);
    final currentC = ref.watch(selectedCareerInfoProvider);
    final searchVal = ref.watch(searchTermProvider);
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);
    final downloadUrl = ref.watch(careerDownloadUrlProvider);

    final availableTypes = tiposDisponibles(careers);
    final filteredCareers =
    _selectedType == null ? const <CareerInfo>[] : carrerasDeTipo(careers, _selectedType!);

    final initialCareer =
    filteredCareers.any((c) => c.id == currentC.id) ? currentC.id : null;

    final searchCtrl = TextEditingController(text: searchVal)
      ..selection = TextSelection.fromPosition(TextPosition(offset: searchVal.length));

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
        fillColor: isDark ? cs.surface.withValues(alpha: 120 / 255) : const Color(0xFFF3F4F6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  decoration: widget.inputDecorationBuilder(context, hint: 'Seleccioná el tipo'),
                  borderRadius: BorderRadius.circular(12),
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
                  key: ValueKey('career_${_selectedType?.name ?? 'null'}_${initialCareer ?? 'null'}'),
                  initialValue: initialCareer,
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surface : Colors.white,
                  decoration: widget.inputDecorationBuilder(
                    context,
                    hint: _selectedType == null ? 'Elegí primero el tipo' : 'Seleccioná tu carrera',
                  ),
                  borderRadius: BorderRadius.circular(12),
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: _h,
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) => ref.read(searchTermProvider.notifier).state = v,
                decoration: widget.inputDecorationBuilder(context, hint: 'Buscar materia...').copyWith(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchVal.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      ref.read(searchTermProvider.notifier).state = '';
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
                  key: ValueKey('tipoFiltro_${tipo}'),
                  initialValue: tipo == 'todos' ? null : tipo,
                  hint: const Text('Tipos'),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: isDark ? theme.colorScheme.surface : Colors.white,
                  decoration: ddDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: tipos
                      .map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(t == 'todos' ? 'Todos' : t),
                  ))
                      .toList(),
                  onChanged: (v) =>
                  ref.read(filtroTipoProvider.notifier).state = v ?? 'todos',
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
                  dropdownColor: isDark ? theme.colorScheme.surface : Colors.white,
                  decoration: ddDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: <DropdownMenuItem<int?>>[
                    const DropdownMenuItem<int?>(
                      value: -1,
                      child: Text('Todos'),
                    ),
                    ...anios.map((y) => DropdownMenuItem<int?>(
                      value: y,
                      child: Text('$y° Año'),
                    )),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(filtroAnioProvider.notifier).state = (v == -1) ? null : v;
                  },
                ),
              ),
              const SizedBox(width: 12),
              squareIconButton(
                icon: Icons.download_rounded,
                tooltip: 'Descargar',
                onTap: () async {
                  final uri = Uri.parse(downloadUrl);
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No se pudo abrir: $uri')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              squareIconButton(
                icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
                onTap: () {
                  final cur = ref.read(themeModeProvider);
                  ref.read(themeModeProvider.notifier).state =
                  cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}