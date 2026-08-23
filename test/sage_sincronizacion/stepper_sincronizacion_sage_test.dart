import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/sage/modelos_sincronizacion_sage_automatica.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/sage/pantalla_sincronizacion_sage_automatica.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(EstadoSincronizacionSageAutomatica estado) {
    return MaterialApp(
      home: PantallaSincronizacionSageAutomatica(
        estado: estado,
        loginDisponible: false,
        procesandoCredenciales: false,
        onIngresar: (_, _) async {},
        onReintentar: () {},
        onCancelar: () {},
      ),
    );
  }

  testWidgets('muestra un riel de cuatro etapas y explica solo la etapa actual', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        const EstadoSincronizacionSageAutomatica(
          etapa: EtapaSincronizacionSageAutomatica.abriendoHistorial,
          titulo: 'Leyendo historial',
          detalle: 'Preparando los datos académicos…',
          progreso: 0.62,
          paso: PasoSincronizacionSageAutomatica.historial,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey<String>('sage-sync-stepper')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-stepper-rail')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('sage-sync-step-0-completada'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('sage-sync-step-1-completada'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-2-activa')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-3-pendiente')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-loading-2')),
      findsOneWidget,
    );
    expect(find.text('Sincronización con SAGE'), findsOneWidget);
    expect(find.text('Paso 3 de 4'), findsOneWidget);
    expect(find.text('Trayectoria académica'), findsOneWidget);
    expect(find.text('Preparando los datos académicos…'), findsOneWidget);
    expect(find.text('Leyendo historial'), findsNothing);
    expect(find.text('Acceso a SAGE'), findsNothing);
    expect(find.text('Perfil y legajo'), findsNothing);
    expect(find.text('Documentos y guardado'), findsNothing);
    expect(find.text('Completado'), findsNothing);
    expect(find.text('En curso'), findsNothing);
    expect(find.text('Pendiente'), findsNothing);
  });

  testWidgets('anima el marcador activo y mantiene estable el área de contenido', (
    WidgetTester tester,
  ) async {
    const firstState = EstadoSincronizacionSageAutomatica(
      etapa: EtapaSincronizacionSageAutomatica.abriendoLegajo,
      titulo: 'Abriendo Legajo Único Alumno',
      detalle: 'Ingresando al módulo académico…',
      progreso: 0.36,
      paso: PasoSincronizacionSageAutomatica.legajo,
      sesionReutilizada: true,
    );
    const secondState = EstadoSincronizacionSageAutomatica(
      etapa: EtapaSincronizacionSageAutomatica.abriendoLegajo,
      titulo: 'Abriendo Legajo Único Alumno',
      detalle: 'Ingresando a Legajo Alumnos con el perfil Docente…',
      progreso: 0.38,
      paso: PasoSincronizacionSageAutomatica.legajo,
      sesionReutilizada: true,
    );
    const contentKey = ValueKey<String>('sage-sync-step-content');

    await tester.pumpWidget(buildSubject(firstState));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-loading-1')),
      findsOneWidget,
    );
    expect(find.text('Perfil y legajo'), findsOneWidget);
    expect(find.text('Sesión reutilizada'), findsOneWidget);
    final heightBefore = tester.getSize(find.byKey(contentKey)).height;
    final progressTopBefore = tester
        .getTopLeft(find.byType(LinearProgressIndicator))
        .dy;

    await tester.pumpWidget(buildSubject(secondState));
    await tester.pump(const Duration(milliseconds: 250));

    final heightAfter = tester.getSize(find.byKey(contentKey)).height;
    final progressTopAfter = tester
        .getTopLeft(find.byType(LinearProgressIndicator))
        .dy;
    expect(heightAfter, heightBefore);
    expect(progressTopAfter, closeTo(progressTopBefore, 0.1));
    expect(
      find.text('Ingresando a Legajo Alumnos con el perfil Docente…'),
      findsOneWidget,
    );
  });

  testWidgets('marca el error sin repetir estados en el contenido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        const EstadoSincronizacionSageAutomatica(
          etapa: EtapaSincronizacionSageAutomatica.error,
          titulo: 'No se pudo cargar',
          detalle: 'SAGE no pudo abrir el legajo.',
          permiteReintentar: true,
          paso: PasoSincronizacionSageAutomatica.legajo,
          codigoError: CodigoErrorSincronizacionSage.abrirLegajo,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(
        const ValueKey<String>('sage-sync-step-0-completada'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-1-error')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('sage-sync-step-2-pendiente')),
      findsOneWidget,
    );
    expect(find.text('Atención requerida'), findsOneWidget);
    expect(find.text('Perfil y legajo'), findsOneWidget);
    expect(find.text('SAGE no pudo abrir el legajo.'), findsOneWidget);
    expect(find.text('SAGE-LEGAJO-02'), findsOneWidget);
    expect(find.text('Requiere atención'), findsNothing);
    expect(find.text('Reintentar este paso'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('muestra las cuatro etapas completadas al finalizar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        const EstadoSincronizacionSageAutomatica(
          etapa: EtapaSincronizacionSageAutomatica.completada,
          titulo: 'Sincronización completa',
          detalle: 'Los datos quedaron actualizados.',
          progreso: 1,
          paso: PasoSincronizacionSageAutomatica.guardado,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    for (var index = 0; index < 4; index++) {
      expect(
        find.byKey(
          ValueKey<String>('sage-sync-step-$index-completada'),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('Finalizado'), findsOneWidget);
    expect(find.text('Sincronización completa'), findsOneWidget);
    expect(find.text('Los datos quedaron actualizados.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
