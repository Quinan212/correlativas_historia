part of 'lista_materias.dart';

class _Seccion extends StatelessWidget {
  const _Seccion({
    super.key,
    required this.careerId,
    required this.titulo,
    required this.materias,
    required this.esColoquios,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.isZeus,
    required this.onTapMateria,
  });

  final String careerId;
  final String titulo;
  final List<MateriaParaLista> materias;
  final bool esColoquios;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final bool isZeus;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isZeus ? 6 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isZeus)
            Container(
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: isDark
                      ? cs.primary.withValues(alpha: 0.18)
                      : const Color(0xFFDBEAFE),
                ),
                child: Text(
                  '${materias.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? cs.onSurface : const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isZeus ? 12 : 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 980;
              if (!isDesktop) {
                return Column(
                  children: [
                    for (var i = 0; i < materias.length; i++) ...[
                      _TarjetaMateria(
                        careerId: careerId,
                        item: materias[i],
                        examsHiddenMode: examsHiddenMode,
                        hiddenModeMessage: hiddenModeMessage,
                        isZeus: isZeus,
                        onTap: () => onTapMateria(
                          materias[i].nombreEvento,
                          esColoquios,
                        ),
                      ),
                      if (i != materias.length - 1)
                        SizedBox(height: isZeus ? 12 : 10),
                    ],
                  ],
                );
              }

              final spacing = isZeus ? 12.0 : 10.0;
              final rawCols = constraints.maxWidth >= 1800
                  ? 4
                  : (constraints.maxWidth >= 1320
                      ? 3
                      : (constraints.maxWidth >= 900
                          ? 2
                          : (constraints.maxWidth >= 480 ? 2 : 1)));
              final cols = math.max(
                1,
                math.min(rawCols, materias.isEmpty ? 1 : materias.length),
              );
              final cardWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in materias)
                    SizedBox(
                      width: cardWidth,
                      child: _TarjetaMateria(
                        careerId: careerId,
                        item: item,
                        examsHiddenMode: examsHiddenMode,
                        hiddenModeMessage: hiddenModeMessage,
                        isZeus: isZeus,
                        onTap: () =>
                            onTapMateria(item.nombreEvento, esColoquios),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
