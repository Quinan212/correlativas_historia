import '../../../../modelos/materia.dart';
import 'cuatrimestre.dart';

int _tipoRank(String t) {
  final s = t.toLowerCase();
  if (s.contains('general')) return 0;
  if (s.contains('espec')) return 1;
  if (s.contains('práctica') || s.contains('practica')) return 2;
  return 99;
}

List<Materia> ordenarMateriasParaGrilla(Iterable<Materia> materias) {
  final ordered = [...materias];
  ordered.sort((a, b) {
    final byYear = a.anio.compareTo(b.anio);
    if (byYear != 0) return byYear;

    final byCuatri = rankCuatri(a).compareTo(rankCuatri(b));
    if (byCuatri != 0) return byCuatri;

    final byTipo = _tipoRank(a.tipo).compareTo(_tipoRank(b.tipo));
    if (byTipo != 0) return byTipo;

    return a.nombre.compareTo(b.nombre);
  });
  return ordered;
}

Map<int, List<Materia>> agruparPorAnio(List<Materia> ordered) {
  final byYear = <int, List<Materia>>{};
  for (final m in ordered) {
    byYear.putIfAbsent(m.anio, () => []).add(m);
  }
  return byYear;
}

List<int> aniosPresentes(Map<int, List<Materia>> byYear) {
  return [1, 2, 3, 4, 5].where(byYear.containsKey).toList();
}
