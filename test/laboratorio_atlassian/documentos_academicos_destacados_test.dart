import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/busqueda/modelos_busqueda_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_inicio_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required Set<TipoDocumentoAcademicoSage> availableTypes,
    bool docente = false,
    bool disableAnimations = false,
  }) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const career = CarreraTrayectoriaSageLaboratorio(
      gridRowId: 'row-historia',
      careerKey: 'historia-pscs',
      nombre: 'Profesorado de Historia',
      institucion: 'Profesorado Superior de Ciencias Sociales',
      materias: <MateriaTrayectoriaSageLaboratorio>[
        MateriaTrayectoriaSageLaboratorio(
          idSage: 'ant',
          nombre: 'Antigüedad',
          estadoOriginal: 'Aprobada',
          estado: EstadoMateriaSageLaboratorio.aprobada,
        ),
      ],
    );

    final documents = <DocumentoAcademicoSage>[
      for (final type in TipoDocumentoAcademicoSage.values)
        if (docente || availableTypes.contains(type))
          DocumentoAcademicoSage(
            tipo: type,
            gridRowId: career.gridRowId,
            careerKey: career.careerKey,
            carrera: career.nombre,
            institucion: career.institucion,
            disponible: !docente,
          ),
    ];
    final trajectory = TrayectoriaSageLaboratorio(
      perfil: const PerfilTrayectoriaSageLaboratorio(nombre: 'Alan'),
      carreras: const <CarreraTrayectoriaSageLaboratorio>[career],
      documentos: documents,
      capturadaEn: DateTime(2026, 8, 20),
      sincronizadaEn: DateTime(2026, 8, 20, 12),
    );

    final trajectoryListenable =
        ValueNotifier<TrayectoriaSageLaboratorio?>(trajectory);
    final loadedListenable = ValueNotifier<bool>(true);
    final selectedCareerListenable = ValueNotifier<int>(0);
    final resetListenable = ValueNotifier<int>(0);
    final actionRequestListenable =
        ValueNotifier<SolicitudInicioAtlassian?>(null);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      trajectoryListenable.dispose();
      loadedListenable.dispose();
      selectedCareerListenable.dispose();
      resetListenable.dispose();
      actionRequestListenable.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: PantallaInicioAtlassian(
              trajectoryListenable: trajectoryListenable,
              localLoadedListenable: loadedListenable,
              selectedCareerListenable: selectedCareerListenable,
              resetListenable: resetListenable,
              actionRequestListenable: actionRequestListenable,
              onTrajectoryChanged: (_) {},
              onNavigate: (_) {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets(
    'muestra una bandeja horizontal compacta con las tres descargas',
    (tester) async {
      await pumpScreen(
        tester,
        availableTypes: TipoDocumentoAcademicoSage.values.toSet(),
      );

      expect(find.text('Documentos académicos'), findsOneWidget);
      expect(find.text('3 DISPONIBLES'), findsOneWidget);
      expect(find.text('Situación académica'), findsOneWidget);
      expect(find.text('Analítico'), findsOneWidget);
      expect(find.text('Libreta'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('academic-documents-dock')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.text('Documentos académicos')).dy,
        lessThan(tester.getTopLeft(find.text('Progreso general')).dy),
      );

      final actions = <Finder>[
        for (final type in TipoDocumentoAcademicoSage.values)
          find.byKey(ValueKey<String>('document-action-${type.clave}')),
      ];
      final offsets = <Offset>[];
      final sizes = <Size>[];
      for (final actionFinder in actions) {
        expect(actionFinder, findsOneWidget);
        final action = tester.widget<InkWell>(actionFinder);
        expect(action.onTap, isNotNull);
        offsets.add(tester.getTopLeft(actionFinder));
        sizes.add(tester.getSize(actionFinder));
      }

      expect(offsets[0].dy, closeTo(offsets[1].dy, 0.1));
      expect(offsets[1].dy, closeTo(offsets[2].dy, 0.1));
      expect(offsets[0].dx, lessThan(offsets[1].dx));
      expect(offsets[1].dx, lessThan(offsets[2].dx));
      expect(sizes[0].width, closeTo(sizes[1].width, 0.1));
      expect(sizes[1].width, closeTo(sizes[2].width, 0.1));
      expect(
        tester
            .getSize(find.byKey(const ValueKey('academic-documents-dock')))
            .height,
        lessThan(150),
      );
    },
  );

  testWidgets('resume los documentos bloqueados del Perfil Docente', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      availableTypes: const <TipoDocumentoAcademicoSage>{},
      docente: true,
    );

    expect(find.text('Documentos académicos'), findsOneWidget);
    expect(find.text('PERFIL DOCENTE'), findsOneWidget);
    expect(
      find.text('Disponibles desde el Perfil Estudiante de SAGE'),
      findsOneWidget,
    );
    expect(
      find.text('Situación académica · Analítico · Libreta'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('academic-documents-disabled-state')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('academic-documents-dock')), findsNothing);

    for (final type in TipoDocumentoAcademicoSage.values) {
      expect(
        find.byKey(ValueKey<String>('document-action-${type.clave}')),
        findsNothing,
      );
    }
  });

  testWidgets('conserva tres posiciones y bloquea solo documentos ausentes', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      availableTypes: const <TipoDocumentoAcademicoSage>{
        TipoDocumentoAcademicoSage.situacionAcademica,
        TipoDocumentoAcademicoSage.libreta,
      },
      disableAnimations: true,
    );

    expect(find.text('2 DE 3'), findsOneWidget);
    expect(find.text('Situación académica'), findsOneWidget);
    expect(find.text('Analítico'), findsOneWidget);
    expect(find.text('Libreta'), findsOneWidget);

    final situation = tester.widget<InkWell>(
      find.byKey(
        const ValueKey<String>('document-action-situacion_academica'),
      ),
    );
    final transcript = tester.widget<InkWell>(
      find.byKey(const ValueKey<String>('document-action-analitico')),
    );
    final record = tester.widget<InkWell>(
      find.byKey(const ValueKey<String>('document-action-libreta')),
    );

    expect(situation.onTap, isNotNull);
    expect(transcript.onTap, isNull);
    expect(record.onTap, isNotNull);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('document-action-analitico'),
        ),
        matching: find.byIcon(Icons.lock_outline_rounded),
      ),
      findsOneWidget,
    );
  });
}
