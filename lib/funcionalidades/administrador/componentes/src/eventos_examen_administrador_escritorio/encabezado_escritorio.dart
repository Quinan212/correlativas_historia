part of '../../eventos_examen_administrador_escritorio.dart';

class _EncabezadoEscritorio extends StatelessWidget {
  const _EncabezadoEscritorio({
    required this.scope,
    required this.selectedCareerName,
    required this.selectedYear,
    required this.searchCtrl,
    required this.busy,
    required this.stats,
    required this.visibleCount,
    required this.onScopeChanged,
    required this.onYearChanged,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onNew,
  });

  final String scope;
  final String selectedCareerName;
  final int? selectedYear;
  final TextEditingController searchCtrl;
  final bool busy;
  final _EstadisticasEventosExamen stats;
  final int visibleCount;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scopeLabel = scope == 'mesas' ? 'mesas' : 'coloquios';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de mesas y coloquios',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$selectedCareerName · $visibleCount $scopeLabel visibles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: busy ? null : onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Actualizar',
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: busy ? null : onNew,
                icon: const Icon(Icons.add_rounded),
                label: Text(scope == 'mesas' ? 'Nueva mesa' : 'Nuevo coloquio'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TabsAlcance(scope: scope, onChanged: onScopeChanged),
              const SizedBox(width: 12),
              _FiltroAnio(value: selectedYear, onChanged: onYearChanged),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoBusqueda(
                  controller: searchCtrl,
                  onChanged: onSearchChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _TarjetaMetrica(
                label: 'Mesas',
                value: stats.totalMesas.toString(),
                icon: Icons.event_available_outlined,
              ),
              const SizedBox(width: 10),
              _TarjetaMetrica(
                label: 'Coloquios',
                value: stats.totalColoquios.toString(),
                icon: Icons.forum_outlined,
              ),
              const SizedBox(width: 10),
              _TarjetaMetrica(
                label: 'Sin fecha',
                value: stats.withoutDate.toString(),
                icon: Icons.event_busy_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabsAlcance extends StatelessWidget {
  const _TabsAlcance({required this.scope, required this.onChanged});

  final String scope;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'mesas',
          icon: Icon(Icons.event_available_outlined),
          label: Text('Mesas'),
        ),
        ButtonSegment(
          value: 'coloquios',
          icon: Icon(Icons.forum_outlined),
          label: Text('Coloquios'),
        ),
      ],
      selected: {scope},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}

class _FiltroAnio extends StatelessWidget {
  const _FiltroAnio({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<int?>(
        initialValue: value,
        decoration: const InputDecoration(
          labelText: 'Año',
          isDense: true,
        ),
        items: const [
          DropdownMenuItem<int?>(child: Text('Todos')),
          DropdownMenuItem<int?>(value: 1, child: Text('1er año')),
          DropdownMenuItem<int?>(value: 2, child: Text('2do año')),
          DropdownMenuItem<int?>(value: 3, child: Text('3er año')),
          DropdownMenuItem<int?>(value: 4, child: Text('4to año')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _CampoBusqueda extends StatelessWidget {
  const _CampoBusqueda({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        hintText: 'Buscar por materia, docente o carrera',
        isDense: true,
      ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
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
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          ),
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
