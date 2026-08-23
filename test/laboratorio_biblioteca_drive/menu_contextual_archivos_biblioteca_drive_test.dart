import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantener presionado abre un menú flotante anclado al archivo', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('onLongPressStart'));
    expect(source, contains('details.globalPosition'));
    expect(source, contains('showGeneralDialog<_AccionArchivoBiblioteca>'));
    expect(source, contains('_MenuFlotanteAccionesArchivoBiblioteca'));
    expect(source, contains('_MenuFlotanteArchivoLayoutDelegate'));
    expect(source, contains('CustomSingleChildLayout'));
    expect(source, isNot(contains('mostrarHojaAtlassian')));
  });

  test('el menú flotante conserva todas las acciones de archivo', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains("label: 'Abrir'"));
    expect(source, contains("label: 'Guardar en el dispositivo'"));
    expect(source, contains("label: 'Compartir'"));
    expect(source, contains("'Eliminar descarga sin conexión'"));
    expect(source, contains('onTap: () => Navigator.of(context).pop()'));
  });

  test('el menú flotante usa el sistema visual Atlassian', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);

    expect(source, contains('temaLaboratorioAtlassian(context)'));
    expect(source, contains('data: atlassianTheme'));
    expect(source, contains('EspacioAtlassian.sm'));
    expect(source, contains('RadioAtlassian.medium'));
    expect(source, contains('Border.all(color: scheme.outlineVariant)'));
    expect(source, contains('surfaceTintColor: Colors.transparent'));
    expect(source, contains('scheme.surfaceContainerHigh'));
    expect(source, isNot(contains('elevation: 14')));
  });

  test('el menú muestra solo las acciones y se cierra desde afuera', () {
    final source = File(
      'lib/funcionalidades/laboratorio_biblioteca_drive/pantallas/'
      'pantalla_carpeta_biblioteca_drive_atlassian.dart',
    ).readAsStringSync(encoding: utf8);
    final menuStart = source.indexOf(
      'class _MenuFlotanteAccionesArchivoBiblioteca',
    );
    final menuEnd = source.indexOf('class _MenuFlotanteArchivoLayoutDelegate');
    final menuSource = source.substring(menuStart, menuEnd);

    expect(menuSource, isNot(contains('item.visibleName')));
    expect(menuSource, isNot(contains("tooltip: 'Cerrar'")));
    expect(menuSource, isNot(contains('Icons.close_rounded')));
    expect(menuSource, contains('onTap: () => Navigator.of(context).pop()'));
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
