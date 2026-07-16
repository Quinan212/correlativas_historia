import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/**/*.dart no contiene secuencias de mojibake conocidas', () {
    const suspiciousTokens = <String>[
      '\u00c3',
      '\u00c2',
      '\u0192',
      '\ufffd',
      '\u00e2\u20ac\u00a2',
      '\u00e2\u20ac\u201c',
      '\u00e2\u20ac\u201d',
      '\u0413',
      '\u0432',
      '\u0412',
    ];

    final libDir = Directory('lib');
    final issues = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final text = entity.readAsStringSync();
      for (final token in suspiciousTokens) {
        if (!text.contains(token)) continue;

        final line = text.split('\n').firstWhere(
              (candidate) => candidate.contains(token),
              orElse: () => '',
            );
        issues.add('${entity.path}: ${line.trim()}');
      }
    }

    expect(
      issues,
      isEmpty,
      reason:
          'Se encontraron secuencias de codificación rotas en fuentes Dart:\n${issues.join('\n')}',
    );
  });
}
