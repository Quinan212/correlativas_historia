import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import 'estado_requiere_carrera.dart';
import 'premium_feature_accordion.dart';
import 'tarjeta_acordeon_inicio.dart';

class TarjetaRegimenCorrelatividades extends ConsumerWidget {
  const TarjetaRegimenCorrelatividades({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(selectedCareerInfoOrNullProvider);
    final hasSelectedCareer = career != null;
    final data =
        career == null ? null : _buildRegimenData(career.id, career.nombre);
    final activeChild = career == null
        ? const SizedBox.shrink()
        : TarjetaAcordeonInicio(
            leading: compact
                ? null
                : _LeadingBadge(
                    icon: Icons.menu_book_rounded,
                    compact: compact,
                  ),
            eyebrowLeading: compact
                ? _LeadingBadge(
                    icon: Icons.gavel_rounded,
                    compact: compact,
                  )
                : null,
            eyebrow: compact ? 'Norma activa' : 'Regimen vigente',
            title: compact
                ? 'El marco de lectura cambia con la carrera que estes viendo'
                : 'Base normativa de la carrera activa',
            summary: compact
                ? 'Aqui ves la referencia normativa de la carrera seleccionada, junto con el recorte del plan que se esta leyendo en esta vista.'
                : 'Esta referencia acompaña la carrera que estas viendo para interpretar correlativas, avance y alcance del plan sin mezclar marcos de otra carrera o institución.',
            initiallyExpanded: false,
            child: compact
                ? _compactExpandedBody(context, data!)
                : _fullExpandedBody(context, data!),
          );

    return CambioEstadoCarrera(
      activo: hasSelectedCareer,
      placeholder: _emptyBody(context),
      child: activeChild,
    );
  }

  Widget _emptyBody(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 8),
            color: theme.shadowColor.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 8),
                child: child,
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingBadge(
                icon: Icons.menu_book_rounded,
                compact: compact,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referencia pendiente',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      compact
                          ? 'Selecciona una carrera para ver la referencia'
                          : 'Selecciona una carrera para cargar la referencia normativa',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      compact
                          ? 'Cuando elijas una carrera, este bloque mostrará la institución y la norma que corresponden a esa vista.'
                          : 'Este panel se actualiza con la carrera elegida para mostrar la institución, el alcance y la norma de referencia que ordenan esa lectura.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _compactExpandedBody(BuildContext context, _RegimenData data) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedBadgeGroup(
          careerIcon: Icons.school_outlined,
          careerText: data.carreraCorta,
          institutionIcon: Icons.apartment_outlined,
          institutionText: data.institucionCorta,
        ),
        if (data.resolucion != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHighest.withValues(alpha: 0.24)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              data.resolucion!,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Widget _fullExpandedBody(BuildContext context, _RegimenData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedBadgeGroup(
          careerIcon: Icons.school_outlined,
          careerText: data.carreraCorta,
          institutionIcon: Icons.account_balance_outlined,
          institutionText: data.institucionCorta,
        ),
        const SizedBox(height: 16),
        PremiumFeatureAccordion(items: _buildAccordionItems(data)),
      ],
    );
  }

  static List<PremiumAccordionItemData> _buildAccordionItems(
    _RegimenData data,
  ) {
    return [
      PremiumAccordionItemData(
        icon: Icons.badge_outlined,
        title: 'Carrera activa',
        kicker: 'Referencia actual',
        summary:
            'Identifica rápido sobre qué carrera se aplica esta referencia.',
        detail:
            'La lectura del mapa toma esta carrera como referencia para interpretar correlativas, alcances y condiciones visibles en la grilla.',
        bullets: [
          data.carreraLinea,
          'Se actualiza automáticamente cuando cambias de carrera.',
        ],
      ),
      PremiumAccordionItemData(
        icon: Icons.location_city_outlined,
        title: 'Institucion',
        kicker: 'Origen del plan',
        summary:
            'Muestra la institución que sostiene la referencia usada en esta vista.',
        detail:
            'Este dato te ayuda a ubicar el plan correcto cuando comparas carreras o revisas documentos de distintas instituciones.',
        bullets: [
          data.institucionLinea,
          'Se mantiene sincronizado con la carrera seleccionada.',
        ],
      ),
      PremiumAccordionItemData(
        icon: Icons.alt_route_outlined,
        title: 'Alcance',
        kicker: 'Como leer el mapa',
        summary:
            'Aclara desde que marco se interpretan las correlativas y el avance de la carrera.',
        detail:
            'El sistema usa el régimen vigente de esta carrera para ordenar la lectura del mapa y evitar mezclar reglas de otro plan o institución.',
        bullets: [
          'La vista adapta correlativas, avance y alcance al plan activo.',
          'Sirve como contexto antes de revisar materias puntuales.',
        ],
      ),
      PremiumAccordionItemData(
        icon: Icons.description_outlined,
        title: 'Norma de referencia',
        kicker: data.resolucion == null ? 'Dato pendiente' : 'Documento base',
        summary: data.resolucion == null
            ? 'Todavía no hay una norma cargada para mostrar en este panel.'
            : 'Resume la norma usada como apoyo para interpretar esta carrera.',
        detail: data.resolucion == null
            ? 'Cuando se incorpore la referencia documental de esta carrera, va a aparecer acá con el mismo formato que el resto de los planes.'
            : 'Esta referencia documental acompaña la lectura de la carrera activa y te da una base concreta para ubicar el régimen correspondiente.',
        bullets: [
          data.resolucion ?? 'Referencia normativa en actualizacion.',
          data.resolucion == null
              ? 'Mientras tanto, el mapa sigue tomando la carrera activa como contexto.'
              : 'Te sirve para contrastar la lectura visual con su respaldo documental.',
        ],
      ),
      const PremiumAccordionItemData(
        icon: Icons.download_rounded,
        title: 'Documento oficial',
        kicker: 'Acceso rapido',
        summary:
            'Explica dónde encontrar la descarga del respaldo documental vinculado a la carrera.',
        detail:
            'Si necesitas revisar el texto original, puedes usar el boton de descarga del panel de controles sin salir del flujo principal del mapa.',
        bullets: [
          'La descarga se gestiona desde el panel de controles.',
          'Te permite contrastar la lectura visual con el documento fuente.',
        ],
      ),
    ];
  }

  _RegimenData _buildRegimenData(String careerId, String fallbackName) {
    switch (careerId) {
      case 'geografia':
        return const _RegimenData(
          carreraLinea: 'Profesorado de Educacion Secundaria en Geografia',
          carreraCorta: 'Geografia',
          institucionLinea: 'Profesorado Superior de Ciencias Sociales',
          institucionCorta: 'PSCS',
          resolucion:
              'Resolucion N 0766 C.G.E. | Expte. Grabado N (1507261) | Provincia de Entre Rios - Consejo General de Educacion.',
        );
      case 'historia':
        return const _RegimenData(
          carreraLinea: 'Profesorado de Educacion Secundaria en Historia',
          carreraCorta: 'Historia',
          institucionLinea: 'Profesorado Superior de Ciencias Sociales',
          institucionCorta: 'PSCS',
          resolucion:
              'Resolucion N 0765 C.G.E. | Expte. Grabado N (1506606) | Provincia de Entre Rios - Consejo General de Educacion.',
        );
      case 'artes_visuales':
        return const _RegimenData(
          carreraLinea: 'Profesorado de Artes Visuales',
          carreraCorta: 'Artes Visuales',
          institucionLinea:
              'Escuela Secundaria y Superior N 1 "Cesareo Bernaldo de Quiros"',
          institucionCorta: 'Cesareo Bernaldo de Quiros',
          resolucion:
              'Resolucion N 0440/23 C.G.E. | Expte. Grabado N (1943528) | Provincia de Entre Rios - Consejo General de Educacion.',
        );
      case 'musica':
        return const _RegimenData(
          carreraLinea:
              'Profesorado de Musica con Orientacion en Educacion Musical',
          carreraCorta: 'Musica',
          institucionLinea:
              'Escuela Secundaria y Superior N 1 "Cesareo Bernaldo de Quiros"',
          institucionCorta: 'Cesareo Bernaldo de Quiros',
          resolucion:
              'Resolucion N 2867/23 C.G.E. | Expte. Grabado N (2856760) | Provincia de Entre Rios - Consejo General de Educacion.',
        );
      case 'fisica':
        return const _RegimenData(
          carreraLinea: 'Profesorado de Educacion Fisica',
          carreraCorta: 'Educacion Fisica',
          institucionLinea:
              'Instituto Superior de las Especialidades de la Educacion Fisica',
          institucionCorta: 'I.S.E.E.F.',
          resolucion:
              'Resolucion N 0338/23 C.G.E. | Expte. Grabado N (1943502) | Provincia de Entre Rios - Consejo General de Educacion.',
        );
      case 'politica':
        return const _RegimenData(
          carreraLinea:
              'Profesorado de Educacion Secundaria en Ciencia Politica',
          carreraCorta: 'Ciencia Politica',
          institucionLinea: 'Profesorado Superior de Ciencias Sociales',
          institucionCorta: 'PSCS',
          resolucion: null,
        );
      default:
        return _RegimenData(
          carreraLinea: fallbackName,
          carreraCorta: fallbackName,
          institucionLinea: 'Institucion correspondiente',
          institucionCorta: 'Institucion correspondiente',
          resolucion: null,
        );
    }
  }
}

