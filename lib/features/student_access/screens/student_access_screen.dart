import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/html_source_loader.dart';
import '../../../features/calculadora/pantalla/pantalla_calculadora.dart';
import '../../../features/cascada/pantalla/pantalla_inicio_mapa.dart';
import '../../../features/cascada/pantalla/pantalla_mapa_correlatividades.dart';
import '../../../features/cascada/panel_detalle/componentes/controles_superiores.dart';
import '../../../features/examenes/examenes_screen.dart';
import '../../../features/faq/faq_screen.dart';
import '../../../models/materia.dart';
import '../../../shared/supabase/supabase.dart';
import '../../../shared/utils/text_sanitize.dart';
import '../../../shared/widgets/metrics_cards.dart';
import '../data/student_access_repository.dart';
import '../models/student_access_models.dart';
import 'student_self_subjects_screen.dart';

class StudentAccessScreen extends ConsumerStatefulWidget {
  const StudentAccessScreen({super.key});

  @override
  ConsumerState<StudentAccessScreen> createState() =>
      _StudentAccessScreenState();
}

class _StudentAccessScreenState extends ConsumerState<StudentAccessScreen> {
  final _dniCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repo = const StudentAccessRepository();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  bool _compactHeader = false;
  String? _error;
  StudentAccessPayload? _payload;
  Future<List<Materia>>? _planFuture;
  int _seenNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    if (Supabase.instance.client.auth.currentSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrajectory());
    }
  }

  void _handleScroll() {
    final compact =
        _scrollController.hasClients && _scrollController.offset > 180;
    if (compact != _compactHeader && mounted) {
      setState(() => _compactHeader = compact);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _dniCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() => _error = 'Supabase no está listo todavía.');
      return;
    }

    final dni = _dniCtrl.text.replaceAll(RegExp(r'\D'), '').trim();
    final password = _passwordCtrl.text.trim();
    if (dni.isEmpty || password.isEmpty) {
      setState(() => _error = 'Completá DNI y contraseña.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await client.auth.signInWithPassword(
        email: _toLoginEmail(dni),
        password: password,
      );
      await _loadTrajectory();
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = 'No se pudo iniciar sesión: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showGuestRegistration() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _GuestRegistrationSheet(
          onStart: (name, dni, careerId) {
            Navigator.pop(context);
            _guestLogin(name, dni, careerId);
          },
        ),
      ),
    );
  }

  Future<void> _guestLogin(String firstName, String dni, String careerId) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() => _error = 'Supabase no está listo');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await client.auth.signInAnonymously();
      final payload = await _repo.load(
        client: client,
        guestFirstName: firstName,
        guestDni: dni,
        guestCareerId: careerId,
      );
      await _loadTrajectory(
        guestFirstName: firstName,
        guestCareerId: careerId,
      );
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = 'No se pudo ingresar como invitado: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadTrajectory({
    String? guestFirstName,
    String? guestCareerId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payload = await _repo.load(
        client: client,
        guestFirstName: guestFirstName,
        guestCareerId: guestCareerId,
      );
      if (!mounted) return;
      setState(() {
        _payload = payload;
        _planFuture = _loadPlanForCareer(payload.student.careerId);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openExamenes() {
    final careerId = _payload?.student.careerId;
    prewarmExamenesData(ref, careerId: careerId);
    Navigator.of(context).push(buildExamenesRoute());
  }

  void _openInicioMapa() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const InicioMapaScreen(),
      ),
    );
  }

  void _openPlanCompleto() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CascadaScreen(),
      ),
    );
  }

  void _openEscenarios() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CalculadoraScreen(),
      ),
    );
  }

  void _openAyuda() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FaqScreen(),
      ),
    );
  }

  Future<void> _openNextSteps() async {
    final payload = _payload;
    if (payload == null) return;
    final plan =
        await (_planFuture ?? _loadPlanForCareer(payload.student.careerId));
    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StudentNextStepsScreen(
          payload: payload,
          entries: entries,
        ),
      ),
    );
  }

  Future<void> _openProgress() async {
    final payload = _payload;
    if (payload == null) return;
    final plan =
        await (_planFuture ?? _loadPlanForCareer(payload.student.careerId));
    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StudentProgressScreen(
          payload: payload,
          entries: entries,
        ),
      ),
    );
  }

  Future<void> _openAcademicCalendar() async {
    final payload = _payload;
    if (payload == null) return;
    final plan =
        await (_planFuture ?? _loadPlanForCareer(payload.student.careerId));
    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _StudentAcademicCalendarScreen(
          payload: payload,
          entries: entries,
        ),
      ),
    );
  }

  void _openNotifications() async {
    final payload = _payload;
    if (payload == null) return;

    final plan =
        await (_planFuture ?? _loadPlanForCareer(payload.student.careerId));
    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);

    if (mounted) {
      setState(() {
        _seenNotificationsCount = payload.history.length;
      });
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _StudentNotificationsScreen(
          history: payload.history,
          entries: entries,
        ),
      ),
    );
  }

  void _showStudentData() {
    final student = _payload?.student;
    if (student == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _StudentDataScreen(
          student: student,
          onSaveContact: _saveStudentContact,
        ),
      ),
    );
  }

  Future<void> _openAccountSheet() async {
    final student = _payload?.student;
    if (student == null) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'DNI ${student.dni}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.logout_rounded,
                    color: cs.error,
                  ),
                  title: Text(
                    'Cerrar sesión',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Volver al ingreso del alumno',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    await client.auth.signOut();
    if (!mounted) return;
    setState(() {
      _payload = null;
      _planFuture = null;
      _seenNotificationsCount = 0;
      _error = null;
      _dniCtrl.clear();
      _passwordCtrl.clear();
    });
  }

  void _openSubjectsScreen() {
    final payload = _payload;
    if (payload == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _StudentSubjectsScreen(
          payload: payload,
          planFuture:
              _planFuture ?? _loadPlanForCareer(payload.student.careerId),
        ),
      ),
    );
  }

  void _openSelfSubjects() {
    final payload = _payload;
    if (payload == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudentSelfSubjectsScreen(payload: payload),
      ),
    ).then((_) {
      if (mounted) {
        _loadTrajectory();
      }
    });
  }

  Future<void> _saveStudentContact({
    required String phone,
    required String email,
    String? firstName,
    String? dni,
    String? careerId,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      throw StateError('Supabase no está listo todavía.');
    }

    await _repo.updateContact(
      client: client,
      phone: phone,
      email: email,
      firstName: firstName,
      dni: dni,
      careerId: careerId,
    );
    await _loadTrajectory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final student = _payload?.student;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF050816) : const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 144),
            children: [
              _HeroBanner(
                loggedIn: loggedIn,
                student: student,
                movementCount:
                    (_payload?.history.length ?? 0) - _seenNotificationsCount,
                onRefresh: loggedIn ? _loadTrajectory : null,
                onOpenSubjects: _payload == null ? null : _openSubjectsScreen,
                onOpenHistory: _payload == null ? null : _openNotifications,
                onOpenExams: _payload == null ? null : _openExamenes,
                onShowStudentData: _payload == null ? null : _showStudentData,
                onOpenAccountSheet: _payload == null ? null : _openAccountSheet,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    if (!loggedIn) ...[
                      _LoginCard(
                        loading: _loading,
                        error: _error,
                        dniCtrl: _dniCtrl,
                        passwordCtrl: _passwordCtrl,
                        onLogin: _login,
                        onGuestLogin: _showGuestRegistration,
                      ),
                    ] else if (_payload != null) ...[
                      FutureBuilder<List<Materia>>(
                        future: _planFuture ?? Future.value(const []),
                        builder: (context, snapshot) {
                          final plan = snapshot.data ?? const <Materia>[];
                          final entries = _buildCurriculumEntries(
                            _payload!.combinedSubjects,
                            plan,
                          );

                          return Column(
                            children: [
                              _SummaryStrip(
                                payload: _payload!,
                                plan: plan,
                                entries: entries,
                              ),
                              const SizedBox(height: 12),
                              _ExamShortcutBanner(onTap: _openExamenes),
                              const SizedBox(height: 14),
                              _StudentAccessSecondaryActions(
                                onOpenInicio: _openInicioMapa,
                                onOpenPlan: _openPlanCompleto,
                                onOpenEscenarios: _openEscenarios,
                                onOpenAyuda: _openAyuda,
                              ),
                              const SizedBox(height: 12),
                              _StudentAccessInsightActions(
                                onOpenNextSteps: _openNextSteps,
                                onOpenProgress: _openProgress,
                                onOpenAcademicCalendar: _openAcademicCalendar,
                                onOpenSelfSubjects: _openSelfSubjects,
                              ),
                            ],
                          );
                        },
                      ),
                    ] else ...[
                      _LoadingStateCard(
                        error: _error,
                        loading: _loading,
                        onRetry: _loadTrajectory,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          _StickyStudentHeader(
            loggedIn: loggedIn,
            student: student,
            compact: _compactHeader,
            movementCount:
                (_payload?.history.length ?? 0) - _seenNotificationsCount,
            onOpenHistory: _payload == null ? null : _openNotifications,
            onRefresh: loggedIn ? _loadTrajectory : null,
            onOpenAccountSheet: _payload == null ? null : _openAccountSheet,
          ),
        ],
      ),
    );
  }

  String _toLoginEmail(String value) {
    if (value.contains('@')) return value;
    return '$value@correlativas.local';
  }

  Future<List<Materia>> _loadPlanForCareer(String careerId) async {
    final plan = await loadPlanFromHtmlAsset(_careerAssetFor(careerId));
    return plan.materias;
  }
}

