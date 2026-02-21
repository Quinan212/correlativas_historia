export 'pantalla/pantalla_calculadora.dart';

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state.dart';
import '../../models/materia.dart';
import 'evaluation_panel.dart';

class CalculadoraScreen extends ConsumerWidget {
  const CalculadoraScreen({super.key});

  static const kPageBgLight = Color(0xFFF5F7FA);

  // ===== Paletas (match leyenda/grilla) =====
  // Formación (light)
  static const _fgLBg = Color(0xFFE0E7FF);
  static const _fgLBd = Color(0xFFC7D2FE);
  static const _fgLFg = Color(0xFF1E40AF);

  static const _feLBg = Color(0xFFD1FAE5);
  static const _feLBd = Color(0xFFA7F3D0);
  static const _feLFg = Color(0xFF065F46);

  static const _ppLBg = Color(0xFFEDE9FE);
  static const _ppLBd = Color(0xFFDDD6FE);
  static const _ppLFg = Color(0xFF6D28D9);

  // Formato (light)
  static const _asigLBg = Color(0xFFE0E7FF);
  static const _asigLBd = Color(0xFFC7D2FE);
  static const _asigLFg = Color(0xFF1D4ED8);

  static const _semLBg = Color(0xFFD1FAE5);
  static const _semLBd = Color(0xFFA7F3D0);
  static const _semLFg = Color(0xFF065F46);

  static const _stLBg = Color(0xFFEDE9FE);
  static const _stLBd = Color(0xFFDDD6FE);
  static const _stLFg = Color(0xFF6D28D9);

  static const _tallerLBg = Color(0xFFFDEAD7);
  static const _tallerLBd = Color(0xFFFED7AA);
  static const _tallerLFg = Color(0xFF9A3412);

  // Dark (igual a DetailPanel)
  static const _fgDBg = Color(0xFF223761);
  static const _fgDBd = Color(0xFF3E60A4);
  static const _fgDFg = Color(0xFFBFD4FF);

  static const _feDBg = Color(0xFF1E4F45);
  static const _feDBd = Color(0xFF2D8C78);
  static const _feDFg = Color(0xFFBFEFE0);

  static const _ppDBg = Color(0xFF3A2769);
  static const _ppDBd = Color(0xFF7351D4);
  static const _ppDFg = Color(0xFFE7D7FF);

  static const _tallerDBg = Color(0xFF5A3027);
  static const _tallerDBd = Color(0xFFB75B33);
  static const _tallerDFg = Color(0xFFF4CBB5);

