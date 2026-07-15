import 'package:flutter/material.dart';

class ItemListaOpcionSage {
  const ItemListaOpcionSage({
    required this.titulo,
    required this.icono,
    required this.onTap,
    this.subtitulo,
    this.enabled = true,
  });

  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final VoidCallback onTap;
  final bool enabled;
}

class ListaOpcionesSage extends StatelessWidget {
  const ListaOpcionesSage({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.opciones,
    this.emptyMessage = 'No se encontraron opciones disponibles.',
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 28),
    this.shrinkWrap = false,
    this.physics,
  });

  final String titulo;
  final String descripcion;
  final List<ItemListaOpcionSage> opciones;
  final String emptyMessage;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outline.withOpacity(0.62);
    return ListView(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: [
        if (titulo.trim().isNotEmpty) ...[
          Text(
            titulo,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (descripcion.trim().isNotEmpty) ...[
          Text(
            descripcion,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 24),
        ],
        if (opciones.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(emptyMessage),
          )
        else
          ...List.generate(opciones.length, (index) {
            final option = opciones[index];
            return Column(
              children: [
                _OpcionSageTile(option: option),
                if (index < opciones.length - 1)
                  Divider(height: 1, thickness: 1, color: dividerColor),
              ],
            );
          }),
      ],
    );
  }
}

class _OpcionSageTile extends StatelessWidget {
  const _OpcionSageTile({required this.option});

  final ItemListaOpcionSage option;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: option.enabled ? option.onTap : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 74),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Icon(
                  option.icono,
                  size: 27,
                  color: option.enabled
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface.withOpacity(0.35),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      option.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: option.enabled
                            ? scheme.onSurface
                            : scheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                    if (option.subtitulo != null &&
                        option.subtitulo!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.subtitulo!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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
                color: option.enabled
                    ? scheme.onSurfaceVariant.withOpacity(0.55)
                    : scheme.onSurface.withOpacity(0.22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
