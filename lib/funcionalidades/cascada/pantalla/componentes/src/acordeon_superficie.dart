part of '../acordeon_funciones_premium.dart';

class _AccordionSurface extends StatelessWidget {
  const _AccordionSurface({
    required this.data,
    required this.progress,
    required this.contentRevealProgress,
    required this.isClosing,
    required this.onTap,
  });

  final PremiumAccordionItemData data;
  final double progress;
  final double contentRevealProgress;
  final bool isClosing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final t = progress.clamp(0.0, 1.0);
    final settledReveal = contentRevealProgress.clamp(0.0, 1.0);
    final isCollapsed = t <= 0.001;
    final expandedReveal = isClosing
        ? t
        : t >= 0.999
            ? settledReveal
            : 0.0;
    final collapsedReveal = isCollapsed ? settledReveal : 0.0;
    final collapsedHeaderDuringClose = isClosing ? (1 - t) : collapsedReveal;
    final structuralLayoutFactor = t;
    final structuralWidthFactor = ui.lerpDouble(0.9, 1, t) ?? 1.0;

    final closedTitleStyle =
        (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurface.withValues(alpha: 0.92),
      height: 1.1,
      letterSpacing: -0.15,
    );
    final openTitleStyle =
        (theme.textTheme.headlineSmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -0.4,
      color: cs.onSurface,
    );

    final closedGradient = isDark
        ? const [
            Color(0xFF111419),
            Color(0xFF0E1116),
          ]
        : const [
            Color(0xFFF5F6F7),
            Color(0xFFF0F2F4),
          ];
    final openGradient = isDark
        ? const [
            Color(0xFF171B21),
            Color(0xFF10141A),
          ]
        : const [
            Color(0xFFF8F8F9),
            Color(0xFFFFFFFF),
          ];

    final radius = BorderRadius.circular(16);
    final padding = EdgeInsets.lerp(
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      const EdgeInsets.fromLTRB(18, 16, 18, 18),
      t,
    )!;
    final collapsedHeader = _CollapsedHeaderRow(
      title: data.title,
      titleStyle: closedTitleStyle,
      action: const _CircleAction(icon: Icons.add_rounded),
      glyph: _FeatureGlyph(
        icon: data.icon,
        progress: 0,
      ),
    );
    const textRevealAlignment = Alignment.topLeft;

    Widget popReveal(
      Widget child, {
      Alignment alignment = Alignment.center,
      double? visibility,
    }) {
      final progress = (visibility ?? settledReveal).clamp(0.0, 1.0);
      return Opacity(
        opacity: progress,
        child: Transform.scale(
          alignment: alignment,
          scale: ui.lerpDouble(0.9, 1, progress) ?? 1,
          child: child,
        ),
      );
    }

    Widget collapseWithPanel(
      Widget child, {
      Alignment alignment = Alignment.topLeft,
    }) {
      return ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: structuralLayoutFactor,
          child: Transform.scale(
            alignment: alignment,
            scaleX: structuralWidthFactor,
            scaleY: 1,
            child: child,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(closedGradient[0], openGradient[0], t)!,
            Color.lerp(closedGradient[1], openGradient[1], t)!,
          ],
        ),
        border: Border.all(
          color: Color.lerp(
            isDark ? const Color(0xFF262B33) : const Color(0xFFD8DDE3),
            isDark ? const Color(0xFF3A414C) : const Color(0xFFC9D0D8),
            t,
          )!,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: isCollapsed
                          ? popReveal(
                              collapsedHeader,
                              alignment: Alignment.centerLeft,
                              visibility: collapsedReveal,
                            )
                          : Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                if (isClosing)
                                  collapseWithPanel(
                                    popReveal(
                                      collapsedHeader,
                                      alignment: Alignment.centerLeft,
                                      visibility: collapsedHeaderDuringClose,
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _MorphAction(
                                      progress: isClosing ? 1 : t,
                                    ),
                                    SizedBox(
                                      width: ui.lerpDouble(10, 6, t) ?? 6,
                                    ),
                                    Flexible(
                                      child: collapseWithPanel(
                                        popReveal(
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Text(
                                                  data.kicker,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    height: 1.35,
                                                    color: cs.onSurfaceVariant
                                                        .withValues(
                                                      alpha: 0.9,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                data.title,
                                                style: TextStyle.lerp(
                                                  closedTitleStyle,
                                                  openTitleStyle,
                                                  t,
                                                ),
                                              ),
                                            ],
                                          ),
                                          alignment: textRevealAlignment,
                                          visibility: expandedReveal,
                                        ),
                                        alignment: textRevealAlignment,
                                      ),
                                    ),
                                    SizedBox(
                                      width: ui.lerpDouble(8, 12, t) ?? 8,
                                    ),
                                    popReveal(
                                      _FeatureGlyph(
                                        icon: data.icon,
                                        progress: t,
                                      ),
                                      visibility: expandedReveal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                if (t > 0.001) ...[
                  SizedBox(height: 12 * t),
                  collapseWithPanel(
                    popReveal(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.summary,
                            style: theme.textTheme.titleSmall?.copyWith(
                              height: 1.32,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.detail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.58,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                          const SizedBox(height: 12),
                          for (var i = 0; i < data.bullets.length; i++) ...[
                            _AccordionBullet(text: data.bullets[i]),
                            if (i != data.bullets.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
                      alignment: textRevealAlignment,
                      visibility: expandedReveal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedHeaderRow extends StatelessWidget {
  const _CollapsedHeaderRow({
    required this.title,
    required this.titleStyle,
    required this.action,
    required this.glyph,
  });

  final String title;
  final TextStyle titleStyle;
  final Widget action;
  final Widget glyph;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        action,
        const SizedBox(width: 10),
        Text(
          title,
          style: titleStyle,
        ),
        const SizedBox(width: 10),
        glyph,
      ],
    );
  }
}

class _AccordionBullet extends StatelessWidget {
  const _AccordionBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.48,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
