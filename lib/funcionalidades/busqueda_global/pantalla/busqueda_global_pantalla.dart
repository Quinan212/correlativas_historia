import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../../modelos/materia.dart';

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final normalized = _normalizeQuery(_query);

    final carreras = ref.watch(proveedorCarreras);
    final planAsync = ref.watch(proveedorPlan);

    final carreraResults = _rankCarreras(normalized, carreras);
    final materiaResults = planAsync.maybeWhen(
      data: (plan) => _rankMaterias(normalized, plan.materias),
      orElse: () => const <_ScoredMateria>[],
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar materias, códigos, carreras...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar búsqueda',
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                        _focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0A1728) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF243041)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF243041)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: normalized.isEmpty
            ? _emptyBody(cs)
            : _resultsBody(cs, normalized, carreraResults, materiaResults),
      ),
    );
  }

  Widget _emptyBody(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          '¿Qué buscás?',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Escribí el nombre de una materia, su código, una carrera...',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Text(
          'Carreras',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        _buildCarrerasSugeridas(cs),
        const SizedBox(height: 18),
        Text(
          'Sugerencias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'Historia 3er año',
                    'Correlativas de Historia',
                    'Carrera de Geografía',
                    'Práctica Docente',
                    'Correlativas detalladas',
                    'Historia del Arte',
                  ]
                  .map((label) {
                    return ActionChip(
                      avatar: const Icon(Icons.north_west_rounded, size: 17),
                      label: Text(label),
                      onPressed: () {
                        _controller.text = label;
                        _controller.selection = TextSelection.collapsed(
                          offset: label.length,
                        );
                        setState(() => _query = label);
                        _focusNode.requestFocus();
                      },
                    );
                  })
                  .toList(growable: false),
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFFEFF6EE),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF0E5E86)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La búsqueda entiende abreviaturas, palabras incompletas, tildes y errores frecuentes de escritura.',
                    style: TextStyle(color: Color(0xFF050816)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrerasSugeridas(ColorScheme cs) {
    final carreras = ref.watch(proveedorCarreras);
    final featured = carreras.where((c) => !c.hidden).take(6).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final width = constraints.maxWidth >= 560
            ? (constraints.maxWidth - spacing * 2) / 3
            : (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: featured
              .map(
                (c) => SizedBox(
                  width: width,
                  child: _CarreraSugeridaCard(
                    carrera: c,
                    onTap: () {
                      _controller.text = c.nombre;
                      _controller.selection = TextSelection.collapsed(
                        offset: c.nombre.length,
                      );
                      setState(() => _query = c.nombre);
                      _focusNode.requestFocus();
                    },
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _resultsBody(
    ColorScheme cs,
    String normalized,
    List<_ScoredCarrera> carreraResults,
    List<_ScoredMateria> materiaResults,
  ) {
    final total = carreraResults.length + materiaResults.length;
    if (total == 0) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 52),
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Color(0xFF5F7289),
          ),
          const SizedBox(height: 12),
          const Text(
            'No encontramos coincidencias',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Probá con palabras más generales: "historia", "correlativas", "carrera", "código"...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF5F7289)),
          ),
        ],
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(
          total == 1 ? '1 resultado' : '$total resultados',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        if (carreraResults.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _ResultHeading('Carreras'),
          const SizedBox(height: 8),
          ...carreraResults
              .take(8)
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CarreraResultCard(carrera: r.carrera),
                ),
              ),
        ],
        if (materiaResults.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _ResultHeading('Materias'),
          const SizedBox(height: 8),
          ...materiaResults
              .take(20)
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MateriaResultCard(
                    materia: r.materia,
                    onTap: () => _abrirDetalleMateria(r.materia),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  void _abrirDetalleMateria(Materia materia) {
    Navigator.of(context).pop();
  }

  // Normalización de consulta
  String _normalizeQuery(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúüñ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Ranking de carreras
  List<_ScoredCarrera> _rankCarreras(String query, List<CareerInfo> carreras) {
    if (query.isEmpty) return const [];
    final results = <_ScoredCarrera>[];
    for (final c in carreras) {
      final score = _scoreText(
        query,
        '${c.nombre} ${c.id} ${c.categoria} ${c.assetHtml}',
      );
      if (score >= _minimumScore(query)) {
        results.add(_ScoredCarrera(c, score));
      }
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  // Ranking de materias
  List<_ScoredMateria> _rankMaterias(String query, List<Materia> materias) {
    if (query.isEmpty) return const [];
    final results = <_ScoredMateria>[];
    for (final m in materias) {
      final text = [
        m.nombre,
        m.codigo,
        m.tipo,
        m.formato,
        m.correlativas.join(' '),
        m.horas ?? '',
      ].join(' ');
      final score = _scoreText(query, text);
      if (score >= _minimumScore(query)) {
        results.add(_ScoredMateria(m, score));
      }
    }
    results.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.materia.nombre.compareTo(b.materia.nombre);
    });
    return results;
  }

  int _minimumScore(String query) {
    if (query.length <= 2) return 22;
    if (query.length <= 4) return 26;
    return 30;
  }

  int _scoreText(String rawQuery, String rawTarget) {
    final query = _normalizeQuery(rawQuery);
    final target = _normalizeQuery(rawTarget);
    if (query.isEmpty || target.isEmpty) return 0;

    var score = 0;
    if (target == query) score += 180;
    if (target.startsWith(query)) score += 90;
    if (target.contains(query)) score += 72;

    final queryTokens = query.split(' ').where((t) => t.isNotEmpty).toList();
    final targetTokens = target.split(' ').where((t) => t.isNotEmpty).toList();
    var matchedTokens = 0;

    for (final qt in queryTokens) {
      var best = 0;
      for (final tt in targetTokens) {
        if (tt == qt) {
          best = math.max(best, 38);
        } else if (tt.startsWith(qt)) {
          best = math.max(best, qt.length <= 2 ? 24 : 31);
        } else if (qt.startsWith(tt) && tt.length >= 3) {
          best = math.max(best, 20);
        } else if (qt.length >= 4 && tt.length >= 4) {
          final dist = _levenshtein(qt, tt);
          if (dist == 1) {
            best = math.max(best, 22);
          } else if (dist == 2 && qt.length >= 6) {
            best = math.max(best, 13);
          }
        }
      }
      if (best > 0) matchedTokens++;
      score += best;
    }

    final tokenCount = queryTokens.length;
    if (tokenCount > 1 && matchedTokens == tokenCount) score += 42;
    if (tokenCount > 1 && matchedTokens < tokenCount) score -= 18;
    return score;
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = List<int>.filled(b.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final insertion = current[j] + 1;
        final deletion = previous[j + 1] + 1;
        final substitution =
            previous[j] + (a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1);
        current[j + 1] = math
            .min(insertion, math.min(deletion, substitution))
            .toInt();
      }
      previous = current;
    }
    return previous.last;
  }
}

// ===== Modelos de resultados =====

class _ScoredCarrera {
  const _ScoredCarrera(this.carrera, this.score);
  final CareerInfo carrera;
  final int score;
}

class _ScoredMateria {
  const _ScoredMateria(this.materia, this.score);
  final Materia materia;
  final int score;
}

// ===== Widgets de UI =====

class _ResultHeading extends StatelessWidget {
  const _ResultHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
      ),
    );
  }
}

