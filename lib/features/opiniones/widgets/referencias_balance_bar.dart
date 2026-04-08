import 'package:flutter/material.dart';

import '../models/opiniones_rating.dart';
import '../utils/referencias_labels.dart';

enum ReferenciasBalanceTone {
  veryCritical,
  critical,
  mixed,
  favorable,
  veryFavorable,
  empty,
}

class ReferenciasBalanceSnapshot {
  const ReferenciasBalanceSnapshot({
    required this.label,
    required this.tone,
    required this.progress,
  });

  final String label;
  final ReferenciasBalanceTone tone;
  final double progress;
}

ReferenciasBalanceSnapshot referenciasBalanceFromAverage(
  double average, {
  required int votes,
}) {
  if (votes <= 0 || average <= 0) {
    return const ReferenciasBalanceSnapshot(
      label: 'Sin referencias todavia',
      tone: ReferenciasBalanceTone.empty,
      progress: 0,
    );
  }

  final clamped = average.clamp(1.0, 5.0);
  final progress = ((clamped - 1) / 4).clamp(0.0, 1.0);

  if (clamped < 1.5) {
    return ReferenciasBalanceSnapshot(
      label: 'Muy criticas',
      tone: ReferenciasBalanceTone.veryCritical,
      progress: progress,
    );
  }
  if (clamped < 2.5) {
    return ReferenciasBalanceSnapshot(
      label: 'Criticas',
      tone: ReferenciasBalanceTone.critical,
      progress: progress,
    );
  }
  if (clamped < 3.5) {
    return ReferenciasBalanceSnapshot(
      label: 'Mixtas',
      tone: ReferenciasBalanceTone.mixed,
      progress: progress,
    );
  }
  if (clamped < 4.5) {
    return ReferenciasBalanceSnapshot(
      label: 'Favorables',
      tone: ReferenciasBalanceTone.favorable,
      progress: progress,
    );
  }
  return ReferenciasBalanceSnapshot(
    label: 'Muy favorables',
    tone: ReferenciasBalanceTone.veryFavorable,
    progress: progress,
  );
}

class ReferenciasBalanceBar extends StatelessWidget {
  const ReferenciasBalanceBar({
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

class ReferenciasBalanceBadge extends StatelessWidget {
  const ReferenciasBalanceBadge({
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

class ReferenciasReadingBadge extends StatelessWidget {
  const ReferenciasReadingBadge({
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
        referenceReadingStateLabel(rating),
        style: theme.textTheme.labelMedium?.copyWith(
          color: palette.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReferenciasBalanceBadgeColors {
  const _ReferenciasBalanceBadgeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

class _ReferenciasReadingBadgeColors {
  const _ReferenciasReadingBadgeColors({
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

  static _ReferenciasBalanceBadgeColors badge(
    ReferenciasBalanceTone tone,
    ThemeData theme,
  ) {
    return switch (tone) {
      ReferenciasBalanceTone.veryCritical =>
        const _ReferenciasBalanceBadgeColors(
          background: Color(0xFFF6E0DB),
          foreground: Color(0xFF8D463A),
        ),
      ReferenciasBalanceTone.critical => const _ReferenciasBalanceBadgeColors(
          background: Color(0xFFF7E8D2),
          foreground: Color(0xFF8A5A16),
        ),
      ReferenciasBalanceTone.mixed => const _ReferenciasBalanceBadgeColors(
          background: Color(0xFFEEE9DF),
          foreground: Color(0xFF66635E),
        ),
      ReferenciasBalanceTone.favorable => const _ReferenciasBalanceBadgeColors(
          background: Color(0xFFDCEFF0),
          foreground: Color(0xFF246C71),
        ),
      ReferenciasBalanceTone.veryFavorable =>
        const _ReferenciasBalanceBadgeColors(
          background: Color(0xFFD7ECF4),
          foreground: Color(0xFF0A5673),
        ),
      ReferenciasBalanceTone.empty => _ReferenciasBalanceBadgeColors(
          background: theme.colorScheme.surfaceContainerHighest,
          foreground: theme.colorScheme.onSurfaceVariant,
        ),
    };
  }
}

class _ReferenciasReadingPalette {
  const _ReferenciasReadingPalette();

  static _ReferenciasReadingBadgeColors colorsFor(
    ReferenceReadingState state,
    ThemeData theme,
  ) {
    return switch (state) {
      ReferenceReadingState.consensus => const _ReferenciasReadingBadgeColors(
          background: Color(0xFFDCEFF0),
          foreground: Color(0xFF215E62),
          border: Color(0xFF9DCFD2),
        ),
      ReferenceReadingState.divided => const _ReferenciasReadingBadgeColors(
          background: Color(0xFFF6E4DE),
          foreground: Color(0xFF8D4E41),
          border: Color(0xFFE3B5A8),
        ),
      ReferenceReadingState.mixed => const _ReferenciasReadingBadgeColors(
          background: Color(0xFFF3ECE2),
          foreground: Color(0xFF6D6458),
          border: Color(0xFFDCCEBB),
        ),
      ReferenceReadingState.insufficientData => _ReferenciasReadingBadgeColors(
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

  final ReferenciasBalanceSnapshot snapshot;
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
