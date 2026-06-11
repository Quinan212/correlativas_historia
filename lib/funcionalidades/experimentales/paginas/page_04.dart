import 'package:flutter/material.dart';

import 'base_pagina_documento.dart';

class DocPage04 extends StatelessWidget {
  const DocPage04({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return DocA4Page(
      width: width,
      pageNumber: 4,
      title: 'CORRELATIVIDADES Y FORMATOS',
      subtitle: 'Continuidad literal del documento de ingresantes',
      children: const [
        DocTagRow(
          tags: [
            'Asignatura',
            'Seminario',
            'Taller',
            'Práctica docente',
            'UDI',
            'Trabajo de campo',
          ],
        ),
        DocLiteralBlock(
          heading: '¿Qué es una Correlatividad?',
          paragraphs: [
            'Una materia es correlativa cuando su aprobación depende de la aprobación de otra asignatura previa. Que una unidad curricular (UC) sea correlativa con otra implica que para aprobar la segunda debemos primero tener aprobada/s la/s unidad/es que en el plan de estudios figuren como requisito para aprobar o cursar ese espacio.',
            'Es decir, para cursar y aprobar una unidad curricular, deben cumplirse los requisitos estipulados tanto en el diseño curricular como en el Régimen Académico Marco (RAM). Al momento de cursar o rendir el examen final de una Unidad Curricular, todas las unidades que sean correlativas de la misma deben estar cursadas y/o aprobadas (según corresponda). Por ejemplo, no podré rendir Matemática II si aún no aprobé Matemática I.',
          ],
        ),
        DocLiteralBlock(
          heading:
              '¿Cómo se organizan las diferentes materias de las carreras?',
          paragraphs: [
            'Cada carrera o diseño curricular está organizado en unidades curriculares o materias, se entiende por “unidad curricular” a aquellas unidades de conocimientos que, adoptando distintas modalidades o formatos pedagógicos, forman parte constitutiva del plan, organizan la enseñanza. Las unidades curriculares están clasificadas en tres formatos diferentes y por lo tanto también prevén formas de evaluación que le son propias.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Formatos (texto literal)',
          paragraphs: [
            'Asignatura: se refiere a una materia o disciplina específica que se estudia o se enseña en el currículo escolar. Cada asignatura tiene un conjunto de objetivos de aprendizaje y contenidos específicos que los estudiantes deben dominar. Estas materias se imparten a lo largo de un año académico, y su estudio contribuye al desarrollo de habilidades, conocimientos y competencias en los estudiantes.',
            'Seminario: posee una naturaleza técnica y académica, cuyo objetivo es llevar a cabo un estudio profundo de determinadas cuestiones o asuntos. En un seminario, se busca fomentar el debate, las ideas propias y originales, y poner a prueba el espíritu crítico de los participantes. Se considera un espacio educativo complementario al aula de clases, donde se promueve la participación activa de los estudiantes y se busca generar conocimientos y poner en práctica los saberes académicos.',
            'Taller: los talleres son unidades curriculares orientadas a promover la resolución práctica de situaciones a partir de la interacción y reflexión de los sujetos en forma cooperativa. Se propone para la evaluación, la presentación de trabajos parciales y/o finales, de producción individual o colectiva según la propuesta didáctica de los docentes de la unidad curricular.',
            'Práctica docente: son trabajos de participación progresiva de los estudiantes en instituciones formales y no formales, escuelas, aulas, desde ayudantías iniciales pasando por prácticas de enseñanza de contenido curriculares delimitados, hasta la residencia con proyectos de enseñanza extendidos en el tiempo.',
            'Unidades de definición institucional (UDI): estas unidades permiten recuperar las experiencias educativas, construidas en la trayectoria formativa del establecimiento educativo.',
            'Trabajos de campo: espacios sistemáticos de síntesis e integración de conocimientos a través de la realización de trabajos de indagación en terreno e intervenciones en campos acotados.',
            'Homologaciones: en cuanto a los estudiantes que hayan estudiado otra carrera (parcial o finalizada) pueden homologar los espacios curriculares aprobados. La institución brindará el tiempo y los requisitos que son necesarios para que puedan presentar la documentación.',
          ],
        ),
      ],
    );
  }
}
