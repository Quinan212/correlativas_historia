import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

class ItemListaOpcionSage {
  const ItemListaOpcionSage({
    required this.titulo,
    required this.icono,
    required this.onTap,
    this.subtitulo,
    this.enabled = true,
    this.available = true,
    this.highlighted = false,
    this.unavailableMessage =
        'Opción no disponible por el momento. Próximamente.',
  });

  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final VoidCallback onTap;
  final bool enabled;
  final bool available;
  final bool highlighted;
  final String unavailableMessage;
}

class ListaOpcionesSage extends StatefulWidget {
  const ListaOpcionesSage({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.opciones,
    this.emptyMessage = 'No se encontraron opciones disponibles.',
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 28),
    this.shrinkWrap = false,
    this.physics,
    this.mostrarBusqueda = true,
    this.textoBusqueda = 'Buscar en SAGE',
  });

  final String titulo;
  final String descripcion;
  final List<ItemListaOpcionSage> opciones;
  final String emptyMessage;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool mostrarBusqueda;
  final String textoBusqueda;

  @override
  State<ListaOpcionesSage> createState() => _ListaOpcionesSageState();
}

class _ListaOpcionesSageState extends State<ListaOpcionesSage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ListaOpcionesSage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.opciones.length < 3 && _query.isNotEmpty) {
      _controller.clear();
      _query = '';
    }
  }

  List<ItemListaOpcionSage> get _filtered {
    final query = _normalize(_query);
    if (query.isEmpty) return widget.opciones;
    return widget.opciones
        .where((option) {
          return _normalize(
            '${option.titulo} ${option.subtitulo ?? ''}',
          ).contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atlassian = usaEstiloAtlassianSage(context);
    final showSearch =
        atlassian && widget.mostrarBusqueda && widget.opciones.length >= 3;
    final options = _filtered;

    return ListView(
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      children: [
        if (widget.titulo.trim().isNotEmpty) ...[
          Text(
            widget.titulo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.descripcion.trim().isNotEmpty) ...[
          Text(
            widget.descripcion,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          SizedBox(height: showSearch ? 16 : 24),
        ],
        if (showSearch) ...[
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: decoracionBusquedaSage(
              context,
              hintText: widget.textoBusqueda,
              showClear: _query.isNotEmpty,
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (options.isEmpty)
          _EstadoSinOpcionesSage(
            text: _query.isEmpty
                ? widget.emptyMessage
                : 'No hay opciones que coincidan con la búsqueda.',
          )
        else if (atlassian)
          _PanelOpcionesAtlassian(opciones: options)
        else
          ...List.generate(options.length, (index) {
            final option = options[index];
            return Column(
              children: [
                _OpcionSageTile(option: option),
                if (index < options.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.46),
                  ),
              ],
            );
          }),
      ],
    );
  }
}

class _PanelOpcionesAtlassian extends StatelessWidget {
  const _PanelOpcionesAtlassian({required this.opciones});

  final List<ItemListaOpcionSage> opciones;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            for (var index = 0; index < opciones.length; index++) ...[
              _OpcionSageTile(option: opciones[index], atlassian: true),
              if (index != opciones.length - 1)
                Divider(height: 1, color: scheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoSinOpcionesSage extends StatelessWidget {
  const _EstadoSinOpcionesSage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: decoracionPanelSage(context),
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _OpcionSageTile extends StatelessWidget {
  const _OpcionSageTile({required this.option, this.atlassian = false});

  final ItemListaOpcionSage option;
  final bool atlassian;

  void _handleTap(BuildContext context) {
    if (!option.enabled) return;
    if (option.available) {
      option.onTap();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(option.unavailableMessage),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = option.available;
    final interactionEnabled = option.enabled;
    final titleColor = !interactionEnabled
        ? scheme.onSurface.withValues(alpha: 0.30)
        : available
        ? (option.highlighted ? scheme.primary : scheme.onSurface)
        : scheme.onSurface.withValues(alpha: 0.42);
    final iconColor = !interactionEnabled
        ? scheme.onSurface.withValues(alpha: 0.26)
        : available
        ? (option.highlighted ? scheme.primary : scheme.onSurfaceVariant)
        : scheme.onSurface.withValues(alpha: 0.34);

    final radius = BorderRadius.circular(atlassian ? 0 : 16);
    return Material(
      color: option.highlighted && available
          ? scheme.primaryContainer.withValues(alpha: atlassian ? 0.72 : 0.46)
          : Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: interactionEnabled ? () => _handleTap(context) : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: atlassian ? 68 : 78),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: atlassian ? 14 : 12,
              vertical: atlassian ? 12 : 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: atlassian
                      ? BoxDecoration(
                          color: option.highlighted && available
                              ? scheme.primary.withValues(alpha: 0.12)
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: Icon(option.icono, size: 23, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option.titulo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          color: titleColor,
                        ),
                      ),
                      if (option.subtitulo?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          option.subtitulo!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: available
                                ? (option.highlighted
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant)
                                : scheme.onSurface.withValues(alpha: 0.38),
                            fontWeight: option.highlighted
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: !interactionEnabled
                      ? scheme.onSurface.withValues(alpha: 0.20)
                      : available
                      ? scheme.onSurfaceVariant.withValues(alpha: 0.62)
                      : scheme.onSurface.withValues(alpha: 0.34),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _normalize(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  var output = value.toLowerCase();
  replacements.forEach((key, replacement) {
    output = output.replaceAll(key, replacement);
  });
  return output.replaceAll(RegExp(r'\s+'), ' ').trim();
}
