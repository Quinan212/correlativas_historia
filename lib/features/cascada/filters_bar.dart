import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/materia.dart';
import '../../shared/providers/app_state.dart';

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final planAsync = ref.watch(planProvider);
    final plan = planAsync.valueOrNull;
    final materias = plan == null ? const <Materia>[] : plan.materias;

    final tiposDisponibles = materias
        .map((m) => m.tipo.trim())
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final tipos = ['todos', ...tiposDisponibles];

    final aniosDisponibles = materias
        .map((m) => m.anio)
        .where((y) => y > 0)
        .toSet()
        .toList()
      ..sort();
    final anios = aniosDisponibles.isEmpty ? <int>[1, 2, 3, 4] : aniosDisponibles;

    const desiredTiposW = 170.0;
    const desiredAniosW = 220.0;
    const minAniosReserve = 92.0;

    final labelStyle = tt.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: cs.onSurfaceVariant,
    );

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
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = 8.0;
          final available = c.maxWidth;
          final maxTiposW =
              (available - gap - minAniosReserve).clamp(0.0, desiredTiposW).toDouble();
          final tiposW = desiredTiposW <= maxTiposW ? desiredTiposW : maxTiposW;
          final maxAniosW =
              (available - gap - tiposW).clamp(0.0, desiredAniosW).toDouble();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: tiposW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo', style: labelStyle),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 44,
                      child: DropdownButtonFormField<String>(
                        initialValue: tipo,
                        hint: const Text('Tipo de materia'),
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: isDark ? cs.surface : Colors.white,
                        decoration: _ddDecoration(context),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        selectedItemBuilder: (context) {
                          return tipos.map((t) {
                            final text = t == 'todos' ? 'Todos los tipos' : t;
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                        },
                        items: [
                          for (final t in tipos)
                            DropdownMenuItem<String>(
                              value: t,
                              child: Text(
                                t == 'todos' ? 'Todos los tipos' : t,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: maxAniosW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Año', style: labelStyle),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 44,
                      child: DropdownButtonFormField<int?>(
                        initialValue: anio,
                        hint: const Text('Año del plan'),
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        dropdownColor: isDark ? cs.surface : Colors.white,
                        decoration: _ddDecoration(context),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        selectedItemBuilder: (context) {
                          return <Widget>[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Todos los años',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ...anios.map(
                              (y) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$y° año',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ];
                        },
                        items: <DropdownMenuItem<int?>>[
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Todos los años'),
                          ),
                          ...anios.map(
                            (y) => DropdownMenuItem<int?>(
                              value: y,
                              child: Text('$y° año'),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          ref.read(filtroAnioProvider.notifier).state = v;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final downloadUrl = ref.watch(careerDownloadUrlProvider);

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
        color: isDarkTheme ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme ? cs.outlineVariant : const Color(0xFFE5E7EB),
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
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Buscar materia...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDarkTheme ? cs.surface : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDarkTheme ? cs.outlineVariant : const Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDarkTheme ? cs.outlineVariant : const Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FiltersTopBar._squareIconButton(
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
          FiltersTopBar._squareIconButton(
            context: context,
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
    );
  }
}
