import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../compartido/proveedores/estado_app.dart';
import '../../compartido/navegacion/ruta_suave.dart';
import 'proveedores/proveedores_examenes.dart';
import 'proveedores/proveedores_plan_examenes.dart';
import 'pantalla/pantalla_examenes.dart';

class ExamenesPantalla extends StatelessWidget {
  const ExamenesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final styleMode = ref.watch(proveedorModoEstiloExamenes);
        final child = const PantallaExamenes();
        if (styleMode == ModoEstiloExamenes.clasico) {
          return child;
        }
        return Theme(
          data: _buildZeusExamenesTheme(Theme.of(context)),
          child: child,
        );
      },
    );
  }
}

ThemeData _buildZeusExamenesTheme(ThemeData base) {
  final isDark = base.brightness == Brightness.dark;
  final pageBg = isDark ? const Color(0xFF08111B) : const Color(0xFFF2F6FA);
  final surface = isDark ? const Color(0xFF101A2B) : const Color(0xFFFFFFFF);
  final surface2 = isDark ? const Color(0xFF0D1726) : const Color(0xFFF8FAFC);
  final outline = isDark ? const Color(0xFF263448) : const Color(0xFFD2DCE8);
  final onSurface = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
  final onSurfaceVariant =
      isDark ? const Color(0xFF9FB0C6) : const Color(0xFF64748B);

  final cs = base.colorScheme.copyWith(
    surface: surface,
    surfaceContainer: surface2,
    surfaceContainerHighest:
        isDark ? const Color(0xFF132033) : const Color(0xFFF0F4F9),
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outlineVariant: outline,
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFF0EA5E9),
  );

  return base.copyWith(
    colorScheme: cs,
    scaffoldBackgroundColor: pageBg,
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: onSurface),
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: isDark ? 1.5 : 1.0,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.primary),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surface2,
      selectedColor:
          isDark ? cs.primaryContainer.withValues(alpha: 0.95) : cs.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    ),
  );
}

String resolveExamenesCareerId(String careerId) {
  switch (careerId) {
    case 'historia':
    case 'geografia':
    case 'politica':
      return careerId;
    default:
      return 'historia';
  }
}

void prewarmExamenesData(WidgetRef ref, {String? careerId}) {
  final resolvedCareerId = resolveExamenesCareerId(
    careerId ?? ref.read(proveedorCarreraSeleccionada).id,
  );

  ref.read(proveedorIdCarreraExamenes.notifier).state = resolvedCareerId;
  unawaited(ref.read(proveedorTodosLosExamenes.future));
  unawaited(ref.read(proveedorPlanMapaMaterias(resolvedCareerId).future));
}

Route<void> buildExamenesRoute() {
  return rutaSuave<void>(const ExamenesPantalla());
}
