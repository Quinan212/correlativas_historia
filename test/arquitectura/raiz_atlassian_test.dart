import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Atlassian es la única raíz registrada en main.dart', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains('home: const PantallaLaboratorioAtlassian(hideExit: true)'),
    );
    expect(source, isNot(contains('NavegacionInferiorApp')));
    expect(source, isNot(contains('proveedorIndiceRouter')));
    expect(source, isNot(contains('proveedorSeccionNav')));
    expect(source, isNot(contains('PantallaShellPrincipalLegacy')));
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
