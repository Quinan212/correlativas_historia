import 'package:flutter/material.dart';

import '../../modelos/estudiante_administrador.dart';
import 'utilidades_administrador.dart';

class TarjetaFormularioEstudiante extends StatelessWidget {
  const TarjetaFormularioEstudiante({
    super.key,
    required this.busy,
    required this.careerId,
    required this.dniCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.cohortCtrl,
    required this.divisionCtrl,
    required this.notesCtrl,
    required this.currentYear,
    required this.isNewStudent,
    required this.isRepeating,
    required this.onYearChanged,
    required this.onNewChanged,
    required this.onRepeatingChanged,
    required this.onSave,
  });

  final bool busy;
  final String careerId;
  final TextEditingController dniCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController cohortCtrl;
  final TextEditingController divisionCtrl;
  final TextEditingController notesCtrl;
  final int? currentYear;
  final bool isNewStudent;
  final bool isRepeating;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<bool> onNewChanged;
  final ValueChanged<bool> onRepeatingChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TarjetaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alta individual',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dniCtrl,
            enabled: !busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'DNI'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: lastNameCtrl,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: firstNameCtrl,
                  enabled: !busy,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: currentYear ?? 1,
                  decoration: const InputDecoration(labelText: 'Año actual'),
                  items: const [
                    DropdownMenuItem<int?>(value: 1, child: Text('1er año')),
                    DropdownMenuItem<int?>(value: 2, child: Text('2do año')),
                    DropdownMenuItem<int?>(value: 3, child: Text('3er año')),
                    DropdownMenuItem<int?>(value: 4, child: Text('4to año')),
                  ],
                  onChanged: busy ? null : (value) => onYearChanged(value ?? 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cohortCtrl,
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cohorte'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: divisionCtrl,
            enabled: !busy && careerId != 'artes_visuales',
            decoration: InputDecoration(
              labelText: careerId == 'artes_visuales'
                  ? 'División fija'
                  : 'Curso/división',
            ),
          ),
          if (careerId == 'artes_visuales') ...[
            const SizedBox(height: 6),
            Text(
              'En Artes Visuales la división queda fija en A.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            value: isNewStudent,
            onChanged: busy ? null : onNewChanged,
            title: const Text('Nuevo en la carrera'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: isRepeating,
            onChanged: busy ? null : onRepeatingChanged,
            title: const Text('Está recursando'),
            contentPadding: EdgeInsets.zero,
          ),
          TextField(
            controller: notesCtrl,
            enabled: !busy,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : onSave,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(busy ? 'Guardando...' : 'Crear usuario alumno'),
          ),
          const SizedBox(height: 8),
          Text(
            'Contraseña inicial: ${BorradorEstudianteAdministrador.defaultPassword}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
