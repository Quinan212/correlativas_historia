import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

class RepositorioTrayectoriaSageLaboratorio {
  const RepositorioTrayectoriaSageLaboratorio();

  static const String _storageKey = 'trayectoria_sage_laboratorio_v1';

  Future<TrayectoriaSageLaboratorio?> cargar() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return TrayectoriaSageLaboratorio.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<TrayectoriaSageLaboratorio> guardar(
    TrayectoriaSageLaboratorio draft,
  ) async {
    final confirmed = draft.confirmarSincronizacion(DateTime.now());
    final preferences = await SharedPreferences.getInstance();
    final stored = await preferences.setString(
      _storageKey,
      jsonEncode(confirmed.toJson()),
    );
    if (!stored) {
      throw StateError('No se pudo guardar la trayectoria en el dispositivo.');
    }
    return confirmed;
  }

  Future<void> borrar() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}
