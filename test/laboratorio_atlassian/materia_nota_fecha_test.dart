import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_materias_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra nota y fecha en el detalle de una materia aprobada', (
    tester,
  ) async {
    const subject = MateriaTrayectoriaSageLaboratorio(
      idSage: 'hist-1',
      nombre: 'Historia Argentina',
      estadoOriginal: 'Aprobada',
      estado: EstadoMateriaSageLaboratorio.aprobada,
      anio: 2,
      nota: '9',
      fecha: '14/07/2026',
    );
    const career = CarreraTrayectoriaSageLaboratorio(
      gridRowId: 'career-1',
      careerKey: 'historia',
      nombre: 'Profesorado de Historia',
      institucion: 'Instituto',
      materias: <MateriaTrayectoriaSageLaboratorio>[subject],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaDetalleMateriaAtlassian(
          subject: subject,
          career: career,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nota'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);
    expect(find.text('14/07/2026'), findsOneWidget);
  });
}
