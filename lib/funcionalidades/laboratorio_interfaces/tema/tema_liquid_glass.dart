import 'package:flutter/material.dart';

class PaletaLiquidGlass {
  const PaletaLiquidGlass._();

  static const Color azul = Color(0xFF5BB8FF);
  static const Color azulProfundo = Color(0xFF267BFF);
  static const Color violeta = Color(0xFF7968FF);
  static const Color turquesa = Color(0xFF45D5D0);
  static const Color verde = Color(0xFF57D69A);
  static const Color amarillo = Color(0xFFFFC861);
  static const Color rojo = Color(0xFFFF6B7B);

  static const Color fondoClaro = Color(0xFFF4F7FF);
  static const Color fondoOscuro = Color(0xFF060A14);
  static const Color textoClaro = Color(0xFFF5F8FF);
  static const Color textoOscuro = Color(0xFF101828);
}

ThemeData temaLaboratorioLiquidGlass(BuildContext context) {
  final base = Theme.of(context);
  final dark = base.brightness == Brightness.dark;
  final colors = base.colorScheme.copyWith(
    primary: dark ? PaletaLiquidGlass.azul : PaletaLiquidGlass.azulProfundo,
    secondary: PaletaLiquidGlass.violeta,
    tertiary: PaletaLiquidGlass.turquesa,
    surface: dark ? const Color(0xFF101728) : const Color(0xFFF8FAFF),
    onSurface: dark
        ? PaletaLiquidGlass.textoClaro
        : PaletaLiquidGlass.textoOscuro,
    onSurfaceVariant: dark ? const Color(0xFFB8C3D9) : const Color(0xFF5F6B80),
    outline: dark ? const Color(0xFF4B607D) : const Color(0xFF9BAAC0),
    outlineVariant: dark ? const Color(0xFF25344C) : const Color(0xFFD8E0EC),
  );

  final textTheme = base.textTheme.apply(
    bodyColor: colors.onSurface,
    displayColor: colors.onSurface,
  );

  return base.copyWith(
    colorScheme: colors,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant.withValues(alpha: 0.55),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xED18243A) : const Color(0xF5F8FAFF),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalBackgroundColor: Colors.transparent,
      modalElevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xF2141C2C) : const Color(0xF8F8FAFF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark
          ? Colors.white.withValues(alpha: 0.075)
          : Colors.white.withValues(alpha: 0.62),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.70),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colors.primary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.75)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: dark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.52),
      selectedColor: colors.primary.withValues(alpha: 0.18),
      side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.60)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: textTheme.labelLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
