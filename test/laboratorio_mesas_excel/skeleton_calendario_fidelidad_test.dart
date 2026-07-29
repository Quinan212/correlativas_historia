import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Calendario Excel usa la geometría real del calendario Atlassian', () {
    final source = File(
      'lib/funcionalidades/laboratorio_mesas_excel/pantallas/'
      'pantalla_calendario_excel_atlassian.dart',
    ).readAsStringSync();

    expect(source, contains('visibleMonth: _visibleMonth,'));
    expect(source, contains('selectedDay: _selectedDay,'));
    expect(source, contains('const _WeekdayHeaderAtlassian()'));
    expect(source, contains('_MonthGridAtlassian('));
    expect(source, contains('SeparadorTituloAtlassian('));
    expect(source, contains('next: firstEvent,'));
    expect(
      source,
      contains('PanelAtlassian(\n            padding: EdgeInsets.zero,'),
    );

    expect(source, isNot(contains('for (var r = 0; r < 4; r++)')));
    expect(source, isNot(contains('next: null')));
    expect(
      source,
      isNot(contains("['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']")),
    );
  });
}
