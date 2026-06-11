import 'package:flutter/material.dart';

import '../modelos/calificacion_opiniones.dart';
import '../utilidades/etiquetas_referencias.dart';

enum TonoBalanceReferencias {
  veryCritical,
  critical,
  mixed,
  favorable,
  veryFavorable,
  empty,
}

class CapturaBalanceReferencias {
  const CapturaBalanceReferencias({
    required this.label,
    required this.tone,
    required this.progress,
  });

  final String label;
  final TonoBalanceReferencias tone;
  final double progress;
}

CapturaBalanceReferencias referenciasBalanceFromAverage(
  double average, {
  required int votes,
}) {
  if (votes <= 0 || average <= 0) {
    return const CapturaBalanceReferencias(
      label: 'Sin referencias todavia',
      tone: TonoBalanceReferencias.empty,
      progress: 0,
    );
  }

  final clamped = average.clamp(1.0, 5.0);
  final progress = ((clamped - 1) / 4).clamp(0.0, 1.0);

  if (clamped < 1.5) {
    return CapturaBalanceReferencias(
      label: 'Muy criticas',
      tone: TonoBalanceReferencias.veryCritical,
      progress: progress,
    );
  }
  if (clamped < 2.5) {
    return CapturaBalanceReferencias(
      label: 'Criticas',
      tone: TonoBalanceReferencias.critical,
      progress: progress,
    );
  }
  if (clamped < 3.5) {
    return CapturaBalanceReferencias(
      label: 'Mixtas',
      tone: TonoBalanceReferencias.mixed,
      progress: progress,
    );
  }
  if (clamped < 4.5) {
    return CapturaBalanceReferencias(
      label: 'Favorables',
      tone: TonoBalanceReferencias.favorable,
      progress: progress,
    );
  }
  return CapturaBalanceReferencias(
    label: 'Muy favorables',
    tone: TonoBalanceReferencias.veryFavorable,
    progress: progress,
  );
}

class BarraBalanceReferencias extends StatelessWidget {
  const BarraBalanceReferencias({
    super.key,
    required this.average,
    required this.votes,
    this.height = 12,
    this.showVotes = true,
  });

