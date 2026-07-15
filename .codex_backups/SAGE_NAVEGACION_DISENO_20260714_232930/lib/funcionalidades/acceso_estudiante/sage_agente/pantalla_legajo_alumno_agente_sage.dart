import 'package:flutter/material.dart';

import 'modelos_agente_sage.dart';

class PantallaLegajoAlumnoAgenteSage extends StatelessWidget {
  const PantallaLegajoAlumnoAgenteSage({
    super.key,
    required this.opciones,
    required this.onSelect,
    required this.onBack,
    this.busy = false,
  });

  final List<OpcionAgenteSage> opciones;
  final ValueChanged<OpcionAgenteSage> onSelect;
  final VoidCallback onBack;
  final bool busy;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF0E5E86),
      foregroundColor: Colors.white,
      title: const Text('Legajo Único Alumno'),
      leading: IconButton(
        onPressed: busy ? null : onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Accesos de alumnos disponibles para el perfil Docente.',
          ),
          const SizedBox(height: 16),
          for (final option in opciones)
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
          if (opciones.isEmpty)
            const Text(
              'No se encontraron opciones de Legajo Único Alumno en SAGE.',
            ),
        ],
      ),
    ),
  );
}
