import 'package:flutter/material.dart';

class EstilosPanel {
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static Color darken(Color c, [double t = 0.2]) =>
      Color.lerp(c, Colors.black, t)!;

  static TextStyle gf({
    required double size,
    required FontWeight weight,
    required Color color,
    double height = 1.2,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static Color border(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? cs.outlineVariant : const Color(0xFFE5E7EB);
  }

  static Color titleColor(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? cs.onSurface : const Color(0xFF111827);
  }

  static Color subtitleColor(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? cs.onSurfaceVariant : const Color(0xFF6B7280);
  }

  static Color chipBg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? darken(cs.surface, 0.30) : const Color(0xFFF3F4F6);
  }

  static Color chipSelectedBg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? darken(cs.primary, 0.72) : const Color(0xFFDBEAFE);
  }

  static Color chipFg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? cs.onSurface : const Color(0xFF374151);
  }

  static Color chipSelectedFg(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return isDark(c) ? cs.onSurface : const Color(0xFF1D4ED8);
  }

  static BorderSide chipSide(BuildContext c, {required bool selected}) {
    if (selected) return const BorderSide(color: Color(0xFF93C5FD));
    return BorderSide(color: border(c));
  }

  static TextStyle chipTextStyle(BuildContext c, {required bool selected}) {
    return gf(
      size: 13,
      weight: FontWeight.w600,
      color: selected ? chipSelectedFg(c) : chipFg(c),
      height: 1.0,
    );
  }

  static String labelFor(String opt) {
    if (opt == 'no-regularizada') return 'no\u00A0regularizada';
    return opt;
  }

  static Widget sectionHeader(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    final dot = isDark(context) ? cs.primary : const Color(0xFF005B7F);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: gf(
            size: 14.5,
            weight: FontWeight.w600,
            color: titleColor(context),
            height: 1.0,
          ),
        ),
      ],
    );
  }

  static Widget panelCard(BuildContext context, Widget child) {
    final cs = Theme.of(context).colorScheme;
    final dark = isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: dark ? darken(cs.surface) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border(context)),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color(0x14000000)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
