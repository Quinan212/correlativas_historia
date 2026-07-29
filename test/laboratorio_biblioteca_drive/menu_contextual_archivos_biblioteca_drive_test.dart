import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantener presionado un archivo abre las acciones de Biblioteca', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('onLongPress'));
    expect(source, contains('Guardar en el dispositivo'));
    expect(source, contains("label: 'Compartir'"));
    expect(source, contains('Eliminar descarga sin conexión'));
  });

  test('Android exporta con el selector del sistema sin permisos amplios', () {
    final mainActivity = File(
      'android/app/src/main/kotlin/ar/maillet/'
      'correlativas_historia/MainActivity.kt',
    ).readAsStringSync(encoding: utf8);
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync(encoding: utf8);

    expect(mainActivity, contains('Intent.ACTION_CREATE_DOCUMENT'));
    expect(mainActivity, contains('saveFileToDevice'));
    expect(mainActivity, contains('contentResolver.openOutputStream'));
    expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
  });

  test('el repositorio permite eliminar solo la copia privada', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/datos/'
      'repositorio_biblioteca_drive.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('Future<bool> eliminarDescarga'));
    expect(source, contains('destination.delete()'));
    expect(source, contains('legacy.delete()'));
  });
}
