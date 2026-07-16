part of '../../seccion_eventos_examen_administrador.dart';

int _compareDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

int _yearSortValue(int? year) => year ?? 99;

int? _resolvedYear(EventoExamenAdministrador event) {
  if (event.anio != null) return event.anio;

  final materia = _clean(event.materia);
  if (event.careerId == 'historia') {
    if (materia.contains('practica docente i')) return 1;
    if (materia.contains('didactica de las ciencias sociales')) return 2;
    if (materia.contains('practica docente ii')) return 2;
    if (materia.contains('epistemologia de la historia')) return 3;
    if (materia.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'geografia') {
    if (materia.contains('practica docente iii')) return 3;
  } else if (event.careerId == 'politica') {
    if (materia.contains('practica docente ii')) return 2;
    if (materia.contains('didactica de las ciencias sociales')) return 2;
    if (materia.contains('practica docente iii')) return 3;
  }

  return null;
}

String _clean(String input) => sanitizeLowerNoAccents(input);

String _formatDate(DateTime value) {
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  final y = value.year.toString();
  return '$d/$m/$y';
}

String _etiquetaCarrera(String careerId) {
  for (final career in kCareers) {
    if (career.id == careerId) return career.nombre;
  }
  return careerId;
}
