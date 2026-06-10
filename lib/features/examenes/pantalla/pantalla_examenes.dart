import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../providers/examenes_providers.dart';
import '../providers/plan_providers.dart';
import 'examenes_visibility.dart';
import 'logica_examenes.dart';
import 'sheet/route_sheet_examenes.dart';
import 'widgets/banner_colapsable_examenes.dart';
import 'widgets/lista_materias.dart';

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
      ref.invalidate(examenesAllProvider);
      ref.invalidate(examenesFiltradosProvider);
      await ref.read(examenesFiltradosProvider.future);
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  Future<void> _openMateriaSheet(
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
      final all = await ref.read(examenesAllProvider.future);
      if (!context.mounted) return;

      final pick = prepararPickParaSheet(
        all: all,
        careerId: careerId,
        materia: materia,
        mapaPlan: mapaPlan,
        fromColoquios: fromColoquios,
      );

      await nav.push(
        RouteSheetExamenes(
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

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e0', 'a')
        .replaceAll('\u00e4', 'a')
        .replaceAll('\u00e2', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00e8', 'e')
        .replaceAll('\u00eb', 'e')
        .replaceAll('\u00ea', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00ec', 'i')
        .replaceAll('\u00ef', 'i')
        .replaceAll('\u00ee', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00f2', 'o')
        .replaceAll('\u00f6', 'o')
        .replaceAll('\u00f4', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00f9', 'u')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00fb', 'u')
        .replaceAll('\u00f1', 'n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<SeccionDeLista> _filtrarSecciones(List<SeccionDeLista> secciones) {
    final q = _normalize(_searchQuery);

    return secciones
        .map((s) {
          final materias = s.materias.where((m) {
            if (_yearFilter != null) {
              final anio = m.anioPlan;
              if (anio != _yearFilter) return false;
            }

            if (q.isEmpty) return true;
            final source = _normalize(
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

  InputDecoration _searchDecoration(
    BuildContext context, {
    required String hintText,
    VoidCallback? onClear,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _searchQuery.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Limpiar búsqueda',
              onPressed: onClear,
            ),
      isDense: true,
      filled: true,
      fillColor: isDarkTheme ? cs.surface : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: cs.outline.withValues(alpha: 0.22),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: cs.outline.withValues(alpha: 0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: cs.primary.withValues(alpha: 0.26),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher({
    required BuildContext context,
    required ExamenesViewMode mode,
  }) {
    return SegmentedButton<ExamenesViewMode>(
      segments: const [
        ButtonSegment(
          value: ExamenesViewMode.resumen,
          label: Text('Resumen'),
          icon: Icon(Icons.dashboard_outlined),
        ),
        ButtonSegment(
          value: ExamenesViewMode.jerarquico,
          label: Text('Jerárquico'),
          icon: Icon(Icons.account_tree_outlined),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        final nextMode = selection.first;
        ref.read(examenesViewModeProvider.notifier).state = nextMode;
        if (nextMode == ExamenesViewMode.jerarquico) {
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
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isZeus =
        ref.watch(examenesStyleModeProvider) == ExamenesStyleMode.zeus;

    final careerId = ref.watch(examenesCareerIdProvider);
    final examCareerOptions = kCareers
        .where(
          (c) =>
              c.id == 'historia' || c.id == 'geografia' || c.id == 'politica',
        )
        .toList();
    final examenesAsync = ref.watch(examenesFiltradosProvider);
    final planMapaAsync = ref.watch(planMapaMateriasProvider(careerId));

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
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? cs.surface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? cs.outlineVariant
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lectura situada de mesas y llamados',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Esta pantalla no reemplaza cronogramas de cátedra ni avisos institucionales. Sirve para cruzar el plan con fechas publicadas, coloquios y movimientos concretos de cursada.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDark ? cs.surface : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? cs.outlineVariant
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: careerId,
                                  isExpanded: true,
                                  menuWidth: constraints.maxWidth,
                                  menuMaxHeight: 400,
                                  dropdownColor:
                                      isDark ? cs.surface : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  itemHeight: 48,
                                  selectedItemBuilder: (context) {
                                    return examCareerOptions.map((career) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: _careerLabel(
                                          career,
                                          textColor: cs.onSurface,
                                          iconSize: 22,
                                          gap: 8,
                                          iconShiftX: -4,
                                        ),
                                      );
                                    }).toList(growable: false);
                                  },
                                  items: examCareerOptions
                                      .map(
                                        (career) => DropdownMenuItem<String>(
                                          value: career.id,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: _careerLabel(
                                                  career,
                                                  textColor: cs.onSurface,
                                                  iconSize: 22,
                                                  gap: 8,
                                                  iconShiftX: -4,
                                                ),
                                              ),
                                              if (career.id == careerId) ...[
                                                Icon(
                                                  Icons.check_rounded,
                                                  size: 18,
                                                  color: cs.primary,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      _yearFilter = null;
                                      _scope = 'todos';
                                    });
                                    ref
                                        .read(
                                          examenesCareerIdProvider.notifier,
                                        )
                                        .state = v;
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (_) {
                            _debounce?.cancel();
                            _debounce =
                                Timer(const Duration(milliseconds: 200), () {
                              if (mounted) {
                                setState(() => _searchQuery = _searchCtrl.text);
                              }
                            });
                          },
                          decoration: _searchDecoration(
                            context,
                            hintText: 'Buscar materia, código o tramo...',
                            onClear: () {
                              _debounce?.cancel();
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _chip(
                                context: context,
                                label: 'Todos',
                                selected: _scope == 'todos',
                                onTap: () => setState(() => _scope = 'todos'),
                              ),
                              const SizedBox(width: 8),
                              _chip(
                                context: context,
                                label: 'Mesas',
                                selected: _scope == 'llamados',
                                onTap: () =>
                                    setState(() => _scope = 'llamados'),
                              ),
                              const SizedBox(width: 8),
                              _chip(
                                context: context,
                                label: 'Coloquios',
                                selected: _scope == 'coloquios',
                                onTap: () =>
                                    setState(() => _scope = 'coloquios'),
                              ),
                              const SizedBox(width: 12),
                              _chip(
                                context: context,
                                label: 'Año: todos',
                                selected: _yearFilter == null,
                                onTap: () => setState(() => _yearFilter = null),
                              ),
                              for (final y in [1, 2, 3, 4]) ...[
                                const SizedBox(width: 8),
                                _chip(
                                  context: context,
                                  label: '$y°',
                                  selected: _yearFilter == y,
                                  onTap: () => setState(() => _yearFilter = y),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          _openMateriaSheet(
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
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isZeus =
        ref.watch(examenesStyleModeProvider) == ExamenesStyleMode.zeus;

    final careerId = ref.watch(examenesCareerIdProvider);
    final examenesAsync = ref.watch(examenesAllProvider);
    final planMapaAsync = ref.watch(planMapaMateriasProvider(careerId));

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
                    mode: ExamenesViewMode.jerarquico,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? cs.surface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? cs.outlineVariant
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: careers
                              .map(
                                (career) => ChoiceChip(
                                  label: Text(career.nombre),
                                  selected: career.id == careerId,
                                  onSelected: (_) {
                                    ref
                                        .read(examenesCareerIdProvider.notifier)
                                        .state = career.id;
                                    setState(() {
                                      _yearFilter = null;
                                      _scope = 'todos';
                                    });
                                  },
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _chip(
                                context: context,
                                label: 'Todos',
                                selected: _scope == 'todos',
                                onTap: () => setState(() => _scope = 'todos'),
                              ),
                              const SizedBox(width: 8),
                              _chip(
                                context: context,
                                label: 'Llamados',
                                selected: _scope == 'llamados',
                                onTap: () =>
                                    setState(() => _scope = 'llamados'),
                              ),
                              const SizedBox(width: 8),
                              _chip(
                                context: context,
                                label: 'Coloquios',
                                selected: _scope == 'coloquios',
                                onTap: () =>
                                    setState(() => _scope = 'coloquios'),
                              ),
                              const SizedBox(width: 12),
                              _chip(
                                context: context,
                                label: 'Año: todos',
                                selected: _yearFilter == null,
                                onTap: () => setState(() => _yearFilter = null),
                              ),
                              for (final y in [1, 2, 3, 4]) ...[
                                const SizedBox(width: 8),
                                _chip(
                                  context: context,
                                  label: '$y\u00ba',
                                  selected: _yearFilter == y,
                                  onTap: () => setState(() => _yearFilter = y),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
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
                          _openMateriaSheet(
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
        ref.watch(examenesStyleModeProvider) == ExamenesStyleMode.zeus;

    final careerId = ref.watch(examenesCareerIdProvider);
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
    final examenesAsync = ref.watch(examenesFiltradosProvider);
    final planMapaAsync = ref.watch(planMapaMateriasProvider(careerId));

    return Row(
      children: [
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B1220) : Colors.white,
            border: Border(
              right: BorderSide(
                color:
                    isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendario académico',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mesas y exámenes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DesktopSearchField(
                    controller: _searchCtrl,
                    query: _searchQuery,
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 160), () {
                        if (mounted) setState(() => _searchQuery = value);
                      });
                    },
                    onClear: () {
                      _debounce?.cancel();
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Carrera',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...examCareerOptions.map(
                    (career) => _DesktopCareerButton(
                      career: career,
                      selected: career.id == careerId,
                      onTap: () {
                        setState(() {
                          _yearFilter = null;
                          _scope = 'todos';
                        });
                        ref.read(examenesCareerIdProvider.notifier).state =
                            career.id;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Tipo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DesktopScopeButton(
                    label: 'Todos',
                    icon: Icons.select_all_rounded,
                    selected: _scope == 'todos',
                    onTap: () => setState(() => _scope = 'todos'),
                  ),
                  _DesktopScopeButton(
                    label: 'Mesas',
                    icon: Icons.event_available_outlined,
                    selected: _scope == 'llamados',
                    onTap: () => setState(() => _scope = 'llamados'),
                  ),
                  _DesktopScopeButton(
                    label: 'Coloquios',
                    icon: Icons.forum_outlined,
                    selected: _scope == 'coloquios',
                    onTap: () => setState(() => _scope = 'coloquios'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Año',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DesktopYearButton(
                        label: 'Todos',
                        selected: _yearFilter == null,
                        onTap: () => setState(() => _yearFilter = null),
                      ),
                      for (final year in [1, 2, 3, 4])
                        _DesktopYearButton(
                          label: '$year°',
                          selected: _yearFilter == year,
                          onTap: () => setState(() => _yearFilter = year),
                        ),
                    ],
                  ),
                  const Spacer(),
                  _DesktopSideNote(isDark: isDark),
                ],
              ),
            ),
          ),
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
                              return _DesktopEmptyState(
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
                                _DesktopSummaryStrip(
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
                                    _openMateriaSheet(
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

  Widget _chip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
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

  Widget _careerLabel(
    CareerInfo career, {
    required Color textColor,
    double iconSize = 22,
    double gap = 8,
    double iconShiftX = 0,
  }) {
    final hasIcon = career.iconAsset != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) ...[
          Transform.translate(
            offset: Offset(iconShiftX, 0),
            child: Container(
              width: iconSize,
              height: iconSize,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(
                career.iconAsset!,
                fit: BoxFit.cover,
                cacheWidth: 64,
                cacheHeight: 64,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.school_rounded,
                  size: iconSize - 4,
                  color: textColor,
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
        ],
        Flexible(
          child: Text(
            career.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final styleMode = ref.watch(examenesStyleModeProvider);
    final isZeus = styleMode == ExamenesStyleMode.zeus;
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

class _DesktopSearchField extends StatelessWidget {
  const _DesktopSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar materia o tramo',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                tooltip: 'Limpiar b?squeda',
                icon: const Icon(Icons.close_rounded),
              ),
        isDense: true,
        filled: true,
        fillColor: isDarkTheme ? cs.surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: cs.outline.withValues(alpha: 0.22),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: cs.outline.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: cs.primary.withValues(alpha: 0.26),
          ),
        ),
      ),
    );
  }
}

class _DesktopCareerButton extends StatelessWidget {
  const _DesktopCareerButton({
    required this.career,
    required this.selected,
    required this.onTap,
  });

  final CareerInfo career;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 19,
                  color: selected ? theme.colorScheme.primary : theme.hintColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    career.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                      color: selected ? theme.colorScheme.primary : null,
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

class _DesktopScopeButton extends StatelessWidget {
  const _DesktopScopeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(42),
          alignment: Alignment.centerLeft,
          backgroundColor: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.10)
              : null,
          foregroundColor: selected ? theme.colorScheme.primary : null,
          side: BorderSide(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.28)
                : theme.colorScheme.outlineVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _DesktopYearButton extends StatelessWidget {
  const _DesktopYearButton({
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.primary : null,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _DesktopSideNote extends StatelessWidget {
  const _DesktopSideNote({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Los filtros quedan fijos para trabajar con muchas materias sin volver arriba.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSummaryStrip extends StatelessWidget {
  const _DesktopSummaryStrip({
    required this.secciones,
    required this.proximos,
    required this.scope,
    required this.yearFilter,
  });

  final List<SeccionDeLista> secciones;
  final List<MateriaParaLista> proximos;
  final String scope;
  final int? yearFilter;

  @override
  Widget build(BuildContext context) {
    final total = secciones.fold<int>(
      0,
      (count, section) => count + section.materias.length,
    );
    final mesas = secciones
        .where((section) => !section.esColoquios)
        .fold<int>(0, (count, section) => count + section.materias.length);
    final coloquios = secciones
        .where((section) => section.esColoquios)
        .fold<int>(0, (count, section) => count + section.materias.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          _DesktopMetric(
            label: 'Resultados',
            value: total.toString(),
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(width: 10),
          _DesktopMetric(
            label: 'Mesas',
            value: mesas.toString(),
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(width: 10),
          _DesktopMetric(
            label: 'Coloquios',
            value: coloquios.toString(),
            icon: Icons.forum_outlined,
          ),
          const SizedBox(width: 10),
          _DesktopMetric(
            label: yearFilter == null ? 'Próximos' : 'Año filtrado',
            value: yearFilter == null
                ? proximos.length.toString()
                : '$yearFilter°',
            icon: yearFilter == null
                ? Icons.upcoming_outlined
                : Icons.filter_alt_outlined,
          ),
        ],
      ),
    );
  }
}

class _DesktopMetric extends StatelessWidget {
  const _DesktopMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopEmptyState extends StatelessWidget {
  const _DesktopEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 52,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
