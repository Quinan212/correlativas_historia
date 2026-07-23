import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializa nota y fecha manteniendo compatibilidad hacia atrás', () {
    const subject = MateriaTrayectoriaSageLaboratorio(
      idSage: 'hist-1',
      nombre: 'Historia Argentina',
      estadoOriginal: 'Aprobada',
      estado: EstadoMateriaSageLaboratorio.aprobada,
      anio: 2,
      fecha: '14/07/2026',
      nota: '8,50',
    );

    final restored = MateriaTrayectoriaSageLaboratorio.fromJson(
      subject.toJson(),
    );
    final legacy = MateriaTrayectoriaSageLaboratorio.fromJson(
      <String, dynamic>{
        'id_sage': 'legacy',
        'nombre': 'Materia anterior',
        'estado_original': 'Regular',
        'estado': 'regular',
        'anio': 1,
      },
    );

    expect(restored.fecha, '14/07/2026');
    expect(restored.nota, '8,50');
    expect(restored.fechaAprobacion, DateTime(2026, 7, 14));
    expect(legacy.fecha, isNull);
    expect(legacy.nota, isNull);
  });

  test('parsea fechas habituales de SAGE y rechaza fechas inválidas', () {
    expect(parsearFechaAcademicaSage('14/07/2026'), DateTime(2026, 7, 14));
    expect(parsearFechaAcademicaSage('2026-07-14'), DateTime(2026, 7, 14));
    expect(parsearFechaAcademicaSage('31/02/2026'), isNull);
    expect(formatearFechaAcademicaSage('2026-07-14'), '14/07/2026');
  });
}
