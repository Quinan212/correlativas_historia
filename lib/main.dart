import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:correlativas_historia/features/cascada/cascada_screen.dart';
import 'package:correlativas_historia/features/cascada/inicio_mapa_screen.dart';
import 'package:correlativas_historia/features/calculadora/calculadora_screen.dart';
import 'package:correlativas_historia/features/faq/faq_screen.dart';
import 'package:correlativas_historia/features/admin_access/screens/admin_access_screen.dart';
import 'package:correlativas_historia/features/admin_access/providers/admin_access_providers.dart';
import 'package:correlativas_historia/features/student_access/screens/student_access_screen.dart';
import 'package:correlativas_historia/shared/firebase/firebase_app.dart';
import 'package:correlativas_historia/shared/nav/app_navigator.dart';
import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/shared/notifications/push_notifications.dart';
import 'package:correlativas_historia/shared/performance/app_performance.dart';
import 'package:correlativas_historia/shared/supabase/supabase.dart';
import 'package:correlativas_historia/shared/widgets/bottom_nav.dart';
import 'package:correlativas_historia/theme/app_theme.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    WindowsVideoPlayer.registerWith();
  }
  AppPerformance.installFrameDiagnostics();
  final supabaseBootstrapFuture = initializeSupabase();
  await ensureFirebaseApp();
  // await AppPerformance.configureCollection();
  final supabaseBootstrap = await supabaseBootstrapFuture;
  runApp(
    ProviderScope(
      overrides: [
        supabaseBootstrapProvider.overrideWithValue(supabaseBootstrap),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return PushNotificationsBootstrapper(
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        title: 'Mapa y Calculadora de Correlatividades',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: AppPerformance.diagnosticsEnabled,
        themeMode: themeMode,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
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
      // WhatsNewSheet.maybeShow(context); // Desactivado por ahora
    });
  }

  @override
  Widget build(BuildContext context) {
    final routerIndex = ref.watch(routerIndexProvider).clamp(0, 4);
    final adminStatus = ref.watch(adminDeviceStatusProvider).valueOrNull;
    final showAdminFab = adminStatus?.isAdmin == true;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final adminFabBottom = isDesktop ? 20.0 : (routerIndex == 1 ? 92.0 : 10.0);

    Widget content = IndexedStack(
      index: routerIndex,
      children: const [
        StudentAccessScreen(key: ValueKey('trayectorias')),
        InicioMapaScreen(key: ValueKey('inicio_mapa')),
        CascadaScreen(key: ValueKey('cascada')),
        CalculadoraScreen(key: ValueKey('calculadora')),
        FaqScreen(key: ValueKey('faq')),
      ],
    );

    if (isDesktop) {
      content = Row(
        children: [
          NavigationRail(
            selectedIndex: routerIndex,
            onDestinationSelected: (idx) =>
                ref.read(routerIndexProvider.notifier).state = idx,
            extended: width >= 1300,
            minExtendedWidth: 165,
            labelType: width >= 1300 ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    onPressed: () {
                      final cur = ref.read(themeModeProvider);
                      ref.read(themeModeProvider.notifier).state =
                        cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
                      builder: (_) => const AdminAccessScreen(),
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
          : AppBottomNav(
              current: routerIndex,
              onTapTrayectorias: () => ref.read(routerIndexProvider.notifier).state = 0,
              onTapHome: () => ref.read(routerIndexProvider.notifier).state = 1,
              onTapMap: () => ref.read(routerIndexProvider.notifier).state = 2,
              onTapCalc: () => ref.read(routerIndexProvider.notifier).state = 3,
            ),
    );
  }
}
