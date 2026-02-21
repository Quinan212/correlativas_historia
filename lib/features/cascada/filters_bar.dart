import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/providers/app_state.dart';
import '../../models/materia.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FiltersTopBar(key: ValueKey('filters-topbar')),
        SizedBox(height: 10),
        SearchBarCard(key: ValueKey('search-card')),
      ],
    );
  }
}

class FiltersTopBar extends ConsumerWidget {
  const FiltersTopBar({super.key});

  static InputDecoration _ddDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? cs.surface : const Color(0xFFF3F4F6),
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary),
      ),
    );
  }

  static Widget _squareIconButton({
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(icon, size: 20, color: cs.onSurface),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final downloadUrl = ref.watch(careerDownloadUrlProvider);
    final cs = Theme.of(context).colorScheme;

    final planAsync = ref.watch(planProvider);
    final plan = planAsync.valueOrNull;
    final List<Materia> materias =
    plan == null ? const <Materia>[] : plan.materias;

    final List<String> tiposDisponibles = materias
        .map((m) => m.tipo.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final List<String> tipos = ['todos', ...tiposDisponibles];

    final List<int> aniosDisponibles = materias
        .map((m) => m.anio)
        .where((y) => y > 0)
        .toSet()
        .toList()
      ..sort();
    final List<int> anios =
    aniosDisponibles.isEmpty ? <int>[1, 2, 3, 4] : aniosDisponibles;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Color(0x12000000)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: DropdownButtonFormField<String>(
                value: tipo,
                hint: const Text('Tipos'),
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: isDark ? cs.surface : Colors.white,
                decoration: _ddDecoration(context),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final t in tipos)
                    DropdownMenuItem<String>(
                      value: t,
                      child: Text(
                        t == 'todos' ? 'Todos' : t,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  ref.read(filtroTipoProvider.notifier).state = v ?? 'todos';
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            height: 44,
            child: DropdownButtonFormField<int?>(
              value: anio,
              hint: const Text('Años'),
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: isDark ? cs.surface : Colors.white,
              decoration: _ddDecoration(context),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: <DropdownMenuItem<int?>>[
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...anios.map(
                      (y) => DropdownMenuItem<int?>(
                    value: y,
                    child: Text('$y° Año'),
                  ),
                ),
              ],
              onChanged: (v) {
                ref.read(filtroAnioProvider.notifier).state = v;
              },
            ),
          ),
          const SizedBox(width: 8),
          _squareIconButton(
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
          _squareIconButton(
            context: context,
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            icon:
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () {
              final cur = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
              cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
    );
  }
}

class SearchBarCard extends ConsumerStatefulWidget {
  const SearchBarCard({super.key});

  @override
  ConsumerState<SearchBarCard> createState() => _SearchBarCardState();
}

class _SearchBarCardState extends ConsumerState<SearchBarCard> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: ref.read(searchTermProvider));
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text;
      if (ref.read(searchTermProvider) != v) {
        ref.read(searchTermProvider.notifier).state = v;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<String>(searchTermProvider, (prev, next) {
      if (_searchCtrl.text != next) {
        _searchCtrl.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 6, color: Color(0x12000000)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar materia…',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: isDark ? cs.surface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color:
                isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color:
                isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary),
            ),
          ),
        ),
      ),
    );
  }
}