class _InstitutionLogoMark extends StatelessWidget {
  const _InstitutionLogoMark({
    required this.loggedIn,
    required this.assetPath,
    this.size = 56,
  });

  final bool loggedIn;
  final String? assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: assetPath == null
          ? Icon(
              loggedIn ? Icons.school_rounded : Icons.lock_open_rounded,
              color: scheme.primary,
            )
          : Image.asset(
              assetPath!,
              fit: BoxFit.cover,
              cacheWidth: 96,
              cacheHeight: 96,
              errorBuilder: (_, __, ___) => Icon(
                Icons.school_rounded,
                color: scheme.primary,
              ),
            ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.loggedIn,
    required this.student,
    required this.movementCount,
    required this.onRefresh,
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.onShowStudentData,
    required this.onOpenAccountSheet,
  });

  final bool loggedIn;
  final StudentAccessProfile? student;
  final int movementCount;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenSubjects;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenExams;
  final VoidCallback? onShowStudentData;
  final VoidCallback? onOpenAccountSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentStudent = student;
    final hasLoadedStudent = loggedIn && currentStudent != null;
    const headerBlue = Color(0xFF0E5E86);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasLoadedStudent ? null : headerBlue,
        gradient: hasLoadedStudent
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  headerBlue,
                  headerBlue,
                  headerBlue,
                  headerBlue.withValues(alpha: 0.82),
                  const Color(0xFFEAF1F7),
                  const Color(0xFFF6F8FC),
                ],
                stops: const [0, 0.34, 0.42, 0.62, 0.84, 1],
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 56,
          16,
          hasLoadedStudent ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loggedIn && currentStudent != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onOpenAccountSheet,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estudiante',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currentStudent.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.04,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'DNI ${currentStudent.dni} · ${_careerLabel(currentStudent.careerId)} · ${currentStudent.yearLabel}'
                        '${currentStudent.cohortYear == null ? '' : ' · Cohorte ${currentStudent.cohortYear}'}'
                        '${currentStudent.division == null ? '' : ' · División ${currentStudent.division}'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DashboardQuickActions(
                        onOpenSubjects: onOpenSubjects,
                        onOpenHistory: onOpenHistory,
                        onOpenExams: onOpenExams,
                        onShowStudentData: onShowStudentData,
                        movementCount: movementCount,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Entrá con DNI o correo técnico para ver tu recorrido académico.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StickyStudentHeader extends StatelessWidget {
  const _StickyStudentHeader({
    required this.loggedIn,
    required this.student,
    required this.compact,
    required this.movementCount,
    required this.onOpenHistory,
    required this.onRefresh,
    required this.onOpenAccountSheet,
  });

  final bool loggedIn;
  final StudentAccessProfile? student;
  final bool compact;
  final int movementCount;
  final VoidCallback? onOpenHistory;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenAccountSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStudent = student;
    final firstName = currentStudent?.firstName.trim() ?? '';
    final greetingName =
        firstName.isEmpty ? 'alumno' : firstName.split(RegExp(r'\s+')).first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14,
        MediaQuery.of(context).padding.top + 6,
        14,
        8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0E5E86),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpenAccountSheet,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  _InstitutionLogoMark(
                    loggedIn: loggedIn,
                    assetPath: currentStudent == null
                        ? null
                        : _institutionLogoAssetFor(currentStudent.careerId),
                    size: 38,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 170,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 220),
                                opacity: compact ? 0 : 1,
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 220),
                                  offset: compact
                                      ? const Offset(-0.12, 0)
                                      : Offset.zero,
                                  child: Text(
                                    'Hola,',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: compact ? 0 : 8,
                              ),
                              Expanded(
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 220),
                                  offset: compact
                                      ? const Offset(-0.22, 0)
                                      : Offset.zero,
                                  child: Text(
                                    greetingName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 8),
          if (loggedIn)
            _HeroIconButton(
              icon: Icons.notifications_none_rounded,
              badge: movementCount,
              tooltip: 'Movimientos',
              onTap: onOpenHistory,
              compact: true,
            ),
          if (loggedIn) const SizedBox(width: 6),
          if (onRefresh != null)
            _HeroIconButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Actualizar',
              onTap: onRefresh,
              compact: true,
            ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
    this.compact = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final int badge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 38.0 : 42.0;
    final radius = compact ? 11.0 : 12.0;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                color: Colors.white,
                size: compact ? 20 : 24,
              ),
            ),
            if (badge > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: themeTextSmall(context).copyWith(
                      color: scheme.onError,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

TextStyle themeTextSmall(BuildContext context) {
  return Theme.of(context).textTheme.labelSmall ??
      const TextStyle(fontSize: 11);
}

class _DashboardQuickActions extends StatelessWidget {
  const _DashboardQuickActions({
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.onShowStudentData,
    required this.movementCount,
  });

  final VoidCallback? onOpenSubjects;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenExams;
  final VoidCallback? onShowStudentData;
  final int movementCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.grid_view_rounded,
            label: 'Materias',
            onTap: onOpenSubjects,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.history_rounded,
            label: 'Historial',
            onTap: onOpenHistory,
            badge: movementCount,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.event_note_rounded,
            label: 'Mesas',
            onTap: onOpenExams,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.badge_rounded,
            label: 'Tus datos',
            onTap: onShowStudentData,
          ),
        ),
      ],
    );
  }
}

