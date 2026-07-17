import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';
import 'modelos_perfiles_sage.dart';

class PantallaSelectorPerfilSage extends StatelessWidget {
  const PantallaSelectorPerfilSage({
    super.key,
    required this.perfiles,
    required this.onSelect,
    this.busy = false,
    this.error,
    this.onRetry,
    this.onBack,
  });

  final List<PerfilDisponibleSage> perfiles;
  final ValueChanged<PerfilSage> onSelect;
  final bool busy;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = perfiles.where((item) => item.disponible).toList();
    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: 'Elegí tu acceso',
        leading: IconButton(
          tooltip: 'Volver al inicio',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Text(
              '¿Cómo querés ingresar a SAGE?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Seleccioná el perfil que vas a utilizar.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            for (final item in available) ...[
              _TarjetaPerfilSage(
                item: item,
                enabled: !busy,
                onTap: () => onSelect(item.perfil),
              ),
              const SizedBox(height: 10),
            ],
            if (available.isEmpty && error == null)
              _MensajePerfilSage(
                message: 'No se encontraron perfiles disponibles.',
              ),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (error != null) ...[
              const SizedBox(height: 8),
              _MensajePerfilSage(message: error!, error: true),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reintentar'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TarjetaPerfilSage extends StatelessWidget {
  const _TarjetaPerfilSage({
    required this.item,
    required this.enabled,
    required this.onTap,
  });

  final PerfilDisponibleSage item;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: decoracionPanelSage(context, selected: item.activo),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.activo
                      ? scheme.primary.withValues(alpha: 0.12)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.perfil == PerfilSage.agente
                      ? Icons.school_outlined
                      : Icons.person_outline_rounded,
                  color: item.activo ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.perfil.etiqueta,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.activo
                          ? 'Perfil activo'
                          : 'Abrir este perfil en SAGE',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.activo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACTIVO',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensajePerfilSage extends StatelessWidget {
  const _MensajePerfilSage({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error ? scheme.errorContainer : scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: error
              ? scheme.error.withValues(alpha: 0.35)
              : scheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            error ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: error ? scheme.error : scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
