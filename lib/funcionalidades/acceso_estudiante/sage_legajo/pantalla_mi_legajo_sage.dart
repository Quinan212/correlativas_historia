import 'package:flutter/material.dart';

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
    final scheme = theme.colorScheme;
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Mi legajo'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            Text(
              'Seleccioná el perfil académico para continuar.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            if (errorMessage != null)
              _MessageCard(message: errorMessage!, error: true),
            if (perfiles.isEmpty && errorMessage == null)
              const _MessageCard(
                message: 'No se encontraron perfiles disponibles.',
              ),
            for (final perfil in perfiles)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  color: scheme.primaryContainer.withOpacity(0.42),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    enabled: !busy,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: scheme.primary,
                      child: Icon(
                        Icons.badge_outlined,
                        color: scheme.onPrimary,
                      ),
                    ),
                    title: Text(
                      perfil.nombreVisible.isEmpty
                          ? 'Perfil académico'
                          : perfil.nombreVisible,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: _secondary(perfil),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: busy ? null : () => onSelect(perfil),
                  ),
                ),
              ),
            if (loadingTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
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

  Widget? _secondary(PerfilLegajoSage perfil) {
    final values = perfil.camposVisibles.values
        .where((value) => value != perfil.nombreVisible)
        .take(3)
        .join(' · ');
    return values.isEmpty ? const Text('Disponible') : Text(values);
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(error ? Icons.error_outline : Icons.info_outline),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
