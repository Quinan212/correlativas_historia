import 'package:correlativas_historia/tema/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el selector de fecha usa el diseño de la app', () {
    final ThemeData theme = TemaApp.light();
    final DatePickerThemeData picker = theme.datePickerTheme;

    expect(picker.headerBackgroundColor, theme.colorScheme.primary);
    expect(picker.surfaceTintColor, Colors.transparent);
    expect(
      (picker.shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(28),
    );
  });

  test('la localización del selector está en español', () async {
    final MaterialLocalizations labels =
        await GlobalMaterialLocalizations.delegate.load(
      const Locale('es', 'AR'),
    );

    expect(labels.cancelButtonLabel.toLowerCase(), 'cancelar');
    expect(labels.okButtonLabel.toLowerCase(), 'aceptar');
  });
}
