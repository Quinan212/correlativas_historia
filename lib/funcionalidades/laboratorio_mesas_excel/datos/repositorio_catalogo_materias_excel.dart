import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../modelos/modelos_mesas_excel.dart';

class RepositorioCatalogoMateriasExcel {
  const RepositorioCatalogoMateriasExcel();

  static Future<List<MateriaCatalogoExcel>>? _cache;

  Future<List<MateriaCatalogoExcel>> cargar() {
    return _cache ??= _cargarInterno();
  }

  Future<List<MateriaCatalogoExcel>> _cargarInterno() async {
    const sources = <String, String>{
      'historia': 'assets/data/historia.json',
      'geografia': 'assets/data/geografia.json',
      'politica': 'assets/data/politica.json',
    };
    final out = <MateriaCatalogoExcel>[];
    for (final entry in sources.entries) {
      final raw = await rootBundle.loadString(entry.value);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw StateError('Catálogo inválido: ${entry.value}');
      }
      final materias = decoded['materias'];
      if (materias is! List) {
        throw StateError('Catálogo sin materias: ${entry.value}');
      }
      for (final item in materias) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString().trim() ?? '';
        final nombre = map['nombre']?.toString().trim() ?? '';
        final anio = (map['año'] as num?)?.toInt() ??
            (map['anio'] as num?)?.toInt() ??
            0;
        if (id.isEmpty || nombre.isEmpty || anio <= 0) continue;
        out.add(
          MateriaCatalogoExcel(
            id: id,
            careerId: entry.key,
            anio: anio,
            codigo: map['codigo']?.toString().trim() ?? '',
            nombre: nombre,
          ),
        );
      }
    }
    return List<MateriaCatalogoExcel>.unmodifiable(out);
  }
}
