import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final screen = File(
    'lib/funcionalidades/laboratorio_atlassian/pantallas/'
    'pantalla_examenes_atlassian.dart',
  );

  test('el aviso de estado de la tarjeta ocupa una sola línea', () {
    final source = screen.readAsStringSync();

    final pattern = RegExp(
      r'event\.mensajeEstadoEfectivo,\s*'
      r'maxLines:\s*1,\s*'
      r'overflow:\s*TextOverflow\.ellipsis,\s*'
      r'softWrap:\s*false,',
    );

    expect(pattern.hasMatch(source), isTrue);
  });

  test('el detalle conserva el mensaje completo sin recorte forzado', () {
    final source = screen.readAsStringSync();

    final detailPattern = RegExp(
      r'event\.mensajeEstadoEfectivo,\s*'
      r'style:\s*Theme\.of\(context\)\.textTheme\.bodyMedium',
    );

    expect(detailPattern.hasMatch(source), isTrue);
  });
}
