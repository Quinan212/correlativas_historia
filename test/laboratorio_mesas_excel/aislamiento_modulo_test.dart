import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el laboratorio Excel no depende de Supabase', () {
    final directory = Directory(
      'lib/funcionalidades/laboratorio_mesas_excel',
    );
    final files = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final content = file.readAsStringSync();
      expect(
        content.contains('supabase_flutter'),
        isFalse,
        reason: 'Dependencia externa encontrada en ${file.path}',
      );
    }
  });
}
