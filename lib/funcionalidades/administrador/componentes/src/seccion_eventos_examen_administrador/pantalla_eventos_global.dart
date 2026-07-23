part of '../../seccion_eventos_examen_administrador.dart';

class _PantallaEventosExamenGlobalAdmin extends ConsumerStatefulWidget {
  const _PantallaEventosExamenGlobalAdmin({required this.adminDeviceId});

  final String adminDeviceId;

  @override
  ConsumerState<_PantallaEventosExamenGlobalAdmin> createState() =>
      _PantallaEventosExamenGlobalAdminState();
}

class _PantallaEventosExamenGlobalAdminState
    extends ConsumerState<_PantallaEventosExamenGlobalAdmin> {
  String _scope = 'mesas';
  bool _busy = false;

  bool _passesScope(EventoExamenAdministrador event) {
    if (_scope == 'mesas') return !event.isColoquio;
    return event.isColoquio;
  }

  Future<void> _openEditor(
    BuildContext context,
    EventoExamenAdministrador? event,
  ) async {
    final draft = await mostrarHojaEditorEventoExamen(
      context: context,
      title: event == null
          ? _scope == 'mesas'
                ? 'Nueva mesa'
                : 'Nuevo coloquio'
          : _scope == 'mesas'
          ? 'Editar mesa'
          : 'Editar coloquio',
      coloquioMode: _scope == 'coloquios',
      initialEvent: event,
    );
    if (draft == null) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioEventosExamenAdministrador);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Examen guardado')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _deleteEvent(
    BuildContext context,
    EventoExamenAdministrador event,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Borrar examen'),
            content: Text(
              'Vas a borrar "${event.materia}". Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Borrar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final client = ref.read(proveedorClienteSupabase);
    if (client == null || event.id == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioEventosExamenAdministrador);
      await repo.delete(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        id: event.id!,
      );
      ref.invalidate(proveedorEventosExamenAdministrador);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Examen borrado')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo borrar: $error')));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examenesAsync = ref.watch(proveedorEventosExamenAdministrador);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista global'),
        actions: [
          IconButton(
            onPressed: _busy ? null : () => _openEditor(context, null),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nuevo',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesas y coloquios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Desde acá podés seguir cargando, editando o borrando sin tocar la vista pública.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Mesas'),
                      selected: _scope == 'mesas',
                      onSelected: _busy
                          ? null
                          : (_) => setState(() => _scope = 'mesas'),
                    ),
                    ChoiceChip(
                      label: const Text('Coloquios'),
                      selected: _scope == 'coloquios',
                      onSelected: _busy
                          ? null
                          : (_) => setState(() => _scope = 'coloquios'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                examenesAsync.when(
                  data: (items) {
                    final filtered =
                        items.where(_passesScope).toList(growable: false)
                          ..sort((a, b) {
                            final byCareer = a.careerId.compareTo(b.careerId);
                            if (byCareer != 0) return byCareer;
                            final byFecha = _compareDate(a.fecha, b.fecha);
                            if (byFecha != 0) return byFecha;
                            final byMateria = a.materia.compareTo(b.materia);
                            if (byMateria != 0) return byMateria;
                            return (a.hora ?? '').compareTo(b.hora ?? '');
                          });

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            _scope == 'mesas'
                                ? 'Todavía no hay mesas cargadas.'
                                : 'Todavía no hay coloquios cargados.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final event = filtered[index];
                        return _TarjetaEventoExamen(
                          event: event,
                          busy: _busy,
                          onEdit: () => _openEditor(context, event),
                          onDelete: () => _deleteEvent(context, event),
                        );
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No se pudieron cargar los exámenes: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
