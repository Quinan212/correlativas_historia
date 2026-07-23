import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../modelos/materia.dart';
import '../../../modelos/item_nomina_materia_administrador.dart';
import '../utilidades_administrador.dart';

class TabMateriaMasiva extends StatelessWidget {
  const TabMateriaMasiva({
    super.key,
    required this.year,
    required this.selectedSubjectId,
    required this.selectedMateria,
    required this.materias,
    required this.selectedRosterStudentIds,
    required this.saving,
    required this.period,
    required this.creditType,
    required this.failureDetail,
    required this.grade,
    required this.date,
    required this.rosterAsync,
    required this.onYearChanged,
    required this.onSubjectChanged,
    required this.onPeriodChanged,
    required this.onCreditTypeChanged,
    required this.onFailureDetailChanged,
    required this.onGradeChanged,
    required this.onDateChanged,
    required this.onToggleStudent,
    required this.onSelectAllRoster,
    required this.onClearRoster,
    required this.onApplyApproved,
    required this.onApplyFailed,
    required this.onApplyRegular,
    required this.onApplyCursando,
  });

  final int year;
  final String selectedSubjectId;
  final Materia? selectedMateria;
  final List<Materia> materias;
  final Set<String> selectedRosterStudentIds;
  final bool saving;
  final String period;
  final String creditType;
  final String failureDetail;
  final int? grade;
  final DateTime date;
  final AsyncValue<List<ItemNominaMateriaAdministrador>> rosterAsync;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<String> onCreditTypeChanged;
  final ValueChanged<String> onFailureDetailChanged;
  final ValueChanged<int?> onGradeChanged;
  final ValueChanged<DateTime> onDateChanged;
  final void Function(String studentId, bool selected) onToggleStudent;
  final ValueChanged<List<ItemNominaMateriaAdministrador>> onSelectAllRoster;
  final VoidCallback onClearRoster;
  final VoidCallback onApplyApproved;
  final VoidCallback onApplyFailed;
  final VoidCallback onApplyRegular;
  final VoidCallback onApplyCursando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (materias.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        children: const [
          TarjetaPanel(
            child: Text('No hay materias del plan cargadas para este año.'),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      children: [
        TarjetaPanel(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final fieldWidth = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 10) / 2;
              final smallFieldWidth = narrow
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 3;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carga masiva por materia',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: narrow ? fieldWidth : 180,
                        child: SelectorDropdown(
                          label: 'Año',
                          value: '$year',
                          items: const {
                            '1': '1er año',
                            '2': '2do año',
                            '3': '3er año',
                            '4': '4to año',
                          },
                          onChanged: (value) => onYearChanged(int.parse(value)),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : constraints.maxWidth - 190,
                        child: SelectorDropdown(
                          label: 'Materia',
                          value:
                              selectedSubjectId.isEmpty && materias.isNotEmpty
                              ? materias.first.id
                              : selectedSubjectId,
                          items: {
                            for (final materia in materias)
                              materia.id: materia.displayNombre,
                          },
                          onChanged: onSubjectChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: SelectorDropdown(
                          label: 'Período',
                          value: period,
                          items: const {
                            'febrero': 'Febrero',
                            'mayo_extraordinaria': 'Mayo extraordinaria',
                            'julio': 'Julio',
                            'diciembre': 'Diciembre',
                            'regular': 'Regular',
                            'tif': 'TIF',
                            'equivalencia': 'Equivalencia',
                            'ajuste': 'Ajuste',
                          },
                          onChanged: onPeriodChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: SelectorDropdown(
                          label: 'Acreditación',
                          value: creditType,
                          items: const {
                            'mesa_final': 'Mesa final',
                            'promocion_directa': 'Promoción directa',
                            'equivalencia': 'Equivalencia',
                            'coloquio_tif': 'Coloquio/TIF',
                          },
                          onChanged: onCreditTypeChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : smallFieldWidth,
                        child: SelectorDropdown(
                          label: 'No aprobada',
                          value: failureDetail,
                          items: const {
                            'desaprobo': 'Desaprobó',
                            'libre': 'Libre',
                            'abandono': 'Abandono',
                            'no_continuo': 'No continuó',
                            'rechazo_equivalencia': 'Rechazo equivalencia',
                          },
                          onChanged: onFailureDetailChanged,
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : 130,
                        child: SelectorNuloDropdown(
                          label: 'Nota',
                          value: grade?.toString(),
                          items: {
                            for (final item in List<int>.generate(
                              10,
                              (i) => i + 1,
                            ))
                              '$item': '$item',
                          },
                          onChanged: (value) => onGradeChanged(
                            value == null ? null : int.tryParse(value),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: narrow ? fieldWidth : 180,
                        child: BotonFecha(
                          label: 'Fecha',
                          value: date,
                          onPick: (value) {
                            if (value != null) onDateChanged(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        rosterAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => TarjetaPanel(
            child: Text('No se pudo cargar la lista por materia: $error'),
          ),
          data: (roster) => TarjetaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedMateria == null
                      ? 'Sin materia seleccionada'
                      : '${selectedMateria!.displayNombre} · ${roster.length} inscriptos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: saving || roster.isEmpty
                          ? null
                          : () => onSelectAllRoster(roster),
                      child: const Text('Seleccionar todos'),
                    ),
                    TextButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onClearRoster,
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyApproved,
                      child: const Text('Aprobar'),
                    ),
                    FilledButton.tonal(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyRegular,
                      child: const Text('Regularizar'),
                    ),
                    FilledButton.tonal(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyFailed,
                      child: const Text('Desaprobar'),
                    ),
                    OutlinedButton(
                      onPressed: saving || selectedRosterStudentIds.isEmpty
                          ? null
                          : onApplyCursando,
                      child: const Text('Volver a cursando'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (roster.isEmpty)
                  const Text(
                    'Todavia no hay alumnos inscriptos en esta materia.',
                  )
                else
                  ...roster.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: CheckboxListTile(
                        value: selectedRosterStudentIds.contains(
                          item.studentId,
                        ),
                        onChanged: saving
                            ? null
                            : (value) => onToggleStudent(
                                item.studentId,
                                value ?? false,
                              ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        title: Text(
                          item.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'DNI ${item.dni} · ${etiquetaAnio(item.currentYear)}${item.division == null ? '' : ' · ${item.division}'} · ${etiquetaEstado(item.subject.status)}${item.subject.grade == null ? '' : ' · Nota ${item.subject.grade!.toStringAsFixed(0)}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
