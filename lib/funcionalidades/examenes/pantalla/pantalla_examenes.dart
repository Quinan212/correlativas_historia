import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../proveedores/proveedores_examenes.dart';
import '../proveedores/proveedores_plan_examenes.dart';
import 'visibilidad_examenes.dart';
import 'logica_examenes.dart';
import 'hoja/ruta_hoja_examenes.dart';
import 'componentes/banner_colapsable_examenes.dart';
import 'componentes/lista_materias.dart';
import 'barra_filtros_examenes.dart';
import 'componentes_escritorio_examenes.dart';

class PantallaExamenes extends ConsumerStatefulWidget {
  const PantallaExamenes({super.key});

  @override
  ConsumerState<PantallaExamenes> createState() => _PantallaExamenesState();
}

class _PantallaExamenesState extends ConsumerState<PantallaExamenes> {
  final _searchCtrl = TextEditingController();
  String _scope = 'todos'; // todos | llamados | coloquios
  int? _yearFilter;
  bool _openingSheet = false;
  bool _refreshing = false;

  // Debounce: evita recalcular en cada tecla
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshExams() async {
    if (_refreshing) return;

    setState(() => _refreshing = true);
    try {
      ref.invalidate(proveedorTodosLosExamenes);
      ref.invalidate(proveedorExamenesFiltrados);
      await ref.read(proveedorExamenesFiltrados.future);
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  Future<void> _abrirHojaMateria(
    BuildContext context, {
    required String careerId,
    required String materia,
    required Map<String, Materia> mapaPlan,
    required bool fromColoquios,
  }) async {
    if (_openingSheet) return;
    _openingSheet = true;

    final nav = Navigator.of(context);

    try {
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
    } finally {
      _openingSheet = false;
    }
  }

  List<SeccionDeLista> _filtrarSecciones(List<SeccionDeLista> secciones) {
    final q = normalizeSearchQuery(_searchQuery);

    return secciones
        .map((s) {
          final materias = s.materias.where((m) {
            if (_yearFilter != null) {
              final anio = m.anioPlan;
              if (anio != _yearFilter) return false;
            }

            if (q.isEmpty) return true;
            final source = normalizeSearchQuery(
              '${m.nombreMostrable} ${m.codigo} ${m.tipo} ${m.formato}',
            );
            return source.contains(q);
          }).toList();

          if (materias.isEmpty) return null;

          final matchesScope = switch (_scope) {
            'llamados' => materias.any((m) => !m.esColoquio),
            'coloquios' => materias.any((m) => m.esColoquio),
            _ => true,
          };

          if (!matchesScope) return null;

          return SeccionDeLista(
            titulo: s.titulo,
            materias: materias,
            esColoquios: s.esColoquios,
          );
        })
        .whereType<SeccionDeLista>()
        .toList();
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

  Widget _buildModeSwitcher({
    required BuildContext context,
    required ModoVistaExamenes mode,
  }) {
    return SegmentedButton<ModoVistaExamenes>(
      segments: const [
        ButtonSegment(
          value: ModoVistaExamenes.resumen,
          label: Text('Resumen'),
          icon: Icon(Icons.dashboard_outlined),
        ),
        ButtonSegment(
          value: ModoVistaExamenes.jerarquico,
          label: Text('Jerárquico'),
          icon: Icon(Icons.account_tree_outlined),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        final nextMode = selection.first;
        ref.read(proveedorModoVistaExamenes.notifier).state = nextMode;
        if (nextMode == ModoVistaExamenes.jerarquico) {
          setState(() => _scope = 'llamados');
        } else {
          setState(() => _scope = 'todos');
        }
      },
      multiSelectionEnabled: false,
      showSelectedIcon: false,
    );
  }

  Widget _buildResumenMode(BuildContext context, double topInset) {
    final theme = Theme.of(context);
    final isZeus =
        ref.watch(proveedorModoEstiloExamenes) == ModoEstiloExamenes.zeus;

    final careerId = ref.watch(proveedorIdCarreraExamenes);
    final examenesAsync = ref.watch(proveedorExamenesFiltrados);
    final planMapaAsync = ref.watch(proveedorPlanMapaMaterias(careerId));

    return RefreshIndicator(
      onRefresh: _refreshExams,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: BannerColapsableExamenes(
              topInset: topInset,
              title: 'Mesas y exámenes',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BarraFiltrosExamenes(
                    careerId: careerId,
                    searchController: _searchCtrl,
                    searchQuery: _searchQuery,
                    scope: _scope,
                    yearFilter: _yearFilter,
                    onCareerChanged: (v) {
                      setState(() {
                        _yearFilter = null;
                        _scope = 'todos';
                      });
                      ref.read(proveedorIdCarreraExamenes.notifier).state = v;
                    },
                    onSearchChanged: () {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 200), () {
                        if (mounted) {
                          setState(() => _searchQuery = _searchCtrl.text);
                        }
                      });
                    },
                    onClearSearch: () {
                      _debounce?.cancel();
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    onScopeChanged: (v) => setState(() => _scope = v),
                    onYearChanged: (v) => setState(() => _yearFilter = v),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              key: ValueKey('examenes-body-$careerId'),
              child: planMapaAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error cargando plan: $e')),
                data: (mapaPlan) {
                  return examenesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error cargando exámenes: $e')),
                    data: (eventos) {
                      if (eventos.isEmpty) {
                        return Center(
                          child: Text(
                            'Todavía no hay mesas cargadas para ${labelCarrera(careerId)}.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }

                      final secciones = armarSeccionesConPlan(
                        eventos: eventos,
                        mapaPlan: mapaPlan,
                      );
                      final baseSecciones = kOcultarExamenesPublicados
                          ? armarSeccionesSoloPlan(mapaPlan: mapaPlan)
                          : secciones;
                      final filtradas = _filtrarSecciones(baseSecciones);
                      final proximos = kOcultarExamenesPublicados
                          ? const <MateriaParaLista>[]
                          : _proximos(filtradas);

                      return ListaMaterias(
                        key: ValueKey(
                          'lista-$careerId-$_scope-${_yearFilter ?? 0}-${_searchCtrl.text}',
                        ),
                        careerId: careerId,
                        secciones: filtradas,
                        proximos: proximos,
                        examsHiddenMode: kOcultarExamenesPublicados,
                        hiddenModeMessage: kMensajeProximasMesas,
                        isZeus: isZeus,
                        onTapMateria: (materia, fromColoquios) {
                          if (kOcultarExamenesPublicados) return;
                          _abrirHojaMateria(
                            context,
                            careerId: careerId,
                            materia: materia,
                            mapaPlan: mapaPlan,
                            fromColoquios: fromColoquios,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildJerarquicoMode(BuildContext context) {
    final theme = Theme.of(context);
    final isZeus =
        ref.watch(proveedorModoEstiloExamenes) == ModoEstiloExamenes.zeus;

    final careerId = ref.watch(proveedorIdCarreraExamenes);
    final examenesAsync = ref.watch(proveedorTodosLosExamenes);
    final planMapaAsync = ref.watch(proveedorPlanMapaMaterias(careerId));

    final careers = kCareers
        .where((c) =>
            c.id == 'historia' || c.id == 'geografia' || c.id == 'politica')
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: _refreshExams,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                children: [
                  _buildModeSwitcher(
                    context: context,
                    mode: ModoVistaExamenes.jerarquico,
                  ),
                  PanelFiltrosJerarquicoExamenes(
                    careers: careers,
                    careerId: careerId,
                    scope: _scope,
                    yearFilter: _yearFilter,
                    onTapCareer: (id) {
                      ref.read(proveedorIdCarreraExamenes.notifier).state = id;
                      setState(() {
                        _yearFilter = null;
                        _scope = 'todos';
                      });
                    },
                    onTapScope: (v) => setState(() => _scope = v),
                    onTapYear: (v) => setState(() => _yearFilter = v),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              key: ValueKey('jerarquico-$careerId-${_yearFilter ?? 0}-$_scope'),
              child: planMapaAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error cargando plan: $e')),
                data: (mapaPlan) {
                  return examenesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error cargando exámenes: $e')),
                    data: (eventos) {
                      var scoped = eventos.where((e) => e.careerId == careerId);
                      if (_scope == 'llamados') {
                        scoped = scoped.where((e) => e.instancia != 'coloquio');
                      } else if (_scope == 'coloquios') {
                        scoped = scoped.where((e) => e.instancia == 'coloquio');
                      }

                      final filteredEvents = scoped.where((e) {
                        if (_yearFilter == null) return true;
                        final effectiveYear = anioPlanParaEvento(e, mapaPlan);
                        return effectiveYear == _yearFilter;
                      }).toList(growable: false);

                      if (filteredEvents.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay resultados para ${labelCarrera(careerId)}.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }

                      final secciones = armarSeccionesConPlan(
                        eventos: filteredEvents,
                        mapaPlan: mapaPlan,
                      );
                      final filtradas = _filtrarSecciones(secciones);
                      final proximos = _proximos(filtradas);

                      return ListaMaterias(
                        key: ValueKey(
                          'jer-lista-$careerId-${_yearFilter ?? 0}-$_scope-${_searchCtrl.text}',
                        ),
                        careerId: careerId,
                        secciones: filtradas,
                        proximos: proximos,
                        examsHiddenMode: kOcultarExamenesPublicados,
                        hiddenModeMessage: kMensajeProximasMesas,
                        isZeus: isZeus,
                        onTapMateria: (materia, fromColoquios) {
                          if (kOcultarExamenesPublicados) return;
                          _abrirHojaMateria(
                            context,
                            careerId: careerId,
                            materia: materia,
                            mapaPlan: mapaPlan,
                            fromColoquios: fromColoquios,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopResumenMode(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isZeus =
        ref.watch(proveedorModoEstiloExamenes) == ModoEstiloExamenes.zeus;

    final careerId = ref.watch(proveedorIdCarreraExamenes);
    final examCareerOptions = kCareers
        .where(
          (c) =>
              c.id == 'historia' || c.id == 'geografia' || c.id == 'politica',
        )
        .toList();
    final selectedCareer = examCareerOptions.firstWhere(
      (career) => career.id == careerId,
      orElse: () => examCareerOptions.first,
    );
    final examenesAsync = ref.watch(proveedorExamenesFiltrados);
    final planMapaAsync = ref.watch(proveedorPlanMapaMaterias(careerId));

    return Row(
      children: [
        BarraLateralEscritorioExamenes(
          searchCtrl: _searchCtrl,
          searchQuery: _searchQuery,
          scope: _scope,
          yearFilter: _yearFilter,
          careerId: careerId,
          careerOptions: examCareerOptions,
          isDark: isDark,
          onSearchChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 160), () {
              if (mounted) setState(() => _searchQuery = value);
            });
          },
          onClearSearch: () {
            _debounce?.cancel();
            _searchCtrl.clear();
            setState(() => _searchQuery = '');
          },
          onTapCareer: (id) {
            setState(() {
              _yearFilter = null;
              _scope = 'todos';
            });
            ref.read(proveedorIdCarreraExamenes.notifier).state = id;
          },
          onTapScope: (v) => setState(() => _scope = v),
          onTapYear: (v) => setState(() => _yearFilter = v),
        ),
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF070C15) : const Color(0xFFF5F7FA),
            child: RefreshIndicator(
              onRefresh: _refreshExams,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedCareer.nombre,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vista de trabajo para revisar fechas, llamados, coloquios y próximos movimientos.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _refreshing ? null : _refreshExams,
                            tooltip: 'Actualizar',
                            icon: _refreshing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: planMapaAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text('Error cargando plan: $e')),
                      ),
                      data: (mapaPlan) {
                        return examenesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text('Error cargando exámenes: $e'),
                            ),
                          ),
                          data: (eventos) {
                            if (eventos.isEmpty) {
                              return EstadoVacioEscritorio(
                                message:
                                    'Todavía no hay mesas cargadas para ${labelCarrera(careerId)}.',
                              );
                            }

                            final secciones = armarSeccionesConPlan(
                              eventos: eventos,
                              mapaPlan: mapaPlan,
                            );
                            final baseSecciones = kOcultarExamenesPublicados
                                ? armarSeccionesSoloPlan(mapaPlan: mapaPlan)
                                : secciones;
                            final filtradas = _filtrarSecciones(baseSecciones);
                            final proximos = kOcultarExamenesPublicados
                                ? const <MateriaParaLista>[]
                                : _proximos(filtradas);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ResumenEscritorio(
                                  secciones: filtradas,
                                  proximos: proximos,
                                  scope: _scope,
                                  yearFilter: _yearFilter,
                                ),
                                ListaMaterias(
                                  key: ValueKey(
                                    'desktop-lista-$careerId-$_scope-${_yearFilter ?? 0}-${_searchCtrl.text}',
                                  ),
                                  careerId: careerId,
                                  secciones: filtradas,
                                  proximos: proximos,
                                  examsHiddenMode: kOcultarExamenesPublicados,
                                  hiddenModeMessage: kMensajeProximasMesas,
                                  isZeus: isZeus,
                                  onTapMateria: (materia, fromColoquios) {
                                    if (kOcultarExamenesPublicados) return;
                                    _abrirHojaMateria(
                                      context,
                                      careerId: careerId,
                                      materia: materia,
                                      mapaPlan: mapaPlan,
                                      fromColoquios: fromColoquios,
                                    );
                                  },
                                ),
                              ],
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final styleMode = ref.watch(proveedorModoEstiloExamenes);
    final isZeus = styleMode == ModoEstiloExamenes.zeus;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final topInset = MediaQuery.of(context).viewPadding.top;

    if (isDesktop) {
      return Scaffold(
        body: _buildDesktopResumenMode(context),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            if (isZeus)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withValues(
                              alpha: 0.14,
                            ),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.24,
                          ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Estilo Zeus activo: exámenes con paneles más sólidos, bordes más firmes y una jerarquía visual más marcada.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: _buildResumenMode(context, topInset),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}


