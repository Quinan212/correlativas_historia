import 'package:flutter/material.dart';

import '../../modelos/estudiante_administrador.dart';

// ── Widgets reutilizables ──────────────────────────────────

class TarjetaPanel extends StatelessWidget {
  const TarjetaPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class SelectorDropdown extends StatelessWidget {
  const SelectorDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class SelectorNuloDropdown extends StatelessWidget {
  const SelectorNuloDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String?>(
          child: Text(
            'Sin detalle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...items.entries.map(
          (entry) => DropdownMenuItem<String?>(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class BotonFecha extends StatelessWidget {
  const BotonFecha({
    super.key,
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onPick(picked);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value == null ? label : '$label: ${_formatearFecha(value!)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _formatearFecha(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class ManijaRedimensionPanel extends StatelessWidget {
  const ManijaRedimensionPanel({
    super.key,
    required this.width,
    required this.onDragUpdate,
  });

  final double width;
  final ValueChanged<double> onDragUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        child: SizedBox(
          width: width,
          child: Center(
            child: Container(
              width: 1,
              height: double.infinity,
              color: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class SinEstudianteSeleccionado extends StatelessWidget {
  const SinEstudianteSeleccionado({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Seleccioná un alumno para cargar su trayectoria.',
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}

// ── Etiquetas ──────────────────────────────────────────────

String etiquetaEstado(String value) {
  return switch (value) {
    'regular' => 'Regular',
    'aprobada' => 'Aprobada',
    'no_regularizada' => 'No regularizada',
    _ => 'Cursando',
  };
}

String etiquetaCondicion(String value) {
  return switch (value) {
    'condicional' => 'Condicional',
    'bloqueada' => 'Bloqueada',
    _ => 'Habilitada',
  };
}

String etiquetaAnio(int? year) {
  return switch (year ?? 1) {
    1 => '1er año',
    2 => '2do año',
    3 => '3er año',
    4 => '4to año',
    _ => '1er año',
  };
}

String etiquetaDetalle(String value) {
  return switch (value) {
    'promocion_directa' => 'Promoción directa',
    'mesa_final' => 'Mesa final',
    'equivalencia' => 'Equivalencia',
    'coloquio_tif' => 'Coloquio/TIF',
    'desaprobo' => 'Desaprobó',
    'libre' => 'Libre',
    'abandono' => 'Abandono',
    'no_continuo' => 'No continuó',
    'rechazo_equivalencia' => 'Rechazo equivalencia',
    _ => value,
  };
}

String etiquetaPeriodo(String value) {
  return switch (value) {
    'mayo_extraordinaria' => 'Mayo extraordinaria',
    'regular' => 'Regular',
    'cursada' => 'Cursada',
    'tif' => 'TIF',
    'equivalencia' => 'Equivalencia',
    'ajuste' => 'Ajuste',
    _ => value[0].toUpperCase() + value.substring(1),
  };
}

String etiquetaCarrera(String careerId) {
  return careerId == 'musica' ? 'Música' : 'Artes Visuales';
}

// ── Chip de estado ─────────────────────────────────────────

class EtiquetaEstadoEstudiante extends StatelessWidget {
  const EtiquetaEstadoEstudiante({super.key, required this.student});

  final EstudianteAdministrador student;

  @override
  Widget build(BuildContext context) {
    if (student.isRepeating) {
      return const Chip(label: Text('Recursa'));
    }
    if (student.isNewStudent &&
        student.currentYear == 1 &&
        student.academicProgressCount == 0) {
      return const Chip(label: Text('Nuevo'));
    }
    return const Chip(label: Text('Regular'));
  }
}
