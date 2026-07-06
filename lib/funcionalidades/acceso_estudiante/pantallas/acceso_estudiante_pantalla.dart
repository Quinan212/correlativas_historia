import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../datos/cargador_fuente_html.dart';
import '../../../funcionalidades/calculadora/pantalla/pantalla_calculadora.dart';
import '../../../funcionalidades/cascada/pantalla/pantalla_inicio_mapa.dart';
import '../../../funcionalidades/cascada/pantalla/pantalla_mapa_correlatividades.dart';
import '../../../funcionalidades/cascada/panel_detalle/componentes/controles_superiores.dart';
import '../../../funcionalidades/examenes/examenes_pantalla.dart';
import '../../../funcionalidades/preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import '../../../modelos/materia.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../../../compartido/componentes/tarjetas_metricas.dart';
import '../../../compartido/componentes/navegacion_inferior.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../datos/repositorio_acceso_estudiante.dart';
import '../modelos/modelos_acceso_estudiante.dart';
import 'materias_autodeclaradas_pantalla.dart';

part '../componentes/acceso/encabezado_y_portada_estudiante.dart';
part '../componentes/panel/panel_estudiante.dart';
part '../componentes/datos/datos_estudiante.dart';
part '../componentes/materias/materias_estudiante.dart';
part '../componentes/materias/estado_academico_estudiante.dart';
part '../componentes/seguimiento/pantallas_secundarias_estudiante.dart';
part '../componentes/comunes/componentes_comunes_estudiante.dart';
part '../dominio/entrada_plan_estudios.dart';
part '../componentes/acceso/registro_invitado_estudiante.dart';

class AccesoEstudiantePantalla extends ConsumerStatefulWidget {
  const AccesoEstudiantePantalla({super.key});

  @override
  ConsumerState<AccesoEstudiantePantalla> createState() =>
      _AccesoEstudiantePantallaState();
}

