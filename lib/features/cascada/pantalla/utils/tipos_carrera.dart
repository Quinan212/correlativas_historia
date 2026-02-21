import '../../../../shared/providers/app_state.dart';

enum TipoCarrera { profesorado, grado }

TipoCarrera tipoCarreraDeId(String id) {
  switch (id) {
    case 'contador':
      return TipoCarrera.grado;
    default:
      return TipoCarrera.profesorado;
  }
}

String labelTipoCarrera(TipoCarrera t) {
  switch (t) {
    case TipoCarrera.profesorado:
      return 'Profesorados';
    case TipoCarrera.grado:
      return 'Carreras de grado';
  }
}

List<TipoCarrera> tiposDisponibles(List<CareerInfo> careers) {
  final set = <TipoCarrera>{};
  for (final c in careers) {
    set.add(tipoCarreraDeId(c.id));
  }
  // mantiene tu lógica: no mostrar "grado"
  return set.where((t) => t != TipoCarrera.grado).toList();
}

List<CareerInfo> carrerasDeTipo(List<CareerInfo> careers, TipoCarrera type) {
  return careers.where((c) => tipoCarreraDeId(c.id) == type).toList();
}