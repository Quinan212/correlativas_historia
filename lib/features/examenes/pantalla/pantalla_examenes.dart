import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/providers/app_state.dart';
import '../../../shared/widgets/career_option_label.dart';
import '../providers/examenes_providers.dart';
import '../providers/plan_providers.dart';
import 'examenes_visibility.dart';
import 'logica_examenes.dart';
import 'sheet/route_sheet_examenes.dart';
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<SeccionDeLista> _filtrarSecciones(List<SeccionDeLista> secciones) {
    final q = _normalize(_searchCtrl.text);

    bool passScope(SeccionDeLista s) {
      if (_scope == 'llamados') return !s.esColoquios;
      if (_scope == 'coloquios') return s.esColoquios;
      return true;
    }

    return secciones
        .where(passScope)
        .map((s) {
          final materias = s.materias.where((m) {
            if (_yearFilter != null && !s.esColoquios) {
              final anio = m.anioPlan;
              if (anio != _yearFilter) return false;
            }

            if (q.isEmpty) return true;
            final source = _normalize(
              '${m.nombreMostrable} ${m.codigo} ${m.tipo} ${m.formato}',
            );
            return source.contains(q);
          }).toList();

          return SeccionDeLista(
            titulo: s.titulo,
            materias: materias,
            esColoquios: s.esColoquios,
          );
        })
        .where((s) => s.materias.isNotEmpty)
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
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final careerId = ref.watch(examenesCareerIdProvider);
    final examCareerOptions = kCareers
        .where((c) =>
            c.id == 'historia' || c.id == 'geografia' || c.id == 'politica')
        .toList();
    final examenesAsync = ref.watch(examenesFiltradosProvider);
    final planMapaAsync = ref.watch(planMapaMateriasProvider(careerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mesas y exámenes')),
      backgroundColor: isDark ? cs.surface : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? cs.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
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
                      ref.read(examenesCareerIdProvider.notifier).state = v;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Buscar materia, código o tramo...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
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
                          label: 'Llamados',
                          selected: _scope == 'llamados',
                          onTap: () => setState(() => _scope = 'llamados'),
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          context: context,
                          label: 'Coloquios',
                          selected: _scope == 'coloquios',
                          onTap: () => setState(() => _scope = 'coloquios'),
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
                          'lista-$careerId-$_scope-${_yearFilter ?? 0}-${_searchCtrl.text}'),
                      careerId: careerId,
                      secciones: filtradas,
                      proximos: proximos,
                      examsHiddenMode: kOcultarExamenesPublicados,
                      hiddenModeMessage: kMensajeProximasMesas,
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
}