class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({
    required this.icon,
    required this.compact,
  });

  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: compact ? 34 : 38,
      height: compact ? 34 : 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202B) : const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(
          color: isDark ? const Color(0xFF263444) : const Color(0xFFD9E2EE),
        ),
      ),
      child: Icon(
        icon,
        size: compact ? 18 : 20,
        color: cs.primary,
      ),
    );
  }
}

class _InlineBadge extends StatelessWidget {
  const _InlineBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.2)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedInlineBadge extends StatelessWidget {
  const _AnimatedInlineBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey('${icon.codePoint}:$text'),
          child: _InlineBadge(
            icon: icon,
            text: text,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBadgeGroup extends StatelessWidget {
  const _AnimatedBadgeGroup({
    required this.careerIcon,
    required this.careerText,
    required this.institutionIcon,
    required this.institutionText,
  });

  final IconData careerIcon;
  final String careerText;
  final IconData institutionIcon;
  final String institutionText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = _shouldStackBadges(context, constraints);
        return AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: KeyedSubtree(
            key: ValueKey<bool>(shouldStack),
            child: shouldStack
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AnimatedInlineBadge(
                        icon: careerIcon,
                        text: careerText,
                      ),
                      const SizedBox(height: 10),
                      _AnimatedInlineBadge(
                        icon: institutionIcon,
                        text: institutionText,
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedInlineBadge(
                        icon: careerIcon,
                        text: careerText,
                      ),
                      const SizedBox(width: 10),
                      _AnimatedInlineBadge(
                        icon: institutionIcon,
                        text: institutionText,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  bool _shouldStackBadges(BuildContext context, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth) return false;

    final availableWidth = constraints.maxWidth;
    final careerWidth = _estimateBadgeWidth(context, text: careerText);
    final institutionWidth = _estimateBadgeWidth(
      context,
      text: institutionText,
    );

    return careerWidth + 10 + institutionWidth > availableWidth;
  }

  double _estimateBadgeWidth(
    BuildContext context, {
    required String text,
  }) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        );

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();

    const horizontalPadding = 22.0;
    const iconWidth = 15.0;
    const iconGap = 7.0;
    const containerSlack = 4.0;

    return painter.width +
        horizontalPadding +
        iconWidth +
        iconGap +
        containerSlack;
  }
}

class _RegimenData {
  const _RegimenData({
    required this.carreraLinea,
    required this.carreraCorta,
    required this.institucionLinea,
    required this.institucionCorta,
    required this.resolucion,
  });

  final String carreraLinea;
  final String carreraCorta;
  final String institucionLinea;
  final String institucionCorta;
  final String? resolucion;
}
