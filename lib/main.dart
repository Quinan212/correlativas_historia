import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:correlativas_historia/funcionalidades/cascada/mapa_correlatividades_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/cascada/inicio_mapa_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/calculadora/calculadora_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/administrador/pantallas/acceso_administrador_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/administrador/proveedores/proveedores_acceso_administrador.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/pantallas/acceso_estudiante_pantalla.dart';
import 'package:correlativas_historia/compartido/firebase/app_firebase.dart';
import 'package:correlativas_historia/compartido/navegacion/navegador_app.dart';
import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/compartido/notificaciones/notificaciones_push.dart';
import 'package:correlativas_historia/compartido/rendimiento/rendimiento_app.dart';
import 'package:correlativas_historia/compartido/supabase/supabase.dart';
import 'package:correlativas_historia/compartido/componentes/navegacion_inferior.dart';
import 'package:correlativas_historia/tema/tema_app.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WindowsVideoPlayer.registerWith();
  }
  RendimientoApp.instalarDiagnosticoFrames();
  final supabaseBootstrapFuture = initializeSupabase();
  await asegurarAppFirebase();
  // await RendimientoApp.configurarRecoleccion();
  final supabaseBootstrap = await supabaseBootstrapFuture;
  runApp(
    ProviderScope(
      overrides: [
        proveedorArranqueSupabase.overrideWithValue(supabaseBootstrap),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(proveedorModoTema);

    return ArranqueNotificacionesPush(
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Mapa y Calculadora de Correlatividades',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: RendimientoApp.diagnosticosHabilitados,
        locale: const Locale('es', 'AR'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('es', 'AR')],
        themeMode: themeMode,
        theme: TemaApp.light(),
        darkTheme: TemaApp.dark(),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _checkedWhatsNew = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedWhatsNew) return;
    _checkedWhatsNew = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // HojaNovedades.maybeShow(context); // Desactivado por ahora
    });
  }

  @override
  Widget build(BuildContext context) {
    final routerIndex = ref.watch(proveedorIndiceRouter).clamp(0, 4);
    final adminStatus =
        ref.watch(proveedorEstadoDispositivoAdministrador).valueOrNull;
    final showAdminFab = adminStatus?.isAdmin == true;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final adminFabBottom = isDesktop ? 20.0 : (routerIndex == 1 ? 92.0 : 10.0);

    Widget content = IndexedStack(
      index: routerIndex,
      children: const [
        AccesoEstudiantePantalla(key: ValueKey('trayectorias')),
        PantallaInicioMapa(key: ValueKey('inicio_mapa')),
        PantallaMapaCorrelatividades(key: ValueKey('cascada')),
        PantallaCalculadora(key: ValueKey('calculadora')),
        PantallaPreguntasFrecuentes(key: ValueKey('faq')),
      ],
    );

    if (isDesktop) {
      content = Row(
        children: [
          NavigationRail(
            selectedIndex: routerIndex,
            onDestinationSelected: (idx) =>
                ref.read(proveedorIndiceRouter.notifier).state = idx,
            extended: width >= 1300,
            minExtendedWidth: 165,
            labelType: width >= 1300
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: Icon(isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded),
                    onPressed: () {
                      final cur = ref.read(proveedorModoTema);
                      ref.read(proveedorModoTema.notifier).state =
                          cur == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                    },
                  ),
                ),
              ),
            ),
            unselectedIconTheme: IconThemeData(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              size: 22,
            ),
            selectedIconTheme: IconThemeData(
              color: theme.colorScheme.primary,
              size: 24,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded),
                label: Text('Trayectorias'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree_rounded),
                label: Text('Mapa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate_rounded),
                label: Text('Calculadora'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      body: content,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: adminFabBottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showAdminFab)
              FloatingActionButton.small(
                heroTag: 'admin_access_fab',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AccesoAdministradorPantalla(),
                    ),
                  );
                },
                child: const Icon(Icons.admin_panel_settings_rounded),
              ),
          ],
        ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavegacionInferiorApp(
              current: routerIndex,
              onTapTrayectorias: () =>
                  ref.read(proveedorIndiceRouter.notifier).state = 0,
              onTapHome: () =>
                  ref.read(proveedorIndiceRouter.notifier).state = 1,
              onTapMap: () =>
                  ref.read(proveedorIndiceRouter.notifier).state = 2,
              onTapCalc: () =>
                  ref.read(proveedorIndiceRouter.notifier).state = 3,
            ),
    );
  }
}
