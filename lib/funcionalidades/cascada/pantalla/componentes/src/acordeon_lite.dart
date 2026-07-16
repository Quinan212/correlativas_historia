part of '../acordeon_funciones_premium.dart';

class _LiteAcordeonFuncionesPremium extends StatefulWidget {
  const _LiteAcordeonFuncionesPremium({
    required this.items,
    required this.initialExpandedIndex,
  });

  final List<PremiumAccordionItemData> items;
  final int? initialExpandedIndex;

  @override
  State<_LiteAcordeonFuncionesPremium> createState() =>
      _LiteAcordeonFuncionesPremiumState();
}

class _LiteAcordeonFuncionesPremiumState
    extends State<_LiteAcordeonFuncionesPremium> {
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.items.length; i++) ...[
          _LitePremiumAccordionItem(
            data: widget.items[i],
            expanded: _expandedIndex == i,
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == i ? null : i;
              });
            },
          ),
          if (i != widget.items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LitePremiumAccordionItem extends StatelessWidget {
  const _LitePremiumAccordionItem({
    required this.data,
    required this.expanded,
    required this.onTap,
  });

  final PremiumAccordionItemData data;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111419) : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF262B33) : const Color(0xFFD8DDE3),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isDark
                              ? cs.surfaceContainerHighest.withValues(alpha: 0.22)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? cs.outlineVariant.withValues(alpha: 0.5)
                                : const Color(0xFFD0D6DE),
                          ),
                        ),
                        child: Icon(data.icon, size: 16, color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          data.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expanded ? Icons.remove_rounded : Icons.add_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 170),
                    crossFadeState: expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.detail,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < data.bullets.length; i++) ...[
                            _AccordionBullet(text: data.bullets[i]),
                            if (i != data.bullets.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
