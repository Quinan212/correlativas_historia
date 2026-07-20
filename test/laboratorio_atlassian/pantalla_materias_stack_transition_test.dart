/// Test: pantalla_materias_stack_transition_test.dart
///
/// Reproduce el error de pantalla roja con letras amarillas:
///   'package:flutter/src/widgets/framework.dart':
///   Failed assertion: '_elements.contains(element)': is not true.
///
/// Causa raíz: el Stack del body de PantallaMateriasAtlassian tenía hijos
/// condicionales — el Positioned del buscador flotante solo aparecía cuando
/// career != null.  Cuando career pasaba de null → no-null el Stack crecía
/// de 2 a 3 hijos, desplazando el Align(header) del índice 1 al 2.
/// Sin una Key que anclara el header, Flutter destruía y recreaba el
/// EncabezadoSeccionAtlassianColapsable.  Durante esa destrucción el
/// ScrollController podía notificar y llamar setState() sobre el State ya
/// en proceso de deactivación, corrompiendo el árbol de elementos del framework.
///
/// Cada test verifica que no aparece ningún ErrorWidget (pantalla roja) y que
/// FlutterError.onError no captura ningún error de framework.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_materias_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_laboratorio_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/busqueda/modelos_busqueda_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';

// ---------------------------------------------------------------------------
// Datos de prueba mínimos
// ---------------------------------------------------------------------------

MateriaTrayectoriaSageLaboratorio _makeMateria(String idSage, String nombre) =>
    MateriaTrayectoriaSageLaboratorio(
      idSage: idSage,
      nombre: nombre,
      estadoOriginal: 'Aprobada',
      estado: EstadoMateriaSageLaboratorio.aprobada,
      anio: 1,
    );

CarreraTrayectoriaSageLaboratorio _makeCareer({
  String id = 'career-1',
  String nombre = 'Ingeniería de Software',
  List<MateriaTrayectoriaSageLaboratorio>? materias,
}) =>
    CarreraTrayectoriaSageLaboratorio(
      gridRowId: id,
      nombre: nombre,
      institucion: 'UTN FRBA',
      materias: materias ??
          [
            _makeMateria('m1', 'Análisis Matemático I'),
            _makeMateria('m2', 'Álgebra'),
          ],
    );

TrayectoriaSageLaboratorio _makeTrajectory({
  List<CarreraTrayectoriaSageLaboratorio>? carreras,
}) =>
    TrayectoriaSageLaboratorio(
      perfil: PerfilTrayectoriaSageLaboratorio(
        nombre: 'Test User',
        campos: const {},
      ),
      carreras: carreras ?? [_makeCareer()],
      capturadaEn: DateTime(2024, 1, 1),
    );

// ---------------------------------------------------------------------------
// Envoltorio de test
// ---------------------------------------------------------------------------

