import 'package:correlativas_historia/compartido/firebase/app_firebase.dart';
import 'package:correlativas_historia/compartido/media/precarga_media_remota.dart';
import 'package:correlativas_historia/compartido/migraciones/migrador_preferencias_app.dart';
import 'package:correlativas_historia/compartido/navegacion/navegador_app.dart';
import 'package:correlativas_historia/compartido/notificaciones/notificaciones_push.dart';
import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/compartido/rendimiento/rendimiento_app.dart';
import 'package:correlativas_historia/compartido/supabase/supabase.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/pantallas/pantalla_laboratorio_atlassian.dart';
import 'package:correlativas_historia/tema/tema_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await MigradorPreferenciasApp.ejecutar();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WindowsVideoPlayer.registerWith();
  }

  RendimientoApp.instalarDiagnosticoFrames();
  final supabaseBootstrapFuture = initializeSupabase();
  await asegurarAppFirebase();
  final supabaseBootstrap = await supabaseBootstrapFuture;

  runApp(
    ProviderScope(
      overrides: [
        proveedorArranqueSupabase.overrideWithValue(supabaseBootstrap),
      ],
      child: const App(),
    ),
  );
  iniciarPrecargaMediaRemota();
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(proveedorModoTema);

    return ArranqueNotificacionesPush(
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Trayectorias',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: RendimientoApp.diagnosticosHabilitados,
        builder: (context, child) {
          if (child == null) {
            return const SizedBox.shrink();
          }

          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.95,
            maxScaleFactor: 1.10,
            child: child,
          );
        },
        locale: const Locale('es', 'AR'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('es', 'AR')],
        themeMode: themeMode,
        theme: TemaApp.light(),
        darkTheme: TemaApp.dark(),
        home: const PantallaLaboratorioAtlassian(hideExit: true),
      ),
    );
  }
}
