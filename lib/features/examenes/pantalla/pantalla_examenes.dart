import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/career_option_label.dart';
import '../providers/examenes_providers.dart';
import '../providers/plan_providers.dart';
import 'examenes_visibility.dart';
import 'logica_examenes.dart';
import 'jerarquico_examenes_screen.dart';
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
        ),
      );
    } finally {
      _openingSheet = false;
    }
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã ', 'a')
        .replaceAll('Ã¤', 'a')
        .replaceAll('Ã¢', 'a')
        .replaceAll('Ã©', 'e')
        .replaceAll('Ã¨', 'e')
        .replaceAll('Ã«', 'e')
        .replaceAll('Ãª', 'e')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ã¬', 'i')
        .replaceAll('Ã¯', 'i')
        .replaceAll('Ã®', 'i')
        .replaceAll('Ã³', 'o')
        .replaceAll('Ã²', 'o')
        .replaceAll('Ã¶', 'o')
        .replaceAll('Ã´', 'o')
        .replaceAll('Ãº', 'u')
        .replaceAll('Ã¹', 'u')
        .replaceAll('Ã¼', 'u')
        .replaceAll('Ã»', 'u')
        .replaceAll('Ã±', 'n')
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
                children: [
                  _buildModeSwitcher(
                    context: context,
                    mode: ExamenesViewMode.resumen,
                  ),
                  const SizedBox(height: 12),
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
                          items: examCareerOptions
                              .map(
                                (career) => DropdownMenuItem<String>(
                                  value: career.id,
                                  child: CareerOptionLabel(
                                    career,
                                    iconSize: 30,
                                    iconShiftX: -6,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _yearFilter = null;
                              _scope = 'todos';
                            });
                            ref.read(examenesCareerIdProvider.notifier).state =
                                v;
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
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Buscar materia, código o tramo...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _debounce?.cancel();
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                        Text(
                          'Vista jerárquica',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Elegí una carrera, luego un año y después alterná entre mesas y coloquios.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 34,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _chip(
                                context: context,
                                label: 'Todos los años',
                                selected: _yearFilter == null,
                                onTap: () => setState(() => _yearFilter = null),
                              ),
                              for (final y in [1, 2, 3, 4]) ...[
                                const SizedBox(width: 8),
                                _chip(
                                  context: context,
                                  label: 'Año $y',
                                  selected: _yearFilter == y,
                                  onTap: () => setState(() => _yearFilter = y),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Mesas'),
                              selected: _scope == 'llamados',
                              onSelected: (_) =>
                                  setState(() => _scope = 'llamados'),
                            ),
                            ChoiceChip(
                              label: const Text('Coloquios'),
                              selected: _scope == 'coloquios',
                              onSelected: (_) =>
                                  setState(() => _scope = 'coloquios'),
                            ),
                          ],
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

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(examenesViewModeProvider);
    final styleMode = ref.watch(examenesStyleModeProvider);
    final isZeus = styleMode == ExamenesStyleMode.zeus;
    final topInset = MediaQuery.of(context).viewPadding.top;
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
              child: mode == ExamenesViewMode.resumen
                  ? _buildResumenMode(context, topInset)
                  : const ExamenesJerarquicoHome(),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
