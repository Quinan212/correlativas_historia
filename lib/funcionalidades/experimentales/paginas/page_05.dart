import 'package:flutter/material.dart';

import 'base_pagina_documento.dart';

class DocPage05 extends StatelessWidget {
  const DocPage05({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return DocA4Page(
      width: width,
      pageNumber: 5,
      title: 'INSTANCIAS DE EVALUACION',
      subtitle:
          'Cierre de la sección académica + transición a correlatividades',
      children: const [
        DocTagRow(
          tags: [
            'Parcial',
            'Trabajos prácticos',
            'Coloquio',
            'Examen final',
            'CGE',
          ],
        ),
        DocLiteralBlock(
          heading:
              '¿Cómo y cuáles son las instancias de evaluación para aprobar una materia?',
          paragraphs: [
            'Para acreditar o aprobar una materia se requiere cumplimentar determinadas actividades de acuerdo a la condición de cursado en la que te encuentres y en función a los requerimientos establecidos por los docentes de cada una de ellas. De acuerdo a los Diseños Curriculares y al Régimen Académico Marco (RAM), podemos identificar algunas instancias evaluativas que te permitirán conocer los requerimientos para aprobar cada materia.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Parcial',
          paragraphs: [
            'Son instancias que acreditan parcialmente una materia a través de exámenes/evaluaciones (orales o escritas). Cada una con sus correspondientes recuperatorios y deben ser tomados en diferentes etapas del cursado según lo establezca el proyecto de cátedra de cada materia, en concordancia con el RAM y el diseño curricular.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Trabajos prácticos',
          paragraphs: [
            'Son actividades generalmente domiciliarias, pueden ser individuales o grupales que requieren actividades extras de las realizadas en clase. Tienen la misma importancia de aprobación que un parcial para la acreditación de las unidades curriculares.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Coloquio',
          paragraphs: [
            'Es una instancia de evaluación oral, que define la aprobación de una cátedra, y que se caracteriza por la defensa de un trabajo práctico o la exposición de un tema específico. Este tipo de instancia se realiza una vez adquirida la condición de promoción.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Examen Final',
          paragraphs: [
            'El Examen Final es la instancia de evaluación individual en la cual se define la aprobación de la asignatura por el estudiante. El mismo está compuesto por una mesa evaluadora presidida por el docente de la cátedra y acompañada por dos docentes auxiliares encargados de garantizar el buen desarrollo de la instancia.',
          ],
        ),
        DocLiteralBlock(
          heading: 'Unidades Curriculares y Regímenes de Correlatividades',
          paragraphs: [
            'A continuación, les presentamos las unidades curriculares para los cuatro años de cada una de las carreras del profesorado. Estos diseños fueron aprobados por el Consejo General de Educación de la provincia de Entre Ríos en el año 2014 (Historia y Geografía) y 2015 (Ciencias Políticas).',
            'Cada año tiene unidades curriculares correspondientes a tres áreas de formación: campo de la formación general, campo de la formación específica y campo de la formación en la práctica profesional.',
          ],
        ),
      ],
    );
  }
}
