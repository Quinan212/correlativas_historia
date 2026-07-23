class MateriaLibretaPdf {
  const MateriaLibretaPdf({
    required this.nombre,
    required this.anio,
    required this.estado,
    required this.fecha,
    required this.calificacion,
  });

  final String nombre;
  final int anio;
  final String estado;
  final String fecha;
  final String calificacion;
}

class ResultadoExtraccionLibretaPdf {
  const ResultadoExtraccionLibretaPdf({
    required this.materias,
    this.carrera,
    this.fechaEmision,
  });

  final List<MateriaLibretaPdf> materias;
  final String? carrera;
  final String? fechaEmision;

  bool get contieneDatosAcademicos => materias.isNotEmpty;
}
