import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../proveedores/proveedores_fotos_materias_administrador.dart';

class FotosMateriasCarreraAdministradorPantalla extends ConsumerWidget {
  const FotosMateriasCarreraAdministradorPantalla({
    super.key,
    required this.careerId,
  });

  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overviewAsync = ref.watch(proveedorResumenFotosMateriasAdministrador);
    final career = kCareers.firstWhere(
      (item) => item.id == careerId,
      orElse: () => kCareers.first,
    );
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(career.nombre),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                ref.invalidate(proveedorResumenFotosMateriasAdministrador),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: overviewAsync.when(
              data: (items) {
                final stats = items
                    .where((item) => item.career.id == careerId)
                    .toList(growable: false);
                if (stats.isEmpty) {
                  return const _EstadoVacio(
                    title: 'No hay fotos para esta carrera',
                    subtitle:
                        'Si todavía no hay imágenes cargadas, no se muestran años ni materias vacías.',
                    icon: Icons.photo_library_outlined,
                  );
                }

                final careerStats = stats.first;
                final padding = isDesktop
                    ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                    : const EdgeInsets.fromLTRB(16, 12, 16, 24);

                return ListView(
                  padding: padding,
                  children: [
                    _TarjetaEncabezado(
                      careerName: career.nombre,
                      totalPhotos: careerStats.photoCount,
                    ),
                    const SizedBox(height: 24),
                    if (isDesktop)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.4,
                            ),
                        itemCount: careerStats.years.length,
                        itemBuilder: (context, index) {
                          return _TarjetaAnio(
                            yearStats: careerStats.years[index],
                          );
                        },
                      )
                    else
                      Column(
                        children: careerStats.years
                            .map(
                              (yearStats) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TarjetaAnio(yearStats: yearStats),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _EstadoVacio(
                title: 'Error de carga',
                subtitle: '$error',
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaEncabezado extends StatelessWidget {
  const _TarjetaEncabezado({
    required this.careerName,
    required this.totalPhotos,
  });

  final String careerName;
  final int totalPhotos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            careerName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Se han detectado $totalPhotos fotos cargadas en esta carrera.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Solo se muestran los años y materias que cuentan con material activo.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _TarjetaAnio extends StatelessWidget {
  const _TarjetaAnio({required this.yearStats});
  final EstadisticasFotosAnioAdministrador yearStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${yearStats.year}° AÑO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              _Insignia(label: '${yearStats.photoCount} fotos'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: yearStats.matters.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final matterStats = yearStats.matters[index];
                return _BaldosaMateria(
                  matterName: matterStats.matter.nombre,
                  photoCount: matterStats.photoCount,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BaldosaMateria extends StatelessWidget {
  const _BaldosaMateria({required this.matterName, required this.photoCount});

  final String matterName;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              matterName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$photoCount',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Insignia extends StatelessWidget {
  const _Insignia({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.hintColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
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
    );
  }
}
