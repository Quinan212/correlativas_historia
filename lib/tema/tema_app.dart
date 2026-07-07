import 'package:flutter/material.dart';

import '../compartido/navegacion/transiciones_paginas_app.dart';

class TemaApp {
  static const _seed = Color(0xFF005B7F);

  static const _bgLight = Color(0xFFF5F7FA);
  static const _bgDark = Color(0xFF060B14);

  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _surfaceDark = Color(0xFF0B1220);

  static const _textLight = Color(0xFF111827);
  static const _textMutedLight = Color(0xFF6B7280);
  static const _borderLight = Color(0xFFE5E7EB);

  static const _textDark = Color(0xFFE5E7EB);
  static const _textMutedDark = Color(0xFF9CA3AF);
  static const _borderDark = Color(0xFF243041);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    final cs = base.copyWith(
      surface: _surfaceLight,
      onSurface: _textLight,
      onSurfaceVariant: _textMutedLight,
      outlineVariant: _borderLight,
    );

    final t = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgLight,
      fontFamily: 'Inter_24pt-Regular',
      dividerColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: _textMutedLight),
      pageTransitionsTheme: buildAppPageTransitionsTheme(),
      datePickerTheme: _datePickerTheme(cs, _surfaceLight),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      ),
      cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
    );

    return t.copyWith(
      textTheme: t.textTheme.apply(fontFamily: 'inter'),
      primaryTextTheme: t.primaryTextTheme.apply(fontFamily: 'inter'),
    );
  }

  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );

    final cs = base.copyWith(
      surface: _surfaceDark,
      onSurface: _textDark,
      onSurfaceVariant: _textMutedDark,
      outlineVariant: _borderDark,
    );

    final t = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: _bgDark,
      fontFamily: 'Inter_24pt-Regular',
      dividerColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: _textMutedDark),
      pageTransitionsTheme: buildAppPageTransitionsTheme(),
      datePickerTheme: _datePickerTheme(cs, _surfaceDark),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A1728),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      ),
      cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
    );

    return t.copyWith(
      textTheme: t.textTheme.apply(fontFamily: 'inter'),
      primaryTextTheme: t.primaryTextTheme.apply(fontFamily: 'inter'),
    );
  }

  static DatePickerThemeData _datePickerTheme(
    ColorScheme colors,
    Color surface,
  ) {
    return DatePickerThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      headerBackgroundColor: colors.primary,
      headerForegroundColor: colors.onPrimary,
      headerHeadlineStyle: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
      ),
      headerHelpStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      weekdayStyle: TextStyle(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurface.withValues(alpha: 0.32);
        }
        return colors.onSurface;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.selected) ? colors.primary : null;
      }),
      todayForegroundColor: WidgetStatePropertyAll<Color>(colors.primary),
      todayBorder: BorderSide(color: colors.primary, width: 1.5),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.onSurfaceVariant,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
