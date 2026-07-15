import 'package:flutter/material.dart';

import 'modelos_agente_sage.dart';

class PantallaPortadaAgenteSage extends StatelessWidget {
  const PantallaPortadaAgenteSage({
    super.key,
    required this.onSelect,
    required this.onBack,
    required this.portada,
    this.busy = false,
  });
  final ValueChanged<OpcionAgenteSage> onSelect;
  final VoidCallback onBack;
  final bool busy;
  final PortadaAgenteSage portada;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = <String, List<OpcionAgenteSage>>{
      'Módulos': portada.modulos,
      'Submódulos': portada.submodulos,
      'Informes': portada.informes,
    }..removeWhere((_, values) => values.isEmpty);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Docente'),
        leading: IconButton(
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'Servicios del perfil Agente',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Elegí una opción para continuar en SAGE.'),
            for (final group in groups.entries) ...[
              const SizedBox(height: 24),
              Text(
                group.key,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              for (final option in group.value)
                Card(
                  child: ListTile(
                    enabled: !busy,
                    leading: Icon(
                      IconData(option.icono, fontFamily: 'MaterialIcons'),
                    ),
                    title: Text(option.etiqueta),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => onSelect(option),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
