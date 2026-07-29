import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos_mesas_excel.dart';

class RepositorioLocalMesasExcel {
  const RepositorioLocalMesasExcel();

  static const _activeKey = 'mesas_excel_active_v1';
  static const _pendingKey = 'mesas_excel_pending_v1';

  Future<CopiaLocalMesasExcel?> cargar() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_activeKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return _decode(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> guardarAtomico(CopiaLocalMesasExcel copy) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_encode(copy));
    final pendingSaved = await preferences.setString(_pendingKey, encoded);
    if (!pendingSaved) {
      throw StateError('No se pudo guardar el conjunto pendiente de mesas.');
    }
    final pendingRaw = preferences.getString(_pendingKey);
    if (pendingRaw == null || pendingRaw != encoded) {
      throw StateError('La verificación del conjunto pendiente falló.');
    }
    final activeSaved = await preferences.setString(_activeKey, pendingRaw);
    if (!activeSaved) {
      throw StateError('No se pudo activar el nuevo conjunto de mesas.');
    }
    await preferences.remove(_pendingKey);
  }

  Future<void> actualizarMetadatos(
    CopiaLocalMesasExcel current,
    MetadatosFuenteMesasExcel metadata,
  ) {
    return guardarAtomico(
      CopiaLocalMesasExcel(
        eventos: current.eventos,
        metadatos: metadata,
        diagnostico: current.diagnostico,
      ),
    );
  }

  Map<String, dynamic> _encode(CopiaLocalMesasExcel copy) {
    return <String, dynamic>{
      'eventos': copy.eventos.map((value) => value.toJson()).toList(),
      'metadatos': copy.metadatos.toJson(),
      'diagnostico': copy.diagnostico.toJson(),
    };
  }

  CopiaLocalMesasExcel _decode(Map<String, dynamic> json) {
    return CopiaLocalMesasExcel(
      eventos: (json['eventos'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) => EventoMesaExcel.fromJson(
              Map<String, dynamic>.from(value),
            ),
          )
          .toList(growable: false),
      metadatos: MetadatosFuenteMesasExcel.fromJson(
        Map<String, dynamic>.from(
          json['metadatos'] as Map? ?? const <String, dynamic>{},
        ),
      ),
      diagnostico: DiagnosticoLibroExcel.fromJson(
        Map<String, dynamic>.from(
          json['diagnostico'] as Map? ?? const <String, dynamic>{},
        ),
      ),
    );
  }
}
