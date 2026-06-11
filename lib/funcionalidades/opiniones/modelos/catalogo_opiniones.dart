class MateriaLite {
  const MateriaLite({
    required this.id,
    required this.nombre,
    required this.anio,
  });

  final String id;
  final String nombre;
  final int anio;
}

class DocenteLite {
  const DocenteLite({
    required this.id,
    required this.nombre,
    required this.apariciones,
  });

  final String id;
  final String nombre;
  final int apariciones;
}

class DocenteComunidadBase {
  const DocenteComunidadBase({
    required this.id,
    required this.nombre,
    required this.materias,
    required this.aparicionesTotales,
  });

  final String id;
  final String nombre;
  final List<MateriaLite> materias;
  final int aparicionesTotales;
}

class OpinionesCatalogo {
  const OpinionesCatalogo({
    required this.docentesPorMateria,
    required this.docentes,
  });

  final Map<String, List<DocenteLite>> docentesPorMateria;
  final Map<String, DocenteComunidadBase> docentes;
}
