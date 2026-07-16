import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('eliminar está en el editor y no en la tarjeta de la lista', () {
    final String cardSource = File(
      'lib/funcionalidades/acceso_estudiante/componentes/'
      'tarjeta_materia_propia.dart',
    ).readAsStringSync();
    final String editorSource = File(
      'lib/funcionalidades/acceso_estudiante/pantallas/'
      'pagina_editor_materia_propia.dart',
    ).readAsStringSync();

    expect(
      cardSource,
      isNot(contains('Icons.delete_outline_rounded')),
    );
    expect(
      editorSource,
      allOf(
        contains('widget.canDelete'),
        contains("const Text('Eliminar')"),
        contains("<String, dynamic>{'delete': true}"),
      ),
    );
  });
}
