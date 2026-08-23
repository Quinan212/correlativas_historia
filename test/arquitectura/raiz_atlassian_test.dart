import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el shell principal abre directamente el Inicio React', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final shellSource = File(
      'lib/funcionalidades/laboratorio_atlassian/pantallas/'
      'pantalla_laboratorio_atlassian.dart',
    ).readAsStringSync();

    expect(
      mainSource,
      contains('home: const PantallaLaboratorioAtlassian(hideExit: true)'),
    );
    expect(shellSource, contains('PantallaInicioReactDeveloper('));
    expect(shellSource, isNot(contains('PantallaInicioAtlassian(')));
    expect(
      shellSource,
      contains('showFloatingSearch = allowBlursAndSearch && _section != 0'),
    );
    expect(mainSource, isNot(contains('NavegacionInferiorApp')));
    expect(mainSource, isNot(contains('proveedorIndiceRouter')));
    expect(mainSource, isNot(contains('proveedorSeccionNav')));
    expect(mainSource, isNot(contains('PantallaShellPrincipalLegacy')));
  });

  test('el shell anterior permanece preservado y desconectado', () {
    final legacy = File(
      'lib/funcionalidades/legacy/navegacion/'
      'pantalla_shell_principal_legacy.dart',
    );

    expect(legacy.existsSync(), isTrue);
    final source = legacy.readAsStringSync();
    expect(source, contains('class PantallaShellPrincipalLegacy'));
    expect(source, contains('NavegacionInferiorApp'));
  });
}
