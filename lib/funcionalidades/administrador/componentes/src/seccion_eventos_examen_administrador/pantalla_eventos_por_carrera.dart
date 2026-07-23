part of '../../seccion_eventos_examen_administrador.dart';

class _PantallaEventosExamenPorCarreraAdmin extends ConsumerWidget {
  const _PantallaEventosExamenPorCarreraAdmin({required this.adminDeviceId});

  final String adminDeviceId;

  static const _careerOrder = ['historia', 'geografia', 'politica'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final examenesAsync = ref.watch(proveedorEventosExamenAdministrador);
    final careers = kCareers
        .where((career) => _careerOrder.contains(career.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Exámenes por carrera')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            Text(
              'Elegí una carrera para ver sus años y separar mesas / coloquios.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            examenesAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 3),
              error: (error, _) =>
                  Text('No se pudieron cargar los exámenes: $error'),
              data: (items) {
                final byCareer = <String, List<EventoExamenAdministrador>>{};
                for (final career in careers) {
                  byCareer[career.id] = items
                      .where((event) => event.careerId == career.id)
                      .toList(growable: false);
                }

                return Column(
                  children: careers
                      .map(
                        (career) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TarjetaResumenCarrera(
                            career: career,
                            items:
                                byCareer[career.id] ??
                                const <EventoExamenAdministrador>[],
                            adminDeviceId: adminDeviceId,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaResumenCarrera extends StatelessWidget {
  const _TarjetaResumenCarrera({
    required this.career,
    required this.items,
    required this.adminDeviceId,
  });

  final CareerInfo career;
  final List<EventoExamenAdministrador> items;
  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMesas = items.where((event) => !event.isColoquio).length;
    final totalColoquios = items.where((event) => event.isColoquio).length;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          abrirPantallaAdministradorAtlassian<void>(
            context,
            _PantallaCarreraExamenAdmin(
              adminDeviceId: adminDeviceId,
              career: career,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.nombre,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalMesas mesas, $totalColoquios coloquios',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
