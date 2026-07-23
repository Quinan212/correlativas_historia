part of '../../seccion_eventos_examen_administrador.dart';

class _PantallaCarreraExamenAdmin extends ConsumerStatefulWidget {
  const _PantallaCarreraExamenAdmin({
    required this.adminDeviceId,
    required this.career,
  });

  final String adminDeviceId;
  final CareerInfo career;

  @override
  ConsumerState<_PantallaCarreraExamenAdmin> createState() =>
      _PantallaCarreraExamenAdminState();
}

class _PantallaCarreraExamenAdminState
    extends ConsumerState<_PantallaCarreraExamenAdmin> {
  bool _busy = false;
  String _scope = 'mesas';

  Future<void> _refresh() async {
    ref.invalidate(proveedorEventosExamenAdministrador);
    await ref.read(proveedorEventosExamenAdministrador.future);
  }

  Future<void> _openEditor(
    BuildContext context,
    EventoExamenAdministrador? event,
  ) async {
    final draft = await mostrarHojaEditorEventoExamen(
      context: context,
      title: event == null
          ? 'Nuevo examen'
          : event.isColoquio
          ? 'Editar coloquio'
          : 'Editar mesa',
      coloquioMode: event?.isColoquio ?? false,
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
    final careerId = widget.career.id;
    final examenesAsync = ref.watch(proveedorEventosExamenAdministrador);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.career.nombre),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: SafeArea(
        child: examenesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('No se pudieron cargar los exámenes: $error')),
          data: (items) {
            final careerEvents = items
                .where((event) => event.careerId == careerId)
                .toList(growable: false);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SelectorAlcance(
                  scope: _scope,
                  onChanged: (value) => setState(() => _scope = value),
                ),
                const SizedBox(height: 14),
                if (_scope == 'mesas')
                  _CareerScopeView(
                    careerEvents: careerEvents,
                    busy: _busy,
                    scope: _scope,
                    onEdit: (event) => _openEditor(context, event),
                    onDelete: (event) => _deleteEvent(context, event),
                  )
                else
                  _CareerScopeView(
                    careerEvents: careerEvents,
                    busy: _busy,
                    scope: _scope,
                    onEdit: (event) => _openEditor(context, event),
                    onDelete: (event) => _deleteEvent(context, event),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
