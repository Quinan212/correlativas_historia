import 'package:correlativas_historia/funcionalidades/cascada/inicio_mapa_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/cascada/mapa_correlatividades_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/busqueda/modelos_busqueda_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_acceso_developer_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_inicio_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('debug muestra el acceso developer en Herramientas', (
    tester,
  ) async {
    await _setViewport(tester, const Size(600, 900));
    final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(null);
    final localLoaded = ValueNotifier<bool>(true);
    final selectedCareer = ValueNotifier<int>(0);
    final reset = ValueNotifier<int>(0);
    final actionRequest = ValueNotifier<SolicitudInicioAtlassian?>(null);
    addTearDown(trajectory.dispose);
    addTearDown(localLoaded.dispose);
    addTearDown(selectedCareer.dispose);
    addTearDown(reset.dispose);
    addTearDown(actionRequest.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaInicioAtlassian(
          trajectoryListenable: trajectory,
          localLoadedListenable: localLoaded,
          selectedCareerListenable: selectedCareer,
          resetListenable: reset,
          actionRequestListenable: actionRequest,
          onTrajectoryChanged: (_) {},
          onNavigate: (_) {},
          onSearch: () {},
        ),
      ),
    );

    expect(find.text('Acceso developer'), findsOneWidget);
  });

  testWidgets('el Inicio legacy conserva navegación interna y oculta salidas', (
    tester,
  ) async {
    await _setViewport(tester, const Size(1600, 900));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PantallaInicioMapa(mostrarAccesosExternos: false),
        ),
      ),
    );

    expect(find.text('Mapa de Carrera'), findsOneWidget);
    expect(find.text('Calculadora'), findsOneWidget);
    expect(find.text('Exámenes'), findsNothing);
    expect(find.text('Alumno y trayectoria'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('el Mapa legacy no expone el acceso móvil a Exámenes', (
    tester,
  ) async {
    await _setViewport(tester, const Size(600, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PantallaMapaCorrelatividades(mostrarAccesoExamenes: false),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Examenes'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('el modo legacy de escritorio ofrece una salida visible', (
    tester,
  ) async {
    await _setViewport(tester, const Size(1600, 900));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PantallaModoLegacyDeveloper()),
      ),
    );

    expect(find.byTooltip('Salir del modo legacy'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Calculadora'), findsAtLeastNWidgets(1));
    expect(find.text('Preguntas'), findsOneWidget);
  });
}

Future<void> _setViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
