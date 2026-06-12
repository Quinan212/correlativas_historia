import 'package:flutter/material.dart';

import '../../modelos/estudiante_administrador.dart';
import 'utilidades_administrador.dart';

class TablaAlumnosAdministrador extends StatelessWidget {
  const TablaAlumnosAdministrador({
    super.key,
    required this.students,
    required this.onSelect,
    this.selectedStudentId,
  });

  final List<EstudianteAdministrador> students;
  final String? selectedStudentId;
  final ValueChanged<EstudianteAdministrador> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (students.isEmpty) {
      return Center(
        child: Text(
          'Todavía no hay alumnos cargados para esta carrera.',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    final groupedStudents = <int?, List<EstudianteAdministrador>>{
      1: <EstudianteAdministrador>[],
      2: <EstudianteAdministrador>[],
      3: <EstudianteAdministrador>[],
      4: <EstudianteAdministrador>[],
    };
    for (final student in students) {
      groupedStudents[student.currentYear ?? 1]?.add(student);
    }

    final sections = <({int? year, String label})>[
      (year: 1, label: '1° año'),
      (year: 2, label: '2° año'),
      (year: 3, label: '3° año'),
      (year: 4, label: '4° año'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: sections.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '${students.length} alumnos cargados',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          );
        }
        final section = sections[index - 1];
        final sectionStudents =
            groupedStudents[section.year] ?? const <EstudianteAdministrador>[];
        return SeccionAnioAlumnos(
          key: PageStorageKey<String>('students-${section.year ?? 'sin-ano'}'),
          title: section.label,
          count: sectionStudents.length,
          students: sectionStudents,
          selectedStudentId: selectedStudentId,
          onSelect: onSelect,
        );
      },
    );
  }
}

class SeccionAnioAlumnos extends StatelessWidget {
  const SeccionAnioAlumnos({
    super.key,
    required this.title,
    required this.count,
    required this.students,
    required this.selectedStudentId,
    required this.onSelect,
  });

  final String title;
  final int count;
  final List<EstudianteAdministrador> students;
  final String? selectedStudentId;
  final ValueChanged<EstudianteAdministrador> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text('$count alumnos'),
      children: [
        for (var i = 0; i < students.length; i++) ...[
          FilaAlumno(
            student: students[i],
            selected: students[i].id == selectedStudentId,
            onSelect: onSelect,
          ),
          if (i != students.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class FilaAlumno extends StatelessWidget {
  const FilaAlumno({
    super.key,
    required this.student,
    required this.selected,
    required this.onSelect,
  });

  final EstudianteAdministrador student;
  final bool selected;
  final ValueChanged<EstudianteAdministrador> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.10)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onSelect(student),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'DNI ${student.dni}'
                      '${student.cohortYear == null ? '' : ' · Cohorte ${student.cohortYear}'}',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 104,
                child: Text(
                  etiquetaCarrera(student.careerId),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  student.currentYear == null ? '-' : '${student.currentYear}°',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 26,
                child: Text(
                  student.division ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 108,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: EtiquetaEstadoEstudiante(student: student),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
