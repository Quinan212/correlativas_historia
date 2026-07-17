import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';
import 'modelos_legajo_sage.dart';

class PantallaMiLegajoSage extends StatelessWidget {
  const PantallaMiLegajoSage({
    super.key,
    required this.perfiles,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
    this.errorMessage,
  });

  final List<PerfilLegajoSage> perfiles;
  final ValueChanged<PerfilLegajoSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: 'Mi legajo',
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Text(
              'Seleccioná el perfil académico para continuar.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            if (errorMessage != null) ...[
              _MessageCard(message: errorMessage!, error: true),
              const SizedBox(height: 10),
            ],
            if (perfiles.isEmpty && errorMessage == null)
              const _MessageCard(
                message: 'No se encontraron perfiles disponibles.',
              ),
            for (final perfil in perfiles) ...[
              _TarjetaLegajoSage(
                perfil: perfil,
                enabled: !busy,
                onTap: () => onSelect(perfil),
              ),
              const SizedBox(height: 10),
            ],
            if (loadingTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(loadingTitle!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaLegajoSage extends StatelessWidget {
  const _TarjetaLegajoSage({
    required this.perfil,
    required this.enabled,
    required this.onTap,
  });

  final PerfilLegajoSage perfil;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = perfil.camposVisibles.values
        .where((value) => value != perfil.nombreVisible)
        .take(3)
        .join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: decoracionPanelSage(context, selected: true),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.badge_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      perfil.nombreVisible.isEmpty
                          ? 'Perfil académico'
                          : perfil.nombreVisible,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      secondary.isEmpty ? 'Disponible' : secondary,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.error = false});

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
