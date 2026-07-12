import 'package:flutter/material.dart';

import '../../../../modelos/materia.dart';
import '../../modelos/estudiante_administrador.dart';
import '../../modelos/materia_estudiante_administrador.dart';
import 'utilidades_administrador.dart';

class DialogoEditorMateria extends StatefulWidget {
  const DialogoEditorMateria({
    super.key,
    required this.student,
    required this.materia,
    required this.existing,
    required this.suggestedCondition,
  });

  final EstudianteAdministrador student;
  final Materia materia;
  final MateriaEstudianteAdministrador? existing;
  final String suggestedCondition;

  @override
  State<DialogoEditorMateria> createState() => _DialogoEditorMateriaState();
}

class _DialogoEditorMateriaState extends State<DialogoEditorMateria> {
  late String _status;
  late String _condition;
  String? _detail;
  String? _creditType;
  String? _period;
  DateTime? _date;
  DateTime? _deadline;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _adminNoteCtrl;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _status = existing?.status ?? 'cursando';
    _condition = existing?.conditionStatus ?? widget.suggestedCondition;
    _detail = existing?.detailStatus;
    _creditType = existing?.creditType;
    _period = existing?.academicPeriod;
    _date = existing?.sourceDate;
    _deadline = existing?.conditionDeadline;
    _gradeCtrl = TextEditingController(text: existing?.grade?.toString() ?? '');
    _noteCtrl = TextEditingController(text: existing?.notes ?? '');
    _adminNoteCtrl = TextEditingController(text: existing?.adminNote ?? '');
  }

  @override
  void dispose() {
    _gradeCtrl.dispose();
    _noteCtrl.dispose();
    _adminNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.materia.displayNombre),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.suggestedCondition == 'condicional')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Atención: no cumple todas las correlativas. Se sugiere cargar como condicional con aclaración.',
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: SelectorDropdown(
                      label: 'Estado',
                      value: _status,
                      items: const {
                        'cursando': 'Cursando',
                        'regular': 'Regular',
                        'aprobada': 'Aprobada',
                        'no_regularizada': 'No regularizada',
                      },
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectorDropdown(
                      label: 'Condición',
                      value: _condition,
                      items: const {
                        'habilitada': 'Habilitada',
                        'condicional': 'Condicional',
                        'bloqueada': 'Bloqueada',
                      },
                      onChanged: (value) => setState(() => _condition = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SelectorNuloDropdown(
                      label: 'Detalle',
                      value: _detail,
                      items: const {
                        'promocion_directa': 'Promoción directa',
                        'mesa_final': 'Mesa final',
                        'equivalencia': 'Equivalencia',
                        'coloquio_tif': 'Coloquio/TIF',
                        'desaprobo': 'Desaprobó',
                        'libre': 'Libre',
                        'abandono': 'Abandono',
                        'no_continuo': 'No continuó',
                        'rechazo_equivalencia': 'Rechazo equivalencia',
                      },
                      onChanged: (value) => setState(() => _detail = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SelectorNuloDropdown(
                      label: 'Acreditación',
                      value: _creditType,
                      items: const {
                        'mesa_final': 'Mesa final',
                        'promocion_directa': 'Promoción directa',
                        'equivalencia': 'Equivalencia',
                        'coloquio_tif': 'Coloquio/TIF',
                      },
                      onChanged: (value) => setState(() => _creditType = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SelectorNuloDropdown(
                      label: 'Período',
                      value: _period,
                      items: const {
                        'febrero': 'Febrero',
                        'mayo_extraordinaria': 'Mayo extraordinaria',
                        'julio': 'Julio',
                        'diciembre': 'Diciembre',
                        'regular': 'Regular',
                        'cursada': 'Cursada',
                        'tif': 'TIF',
                        'equivalencia': 'Equivalencia',
                        'ajuste': 'Ajuste',
                      },
                      onChanged: (value) => setState(() => _period = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _gradeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nota'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BotonFecha(
                      label: 'Fecha',
                      value: _date,
                      onPick: (value) => setState(() => _date = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BotonFecha(
                      label: 'Límite condición',
                      value: _deadline,
                      onPick: (value) => setState(() => _deadline = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observación'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _adminNoteCtrl,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Aclaración administrativa'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _save() {
    final studentId = widget.student.id;
    if (studentId == null) return;
    Navigator.of(context).pop(
      BorradorMateriaEstudianteAdministrador(
        id: widget.existing?.id,
        studentId: studentId,
        careerId: widget.student.careerId,
        subjectId: widget.materia.id,
        subjectName: widget.materia.displayNombre,
        subjectYear: widget.materia.anio,
        status: _status,
        conditionStatus: _condition,
        detailStatus: _detail,
        creditType: _creditType,
        academicPeriod: _period,
        sourceDate: _date,
        grade: double.tryParse(_gradeCtrl.text.trim().replaceAll(',', '.')),
        conditionDeadline: _deadline,
        notes: _noteCtrl.text,
        adminNote: _adminNoteCtrl.text,
      ),
    );
  }
}
