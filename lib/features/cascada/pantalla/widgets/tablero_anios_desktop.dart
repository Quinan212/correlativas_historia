import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../../visualization_grid.dart';

class TableroAniosDesktop extends StatelessWidget {
  const TableroAniosDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget col(String title, int year) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? cs.outlineVariant
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: theme.shadowColor.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                child: YearLane(year: year),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        col('1º Año', 1),
        col('2º Año', 2),
        col('3º Año', 3),
        col('4º Año', 4),
      ],
    );
  }
}

class YearLane extends ConsumerWidget {
  const YearLane({super.key, required this.year});
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [filtroAnioProvider.overrideWith((ref) => year)],
      child: const VisualizationGrid(
        showYearHeaders: false,
        borderless: true,
      ),
    );
  }
}
