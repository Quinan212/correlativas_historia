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
      'Accesos superiores': portada.accesosSuperiores,
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
          tooltip: 'Cambiar perfil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.swap_horiz_rounded),
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
            const Text(
              'Los accesos superiores corresponden al menú principal de SAGE. '
              'Desde Legajo Único Alumno podés abrir los legajos estudiantiles.',
            ),
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
                    subtitle: option.sigla == null ? null : Text(option.sigla!),
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
