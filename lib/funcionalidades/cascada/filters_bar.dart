import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../modelos/materia.dart';
import '../../compartido/proveedores/estado_app.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBarRow(key: ValueKey('search-row')),
        SizedBox(height: 16),
        FilaEtiquetasFiltros(key: ValueKey('filters-chips')),
      ],
    );
  }
}

class _EtiquetaFiltro extends StatelessWidget {
  const _EtiquetaFiltro({
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
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.10)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.20)
                  : theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class FilaEtiquetasFiltros extends ConsumerWidget {
  const FilaEtiquetasFiltros({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);

    final planAsync = ref.watch(proveedorPlan);
    final plan = planAsync.valueOrNull;
    final materias = plan == null ? const <Materia>[] : plan.materias;

    final tiposDisponibles = materias
        .map((m) => m.tipo.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final aniosDisponibles = materias
        .map((m) => m.anio)
        .where((y) => y > 0)
        .toSet()
        .toList()
      ..sort();
    final anios =
        aniosDisponibles.isEmpty ? <int>[1, 2, 3, 4] : aniosDisponibles;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _EtiquetaFiltro(
            label: 'Todos',
            selected: anio == null && tipo == 'todos',
            onTap: () {
              ref.read(filtroAnioProvider.notifier).state = null;
              ref.read(filtroTipoProvider.notifier).state = 'todos';
            },
          ),
          const SizedBox(width: 8),
          for (final y in anios) ...[
            _EtiquetaFiltro(
              label: '$y° año',
              selected: anio == y,
              onTap: () {
                if (anio == y) {
                  ref.read(filtroAnioProvider.notifier).state = null;
                } else {
                  ref.read(filtroAnioProvider.notifier).state = y;
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          for (final t in tiposDisponibles) ...[
            _EtiquetaFiltro(
              label: t,
              selected: tipo == t,
              onTap: () {
                if (tipo == t) {
                  ref.read(filtroTipoProvider.notifier).state = 'todos';
                } else {
                  ref.read(filtroTipoProvider.notifier).state = t;
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class SearchBarRow extends ConsumerStatefulWidget {
  const SearchBarRow({super.key});

  @override
  ConsumerState<SearchBarRow> createState() => _SearchBarRowState();
}

class _SearchBarRowState extends ConsumerState<SearchBarRow> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl =
        TextEditingController(text: ref.read(proveedorTerminoBusqueda));
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text;
      if (ref.read(proveedorTerminoBusqueda) != v) {
        ref.read(proveedorTerminoBusqueda.notifier).state = v;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _circleIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
            ),
            boxShadow: const [
              BoxShadow(blurRadius: 4, color: Color(0x0A000000)),
            ],
          ),
          child: Icon(icon, size: 22, color: cs.onSurface),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(proveedorModoTema);
    final isDark = themeMode == ThemeMode.dark;
    final downloadUrl = ref.watch(proveedorUrlDescargaCarrera);

    ref.listen<String>(proveedorTerminoBusqueda, (prev, next) {
      if (_searchCtrl.text != next) {
        _searchCtrl.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar materia...',
              prefixIcon: const Icon(Icons.search_rounded),
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
          ),
        ),
        const SizedBox(width: 10),
        _circleIconButton(
          context: context,
          tooltip: 'Descargar',
          icon: Icons.download_rounded,
          onTap: () async {
            final uri = Uri.parse(downloadUrl);
            final ok = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No se pudo abrir: $uri')),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        _circleIconButton(
          context: context,
          tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          onTap: () {
            ref.read(proveedorModoTema.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
      ],
    );
  }
}
