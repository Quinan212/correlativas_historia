import 'package:flutter/material.dart';

class TarjetaMetricaVidrio extends StatelessWidget {
  const TarjetaMetricaVidrio({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: highlight
            ? (isDark
                ? cs.primary.withOpacity(0.15)
                : cs.primary.withOpacity(0.05))
            : (isDark ? cs.surface : Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? cs.primary.withOpacity(0.3)
              : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 6),
            color: theme.shadowColor.withOpacity(isDark ? 0.15 : 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TarjetaMetrica extends StatelessWidget {
  const TarjetaMetrica({
    super.key,
    this.icon,
    this.customIcon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.maxLines = 1,
    this.padding = const EdgeInsets.all(12),
  }) : assert(icon != null || customIcon != null,
            'Either icon or customIcon must be provided');

  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final String value;
  final bool highlight;
  final int maxLines;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TarjetaMetricaVidrio(
      highlight: highlight,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customIcon ?? Icon(icon, color: cs.primary, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
