import 'package:flutter/material.dart';

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
    final dividerColor = theme.colorScheme.outline.withOpacity(0.46);
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
        ? scheme.onSurface.withOpacity(0.30)
        : available
            ? (option.highlighted ? scheme.primary : scheme.onSurface)
            : scheme.onSurface.withOpacity(0.42);
    final iconColor = !interactionEnabled
        ? scheme.onSurface.withOpacity(0.26)
        : available
            ? (option.highlighted
                ? scheme.primary
                : scheme.onSurfaceVariant)
            : scheme.onSurface.withOpacity(0.34);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: option.highlighted && available
            ? scheme.primaryContainer.withOpacity(0.46)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: interactionEnabled ? () => _handleTap(context) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 78),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Icon(option.icono, size: 27, color: iconColor),
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
                                  : scheme.onSurface.withOpacity(0.38),
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
                        ? scheme.onSurface.withOpacity(0.20)
                        : available
                            ? scheme.onSurfaceVariant.withOpacity(0.62)
                            : scheme.onSurface.withOpacity(0.34),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
