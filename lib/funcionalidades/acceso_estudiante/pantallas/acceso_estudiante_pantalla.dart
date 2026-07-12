import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../compartido/componentes/tarjetas_metricas.dart';
import '../../../compartido/media/widgets_media_remota.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../../../datos/cargador_fuente_html.dart';
import '../../../funcionalidades/calculadora/pantalla/pantalla_calculadora.dart';
import '../../../funcionalidades/cascada/pantalla/pantalla_mapa_correlatividades.dart';
import '../../../funcionalidades/curriculum/pantalla/pantalla_disenos_curriculares.dart';
import '../../../funcionalidades/examenes/componentes/etiqueta_carrera_examenes.dart';
import '../../../funcionalidades/examenes/examenes_pantalla.dart';
import '../../../funcionalidades/preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import '../../../modelos/materia.dart';
import '../datos/repositorio_acceso_estudiante.dart';
import '../modelos/modelos_acceso_estudiante.dart';
import 'materias_autodeclaradas_pantalla.dart';

part '../componentes/acceso/encabezado_y_portada_estudiante.dart';
part '../componentes/panel/panel_estudiante.dart';
part '../componentes/datos/datos_estudiante.dart';
part '../componentes/materias/materias_estudiante.dart';
part '../componentes/materias/estado_academico_estudiante.dart';
part '../componentes/seguimiento/notificaciones_estudiante_pantalla.dart';
part '../componentes/seguimiento/proximos_pasos_estudiante_pantalla.dart';
part '../componentes/seguimiento/progreso_estudiante_pantalla.dart';
part '../componentes/seguimiento/calendario_academico_estudiante_pantalla.dart';
part '../componentes/comunes/componentes_comunes_estudiante.dart';
part '../dominio/entrada_plan_estudios.dart';
part '../componentes/acceso/registro_invitado_estudiante.dart';
part '../componentes/seguimiento/trayectoria_reimaginada_estudiante_pantalla.dart';

class AccesoEstudiantePantalla extends ConsumerStatefulWidget {
  const AccesoEstudiantePantalla({super.key, this.onOpenSearch});

  final VoidCallback? onOpenSearch;

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
  final GlobalKey _bannerPortadaKey = GlobalKey();

  bool _loading = false;
  String? _error;
  DatosAccesoEstudiante? _payload;
  Future<List<Materia>>? _planFuture;
  int _seenNotificationsCount = 0;
  double _bannerPortadaHeight = 280.0;
  bool _bannerMeasurementScheduled = false;

  /// ID de sesión: se incrementa cada vez que se abre una nueva sección del
  /// nav bar. Permite que el .then() de un push anterior no resetee el provider
  /// si ya se cambio de sección antes de que terminara la animación de salida.
  int _navSession = 0;

