import 'package:flutter/material.dart';

class PantallaModulosSage extends StatelessWidget {
  const PantallaModulosSage({
    super.key,
    required this.onOpenLegajo,
    required this.onRefresh,
    required this.onBack,
    this.loadingTitle,
  });

  final VoidCallback onOpenLegajo;
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  final String? loadingTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Volver al acceso estudiantil',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Servicios académicos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'Elegí un módulo para continuar con tu gestión en SAGE.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: busy ? null : onOpenLegajo,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.badge_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Legajo Único Alumno',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Consultá tu legajo, certificados, inscripciones y servicios académicos.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
            if (loadingTitle != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Abriendo $loadingTitle…')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
