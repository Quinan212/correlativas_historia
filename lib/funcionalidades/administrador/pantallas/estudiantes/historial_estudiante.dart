import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modelos/entrada_historial_estudiante_administrador.dart';
import 'utilidades_administrador.dart';

class TabHistorial extends StatelessWidget {
  const TabHistorial({super.key, required this.historyAsync});

  final AsyncValue<List<EntradaHistorialEstudianteAdministrador>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No se pudo cargar historial: $error'),
        ),
      ),
      data: (history) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: [
          TarjetaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial del alumno',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (history.isEmpty)
                  const Text('Todavia no hay movimientos guardados.')
                else
                  ...history.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_tituloHistorial(entry)),
                      subtitle: Text(_subtituloHistorial(entry)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tituloHistorial(EntradaHistorialEstudianteAdministrador entry) {
    final subjectName = entry.payload['subject_name']?.toString().trim() ?? '';
    if (subjectName.isNotEmpty) {
      final status = entry.payload['status']?.toString().trim() ?? '';
      final statusLabel = status.isEmpty ? '' : ' · ${etiquetaEstado(status)}';
      return '$subjectName$statusLabel';
    }
    return switch (entry.eventType) {
      'student_upsert' => 'Actualizacion de alumno',
      'student_bulk_upsert' => 'Carga masiva de alumno',
      'subject_upsert' => 'Actualizacion de materia',
      'subjects_bulk_upsert' => 'Actualizacion masiva por materia',
      _ => entry.eventType,
    };
  }

  String _subtituloHistorial(EntradaHistorialEstudianteAdministrador entry) {
    final parts = <String>[
      if (entry.createdAt != null)
        '${entry.createdAt!.day.toString().padLeft(2, '0')}/${entry.createdAt!.month.toString().padLeft(2, '0')}/${entry.createdAt!.year}',
      if ((entry.payload['academic_period'] ?? '').toString().trim().isNotEmpty)
        etiquetaPeriodo(entry.payload['academic_period'].toString()),
      if ((entry.payload['detail_status'] ?? '').toString().trim().isNotEmpty)
        etiquetaDetalle(entry.payload['detail_status'].toString()),
      if ((entry.payload['grade'] ?? '').toString().trim().isNotEmpty)
        'Nota ${entry.payload['grade']}',
    ];
    return parts.isEmpty ? entry.eventType : parts.join(' · ');
  }
}
