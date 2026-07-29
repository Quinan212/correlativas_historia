import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la fila diferencia archivos pendientes y disponibles sin conexión', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('Icons.download_rounded'));
    expect(source, contains('Icons.check_circle_rounded'));
    expect(source, contains('_downloadedItemIds.contains(item.id)'));
  });

  test('el repositorio puede consultar la descarga local sin usar red', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/datos/'
      'repositorio_biblioteca_drive.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('Future<bool> estaDescargado'));
    expect(source, contains('Future<File?> obtenerArchivoDescargado'));
    expect(source, contains('_legacyDestinationFor'));
  });
}
