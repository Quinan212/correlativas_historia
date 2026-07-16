import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Volver al inicio',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Elegí tu acceso'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '¿Cómo querés ingresar a SAGE?',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Seleccioná el perfil que vas a utilizar.'),
            const SizedBox(height: 24),
            for (final item in perfiles.where((item) => item.disponible))
              Card(
                child: ListTile(
                  enabled: !busy,
                  leading: Icon(
                    item.perfil == PerfilSage.agente
                        ? Icons.school_outlined
                        : Icons.person_outline_rounded,
                  ),
                  title: Text(item.perfil.etiqueta),
                  subtitle: Text(
                    item.activo ? 'Perfil activo' : 'Abrir este perfil en SAGE',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => onSelect(item.perfil),
                ),
              ),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(error!, style: TextStyle(color: theme.colorScheme.error)),
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
