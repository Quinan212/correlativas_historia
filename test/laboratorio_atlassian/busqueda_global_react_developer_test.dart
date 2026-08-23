import 'dart:convert';
import 'dart:io';

import 'package:correlativas_historia/funcionalidades/curriculum/proveedores/proveedores_curriculum.dart';
import 'package:correlativas_historia/funcionalidades/examenes/modelos/evento_examen.dart';
import 'package:correlativas_historia/funcionalidades/examenes/proveedores/proveedores_examenes.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/busqueda/modelos_busqueda_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/busqueda/pantalla_busqueda_global_react_developer.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:correlativas_historia/modelos/contenido_curricular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el clon React abre SAGE y separa cerrar sesión de Salir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 980);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const career = CarreraTrayectoriaSageLaboratorio(
      gridRowId: 'historia',
      careerKey: 'historia-pscs',
      nombre: 'Profesorado de Historia',
      institucion: 'Profesorado Superior de Ciencias Sociales',
      materias: <MateriaTrayectoriaSageLaboratorio>[
        MateriaTrayectoriaSageLaboratorio(
          idSage: '1',
          nombre: 'Historia de las Ideas',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
          anio: 1,
        ),
      ],
    );
    final trajectory = ValueNotifier<TrayectoriaSageLaboratorio?>(
      TrayectoriaSageLaboratorio(
        perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
        carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
        capturadaEn: DateTime(2026, 8, 21),
        sincronizadaEn: DateTime(2026, 8, 21, 15),
      ),
    );
    final selectedCareer = ValueNotifier<int>(0);
    addTearDown(trajectory.dispose);
    addTearDown(selectedCareer.dispose);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    DestinoBusquedaAtlassian? opened;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proveedorTodosLosExamenes.overrideWith(
            (ref) async => const <EventoExamen>[],
          ),
          proveedorContenidosCurriculares.overrideWith(
            (ref) async => const <ContenidoCurricular>[],
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: PantallaBusquedaGlobalReactDeveloper(
            trajectoryListenable: trajectory,
            selectedCareerListenable: selectedCareer,
            onOpenDestination: (destination) async {
              opened = destination;
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('busqueda-react-magic-bento')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('busqueda-react-liquid-field')),
      findsOneWidget,
    );
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration?.filled, isFalse);
    expect(textField.decoration?.fillColor, Colors.transparent);
    expect(textField.decoration?.border, InputBorder.none);
    expect(textField.decoration?.enabledBorder, InputBorder.none);
    expect(textField.decoration?.focusedBorder, InputBorder.none);
    expect(textField.decoration?.contentPadding, EdgeInsets.zero);
    expect(textField.decoration?.isCollapsed, isTrue);
    expect(textField.decoration?.hintText, 'Buscar en Trayectorias…');

    await tester.tap(find.byKey(const ValueKey('busqueda-react-sage-card')));
    await tester.pump(const Duration(milliseconds: 280));
    expect(find.text('abrir sage'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abrir sage');
    await tester.pump(const Duration(milliseconds: 190));
    await tester.tap(find.text('Abrir SAGE').first);
    await tester.pump();
    expect(opened?.tipo, TipoDestinoBusquedaAtlassian.sage);

    opened = null;
    await tester.enterText(find.byType(TextField), 'cerrar sesión');
    await tester.pump(const Duration(milliseconds: 190));

    expect(find.text('Cerrar sesión de SAGE'), findsAtLeastNWidgets(1));
    expect(find.text('Salir'), findsNothing);
    expect(
      find.byKey(const ValueKey('busqueda-react-gooey-filter')),
      findsOneWidget,
    );

    opened = null;
    await tester.enterText(find.byType(TextField), 'el analitico academico');
    await tester.pump(const Duration(milliseconds: 190));
    expect(find.text('Analítico'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Analítico').first);
    await tester.pump();
    expect(opened?.tipo, TipoDestinoBusquedaAtlassian.documentoAcademico);
    expect(opened?.tipoDocumento, TipoDocumentoAcademicoSage.analitico);

    opened = null;
    await tester.enterText(find.byType(TextField), 'la libreta academica');
    await tester.pump(const Duration(milliseconds: 190));
    expect(find.text('Libreta'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Libreta').first);
    await tester.pump();
    expect(opened?.tipo, TipoDestinoBusquedaAtlassian.documentoAcademico);
    expect(opened?.tipoDocumento, TipoDocumentoAcademicoSage.libreta);

    opened = null;
    await tester.enterText(find.byType(TextField), 'resumen academico');
    await tester.pump(const Duration(milliseconds: 190));
    expect(find.text('Situación académica'), findsAtLeastNWidgets(1));
    await tester.tap(find.text('Situación académica').first);
    await tester.pump();
    expect(opened?.tipo, TipoDestinoBusquedaAtlassian.documentoAcademico);
    expect(
      opened?.tipoDocumento,
      TipoDocumentoAcademicoSage.situacionAcademica,
    );

    trajectory.value = null;
    await tester.enterText(find.byType(TextField), 'desincronizar');
    await tester.pump(const Duration(milliseconds: 190));
    expect(find.text('Desincronizar trayectoria'), findsNothing);
  });

  test('la búsqueda React corrige caché, teclado y sugerencias temporales', () {
    final source = File(
      'lib/funcionalidades/laboratorio_atlassian/busqueda/'
      'pantalla_busqueda_global_react_developer.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('ValueListenableBuilder<int>'));
    expect(source, contains('_trajectoryFingerprint('));
    expect(source, contains('resizeToAvoidBottomInset: true'));
    expect(source, contains("title: 'Abrir SAGE'"));
    expect(source, contains("title: 'Situación académica'"));
    expect(source, contains("title: 'Analítico'"));
    expect(source, contains("title: 'Libreta'"));
    expect(source, contains('TipoDestinoBusquedaAtlassian.documentoAcademico'));
    expect(source, contains('if (!action.enabled) continue;'));
    expect(source, contains('monthNameAtlassian(targetMonth)'));
    expect(source, isNot(contains("'Mesas de agosto'")));
    expect(source, contains('busqueda-react-career-carousel'));
    expect(source, contains('busqueda-react-gooey-filter'));
    expect(source, contains('InputDecoration.collapsed('));
    expect(source, contains('filled: false'));
    expect(source, contains('fillColor: Colors.transparent'));
    expect(source, contains('enabledBorder: InputBorder.none'));
    expect(source, contains('focusedBorder: InputBorder.none'));
    expect(source, contains('contentPadding: EdgeInsets.zero'));
    expect(source, contains('maxWidth: MediaQuery.sizeOf(context).width - 78'));
    expect(source, contains('overflow: TextOverflow.ellipsis'));
    expect(source, contains('assets/sage_wordmark_react.png'));
    expect(source, isNot(contains('Icons.hub_rounded')));
    expect(source, contains("subtitle: 'Mesas y fechas publicadas'"));
    expect(source, contains("subtitle: 'Mesas y llamados'"));
    expect(source, contains("subtitle: 'Materias y correlatividades'"));
    expect(source, contains("subtitle: 'Estados de tu trayectoria'"));
    expect(source, contains("subtitle: 'Perfil y carreras'"));
    expect(source, contains('action: data,\n                height: 148'));
    expect(
      source,
      contains(
        'action: plan,\n          height: 104,\n          horizontal: true',
      ),
    );
    expect(source, contains("primary: 'elegí la'"));
    expect(source, contains("accent: 'institución'"));
    expect(source, contains('logo_pscs_overlay_circular.png'));
    expect(source, contains('logo_artes_circular.png'));
    expect(source, contains('_careerWatermarkAsset(career)'));
    expect(source, contains('clipBehavior: Clip.antiAlias'));
    expect(source, contains('Positioned.fill('));
    expect(source, contains('Transform.translate('));
    expect(source, contains('alignment: Alignment.bottomRight'));
    expect(source, contains('offset: const Offset(18, 18)'));
    expect(source, contains('width: 230'));
    expect(source, isNot(contains('EdgeInsets.only(right: -10)')));
    expect(source, isNot(contains('ClipOval(')));
    expect(
      source,
      isNot(contains('width: 50,\n                          height: 50')),
    );
  });

  test(
    'el Inicio React abre el clon y la búsqueda principal queda intacta',
    () {
      final shell = File(
        'lib/funcionalidades/laboratorio_atlassian/pantallas/'
        'pantalla_laboratorio_atlassian.dart',
      ).readAsStringSync(encoding: utf8);
      final home = File(
        'lib/funcionalidades/laboratorio_atlassian/pantallas/'
        'pantalla_inicio_atlassian.dart',
      ).readAsStringSync(encoding: utf8);
      final original = File(
        'lib/funcionalidades/laboratorio_atlassian/busqueda/'
        'pantalla_busqueda_global_atlassian.dart',
      ).readAsStringSync(encoding: utf8);

      expect(shell, contains('PantallaBusquedaGlobalReactDeveloper('));
      expect(shell, contains('onSearch: _openReactSearch'));
      expect(home, contains('(widget.onReactSearch ?? widget.onSearch)();'));
      expect(original, contains('class PantallaBusquedaGlobalAtlassian'));
    },
  );
}