class _CarreraSugeridaCard extends StatelessWidget {
  const _CarreraSugeridaCard({required this.carrera, required this.onTap});

  final CareerInfo carrera;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_rounded, color: Color(0xFF0E5E86)),
              const SizedBox(height: 14),
              Text(
                carrera.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarreraResultCard extends StatelessWidget {
  const _CarreraResultCard({required this.carrera});

  final CareerInfo carrera;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEFF6EE),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: carrera.iconAsset != null
                      ? Image.asset(carrera.iconAsset!, fit: BoxFit.contain)
                      : const Icon(
                          Icons.school_rounded,
                          color: Color(0xFF0E5E86),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carrera.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E5E86),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(carrera.categoria),
                      const SizedBox(height: 3),
                      Text(
                        carrera.id,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F7269),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    // TODO: navegar a la carrera
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Ver carrera'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MateriaResultCard extends StatelessWidget {
  const _MateriaResultCard({required this.materia, required this.onTap});

  final Materia materia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconForTipo(materia.tipo),
                      color: const Color(0xFF0E5E86),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materia.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E5E86),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          materia.codigo,
                          style: const TextStyle(
                            color: Color(0xFF5F7269),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Ver detalle',
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF0E5E86),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _buildMateriaSubtitle(materia),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildMateriaSubtitle(Materia m) {
    final parts = <String>['${m.anio}° año', m.tipo];
    if (m.cuatri != null) parts.add('${m.cuatri}° cuatrimestre');
    if (m.horas != null) parts.add('${m.horas} hs');
    return parts.join(' · ');
  }

  IconData _iconForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'anual':
        return Icons.calendar_today_rounded;
      case 'cuatrimestral':
        return Icons.event_rounded;
      case 'práctica':
      case 'practica':
        return Icons.school_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}