class _AccesoEstudiantePantallaState
    extends ConsumerState<AccesoEstudiantePantalla> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repo = const RepositorioAccesoEstudiante();
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  bool _compactHeader = false;
  String? _error;
  DatosAccesoEstudiante? _payload;
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) {
      setState(() => _error = 'Supabase no está listo todavía.');
      return;
    }

    final dni = _emailCtrl.text.replaceAll(RegExp(r'\D'), '').trim();
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
        child: _HojaRegistroInvitado(
          onStart: (name, dni, careerId) {
            Navigator.pop(context);
            _guestLogin(name, dni, careerId);
          },
        ),
      ),
    );
  }

  Future<void> _guestLogin(
      String firstName, String dni, String careerId) async {
    final client = ref.read(proveedorClienteSupabase);
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
      await _repo.load(
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
    final client = ref.read(proveedorClienteSupabase);
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
        builder: (_) => _conNavegacionInferior(const PantallaInicioMapa()),
      ),
    );
  }

  void _openPlanCompleto() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _conNavegacionInferior(const PantallaMapaCorrelatividades()),
      ),
    );
  }

  void _openEscenarios() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _conNavegacionInferior(const PantallaCalculadora()),
      ),
    );
  }

  void _openAyuda() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _conNavegacionInferior(const PantallaPreguntasFrecuentes()),
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
        builder: (_) => _conNavegacionInferior(
          _ProximosPasosEstudiantePantalla(
            payload: payload,
            entries: entries,
          ),
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
        builder: (_) => _conNavegacionInferior(
          _ProgresoEstudiantePantalla(
            payload: payload,
            entries: entries,
          ),
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
        builder: (_) => _conNavegacionInferior(
          _CalendarioAcademicoEstudiantePantalla(
            payload: payload,
            entries: entries,
          ),
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
        builder: (context) => _NotificacionesEstudiantePantalla(
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
        builder: (context) => _DatosEstudiantePantalla(
          student: student,
          onSaveContact: _saveStudentContact,
        ),
      ),
    );
  }

  Future<void> _abrirHojaCuenta() async {
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
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    await client.auth.signOut();
    if (!mounted) return;
    setState(() {
      _payload = null;
      _planFuture = null;
      _seenNotificationsCount = 0;
      _error = null;
      _emailCtrl.clear();
      _passwordCtrl.clear();
    });
  }

  void _abrirPantallaMaterias() {
    final payload = _payload;
    if (payload == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _MateriasEstudiantePantalla(
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
    Navigator.of(context)
        .push(
      MaterialPageRoute<void>(
        builder: (_) => _conNavegacionInferior(
          MateriasAutodeclaradasPantalla(payload: payload),
        ),
      ),
    )
        .then((_) {
      if (mounted) {
        _loadTrajectory();
      }
    });
  }

  Widget _conNavegacionInferior(Widget child) {
    return Consumer(
      builder: (context, ref, _) {
        final current = ref.watch(proveedorIndiceRouter).clamp(0, 4);

        void navigateTo(int index) {
          ref.read(proveedorIndiceRouter.notifier).state = index;
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: MediaQuery.sizeOf(context).width >= 900
              ? null
              : NavegacionInferiorApp(
                  current: current,
                  onTapTrayectorias: () => navigateTo(0),
                  onTapHome: () => navigateTo(1),
                  onTapMap: () => navigateTo(2),
                  onTapCalc: () => navigateTo(3),
                ),
        );
      },
    );
  }

  Future<void> _saveStudentContact({
    required String phone,
    required String email,
    String? firstName,
    String? lastName,
    String? dni,
    String? careerId,
    String? division,
    int? currentYear,
    int? cohortYear,
  }) async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) {
      throw StateError('Supabase no está listo todavía.');
    }

    await _repo.updateContact(
      client: client,
      phone: phone,
      email: email,
      firstName: firstName,
      lastName: lastName,
      dni: dni,
      careerId: careerId,
      division: division,
      currentYear: currentYear,
      cohortYear: cohortYear,
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
              _BannerPortada(
                loggedIn: loggedIn,
                student: student,
                movementCount:
                    (_payload?.history.length ?? 0) - _seenNotificationsCount,
                onRefresh: loggedIn ? _loadTrajectory : null,
                onOpenSubjects:
                    _payload == null ? null : _abrirPantallaMaterias,
                onOpenHistory: _payload == null ? null : _openNotifications,
                onOpenExams: _payload == null ? null : _openExamenes,
                onShowStudentData: _payload == null ? null : _showStudentData,
                onOpenAccountSheet: _payload == null ? null : _abrirHojaCuenta,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    if (!loggedIn) ...[
                      _TarjetaIngreso(
                        loading: _loading,
                        error: _error,
                        emailCtrl: _emailCtrl,
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
                              _FranjaResumen(
                                payload: _payload!,
                                plan: plan,
                                entries: entries,
                              ),
                              const SizedBox(height: 12),
                              _ExamShortcutBanner(onTap: _openExamenes),
                              const SizedBox(height: 14),
                              _AccionesSecundariasAccesoEstudiante(
                                onOpenInicio: _openInicioMapa,
                                onOpenPlan: _openPlanCompleto,
                                onOpenEscenarios: _openEscenarios,
                                onOpenAyuda: _openAyuda,
                              ),
                              const SizedBox(height: 12),
                              _AccionesAnaliticasAccesoEstudiante(
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
                      _TarjetaEstadoCarga(
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
          _EncabezadoEstudianteFijo(
            loggedIn: loggedIn,
            student: student,
            compact: _compactHeader,
            movementCount:
                (_payload?.history.length ?? 0) - _seenNotificationsCount,
            onOpenHistory: _payload == null ? null : _openNotifications,
            onRefresh: loggedIn ? _loadTrajectory : null,
            onOpenAccountSheet: _payload == null ? null : _abrirHojaCuenta,
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
    final plan = await cargarPlanDesdeAssetHtml(_careerAssetFor(careerId));
    return plan.materias;
  }
}
