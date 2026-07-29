import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la biblioteca usa REST nativo y no depende de WebView o Supabase', () {
    final directory = Directory(
      'lib/funcionalidades/laboratorio_biblioteca_drive',
    );
    final source = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync(encoding: utf8))
        .join('\n');

    expect(source, isNot(contains('webview_flutter')));
    expect(source, isNot(contains('supabase_flutter')));
    expect(source, contains('www.googleapis.com'));
  });

  test('el acceso aparece debajo de la tarjeta SAGE del laboratorio Excel', () {
    final source = File(
      'lib/funcionalidades/laboratorio_mesas_excel/pantallas/'
      'pantalla_inicio_mesas_excel_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    final sageIndex = source.indexOf("label: 'Abrir SAGE'");
    final libraryIndex = source.indexOf('Biblioteca académica');

    expect(sageIndex, greaterThanOrEqualTo(0));
    expect(libraryIndex, greaterThan(sageIndex));
    expect(source, contains('PantallaBibliotecaDriveAtlassian'));
  });
}
