import 'dart:io';

import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/funcionalidades/administrador/componentes/componentes_administrador_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/administrador/tema/tema_administrador_atlassian.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/tema/tema_atlassian.dart';
import 'package:correlativas_historia/tema/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el panel administrativo respeta el modo claro', (tester) async {
    late ThemeData resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.light(),
        home: Builder(
          builder: (context) {
            resolved = temaAdministradorAtlassian(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.brightness, Brightness.light);
    expect(resolved.colorScheme.primary, PaletaAtlassian.brand);
    expect(resolved.scaffoldBackgroundColor, PaletaAtlassian.canvasLight);
  });

  testWidgets('el panel administrativo respeta el modo oscuro', (tester) async {
    late ThemeData resolved;

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.dark(),
        home: Builder(
          builder: (context) {
            resolved = temaAdministradorAtlassian(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.brightness, Brightness.dark);
    expect(resolved.colorScheme.primary, PaletaAtlassian.brand);
    expect(resolved.scaffoldBackgroundColor, PaletaAtlassian.canvasDark);
  });

  testWidgets('el wrapper administrativo reconstruye el tema al cambiar modo', (
    tester,
  ) async {
    final mode = StateProvider<ThemeMode>((_) => ThemeMode.light);

    await tester.pumpWidget(_TemaAdminHarness(mode: mode));

    expect(find.text('light'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TemaAdministradorAtlassian)),
    );
    container.read(mode.notifier).state = ThemeMode.dark;
    await tester.pumpAndSettle();

    expect(find.text('dark'), findsOneWidget);
  });

  testWidgets('los avisos administrativos renderizan con ambos temas', (
    tester,
  ) async {
    Future<void> pump(ThemeData baseTheme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: baseTheme,
          home: Builder(
            builder: (context) => Theme(
              data: temaAdministradorAtlassian(context),
              child: const Scaffold(
                body: AvisoAdministradorAtlassian(
                  icon: Icons.warning_amber_rounded,
                  title: 'Mesa suspendida',
                  message: 'Mensaje de prueba',
                  level: NivelAvisoAdministrador.warning,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Mesa suspendida'), findsOneWidget);
      expect(find.text('Mensaje de prueba'), findsOneWidget);
    }

    await pump(TemaApp.light());
    await pump(TemaApp.dark());
  });

  test('el módulo administrador dejó de usar la paleta visual anterior', () {
    const legacyTokens = <String>[
      '0xFF030712',
      '0xFF0B1220',
      '0xFF243041',
      '0xFFE5E7EB',
      '0xFF161E2C',
      '0xFFF8FAFC',
      '0xFF0E5E86',
    ];

    final directory = Directory('lib/funcionalidades/administrador');
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      for (final token in legacyTokens) {
        expect(
          source.contains(token),
          isFalse,
          reason: '${file.path} todavía contiene $token',
        );
      }
    }
  });
}

class _TemaAdminHarness extends ConsumerWidget {
  const _TemaAdminHarness({required this.mode});

  final StateProvider<ThemeMode> mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [proveedorModoTema.overrideWith((ref) => ref.watch(mode))],
      child: Consumer(
        builder: (context, ref, child) => MaterialApp(
          theme: TemaApp.light(),
          darkTheme: TemaApp.dark(),
          themeMode: ref.watch(proveedorModoTema),
          home: const TemaAdministradorAtlassian(
            child: _AdminBrightnessLabel(),
          ),
        ),
      ),
    );
  }
}

class _AdminBrightnessLabel extends StatelessWidget {
  const _AdminBrightnessLabel();

  @override
  Widget build(BuildContext context) {
    return Text(Theme.of(context).brightness.name);
  }
}
