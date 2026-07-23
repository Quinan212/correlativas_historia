import 'package:correlativas_historia/compartido/migraciones/migrador_preferencias_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('elimina solo claves legacy exactas y conserva datos activos', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'bottom_navigation_index': 3,
      'seccion_nav': 2,
      'mi_navigation_preference_legitima': 'conservar',
      'color_barra_principal': 'azul',
      'trayectoria_sage_laboratorio_v1': '{"carreras":[]}',
      'estado_sincronizacion_sage_v2': '{"sesion_confirmada":true}',
      'device_identity.v1': 'dev_test',
    });

    final result = await MigradorPreferenciasApp.ejecutar();
    final prefs = await SharedPreferences.getInstance();

    expect(result.versionAnterior, 0);
    expect(result.versionActual, MigradorPreferenciasApp.versionActual);
    expect(result.clavesEliminadas, containsAll(<String>[
      'bottom_navigation_index',
      'seccion_nav',
    ]));
    expect(prefs.containsKey('bottom_navigation_index'), isFalse);
    expect(prefs.containsKey('seccion_nav'), isFalse);
    expect(prefs.getString('mi_navigation_preference_legitima'), 'conservar');
    expect(prefs.getString('color_barra_principal'), 'azul');
    expect(prefs.getString('trayectoria_sage_laboratorio_v1'), isNotNull);
    expect(prefs.getString('estado_sincronizacion_sage_v2'), isNotNull);
    expect(prefs.getString('device_identity.v1'), 'dev_test');
  });

  test('la migracion es idempotente y se ejecuta una sola vez', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'bottom_bar_index': 4,
    });

    final first = await MigradorPreferenciasApp.ejecutar();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bottom_bar_index', 1);
    final second = await MigradorPreferenciasApp.ejecutar(preferences: prefs);

    expect(first.aplicoCambios, isTrue);
    expect(second.aplicoCambios, isFalse);
    expect(prefs.getInt('bottom_bar_index'), 1);
    expect(
      prefs.getInt(MigradorPreferenciasApp.claveVersion),
      MigradorPreferenciasApp.versionActual,
    );
  });
}