class _QuickCircleAction extends StatelessWidget {
  const _QuickCircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.circleColor,
    this.circleBorderColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final Color? circleColor;
  final Color? circleBorderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor ?? scheme.primary.withValues(alpha: 0.10),
                  border: Border.all(
                    color: circleBorderColor ??
                        scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentDataScreen extends StatefulWidget {
  const _StudentDataScreen({
    required this.student,
    required this.onSaveContact,
  });

  final StudentAccessProfile student;
  final Future<void> Function({
    required String phone,
    required String email,
    String? firstName,
    String? dni,
    String? careerId,
  }) onSaveContact;

  @override
  State<_StudentDataScreen> createState() => _StudentDataScreenState();
}

class _StudentDataScreenState extends State<_StudentDataScreen> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dniCtrl;
  late String _selectedCareer;
  
  bool _showAcademic = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.student.contactPhone ?? '');
    _emailCtrl = TextEditingController(text: widget.student.contactEmail ?? '');
    _nameCtrl = TextEditingController(text: widget.student.firstName);
    _dniCtrl = TextEditingController(text: widget.student.dni.startsWith('guest_') ? '' : widget.student.dni);
    _selectedCareer = widget.student.careerId;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _dniCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSaveContact(
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        firstName: _nameCtrl.text.trim(),
        dni: _dniCtrl.text.trim().replaceAll(RegExp(r'\D'), ''),
        careerId: _selectedCareer,
      );
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto actualizado.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _copyValue(String label, String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = widget.student;
    final scheme = theme.colorScheme;
    final primaryBlue = const Color(0xFF0E5E86);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          'Tus datos',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _copyValue(
              'Datos',
              '${student.fullName}\nDNI ${student.dni}\n${_careerLabel(student.careerId)}\n${student.yearLabel}',
            ),
            icon: const Icon(Icons.content_copy_rounded),
            tooltip: 'Copiar datos',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD9E2EE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StudentDataTabButton(
                        label: 'Académicos',
                        selected: _showAcademic,
                        onTap: () => setState(() => _showAcademic = true),
                      ),
                    ),
                    Expanded(
                      child: _StudentDataTabButton(
                        label: 'Contacto',
                        selected: !_showAcademic,
                        onTap: () => setState(() => _showAcademic = false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_showAcademic) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.isDemo ? 'Perfil temporal' : 'Desde la institución',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF182234),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (student.isDemo)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _editing = !_editing),
                        child: Text(_editing ? 'Cancelar' : 'Editar'),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _StudentDataSection(
                  child: Column(
                    children: [
                      if (student.isDemo && _editing) ...[
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre completo'),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _dniCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'DNI'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedCareer,
                          decoration: const InputDecoration(labelText: 'Carrera'),
                          items: const [
                            DropdownMenuItem(value: 'artes_visuales', child: Text('Artes Visuales')),
                            DropdownMenuItem(value: 'historia', child: Text('Historia')),
                            DropdownMenuItem(value: 'geografia', child: Text('Geografía')),
                            DropdownMenuItem(value: 'politica', child: Text('Ciencias Políticas')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCareer = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: primaryBlue,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Guardar cambios'),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          ),
                        ],
                      ] else ...[
                        _StudentDataTile(
                          label: 'Nombre completo',
                          value: student.fullName,
                          onCopy: () => _copyValue('Nombre', student.fullName),
                        ),
                        _StudentDataTile(
                          label: 'DNI',
                          value: student.dni.startsWith('guest_') ? 'No especificado' : student.dni,
                          onCopy: () => _copyValue('DNI', student.dni),
                        ),
                        _StudentDataTile(
                          label: 'Carrera',
                          value: _careerLabel(student.careerId),
                          onCopy: () => _copyValue('Carrera', _careerLabel(student.careerId)),
                        ),
                      ],
                      _StudentDataTile(
                        label: 'Año actual',
                        value: student.yearLabel,
                        onCopy: () =>
                            _copyValue('Año actual', student.yearLabel),
                      ),
                      if (student.cohortYear != null)
                        _StudentDataTile(
                          label: 'Cohorte',
                          value: '${student.cohortYear}',
                          onCopy: () => _copyValue(
                            'Cohorte',
                            '${student.cohortYear}',
                          ),
                        ),
                      _StudentDataTile(
                        label: 'División',
                        value: (student.division?.trim().isNotEmpty ?? false)
                            ? student.division!
                            : 'A',
                        onCopy: () => _copyValue(
                          'División',
                          (student.division?.trim().isNotEmpty ?? false)
                              ? student.division!
                              : 'A',
                        ),
                      ),
                      _StudentDataTile(
                        label: 'Estado',
                        value: _enrollmentStatusLabel(student.enrollmentStatus),
                        onCopy: () => _copyValue(
                          'Estado',
                          _enrollmentStatusLabel(student.enrollmentStatus),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _copyValue(
                          'Datos',
                          '${student.fullName}\nDNI ${student.dni}\n${_careerLabel(student.careerId)}\n${student.yearLabel}',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F0FB),
                          foregroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Compartir datos'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showAcademic = false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: Color(0xFFD9E2EE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('Ver contacto'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Desde la app',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF182234),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _editing = !_editing),
                      child: Text(_editing ? 'Cancelar' : 'Editar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _StudentDataSection(
                  child: Column(
                    children: [
                      _StudentEditableTile(
                        label: 'Celular',
                        value: student.contactPhone ?? '',
                        hint: 'Agregá tu teléfono',
                        controller: _phoneCtrl,
                        enabled: _editing && !_saving,
                        keyboardType: TextInputType.phone,
                      ),
                      _StudentEditableTile(
                        label: 'E-mail',
                        value: student.contactEmail ?? '',
                        hint: 'Agregá tu e-mail',
                        controller: _emailCtrl,
                        enabled: _editing && !_saving,
                        keyboardType: TextInputType.emailAddress,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: !_editing || _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE7F0FB),
                          foregroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: Text(_saving ? 'Guardando...' : 'Guardar datos'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentSubjectsScreen extends StatefulWidget {
  const _StudentSubjectsScreen({
    required this.payload,
    required this.planFuture,
  });

  final StudentAccessPayload payload;
  final Future<List<Materia>> planFuture;

  @override
  State<_StudentSubjectsScreen> createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<_StudentSubjectsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedYear = 0;
  String _selectedStatus = 'todos';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF0E5E86);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        title: Text(
          'Materias',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<List<Materia>>(
          future: widget.planFuture,
          builder: (context, snapshot) {
            final plan = snapshot.data ?? const <Materia>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _SubjectsCard(
                  payload: widget.payload,
                  plan: plan,
                  history: widget.payload.history,
                  loadingPlan: snapshot.connectionState != ConnectionState.done,
                  query: _searchCtrl.text,
                  searchController: _searchCtrl,
                  selectedYear: _selectedYear,
                  selectedStatus: _selectedStatus,
                  onYearSelected: (year) =>
                      setState(() => _selectedYear = year),
                  onStatusSelected: (status) =>
                      setState(() => _selectedStatus = status),
                  onQueryChanged: (_) => setState(() {}),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraInferiorDetalle(
          onTap: () => Navigator.of(context).pop(),
          label: 'Cerrar y volver',
        ),
      ),
    );
  }
}

class _StudentDataSection extends StatelessWidget {
  const _StudentDataSection({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: child,
    );
  }
}

class _StudentDataTabButton extends StatelessWidget {
  const _StudentDataTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: selected
              ? Border.all(
                  color: const Color(0xFFD9E2EE),
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: selected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StudentDataTile extends StatelessWidget {
  const _StudentDataTile({
    required this.label,
    required this.value,
    required this.onCopy,
    this.isLast = false,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _DataActionButton(
            icon: Icons.content_copy_rounded,
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

class _StudentEditableTile extends StatelessWidget {
  const _StudentEditableTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.controller,
    required this.enabled,
    required this.keyboardType,
    this.isLast = false,
  });

  final String label;
  final String value;
  final String hint;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType keyboardType;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.35),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: enabled
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      labelText: label,
                      hintText: hint,
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.isEmpty ? hint : value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: value.isEmpty
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          _DataActionButton(
            icon: enabled ? Icons.edit_rounded : Icons.content_copy_rounded,
            onTap: enabled
                ? null
                : () {
                    final text = value.isEmpty ? hint : value;
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label copiado.')),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _DataActionButton extends StatelessWidget {
  const _DataActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.loading,
    required this.error,
    required this.dniCtrl,
    required this.passwordCtrl,
    required this.onLogin,
    required this.onGuestLogin,
  });

  final bool loading;
  final String? error;
  final TextEditingController dniCtrl;
  final TextEditingController passwordCtrl;
  final Future<void> Function() onLogin;
  final VoidCallback onGuestLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso al perfil',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usá DNI o correo técnico y contraseña para entrar al perfil del alumno.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final dniField = TextField(
                controller: dniCtrl,
                enabled: !loading,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'DNI o correo',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              );
              final passwordField = TextField(
                controller: passwordCtrl,
                enabled: !loading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    dniField,
                    const SizedBox(height: 12),
                    passwordField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dniField),
                  const SizedBox(width: 12),
                  Expanded(child: passwordField),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onLogin,
              icon: const Icon(Icons.login_rounded),
              label: Text(loading ? 'Ingresando...' : 'Entrar'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onGuestLogin,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Ingresar como Invitado'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.payload,
    required this.plan,
    required this.entries,
  });

  final StudentAccessPayload payload;
  final List<Materia> plan;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totalPlan = plan.length;
    final approved = entries
        .where(
          (e) =>
              e.current != null &&
              e.current!.status.toLowerCase().trim() == 'aprobada',
        )
        .length;
    final inProgress = entries
        .where(
          (e) => e.current != null && _isSubjectInProgress(e.current!),
        )
        .length;
    final available =
        entries.where((e) => e.current == null && e.available).length;
    final progress = totalPlan == 0 ? 0.0 : approved / totalPlan;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final thirdWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        final tileHeight = thirdWidth * 0.84;
        final largeWidth = (thirdWidth * 2) + spacing;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: largeWidth,
                  height: tileHeight,
                  child: _LargeProgressCard(
                    progress: progress,
                    approved: approved,
                    totalPlan: totalPlan,
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: tileHeight,
                    child: MetricCard(
                      icon: Icons.check_circle_rounded,
                      label: 'Aprobadas',
                      value: '$approved',
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: MetricCard(
                    icon: Icons.lock_open_rounded,
                    label: 'Habilitadas',
                    value: '$available',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: MetricCard(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgress',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: MetricCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Plan total',
                    value: '$totalPlan',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LargeProgressCard extends StatelessWidget {
  const _LargeProgressCard({
    required this.progress,
    required this.approved,
    required this.totalPlan,
  });

  final double progress;
  final int approved;
  final int totalPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.10),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso general',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$approved de $totalPlan materias ya están acreditadas en tu recorrido.',
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamShortcutBanner extends StatelessWidget {
  const _ExamShortcutBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.secondary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(alpha: 0.16),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: scheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mesas y fechas publicadas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAccessSecondaryActions extends StatelessWidget {
  const _StudentAccessSecondaryActions({
    required this.onOpenInicio,
    required this.onOpenPlan,
    required this.onOpenEscenarios,
    required this.onOpenAyuda,
  });

  final VoidCallback onOpenInicio;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenEscenarios;
  final VoidCallback onOpenAyuda;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.home_rounded,
            label: 'Inicio',
            onTap: onOpenInicio,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.account_tree_rounded,
            label: 'Plan completo',
            onTap: onOpenPlan,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.auto_graph_rounded,
            label: 'Escenarios',
            onTap: onOpenEscenarios,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.help_rounded,
            label: 'Ayuda',
            onTap: onOpenAyuda,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
      ],
    );
  }
}

class _StudentAccessInsightActions extends StatelessWidget {
  const _StudentAccessInsightActions({
    required this.onOpenNextSteps,
    required this.onOpenProgress,
    required this.onOpenAcademicCalendar,
    required this.onOpenSelfSubjects,
  });

  final VoidCallback onOpenNextSteps;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenAcademicCalendar;
  final VoidCallback onOpenSelfSubjects;

  @override
  Widget build(BuildContext context) {
    final outline =
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.12);

    return Row(
      children: [
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.flag_outlined,
            label: 'Pr\u00f3ximos pasos',
            onTap: onOpenNextSteps,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.insights_outlined,
            label: 'Mi avance',
            onTap: onOpenProgress,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.calendar_month_outlined,
            label: 'Calendario',
            onTap: onOpenAcademicCalendar,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _QuickCircleAction(
            icon: Icons.edit_note_rounded,
            label: 'Mi registro',
            onTap: onOpenSelfSubjects,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
      ],
    );
  }
}

class _SubjectsCard extends StatelessWidget {
  const _SubjectsCard({
    required this.payload,
    required this.plan,
    required this.history,
    required this.loadingPlan,
    required this.query,
    required this.searchController,
    required this.selectedYear,
    required this.selectedStatus,
    required this.onYearSelected,
    required this.onStatusSelected,
    required this.onQueryChanged,
  });

  final StudentAccessPayload payload;
  final List<Materia> plan;
  final List<StudentAccessHistoryEntry> history;
  final bool loadingPlan;
  final String query;
  final TextEditingController searchController;
  final int selectedYear;
  final String selectedStatus;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loadingPlan && plan.isEmpty) {
      return _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapa académico',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 12),
            Text(
              'Cargando correlatividades de tu carrera...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    final normalizedQuery = _norm(query);
    bool matchesStatus(_CurriculumEntry entry) {
      return switch (selectedStatus) {
        'aprobadas' =>
          entry.current != null && _isSubjectApproved(entry.current!),
        'bloqueadas' => _isEntryBlocked(entry),
        'cursando' =>
          entry.current != null && _isSubjectInProgress(entry.current!),
        _ => true,
      };
    }

    bool matchesSearch(_CurriculumEntry entry) {
      if (normalizedQuery.isEmpty) return true;
      return _norm(entry.materia.displayNombre).contains(normalizedQuery) ||
          _norm(entry.materia.nombre).contains(normalizedQuery);
    }

    final filteredEntries = entries
        .where((entry) =>
            (selectedYear == 0 || entry.materia.anio == selectedYear) &&
            matchesStatus(entry) &&
            matchesSearch(entry))
        .toList(growable: false);
    final grouped = <int, List<_CurriculumEntry>>{
      1: <_CurriculumEntry>[],
      2: <_CurriculumEntry>[],
      3: <_CurriculumEntry>[],
      4: <_CurriculumEntry>[],
    };
    for (final entry in filteredEntries) {
      grouped[entry.materia.anio]!.add(entry);
    }
    final approvedCount = entries
        .where(
          (e) => e.current != null && _isSubjectApproved(e.current!),
        )
        .length;
    final inProgressCount = entries
        .where(
          (e) => e.current != null && _isSubjectInProgress(e.current!),
        )
        .length;
    final availableCount = entries
        .where(
          (e) => e.current == null && e.available,
        )
        .length;
    final blockedCount = entries
        .where(
          _isEntryBlocked,
        )
        .length;
    final yearsToShow = selectedYear == 0 ? const [1, 2, 3, 4] : [selectedYear];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mapa de correlatividades',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acá ves lo aprobado, lo que ya podés cursar y lo que sigue bloqueado por correlativas.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Aprobadas',
                    value: '$approvedCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgressCount',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Habilitadas',
                    value: '$availableCount',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.lock_rounded,
                    label: 'Bloqueadas',
                    value: '$blockedCount',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    icon: Icons.menu_book_rounded,
                    label: 'Plan total',
                    value: '${entries.length}',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: searchController,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Buscar materia',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.22),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.22),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.26),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _YearFilterChip(
                label: 'Todos',
                selected: selectedYear == 0 && selectedStatus == 'todos',
                onTap: () {
                  onYearSelected(0);
                  onStatusSelected('todos');
                },
              ),
              const SizedBox(width: 8),
              for (final year in [1, 2, 3, 4]) ...[
                _YearFilterChip(
                  label: '$year° año',
                  selected: selectedYear == year,
                  onTap: () => onYearSelected(year),
                ),
                const SizedBox(width: 8),
              ],
              for (final item in const [
                ('aprobadas', 'Aprobadas'),
                ('bloqueadas', 'Bloqueadas'),
                ('cursando', 'Cursando'),
              ]) ...[
                _YearFilterChip(
                  label: item.$2,
                  selected: selectedStatus == item.$1,
                  onTap: () => onStatusSelected(item.$1),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${filteredEntries.length} materias visibles',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (filteredEntries.isEmpty)
          _GlassCard(
            child: Text(
              'No encontramos materias con esos filtros.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final year in yearsToShow) ...[
            _YearSubjectGroup(
              year: year,
              entries: grouped[year] ?? const [],
              allEntries: entries,
              history: history,
            ),
            if (year != yearsToShow.last) const SizedBox(height: 16),
          ],
      ],
    );
  }
}

class _YearSubjectGroup extends StatelessWidget {
  const _YearSubjectGroup({
    required this.year,
    required this.entries,
    required this.allEntries,
    required this.history,
  });

  final int year;
  final List<_CurriculumEntry> entries;
  final List<_CurriculumEntry> allEntries;
  final List<StudentAccessHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) return const SizedBox.shrink();

    final approved = entries.where((e) {
      final current = e.current;
      return current != null &&
          current.status.toLowerCase().trim() == 'aprobada';
    }).length;
    final blocked =
        entries.where((e) => e.current == null && !e.available).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$year° año',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _SectionPill(label: '$approved aprobadas'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${entries.length} materias${blocked == 0 ? '' : ' · $blocked bloqueadas'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in entries) ...[
          _SubjectRow(
            entry: entry,
            history: history,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _StudentSubjectDetailScreen(
                    entry: entry,
                    allEntries: allEntries,
                    history: history,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.entry,
    required this.history,
    required this.onTap,
  });

  final _CurriculumEntry entry;
  final List<StudentAccessHistoryEntry> history;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateLabel = _subjectStateForRow(entry);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.022),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.materia.displayNombre,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              _SubjectMetaLine(
                icon: _subjectStateIcon(entry),
                iconColor: _subjectStateColor(context, entry),
                label: stateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_subjectCardDate(entry, history) != null) ...[
                const SizedBox(height: 6),
                _SubjectMetaLine(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  label: _subjectCardDate(entry, history)!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentSubjectDetailScreen extends StatelessWidget {
  const _StudentSubjectDetailScreen({
    required this.entry,
    required this.allEntries,
    required this.history,
  });

  final _CurriculumEntry entry;
  final List<_CurriculumEntry> allEntries;
  final List<StudentAccessHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = entry.current;
    final historySteps = _subjectHistorySteps(entry, history);
    final unlocks = _subjectsUnlockedBy(entry, allEntries);

    return Scaffold(
      appBar: _SubjectDetailBanner(
        title: entry.materia.displayNombre,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: [
          _SubjectStatusDashboard(entry: entry),
          _SubjectHistoryCard(steps: historySteps),
          const SizedBox(height: 16),
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current != null &&
                          _subjectStatusForRequirement(current) == 'aprobada'
                      ? 'Lo que desbloquea'
                      : 'Correlativas',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (current != null &&
                    _subjectStatusForRequirement(current) == 'aprobada') ...[
                  Text(
                    'Aprobar esta materia te permite avanzar en estas materias:',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (unlocks.isEmpty)
                    Text(
                      'No desbloquea otras materias del plan.',
                      style: theme.textTheme.bodyLarge,
                    )
                  else
                    Column(
                      children: [
                        for (final unlock in unlocks.take(8)) ...[
                          _UnlockRow(
                            title: unlock.materia.displayNombre,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (unlocks.length > 8)
                          Text(
                            '+ ${unlocks.length - 8} materias más',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                ] else if (_isUdiMateria(entry.materia) ||
                    _isPracticaDocenteIV(entry.materia))
                  Text(
                    _isPracticaDocenteIV(entry.materia)
                        ? 'Para la Residencia necesitás tener aprobados todos los años anteriores.'
                        : 'Para esta UDI necesitás tener aprobados todos los años anteriores.',
                    style: theme.textTheme.bodyLarge,
                  )
                else if (entry.missing.isEmpty)
                  Text(
                    current != null
                        ? 'Cumplís con los requisitos de correlativas.'
                        : 'Materia desbloqueada. Podés cursar o rendir.',
                    style: theme.textTheme.bodyLarge,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Te faltan estas correlativas:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in entry.missing)
                            _StatusChip(label: item),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraInferiorDetalle(
          onTap: () => Navigator.of(context).pop(),
          label: 'Cerrar y volver',
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Banner azul de la pantalla de detalle de materia
// ──────────────────────────────────────────────────────────────
class _SubjectDetailBanner extends StatelessWidget
    implements PreferredSizeWidget {
  const _SubjectDetailBanner({required this.title});

  final String title;

  static const Color _c1 = Color(0xFF005B7F);
  static const Color _c2 = Color(0xFF004966);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _c1,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: kToolbarHeight,
      titleSpacing: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c1, _c2],
          ),
        ),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1.15,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _UnlockRow extends StatelessWidget {
  const _UnlockRow({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_open_rounded,
            size: 18,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _CompactBadge(
            label: 'Desbloquea',
            color: theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _SubjectHistoryCard extends StatelessWidget {
  const _SubjectHistoryCard({required this.steps});

  final List<_SubjectHistoryStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movimientos de la materia',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (steps.isEmpty)
            Text(
              'Todavía no hay movimientos guardados para esta materia.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                for (final step in steps) ...[
                  _SubjectHistoryRow(step: step),
                  const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SubjectHistoryRow extends StatelessWidget {
  const _SubjectHistoryRow({required this.step});

  final _SubjectHistoryStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: step.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(step.icon, color: step.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (step.dateLabel != null)
                      Text(
                        step.dateLabel!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (step.detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.detail!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentMovement {
  const _StudentMovement({
    required this.title,
    required this.detail,
    required this.dateLabel,
    required this.icon,
    required this.color,
    this.entry,
  });

  final String title;
  final String detail;
  final String? dateLabel;
  final IconData icon;
  final Color color;
  final _CurriculumEntry? entry;
}

class _SubjectHistoryStep {
  const _SubjectHistoryStep({
    required this.label,
    required this.detail,
    required this.dateLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final String? detail;
  final String? dateLabel;
  final Color color;
  final IconData icon;
}

// ──────────────────────────────────────────────────────────────
// Dashboard 2×2 de estado de materia
// ──────────────────────────────────────────────────────────────
class _SubjectStatusDashboard extends StatelessWidget {
  const _SubjectStatusDashboard({required this.entry});

  final _CurriculumEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = entry.current;

    // ── colores y datos del estado ─────────────────────────
    final bool isApproved =
        current != null && _subjectStatusForRequirement(current) == 'aprobada';
    final bool isInProgress = current != null && _isSubjectInProgress(current);
    final bool isBlocked = _isEntryBlocked(entry);

    final Color statusColor = isApproved
        ? const Color(0xFF2EAD57)
        : isInProgress
            ? const Color(0xFF1E6FDB)
            : isBlocked
                ? const Color(0xFFDC2626)
                : cs.onSurfaceVariant;

    final IconData statusIcon = isApproved
        ? Icons.check_circle_rounded
        : isInProgress
            ? Icons.play_circle_rounded
            : isBlocked
                ? Icons.block_rounded
                : Icons.remove_circle_outline_rounded;

    final String statusLabel = isApproved
        ? 'Aprobada'
        : isInProgress
            ? 'Cursando'
            : isBlocked
                ? 'No disponible'
                : 'Sin cursar';

    // ── nota ──────────────────────────────────────────────
    final String? noteLabel = current?.grade != null
        ? 'Nota ${current!.grade!.toStringAsFixed(0)}'
        : null;
    final String? periodLabel = (current?.academicPeriod.isNotEmpty ?? false)
        ? _periodLabel(current!.academicPeriod)
        : null;
    final String? condLabel = current?.detailStatus != null
        ? _detailLabel(current!.detailStatus!)
        : null;
    final hasSourceDate = current?.sourceDate != null;
    final noteFlex = hasSourceDate ? 3 : 4;
    final conditionFlex = hasSourceDate ? 4 : 6;
    final dateFlex = 3;

    const double spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fila 1: grande (estado actual) + chico (valor estado)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Card grande: Estado actual ──────────────────
              Expanded(
                flex: 3,
                child: GlassMetricCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 22,
                          color: statusColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Estado actual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revisá el estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: spacing),
              // ── Card chica: estado ─────────────────────────
              Expanded(
                flex: 2,
                child: GlassMetricCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(statusIcon, size: 26, color: statusColor),
                      const Spacer(),
                      Text(
                        statusLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fila 2 solo si hay nota o condición
        if (current != null && (noteLabel != null || condLabel != null)) ...[
          const SizedBox(height: spacing),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card chica: nota + período ─────────────
                if (noteLabel != null)
                  Expanded(
                    flex: noteFlex,
                    child: GlassMetricCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 22,
                            color: const Color(0xFFD97706),
                          ),
                          const Spacer(),
                          Text(
                            noteLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            periodLabel ?? 'Período',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (noteLabel != null && condLabel != null)
                  const SizedBox(width: spacing),
                // ── Card chica: condición ──────────────────
                if (condLabel != null)
                  Expanded(
                    flex: conditionFlex,
                    child: GlassMetricCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            condLabel.toLowerCase().contains('directa')
                                ? Icons.verified_rounded
                                : condLabel
                                        .toLowerCase()
                                        .contains('extraordinaria')
                                    ? Icons.warning_amber_rounded
                                    : Icons.event_available_rounded,
                            size: 22,
                            color: condLabel.toLowerCase().contains('directa')
                                ? const Color(0xFF2EAD57)
                                : condLabel
                                        .toLowerCase()
                                        .contains('extraordinaria')
                                    ? const Color(0xFFD97706)
                                    : cs.primary,
                          ),
                          const Spacer(),
                          Text(
                            condLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Condición',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ── Card chica: fecha de aprobación ───────────
                if (hasSourceDate) ...[
                  const SizedBox(width: spacing),
                  Expanded(
                    flex: dateFlex,
                    child: GlassMetricCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 22,
                            color: Color(0xFF7C3AED),
                          ),
                          const Spacer(),
                          Text(
                            '${current.sourceDate!.year}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${current.sourceDate!.day.toString().padLeft(2, '0')}/${current.sourceDate!.month.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _YearFilterChip extends StatelessWidget {
  const _YearFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.10)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.20)
                  : theme.colorScheme.outline.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectMetaLine extends StatelessWidget {
  const _SubjectMetaLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _StudentNotificationsScreen extends StatelessWidget {
  const _StudentNotificationsScreen({
    required this.history,
    required this.entries,
  });

  final List<StudentAccessHistoryEntry> history;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movements = _buildStudentMovements(history, entries)
        .take(24)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notificaciones'),
      ),
      body: SafeArea(
        top: false,
        child: movements.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Sin movimientos recientes.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                itemCount: movements.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.28),
                ),
                itemBuilder: (context, index) => _StudentMovementRow(
                  movement: movements[index],
                  history: history,
                  allEntries: entries,
                ),
              ),
      ),
    );
  }
}

class _StudentMovementRow extends StatelessWidget {
  const _StudentMovementRow({
    required this.movement,
    this.history,
    this.allEntries,
  });

  final _StudentMovement movement;
  final List<StudentAccessHistoryEntry>? history;
  final List<_CurriculumEntry>? allEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: movement.entry == null
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => _StudentSubjectDetailScreen(
                    entry: movement.entry!,
                    allEntries: allEntries ?? const [],
                    history: history ?? const [],
                  ),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.55),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                movement.icon,
                color: movement.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          movement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                      ),
                      if (movement.dateLabel != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          movement.dateLabel!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movement.detail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (movement.entry != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentNextStepsScreen extends StatelessWidget {
  const _StudentNextStepsScreen({
    required this.payload,
    required this.entries,
  });

  final StudentAccessPayload payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = payload.student;
    final availableEntries = entries
        .where((entry) => entry.current == null && entry.available)
        .toList(growable: false);
    final pendingFinals = entries.where((entry) {
      final current = entry.current;
      if (current == null || _isSubjectApproved(current)) return false;
      return _subjectStatusForRequirement(current) == 'regular' ||
          _isSubjectInProgress(current);
    }).toList(growable: false);
    final missingContact = (student.contactPhone?.trim().isEmpty ?? true) ||
        (student.contactEmail?.trim().isEmpty ?? true);

    _CurriculumEntry? bestCandidate;
    var bestUnlockCount = 0;
    for (final entry in availableEntries) {
      final unlockCount = _subjectsUnlockedBy(entry, entries)
          .where((candidate) => candidate.current == null)
          .length;
      if (unlockCount > bestUnlockCount) {
        bestUnlockCount = unlockCount;
        bestCandidate = entry;
      }
    }

    final items = <_NextStepItem>[
      if (availableEntries.isNotEmpty)
        _NextStepItem(
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF0E7490),
          title:
              'Ten\u00e9s ${availableEntries.length} materias disponibles para cursar.',
          detail: availableEntries
              .take(2)
              .map((entry) => entry.materia.displayNombre)
              .join(' \u00b7 '),
        )
      else
        const _NextStepItem(
          icon: Icons.pause_circle_outline_rounded,
          color: Color(0xFF64748B),
          title: 'No hay materias nuevas habilitadas por ahora.',
          detail:
              'Conviene revisar correlativas pendientes o finales en curso.',
        ),
      _NextStepItem(
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFFD97706),
        title:
            'Ten\u00e9s ${pendingFinals.length} finales o cierres pendientes.',
        detail: pendingFinals.isEmpty
            ? 'No hay materias en curso pendientes de cierre.'
            : pendingFinals
                .take(2)
                .map((entry) => entry.materia.displayNombre)
                .join(' \u00b7 '),
      ),
      if (bestCandidate != null)
        _NextStepItem(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF2EAD57),
          title: 'Conviene priorizar ${bestCandidate.materia.displayNombre}.',
          detail: bestUnlockCount == 0
              ? 'Ya est\u00e1 disponible y ayuda a sostener tu avance actual.'
              : 'Puede habilitar $bestUnlockCount materias posteriores si la aprob\u00e1s.',
        ),
      if (missingContact)
        const _NextStepItem(
          icon: Icons.contact_phone_outlined,
          color: Color(0xFF7C3AED),
          title: 'Faltan completar datos de contacto.',
          detail:
              'Revis\u00e1 tel\u00e9fono y correo en la secci\u00f3n Tus datos.',
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pr\u00f3ximos pasos'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionPill(label: 'Orientaci\u00f3n r\u00e1pida'),
                  const SizedBox(height: 12),
                  Text(
                    'Qu\u00e9 conviene hacer ahora',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leemos tu trayectoria actual para marcar lo m\u00e1s urgente, lo disponible y lo que m\u00e1s impacto puede tener en el recorrido.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final item in items) ...[
              _NextStepCard(item: item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentProgressScreen extends StatelessWidget {
  const _StudentProgressScreen({
    required this.payload,
    required this.entries,
  });

  final StudentAccessPayload payload;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final blocked = entries
        .where((entry) => entry.current == null && !entry.available)
        .length;
    final total = entries.length;
    final progress = total == 0 ? 0.0 : approved / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mi avance'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _LargeProgressCard(
              progress: progress,
              approved: approved,
              totalPlan: total,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.check_circle_rounded,
                    label: 'Aprobadas',
                    value: '$approved',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgress',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Disponibles',
                    value: '$available',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    icon: Icons.lock_rounded,
                    label: 'No disponibles',
                    value: '$blocked',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagn\u00f3stico breve',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _progressDiagnosis(
                      student: payload.student,
                      approved: approved,
                      available: available,
                      blocked: blocked,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final year in [1, 2, 3, 4]) ...[
              if (entries.any((entry) => entry.materia.anio == year))
                _YearProgressCard(
                  year: year,
                  entries: entries
                      .where((entry) => entry.materia.anio == year)
                      .toList(growable: false),
                ),
              if (entries.any((entry) => entry.materia.anio == year))
                const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentAcademicCalendarScreen extends StatefulWidget {
  const _StudentAcademicCalendarScreen({
    required this.payload,
    required this.entries,
  });

  final StudentAccessPayload payload;
  final List<_CurriculumEntry> entries;

  @override
  State<_StudentAcademicCalendarScreen> createState() =>
      _StudentAcademicCalendarScreenState();
}

class _StudentAcademicCalendarScreenState
    extends State<_StudentAcademicCalendarScreen> {
  late final List<_AcademicCalendarEvent> _events;
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = _buildAcademicCalendarEvents(
      widget.payload.history,
      widget.entries,
    );
    final latestDate = _events.isEmpty
        ? DateTime.now()
        : _events.map((event) => event.date).reduce(
              (a, b) => a.isAfter(b) ? a : b,
            );
    _visibleMonth = DateTime(latestDate.year, latestDate.month);
    _selectedDay = _dateOnly(latestDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthEvents = _events
        .where(
          (event) =>
              event.date.year == _visibleMonth.year &&
              event.date.month == _visibleMonth.month,
        )
        .toList(growable: false);
    final eventsByDay = <DateTime, List<_AcademicCalendarEvent>>{};
    for (final event in monthEvents) {
      final key = _dateOnly(event.date);
      eventsByDay.putIfAbsent(key, () => []).add(event);
    }
    final selectedEvents =
        eventsByDay[_selectedDay] ?? const <_AcademicCalendarEvent>[];
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final firstWeekdayOffset =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday - 1;
    final totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Calendario acad\u00e9mico'),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month - 1,
                            );
                            _selectedDay = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          _monthLabel(_visibleMonth),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _visibleMonth = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month + 1,
                            );
                            _selectedDay = DateTime(
                              _visibleMonth.year,
                              _visibleMonth.month,
                              1,
                            );
                          });
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      _CalendarWeekdayCell(label: 'L'),
                      _CalendarWeekdayCell(label: 'M'),
                      _CalendarWeekdayCell(label: 'M'),
                      _CalendarWeekdayCell(label: 'J'),
                      _CalendarWeekdayCell(label: 'V'),
                      _CalendarWeekdayCell(label: 'S'),
                      _CalendarWeekdayCell(label: 'D'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCells,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (context, index) {
                      final dayNumber = index - firstWeekdayOffset + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month,
                        dayNumber,
                      );
                      final dayEvents = eventsByDay[_dateOnly(date)] ??
                          const <_AcademicCalendarEvent>[];
                      final isSelected = _isSameDay(date, _selectedDay);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              setState(() => _selectedDay = _dateOnly(date)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.26)
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.16),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: [
                                    for (final event in dayEvents.take(3))
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: event.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                if (dayEvents.length > 3) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '+${dayEvents.length - 3}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos del ${_selectedDay.day.toString().padLeft(2, '0')}/${_selectedDay.month.toString().padLeft(2, '0')}/${_selectedDay.year}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedEvents.isEmpty)
                    Text(
                      'No hay movimientos o acreditaciones guardadas para este d\u00eda.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final event in selectedEvents) ...[
                          _AcademicCalendarEventTile(
                            event: event,
                            allEntries: widget.entries,
                            history: widget.payload.history,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BarraInferiorDetalle(
          onTap: () => Navigator.of(context).pop(),
          label: 'Cerrar y volver',
        ),
      ),
    );
  }
}

class _NextStepItem {
  const _NextStepItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.item});

  final _NextStepItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearProgressCard extends StatelessWidget {
  const _YearProgressCard({
    required this.year,
    required this.entries,
  });

  final int year;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectApproved(current);
    }).length;
    final inProgress = entries.where((entry) {
      final current = entry.current;
      return current != null && _isSubjectInProgress(current);
    }).length;
    final available = entries
        .where((entry) => entry.current == null && entry.available)
        .length;
    final total = entries.length;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_yearLabel(year)} a\u00f1o',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _SectionPill(label: '$approved/$total aprobadas'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$inProgress cursando \u00b7 $available disponibles',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekdayCell extends StatelessWidget {
  const _CalendarWeekdayCell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AcademicCalendarEventTile extends StatelessWidget {
  const _AcademicCalendarEventTile({
    required this.event,
    required this.allEntries,
    required this.history,
  });

  final _AcademicCalendarEvent event;
  final List<_CurriculumEntry> allEntries;
  final List<StudentAccessHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: event.entry == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _StudentSubjectDetailScreen(
                      entry: event.entry!,
                      allEntries: allEntries,
                      history: history,
                    ),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: event.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: event.color.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(event.icon, color: event.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.detail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (event.entry != null) ...[
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.42),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AcademicCalendarEvent {
  const _AcademicCalendarEvent({
    required this.date,
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    this.entry,
  });

  final DateTime date;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final _CurriculumEntry? entry;
}

class _LoadingStateCard extends StatelessWidget {
  const _LoadingStateCard({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 16),
          ],
          Text(
            'Trayectoria',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ??
                (loading
                    ? 'Cargando trayectoria del alumno...'
                    : 'Todavía no hay información cargada de la trayectoria del alumno.'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: error == null
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: loading ? null : onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1020) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? const Color(0xFF21304A) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CurriculumEntry {
  const _CurriculumEntry({
    required this.materia,
    required this.current,
    required this.available,
    required this.missing,
  });

  final Materia materia;
  final StudentAccessSubject? current;
  final bool available;
  final List<String> missing;
}

List<_CurriculumEntry> _buildCurriculumEntries(
  List<StudentAccessSubject> subjects,
  List<Materia> plan,
) {
  final subjectById = <String, StudentAccessSubject>{};
  final subjectByName = <String, StudentAccessSubject>{};
  for (final subject in subjects) {
    _addIndex(subjectById, subject.subjectId, subject);
    _addIndex(subjectByName, subject.subjectName, subject);
  }

  return [
    for (final materia in plan)
      _CurriculumEntry(
        materia: materia,
        current: _matchCurrentSubject(
          materia,
          byId: subjectById,
          byName: subjectByName,
        ),
        available: _missingCorrelativas(
          materia,
          subjects,
          plan,
        ).isEmpty,
        missing: _missingCorrelativas(materia, subjects, plan),
      ),
  ];
}

StudentAccessSubject? _matchCurrentSubject(
  Materia materia, {
  required Map<String, StudentAccessSubject> byId,
  required Map<String, StudentAccessSubject> byName,
}) {
  final key = _norm(materia.id);
  final current = byId[key] ?? byName[key];
  if (current != null) return current;

  final nameKey = _norm(materia.displayNombre);
  return byName[nameKey] ?? byId[nameKey];
}

List<String> _missingCorrelativas(
  Materia materia,
  List<StudentAccessSubject> subjects,
  List<Materia> plan,
) {
  final reqs = _resolvedRequirements(materia);

  final subjectById = <String, StudentAccessSubject>{};
  final subjectByName = <String, StudentAccessSubject>{};
  for (final subject in subjects) {
    _addIndex(subjectById, subject.subjectId, subject);
    _addIndex(subjectByName, subject.subjectName, subject);
  }

  final missing = <String>[];
  if (_isUdiMateria(materia) || _isPracticaDocenteIV(materia)) {
    missing.addAll(
      _missingPreviousYearsForUdi(
        materia,
        subjects,
        plan,
        byId: subjectById,
        byName: subjectByName,
      ),
    );
  }

  for (final req in reqs) {
    final ref = _matchRequirementSubject(
      req,
      byId: subjectById,
      byName: subjectByName,
    );
    final displayName = _displayNameForRequirement(req, plan);
    final status = ref == null ? null : _subjectStatusForRequirement(ref);
    final ok = switch (req.type.toUpperCase()) {
      'R' => status == 'regular' || status == 'aprobada',
      _ => status == 'aprobada',
    };
    if (!ok) missing.add(displayName);
  }
  return missing;
}

List<CorrelativaDetallada> _resolvedRequirements(Materia materia) {
  if (materia.correlativasDetalladas.isNotEmpty) {
    return materia.correlativasDetalladas;
  }
  return materia.correlativas
      .map(
        (id) => CorrelativaDetallada(
          id: id,
          type: 'A',
          nombre: id,
        ),
      )
      .toList(growable: false);
}

List<_CurriculumEntry> _subjectsUnlockedBy(
  _CurriculumEntry entry,
  List<_CurriculumEntry> allEntries,
) {
  final current = entry.materia;
  final currentKeys = <String>{
    _norm(current.id),
    _norm(current.nombre),
    _norm(current.displayNombre),
  };

  final unlocked = <_CurriculumEntry>[];
  for (final candidate in allEntries) {
    if (candidate.materia.id == current.id) continue;
    final reqs = _resolvedRequirements(candidate.materia);
    final matches = reqs.any((req) {
      final reqKey = _norm(req.id);
      return currentKeys.contains(reqKey);
    });
    if (matches) unlocked.add(candidate);
  }

  unlocked.sort((a, b) {
    final byYear = a.materia.anio.compareTo(b.materia.anio);
    if (byYear != 0) return byYear;
    return a.materia.displayNombre.compareTo(b.materia.displayNombre);
  });
  return unlocked;
}

StudentAccessSubject? _matchRequirementSubject(
  CorrelativaDetallada req, {
  required Map<String, StudentAccessSubject> byId,
  required Map<String, StudentAccessSubject> byName,
}) {
  final reqKey = _norm(req.id);
  return byId[reqKey] ?? byName[reqKey];
}

String _displayNameForRequirement(
    CorrelativaDetallada req, List<Materia> plan) {
  final reqKey = _norm(req.id);
  for (final materia in plan) {
    if (_norm(materia.id) == reqKey ||
        _norm(materia.displayNombre) == reqKey ||
        _norm(materia.nombre) == reqKey) {
      return materia.displayNombre;
    }
  }
  return req.nombre ?? req.id;
}

void _addIndex(
  Map<String, StudentAccessSubject> map,
  String raw,
  StudentAccessSubject value,
) {
  final key = _norm(raw);
  if (key.isNotEmpty) map[key] = value;
}

String _subjectStatusForRequirement(StudentAccessSubject subject) {
  final status = subject.status.toLowerCase().trim();
  if (status == 'aprobada') return 'aprobada';
  if (status == 'regular') return 'regular';
  if (subject.academicPeriod == 'equivalencia') return 'aprobada';
  return status;
}

String _subjectCreditDetail(StudentAccessSubject current) {
  final parts = <String>[
    'Aprobada en ${_periodLabel(current.academicPeriod).toLowerCase()}',
  ];
  if (current.detailStatus != null) {
    parts
        .add(_creditMethodLabel(current.academicPeriod, current.detailStatus!));
  }
  if (current.grade != null) {
    parts.add('Nota ${current.grade!.toStringAsFixed(0)}');
  }
  return parts.join(' · ');
}

String _subjectStateForRow(_CurriculumEntry entry) {
  if (entry.current != null) {
    final status = entry.current!.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => 'Aprobada',
      'cursando' => 'Cursando',
      'regular' => 'Regular',
      'no_regularizada' => 'No regularizada',
      _ => 'Cursando',
    };
  }
  return entry.available ? 'Disponible' : 'No disponible';
}

IconData _subjectStateIcon(_CurriculumEntry entry) {
  final current = entry.current;
  if (current != null) {
    final status = current.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => Icons.check_circle_rounded,
      'cursando' => Icons.play_circle_rounded,
      'regular' => Icons.assignment_turned_in_rounded,
      'no_regularizada' => Icons.cancel_rounded,
      _ => Icons.school_rounded,
    };
  }
  return entry.available ? Icons.task_alt_rounded : Icons.lock_rounded;
}

Color _subjectStateColor(BuildContext context, _CurriculumEntry entry) {
  final current = entry.current;
  if (current != null) {
    final status = current.status.toLowerCase().trim();
    return switch (status) {
      'aprobada' => const Color(0xFF2EAD57),
      'cursando' => const Color(0xFF1E6FDB),
      'regular' => const Color(0xFFD97706),
      'no_regularizada' => const Color(0xFFDC2626),
      _ => Theme.of(context).colorScheme.secondary,
    };
  }
  return entry.available ? const Color(0xFF0E7490) : const Color(0xFFD93025);
}

bool _isSubjectInProgress(StudentAccessSubject subject) {
  final status = subject.status.toLowerCase().trim();
  return status == 'regular' || status == 'cursando';
}

bool _isSubjectApproved(StudentAccessSubject subject) {
  return _subjectStatusForRequirement(subject) == 'aprobada';
}

bool _isEntryBlocked(_CurriculumEntry entry) {
  final current = entry.current;
  if (entry.available) return false;
  if (current == null) return true;
  return !_isSubjectApproved(current) && !_isSubjectInProgress(current);
}

String? _subjectCardDate(
  _CurriculumEntry entry,
  List<StudentAccessHistoryEntry> history,
) {
  final current = entry.current;
  if (current == null) return null;
  if (current.sourceDate != null) {
    return _historyDateLabel(current.sourceDate);
  }
  final steps = _subjectHistorySteps(entry, history);
  if (steps.isEmpty) return null;
  return steps.last.dateLabel;
}

List<_SubjectHistoryStep> _subjectHistorySteps(
  _CurriculumEntry entry,
  List<StudentAccessHistoryEntry> history,
) {
  final subjectKeys = <String>{
    _norm(entry.materia.id),
    _norm(entry.materia.nombre),
    _norm(entry.materia.displayNombre),
  };

  final matching = <StudentAccessHistoryEntry>[];
  for (final item in history) {
    final payload = item.payload;
    final payloadKeys = <String>{
      _norm(payload['subject_id']?.toString() ?? ''),
      _norm(payload['subject_name']?.toString() ?? ''),
      _norm(payload['subject']?.toString() ?? ''),
    };
    if (payloadKeys.any(subjectKeys.contains)) matching.add(item);
  }

  matching.sort((a, b) {
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return aDate.compareTo(bDate);
  });

  final steps = <_SubjectHistoryStep>[];
  _SubjectHistoryStep? approvalStep;

  for (final item in matching) {
    final payload = item.payload;
    final status = _norm(payload['status']?.toString() ?? '');
    final eventType = _norm(item.eventType);
    final isApproved = status == 'aprobada' ||
        eventType.contains('aprob') ||
        eventType.contains('approve');
    final isEnrollment = !isApproved &&
        (eventType.contains('inscrip') ||
            eventType.contains('enroll') ||
            eventType.contains('upsert') ||
            status == 'cursando' ||
            status == 'regular');

    final dateLabel = _historyDateLabel(item.createdAt) ??
        _historyDateLabel(_parseHistoryDate(payload['source_date']));

    if (isEnrollment && steps.every((step) => step.label != 'Inscripción')) {
      steps.add(
        _SubjectHistoryStep(
          label: 'Inscripción',
          detail: 'Alta de la materia',
          dateLabel: dateLabel,
          color: const Color(0xFF2B6F96),
          icon: Icons.edit_note_rounded,
        ),
      );
    }

    if (isApproved) {
      approvalStep = _SubjectHistoryStep(
        label: 'Acreditación del espacio',
        detail: _historyCreditDetail(payload),
        dateLabel: dateLabel,
        color: const Color(0xFF2EAD57),
        icon: Icons.check_circle_rounded,
      );
    }
  }

  if (steps.isEmpty &&
      approvalStep == null &&
      entry.current?.status.toLowerCase().trim() == 'aprobada') {
    steps.add(
      _SubjectHistoryStep(
        label: 'Inscripción',
        detail: 'Registro inicial',
        dateLabel: _historyDateLabel(entry.current?.sourceDate),
        color: const Color(0xFF2B6F96),
        icon: Icons.edit_note_rounded,
      ),
    );
  }

  if (approvalStep == null &&
      entry.current != null &&
      entry.current!.status.toLowerCase().trim() == 'aprobada') {
    approvalStep = _SubjectHistoryStep(
      label: 'Acreditación del espacio',
      detail: _subjectCreditDetail(entry.current!),
      dateLabel: _historyDateLabel(entry.current!.sourceDate),
      color: const Color(0xFF2EAD57),
      icon: Icons.check_circle_rounded,
    );
  }

  if (approvalStep != null) {
    steps.removeWhere((step) => step.label == 'Acreditación del espacio');
    steps.add(approvalStep);
  }

  return steps;
}

DateTime? _parseHistoryDate(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String? _historyDateLabel(DateTime? date) {
  if (date == null) return null;
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

List<_StudentMovement> _buildStudentMovements(
  List<StudentAccessHistoryEntry> history,
  List<_CurriculumEntry> entries,
) {
  final enrollmentsByDay = <String, List<StudentAccessHistoryEntry>>{};
  final movements = <_StudentMovement>[];

  _CurriculumEntry? findEntry(String? name) {
    if (name == null || name.isEmpty) return null;
    final normalized = _norm(name);
    return entries.cast<_CurriculumEntry?>().firstWhere(
          (e) =>
              _norm(e!.materia.id) == normalized ||
              _norm(e.materia.displayNombre) == normalized ||
              _norm(e.materia.nombre) == normalized,
          orElse: () => null,
        );
  }

  for (final entry in history) {
    final payload = entry.payload;
    final status = _norm(payload['status']?.toString() ?? '');
    final eventType = _norm(entry.eventType);
    final subjectName = payload['subject_name']?.toString().trim() ?? '';
    final dateLabel = _historyDateLabel(entry.createdAt);
    final dayKey = dateLabel ?? 'sin-fecha';
    final isApproved = status == 'aprobada' ||
        eventType.contains('aprob') ||
        eventType.contains('approve');
    final isEnrollment = !isApproved &&
        (eventType.contains('inscrip') ||
            eventType.contains('enroll') ||
            eventType.contains('upsert') ||
            status == 'cursando' ||
            status == 'regular');

    if (isEnrollment && subjectName.isNotEmpty) {
      enrollmentsByDay.putIfAbsent(dayKey, () => []).add(entry);
      continue;
    }

    if (isApproved && subjectName.isNotEmpty) {
      movements.add(
        _StudentMovement(
          title: 'Aprobó $subjectName',
          detail: _historyCreditDetail(payload),
          dateLabel: dateLabel,
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF2EAD57),
          entry: findEntry(subjectName),
        ),
      );
    }

    if (eventType.contains('contact')) {
      movements.add(
        _StudentMovement(
          title: 'Actualizó sus datos de contacto',
          detail: _contactHistoryDetail(payload),
          dateLabel: dateLabel,
          icon: Icons.contact_phone_rounded,
          color: const Color(0xFF2B6F96),
        ),
      );
    }
  }

  for (final entry in enrollmentsByDay.entries) {
    final rows = entry.value;
    rows.sort((a, b) {
      final aName = a.payload['subject_name']?.toString() ?? '';
      final bName = b.payload['subject_name']?.toString() ?? '';
      return aName.compareTo(bName);
    });
    final names = rows
        .map((row) => row.payload['subject_name']?.toString().trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    if (names.isEmpty) continue;
    final extra = names.length > 2 ? ' +${names.length - 2}' : '';
    movements.add(
      _StudentMovement(
        title: names.length == 1
            ? 'Se inscribió a ${names.first}'
            : 'Se inscribió a varias materias',
        detail: '${names.take(2).join(' · ')}$extra',
        dateLabel: entry.key == 'sin-fecha' ? null : entry.key,
        icon: Icons.playlist_add_check_rounded,
        color: const Color(0xFF2B6F96),
        entry: names.length == 1 ? findEntry(names.first) : null,
      ),
    );
  }

  movements.sort((a, b) {
    final aDate = _parseDisplayDate(a.dateLabel) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = _parseDisplayDate(b.dateLabel) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  });
  return movements;
}

List<_AcademicCalendarEvent> _buildAcademicCalendarEvents(
  List<StudentAccessHistoryEntry> history,
  List<_CurriculumEntry> entries,
) {
  final events = <_AcademicCalendarEvent>[];
  final dedupe = <String>{};

  void addEvent(_AcademicCalendarEvent event) {
    final key =
        '${_dateOnly(event.date).toIso8601String()}|${_norm(event.title)}|${_norm(event.detail)}';
    if (dedupe.add(key)) {
      events.add(event);
    }
  }

  for (final movement in _buildStudentMovements(history, entries)) {
    final date = _parseDisplayDate(movement.dateLabel);
    if (date == null) continue;
    addEvent(
      _AcademicCalendarEvent(
        date: date,
        title: movement.title,
        detail: movement.detail,
        icon: movement.icon,
        color: movement.color,
        entry: movement.entry,
      ),
    );
  }

  for (final entry in entries) {
    final current = entry.current;
    if (current == null || current.sourceDate == null) continue;
    if (!_isSubjectApproved(current)) continue;
    addEvent(
      _AcademicCalendarEvent(
        date: current.sourceDate!,
        title: 'Aprob\u00f3 ${entry.materia.displayNombre}',
        detail: current.grade == null
            ? 'Materia acreditada'
            : 'Materia acreditada \u00b7 Nota ${current.grade!.toStringAsFixed(0)}',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF2EAD57),
        entry: entry,
      ),
    );
  }

  events.sort((a, b) => b.date.compareTo(a.date));
  return events;
}

String _progressDiagnosis({
  required StudentAccessProfile student,
  required int approved,
  required int available,
  required int blocked,
}) {
  if (available == 0 && blocked > 0) {
    return 'Hoy no ten\u00e9s materias nuevas habilitadas. Conviene cerrar materias en curso o revisar correlativas pendientes para destrabar el siguiente tramo.';
  }
  if (available >= 4) {
    return 'Ten\u00e9s un margen amplio para elegir cursadas. Est\u00e1s en un momento favorable para priorizar materias que ordenen mejor el resto del recorrido.';
  }
  if (approved <= 4) {
    return 'Tu trayectoria todav\u00eda est\u00e1 en una etapa inicial. Suma mucho consolidar las bases del ${student.yearLabel.toLowerCase()} antes de abrir demasiados frentes.';
  }
  return 'Tu avance est\u00e1 equilibrado. Ya hay materias acreditadas y tambi\u00e9n opciones disponibles para seguir moviendo el plan sin perder continuidad.';
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _monthLabel(DateTime value) {
  const months = <String>[
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  return '${months[value.month - 1]} ${value.year}';
}

String _historyCreditDetail(Map<String, dynamic> payload) {
  final parts = <String>[];
  final period = (payload['academic_period'] ?? payload['source_period'] ?? '')
      .toString()
      .trim();
  if (period.isNotEmpty) {
    parts.add('Aprobada en ${_periodLabel(period).toLowerCase()}');
  } else {
    parts.add('Aprobada');
  }
  final detail = payload['detail_status']?.toString().trim() ?? '';
  if (detail.isNotEmpty) parts.add(_creditMethodLabel(period, detail));
  final grade = payload['grade'];
  if (grade != null && grade.toString().trim().isNotEmpty) {
    final parsed = num.tryParse(grade.toString());
    parts.add(
        parsed == null ? 'Nota $grade' : 'Nota ${parsed.toStringAsFixed(0)}');
  }
  return parts.join(' · ');
}

String _contactHistoryDetail(Map<String, dynamic> payload) {
  final parts = <String>[];
  final phone = payload['contact_phone']?.toString().trim() ?? '';
  final email = payload['contact_email']?.toString().trim() ?? '';
  if (phone.isNotEmpty) parts.add('Teléfono cargado');
  if (email.isNotEmpty) parts.add('E-mail cargado');
  if (parts.isEmpty) return 'Actualización de contacto';
  return parts.join(' · ');
}

String _creditMethodLabel(String period, String detail) {
  final normalizedPeriod = _norm(period);
  final normalizedDetail = _norm(detail);
  if (normalizedDetail == 'mesa_final' &&
      (normalizedPeriod == 'mayo' ||
          normalizedPeriod == 'mayo_extraordinaria' ||
          normalizedPeriod == 'mayo extraordinaria')) {
    return 'Mesa extraordinaria';
  }
  return _detailLabel(detail);
}

DateTime? _parseDisplayDate(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final parts = text.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

bool _isUdiMateria(Materia materia) {
  final name = _norm(materia.displayNombre);
  final format = _norm(materia.formato);
  return format.contains('variable') &&
      (name.contains('udi') ||
          name.contains('unidad de definicion institucional'));
}

bool _isPracticaDocenteIV(Materia materia) {
  final raw = _norm(materia.displayNombre);
  final hasPractica = raw.contains('practica');
  final hasIv = RegExp(r'\b(iv|4|cuarta)\b').hasMatch(raw);
  final docenteResid = raw.contains('docente') || raw.contains('residencia');
  return hasPractica && hasIv && docenteResid;
}

List<String> _missingPreviousYearsForUdi(
  Materia materia,
  List<StudentAccessSubject> subjects,
  List<Materia> plan, {
  required Map<String, StudentAccessSubject> byId,
  required Map<String, StudentAccessSubject> byName,
}) {
  if (materia.anio <= 1) return const [];

  final missing = <String>[];
  for (var year = 1; year < materia.anio; year++) {
    final yearMaterias = plan.where((item) => item.anio == year).toList();
    if (yearMaterias.isEmpty) continue;

    final allApproved = yearMaterias.every((yearMateria) {
      final current = _matchCurrentSubject(
        yearMateria,
        byId: byId,
        byName: byName,
      );
      if (current == null) return false;
      return _subjectStatusForRequirement(current) == 'aprobada';
    });

    if (!allApproved) {
      missing.add('${_yearLabel(year)} año completo');
    }
  }
  return missing;
}

String _yearLabel(int year) {
  return switch (year) {
    1 => '1°',
    2 => '2°',
    3 => '3°',
    4 => '4°',
    _ => '$year°',
  };
}

String _enrollmentStatusLabel(String value) {
  return switch (_norm(value)) {
    'active' => 'Activo',
    'inactive' => 'Inactivo',
    'pending' => 'Pendiente',
    _ => value,
  };
}

String _careerAssetFor(String careerId) {
  return switch (careerId) {
    'historia' => 'assets/historia.html',
    'geografia' => 'assets/geografia.html',
    'politica' => 'assets/politica.html',
    'artes_visuales' => 'assets/data/artes_visuales.json',
    'musica' => 'assets/Musica.html',
    _ => 'assets/historia.html',
  };
}

String _institutionLogoAssetFor(String careerId) {
  return switch (careerId) {
    'artes_visuales' => 'assets/career_icons/logo_artes.png',
    'historia' ||
    'geografia' ||
    'politica' =>
      'assets/career_icons/career_logo.png',
    _ => 'assets/career_icons/career_logo.png',
  };
}

String _careerLabel(String careerId) {
  return switch (careerId) {
    'artes_visuales' => 'Artes Visuales',
    'musica' => 'Música',
    'historia' => 'Historia',
    'geografia' => 'Geografía',
    'politica' => 'Ciencia Política',
    _ => careerId,
  };
}

String _periodLabel(String value) {
  return switch (value) {
    'diciembre' => 'Diciembre',
    'febrero_marzo' => 'Febrero-marzo',
    'febrero-marzo' => 'Febrero-marzo',
    'febrero' => 'Febrero-marzo',
    'julio' => 'Julio',
    'mayo' => 'Mayo',
    'mayo_extraordinaria' => 'Mayo extraordinaria',
    'regular' => 'Regular',
    'cursada' => 'Cursada',
    'tif' => 'TIF',
    'equivalencia' => 'Equivalencia',
    'ajuste' => 'Ajuste',
    _ => value,
  };
}

String _detailLabel(String value) {
  return switch (value) {
    'promocion_directa' => 'Promoción directa',
    'mesa_final' => 'Mesa final',
    'equivalencia' => 'Equivalencia',
    'coloquio_tif' => 'Coloquio/TIF',
    'desaprobo' => 'Desaprobó',
    'libre' => 'Libre',
    'abandono' => 'Abandono',
    'no_continuo' => 'No continuó',
    'rechazo_equivalencia' => 'Rechazo equivalencia',
    _ => value,
  };
}

String _norm(String value) =>
    sanitizeLowerNoAccents(value).replaceAll(RegExp(r'\s+'), ' ').trim();

class _GuestRegistrationSheet extends StatefulWidget {
  const _GuestRegistrationSheet({required this.onStart});

  final void Function(String name, String dni, String careerId) onStart;

  @override
  State<_GuestRegistrationSheet> createState() => _GuestRegistrationSheetState();
}

class _GuestRegistrationSheetState extends State<_GuestRegistrationSheet> {
  final _nameCtrl = TextEditingController(text: 'Invitado');
  final _dniCtrl = TextEditingController();
  String _selectedCareer = 'historia';

  final _careers = const {
    'artes_visuales': 'Artes Visuales',
    'historia': 'Historia',
    'geografia': 'Geografía',
    'politica': 'Ciencias Políticas',
  };

  void _submit() {
    final name = _nameCtrl.text.trim().isEmpty ? 'Invitado' : _nameCtrl.text.trim();
    final dni = _dniCtrl.text.replaceAll(RegExp(r'\D'), '').trim();
    widget.onStart(name, dni, _selectedCareer);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dniCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        32 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Perfil de Invitado',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Completá estos datos para armar tu plan de estudios personalizado.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Tu nombre',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dniCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DNI (opcional)',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCareer,
            decoration: const InputDecoration(
              labelText: 'Carrera que cursás',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: _careers.entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCareer = value);
              }
            },
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Comenzar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
