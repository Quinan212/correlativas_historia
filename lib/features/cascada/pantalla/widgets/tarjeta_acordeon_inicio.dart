import 'package:flutter/material.dart';

class TarjetaAcordeonInicio extends StatefulWidget {
  const TarjetaAcordeonInicio({
    super.key,
    this.leading,
    this.eyebrowLeading,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.child,
    this.initiallyExpanded = false,
  });

  final Widget? leading;
  final Widget? eyebrowLeading;
  final String eyebrow;
  final String title;
  final String summary;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<TarjetaAcordeonInicio> createState() => _TarjetaAcordeonInicioState();
}

class _TarjetaAcordeonInicioState extends State<TarjetaAcordeonInicio> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final baseDuration = reduceMotion
        ? const Duration(milliseconds: 1)
        : const Duration(milliseconds: 260);

    return AnimatedContainer(
      duration: baseDuration,
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
            blurRadius: _expanded ? 10 : 6,
            offset: const Offset(0, 6),
            color: theme.shadowColor.withValues(alpha: _expanded ? 0.10 : 0.07),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.leading != null) ...[
                              widget.leading!,
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.eyebrowLeading != null) ...[
                                        widget.eyebrowLeading!,
                                        const SizedBox(width: 8),
                                      ],
                                      Flexible(
                                        child: Text(
                                          widget.eyebrow,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: cs.primary,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onSurface,
                                      height: 1.08,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              turns: _expanded ? 0.125 : 0,
                              duration: reduceMotion
                                  ? const Duration(milliseconds: 1)
                                  : const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? cs.surfaceContainerHighest.withValues(
                                          alpha: 0.34,
                                        )
                                      : const Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? cs.outlineVariant
                                        : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Icon(
                                  _expanded
                                      ? Icons.close_rounded
                                      : Icons.add_rounded,
                                  size: 18,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedDefaultTextStyle(
                          duration: reduceMotion
                              ? const Duration(milliseconds: 1)
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            height: 1.5,
                            color: _expanded
                                ? cs.onSurfaceVariant
                                : cs.onSurfaceVariant.withValues(alpha: 0.92),
                          ),
                          child: Text(widget.summary),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: reduceMotion
                      ? const Duration(milliseconds: 1)
                      : const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: reduceMotion
                                  ? const Duration(milliseconds: 1)
                                  : const Duration(milliseconds: 240),
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
                              child: widget.child,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
