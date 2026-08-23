import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/tema/tema_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/documentos_pdf/modelos_documento_academico_pdf.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/documentos_pdf/vista_documento_academico_nativo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filtra pendientes y conserva el dock del PDF', (tester) async {
    var originalPdfCalls = 0;
    await tester.binding.setSurfaceSize(const Size(430, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: temaLaboratorioAtlassian(context),
            child: Scaffold(
              body: VistaDocumentoAcademicoNativo(
                documento: _situacionAcademica(),
              ),
              bottomNavigationBar: DockDocumentoAcademicoNativo(
                onCompartir: () {},
                onVerPdfOriginal: () => originalPdfCalls++,
                onAbrirExternamente: () {},
                reduceMotion: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('situación'), findsOneWidget);
    expect(find.text('académica'), findsOneWidget);
    expect(find.text('documento sage'), findsNothing);
    expect(
      find.text('vista reconstruida desde el PDF oficial de SAGE'),
      findsNothing,
    );
    expect(find.text('aprobadas'), findsWidgets);
    expect(find.text('cursando'), findsWidgets);
    expect(find.text('pendientes'), findsWidgets);
    expect(
      find.byKey(const Key('document-situation-scroll-stack')),
      findsOneWidget,
    );
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byType(ExpansionTile), findsNothing);

    final dockSurface = find.byKey(const Key('document-dock-surface'));
    expect(dockSurface, findsOneWidget);
    expect(tester.getSize(dockSurface).height, 74);
    expect(tester.getSize(dockSurface).width, lessThanOrEqualTo(316));
    expect(find.byKey(const Key('document-dock-ambient-glow')), findsOneWidget);

    final pdfIndicator = find.byKey(
      const ValueKey('document-action-indicator-pdf'),
    );
    expect(pdfIndicator, findsOneWidget);
    expect(tester.getSize(pdfIndicator).width, 20);

    final pdfIcon = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('document-action-icon-pdf')),
    );
    final pdfDecoration = pdfIcon.decoration! as BoxDecoration;
    expect(pdfDecoration.shape, BoxShape.circle);
    expect(pdfDecoration.gradient, isNotNull);

    final pdfAction = find.byKey(const Key('document-action-original-pdf'));
    await tester.tap(pdfAction);
    expect(originalPdfCalls, 1);

    final pendingFilter = find.byKey(
      const Key('document-filter-status-pending'),
    );
    await tester.ensureVisible(pendingFilter);
    await tester.tap(pendingFilter);
    await tester.pumpAndSettle();

    expect(find.text('Materia Aprobada'), findsNothing);
    expect(find.text('Materia Pendiente'), findsOneWidget);
    expect(find.text('pendiente'), findsWidgets);
  });

  testWidgets('ordena el analítico por nota y sale del carrusel por año', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: temaLaboratorioAtlassian(context),
            child: Scaffold(
              body: VistaDocumentoAcademicoNativo(documento: _analitico()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('document-analytic-year-carousel')),
      findsOneWidget,
    );
    expect(find.text('primer registro'), findsOneWidget);
    expect(find.text('primera aprobación'), findsNothing);

    final gradeSort = find.byKey(const Key('document-sort-grade'));
    await tester.ensureVisible(gradeSort);
    await tester.tap(gradeSort);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('document-analytic-year-carousel')),
      findsNothing,
    );
    expect(find.byIcon(Icons.north_east_rounded), findsNothing);

    final high = find.text('Materia Nota Diez');
    final low = find.text('Materia Nota Siete');
    expect(high, findsOneWidget);
    expect(low, findsOneWidget);
    final highOffset = tester.getTopLeft(high);
    final lowOffset = tester.getTopLeft(low);
    final highComesFirst =
        highOffset.dy < lowOffset.dy ||
        ((highOffset.dy - lowOffset.dy).abs() < 1 &&
            highOffset.dx < lowOffset.dx);
    expect(highComesFirst, isTrue);
  });

  testWidgets('respeta el margen superior para el botón flotante', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VistaDocumentoAcademicoNativo(
            documento: _analitico(),
            topPadding: 120,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('certificado');
    expect(title, findsOneWidget);
    expect(tester.getTopLeft(title).dy, greaterThanOrEqualTo(120));
  });

  testWidgets('situación académica no desborda en un teléfono angosto', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.15)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Theme(
            data: temaLaboratorioAtlassian(context),
            child: Scaffold(
              body: VistaDocumentoAcademicoNativo(
                documento: _situacionAcademica(),
              ),
              bottomNavigationBar: DockDocumentoAcademicoNativo(
                onCompartir: () {},
                onVerPdfOriginal: () {},
                onAbrirExternamente: () {},
                reduceMotion: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

DocumentoAcademicoPdf _situacionAcademica() {
  return const DocumentoAcademicoPdf(
    tipo: TipoDocumentoAcademicoPdf.situacionAcademica,
    alumno: 'PERSONA DE PRUEBA',
    documento: '00000000',
    establecimiento: 'INSTITUTO DE PRUEBA',
    carrera: 'PROFESORADO DE PRUEBA',
    fechaEmision: '21/8/2026',
    condicionAlumno: 'REGULAR',
    materias: <MateriaDocumentoAcademicoPdf>[
      MateriaDocumentoAcademicoPdf(
        nombre: 'MATERIA APROBADA',
        anio: 1,
        estado: 'Aprobada',
        fechaMovimiento: '17/11/2025',
        nota: '8.00',
      ),
      MateriaDocumentoAcademicoPdf(
        nombre: 'MATERIA EN CURSO',
        anio: 3,
        estado: 'Cursando',
        fechaMovimiento: '17/03/2026',
      ),
      MateriaDocumentoAcademicoPdf(nombre: 'MATERIA PENDIENTE', anio: 4),
    ],
  );
}

DocumentoAcademicoPdf _analitico() {
  return const DocumentoAcademicoPdf(
    tipo: TipoDocumentoAcademicoPdf.analitico,
    alumno: 'PERSONA DE PRUEBA',
    documento: '00000000',
    establecimiento: 'INSTITUTO DE PRUEBA',
    carrera: 'PROFESORADO DE PRUEBA',
    fechaEmision: '21/8/2026',
    condicionAlumno: 'REGULAR',
    promedioOficial: '8.50',
    materias: <MateriaDocumentoAcademicoPdf>[
      MateriaDocumentoAcademicoPdf(
        nombre: 'MATERIA NOTA SIETE',
        anio: 1,
        estado: 'Aprobada',
        fechaMovimiento: '17/11/2025',
        nota: '7.00',
      ),
      MateriaDocumentoAcademicoPdf(
        nombre: 'MATERIA NOTA DIEZ',
        anio: 2,
        estado: 'Aprobada',
        fechaMovimiento: '18/12/2025',
        nota: '10.00',
      ),
    ],
  );
}
