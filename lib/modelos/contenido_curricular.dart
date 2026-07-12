import '../compartido/utilidades/sanitizar_texto.dart';

class EjeContenido {
  final String titulo;
  final String descripcion;

  const EjeContenido({
    required this.titulo,
    required this.descripcion,
  });

  factory EjeContenido.fromMap(Map<String, dynamic> m) {
    return EjeContenido(
      titulo: sanitizarTexto((m['titulo'] ?? '').toString()),
      descripcion: sanitizarTexto((m['descripcion'] ?? '').toString()),
    );
  }
}

class ContenidoCurricular {
  final String id;
  final String nombre;
  final int anio;
  final String formato;
  final String cargaHoraria;
  final String regimenCursado;
  final String marcoOrientador;
  final List<EjeContenido> ejes;
  final List<String> bibliografia;
  final String tipo;

  const ContenidoCurricular({
    required this.id,
    required this.nombre,
    required this.anio,
    required this.formato,
    required this.cargaHoraria,
    required this.regimenCursado,
    required this.marcoOrientador,
    required this.ejes,
    required this.bibliografia,
    required this.tipo,
  });

  factory ContenidoCurricular.fromMap(Map<String, dynamic> m) {
    return ContenidoCurricular(
      id: sanitizarTexto((m['id'] ?? '').toString()),
      nombre: sanitizarTexto((m['nombre'] ?? '').toString()),
      anio: (m['anio'] as num).toInt(),
      formato: sanitizarTexto((m['formato'] ?? '').toString()),
      cargaHoraria: sanitizarTexto((m['cargaHoraria'] ?? '').toString()),
      regimenCursado: sanitizarTexto((m['regimenCursado'] ?? '').toString()),
      marcoOrientador: sanitizarTexto((m['marcoOrientador'] ?? '').toString()),
      ejes: ((m['ejes'] as List?) ?? [])
          .map((e) => EjeContenido.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
      bibliografia: ((m['bibliografia'] as List?) ?? [])
          .map((e) => sanitizarTexto(e.toString()))
          .toList(),
      tipo: sanitizarTexto((m['tipo'] ?? '').toString()),
    );
  }
}
