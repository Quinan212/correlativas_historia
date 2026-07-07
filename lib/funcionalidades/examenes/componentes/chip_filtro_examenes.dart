import 'package:flutter/material.dart';

class ChipFiltroExamenes extends StatelessWidget {
  const ChipFiltroExamenes({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected
            ? (isDark ? cs.onPrimaryContainer : const Color(0xFF1D4ED8))
            : cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      backgroundColor: isDark ? cs.surface : Colors.white,
      selectedColor: isDark ? cs.primaryContainer : const Color(0xFFDBEAFE),
      side: BorderSide(
        color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
