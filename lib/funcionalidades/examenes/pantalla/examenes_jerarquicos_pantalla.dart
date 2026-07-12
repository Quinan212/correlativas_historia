import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/componentes/etiqueta_opcion_carrera.dart';
import 'visibilidad_examenes.dart';
import 'logica_examenes.dart';
import '../proveedores/proveedores_examenes.dart';
import '../proveedores/proveedores_plan_examenes.dart';
import 'hoja/ruta_hoja_examenes.dart';
import 'componentes/banner_colapsable_examenes.dart';
import 'componentes/lista_materias.dart';

class InicioExamenesJerarquicos extends ConsumerStatefulWidget {
  const InicioExamenesJerarquicos({super.key});

  static const _careers = ['historia', 'geografia', 'politica'];

  @override
  ConsumerState<InicioExamenesJerarquicos> createState() =>
      _InicioExamenesJerarquicosState();
}

class _InicioExamenesJerarquicosState
    extends ConsumerState<InicioExamenesJerarquicos> {
  int? _yearFilter;

  List<int> _availableYearsForCareer(String careerId) {
    final eventos = ref.watch(proveedorTodosLosExamenes).value;
    if (eventos == null) return const [1, 2, 3, 4];

    final years = eventos
        .where(
          (e) =>
              e.careerId == careerId &&
              e.instancia != 'coloquio' &&
              e.anio != null,
        )
        .map((e) => e.anio!)
        .toSet()
        .toList()
      ..sort();
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final careerId = ref.watch(proveedorIdCarreraExamenes);
    final availableYears = _availableYearsForCareer(careerId);
    final careers = kCareers
        .where((c) => InicioExamenesJerarquicos._careers.contains(c.id))
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(proveedorTodosLosExamenes);
        await ref.read(proveedorTodosLosExamenes.future);
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: BannerColapsableExamenes(
                topInset: MediaQuery.of(context).viewPadding.top,
                title: 'Mesas y exámenes',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectorModo(
                      selected: ModoVistaExamenes.jerarquico,
                      onChanged: (value) {
                        ref.read(proveedorModoVistaExamenes.notifier).state =
                            value;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vista jerarquica',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elegi la carrera y despues abrí el año que quieras.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: careerId,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor:
                          isDark ? cs.surfaceContainer : Colors.white,
                      menuMaxHeight: 400,
                      itemHeight: 56,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? cs.surface : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? cs.outlineVariant
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                      items: careers
                          .map(
                            (career) => DropdownMenuItem<String>(
                              value: career.id,
                              child: EtiquetaOpcionCarrera(
                                career,
                                iconSize: 30,
                                iconShiftX: -6,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        ref.read(proveedorIdCarreraExamenes.notifier).state = v;
                        setState(() => _yearFilter = null);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Filtrá por año',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _ChipAnio(
                            label: 'Todos',
                            selected: _yearFilter == null,
                            onTap: () => setState(() => _yearFilter = null),
                          ),
                          for (final year in availableYears) ...[
                            const SizedBox(width: 8),
                            _ChipAnio(
                              label: 'Año $year',
                              selected: _yearFilter == year,
                              onTap: () => setState(() => _yearFilter = year),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    for (final year in availableYears.where(
                      (year) => _yearFilter == null || _yearFilter == year,
                    )) ...[
                      _TarjetaLanzarAnio(
                        year: year,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _PantallaAnioJerarquico(
                                careerId: careerId,
                                year: year,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipAnio extends StatelessWidget {
  const _ChipAnio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected
            ? (isDark ? cs.onPrimaryContainer : const Color(0xFF1D4ED8))
            : cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      backgroundColor: isDark ? cs.surface : Colors.white,
      selectedColor: isDark ? cs.primaryContainer : const Color(0xFFDBEAFE),
      side: BorderSide(
        color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SelectorModo extends StatelessWidget {
  const _SelectorModo({
    required this.selected,
    required this.onChanged,
  });

  final ModoVistaExamenes selected;
  final ValueChanged<ModoVistaExamenes> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ModoVistaExamenes>(
      segments: const [
        ButtonSegment(
          value: ModoVistaExamenes.resumen,
          label: Text('Resumen'),
          icon: Icon(Icons.dashboard_outlined),
        ),
        ButtonSegment(
          value: ModoVistaExamenes.jerarquico,
          label: Text('Jerarquico'),
          icon: Icon(Icons.account_tree_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
      multiSelectionEnabled: false,
      showSelectedIcon: false,
    );
  }
}

class _TarjetaLanzarAnio extends StatelessWidget {
  const _TarjetaLanzarAnio({
    required this.year,
    required this.onTap,
  });

  final int year;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: Text(
                '$year°',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Año $year',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _PantallaAnioJerarquico extends StatelessWidget {
  const _PantallaAnioJerarquico({
    required this.careerId,
    required this.year,
  });

  final String careerId;
  final int year;

  @override
  Widget build(BuildContext context) {
    final career = kCareers.firstWhere(
      (c) => c.id == careerId,
      orElse: () => kCareers.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${career.nombre} · $year° año'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _TarjetaLanzarAlcance(
            title: 'Mesas',
            subtitle: 'Abrir la lista del año.',
            icon: Icons.event_note_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _PantallaAlcanceJerarquico(
                    careerId: careerId,
                    year: year,
                    scope: 'llamados',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _TarjetaLanzarAlcance(
            title: 'Coloquios',
            subtitle: 'Abrir la lista de coloquios.',
            icon: Icons.school_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _PantallaAlcanceJerarquico(
                    careerId: careerId,
                    year: year,
                    scope: 'coloquios',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TarjetaLanzarAlcance extends StatelessWidget {
  const _TarjetaLanzarAlcance({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
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

class _PantallaAlcanceJerarquico extends ConsumerStatefulWidget {
  const _PantallaAlcanceJerarquico({
    required this.careerId,
    required this.year,
    required this.scope,
  });

  final String careerId;
  final int year;
  final String scope;

  @override
  ConsumerState<_PantallaAlcanceJerarquico> createState() =>
      _PantallaAlcanceJerarquicoState();
}

class _PantallaAlcanceJerarquicoState
    extends ConsumerState<_PantallaAlcanceJerarquico> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      ref.invalidate(proveedorTodosLosExamenes);
      await ref.read(proveedorTodosLosExamenes.future);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _abrirHojaMateria(
    BuildContext context, {
    required String careerId,
    required String materia,
    required Map<String, Materia> mapaPlan,
    required bool fromColoquios,
  }) async {
    final nav = Navigator.of(context);
    final all = await ref.read(proveedorTodosLosExamenes.future);
    if (!context.mounted) return;

    final pick = prepararSeleccionParaHoja(
      all: all,
      careerId: careerId,
      materia: materia,
      mapaPlan: mapaPlan,
      fromColoquios: fromColoquios,
    );

    await nav.push(
      RutaHojaExamenes(
        careerId: careerId,
        materia: materia,
        llamado1Eventos: pick.llamado1Eventos,
        llamado2Eventos: pick.llamado2Eventos,
        coloquioEventos: pick.coloquioEventos,
        detalleInicial: pick.detalleInicial,
        mapaPlan: mapaPlan,
      ),
    );
  }

  List<MateriaParaLista> _proximos(List<SeccionDeLista> secciones) {
    final all = secciones.expand((s) => s.materias).toList();
    final now = DateTime.now();
    all.sort((a, b) {
      final da = a.fechaActual;
      final db = b.fechaActual;
      if (da == null && db == null) {
        return a.nombreMostrable.compareTo(b.nombreMostrable);
      }
      if (da == null) return 1;
      if (db == null) return -1;
      final diffA = da.difference(now).inMinutes.abs();
      final diffB = db.difference(now).inMinutes.abs();
      final byProximity = diffA.compareTo(diffB);
      if (byProximity != 0) return byProximity;
      return db.compareTo(da);
    });

    return all.where((m) => m.fechaActual != null).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZeus =
        ref.watch(proveedorModoEstiloExamenes) == ModoEstiloExamenes.zeus;
    final career = kCareers.firstWhere(
      (c) => c.id == widget.careerId,
      orElse: () => kCareers.first,
    );
    final scopeIsColoquios = widget.scope == 'coloquios';
    final title = scopeIsColoquios ? 'Coloquios' : 'Mesas';
    final examenesAsync = ref.watch(proveedorTodosLosExamenes);
    final planMapaAsync = ref.watch(proveedorPlanMapaMaterias(widget.careerId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${career.nombre} · ${widget.year}° · $title'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refresh,
            tooltip: 'Recargar',
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          top: false,
          bottom: true,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isZeus ? 14 : 12,
                    isZeus ? 14 : 12,
                    isZeus ? 14 : 12,
                    isZeus ? 10 : 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title de ${career.nombre} para ${widget.year}° año',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mismo formato que en Resumen.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: planMapaAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Error cargando plan: $e')),
                  ),
                  data: (mapaPlan) {
                    return examenesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Center(child: Text('Error cargando examenes: $e')),
                      ),
                      data: (eventos) {
                        final filteredEvents = eventos.where((event) {
                          if (event.careerId != widget.careerId) return false;
                          final effectiveYear =
                              anioPlanParaEvento(event, mapaPlan);
                          if (effectiveYear != widget.year) return false;
                          return scopeIsColoquios
                              ? event.instancia == 'coloquio'
                              : event.instancia != 'coloquio';
                        }).toList(growable: false);

                        if (filteredEvents.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No hay resultados para este tramo.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          );
                        }

                        final secciones = armarSeccionesConPlan(
                          eventos: filteredEvents,
                          mapaPlan: mapaPlan,
                        );
                        final filtradas = kOcultarExamenesPublicados
                            ? armarSeccionesSoloPlan(mapaPlan: mapaPlan)
                            : secciones;
                        final proximos = scopeIsColoquios
                            ? const <MateriaParaLista>[]
                            : kOcultarExamenesPublicados
                                ? const <MateriaParaLista>[]
                                : _proximos(filtradas);

                        return ListaMaterias(
                          key: ValueKey(
                            'jer-lista-${widget.careerId}-${widget.year}-${widget.scope}',
                          ),
                          careerId: widget.careerId,
                          secciones: filtradas,
                          proximos: proximos,
                          examsHiddenMode: kOcultarExamenesPublicados,
                          hiddenModeMessage: kMensajeProximasMesas,
                          isZeus: isZeus,
                          onTapMateria: (materia, fromColoquios) {
                            if (kOcultarExamenesPublicados) return;
                            unawaited(
                              _abrirHojaMateria(
                                context,
                                careerId: widget.careerId,
                                materia: materia,
                                mapaPlan: mapaPlan,
                                fromColoquios: fromColoquios,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
