import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../detail_panel.dart';

Future<void> mostrarModalDetalleMateria({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.40,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.zero,
                children: const [
                  RepaintBoundary(child: DetailPanel()),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  // al cerrar, limpiamos selección (igual que antes)
  ref.read(selectedMateriaIdProvider.notifier).state = null;
}