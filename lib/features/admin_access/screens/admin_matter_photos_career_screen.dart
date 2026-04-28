import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../providers/admin_matter_photos_provider.dart';

class AdminMatterPhotosCareerScreen extends ConsumerWidget {
  const AdminMatterPhotosCareerScreen({
    super.key,
    required this.careerId,
  });

  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(adminMatterPhotosOverviewProvider);
    final career = kCareers.firstWhere(
      (item) => item.id == careerId,
      orElse: () => kCareers.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(career.nombre),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminMatterPhotosOverviewProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: overviewAsync.when(
          data: (items) {
            final stats = items.where((item) => item.career.id == careerId).toList(
                  growable: false,
                );
            if (stats.isEmpty) {
              return _EmptyState(
                title: 'No hay fotos para esta carrera',
                subtitle:
                    'Si todavía no hay imágenes cargadas, no se muestran años ni materias vacías.',
                icon: Icons.photo_library_outlined,
              );
            }

            final careerStats = stats.first;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _HeaderCard(
                  careerName: career.nombre,
                  totalPhotos: careerStats.photoCount,
                ),
                const SizedBox(height: 14),
                ...careerStats.years.map(
                  (yearStats) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _YearCard(
                      yearStats: yearStats,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _EmptyState(
            title: 'No se pudo cargar la carrera',
            subtitle: '$error',
            icon: Icons.error_outline_rounded,
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.careerName,
    required this.totalPhotos,
  });

  final String careerName;
  final int totalPhotos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            careerName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPhotos fotos en total',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Solo se muestran años y materias que tienen al menos una imagen.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _YearCard extends StatelessWidget {
  const _YearCard({required this.yearStats});

  final AdminMatterPhotoYearStats yearStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${yearStats.year}° año',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              _Badge(label: '${yearStats.photoCount} fotos'),
            ],
          ),
          const SizedBox(height: 12),
          ...yearStats.matters.map(
            (matterStats) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MatterRow(
                matterName: matterStats.matter.nombre,
                photoCount: matterStats.photoCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatterRow extends StatelessWidget {
  const _MatterRow({
    required this.matterName,
    required this.photoCount,
  });

  final String matterName;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              matterName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Badge(label: '$photoCount'),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
