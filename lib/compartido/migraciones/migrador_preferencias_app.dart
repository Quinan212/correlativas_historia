import 'package:shared_preferences/shared_preferences.dart';

class ResultadoMigracionPreferenciasApp {
  const ResultadoMigracionPreferenciasApp({
    required this.versionAnterior,
    required this.versionActual,
    required this.clavesEliminadas,
  });

  final int versionAnterior;
  final int versionActual;
  final List<String> clavesEliminadas;

  bool get aplicoCambios =>
      versionAnterior != versionActual || clavesEliminadas.isNotEmpty;
}

class MigradorPreferenciasApp {
  const MigradorPreferenciasApp._();

  static const int versionActual = 1;
  static const String claveVersion = 'app_preference_schema_version';

  /// Claves exactas usadas por shells y barras anteriores.
  ///
  /// La lista es deliberadamente cerrada: evita borrar preferencias futuras
  /// solo porque su nombre contenga palabras como `navigation` o `barra`.
  static const Set<String> clavesNavegacionLegacy = <String>{
    'barra_navegacion_indice',
    'bottom_bar_index',
    'bottom_navigation_index',
    'indice_router',
    'legacy_bottom_bar_index',
    'legacy_navigation_index',
    'navegacion_inferior_indice',
    'router_index',
    'sage_activo',
    'sage_bottom_bar_index',
    'sage_navigation_index',
    'seccion_nav',
    'selected_navigation_index',
  };

  static Future<ResultadoMigracionPreferenciasApp> ejecutar({
    SharedPreferences? preferences,
  }) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final previousVersion = prefs.getInt(claveVersion) ?? 0;
    if (previousVersion >= versionActual) {
      return ResultadoMigracionPreferenciasApp(
        versionAnterior: previousVersion,
        versionActual: previousVersion,
        clavesEliminadas: const <String>[],
      );
    }

    final removed = <String>[];
    var nextVersion = previousVersion;

    if (nextVersion < 1) {
      for (final key in clavesNavegacionLegacy) {
        if (!prefs.containsKey(key)) continue;
        final removedKey = await prefs.remove(key);
        if (removedKey) removed.add(key);
      }
      nextVersion = 1;
    }

    final stored = await prefs.setInt(claveVersion, nextVersion);
    if (!stored) {
      throw StateError(
        'No se pudo guardar la versión de preferencias de la aplicación.',
      );
    }

    return ResultadoMigracionPreferenciasApp(
      versionAnterior: previousVersion,
      versionActual: nextVersion,
      clavesEliminadas: List<String>.unmodifiable(removed),
    );
  }
}
