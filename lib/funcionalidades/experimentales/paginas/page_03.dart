import 'package:flutter/material.dart';

import 'base_pagina_documento.dart';

class DocPage03 extends StatelessWidget {
  const DocPage03({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return DocA4Page(
      width: width,
      pageNumber: 3,
      title: 'GLOSARIO ACADEMICO',
      subtitle: 'Bloques literales del DOCX con estilo visual unificado',
      children: const [
        DocTagRow(
          tags: [
            'Normativa',
            'Diseño curricular',
            'Correlatividad',
            'RAM',
            'Plan de estudios',
          ],
        ),
        DocLiteralBlock(
          heading:
              '¿Qué palabras necesito comprender para desenvolverme en una institución de nivel superior?',
          paragraphs: [
            'Hora cátedra: uno o medio módulo de clases (35 o 40 min.) - Espacio curricular: materia-asignatura - Cátedra compartida o equipo de cátedra. Parcial - Final - Promoción directa - Coloquio - Regularidad: se refiere a la condición de alumno en relación a la asistencia a clases -Homologación- Correlatividades - Currículum - Práctica-Talleres -Seminarios -Exámenes finales: instancias de evaluación final sobre un espacio curricular (febrero-marzo; julio-agosto; noviembre-diciembre) -1er, 2do, 3er… llamado: instancias de mesas de exámenes finales. -Programa – Proyecto: consiste en la planificación del espacio curricular que el docente realiza para el ciclo lectivo (objetivos, contenidos, estrategias didácticas, recursos, evaluación).',
          ],
        ),
        DocLiteralBlock(
          heading: '¿Qué es una Normativa?',
          paragraphs: [
            'La vida académica está regulada por un conjunto de normativas (leyes, decretos, resoluciones, disposiciones, circulares) con alcance a nivel nacional, provincial e institucional.',
            'Una normativa es un documento que contiene reglas, obligaciones, derechos y garantías. En este caso vienen a ordenar la vida en las instituciones y a regular la actividad que desarrollan los sujetos que las habitan, quienes suponen ciertos consensos para vivir en comunidad. Pueden ser disposiciones, resoluciones, decretos, leyes, estatutos, acuerdos, entre otros.',
          ],
        ),
        DocLiteralBlock(
          heading: '¿Qué es un Diseño Curricular?',
          paragraphs: [
            'El término diseño curricular hace referencia a lo que en muchas ocasiones denominamos Plan de Estudios de una carrera, pero va más allá y abarca otros aspectos que permiten organizar y desarrollar el plan educativo. El diseño curricular busca satisfacer las necesidades formativas de las y los estudiantes y se plasma en un documento detallando las características y proyectando los alcances de la formación.',
            'Las y los docentes encuentran en él una guía para llevar adelante la enseñanza y les posibilita la planificación general de las actividades académicas, establece la organización de las unidades curriculares, su modalidad de cursado, como así también lo que se denomina el régimen de correlatividades para cada carrera.',
            'Cada diseño curricular es aprobado por el Consejo General de Educación a través de una Resolución y, periódicamente junto al Ministerio de Educación de Nación, se realiza una evaluación de la implementación de los mismos a los efectos de ir respondiendo a las necesidades de formación de cada una de las provincias.',
          ],
        ),
      ],
    );
  }
}