  @override
  void initState() {
    super.initState();
    final client = ref.read(proveedorClienteSupabase);
    if (client?.auth.currentSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrajectory());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _scheduleBannerPortadaMeasurement() {
    if (_bannerMeasurementScheduled) return;

    _bannerMeasurementScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerMeasurementScheduled = false;

      if (!mounted) return;

      final renderObject = _bannerPortadaKey.currentContext?.findRenderObject();

      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final measuredHeight = renderObject.size.height;

      if ((measuredHeight - _bannerPortadaHeight).abs() < 0.5) {
        return;
      }

      setState(() {
        _bannerPortadaHeight = measuredHeight;
      });
    });
  }

  String _mensajeErrorAutenticacion(AuthException error) {
    final message = error.message.toLowerCase().trim();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        message.contains('email or password')) {
      return 'El DNI o la contraseña son incorrectos.';
    }

    if (message.contains('email not confirmed')) {
      return 'La cuenta todavía no fue confirmada.';
    }

    if (message.contains('user not found')) {
      return 'No encontramos una cuenta asociada a ese DNI.';
    }

    if (message.contains('invalid email')) {
      return 'El DNI o correo ingresado no es válido.';
    }

    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Hubo demasiados intentos. Esperá un momento y volvé a probar.';
    }

    if (message.contains('anonymous sign-ins are disabled') ||
        message.contains('anonymous provider is disabled')) {
      return 'El ingreso como invitado no está habilitado en este momento.';
    }

    if (message.contains('signup is disabled')) {
      return 'La creación de cuentas no está habilitada.';
    }

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socket')) {
      return 'No se pudo conectar. Revisá tu conexión a internet.';
    }

    return 'No se pudo iniciar sesión. Revisá los datos e intentá nuevamente.';
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
      if (!mounted) return;

      setState(() {
        _error = _mensajeErrorAutenticacion(error);
      });
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
          onStart: (name, careerId) {
            Navigator.pop(context);
            _guestLogin(name, careerId);
          },
        ),
      ),
    );
  }

  Future<void> _guestLogin(String firstName, String careerId) async {
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
        guestCareerId: careerId,
      );
      await _loadTrajectory(guestFirstName: firstName, guestCareerId: careerId);
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _mensajeErrorAutenticacion(error);
      });
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
      setState(() {
        _error = _mensajeErrorCargaTrayectoria(error);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mensajeErrorCargaTrayectoria(Object error) {
    final message = error.toString().toLowerCase();
    final isNetworkError =
        message.contains('socket') ||
        message.contains('connection') ||
        message.contains('failed host lookup') ||
        message.contains('network') ||
        message.contains('clientexception');
    if (isNetworkError) {
      return 'No hay conexión y todavía no tenemos datos guardados para esta sesión.';
    }
    return 'No se pudo cargar la trayectoria. Reintentá en un momento.';
  }

  void _openExamenes() {
    final careerId = _payload?.student.careerId;
    prewarmExamenesData(ref, careerId: careerId);
    Navigator.of(context, rootNavigator: true).push(buildExamenesRoute());
  }

  void _openPlanCompleto() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PantallaMapaCorrelatividades(),
      ),
    );
  }

  void _openEscenarios() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PantallaCalculadora()),
    );
  }

  void _openAyuda() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PantallaPreguntasFrecuentes(),
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
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _ProximosPasosEstudiantePantalla(
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
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              _ProgresoEstudiantePantalla(payload: payload, entries: entries),
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
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _CalendarioAcademicoEstudiantePantalla(
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
    unawaited(
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (context) => _NotificacionesEstudiantePantalla(
            history: payload.history,
            entries: entries,
          ),
        ),
      ),
    );
  }

  void _showStudentData() {
    final student = _payload?.student;
    if (student == null) return;
    Navigator.of(context, rootNavigator: true).push(
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
      // ignore: avoid_redundant_argument_values
      useRootNavigator: true,
      isScrollControlled: true,
      // ignore: avoid_redundant_argument_values
      useSafeArea: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final cs = theme.colorScheme;

        TableRow dataRow(String label, String value) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        }

        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 44,
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Cuenta',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _InstitutionLogoMark(
                      loggedIn: true,
                      assetPath: _institutionLogoAssetFor(student.careerId),
                      // ignore: avoid_redundant_argument_values
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Perfil del estudiante',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 18),
                Text(
                  'Datos académicos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(100),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    dataRow('DNI', student.dni),
                    dataRow('Carrera', _etiquetaCarrera(student.careerId)),
                    dataRow('Año', student.yearLabel),
                    if (student.cohortYear != null)
                      dataRow('Cohorte', '${student.cohortYear}'),
                    if (student.division != null)
                      dataRow('División', '${student.division}'),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 18),
                Text(
                  'Sesión',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 36,
                  leading: Icon(
                    Icons.logout_rounded,
                    color: cs.error,
                    size: 28,
                  ),
                  title: Text(
                    'Cerrar sesión',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    'Volver al ingreso del alumno',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: cs.error),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
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
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => _MateriasEstudiantePantalla(
          payload: payload,
          planFuture:
              _planFuture ?? _loadPlanForCareer(payload.student.careerId),
        ),
      ),
    );
  }

  void _abrirPantallaMateriasConFiltro(
    List<_CurriculumEntry> entries,
    bool Function(_CurriculumEntry) match,
    String status,
  ) {
    final payload = _payload;
    if (payload == null) return;
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (final e in entries) {
      if (match(e)) counts[e.materia.anio] = (counts[e.materia.anio] ?? 0) + 1;
    }
    final year = counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => _MateriasEstudiantePantalla(
          payload: payload,
          planFuture:
              _planFuture ?? _loadPlanForCareer(payload.student.careerId),
          initialYear: year,
          initialStatus: status,
        ),
      ),
    );
  }

  Future<void> _openCurriculum() async {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PantallaDisenosCurriculares(),
        ),
      ),
    );
  }

  Future<void> _openReimaginedTrajectory() async {
    final payload = _payload;
    if (payload == null) return;
    final plan =
        await (_planFuture ?? _loadPlanForCareer(payload.student.careerId));
    final entries = _buildCurriculumEntries(payload.combinedSubjects, plan);
    if (!mounted) return;
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _TrayectoriaReimaginadaEstudiantePantalla(
            payload: payload,
            entries: entries,
          ),
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
            builder: (_) => MateriasAutodeclaradasPantalla(payload: payload),
          ),
        )
        .then((_) {
          if (mounted) {
            _loadTrajectory();
          }
        });
  }

  /// Abre la pantalla de Exámenes dentro del navigator anidado
  /// (la barra de navegación sigue visible).
  void _openExamenesNavBar() {
    final sessionId = _navSession;
    final careerId = _payload?.student.careerId;
    prewarmExamenesData(ref, careerId: careerId);
    Navigator.of(context).push(buildExamenesRoute()).then((_) {
      if (mounted && _navSession == sessionId) {
        ref.read(proveedorSeccionNav.notifier).state = 0;
      }
    });
  }

  /// Abre la pantalla de Materias dentro del navigator anidado.
  void _abrirMateriasNavBar() {
    final payload = _payload;
    if (payload == null) {
      ref.read(proveedorSeccionNav.notifier).state = 0;
      return;
    }
    final sessionId = _navSession;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => _MateriasEstudiantePantalla(
              payload: payload,
              planFuture:
                  _planFuture ?? _loadPlanForCareer(payload.student.careerId),
            ),
          ),
        )
        .then((_) {
          if (mounted && _navSession == sessionId) {
            ref.read(proveedorSeccionNav.notifier).state = 0;
          }
        });
  }

  /// Abre la pantalla de Datos del estudiante dentro del navigator anidado.
  void _abrirDatosNavBar() {
    final student = _payload?.student;
    if (student == null) {
      ref.read(proveedorSeccionNav.notifier).state = 0;
      return;
    }
    final sessionId = _navSession;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => _DatosEstudiantePantalla(
              student: student,
              onSaveContact: _saveStudentContact,
            ),
          ),
        )
        .then((_) {
          if (mounted && _navSession == sessionId) {
            ref.read(proveedorSeccionNav.notifier).state = 0;
          }
        });
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
    // Escucha la sección activa del nav bar y navega dentro del navigator anidado.
    ref.listen<int>(proveedorSeccionNav, (prev, next) {
      if (next == prev) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _navSession++; // Invalida los .then() de secciones anteriores.
        if (next == 0) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        } else if (next == 1) {
          Navigator.of(context).popUntil((r) => r.isFirst);
          _openExamenesNavBar();
        } else if (next == 2) {
          Navigator.of(context).popUntil((r) => r.isFirst);
          _abrirMateriasNavBar();
        } else if (next == 3) {
          Navigator.of(context).popUntil((r) => r.isFirst);
          _abrirDatosNavBar();
        }
      });
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loggedIn = ref.watch(proveedorSesionActivaSupabase);
    final student = _payload?.student;
    final fixedHeaderHeight = MediaQuery.of(context).padding.top + 62.0;
    _scheduleBannerPortadaMeasurement();
    const headerCornerBandHeight = 24.0;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF050816)
          : const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          Positioned(
            top: fixedHeaderHeight - headerCornerBandHeight,
            left: 0,
            right: 0,
            height: headerCornerBandHeight,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final scrollOffset = _scrollController.hasClients
                      ? math.max(_scrollController.offset, 0.0)
                      : 0.0;

                  return CustomPaint(
                    painter: _FondoEsquinasEncabezadoPainter(
                      scrollOffset: scrollOffset,
                      gradientTopExtension: fixedHeaderHeight,
                      bannerHeight: _bannerPortadaHeight,
                      hasLoadedStudent: loggedIn && student != null,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: fixedHeaderHeight),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    key: _bannerPortadaKey,
                    child: _BannerPortada(
                      loggedIn: loggedIn,
                      student: student,
                      gradientTopExtension: fixedHeaderHeight,
                      movementCount:
                          (_payload?.history.length ?? 0) -
                          _seenNotificationsCount,
                      onRefresh: loggedIn ? _loadTrajectory : null,
                      onOpenSubjects: _payload == null
                          ? null
                          : _abrirPantallaMaterias,
                      onOpenHistory: _payload == null
                          ? null
                          : _openNotifications,
                      onOpenExams: _payload == null ? null : _openExamenes,
                      onShowStudentData: _payload == null
                          ? null
                          : _showStudentData,
                      onOpenAccountSheet: _payload == null
                          ? null
                          : _abrirHojaCuenta,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (!loggedIn)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                            child: _TarjetaIngreso(
                              loading: _loading,
                              error: _error,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              onLogin: _login,
                              onGuestLogin: _showGuestRegistration,
                            ),
                          ),
                        if (loggedIn && _payload != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: FutureBuilder<List<Materia>>(
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
                                      onTapAprobadas: () =>
                                          _abrirPantallaMateriasConFiltro(
                                            entries,
                                            (e) =>
                                                e.current != null &&
                                                _isSubjectApproved(e.current!),
                                            'aprobadas',
                                          ),
                                      onTapCursando: () =>
                                          _abrirPantallaMateriasConFiltro(
                                            entries,
                                            (e) =>
                                                e.current != null &&
                                                _isSubjectInProgress(
                                                  e.current!,
                                                ),
                                            'cursando',
                                          ),
                                      onTapHabilitadas: () =>
                                          _abrirPantallaMateriasConFiltro(
                                            entries,
                                            (e) =>
                                                e.current == null &&
                                                e.available,
                                            'habilitadas',
                                          ),
                                      onTapPlanTotal: _openCurriculum,
                                    ),
                                    const SizedBox(height: 12),
                                    _ExamShortcutBanner(onTap: _openExamenes),
                                    const SizedBox(height: 14),
                                    _GrillaAccionesEstudiante(
                                      onOpenSelfSubjects: _openSelfSubjects,
                                      onOpenPlan: _openPlanCompleto,
                                      onOpenEscenarios: _openEscenarios,
                                      onOpenAyuda: _openAyuda,
                                      onOpenNextSteps: _openNextSteps,
                                      onOpenProgress: _openProgress,
                                      onOpenAcademicCalendar:
                                          _openAcademicCalendar,
                                      onOpenReimaginedTrajectory:
                                          _openReimaginedTrajectory,
                                      onOpenCurriculum: _openCurriculum,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        if (loggedIn && _payload == null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: _TarjetaEstadoCarga(
                              error: _error,
                              loading: _loading,
                              onRetry: _loadTrajectory,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (loggedIn && _payload != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PromocionalTrayectoriasHeaderDelegate(
                      viewportHeight:
                          MediaQuery.sizeOf(context).height - fixedHeaderHeight,
                      onOpenExams: _openExamenes,
                      onOpenScenarios: _openEscenarios,
                      onOpenSelfSubjects: _openSelfSubjects,
                      onOpenAcademicCalendar: _openAcademicCalendar,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 144)),
              ],
            ),
          ),
          _EncabezadoEstudianteFijo(
            loggedIn: loggedIn,
            student: student,
            scrollController: _scrollController,
            movementCount:
                (_payload?.history.length ?? 0) - _seenNotificationsCount,
            onOpenHistory: _payload == null ? null : _openNotifications,
            onRefresh: loggedIn ? _loadTrajectory : null,
            onOpenAccountSheet: _payload == null ? null : _abrirHojaCuenta,
            onOpenSearch: widget.onOpenSearch,
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
