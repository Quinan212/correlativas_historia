import 'package:flutter/material.dart';

import '../../../modelos/materia.dart';
import '../componentes/tarjeta_materia_propia.dart';
import '../modelos/modelos_acceso_estudiante.dart';

class MateriasPorAnioPantalla extends StatelessWidget {
  const MateriasPorAnioPantalla({
    super.key,
    required this.year,
    required this.subjects,
    required this.allSubjects,
    required this.plan,
    required this.payload,
    required this.onEdit,
    required this.busy,
  });

  final int year;
  final List<MateriaEstudiante> subjects;
  final List<MateriaEstudiante> allSubjects;
  final List<Materia> plan;
  final DatosAccesoEstudiante payload;
  final Future<bool> Function({MateriaEstudiante? existing}) onEdit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF0E5E86);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          '$year° año',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: subjects.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No hay materias cargadas en $year° año.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: subjects.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text(
                            '${subjects.length} materias en $year° año',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          );
                        }
                        if (index == 1) {
                          return const SizedBox(height: 16);
                        }
                        final subject = subjects[index - 2];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TarjetaMateriaPropia(
                            subject: subject,
                            onEdit: () async {
                              final bool deleted = await onEdit(
                                existing: subject,
                              );
                              if (deleted && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            busy: busy,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
