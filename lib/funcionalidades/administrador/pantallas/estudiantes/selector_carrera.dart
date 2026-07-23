import 'package:flutter/material.dart';

class SelectorCarreraAdministrador extends StatelessWidget {
  const SelectorCarreraAdministrador({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Carrera'),
      items: const [
        DropdownMenuItem(
          value: 'artes_visuales',
          child: Text('Profesorado en Artes Visuales'),
        ),
        DropdownMenuItem(value: 'musica', child: Text('Profesorado en Música')),
      ],
      onChanged: onChanged,
    );
  }
}
