import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos_biblioteca_drive.dart';

class RepositorioCacheBibliotecaDrive {
  const RepositorioCacheBibliotecaDrive();

  static const _prefix = 'biblioteca_drive_folder_v1_';

  Future<CopiaCarpetaBibliotecaDrive?> cargar(String folderId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString('$_prefix$folderId');
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final copy = CopiaCarpetaBibliotecaDrive.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      return copy.folderId == folderId ? copy : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> guardar(CopiaCarpetaBibliotecaDrive copy) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      '$_prefix${copy.folderId}',
      jsonEncode(copy.toJson()),
    );
    if (!saved) {
      throw StateError('No se pudo guardar la copia local de la biblioteca.');
    }
  }
}
