import 'package:flutter/material.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../componentes/chip_filtro_examenes.dart';
import '../componentes/etiqueta_carrera_examenes.dart';

class BarraFiltrosExamenes extends StatelessWidget {
  const BarraFiltrosExamenes({
    required this.careerId,
    required this.searchController,
    required this.searchQuery,
    required this.scope,
    required this.yearFilter,
    required this.onCareerChanged,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onScopeChanged,
    required this.onYearChanged,
  });

  final String careerId;
  final TextEditingController searchController;
  final String searchQuery;
  final String scope;
  final int? yearFilter;
  final ValueChanged<String> onCareerChanged;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<int?> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final examCareerOptions = kCareers
        .where(
          (c) =>
              c.id == 'historia' ||
              c.id == 'geografia' ||
              c.id == 'politica' ||
              c.id == 'musica',
        )
        .toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? cs.surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: careerId,
                    isExpanded: true,
                    menuWidth: constraints.maxWidth,
                    menuMaxHeight: 400,
                    dropdownColor: isDark ? cs.surface : Colors.white,
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
                          child: EtiquetaCarreraExamenes(
                            career: career,
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
                                  child: EtiquetaCarreraExamenes(
                                    career: career,
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
                      onCareerChanged(v);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Buscar materia, código o tramo...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Limpiar búsqueda',
                      onPressed: onClearSearch,
                    ),
              isDense: true,
              filled: true,
              fillColor: isDark ? cs.surface : Colors.white,
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
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChipFiltroExamenes(
                  label: 'Todos',
                  selected: scope == 'todos',
                  onTap: () => onScopeChanged('todos'),
                ),
                const SizedBox(width: 8),
                ChipFiltroExamenes(
                  label: 'Mesas',
                  selected: scope == 'llamados',
                  onTap: () => onScopeChanged('llamados'),
                ),
                const SizedBox(width: 8),
                ChipFiltroExamenes(
                  label: 'Coloquios',
                  selected: scope == 'coloquios',
                  onTap: () => onScopeChanged('coloquios'),
                ),
                const SizedBox(width: 12),
                ChipFiltroExamenes(
                  label: 'Año: todos',
                  selected: yearFilter == null,
                  onTap: () => onYearChanged(null),
                ),
                for (final y in [1, 2, 3, 4]) ...[
                  const SizedBox(width: 8),
                  ChipFiltroExamenes(
                    label: '$y°',
                    selected: yearFilter == y,
                    onTap: () => onYearChanged(y),
                  ),
                ],
              ],
            ),
          ),
        ],
    );
  }
}

class PanelFiltrosJerarquicoExamenes extends StatelessWidget {
  const PanelFiltrosJerarquicoExamenes({
    required this.careers,
    required this.careerId,
    required this.scope,
    required this.yearFilter,
    required this.onTapCareer,
    required this.onTapScope,
    required this.onTapYear,
  });

  final List<CareerInfo> careers;
  final String careerId;
  final String scope;
  final int? yearFilter;
  final ValueChanged<String> onTapCareer;
  final ValueChanged<String> onTapScope;
  final ValueChanged<int?> onTapYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
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
                    onSelected: (_) => onTapCareer(career.id),
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
                ChipFiltroExamenes(
                  label: 'Todos',
                  selected: scope == 'todos',
                  onTap: () => onTapScope('todos'),
                ),
                const SizedBox(width: 8),
                ChipFiltroExamenes(
                  label: 'Llamados',
                  selected: scope == 'llamados',
                  onTap: () => onTapScope('llamados'),
                ),
                const SizedBox(width: 8),
                ChipFiltroExamenes(
                  label: 'Coloquios',
                  selected: scope == 'coloquios',
                  onTap: () => onTapScope('coloquios'),
                ),
                const SizedBox(width: 12),
                ChipFiltroExamenes(
                  label: 'Año: todos',
                  selected: yearFilter == null,
                  onTap: () => onTapYear(null),
                ),
                for (final y in [1, 2, 3, 4]) ...[
                  const SizedBox(width: 8),
                  ChipFiltroExamenes(
                    label: '$y°',
                    selected: yearFilter == y,
                    onTap: () => onTapYear(y),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


