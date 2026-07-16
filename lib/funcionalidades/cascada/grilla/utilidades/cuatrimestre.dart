import '../../../../modelos/materia.dart';

int rankCuatri(Materia m) {
  final c = m.cuatri;
  if (c == null) return 99;
  return c;
}

String etiquetaCuatri(int? cuatri) {
  if (cuatri == null) return 'Anuales';
  if (cuatri == 1) return '1° cuatrimestre';
  if (cuatri == 2) return '2° cuatrimestre';
  return '$cuatri° cuatrimestre';
}
