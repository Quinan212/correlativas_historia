import 'package:flutter/material.dart';

import 'utilidades_administrador.dart';

class TarjetaCargaMasivaEstudiantes extends StatelessWidget {
  const TarjetaCargaMasivaEstudiantes({
    super.key,
    required this.busy,
    required this.controller,
    required this.onLoad,
  });

  final bool busy;
  final TextEditingController controller;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carga masiva',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Formato: DNI; Apellido; Nombre; Carrera; Año; División; Recursa',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: !busy,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText:
                  '40111222; Pérez; Ana; artes; 1; A; no\n38999888; Gómez; Luis; artes; 2; B; si',
              alignLabelWithHint: true,
              labelText: 'Pegar lista',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : onLoad,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(busy ? 'Cargando...' : 'Cargar lista'),
          ),
        ],
      ),
    );
  }
}
