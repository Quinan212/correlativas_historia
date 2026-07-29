import 'package:correlativas_historia/funcionalidades/laboratorio_mesas_excel/dominio/normalizador_mesas_excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalización de fechas', () {
    test('interpreta seriales y el formato defectuoso observado', () {
      expect(normalizarFechaExcel(46223), DateTime(2026, 7, 20));
      expect(normalizarFechaExcel('28/0726'), DateTime(2026, 7, 28));
    });
  });

  group('normalización de horarios', () {
    test('interpreta fracciones, números y texto institucional', () {
      expect(normalizarHoraExcel(0.7916666666666666), '19:00');
      expect(normalizarHoraExcel(0.8125), '19:30');
      expect(normalizarHoraExcel(19.0), '19:00');
      expect(normalizarHoraExcel('19,00hs'), '19:00');
      expect(normalizarHoraExcel('19hs'), '19:00');
    });
  });

  test('separa año y división', () {
    final placement = normalizarAnioDivisionExcel('2do 1ra');
    expect(placement.anio, 2);
    expect(placement.division, '1.ª');
  });
}
