export 'pantalla/pantalla_mapa_correlatividades.dart';

/*
import 'dart:math' as math;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../shared/providers/app_state.dart';
import 'filters_bar.dart';
import 'visualization_grid.dart';



enum _CareerType { profesorado, grado }

_CareerType _careerTypeForId(String id) {
  switch (id) {
    case 'contador':
      return _CareerType.grado;
    default:
      return _CareerType.profesorado;
  }
}

String _careerTypeLabel(_CareerType t) {
  switch (t) {
    case _CareerType.profesorado:
      return 'Profesorados';
    case _CareerType.grado:
      return 'Carreras de grado';
  }
}

List<_CareerType> _availableCareerTypes(List<CareerInfo> careers) {
  final set = <_CareerType>{};
  for (final c in careers) {
    set.add(_careerTypeForId(c.id));
  }
  return set.where((t) => t != _CareerType.grado).toList();
}

List<CareerInfo> _careersOfType(List<CareerInfo> careers, _CareerType type) {
  return careers.where((c) => _careerTypeForId(c.id) == type).toList();
}

class CascadaScreen extends ConsumerWidget {
  const CascadaScreen({super.key});

  static const kPageBgLight = Color(0xFFF5F7FA);

  static const double kMaxWGeneral = 1400;
  static const double kColsFactor = 1.18;
  static const double kColsSidePadding = 12.0;

  bool _isWindowsDesktop() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  Widget _pageContainer(BuildContext context, Widget child) {
    final w = MediaQuery.of(context).size.width;
    final double maxW = w < kMaxWGeneral ? w : kMaxWGeneral;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ),
    );
  }

  Widget _columnsContainer(BuildContext context, Widget child) {
    final w = MediaQuery.of(context).size.width;
    const double byFactor = kMaxWGeneral * kColsFactor;
    final double byScreen =
    (w - (kColsSidePadding * 2)).clamp(0.0, double.infinity);
    final double maxW = math.min(byFactor, byScreen);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kColsSidePadding),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final topInset = MediaQuery.of(context).viewPadding.top;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1180;
    final isWindowsDesktop = _isWindowsDesktop();



    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: _CollapsingBannerDelegate(topInset: topInset),
          ),
          SliverToBoxAdapter(
            child: _pageContainer(
              context,
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop && isWindowsDesktop) ...[
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _HeroHeaderWrapper()),
                          SizedBox(width: 12),
                          Expanded(child: _RegimenCardWrapper()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _OneLineControlsBar(
                        inputDecorationBuilder: _inputDecoration,
                      ),
                    ] else ...[
                      const _HeroHeaderWrapper(),
                      const SizedBox(height: 12),
                      if (isDesktop) ...[
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _RegimenCardWrapper()),
                            SizedBox(width: 12),
                            Expanded(child: _CareerSelectorCardStandalone()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const FiltersBar(),
                      ] else ...[
                        const _RegimenCardWrapper(),
                        const SizedBox(height: 12),
                        const _CareerSelectorCardStandalone(),
                        const SizedBox(height: 12),
                        const FiltersBar(),
                      ],
                    ],
                    const SizedBox(height: 12),
                    if (!isDesktop) const VisualizationGrid(),
                  ],
                ),
              ),
            ),
          ),
          if (isDesktop)
            SliverToBoxAdapter(
              child: _columnsContainer(
                context,
                const _DesktopYearBoard(),
              ),
            ),
          SliverToBoxAdapter(
            child: _pageContainer(
              context,
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _leyenda(context),
                    const SizedBox(height: 12),
                    _autorTop(context),
                    const SizedBox(height: 24),
                    planAsync.when(
                      data: (_) => const SizedBox.shrink(),
                      loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text(
                        'Error cargando plan: $e',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa de Correlatividades:\n¿Qué Me Falta?',
            style: tt.headlineSmall?.copyWith(
              height: 1.18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Con ¿Qué Me Falta? podés ver al instante qué materias te faltan para cursar o rendir. Seleccionás la materia en un mapa interactivo y el sistema te muestra sus correlativas previas y posteriores. Así sabés exactamente qué te habilita a seguir avanzando.',
            style: tt.bodyMedium?.copyWith(
              height: 1.55,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _regimenCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final career = ref.watch(selectedCareerInfoProvider);

    String carreraLinea;
    String articuloCentro;
    String institucionLinea;
    String? resolucion;

    switch (career.id) {
      case 'geografia':
        carreraLinea = 'Profesorado de Educación Secundaria en Geografía';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion =
        'Resolución N° 0766 C.G.E. | Expte. Grabado N° (1507261) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'historia':
        carreraLinea = 'Profesorado de Educación Secundaria en Historia';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion =
        'Resolución N° 0765 C.G.E. | Expte. Grabado N° (1506606) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'artes_visuales':
        carreraLinea = 'Profesorado de Artes Visuales';
        articuloCentro = 'la';
        institucionLinea =
        'Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"';
        resolucion =
        'Resolución N° 0440/23 C.G.E. | Expte. Grabado N° (1943528) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'musica':
        carreraLinea =
        'Profesorado de Música con Orientación en Educación Musical';
        articuloCentro = 'la';
        institucionLinea =
        'Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"';
        resolucion =
        'Resolución N° 2867/23 C.G.E. | Expte. Grabado N° (2856760) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'fisica':
        carreraLinea = 'Profesorado de Educación Física';
        articuloCentro = 'el';
        institucionLinea =
        'Instituto Superior de las Especialidades de la Educación Física';
        resolucion =
        'Resolución N° 0338/23 C.G.E. | Expte. Grabado N° (1943502) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'politica':
        carreraLinea =
        'Profesorado de Educación Secundaria en Ciencia Política';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion = null;
        break;
      default:
        carreraLinea = career.nombre;
        articuloCentro = 'la';
        institucionLinea = 'institución correspondiente';
        resolucion = null;
    }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Régimen de Correlatividades Vigente',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                  'Este sistema está basado en el régimen de correlatividades actual para la carrera de ',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                TextSpan(
                  text: carreraLinea,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' que se cursa en $articuloCentro ',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                TextSpan(
                  text: institucionLinea,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (resolucion != null) ...[
            Text(
              resolucion,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Si querés acceder directamente al documento oficial, podés hacerlo con el botón de descarga que encontrarás justo al final del menú de opciones.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(BuildContext context,
      {String? hint}) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? cs.surface : Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

  Widget _leyenda(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget colorCard(
        String label,
        String desc,
        Color bg,
        Color border,
        Color textC,
        ) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(
                  color: textC,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: textC.withOpacity(0.8),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget chipRow(String label, String desc, Color bg, Color fg) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Container(
                alignment: Alignment.center,
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: bg == const Color(0xFFE5E7EB)
                        ? Colors.grey.shade300
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desc,
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurface, height: 1.3),
              ),
            ),
          ],
        ),
      );
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            maintainState: true,
            tilePadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            childrenPadding:
            const EdgeInsets.fromLTRB(20, 0, 20, 24),
            backgroundColor: isDark ? cs.surface : Colors.white,
            collapsedBackgroundColor:
            isDark ? cs.surface : Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            collapsedShape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            iconColor: cs.primary,
            collapsedIconColor: cs.onSurfaceVariant,
            title: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Guía de Referencias',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 34.0, top: 2),
              child: Text(
                'Entendé los colores y etiquetas del mapa.',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            children: [
              Divider(
                color:
                isDark ? cs.outlineVariant : Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'COLORES DE LAS MATERIAS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colorCard(
                    'General',
                    'Formación común y transversal.',
                    const Color(0xFFE0E7FF),
                    const Color(0xFFC7D2FE),
                    const Color(0xFF1E40AF),
                  ),
                  colorCard(
                    'Específica',
                    'Propia de la especialidad.',
                    const Color(0xFFD1FAE5),
                    const Color(0xFFA7F3D0),
                    const Color(0xFF065F46),
                  ),
                  colorCard(
                    'Práctica',
                    'Vinculación profesional.',
                    const Color(0xFFEDE9FE),
                    const Color(0xFFDDD6FE),
                    const Color(0xFF6D28D9),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ETIQUETAS Y FORMATOS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              chipRow(
                'Asignatura',
                'Materia regular teórica/práctica.',
                const Color(0xFFE0E7FF),
                const Color(0xFF1D4ED8),
              ),
              chipRow(
                'Seminario',
                'Estudio intensivo de un tema específico.',
                const Color(0xFFD1FAE5),
                const Color(0xFF065F46),
              ),
              chipRow(
                'Taller',
                'Espacio práctico de producción.',
                const Color(0xFFFDEAD7),
                const Color(0xFF9A3412),
              ),
              chipRow(
                'Sem-Taller',
                'Combinación aplicada de seminario.',
                const Color(0xFFEDE9FE),
                const Color(0xFF6D28D9),
              ),
              chipRow(
                'Variable',
                'Definido por la institución (UDI).',
                const Color(0xFFE5E7EB),
                const Color(0xFF374151),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: isDark
                    ? cs.outlineVariant
                    : Colors.grey.shade100,
              ),
              const SizedBox(height: 16),
              chipRow(
                'ABC',
                'Abreviatura del nombre de la materia.',
                const Color(0xFFFEF3C7),
                const Color(0xFF92400E),
              ),
              chipRow(
                'Especial',
                'Requisito especial (ej. tener todas aprobadas).',
                const Color(0xFFE0E7FF),
                const Color(0xFF1D4ED8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _autorTop(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autor',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '© 2025 Alan Gabriel Maillet — Autor original\nTodos los derechos reservados.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Material educativo didáctico, creado con la única intención de facilitarle la vida a los estudiantes.',
            style: tt.bodySmall?.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

class _HeroHeaderWrapper extends StatelessWidget {
  const _HeroHeaderWrapper();

  @override
  Widget build(BuildContext context) =>
      const CascadaScreen()._heroHeader(context);
}

class _RegimenCardWrapper extends ConsumerWidget {
  const _RegimenCardWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const CascadaScreen()._regimenCard(context, ref);
}

class _OneLineControlsBar extends ConsumerStatefulWidget {
  const _OneLineControlsBar({super.key, required this.inputDecorationBuilder});

  final InputDecoration Function(BuildContext, {String? hint})
  inputDecorationBuilder;

  @override
  ConsumerState<_OneLineControlsBar> createState() =>
      _OneLineControlsBarState();
}

class _OneLineControlsBarState extends ConsumerState<_OneLineControlsBar> {
  static const double _h = 44;
  static const double _wTipo = 220;
  static const double _wCarrera = 320;

  _CareerType? _selectedType;

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

    final availableTypes = _availableCareerTypes(careers);
    final filteredCareers = _selectedType == null
        ? const <CareerInfo>[]
        : _careersOfType(careers, _selectedType!);

    final searchCtrl = TextEditingController(text: searchVal)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: searchVal.length),
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

    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withOpacity(0.8),
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
                DropdownButtonFormField<_CareerType?>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surface : Colors.white,
                  decoration: widget.inputDecorationBuilder(
                    context,
                    hint: 'Seleccioná el tipo',
                  ),
                  borderRadius: BorderRadius.circular(12),
                  items: availableTypes
                      .map(
                        (t) => DropdownMenuItem<_CareerType?>(
                      value: t,
                      child: Text(_careerTypeLabel(t)),
                    ),
                  )
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
                  value: filteredCareers
                      .any((c) => c.id == currentC.id)
                      ? currentC.id
                      : null,
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
                        (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(
                        c.nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: _selectedType == null
                      ? null
                      : (v) {
                    if (v == null || v == currentC.id) return;
                    ref
                        .read(
                        selectedCareerIdProvider.notifier)
                        .state = v;
                    ref
                        .read(searchTermProvider.notifier)
                        .state = '';
                    ref
                        .read(filtroTipoProvider.notifier)
                        .state = 'todos';
                    ref
                        .read(filtroAnioProvider.notifier)
                        .state = null;
                    ref
                        .read(selectedMateriaIdProvider
                        .notifier)
                        .state = null;
                    ref
                        .read(zoomProvider.notifier)
                        .state = 1.0;
                    final tc = ref.read(
                        transformationControllerProvider);
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
                onChanged: (v) =>
                ref.read(searchTermProvider.notifier).state = v,
                decoration: widget.inputDecorationBuilder(
                  context,
                  hint: 'Buscar materia...',
                ).copyWith(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchVal.isNotEmpty
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
                  value: tipo == 'todos' ? null : tipo,
                  hint: const Text('Tipos'),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor:
                  isDark ? theme.colorScheme.surface : Colors.white,
                  decoration: ddDecoration(),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: tipos
                      .map(
                        (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(t == 'todos' ? 'Todos' : t),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => ref
                      .read(filtroTipoProvider.notifier)
                      .state = v ?? 'todos',
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 130,
                height: 44,
                child: DropdownButtonFormField<int?>(
                  value: anio,
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
                          (y) => DropdownMenuItem<int?>(
                        value: y,
                        child: Text('$y° Año'),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(filtroAnioProvider.notifier).state =
                    (v == -1) ? null : v;
                  },
                ),
              ),
              const SizedBox(width: 12),
              squareIconButton(
                icon: Icons.download_rounded,
                onTap: () async {
                  final uri = Uri.parse(downloadUrl);
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No se pudo abrir: $uri'),
                        ),
                      );
                    }
                  }
                },
                tooltip: 'Descargar',
              ),
              const SizedBox(width: 8),
              squareIconButton(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                onTap: () {
                  final cur = ref.read(themeModeProvider);
                  ref.read(themeModeProvider.notifier).state =
                  cur == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareerSelectorCardStandalone extends ConsumerStatefulWidget {
  const _CareerSelectorCardStandalone({super.key});

  @override
  ConsumerState<_CareerSelectorCardStandalone> createState() =>
      _CareerSelectorCardStandaloneState();
}

class _CareerSelectorCardStandaloneState
    extends ConsumerState<_CareerSelectorCardStandalone> {
  _CareerType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careers = ref.watch(careersProvider);
    final currentC = ref.watch(selectedCareerInfoProvider);

    final availableTypes = _availableCareerTypes(careers);
    final filteredCareers = _selectedType == null
        ? const <CareerInfo>[]
        : _careersOfType(careers, _selectedType!);

    InputDecoration inputDecoration({String? hint}) =>
        CascadaScreen._inputDecoration(context, hint: hint);

    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: cs.onSurface.withOpacity(0.8),
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
          DropdownButtonFormField<_CareerType?>(
            value: _selectedType,
            isExpanded: true,
            dropdownColor: isDark ? cs.surface : Colors.white,
            decoration: inputDecoration(hint: 'Tipo de carrera'),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 420,
            itemHeight: 48,
            items: availableTypes
                .map(
                  (t) => DropdownMenuItem<_CareerType?>(
                value: t,
                child: Text(_careerTypeLabel(t)),
              ),
            )
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
            value:
            filteredCareers.any((c) => c.id == currentC.id)
                ? currentC.id
                : null,
            isExpanded: true,
            dropdownColor: isDark ? cs.surface : Colors.white,
            decoration: inputDecoration(
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
                  (c) => DropdownMenuItem<String?>(
                value: c.id,
                child: Text(
                  c.nombre,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            onChanged: _selectedType == null
                ? null
                : (v) {
              if (v == null || v == currentC.id) return;
              ref
                  .read(selectedCareerIdProvider.notifier)
                  .state = v;
              ref
                  .read(searchTermProvider.notifier)
                  .state = '';
              ref
                  .read(filtroTipoProvider.notifier)
                  .state = 'todos';
              ref
                  .read(filtroAnioProvider.notifier)
                  .state = null;
              ref
                  .read(selectedMateriaIdProvider.notifier)
                  .state = null;
              ref.read(zoomProvider.notifier).state = 1.0;
              final tc =
              ref.read(transformationControllerProvider);
              tc.value = Matrix4.identity();
            },
          ),
        ],
      ),
    );
  }
}

class _DesktopYearBoard extends StatelessWidget {
  const _DesktopYearBoard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget col(String title, int year) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? cs.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? cs.outlineVariant
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: theme.shadowColor.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                child: YearLane(year: year),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        col('1º Año', 1),
        col('2º Año', 2),
        col('3º Año', 3),
        col('4º Año', 4),
      ],
    );
  }
}

class YearLane extends ConsumerWidget {
  const YearLane({super.key, required this.year});
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [filtroAnioProvider.overrideWith((ref) => year)],
      child: const VisualizationGrid(
        showYearHeaders: false,
        borderless: true,
      ),
    );
  }
}

class _CollapsingBannerDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingBannerDelegate({required this.topInset});
  final double topInset;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;
  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final range = maxExtent - minExtent;
    final t = (maxExtent - shrinkOffset - minExtent) / range;
    final vis = t.clamp(0.0, 1.0);
    final smallT = 1.0 - vis;
    final smallOpacity = Curves.easeIn.transform(smallT);

    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: Column(
        children: [
          SizedBox(
            height: _h1 * vis,
            child: Opacity(
              opacity: Curves.easeOut.transform(vis),
              child: Transform.translate(
                offset: Offset(0, (1 - vis) * -8),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: topInset).add(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  color: c1,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mapa de Correlatividades',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: c2,
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Opacity(
              opacity: smallOpacity,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mapa de Correlatividades',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingBannerDelegate oldDelegate) {
    return oldDelegate.topInset != topInset;
  }
}

*/

