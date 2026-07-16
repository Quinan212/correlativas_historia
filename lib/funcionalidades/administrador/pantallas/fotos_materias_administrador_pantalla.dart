import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores/proveedores_fotos_materias_administrador.dart';
import 'fotos_materias_carrera_administrador_pantalla.dart';

class FotosMateriasAdministradorPantalla extends ConsumerWidget {
  const FotosMateriasAdministradorPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(proveedorResumenFotosMateriasAdministrador);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Fotos por carrera'),
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
            child: statsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const _EstadoVacio(
                    title: 'Todavía no hay fotos cargadas',
                    subtitle:
                        'Cuando aparezcan fotos de materia, van a listarse primero por carrera y luego por año y materia.',
                    icon: Icons.photo_library_outlined,
                  );
                }

                final totalPhotos =
                    items.fold<int>(0, (sum, item) => sum + item.photoCount);

                return ListView(
                  padding: isDesktop
                      ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                      : const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _TarjetaResumen(
                      totalPhotos: totalPhotos,
                      totalCareers: items.length,
                    ),
                    const SizedBox(height: 24),
                    if (isDesktop)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _TarjetaCarrera(
                            stats: items[index],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      FotosMateriasCarreraAdministradorPantalla(
                                    careerId: items[index].career.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    else
                      Column(
                        children: items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TarjetaCarrera(
                                  stats: item,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            FotosMateriasCarreraAdministradorPantalla(
                                          careerId: item.career.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _EstadoVacio(
                title: 'No se pudo cargar el resumen de fotos',
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

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.totalPhotos,
    required this.totalCareers,
  });

  final int totalPhotos;
  final int totalCareers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen general de archivos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Se detectaron $totalPhotos fotos distribuidas en $totalCareers carreras con contenido activo.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCarrera extends StatelessWidget {
  const _TarjetaCarrera({
    required this.stats,
    required this.onTap,
  });

  final EstadisticasFotosCarreraAdministrador stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF0B1220) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.collections_bookmark_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stats.career.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.photoCount} fotos cargadas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.hintColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
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
      ),
    );
  }
}
