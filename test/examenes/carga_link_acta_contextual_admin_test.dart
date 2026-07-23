import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final screen = File(
    'lib/funcionalidades/laboratorio_atlassian/pantallas/'
    'pantalla_examenes_atlassian.dart',
  );
  final repository = File(
    'lib/funcionalidades/administrador/datos/'
    'repositorio_eventos_examen_administrador.dart',
  );

  test('una mesa sin acta permite cargar el enlace en cualquier estado', () {
    final source = screen.readAsStringSync();

    expect(source, contains("labelText: 'Enlace al acta'"));
    expect(source, contains("tooltip: 'Pegar enlace'"));
    expect(source, contains('Clipboard.getData(Clipboard.kTextPlain)'));
    expect(source, contains("uri.scheme == 'http' || uri.scheme == 'https'"));
    expect(source, contains('final isAddingActUrl = !_hadActUrl;'));
  });

  test('el control del acta conserva su valor al cambiar el estado', () {
    final source = screen.readAsStringSync();

    expect(source, contains('_actEnabled = widget.event.actaHabilitada;'));
    expect(
      source,
      contains('final canEnableAct = _hadActUrl || _hasValidActUrl;'),
    );
    expect(source, isNot(contains('if (status != EstadoEventoExamen.activa)')));
  });

  test('el enlace cargado habilita el acta al guardar', () {
    final source = screen.readAsStringSync();

    expect(source, contains('actUrl: result.actUrl'));
    expect(source, contains('required this.actUrl'));
    expect(source, contains('_actEnabled = _hasValidActUrl'));
    expect(
      source,
      contains('actEnabled: _actEnabled && (actUrl?.isNotEmpty ?? false)'),
    );
  });

  test('el repositorio envía acta_habilitada sin depender del estado', () {
    final source = repository.readAsStringSync();

    expect(source, contains('required String? actUrl'));
    expect(source, contains("'acta_url': normalizedActUrl"));
    expect(source, contains("'acta_habilitada': actEnabled"));
    expect(
      source,
      isNot(contains("'acta_habilitada': status == EstadoEventoExamen.activa")),
    );
  });
}
