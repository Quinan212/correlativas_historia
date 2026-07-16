import 'package:flutter/material.dart';

import '../../../compartido/proveedores/estado_app.dart';
import 'logica_examenes.dart';

class CampoBusquedaEscritorio extends StatelessWidget {
  const CampoBusquedaEscritorio({
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
                tooltip: 'Limpiar búsqueda',
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

class BotonCarreraEscritorio extends StatelessWidget {
  const BotonCarreraEscritorio({
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

class BotonAlcanceEscritorio extends StatelessWidget {
  const BotonAlcanceEscritorio({
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

class BotonAnioEscritorio extends StatelessWidget {
  const BotonAnioEscritorio({
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

class BarraLateralEscritorioExamenes extends StatelessWidget {
  const BarraLateralEscritorioExamenes({
    required this.searchCtrl,
    required this.searchQuery,
    required this.scope,
    required this.yearFilter,
    required this.careerId,
    required this.careerOptions,
    required this.isDark,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTapCareer,
    required this.onTapScope,
    required this.onTapYear,
  });

  final TextEditingController searchCtrl;
  final String searchQuery;
  final String scope;
  final int? yearFilter;
  final String careerId;
  final List<CareerInfo> careerOptions;
  final bool isDark;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onTapCareer;
  final ValueChanged<String> onTapScope;
  final ValueChanged<int?> onTapYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
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
              CampoBusquedaEscritorio(
                controller: searchCtrl,
                query: searchQuery,
                onChanged: onSearchChanged,
                onClear: onClearSearch,
              ),
              const SizedBox(height: 18),
              Text(
                'Carrera',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ...careerOptions.map(
                (career) => BotonCarreraEscritorio(
                  career: career,
                  selected: career.id == careerId,
                  onTap: () => onTapCareer(career.id),
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
              BotonAlcanceEscritorio(
                label: 'Todos',
                icon: Icons.select_all_rounded,
                selected: scope == 'todos',
                onTap: () => onTapScope('todos'),
              ),
              BotonAlcanceEscritorio(
                label: 'Mesas',
                icon: Icons.event_available_outlined,
                selected: scope == 'llamados',
                onTap: () => onTapScope('llamados'),
              ),
              BotonAlcanceEscritorio(
                label: 'Coloquios',
                icon: Icons.forum_outlined,
                selected: scope == 'coloquios',
                onTap: () => onTapScope('coloquios'),
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
                  BotonAnioEscritorio(
                    label: 'Todos',
                    selected: yearFilter == null,
                    onTap: () => onTapYear(null),
                  ),
                  for (final year in [1, 2, 3, 4])
                    BotonAnioEscritorio(
                      label: '$year°',
                      selected: yearFilter == year,
                      onTap: () => onTapYear(year),
                    ),
                ],
              ),
              const Spacer(),
              NotaLateralEscritorio(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class NotaLateralEscritorio extends StatelessWidget {
  const NotaLateralEscritorio({required this.isDark});

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

class ResumenEscritorio extends StatelessWidget {
  const ResumenEscritorio({
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
          _MetricaEscritorio(
            label: 'Resultados',
            value: total.toString(),
            icon: Icons.list_alt_rounded,
          ),
          const SizedBox(width: 10),
          _MetricaEscritorio(
            label: 'Mesas',
            value: mesas.toString(),
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(width: 10),
          _MetricaEscritorio(
            label: 'Coloquios',
            value: coloquios.toString(),
            icon: Icons.forum_outlined,
          ),
          const SizedBox(width: 10),
          _MetricaEscritorio(
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

class _MetricaEscritorio extends StatelessWidget {
  const _MetricaEscritorio({
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

class EstadoVacioEscritorio extends StatelessWidget {
  const EstadoVacioEscritorio({required this.message});

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
