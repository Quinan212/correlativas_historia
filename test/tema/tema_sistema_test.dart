import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el modo de tema inicial sigue la configuracion del sistema', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(proveedorModoTema), ThemeMode.system);
  });

  test('el control manual fuerza claro cuando el tema efectivo es oscuro', () {
    expect(modoTemaOpuestoPara(Brightness.dark), ThemeMode.light);
  });

  test('el control manual fuerza oscuro cuando el tema efectivo es claro', () {
    expect(modoTemaOpuestoPara(Brightness.light), ThemeMode.dark);
  });
}
