import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../../../shared/supabase/supabase.dart';
import '../../../shared/utils/text_sanitize.dart';
import '../models/admin_exam_event.dart';
import '../providers/admin_exam_events_providers.dart';
import 'exam_event_editor_sheet.dart';

class AdminExamEventsSection extends ConsumerStatefulWidget {
  const AdminExamEventsSection({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<AdminExamEventsSection> createState() =>
      _AdminExamEventsSectionState();
}

class _AdminExamEventsSectionState extends ConsumerState<AdminExamEventsSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mesas y coloquios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Elegí si querés entrar por carrera o ver toda la lista en una vista global.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _openByCareer(context),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Por carrera'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _openGlobal(context),
                icon: const Icon(Icons.view_list_rounded),
                label: const Text('Vista global'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openByCareer(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdminExamEventsByCareerScreen(
          adminDeviceId: widget.adminDeviceId,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(adminExamEventsProvider);
  }

  Future<void> _openGlobal(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdminExamEventsGlobalScreen(
          adminDeviceId: widget.adminDeviceId,
        ),
      ),
    );
    if (!mounted) return;
    ref.invalidate(adminExamEventsProvider);
  }
}

class _AdminExamEventsByCareerScreen extends ConsumerWidget {
  const _AdminExamEventsByCareerScreen({
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  static const _careerOrder = ['historia', 'geografia', 'politica'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final examenesAsync = ref.watch(adminExamEventsProvider);
    final careers = kCareers
        .where((career) => _careerOrder.contains(career.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exámenes por carrera'),
      ),
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
              error: (error, _) => Text('No se pudieron cargar los exámenes: $error'),
              data: (items) {
                final byCareer = <String, List<AdminExamEvent>>{};
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
                          child: _CareerOverviewCard(
                            career: career,
                            items: byCareer[career.id] ?? const <AdminExamEvent>[],
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

class _AdminExamEventsGlobalScreen extends ConsumerStatefulWidget {
  const _AdminExamEventsGlobalScreen({
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<_AdminExamEventsGlobalScreen> createState() =>
      _AdminExamEventsGlobalScreenState();
}

class _AdminExamEventsGlobalScreenState
    extends ConsumerState<_AdminExamEventsGlobalScreen> {
  String _scope = 'mesas';
  bool _busy = false;

  bool _passesScope(AdminExamEvent event) {
    if (_scope == 'mesas') return !event.isColoquio;
    return event.isColoquio;
  }

  Future<void> _openEditor(BuildContext context, AdminExamEvent? event) async {
    final draft = await showExamEventEditorSheet(
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

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(adminExamEventsRepositoryProvider);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(adminExamEventsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examen guardado')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _deleteEvent(BuildContext context, AdminExamEvent event) async {
    final confirmed = await showDialog<bool>(
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

    final client = ref.read(supabaseClientProvider);
    if (client == null || event.id == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(adminExamEventsRepositoryProvider);
      await repo.delete(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        id: event.id!,
      );
      ref.invalidate(adminExamEventsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examen borrado')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo borrar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final examenesAsync = ref.watch(adminExamEventsProvider);

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
                      onSelected:
                          _busy ? null : (_) => setState(() => _scope = 'mesas'),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final event = filtered[index];
                        return _ExamEventCard(
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
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
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

class _CareerOverviewCard extends StatelessWidget {
  const _CareerOverviewCard({
    required this.career,
    required this.items,
    required this.adminDeviceId,
  });

  final CareerInfo career;
  final List<AdminExamEvent> items;
  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMesas = items.where((event) => !event.isColoquio).length;
    final totalColoquios = items.where((event) => event.isColoquio).length;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _AdminExamCareerScreen(
                adminDeviceId: adminDeviceId,
                career: career,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
                      style: theme.textTheme.bodyMedium,
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

class _AdminExamCareerScreen extends ConsumerStatefulWidget {
  const _AdminExamCareerScreen({
    required this.adminDeviceId,
    required this.career,
  });

  final String adminDeviceId;
  final CareerInfo career;

  @override
  ConsumerState<_AdminExamCareerScreen> createState() =>
      _AdminExamCareerScreenState();
}

class _AdminExamCareerScreenState extends ConsumerState<_AdminExamCareerScreen> {
  bool _busy = false;
  String _scope = 'mesas';

  Future<void> _refresh() async {
    ref.invalidate(adminExamEventsProvider);
    await ref.read(adminExamEventsProvider.future);
  }

  Future<void> _openEditor(BuildContext context, AdminExamEvent? event) async {
    final draft = await showExamEventEditorSheet(
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

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(adminExamEventsRepositoryProvider);
      await repo.upsert(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        draft: draft,
      );
      ref.invalidate(adminExamEventsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examen guardado')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _deleteEvent(BuildContext context, AdminExamEvent event) async {
    final confirmed = await showDialog<bool>(
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

    final client = ref.read(supabaseClientProvider);
    if (client == null || event.id == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(adminExamEventsRepositoryProvider);
      await repo.delete(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        id: event.id!,
      );
      ref.invalidate(adminExamEventsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Examen borrado')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo borrar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final careerId = widget.career.id;
    final examenesAsync = ref.watch(adminExamEventsProvider);

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
          error: (error, _) => Center(
            child: Text('No se pudieron cargar los exámenes: $error'),
          ),
          data: (items) {
            final careerEvents = items
                .where((event) => event.careerId == careerId)
                .toList(growable: false);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _ScopeSelector(
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

class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({
    required this.scope,
    required this.onChanged,
  });

  final String scope;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          label: const Text('Mesas'),
          selected: scope == 'mesas',
          onSelected: (_) => onChanged('mesas'),
        ),
        ChoiceChip(
          label: const Text('Coloquios'),
          selected: scope == 'coloquios',
          onSelected: (_) => onChanged('coloquios'),
        ),
      ],
    );
  }
}

class _CareerScopeView extends StatelessWidget {
  const _CareerScopeView({
    required this.careerEvents,
    required this.busy,
    required this.scope,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AdminExamEvent> careerEvents;
  final bool busy;
  final String scope;
  final ValueChanged<AdminExamEvent> onEdit;
  final ValueChanged<AdminExamEvent> onDelete;

  @override
  Widget build(BuildContext context) {
    final scoped = careerEvents
        .where((event) => scope == 'coloquios' ? event.isColoquio : !event.isColoquio)
        .toList(growable: false)
      ..sort((a, b) {
        final byYear = _yearSortValue(_resolvedYear(a))
            .compareTo(_yearSortValue(_resolvedYear(b)));
        if (byYear != 0) return byYear;
        final byFecha = _compareDate(a.fecha, b.fecha);
        if (byFecha != 0) return byFecha;
        final byMateria = a.materia.compareTo(b.materia);
        if (byMateria != 0) return byMateria;
        return (a.hora ?? '').compareTo(b.hora ?? '');
      });

    final grouped = <int?, List<AdminExamEvent>>{};
    for (final event in scoped) {
      grouped.putIfAbsent(_resolvedYear(event), () => <AdminExamEvent>[]).add(event);
    }

    for (final list in grouped.values) {
      list.sort((a, b) {
        final byFecha = _compareDate(a.fecha, b.fecha);
        if (byFecha != 0) return byFecha;
        final byMateria = a.materia.compareTo(b.materia);
        if (byMateria != 0) return byMateria;
        return (a.hora ?? '').compareTo(b.hora ?? '');
      });
    }

    final years = [1, 2, 3, 4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final year in years) ...[
          _YearGroupCard(
            title: '$year° año',
            events: grouped[year] ?? const <AdminExamEvent>[],
            busy: busy,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _YearGroupCard extends StatelessWidget {
  const _YearGroupCard({
    required this.title,
    required this.events,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final List<AdminExamEvent> events;
  final bool busy;
  final ValueChanged<AdminExamEvent> onEdit;
  final ValueChanged<AdminExamEvent> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mesas =
        events.where((event) => !event.isColoquio).toList(growable: false);
    final coloquios =
        events.where((event) => event.isColoquio).toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${events.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          children: [
            if (mesas.isNotEmpty) ...[
              Text(
                'Mesas',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...mesas.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExamEventCard(
                    event: event,
                    busy: busy,
                    onEdit: () => onEdit(event),
                    onDelete: () => onDelete(event),
                  ),
                ),
              ),
            ],
            if (coloquios.isNotEmpty) ...[
              if (mesas.isNotEmpty) const SizedBox(height: 6),
              Text(
                'Coloquios',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...coloquios.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExamEventCard(
                    event: event,
                    busy: busy,
                    onEdit: () => onEdit(event),
                    onDelete: () => onDelete(event),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExamEventCard extends StatelessWidget {
  const _ExamEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.busy,
  });

  final AdminExamEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final careerLabel = _careerLabel(event.careerId);
    final displayYear = _resolvedYear(event);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: careerLabel),
              _Badge(
                label: event.isColoquio ? 'Coloquio' : 'Mesa',
              ),
              if (displayYear != null) _Badge(label: '$displayYear° año'),
              if (event.hora != null) _Badge(label: event.hora!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.materia,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (event.fecha != null) ...[
            const SizedBox(height: 4),
            Text(_formatDate(event.fecha!), style: theme.textTheme.bodyMedium),
          ],
          if (event.docentes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.docentes.join(' / '),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              OutlinedButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Borrar'),
              ),
            ],
          ),
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
        color: theme.colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
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

int _compareDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

int _yearSortValue(int? year) => year ?? 99;

int? _resolvedYear(AdminExamEvent event) {
  if (event.anio != null) return event.anio;

  final materia = _clean(event.materia);
  if (event.careerId == 'historia') {
    if (materia.contains('practica docente i')) return 1;
    if (materia.contains('didactica de las ciencias sociales')) return 2;
    if (materia.contains('practica docente ii')) return 2;
    if (materia.contains('epistemologia de la historia')) return 3;
    if (materia.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'geografia') {
    if (materia.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'politica') {
    if (materia.contains('practica docente ii')) return 2;
    if (materia.contains('didactica de las ciencias sociales')) return 2;
    if (materia.contains('practica docente iii')) return 3;
  }

  return null;
}

String _clean(String input) => sanitizeLowerNoAccents(input);

String _formatDate(DateTime value) {
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  final y = value.year.toString();
  return '$d/$m/$y';
}

String _careerLabel(String careerId) {
  for (final career in kCareers) {
    if (career.id == careerId) return career.nombre;
  }
  return careerId;
}


