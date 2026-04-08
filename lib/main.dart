import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:correlativas_historia/features/cascada/cascada_screen.dart';
import 'package:correlativas_historia/features/cascada/inicio_mapa_screen.dart';
import 'package:correlativas_historia/features/calculadora/calculadora_screen.dart';
import 'package:correlativas_historia/features/faq/faq_screen.dart';
import 'package:correlativas_historia/features/admin_access/screens/admin_access_screen.dart';
import 'package:correlativas_historia/shared/firebase/firebase_app.dart';
import 'package:correlativas_historia/shared/nav/app_navigator.dart';
import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/shared/notifications/push_notifications.dart';
import 'package:correlativas_historia/shared/performance/app_performance.dart';
import 'package:correlativas_historia/shared/supabase/supabase.dart';
import 'package:correlativas_historia/shared/widgets/bottom_nav.dart';
import 'package:correlativas_historia/shared/widgets/whats_new_sheet.dart';
import 'package:correlativas_historia/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppPerformance.installFrameDiagnostics();
  final supabaseBootstrapFuture = initializeSupabase();
  await ensureFirebaseApp();
  await AppPerformance.configureCollection();
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
      WhatsNewSheet.maybeShow(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final routerIndex = ref.watch(routerIndexProvider).clamp(0, 3);
    final adminFabBottom = routerIndex == 1 ? 92.0 : 10.0;

    return Scaffold(
      body: IndexedStack(
        index: routerIndex,
        children: const [
          InicioMapaScreen(key: ValueKey('inicio_mapa')),
          CascadaScreen(key: ValueKey('cascada')),
          CalculadoraScreen(key: ValueKey('calculadora')),
          FaqScreen(key: ValueKey('faq')),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: adminFabBottom),
        child: FloatingActionButton.small(
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
      ),
      bottomNavigationBar: AppBottomNav(
        current: routerIndex,
        onTapHome: () => ref.read(routerIndexProvider.notifier).state = 0,
        onTapMap: () => ref.read(routerIndexProvider.notifier).state = 1,
        onTapCalc: () => ref.read(routerIndexProvider.notifier).state = 2,
        onTapFaq: () => ref.read(routerIndexProvider.notifier).state = 3,
      ),
    );
  }
}