Widget _buildSubject({
  required ValueNotifier<TrayectoriaSageLaboratorio?> trajectory,
  required ValueNotifier<bool> localLoaded,
  required ValueNotifier<int> selectedCareer,
}) {
  final request = ValueNotifier<SolicitudMateriasAtlassian?>(null);
  return MaterialApp(
    home: Scaffold(
      body: PantallaMateriasAtlassian(
        trajectoryListenable: trajectory,
        localLoadedListenable: localLoaded,
        selectedCareerListenable: selectedCareer,
        requestListenable: request,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Utilidades del test
// ---------------------------------------------------------------------------

/// Intercepta errores de Flutter framework durante la ejecución de [body].
///
/// Si Flutter lanza un error (que en producción muestra la pantalla roja)
/// lo captura en [captured] para que los asserts del test puedan verificarlo.
Future<List<FlutterErrorDetails>> _withErrorCapture(
  Future<void> Function() body,
) async {
  final captured = <FlutterErrorDetails>[];
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    captured.add(details);
    // También llamamos al manejador original para que el log muestre el error.
    original?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = original;
  }
  return captured;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group(
    'PantallaMateriasAtlassian – transición null → career '
    '(previene pantalla roja con letras amarillas)',
    () {
      // ── Test 1 ──────────────────────────────────────────────────────────
      testWidgets(
        '1. Construye sin error con localLoaded=false (estado inicial)',
        (tester) async {
          final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(null);
          final localLoaded = ValueNotifier<bool>(false);
          final selectedCareer = ValueNotifier<int>(0);

          final errors = await _withErrorCapture(() async {
            await tester.pumpWidget(_buildSubject(
              trajectory: trajectory,
              localLoaded: localLoaded,
              selectedCareer: selectedCareer,
            ));
            await tester.pump();
          });

          expect(
            find.byType(ErrorWidget),
            findsNothing,
            reason: 'Pantalla roja inesperada con localLoaded=false',
          );
          expect(
            errors,
            isEmpty,
            reason: 'Errores de framework: '
                '${errors.map((e) => e.exceptionAsString()).join(', ')}',
          );

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 2 ──────────────────────────────────────────────────────────
      testWidgets(
        '2. Construye sin error con localLoaded=true pero trajectory=null',
        (tester) async {
          final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(null);
          final localLoaded = ValueNotifier<bool>(true);
          final selectedCareer = ValueNotifier<int>(0);

          final errors = await _withErrorCapture(() async {
            await tester.pumpWidget(_buildSubject(
              trajectory: trajectory,
              localLoaded: localLoaded,
              selectedCareer: selectedCareer,
            ));
            await tester.pump();
          });

          expect(find.byType(ErrorWidget), findsNothing,
              reason: 'Pantalla roja con trajectory=null');
          expect(errors, isEmpty,
              reason: 'Errores: '
                  '${errors.map((e) => e.exceptionAsString()).join(', ')}');

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 3 ──────────────────────────────────────────────────────────
      testWidgets(
        '3. Construye sin error con career completa desde el inicio',
        (tester) async {
          final trajectory =
              ValueNotifier<TrayectoriaSageLaboratorio?>(_makeTrajectory());
          final localLoaded = ValueNotifier<bool>(true);
          final selectedCareer = ValueNotifier<int>(0);

          final errors = await _withErrorCapture(() async {
            await tester.pumpWidget(_buildSubject(
              trajectory: trajectory,
              localLoaded: localLoaded,
              selectedCareer: selectedCareer,
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          });

          expect(find.byType(ErrorWidget), findsNothing,
              reason: 'Pantalla roja con career != null desde el inicio');
          expect(errors, isEmpty,
              reason: 'Errores: '
                  '${errors.map((e) => e.exceptionAsString()).join(', ')}');

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 4: CASO CRÍTICO ─────────────────────────────────────────────
      testWidgets(
        '4. CRÍTICO: transición null → career no corrompe el árbol de elementos\n'
        "   Reproduce: '_elements.contains(element): is not true' en framework.dart",
        (tester) async {
          // Estado inicial: sin trayectoria → career == null.
          // El Stack tiene 2 hijos: [Positioned.fill, Align(header)]
          final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(null);
          final localLoaded = ValueNotifier<bool>(true);
          final selectedCareer = ValueNotifier<int>(0);

          await tester.pumpWidget(_buildSubject(
            trajectory: trajectory,
            localLoaded: localLoaded,
            selectedCareer: selectedCareer,
          ));
          await tester.pump();

          expect(find.byType(ErrorWidget), findsNothing,
              reason: 'Pantalla roja antes de la transición');

          // ── TRANSICIÓN CLAVE: career pasa de null → no-null ──────────────
          // Si el Positioned del filtro flotante es condicional, el Stack
          // crece de 2 a 3 hijos, desplazando el Align(header) e invalidando
          // el árbol de elementos del EncabezadoSeccionAtlassianColapsable.
          final errors = await _withErrorCapture(() async {
            trajectory.value = _makeTrajectory();
            await tester.pump(); // procesa el markNeedsBuild
            await tester.pump(const Duration(milliseconds: 50)); // layout
            await tester.pump(const Duration(milliseconds: 50)); // paint extra
          });

          expect(
            errors,
            isEmpty,
            reason:
                'El framework lanzó errores durante la transición null → career:\n'
                '${errors.map((e) => e.exceptionAsString()).join('\n\n')}',
          );
          expect(find.byType(ErrorWidget), findsNothing,
              reason: 'Pantalla roja después de la transición null → career');

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 5 ──────────────────────────────────────────────────────────
      testWidgets(
        '5. Cambiar carrera seleccionada no produce pantalla roja',
        (tester) async {
          final carrera2 = _makeCareer(
            id: 'career-2',
            nombre: 'Licenciatura en Sistemas',
            materias: [_makeMateria('m3', 'Programación I')],
          );
          final traj = _makeTrajectory(
            carreras: [_makeCareer(), carrera2],
          );
          final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(traj);
          final localLoaded = ValueNotifier<bool>(true);
          final selectedCareer = ValueNotifier<int>(0);

          await tester.pumpWidget(_buildSubject(
            trajectory: trajectory,
            localLoaded: localLoaded,
            selectedCareer: selectedCareer,
          ));
          await tester.pump();

          final errors = await _withErrorCapture(() async {
            selectedCareer.value = 1;
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          });

          expect(errors, isEmpty,
              reason: 'Errores al cambiar carrera: '
                  '${errors.map((e) => e.exceptionAsString()).join(', ')}');
          expect(find.byType(ErrorWidget), findsNothing);

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 6 ──────────────────────────────────────────────────────────
      testWidgets(
        '6. career → null (ej: logout) no produce pantalla roja',
        (tester) async {
          final trajectory =
              ValueNotifier<TrayectoriaSageLaboratorio?>(_makeTrajectory());
          final localLoaded = ValueNotifier<bool>(true);
          final selectedCareer = ValueNotifier<int>(0);

          await tester.pumpWidget(_buildSubject(
            trajectory: trajectory,
            localLoaded: localLoaded,
            selectedCareer: selectedCareer,
          ));
          await tester.pump();

          // Transición inversa: career → null (ej. usuario limpia datos).
          final errors = await _withErrorCapture(() async {
            trajectory.value = null;
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 50));
          });

          expect(errors, isEmpty,
              reason: 'Errores en transición career → null: '
                  '${errors.map((e) => e.exceptionAsString()).join(', ')}');
          expect(find.byType(ErrorWidget), findsNothing);

          trajectory.dispose();
          localLoaded.dispose();
          selectedCareer.dispose();
        },
      );

      // ── Test 7: PantallaLaboratorioAtlassian ────────────────────────────
      testWidgets(
        '7. Navegación completa en PantallaLaboratorioAtlassian (transiciones entre pestañas)',
        (tester) async {
          final errors = await _withErrorCapture(() async {
            await tester.pumpWidget(const MaterialApp(
              home: Scaffold(
                body: PantallaLaboratorioAtlassian(),
              ),
            ));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));
          });

          expect(find.byType(ErrorWidget), findsNothing);
          expect(errors, isEmpty,
              reason: 'Errores al construir PantallaLaboratorioAtlassian: '
                  '${errors.map((e) => e.exceptionAsString()).join(', ')}');
        },
      );
    },
  );
}