  Color _cardBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cs.surface : Colors.white;
  }

  Color _borderColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cs.outlineVariant : const Color(0xFFD1D5DB);
  }

  Color _textPrimary(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cs.onSurface : const Color(0xFF111827);
  }

  Color _textMuted(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final year = ref.watch(evalYearProvider);
    final selectedId = ref.watch(selectedCalcMateriaIdProvider);
    final topInset = MediaQuery.of(context).viewPadding.top;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _CollapsingBannerDelegate(
              topInset: topInset,
              subtitle: '¿Puedo Cursar?',
            ),
          ),
          SliverToBoxAdapter(
            child: planAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error cargando plan: $e')),
              ),
              data: (plan) {
                final materiasYear =
                plan.materias.where((m) => m.anio == year).toList()
                  ..sort((a, b) => a.nombre.compareTo(b.nombre));

                final Materia? course = selectedId == null
                    ? null
                    : _firstWhereOrNull(
                  plan.materias,
                      (m) => m.id == selectedId,
                );

                if (selectedId != null && course == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedCalcMateriaIdProvider.notifier).state =
                    null;
                    ref.read(correlativaStatusMapProvider.notifier).clear();
                  });
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _hero(context, ref),
                      const SizedBox(height: 12),
                      _stepCard(
                        context,
                        number: 1,
                        title: 'Seleccioná la Carrera',
                        subtitle:
                        'Elegí primero la carrera (p. ej., Profesorado en Geografía o Profesorado de Historia).',
                      ),
                      const SizedBox(height: 12),
                      _stepCard(
                        context,
                        number: 2,
                        title: 'Seleccioná el Año',
                        subtitle:
                        'Elegí el año de la materia que querés saber si podés cursar.',
                      ),
                      const SizedBox(height: 12),
                      _stepCard(
                        context,
                        number: 3,
                        title: 'Seleccioná la Materia',
                        subtitle:
                        'Ahora, elegí la materia específica que te interesa.',
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Carrera:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Builder(builder: (_) {
                        final careers = ref.watch(careersProvider);
                        final currentC = ref.watch(selectedCareerInfoProvider);

                        return DropdownButtonFormField<String>(
                          key: ValueKey('career_${currentC.id}'),
                          initialValue: currentC.id,
                          isExpanded: true,
                          decoration: _inputDecoration(context),
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
                              child: Text(
                                c.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                              .toList(),
                          onChanged: (v) {
                            if (v == null || v == currentC.id) return;
                            ref.read(selectedCareerIdProvider.notifier).state =
                                v;
                            ref.read(evalYearProvider.notifier).state = 2;
                            ref
                                .read(selectedCalcMateriaIdProvider.notifier)
                                .state = null;
                            ref
                                .read(correlativaStatusMapProvider.notifier)
                                .clear();
                          },
                        );
                      }),

                      const SizedBox(height: 16),
                      Text(
                        'Año:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        key: ValueKey('year_$year'),
                        initialValue: year,
                        isExpanded: true,
                        decoration: _inputDecoration(context),
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
                            .map(
                              (y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y° Año'),
                          ),
                        )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          ref.read(evalYearProvider.notifier).state = v;
                          ref
                              .read(selectedCalcMateriaIdProvider.notifier)
                              .state = null;
                          ref
                              .read(correlativaStatusMapProvider.notifier)
                              .clear();
                        },
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Materia:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String?>(
                        key: ValueKey('materia_${selectedId ?? 'null'}'),
                        initialValue: selectedId,
                        isExpanded: true,
                        decoration: _inputDecoration(
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
                          ref
                              .read(selectedCalcMateriaIdProvider.notifier)
                              .state = v;
                          ref
                              .read(correlativaStatusMapProvider.notifier)
                              .clear();
                        },
                      ),

                      const SizedBox(height: 16),
                      if (course == null)
                        _placeholderCard(
                          context,
                          'Selecciona una carrera, un año y una materia para ver tus opciones de cursada.',
                        )
                      else ...[
                        _materiaSummaryCard(context, course),
                        const SizedBox(height: 12),
                        const EvaluationPanel(),
                      ],

                      const SizedBox(height: 24),
                      _autorPC(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, WidgetRef ref) => Container(
    decoration: BoxDecoration(
      color: _cardBg(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor(context), width: 1),
      boxShadow: const [
        BoxShadow(blurRadius: 10, color: Color(0x14000000)),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Puedo Cursar?',
          style: TextStyle(
            fontSize: 30,
            height: 1.10,
            fontWeight: FontWeight.w700,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ya sabés qué te falta... ahora, ¿Podés Cursar?\n'
              'Con Puedo Cursar descubrís en segundos si podés avanzar en tu carrera. '
              'Un par de clics y sabrás exactamente qué camino seguir para llegar a tu meta académica.',
          style: TextStyle(
            fontSize: 14.5,
            height: 1.45,
            fontWeight: FontWeight.w400,
            color: _textMuted(context),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: () =>
            ref.read(routerIndexProvider.notifier).state = 0,
            style: OutlinedButton.styleFrom(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: _borderColor(context)),
              foregroundColor: _textPrimary(context),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: const Text('Volver al Mapa'),
          ),
        ),
      ],
    ),
  );

  Widget _stepCard(
      BuildContext context, {
        required int number,
        required String title,
        required String subtitle,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context), width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x14000000)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
              isDark ? _darken(const Color(0xFFE5EDFF), 0.82) : const Color(0xFFE5EDFF),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFBFDBFE),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? cs.onSurface : const Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _darken(Color c, [double t = 0.2]) =>
      Color.lerp(c, Colors.black, t)!;

  static InputDecoration _inputDecoration(
      BuildContext context, {
        String? hint,
      }) {
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
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) => Container(
    decoration: BoxDecoration(
      color: _cardBg(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor(context), width: 1),
      boxShadow: const [
        BoxShadow(blurRadius: 10, color: Color(0x14000000)),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: child,
  );

  Widget _placeholderCard(BuildContext context, String text) => _card(
    context,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : const Color(0xFF9CA3AF),
      ),
    ),
  );

  Widget _autorPC(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _cardBg(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _borderColor(context), width: 1),
      boxShadow: const [
        BoxShadow(blurRadius: 10, color: Color(0x14000000)),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Autor',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '© 2025 Alan Gabriel Maillet — Autor original\nTodos los derechos reservados.',
          style: TextStyle(
            fontSize: 12,
            color: _textMuted(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Material educativo didáctico, creado con la única intención de facilitarle la vida a los estudiantes.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : const Color(0xFF4B5563),
          ),
        ),
      ],
    ),
  );

  Widget _materiaSummaryCard(BuildContext context, Materia m) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context), width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x14000000)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.nombre,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary(context),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tipoChip(context, m.tipo),
              _formatoChip(context, m.formato),
              _yearChip(context, m.anio),
              // if (m.horas != null && m.horas!.isNotEmpty) _hoursChip(context, m.horas!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipBase({
    required String text,
    required Color bg,
    required Color bd,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bd),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _tipoChip(BuildContext context, String tipo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    Color bg, bd, fg;

    switch (tipo.trim()) {
      case 'Formación General':
        bg = isDark ? _fgDBg : _fgLBg;
        bd = isDark ? _fgDBd : _fgLBd;
        fg = isDark ? _fgDFg : _fgLFg;
        break;
      case 'Formación Específica':
        bg = isDark ? _feDBg : _feLBg;
        bd = isDark ? _feDBd : _feLBd;
        fg = isDark ? _feDFg : _feLFg;
        break;
      case 'Práctica Profesional':
        bg = isDark ? _ppDBg : _ppLBg;
        bd = isDark ? _ppDBd : _ppLBd;
        fg = isDark ? _ppDFg : _ppLFg;
        break;
      default:
        bg = isDark ? cs.surface : const Color(0xFFF3F4F6);
        bd = isDark ? cs.outlineVariant : const Color(0xFFE5E7EB);
        fg = cs.onSurface;
    }

    return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg);
  }

  Widget _formatoChip(BuildContext context, String formato) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    Color bg, bd, fg;

    switch (formato.trim()) {
      case 'Asignatura':
        bg = isDark ? _fgDBg : _asigLBg;
        bd = isDark ? _fgDBd : _asigLBd;
        fg = isDark ? _fgDFg : _asigLFg;
        break;
      case 'Seminario':
        bg = isDark ? _feDBg : _semLBg;
        bd = isDark ? _feDBd : _semLBd;
        fg = isDark ? _feDFg : _semLFg;
        break;
      case 'Seminario-Taller':
        bg = isDark ? _ppDBg : _stLBg;
        bd = isDark ? _ppDBd : _stLBd;
        fg = isDark ? _ppDFg : _stLFg;
        break;
      case 'Taller':
        bg = isDark ? _tallerDBg : _tallerLBg;
        bd = isDark ? _tallerDBd : _tallerLBd;
        fg = isDark ? _tallerDFg : _tallerLFg;
        break;
      default:
        bg = isDark ? cs.surface : const Color(0xFFF3F4F6);
        bd = isDark ? cs.outlineVariant : const Color(0xFFE5E7EB);
        fg = cs.onSurface;
    }

    return _chipBase(text: formato, bg: bg, bd: bd, fg: fg);
  }

  Widget _yearChip(BuildContext context, int anio) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _chipBase(
      text: '$anio° Año',
      bg: isDark ? _darken(cs.surface, 0.20) : const Color(0xFFF3F4F6),
      bd: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
      fg: cs.onSurface,
    );
  }

  Widget _hoursChip(BuildContext context, String horas) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _chipBase(
      text: horas,
      bg: isDark ? _darken(cs.surface, 0.20) : const Color(0xFFF3F4F6),
      bd: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
      fg: cs.onSurface,
    );
  }
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final x in items) {
    if (test(x)) return x;
  }
  return null;
}

class _CollapsingBannerDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingBannerDelegate({required this.topInset, required this.subtitle});

  final double topInset;
  final String subtitle;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;

  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                      '¿Puedo Cursar?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Opacity(
              opacity: smallOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
  bool shouldRebuild(covariant _CollapsingBannerDelegate old) =>
      old.topInset != topInset || old.subtitle != subtitle;
}
*/