  final double average;
  final int votes;
  final double height;
  final bool showVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = referenciasBalanceFromAverage(average, votes: votes);
    final hasData = votes > 0 && average > 0;
    const palette = _ReferenciasBalancePalette();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReferenciasBalanceHeader(
          snapshot: snapshot,
          votes: votes,
          showVotes: showVotes,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final markerLeft = hasData
                ? snapshot.progress * (constraints.maxWidth - 16)
                : null;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: hasData
                          ? palette.trackBorder
                          : theme.colorScheme.outlineVariant,
                    ),
                    color: hasData
                        ? null
                        : theme.colorScheme.surfaceContainerHighest,
                    gradient: hasData
                        ? const LinearGradient(
                            colors: [
                              _ReferenciasBalancePalette.clay,
                              _ReferenciasBalancePalette.sand,
                              _ReferenciasBalancePalette.stone,
                              _ReferenciasBalancePalette.mutedTeal,
                              _ReferenciasBalancePalette.deepPetrol,
                            ],
                          )
                        : null,
                  ),
                ),
                if (markerLeft != null)
                  Positioned(
                    left: markerLeft,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: height + 8,
                      decoration: BoxDecoration(
                        color: palette.markerFill,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: palette.markerBorder,
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            offset: Offset(0, 3),
                            color: Color(0x26000000),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Mas bien criticas',
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(
              'Mas bien favorables',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class ReferenciasBalanceInsignia extends StatelessWidget {
  const ReferenciasBalanceInsignia({
    super.key,
    required this.average,
    required this.votes,
  });

  final double average;
  final int votes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = referenciasBalanceFromAverage(average, votes: votes);
    final palette = _ReferenciasBalancePalette.badge(snapshot.tone, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        snapshot.label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ReferenciasReadingInsignia extends StatelessWidget {
  const ReferenciasReadingInsignia({
    super.key,
    required this.rating,
  });

  final RatingResumen rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _ReferenciasReadingPalette.colorsFor(
      rating.readingState,
      theme,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.border,
        ),
      ),
      child: Text(
        etiquetaEstadoLecturaReferencia(rating),
        style: theme.textTheme.labelMedium?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReferenciasBalanceInsigniaColors {
  const _ReferenciasBalanceInsigniaColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

class _ReferenciasReadingInsigniaColors {
  const _ReferenciasReadingInsigniaColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

class _ReferenciasBalancePalette {
  const _ReferenciasBalancePalette();

  static const clay = Color(0xFFC96F5D);
  static const sand = Color(0xFFD9A35F);
  static const stone = Color(0xFFDDD6C8);
  static const mutedTeal = Color(0xFF58AEB1);
  static const deepPetrol = Color(0xFF0A6C8E);

  final Color trackBorder = const Color(0xFFCCD6DD);
  final Color markerFill = const Color(0xFFF8FAFC);
  final Color markerBorder = const Color(0xFF0A6C8E);

  static _ReferenciasBalanceInsigniaColors badge(
    TonoBalanceReferencias tone,
    ThemeData theme,
  ) {
    return switch (tone) {
      TonoBalanceReferencias.veryCritical =>
        const _ReferenciasBalanceInsigniaColors(
          background: Color(0xFFF6E0DB),
          foreground: Color(0xFF8D463A),
        ),
      TonoBalanceReferencias.critical =>
        const _ReferenciasBalanceInsigniaColors(
          background: Color(0xFFF7E8D2),
          foreground: Color(0xFF8A5A16),
        ),
      TonoBalanceReferencias.mixed => const _ReferenciasBalanceInsigniaColors(
          background: Color(0xFFEEE9DF),
          foreground: Color(0xFF66635E),
        ),
      TonoBalanceReferencias.favorable =>
        const _ReferenciasBalanceInsigniaColors(
          background: Color(0xFFDCEFF0),
          foreground: Color(0xFF246C71),
        ),
      TonoBalanceReferencias.veryFavorable =>
        const _ReferenciasBalanceInsigniaColors(
          background: Color(0xFFD7ECF4),
          foreground: Color(0xFF0A5673),
        ),
      TonoBalanceReferencias.empty => _ReferenciasBalanceInsigniaColors(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        ),
    };
  }
}

class _ReferenciasReadingPalette {
  const _ReferenciasReadingPalette();

  static _ReferenciasReadingInsigniaColors colorsFor(
    EstadoLecturaReferencia state,
    ThemeData theme,
  ) {
    return switch (state) {
      EstadoLecturaReferencia.consensus =>
        const _ReferenciasReadingInsigniaColors(
          background: Color(0xFFDCEFF0),
          foreground: Color(0xFF215E62),
          border: Color(0xFF9DCFD2),
        ),
      EstadoLecturaReferencia.divided =>
        const _ReferenciasReadingInsigniaColors(
          background: Color(0xFFF6E4DE),
          foreground: Color(0xFF8D4E41),
          border: Color(0xFFE3B5A8),
        ),
      EstadoLecturaReferencia.mixed => const _ReferenciasReadingInsigniaColors(
          background: Color(0xFFF3ECE2),
          foreground: Color(0xFF6D6458),
          border: Color(0xFFDCCEBB),
        ),
      EstadoLecturaReferencia.insufficientData =>
        _ReferenciasReadingInsigniaColors(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
          border: theme.colorScheme.outlineVariant,
        ),
    };
  }
}

class _ReferenciasBalanceHeader extends StatelessWidget {
  const _ReferenciasBalanceHeader({
    required this.snapshot,
    required this.votes,
    required this.showVotes,
  });

  final CapturaBalanceReferencias snapshot;
  final int votes;
  final bool showVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          snapshot.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (showVotes)
          Text(
            votes <= 0 ? 'Todavia sin referencias' : '$votes referencias',
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );
  }
}
