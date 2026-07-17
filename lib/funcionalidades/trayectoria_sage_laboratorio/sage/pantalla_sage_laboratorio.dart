import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../acceso_estudiante/pantallas/pantalla_visor_pdf_sage.dart';
import '../../acceso_estudiante/sage_agente/ejecutor_shell_agente_sage.dart';
import '../../acceso_estudiante/sage_agente/extractor_agente_sage.dart';
import '../../acceso_estudiante/sage_agente/modelos_agente_sage.dart';
import '../../acceso_estudiante/sage_agente/pantalla_legajo_alumno_agente_sage.dart';
import '../../acceso_estudiante/sage_agente/pantalla_legajo_personal_sage.dart';
import '../../acceso_estudiante/sage_agente/pantalla_portada_agente_sage.dart';
import '../../acceso_estudiante/sage_historial/controlador_historial_sage.dart';
import '../../acceso_estudiante/sage_historial/modelos_historial_sage.dart';
import '../../acceso_estudiante/sage_historial/pantalla_historial_sage.dart';
import '../../acceso_estudiante/sage_legajo/ejecutor_legajo_sage.dart';
import '../../acceso_estudiante/sage_legajo/extractor_legajo_sage.dart';
import '../../acceso_estudiante/sage_legajo/modelos_legajo_sage.dart';
import '../../acceso_estudiante/sage_legajo/pantalla_escolares_sage.dart';
import '../../acceso_estudiante/sage_legajo/pantalla_mi_legajo_sage.dart';
import '../../acceso_estudiante/sage_legajo/pantalla_secciones_legajo_sage.dart';
import '../../acceso_estudiante/sage_navegacion/barra_navegacion_sage.dart';
import '../../acceso_estudiante/sage_navegacion/detector_navegacion_sage.dart';
import '../../acceso_estudiante/sage_navegacion/modelos_navegacion_sage.dart';
import '../../acceso_estudiante/sage_navegacion/pantalla_carga_sage.dart';
import '../../acceso_estudiante/sage_navegacion/pantalla_modulos_sage.dart';
import '../../acceso_estudiante/sage_navegacion/pantalla_submodulos_sage.dart';
import '../../acceso_estudiante/sage_perfiles/ejecutor_perfiles_sage.dart';
import '../../acceso_estudiante/sage_perfiles/modelos_perfiles_sage.dart';
import '../../acceso_estudiante/sage_perfiles/pantalla_selector_perfil_sage.dart';
import '../componentes/tema_mensajes_laboratorio_sage.dart';
import '../datos/repositorio_estado_sincronizacion_sage.dart';
import '../dominio/constructor_trayectoria_sage_laboratorio.dart';
import '../modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'estilo_visual_sage.dart';
import 'modelos_sincronizacion_sage_automatica.dart';
import 'pantalla_sincronizacion_sage_automatica.dart';

class PantallaSageLaboratorio extends StatefulWidget {
  const PantallaSageLaboratorio({
    super.key,
    this.onClose,
    this.onTrayectoriaLista,
    this.onEstadoPreparacion,
    this.themeOverride,
    this.appBarBackground,
    this.appBarForeground,
    this.title = 'SAGE · Pruebas',
    this.logoutOnOpen = false,
    this.modo = ModoPantallaSageLaboratorio.manual,
    this.onGuardarTrayectoriaAutomatica,
    this.cerrarAlCompletar = true,
    this.perfilEsperado,
    this.onSesionCerrada,
    this.documentoSolicitado,
    this.onDocumentoDescargado,
  });

  final VoidCallback? onClose;
  final ValueChanged<TrayectoriaSageLaboratorio>? onTrayectoriaLista;
  final ValueChanged<EstadoPreparacionSageLaboratorio>? onEstadoPreparacion;
  final ThemeData? themeOverride;
  final Color? appBarBackground;
  final Color? appBarForeground;
  final String title;
  final bool logoutOnOpen;
  final ModoPantallaSageLaboratorio modo;
  final GuardarTrayectoriaSageAutomatica? onGuardarTrayectoriaAutomatica;
  final bool cerrarAlCompletar;
  final PerfilTrayectoriaSageLaboratorio? perfilEsperado;
  final VoidCallback? onSesionCerrada;
  final DocumentoAcademicoSage? documentoSolicitado;
  final ValueChanged<File>? onDocumentoDescargado;

  @override
  State<PantallaSageLaboratorio> createState() =>
      _PantallaSageLaboratorioState();
}

class _PantallaSageLaboratorioState extends State<PantallaSageLaboratorio> {
  static final Uri _initialUri = Uri.parse(
    'https://sage.entrerios.gov.ar/login/',
  );

  late final WebViewController _controller;
  final WebViewCookieManager _cookieManager = WebViewCookieManager();
  final http.Client _httpClient = http.Client();
  final ValueNotifier<int> _navigationProgress = ValueNotifier<int>(0);
  final ValueNotifier<String?> _mainFrameError = ValueNotifier<String?>(null);
  final ValueNotifier<_DownloadState> _downloadState =
      ValueNotifier<_DownloadState>(const _DownloadState.idle());
  final ControladorHistorialSage _historialController =
      ControladorHistorialSage();
  static const RepositorioEstadoSincronizacionSage _syncStateRepository =
      RepositorioEstadoSincronizacionSage();
  static const _navigationDetector = DetectorNavegacionSage();

  Uri? _activeDownloadUri;
  DateTime? _activeDownloadStartedAt;
  DateTime? _firstPageStartedAt;
  bool _isClosing = false;
  bool _navigationProbeRunning = false;
  bool _historyProbeRunning = false;
  bool _nativeHistoryVisible = false;
  bool _nativeModulesVisible = false;
  bool _nativeSubmodulesVisible = false;
  bool _nativeLegajoVisible = false;
  bool _nativeSeccionesLegajoVisible = false;
  bool _nativeEscolaresVisible = false;
  bool _nativeLoadingVisible = false;
  bool _privateSageShellActive = false;
  bool _showOriginalWebView = false;
  bool _nativeAgentHomeVisible = false;
  bool _nativeAgentPersonalVisible = false;
  bool _nativeAgentStudentMenuVisible = false;
  List<OpcionAgenteSage> _agentPersonalOptions = const [];
  List<OpcionAgenteSage> _agentStudentOptions = const [];
  bool _nativeProfileSelectorVisible = false;
  bool _profileChoiceMade = false;
  bool _profileSwitchBusy = false;
  bool _profileHomeResetBusy = false;
  bool _logoutBusy = false;
  bool _logoutOnOpenHandled = false;
  bool _studentAutoLandingActive = false;
  bool _authTransitionCoverVisible = true;
  bool _authCoverReleaseScheduled = false;
  bool _profileSelectorPreparing = false;
  bool _loginDocumentReady = false;
  String _authTransitionCoverMessage = 'Cargando SAGE…';
  int _logoutTransitionId = 0;
  int _profileTransitionId = 0;
  PerfilSage? _selectedProfile;
  bool _manualNavigationActive = false;
  String? _profileError;
  CapturaPerfilesSage? _profileCapture;
  PortadaAgenteSage _portadaAgente = const PortadaAgenteSage();
  String _nativeLoadingMessage = 'Preparando tus servicios académicos…';
  String? _navigationActionInFlight;
  ResultadoDeteccionNavegacionSage? _lastNavigationResult;
  String? _navigationOriginSignature;
  EstadoNavegacionSage? _navigationOriginState;
  String? _navigationOriginPath;
  DateTime? _navigationActionStartedAt;
  bool _navigationAwaitingTransition = false;
  EstadoHistorialSage _historyState = EstadoHistorialSage.esperandoPagina;
  HistorialNivelSuperiorSage? _history;
  bool _historyAutoLoadRunning = false;
  bool _historyNeedsFreshDom = false;
  bool _reportInFlight = false;
  Completer<Uri>? _pendingReportUrl;
  final Set<String> _historyAutoAttemptedCareerIds = <String>{};
  Timer? _historyPollTimer;
  Timer? _navigationDebounceTimer;
  Timer? _profileSwitchWatchdog;
  Timer? _studentAutoLandingWatchdog;
  Timer? _loginTransitionWatchdog;
  int _loginTransitionId = 0;
  DateTime? _loginTransitionStartedAt;
  PerfilSage? _profileSwitchTarget;
  ResultadoExtraccionLegajoSage? _legajoExtraction;
  String? _legajoActionInFlight;
  String? _legajoOriginSignature;
  TipoAccionLegajoSage _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
  bool _usuarioSolicitoEscolares = false;
  int _loadRequestCount = 0;
  PerfilLegajoSage? _selectedStudentRecord;
  String? _lastTrajectorySignature;
  EstadoSincronizacionSageAutomatica _automaticState =
      const EstadoSincronizacionSageAutomatica.preparando();
  bool _automaticCredentialsBusy = false;
  bool _automaticFlowActive = false;
  bool _automaticActionBusy = false;
  bool _automaticCompleting = false;
  int _automaticRunId = 0;
  int _automaticProfileMisses = 0;
  Timer? _automaticWatchdog;
  Timer? _automaticRetryTimer;
  final Map<PasoSincronizacionSageAutomatica, int> _automaticStepAttempts =
      <PasoSincronizacionSageAutomatica, int>{};
  EstadoPersistidoSincronizacionSage _persistedSyncState =
      const EstadoPersistidoSincronizacionSage();
  PasoSincronizacionSageAutomatica? _automaticLastFailedStep;
  Future<void> Function()? _automaticRetryAction;
  String? _automaticRetryMessage;
  CodigoErrorSincronizacionSage _automaticLastErrorCode =
      CodigoErrorSincronizacionSage.desconocido;
  bool _automaticSessionReused = false;
  bool _automaticCredentialsSubmittedThisRun = false;
  bool _automaticDocumentsPreparing = false;
  bool _automaticDocumentRequestRunning = false;
  bool _automaticDocumentRequestCompleted = false;

  bool get _automaticMode => widget.modo != ModoPantallaSageLaboratorio.manual;
  bool get _documentDownloadMode =>
      widget.modo == ModoPantallaSageLaboratorio.descargaDocumento;

  @override
  void initState() {
    super.initState();
    if (_automaticMode) {
      unawaited(_loadAutomaticSyncMetadata());
      if (!_documentDownloadMode) {
        unawaited(_syncStateRepository.registrarIntento());
      }
    }
    if (kDebugMode && Platform.isAndroid) {
      unawaited(AndroidWebViewController.enableDebugging(true));
    }
    final navigationDelegate = NavigationDelegate(
      onProgress: (progress) {
        _navigationProgress.value = progress.clamp(0, 100);
      },
      onPageStarted: (url) {
        _firstPageStartedAt ??= DateTime.now();
        _navigationProgress.value = 0;
        _mainFrameError.value = null;
        _loginDocumentReady = false;
        final uri = Uri.tryParse(url);
        final isPrivatePregase =
            uri != null &&
            uri.host.toLowerCase() == 'sage.entrerios.gov.ar' &&
            uri.path.toLowerCase().startsWith('/pregase/') &&
            !uri.path.toLowerCase().startsWith('/login/');
        final isSageLogin = _isLoginUri(uri);
        if (mounted && isPrivatePregase) {
          setState(() {
            _authTransitionCoverVisible =
                !_automaticMode || !_automaticFlowActive;
            _authTransitionCoverMessage =
                'Preparando tus servicios académicos…';
            _privateSageShellActive = true;
            _showOriginalWebView = false;
            final keepProfileSelectorVisible =
                _nativeProfileSelectorVisible &&
                !_profileSwitchBusy &&
                !_logoutBusy;
            if (!keepProfileSelectorVisible) {
              _nativeLoadingVisible = true;
              final target = _profileSwitchTarget;
              _nativeLoadingMessage = _logoutBusy
                  ? 'Cerrando sesión…'
                  : _profileHomeResetBusy
                  ? 'Volviendo al inicio de SAGE…'
                  : _profileSwitchBusy && target != null
                  ? 'Cambiando a ${target.etiqueta}…'
                  : 'Preparando tus servicios académicos…';
            }
          });
        } else if (mounted && isSageLogin) {
          _stopProfileSwitchWatchdog();
          setState(() {
            _authTransitionCoverVisible = true;
            _authTransitionCoverMessage = _logoutBusy
                ? 'Cerrando sesión…'
                : 'Cargando inicio de sesión…';
            if (_logoutBusy) {
              _privateSageShellActive = true;
              _showOriginalWebView = false;
              _nativeLoadingVisible = true;
              _nativeLoadingMessage = 'Cerrando sesión…';
            }
          });
        }
      },
      onPageFinished: (url) {
        _navigationProgress.value = 100;
        _mainFrameError.value = null;
        _logFirstPageTiming();
        final uri = Uri.tryParse(url);
        final isSageLogin = _isLoginUri(uri);
        final isPrivatePregase =
            uri != null &&
            uri.host.toLowerCase() == 'sage.entrerios.gov.ar' &&
            uri.path.toLowerCase().startsWith('/pregase/') &&
            !uri.path.toLowerCase().startsWith('/login/');
        _loginDocumentReady = isSageLogin;

        if (mounted &&
            isPrivatePregase &&
            _authTransitionCoverVisible &&
            !_logoutBusy) {
          _completeLoginTransitionToPrivate();
        } else if (_automaticMode &&
            !isSageLogin &&
            _automaticCredentialsSubmittedThisRun &&
            !_logoutBusy) {
          unawaited(() async {
            final state = await _readLoginTransitionState();
            if (!mounted || _logoutBusy) return;
            if (state['authenticated'] == true ||
                state['privateShell'] == true) {
              _completeLoginTransitionToPrivate();
            }
          }());
        }
        unawaited(_installNavigationObservers());
        unawaited(_installLoginTransitionObserver());
        _ensureProbeTimer();

        if (mounted && isSageLogin && !_logoutBusy) {
          setState(_resetPrivateSageStateForLogin);
        } else {
          _requestSageProbe();
          _scheduleLogoutOnOpen(uri);
        }

        if (_profileChoiceMade &&
            !_profileSwitchBusy &&
            !_profileHomeResetBusy &&
            !_logoutBusy) {
          _scheduleProfileLandingProbes(_profileTransitionId);
        }
      },
      onWebResourceError: (error) {
        if (error.isForMainFrame != true) return;
        if (_activeDownloadUri != null) {
          _navigationProgress.value = 100;
          return;
        }
        _navigationProgress.value = 100;
        final message = _errorMessage(error);
        if (_automaticMode) {
          _scheduleAutomaticStepRetry(
            step: PasoSincronizacionSageAutomatica.sesion,
            message: message,
            code: CodigoErrorSincronizacionSage.red,
            action: _retry,
          );
        } else {
          _mainFrameError.value = message;
        }
      },
      onUrlChange: (change) {
        final uri = Uri.tryParse(change.url ?? '');
        if (uri == null) return;
        if (uri.scheme == 'blob' || _isPdfDownloadUri(uri)) {
          _logPdfDiagnostic(uri, source: 'url-change');
        }
      },
      onNavigationRequest: _handleNavigationRequest,
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SageReportBridge',
        onMessageReceived: _onSageReportMessage,
      )
      ..addJavaScriptChannel(
        'SageDiagnosticBridge',
        onMessageReceived: _onSageDiagnosticMessage,
      )
      ..addJavaScriptChannel(
        'SageNavigationBridge',
        onMessageReceived: (_) {
          unawaited(_installNavigationObservers());
          _scheduleNavigationProbe();
        },
      )
      ..addJavaScriptChannel(
        'SageVisualBridge',
        onMessageReceived: _onSageVisualMessage,
      );
    if (kDebugMode &&
        Platform.isAndroid &&
        navigationDelegate.platform is AndroidNavigationDelegate) {
      // setPlatformNavigationDelegate installs the package's public
      // AndroidNavigationDelegate.androidDownloadListener on Android.
      debugPrint('[SAGE] Android DownloadListener conectado');
    }
    unawaited(
      _controller.setNavigationDelegate(navigationDelegate).then((_) async {
        await _installReportDiagnostics();
        await _loadInitialPage();
      }),
    );
    _ensureProbeTimer();
  }

  void _ensureProbeTimer() {
    if (_historyPollTimer?.isActive == true) return;
    _historyPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _requestSageProbe(),
    );
  }

  void _startProfileSwitchWatchdog(PerfilSage profile, int transitionId) {
    _profileSwitchWatchdog?.cancel();
    _profileSwitchWatchdog = Timer(const Duration(seconds: 22), () {
      if (!mounted ||
          _isClosing ||
          transitionId != _profileTransitionId ||
          !_profileSwitchBusy) {
        return;
      }
      _failProfileSelection(
        'SAGE no terminó de cambiar a ${profile.etiqueta}. Intentá nuevamente.',
        transitionId,
      );
    });
  }

  void _stopProfileSwitchWatchdog() {
    _profileSwitchWatchdog?.cancel();
    _profileSwitchWatchdog = null;
  }

  void _scheduleProfileLandingProbes(int transitionId) {
    const delays = <Duration>[
      Duration(milliseconds: 250),
      Duration(milliseconds: 800),
      Duration(milliseconds: 1600),
      Duration(milliseconds: 3000),
    ];
    for (final delay in delays) {
      unawaited(
        Future<void>.delayed(delay, () {
          if (!mounted ||
              _isClosing ||
              transitionId != _profileTransitionId ||
              _profileSwitchBusy) {
            return;
          }
          _requestSageProbe();
        }),
      );
    }
  }

  void _requestSageProbe() {
    unawaited(_probeNavigationAndApply());
    unawaited(_probeHistoryAndApply());
  }

  void _scheduleNavigationProbe() {
    _navigationDebounceTimer?.cancel();
    _navigationDebounceTimer = Timer(
      const Duration(milliseconds: 180),
      () => unawaited(_probeNavigationAndApply()),
    );
  }

  Future<String> _evaluateJavascript(String source) {
    return _controller
        .runJavaScriptReturningResult(source)
        .then((value) => value is String ? value : jsonEncode(value));
  }

  Future<void> _loadAutomaticSyncMetadata() async {
    final state = await _syncStateRepository.cargar();
    if (!mounted) return;
    _persistedSyncState = state;
  }

  PasoSincronizacionSageAutomatica _stepForStage(
    EtapaSincronizacionSageAutomatica stage,
  ) {
    return switch (stage) {
      EtapaSincronizacionSageAutomatica.preparando ||
      EtapaSincronizacionSageAutomatica.verificandoSesion ||
      EtapaSincronizacionSageAutomatica.credenciales ||
      EtapaSincronizacionSageAutomatica.autenticando ||
      EtapaSincronizacionSageAutomatica.reanudandoSesion =>
        PasoSincronizacionSageAutomatica.sesion,
      EtapaSincronizacionSageAutomatica.detectandoPerfil ||
      EtapaSincronizacionSageAutomatica.cambiandoAEstudiante =>
        PasoSincronizacionSageAutomatica.perfil,
      EtapaSincronizacionSageAutomatica.abriendoLegajo ||
      EtapaSincronizacionSageAutomatica.seleccionandoLegajo =>
        PasoSincronizacionSageAutomatica.legajo,
      EtapaSincronizacionSageAutomatica.abriendoEscolares =>
        PasoSincronizacionSageAutomatica.escolares,
      EtapaSincronizacionSageAutomatica.abriendoHistorial =>
        PasoSincronizacionSageAutomatica.historial,
      EtapaSincronizacionSageAutomatica.leyendoTrayectoria =>
        PasoSincronizacionSageAutomatica.carreras,
      EtapaSincronizacionSageAutomatica.preparandoDocumentos ||
      EtapaSincronizacionSageAutomatica.descargandoDocumento =>
        PasoSincronizacionSageAutomatica.documentos,
      EtapaSincronizacionSageAutomatica.guardando ||
      EtapaSincronizacionSageAutomatica.completada =>
        PasoSincronizacionSageAutomatica.guardado,
      EtapaSincronizacionSageAutomatica.reintentandoPaso ||
      EtapaSincronizacionSageAutomatica.error =>
        _automaticLastFailedStep ?? PasoSincronizacionSageAutomatica.sesion,
    };
  }

  void _clearAutomaticInFlightState() {
    _automaticActionBusy = false;
    _navigationAwaitingTransition = false;
    _navigationActionInFlight = null;
    _legajoActionInFlight = null;
    _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
    _navigationOriginSignature = null;
    _navigationOriginState = null;
    _navigationOriginPath = null;
    _navigationActionStartedAt = null;
    _legajoOriginSignature = null;
    if (mounted) {
      setState(() => _nativeLoadingVisible = false);
    } else {
      _nativeLoadingVisible = false;
    }
  }

  Future<void> _recoverAutomaticStep(
    PasoSincronizacionSageAutomatica step,
  ) async {
    if (!_automaticMode || !mounted || _isClosing) return;
    _clearAutomaticInFlightState();
    switch (step) {
      case PasoSincronizacionSageAutomatica.sesion:
        await _retry();
        return;
      case PasoSincronizacionSageAutomatica.perfil:
        _profileChoiceMade = false;
        _profileSwitchBusy = false;
        _profileHomeResetBusy = false;
        _profileSwitchTarget = null;
        _requestSageProbe();
        _scheduleNavigationProbe();
        return;
      case PasoSincronizacionSageAutomatica.legajo:
      case PasoSincronizacionSageAutomatica.escolares:
      case PasoSincronizacionSageAutomatica.historial:
        _requestSageProbe();
        _scheduleNavigationProbe();
        return;
      case PasoSincronizacionSageAutomatica.carreras:
        _historyAutoAttemptedCareerIds.clear();
        _historyAutoLoadRunning = false;
        final history = _history;
        if (history != null && history.carreras.isNotEmpty) {
          await _autoLoadAllCareers(history.carreras);
        } else {
          await _refreshHistory();
        }
        return;
      case PasoSincronizacionSageAutomatica.documentos:
        if (_documentDownloadMode) {
          _automaticDocumentRequestRunning = false;
          await _tryDownloadRequestedDocument();
        } else {
          _automaticDocumentsPreparing = false;
          final history = _history;
          if (history != null && history.carreras.isNotEmpty) {
            final trajectory = ConstructorTrayectoriaSageLaboratorio.construir(
              historial: history,
              perfil: _selectedStudentRecord,
            );
            await _prepareDocumentsAndCompleteAutomaticSync(trajectory);
          }
        }
        return;
      case PasoSincronizacionSageAutomatica.guardado:
        final trajectory = _history == null
            ? null
            : ConstructorTrayectoriaSageLaboratorio.construir(
                historial: _history!,
                perfil: _selectedStudentRecord,
              );
        if (trajectory != null && trajectory.listaParaSincronizar) {
          await _prepareDocumentsAndCompleteAutomaticSync(trajectory);
        }
        return;
    }
  }

  void _scheduleAutomaticStepRetry({
    required PasoSincronizacionSageAutomatica step,
    required String message,
    required CodigoErrorSincronizacionSage code,
    Future<void> Function()? action,
    int maxAttempts = 3,
  }) {
    if (!_automaticMode || _automaticCompleting || _isClosing) return;
    if (_automaticRetryTimer?.isActive == true) return;

    final nextAttempt = (_automaticStepAttempts[step] ?? 0) + 1;
    _automaticLastFailedStep = step;
    _automaticRetryAction = action;
    _automaticRetryMessage = message;
    _automaticLastErrorCode = code;

    if (nextAttempt > maxAttempts) {
      _failAutomaticSync(
        message,
        code: code,
        step: step,
        permiteReintentar: true,
      );
      return;
    }

    _automaticStepAttempts[step] = nextAttempt;
    _automaticFlowActive = true;
    _setAutomaticState(
      EtapaSincronizacionSageAutomatica.reintentandoPaso,
      'Reintentando',
      detalle: message,
      progreso: _automaticState.progreso,
      paso: step,
      codigoError: code,
      intentoActual: nextAttempt,
      intentosMaximos: maxAttempts,
      permiteReintentar: false,
    );

    final delay = switch (nextAttempt) {
      1 => const Duration(milliseconds: 450),
      2 => const Duration(milliseconds: 950),
      _ => const Duration(milliseconds: 1800),
    };
    final runId = _automaticRunId;
    _automaticRetryTimer = Timer(delay, () {
      unawaited(() async {
        if (!mounted ||
            runId != _automaticRunId ||
            _automaticCompleting ||
            _isClosing) {
          return;
        }
        _clearAutomaticInFlightState();
        try {
          final retryAction = action ?? () => _recoverAutomaticStep(step);
          await retryAction();
          if (!mounted || _automaticCompleting) return;
          _requestSageProbe();
          _scheduleNavigationProbe();
        } catch (_) {
          _scheduleAutomaticStepRetry(
            step: step,
            message: message,
            code: code,
            action: action,
            maxAttempts: maxAttempts,
          );
        }
      }());
    });
  }

  void _retryLastAutomaticStep() {
    final step = _automaticLastFailedStep;
    if (step == null) {
      _automaticFlowActive = false;
      unawaited(_retry().then((_) => _beginAutomaticFlow()));
      return;
    }
    _automaticStepAttempts[step] = 0;
    _automaticFlowActive = true;
    _scheduleAutomaticStepRetry(
      step: step,
      message: _automaticRetryMessage ?? 'Reintentando el último paso…',
      code: _automaticLastErrorCode,
      action: _automaticRetryAction,
    );
  }

  void _setAutomaticState(
    EtapaSincronizacionSageAutomatica etapa,
    String titulo, {
    String? detalle,
    double? progreso,
    bool permiteReintentar = false,
    bool notifyPreparation = true,
    PasoSincronizacionSageAutomatica? paso,
    CodigoErrorSincronizacionSage? codigoError,
    int intentoActual = 0,
    int intentosMaximos = 0,
    bool? sesionReutilizada,
  }) {
    if (!_automaticMode) return;
    final state = EstadoSincronizacionSageAutomatica(
      etapa: etapa,
      titulo: titulo,
      detalle: detalle,
      progreso: progreso,
      permiteReintentar: permiteReintentar,
      paso: paso ?? _stepForStage(etapa),
      codigoError: codigoError,
      intentoActual: intentoActual,
      intentosMaximos: intentosMaximos,
      sesionReutilizada: sesionReutilizada ?? _automaticSessionReused,
    );
    final changed =
        _automaticState.etapa != state.etapa ||
        _automaticState.titulo != state.titulo ||
        _automaticState.detalle != state.detalle ||
        _automaticState.progreso != state.progreso ||
        _automaticState.permiteReintentar != state.permiteReintentar ||
        _automaticState.paso != state.paso ||
        _automaticState.codigoError != state.codigoError ||
        _automaticState.intentoActual != state.intentoActual ||
        _automaticState.intentosMaximos != state.intentosMaximos ||
        _automaticState.sesionReutilizada != state.sesionReutilizada;
    if (changed) {
      if (mounted) {
        setState(() => _automaticState = state);
      } else {
        _automaticState = state;
      }
      if (notifyPreparation) {
        widget.onEstadoPreparacion?.call(
          EstadoPreparacionSageLaboratorio(
            mensaje: detalle?.trim().isNotEmpty == true ? detalle! : titulo,
            progreso: progreso,
            bloqueado: etapa == EtapaSincronizacionSageAutomatica.error,
          ),
        );
      }
      _restartAutomaticWatchdog();
    }
  }

  void _reportPreparation(EstadoPreparacionSageLaboratorio status) {
    widget.onEstadoPreparacion?.call(status);
    if (!_automaticMode || !_automaticFlowActive || _automaticCompleting) {
      return;
    }
    if (status.bloqueado) {
      _scheduleAutomaticStepRetry(
        step: PasoSincronizacionSageAutomatica.carreras,
        message: status.mensaje,
        code: CodigoErrorSincronizacionSage.lecturaCarrera,
        action: () =>
            _recoverAutomaticStep(PasoSincronizacionSageAutomatica.carreras),
      );
      return;
    }
    final progress = status.progreso == null
        ? _automaticState.progreso
        : 0.78 + status.progreso!.clamp(0, 1).toDouble() * 0.17;
    final state = EstadoSincronizacionSageAutomatica(
      etapa: EtapaSincronizacionSageAutomatica.leyendoTrayectoria,
      titulo: 'Leyendo trayectoria',
      detalle: status.mensaje,
      progreso: progress,
      permiteReintentar: false,
      paso: PasoSincronizacionSageAutomatica.carreras,
      sesionReutilizada: _automaticSessionReused,
    );
    final changed =
        _automaticState.etapa != state.etapa ||
        _automaticState.detalle != state.detalle ||
        _automaticState.progreso != state.progreso;
    if (changed) {
      if (mounted) {
        setState(() => _automaticState = state);
      } else {
        _automaticState = state;
      }
      _restartAutomaticWatchdog();
    }
  }

  void _restartAutomaticWatchdog() {
    _automaticWatchdog?.cancel();
    if (!_automaticMode ||
        !_automaticFlowActive ||
        _automaticCompleting ||
        _automaticState.solicitaCredenciales ||
        _automaticState.esError ||
        _automaticState.completada) {
      return;
    }
    final runId = _automaticRunId;
    _automaticWatchdog = Timer(const Duration(seconds: 120), () {
      if (!mounted ||
          runId != _automaticRunId ||
          !_automaticFlowActive ||
          _automaticCompleting) {
        return;
      }
      final step = _automaticState.paso ?? _stepForStage(_automaticState.etapa);
      _scheduleAutomaticStepRetry(
        step: step,
        message: 'SAGE tardó demasiado en completar este paso.',
        code: CodigoErrorSincronizacionSage.tiempoAgotado,
        action: () => _recoverAutomaticStep(step),
      );
    });
  }

  void _beginAutomaticFlow() {
    if (!_automaticMode || _automaticCompleting) return;
    _automaticRunId++;
    _automaticRetryTimer?.cancel();
    _automaticFlowActive = true;
    _automaticActionBusy = false;
    _automaticCredentialsBusy = false;
    _automaticProfileMisses = 0;
    _automaticStepAttempts.clear();
    _automaticDocumentsPreparing = false;
    _automaticDocumentRequestRunning = false;
    _automaticDocumentRequestCompleted = false;
    _automaticLastFailedStep = null;
    _automaticRetryAction = null;
    _automaticRetryMessage = null;
    _lastTrajectorySignature = null;
    _manualNavigationActive = false;
    _automaticSessionReused = !_automaticCredentialsSubmittedThisRun;
    unawaited(_syncStateRepository.registrarSesionActiva());
    _setAutomaticState(
      _automaticSessionReused
          ? EtapaSincronizacionSageAutomatica.reanudandoSesion
          : EtapaSincronizacionSageAutomatica.detectandoPerfil,
      _automaticSessionReused
          ? 'Sesión activa'
          : _documentDownloadMode
          ? 'Preparando documento'
          : 'Detectando perfil',
      detalle: _automaticSessionReused
          ? (_documentDownloadMode
                ? 'SAGE sigue conectado. Buscando el documento…'
                : 'SAGE sigue conectado. Continuando la sincronización…')
          : 'Buscando el perfil Estudiante…',
      progreso: _automaticSessionReused ? 0.18 : 0.22,
      paso: PasoSincronizacionSageAutomatica.sesion,
      sesionReutilizada: _automaticSessionReused,
    );
    _ensureProbeTimer();
    _requestSageProbe();
    _scheduleNavigationProbe();
  }

  void _failAutomaticSync(
    String message, {
    bool loginAvailable = false,
    CodigoErrorSincronizacionSage code =
        CodigoErrorSincronizacionSage.desconocido,
    PasoSincronizacionSageAutomatica? step,
    bool permiteReintentar = true,
  }) {
    if (!_automaticMode) return;
    _automaticRunId++;
    _automaticWatchdog?.cancel();
    _automaticRetryTimer?.cancel();
    _automaticFlowActive = false;
    _automaticActionBusy = false;
    _automaticCredentialsBusy = false;
    _automaticProfileMisses = 0;
    _automaticCompleting = false;
    _automaticDocumentsPreparing = false;
    _automaticDocumentRequestRunning = false;
    _navigationAwaitingTransition = false;
    _navigationActionInFlight = null;
    _legajoActionInFlight = null;
    _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
    final failedStep =
        step ?? _automaticState.paso ?? _stepForStage(_automaticState.etapa);
    _automaticLastFailedStep = failedStep;
    _automaticLastErrorCode = code;
    final state = EstadoSincronizacionSageAutomatica(
      etapa: loginAvailable
          ? EtapaSincronizacionSageAutomatica.credenciales
          : EtapaSincronizacionSageAutomatica.error,
      titulo: loginAvailable ? 'Conectar con SAGE' : 'No se pudo sincronizar',
      detalle: message,
      progreso: null,
      permiteReintentar: !loginAvailable && permiteReintentar,
      paso: failedStep,
      codigoError: code,
      sesionReutilizada: _automaticSessionReused,
    );
    if (mounted) {
      setState(() => _automaticState = state);
    } else {
      _automaticState = state;
    }
    if (!_documentDownloadMode) {
      unawaited(
        _syncStateRepository.registrarError(
          codigo: code.clave,
          mensaje: message,
          sesionVencida: code == CodigoErrorSincronizacionSage.sesionVencida,
        ),
      );
    }
    widget.onEstadoPreparacion?.call(
      EstadoPreparacionSageLaboratorio(mensaje: message, bloqueado: true),
    );
  }

  void _retryAutomaticSync() {
    if (!_automaticMode || _automaticCredentialsBusy) return;
    if (_loginDocumentReady) {
      setState(() {
        _automaticState = EstadoSincronizacionSageAutomatica(
          etapa: EtapaSincronizacionSageAutomatica.credenciales,
          titulo: 'Conectar con SAGE',
          paso: PasoSincronizacionSageAutomatica.sesion,
          codigoError: _automaticState.codigoError,
        );
      });
      return;
    }
    _retryLastAutomaticStep();
  }

  Future<bool> _ensureAutomaticLoginDocumentReady() async {
    if (_loginDocumentReady) return true;
    final current = Uri.tryParse(await _controller.currentUrl() ?? '');
    if (!_isLoginUri(current)) {
      await _controller.loadRequest(_initialUri);
    }
    for (var attempt = 0; attempt < 40; attempt++) {
      if (!mounted || _isClosing) return false;
      final state = await _readLoginTransitionState();
      if (state['authenticated'] == true) {
        _completeLoginTransitionToPrivate();
        return false;
      }
      if (state['loginFormVisible'] == true || state['loginForm'] == true) {
        if (mounted) setState(() => _loginDocumentReady = true);
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }

  Future<void> _submitAutomaticCredentials(
    String usuario,
    String password,
  ) async {
    if (!_automaticMode || _automaticCredentialsBusy) return;
    if (!await _ensureAutomaticLoginDocumentReady()) {
      if (mounted && !_privateSageShellActive) {
        _failAutomaticSync(
          'SAGE todavía no mostró el formulario de acceso.',
          loginAvailable: true,
          code: CodigoErrorSincronizacionSage.estructuraIncompatible,
          step: PasoSincronizacionSageAutomatica.sesion,
        );
      }
      return;
    }
    final userJson = jsonEncode(usuario.trim());
    final passwordJson = jsonEncode(password);
    _automaticCredentialsSubmittedThisRun = true;
    _automaticSessionReused = false;
    setState(() => _automaticCredentialsBusy = true);
    _setAutomaticState(
      EtapaSincronizacionSageAutomatica.autenticando,
      'Iniciando sesión',
      detalle: 'Validando tus credenciales…',
      progreso: 0.12,
    );

    try {
      final raw = await _evaluateJavascript('''(() => {
        const userValue = $userJson;
        const passwordValue = $passwordJson;
        const normalize = value => String(value || '')
          .toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g, '')
          .replace(/\\s+/g, ' ').trim();
        const visible = node => {
          if (!node || !node.isConnected) return false;
          const style = node.ownerDocument?.defaultView?.getComputedStyle(node);
          if (style && (style.display === 'none' || style.visibility === 'hidden')) return false;
          const rect = node.getBoundingClientRect?.();
          return !rect || (rect.width > 0 && rect.height > 0);
        };
        const contexts = [];
        const seen = new Set();
        const visit = win => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          contexts.push({win, doc});
          doc.querySelectorAll('iframe').forEach(frame => {
            try { visit(frame.contentWindow); } catch (_) {}
          });
        };
        visit(window);
        let passwordInput = null;
        let form = null;
        let context = null;
        for (const item of contexts) {
          const candidates = [...item.doc.querySelectorAll('input[type="password"]')];
          passwordInput = candidates.find(visible) || candidates[0] || null;
          if (passwordInput) {
            form = passwordInput.form || passwordInput.closest?.('form');
            context = item;
            break;
          }
        }
        if (!passwordInput || !context) {
          return JSON.stringify({found:false,submitted:false,stage:'password_missing'});
        }
        const scope = form || context.doc;
        const inputs = [...scope.querySelectorAll('input')].filter(input => {
          const type = String(input.type || 'text').toLowerCase();
          return input !== passwordInput &&
            !['password','hidden','submit','button','checkbox','radio','file'].includes(type) &&
            input.disabled !== true;
        });
        const score = input => {
          const signature = normalize([
            input.name, input.id, input.placeholder,
            input.getAttribute('aria-label'), input.autocomplete,
          ].join(' '));
          let value = visible(input) ? 20 : 0;
          if (/(usuario|user|login|dni|documento|correo|email)/.test(signature)) value += 100;
          if (String(input.type || '').toLowerCase() === 'email') value += 25;
          return value;
        };
        inputs.sort((a, b) => score(b) - score(a));
        const userInput = inputs[0] || null;
        if (!userInput) {
          return JSON.stringify({found:false,submitted:false,stage:'user_missing'});
        }
        const assign = (input, value) => {
          const descriptor = Object.getOwnPropertyDescriptor(
            input.ownerDocument.defaultView.HTMLInputElement.prototype,
            'value',
          );
          if (descriptor?.set) descriptor.set.call(input, value);
          else input.value = value;
          input.dispatchEvent(new Event('input', {bubbles:true}));
          input.dispatchEvent(new Event('change', {bubbles:true}));
        };
        assign(userInput, userValue);
        assign(passwordInput, passwordValue);
        let submitted = false;
        let mechanism = '';
        const submitControl = form?.querySelector(
          'button[type="submit"],input[type="submit"],button:not([type])'
        );
        if (submitControl && typeof submitControl.click === 'function') {
          submitControl.click();
          submitted = true;
          mechanism = 'submit_click';
        } else if (form && typeof form.requestSubmit === 'function') {
          form.requestSubmit();
          submitted = true;
          mechanism = 'request_submit';
        } else if (form && typeof form.submit === 'function') {
          form.submit();
          submitted = true;
          mechanism = 'form_submit';
        }
        return JSON.stringify({
          found:true,
          submitted,
          mechanism,
          userName:String(userInput.name || userInput.id || ''),
          passwordName:String(passwordInput.name || passwordInput.id || ''),
        });
      })()''');
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      final result = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : const <String, dynamic>{};
      if (result['found'] != true || result['submitted'] != true) {
        _failAutomaticSync(
          'No se encontraron los controles de acceso de SAGE.',
          loginAvailable: true,
          code: CodigoErrorSincronizacionSage.estructuraIncompatible,
          step: PasoSincronizacionSageAutomatica.sesion,
        );
        return;
      }
      setState(() {
        _authTransitionCoverVisible = true;
        _authTransitionCoverMessage = 'Iniciando sesión…';
        _loginDocumentReady = false;
      });
      _startLoginTransitionWatchdog();
    } catch (_) {
      _failAutomaticSync(
        'No se pudo enviar el inicio de sesión a SAGE.',
        loginAvailable: true,
        code: CodigoErrorSincronizacionSage.red,
        step: PasoSincronizacionSageAutomatica.sesion,
      );
    } finally {
      if (mounted) setState(() => _automaticCredentialsBusy = false);
    }
  }

  PerfilLegajoSage? _preferredAutomaticStudentRecord(
    List<PerfilLegajoSage> records,
  ) {
    if (records.isEmpty) return null;
    if (records.length == 1) return records.first;

    final expected = widget.perfilEsperado;
    final expectedName = _normalizeAutomaticIdentity(
      expected?.nombre ?? _persistedSyncState.nombrePerfil ?? '',
    );
    final expectedDni = _digitsOnly(
      expected?.dni ?? _persistedSyncState.dniPerfil ?? '',
    );
    final preferredSignature = _persistedSyncState.firmaLegajo?.trim() ?? '';

    PerfilLegajoSage? best;
    var bestScore = -1;
    for (final record in records) {
      var score = 0;
      if (preferredSignature.isNotEmpty &&
          record.firmaTecnica == preferredSignature) {
        score += 1200;
      }
      final searchable = _normalizeAutomaticIdentity(
        <String>[
          record.nombreVisible,
          ...record.camposVisibles.keys,
          ...record.camposVisibles.values,
        ].join(' '),
      );
      final digits = _digitsOnly(
        <String>[
          record.nombreVisible,
          ...record.camposVisibles.values,
        ].join(' '),
      );
      if (expectedDni.isNotEmpty && digits.contains(expectedDni)) {
        score += 900;
      }
      if (expectedName.isNotEmpty) {
        if (searchable == expectedName) {
          score += 700;
        } else {
          final tokens = expectedName
              .split(' ')
              .where((token) => token.length >= 3)
              .toList(growable: false);
          score += tokens.where(searchable.contains).length * 90;
        }
      }
      if (record.nombreVisible.trim().isNotEmpty) score += 20;
      if (score > bestScore) {
        bestScore = score;
        best = record;
      }
    }
    return best ?? records.first;
  }

  String _normalizeAutomaticIdentity(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]+'), '');

  SeccionLegajoSage? _automaticSchoolSection(
    ResultadoExtraccionLegajoSage extraction,
  ) {
    for (final section in extraction.secciones) {
      if (section.clave == 'escolares' ||
          normalizarLegajoSage(section.titulo) == 'escolares') {
        return section;
      }
    }
    if (extraction.etapa == EtapaLegajoSage.secciones ||
        extraction.etapa == EtapaLegajoSage.escolares) {
      return SeccionLegajoSage(
        clave: 'escolares',
        titulo: 'Escolares',
        firmaTecnica: 'automatic:escolares',
        frameId: extraction.frameId,
        pathname: extraction.pathname,
        controlEncontrado: extraction.historyControlFound,
      );
    }
    return null;
  }

  OpcionEscolarSage? _automaticHistoryOption(
    ResultadoExtraccionLegajoSage extraction,
  ) {
    for (final option in extraction.opcionesEscolares) {
      final normalized = normalizarLegajoSage(option.titulo);
      if (option.clave == 'nivel_superior_historial' ||
          option.clave == 'historial_del_alumnado' ||
          normalized == 'nivel superior - historial' ||
          (normalized.contains('nivel superior') &&
              normalized.contains('historial'))) {
        return option;
      }
    }
    return null;
  }

  Future<bool> _advanceAutomaticSync(
    ResultadoDeteccionNavegacionSage navigation,
    ResultadoExtraccionLegajoSage? extraction,
    CapturaPerfilesSage profiles,
  ) async {
    if (!_automaticMode || !_automaticFlowActive || _automaticCompleting) {
      return false;
    }

    if (navigation.estado == EstadoNavegacionSage.login ||
        navigation.estado == EstadoNavegacionSage.sesionVencida) {
      final expired = navigation.estado == EstadoNavegacionSage.sesionVencida;
      _automaticSessionReused = false;
      _failAutomaticSync(
        expired
            ? 'La sesión de SAGE venció. Iniciá sesión nuevamente.'
            : 'Ingresá tus credenciales para continuar.',
        loginAvailable: true,
        code: expired
            ? CodigoErrorSincronizacionSage.sesionVencida
            : CodigoErrorSincronizacionSage.credenciales,
        step: PasoSincronizacionSageAutomatica.sesion,
      );
      return true;
    }

    if (_automaticActionBusy ||
        _profileSwitchBusy ||
        _profileHomeResetBusy ||
        _logoutBusy ||
        _navigationAwaitingTransition ||
        _navigationActionInFlight != null ||
        _legajoActionInFlight != null ||
        _historyAutoLoadRunning) {
      return true;
    }

    if (!_profileChoiceMade || _effectiveProfile != PerfilSage.alumnos) {
      final studentContext =
          extraction?.disponible == true ||
          navigation.estado == EstadoNavegacionSage.submodulosLegajoUnico ||
          navigation.estado == EstadoNavegacionSage.listadoLegajos ||
          navigation.estado == EstadoNavegacionSage.seccionesLegajo ||
          navigation.estado == EstadoNavegacionSage.escolares;
      if (profiles.perfiles.isEmpty && studentContext) {
        _selectedProfile = PerfilSage.alumnos;
        _profileChoiceMade = true;
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoLegajo,
          'Perfil Estudiante detectado',
          detalle: 'Preparando el acceso al historial…',
          progreso: 0.30,
        );
        _scheduleNavigationProbe();
        return true;
      }
      _setAutomaticState(
        EtapaSincronizacionSageAutomatica.detectandoPerfil,
        'Detectando perfil',
        detalle: 'Buscando el perfil Estudiante…',
        progreso: 0.22,
      );
      if (profiles.contiene(PerfilSage.alumnos)) {
        _automaticProfileMisses = 0;
        _automaticActionBusy = true;
        _setAutomaticState(
          profiles.activo == PerfilSage.alumnos
              ? EtapaSincronizacionSageAutomatica.abriendoLegajo
              : EtapaSincronizacionSageAutomatica.cambiandoAEstudiante,
          profiles.activo == PerfilSage.alumnos
              ? 'Perfil Estudiante detectado'
              : 'Activando perfil Estudiante',
          detalle: profiles.activo == PerfilSage.alumnos
              ? 'Preparando el acceso al historial…'
              : 'Cambiando el perfil activo de SAGE…',
          progreso: profiles.activo == PerfilSage.alumnos ? 0.30 : 0.27,
        );
        try {
          await _selectProfile(PerfilSage.alumnos);
        } finally {
          _automaticActionBusy = false;
        }
        return true;
      }
      if (profiles.perfiles.isNotEmpty) {
        _automaticProfileMisses++;
        if (_automaticProfileMisses >= 3) {
          _failAutomaticSync(
            'La cuenta de SAGE no expuso un perfil Estudiante.',
            code: CodigoErrorSincronizacionSage.perfilEstudianteAusente,
            step: PasoSincronizacionSageAutomatica.perfil,
            permiteReintentar: false,
          );
        } else {
          _scheduleNavigationProbe();
        }
      }
      return true;
    }

    if (_historyState == EstadoHistorialSage.vacio) {
      _failAutomaticSync(
        'SAGE no encontró carreras en el Historial.',
        code: CodigoErrorSincronizacionSage.historialVacio,
        step: PasoSincronizacionSageAutomatica.historial,
        permiteReintentar: false,
      );
      return true;
    }
    if (_historyState == EstadoHistorialSage.error) {
      _scheduleAutomaticStepRetry(
        step: PasoSincronizacionSageAutomatica.historial,
        message: 'No se pudo leer el Historial de SAGE.',
        code: CodigoErrorSincronizacionSage.abrirHistorial,
        action: _refreshHistory,
      );
      return true;
    }

    if (_nativeHistoryVisible ||
        _historyState == EstadoHistorialSage.disponible ||
        _historyState == EstadoHistorialSage.cargandoCarreras ||
        _historyState == EstadoHistorialSage.cargandoMaterias) {
      _setAutomaticState(
        EtapaSincronizacionSageAutomatica.leyendoTrayectoria,
        'Leyendo trayectoria',
        detalle: 'Preparando las carreras y materias…',
        progreso: 0.80,
      );
      final history = _history;
      if (_documentDownloadMode &&
          history != null &&
          history.carreras.isNotEmpty) {
        unawaited(_tryDownloadRequestedDocument());
        return true;
      }
      if (history != null &&
          history.carreras.isNotEmpty &&
          history.carreras.every((career) => career.materiasCargadas)) {
        _emitTrajectoryIfReady();
      }
      return true;
    }

    if (extraction != null && extraction.disponible) {
      switch (extraction.etapa) {
        case EtapaLegajoSage.miLegajo:
          final record = _preferredAutomaticStudentRecord(extraction.perfiles);
          if (record == null) {
            _scheduleAutomaticStepRetry(
              step: PasoSincronizacionSageAutomatica.legajo,
              message: 'SAGE no mostró un legajo estudiantil.',
              code: CodigoErrorSincronizacionSage.legajoAusente,
              action: () => _recoverAutomaticStep(
                PasoSincronizacionSageAutomatica.legajo,
              ),
            );
            return true;
          }
          _automaticActionBusy = true;
          _setAutomaticState(
            EtapaSincronizacionSageAutomatica.seleccionandoLegajo,
            'Seleccionando legajo',
            detalle: record.nombreVisible.trim().isEmpty
                ? 'Abriendo tu información académica…'
                : 'Abriendo ${record.nombreVisible}…',
            progreso: 0.48,
          );
          try {
            await _activateLegajoProfile(record);
          } finally {
            _automaticActionBusy = false;
          }
          return true;
        case EtapaLegajoSage.secciones:
          final school = _automaticSchoolSection(extraction);
          if (school == null) {
            _scheduleAutomaticStepRetry(
              step: PasoSincronizacionSageAutomatica.escolares,
              message: 'SAGE no mostró la sección Escolares.',
              code: CodigoErrorSincronizacionSage.escolaresAusente,
              action: () => _recoverAutomaticStep(
                PasoSincronizacionSageAutomatica.escolares,
              ),
            );
            return true;
          }
          _automaticActionBusy = true;
          _setAutomaticState(
            EtapaSincronizacionSageAutomatica.abriendoEscolares,
            'Abriendo Escolares',
            detalle: 'Preparando las opciones académicas…',
            progreso: 0.60,
          );
          try {
            await _activateLegajoSection(school);
          } finally {
            _automaticActionBusy = false;
          }
          return true;
        case EtapaLegajoSage.escolares:
          final history = _automaticHistoryOption(extraction);
          if (history == null) {
            _setAutomaticState(
              EtapaSincronizacionSageAutomatica.abriendoHistorial,
              'Buscando Historial',
              detalle: 'Esperando Nivel Superior - Historial…',
              progreso: 0.70,
            );
            return true;
          }
          _automaticActionBusy = true;
          _setAutomaticState(
            EtapaSincronizacionSageAutomatica.abriendoHistorial,
            'Abriendo Historial',
            detalle: 'Cargando tu trayectoria académica…',
            progreso: 0.74,
          );
          try {
            await _activateEscolarOption(history);
          } finally {
            _automaticActionBusy = false;
          }
          return true;
        case EtapaLegajoSage.ninguna:
          break;
      }
    }

    switch (navigation.estado) {
      case EstadoNavegacionSage.modulos:
        _automaticActionBusy = true;
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoLegajo,
          'Abriendo Legajo Único Alumno',
          detalle: 'Ingresando al módulo académico…',
          progreso: 0.36,
        );
        try {
          final opened = await _activateSageLink(
            const OpcionSubmoduloSage(
              titulo: 'Legajo Único Alumno',
              icono: 0xe151,
              pathname: '/pregase/menuprincipal_nuevo.php',
              etiquetasAlternativas: ['legajo unico alumno'],
            ),
          );
          if (!opened) return true;
        } finally {
          _automaticActionBusy = false;
        }
        return true;
      case EstadoNavegacionSage.submodulosLegajoUnico:
        _automaticActionBusy = true;
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.seleccionandoLegajo,
          'Abriendo Legajo Alumnos',
          detalle: 'Buscando tu registro estudiantil…',
          progreso: 0.43,
        );
        try {
          final opened = await _activateSageLink(opcionesSubmodulosSage.first);
          if (!opened) return true;
        } finally {
          _automaticActionBusy = false;
        }
        return true;
      case EstadoNavegacionSage.listadoLegajos:
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.seleccionandoLegajo,
          'Leyendo legajos',
          detalle: 'Esperando los registros disponibles…',
          progreso: 0.46,
        );
        return true;
      case EstadoNavegacionSage.seccionesLegajo:
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoEscolares,
          'Preparando Escolares',
          detalle: 'Esperando las secciones del legajo…',
          progreso: 0.56,
        );
        return true;
      case EstadoNavegacionSage.escolares:
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoHistorial,
          'Preparando Historial',
          detalle: 'Esperando las opciones de Nivel Superior…',
          progreso: 0.68,
        );
        return true;
      case EstadoNavegacionSage.otraPagina:
      case EstadoNavegacionSage.desconocido:
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoLegajo,
          'Preparando recorrido',
          detalle: 'Esperando la siguiente pantalla de SAGE…',
          progreso: _automaticState.progreso ?? 0.32,
        );
        return true;
      case EstadoNavegacionSage.error:
        _failAutomaticSync(
          'SAGE devolvió una pantalla incompatible.',
          code: CodigoErrorSincronizacionSage.estructuraIncompatible,
          step: _automaticState.paso,
        );
        return true;
      case EstadoNavegacionSage.login:
      case EstadoNavegacionSage.sesionVencida:
        return true;
    }
  }

  Future<void> _completeAutomaticSync(
    TrayectoriaSageLaboratorio trajectory,
  ) async {
    if (!_automaticMode || _documentDownloadMode || _automaticCompleting)
      return;
    _automaticCompleting = true;
    _automaticFlowActive = false;
    _automaticWatchdog?.cancel();
    _setAutomaticState(
      EtapaSincronizacionSageAutomatica.guardando,
      'Guardando trayectoria',
      detalle: 'Actualizando la copia local…',
      progreso: 0.97,
    );
    try {
      final stored = widget.onGuardarTrayectoriaAutomatica == null
          ? trajectory
          : await widget.onGuardarTrayectoriaAutomatica!(trajectory);
      if (!mounted) return;
      widget.onTrayectoriaLista?.call(stored);
      _automaticStepAttempts.clear();
      _automaticLastFailedStep = null;
      _automaticRetryAction = null;
      _automaticRetryMessage = null;
      unawaited(
        _syncStateRepository.registrarExito(
          stored,
          firmaLegajo: _selectedStudentRecord?.firmaTecnica,
        ),
      );
      _setAutomaticState(
        EtapaSincronizacionSageAutomatica.completada,
        'Sincronización completa',
        detalle: '${stored.totalMaterias} materias actualizadas.',
        progreso: 1,
        paso: PasoSincronizacionSageAutomatica.guardado,
      );
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted || !widget.cerrarAlCompletar) return;
      _exitSageToAppHome();
    } catch (error) {
      _automaticCompleting = false;
      final message = error is ErrorSincronizacionSageAutomatica
          ? error.mensaje
          : 'La trayectoria se leyó, pero no pudo guardarse en el dispositivo.';
      final code = error is ErrorSincronizacionSageAutomatica
          ? error.codigo
          : CodigoErrorSincronizacionSage.guardadoLocal;
      _failAutomaticSync(
        message,
        code: code,
        step: PasoSincronizacionSageAutomatica.guardado,
      );
    }
  }

  void _onSageVisualMessage(JavaScriptMessage message) {
    if (!mounted || _isClosing) return;
    if (message.message != 'login-submit') return;
    setState(() {
      _authTransitionCoverVisible = true;
      _authTransitionCoverMessage = 'Iniciando sesión…';
      _loginDocumentReady = false;
    });
    _startLoginTransitionWatchdog();
  }

  void _cancelLoginTransitionWatchdog() {
    _loginTransitionId++;
    _loginTransitionWatchdog?.cancel();
    _loginTransitionWatchdog = null;
    _loginTransitionStartedAt = null;
  }

  void _startLoginTransitionWatchdog() {
    final transitionId = ++_loginTransitionId;
    _loginTransitionWatchdog?.cancel();
    _loginTransitionStartedAt = DateTime.now();
    _scheduleLoginTransitionPoll(transitionId);
  }

  void _scheduleLoginTransitionPoll(int transitionId) {
    _loginTransitionWatchdog?.cancel();
    _loginTransitionWatchdog = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_pollLoginTransition(transitionId)),
    );
  }

  Future<Map<String, dynamic>> _readLoginTransitionState() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const normalize = value => String(value || '')
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ')
          .trim();

        const seen = new Set();
        let privateShell = false;
        let privateHome = false;
        let loginForm = false;
        let loginFormVisible = false;
        let loginError = false;
        let pathname = '';
        let authenticatedScore = 0;
        let documentCount = 0;

        const visible = node => {
          if (!node || !node.isConnected) return false;
          const style = node.ownerDocument?.defaultView?.getComputedStyle(node);
          if (style && (style.display === 'none' ||
              style.visibility === 'hidden' || style.opacity === '0')) {
            return false;
          }
          const rect = node.getBoundingClientRect?.();
          return !rect || (rect.width > 0 && rect.height > 0);
        };

        const visit = win => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try {
            doc = win.document;
            pathname = pathname ||
              String(win.location.pathname || '').toLowerCase();
          } catch (_) {
            return;
          }
          documentCount += 1;

          const path = String(win.location.pathname || '').toLowerCase();
          const body = normalize(doc.body?.innerText || '');
          const isLoginPath = path === '/login' || path.startsWith('/login/');
          const passwordInputs = [...doc.querySelectorAll('input[type="password"]')];
          const visiblePassword = passwordInputs.find(visible) || null;

          if (passwordInputs.length > 0) loginForm = true;
          if (visiblePassword) loginFormVisible = true;

          if (path.startsWith('/pregase/') && !isLoginPath) {
            privateShell = true;
            authenticatedScore += 5;
          }

          if (path === '/pregase/menuprincipal_nuevo.php') {
            privateHome = true;
            authenticatedScore += 4;
          }

          const mainFrame = doc.querySelector('iframe#Main');
          const profileControl = doc.querySelector(
            'button.btn.btn-user,[data-bs-toggle="dropdown"],'
            + 'button.menuItem,button.menuItemMobile'
          );
          const logoutControl = [...doc.querySelectorAll('a,button,[onclick]')]
            .find(node => /cerrar sesion|salir|logout/.test(normalize(node.textContent)));

          if (mainFrame) {
            privateShell = true;
            authenticatedScore += 4;
          }
          if (profileControl) {
            privateShell = true;
            authenticatedScore += 3;
          }
          if (logoutControl) {
            privateShell = true;
            authenticatedScore += 3;
          }

          if (body.includes('l.u.a.') ||
              body.includes('l.u.p.') ||
              body.includes('legajo unico alumno') ||
              body.includes('legajo unico personal') ||
              body.includes('seleccionar perfil')) {
            privateShell = true;
            authenticatedScore += 3;
          }

          if (isLoginPath) {
            const errorNodes = [...doc.querySelectorAll(
              '.alert-danger,.invalid-feedback,[role="alert"],'
              + '.text-danger,.error,.login-error'
            )];
            loginError = errorNodes.some(node => {
              const text = normalize(node.textContent);
              return visible(node) && text.length > 0 &&
                /(incorrect|inval|error|usuario|contrasena|clave|credencial)/.test(text);
            });
          }

          doc.querySelectorAll('iframe').forEach(frame => {
            try { visit(frame.contentWindow); } catch (_) {}
          });
        };

        visit(window);
        const authenticated = privateShell ||
          (authenticatedScore >= 4 && !loginFormVisible);

        return JSON.stringify({
          privateShell,
          privateHome,
          authenticated,
          authenticatedScore,
          loginForm,
          loginFormVisible,
          loginError: loginError && loginFormVisible && !authenticated,
          pathname,
          documentCount,
          readyState: String(document.readyState || ''),
        });
      })()''');

      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        return value.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {
      // Se devuelve un estado vacío debajo.
    }

    return const {
      'privateShell': false,
      'privateHome': false,
      'authenticated': false,
      'authenticatedScore': 0,
      'loginForm': false,
      'loginFormVisible': false,
      'loginError': false,
      'pathname': '',
      'documentCount': 0,
      'readyState': '',
    };
  }

  void _completeLoginTransitionToPrivate() {
    if (!mounted || _logoutBusy) return;
    _cancelLoginTransitionWatchdog();
    setState(() {
      _authTransitionCoverVisible = !_automaticMode;
      _authTransitionCoverMessage = 'Preparando tus servicios académicos…';
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Preparando tus servicios académicos…';
      _loginDocumentReady = false;
    });
    _ensureProbeTimer();
    if (_automaticMode) {
      if (!_automaticFlowActive && !_automaticCompleting) {
        _beginAutomaticFlow();
      } else {
        _requestSageProbe();
        _scheduleNavigationProbe();
      }
    } else {
      _requestSageProbe();
      _scheduleNavigationProbe();
    }
    unawaited(_installNavigationObservers());
    if (kDebugMode) {
      debugPrint('[SAGE visual] login_private_shell_confirmed=true');
    }
  }

  Future<void> _pollLoginTransition(int transitionId) async {
    if (!mounted ||
        _isClosing ||
        _logoutBusy ||
        transitionId != _loginTransitionId ||
        !_authTransitionCoverVisible) {
      return;
    }

    final state = await _readLoginTransitionState();

    if (!mounted ||
        transitionId != _loginTransitionId ||
        !_authTransitionCoverVisible) {
      return;
    }

    if (state['authenticated'] == true || state['privateShell'] == true) {
      _completeLoginTransitionToPrivate();
      return;
    }

    if (state['loginError'] == true) {
      _cancelLoginTransitionWatchdog();
      setState(_resetPrivateSageStateForLogin);
      if (_automaticMode) {
        _failAutomaticSync(
          'El usuario o la contraseña no fueron aceptados por SAGE.',
          loginAvailable: true,
          code: CodigoErrorSincronizacionSage.credenciales,
          step: PasoSincronizacionSageAutomatica.sesion,
        );
      }
      return;
    }

    final startedAt = _loginTransitionStartedAt;
    final elapsed = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);

    if (elapsed >= const Duration(seconds: 30)) {
      _cancelLoginTransitionWatchdog();
      setState(() {
        _authTransitionCoverVisible = false;
        _authTransitionCoverMessage = 'Cargando SAGE…';
        _privateSageShellActive = false;
        _showOriginalWebView = true;
        _nativeLoadingVisible = false;
        _loginDocumentReady = state['loginForm'] == true;
      });

      if (_automaticMode) {
        _failAutomaticSync(
          'SAGE no confirmó el inicio de sesión. Intentá nuevamente.',
          loginAvailable:
              state['loginFormVisible'] == true || state['loginForm'] == true,
          code: CodigoErrorSincronizacionSage.tiempoAgotado,
          step: PasoSincronizacionSageAutomatica.sesion,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'SAGE no confirmó el inicio de sesión. '
              'Revisá la pantalla e intentá nuevamente.',
            ),
          ),
        );
      }

      if (kDebugMode) {
        debugPrint(
          '[SAGE visual] login_timeout=true; '
          'pathname=${state['pathname']}; '
          'login_form=${state['loginForm']}; '
          'login_form_visible=${state['loginFormVisible']}; '
          'authenticated_score=${state['authenticatedScore']}; '
          'ready_state=${state['readyState']}',
        );
      }
      return;
    }

    _scheduleLoginTransitionPoll(transitionId);
  }

  Future<void> _installLoginTransitionObserver() async {
    try {
      await _evaluateJavascript(r'''(() => {
        const path = String(window.location.pathname || '').toLowerCase();
        if (path !== '/login' && !path.startsWith('/login/')) return false;
        const bridge = window.SageVisualBridge;
        if (!bridge || typeof bridge.postMessage !== 'function') return false;
        const doc = window.document;
        if (!doc || doc.__flutterSageLoginVisualObserver === true) return true;

        let notified = false;
        const notify = () => {
          if (notified) return;
          notified = true;
          try { bridge.postMessage('login-submit'); } catch (_) {}
          window.setTimeout(() => { notified = false; }, 2500);
        };

        doc.addEventListener('submit', event => {
          const form = event.target;
          if (form && String(form.tagName || '').toLowerCase() === 'form') {
            notify();
          }
        }, true);

        doc.addEventListener('click', event => {
          const target = event.target?.closest?.(
            'button[type="submit"],input[type="submit"],button:not([type])'
          );
          if (!target) return;
          const form = target.form || target.closest?.('form');
          if (form) notify();
        }, true);

        doc.addEventListener('keydown', event => {
          if (event.key !== 'Enter') return;
          const target = event.target;
          const form = target?.form || target?.closest?.('form');
          if (form) notify();
        }, true);

        doc.__flutterSageLoginVisualObserver = true;
        return true;
      })()''');
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[SAGE visual] login_observer=false');
      }
    }
  }

  Future<void> _installNavigationObservers() async {
    try {
      await _evaluateJavascript(r'''(() => {
        const root = window;
        const bridge = root.SageNavigationBridge;
        if (!bridge || typeof bridge.postMessage !== 'function') return false;
        const notify = (() => {
          let timer = null;
          return () => {
            clearTimeout(timer);
            timer = setTimeout(() => bridge.postMessage('changed'), 120);
          };
        })();
        const seen = new Set();
        const install = win => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          if (!doc?.documentElement) return;
          if (doc.__flutterSageNavigationObserverDocument !== doc) {
            try { doc.__flutterSageNavigationObserver?.disconnect(); } catch (_) {}
            const observer = new MutationObserver(notify);
            observer.observe(doc.documentElement, {
              childList: true,
              subtree: true,
              characterData: true,
              attributes: true,
              attributeFilter: ['src', 'href', 'class', 'style'],
            });
            doc.__flutterSageNavigationObserver = observer;
            doc.__flutterSageNavigationObserverDocument = doc;
          }
          doc.querySelectorAll('iframe').forEach(frame => {
            if (!frame.__flutterSageNavigationLoadListener) {
              frame.addEventListener('load', notify, {passive: true});
              frame.__flutterSageNavigationLoadListener = true;
            }
            try { install(frame.contentWindow); } catch (_) {}
          });
        };
        install(root);
        return true;
      })()''');
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[SAGE navegación] observer_install=false');
      }
    }
  }

  // ignore: unused_element
  Future<void> _installReportBridge() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const root = window;
        const main = root.document.querySelector('iframe#Main');
        const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
        const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
        const flutterBridge = root.SageReportBridge;
        const allowedPaths = new Set([
          '/alumnos_v2/ns_reporte_estado_alumno_carrera.php',
          '/alumnos_v2/ns_reporte_analitico.php',
          '/alumnos_v2/ns_reporte_examenes_rendidos.php',
        ]);
        if (!flutterBridge || typeof flutterBridge.postMessage !== 'function') {
          return JSON.stringify({state:'channel_unavailable', patched:0});
        }
        const contexts = [
          {target:root, label:'root'},
          {target:main?.contentWindow, label:'main'},
          {target:alumnos?.contentWindow, label:'alumnos'},
          {target:escolares?.contentWindow, label:'escolares'},
        ];
        const installInto = (targetWin, label) => {
          if (!targetWin) return {label, state:'missing'};
          try {
            const installed = targetWin.__flutterSageReportBridgeV2;
            if (installed?.wrapper && targetWin.open === installed.wrapper) {
              return {label, state:'reused'};
            }
            const originalOpen = targetWin.open.bind(targetWin);
            const wrapper = function(url, target, features) {
              try {
                const resolved = new URL(String(url), targetWin.location.href);
                const normalizedPath = resolved.pathname.toLowerCase().replace(/\/+$/, '');
                const allowed = resolved.protocol === 'https:' &&
                  resolved.hostname.toLowerCase() === 'sage.entrerios.gov.ar' &&
                  allowedPaths.has(normalizedPath);
                if (allowed) {
                  flutterBridge.postMessage(JSON.stringify({
                    type:'sage_report_url',
                    url:resolved.href,
                  }));
                  return {closed:false, close(){}, focus(){}, blur(){}};
                }
              } catch (_) {}
              return originalOpen(url, target, features);
            };
            targetWin.open = wrapper;
            targetWin.__flutterSageReportBridgeV2 = {wrapper, originalOpen, label};
            return {label, state:'patched'};
          } catch (_) {
            return {label, state:'inaccessible'};
          }
        };
        const states = contexts.map(item => installInto(item.target, item.label));
        const result = {
          state: states.some(item => item.state === 'patched' || item.state === 'reused')
            ? 'ready' : 'bridge_install_failed',
          patched: states.filter(item => item.state === 'patched' || item.state === 'reused').length,
          states,
        };
        return JSON.stringify(result);
      })()''');
      if (kDebugMode) {
        dynamic decoded;
        try {
          decoded = jsonDecode(raw);
          if (decoded is String) decoded = jsonDecode(decoded);
        } catch (_) {}
        final states = decoded is Map && decoded['states'] is List
            ? decoded['states'] as List
            : const <dynamic>[];
        bool stateFor(String label, String state) => states.any(
          (item) =>
              item is Map &&
              item['label'] == label &&
              (item['state'] == state ||
                  (state == 'active' &&
                      (item['state'] == 'patched' ||
                          item['state'] == 'reused'))),
        );
        debugPrint(
          '[SAGE report] channel_available=${decoded is Map && decoded['state'] != 'channel_unavailable'}',
        );
        debugPrint('[SAGE report] patched_root=${stateFor('root', 'active')}');
        debugPrint('[SAGE report] patched_main=${stateFor('main', 'active')}');
        debugPrint(
          '[SAGE report] patched_alumnos=${stateFor('alumnos', 'active')}',
        );
        debugPrint(
          '[SAGE report] patched_escolares=${stateFor('escolares', 'active')}',
        );
      }
    } catch (_) {
      if (kDebugMode) debugPrint('[SAGE report] bridge_install_failed=true');
    }
  }

  Future<void> _installReportDiagnostics() async {
    try {
      await _evaluateJavascript(r'''(() => {
        const root = window;
        const bridge = root.SageDiagnosticBridge;
        if (!bridge || typeof bridge.postMessage !== 'function') return false;
        const main = root.document.querySelector('iframe#Main');
        const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
        const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
        const contexts = [
          {target:root, label:'root'},
          {target:main?.contentWindow, label:'main'},
          {target:alumnos?.contentWindow, label:'alumnos'},
          {target:escolares?.contentWindow, label:'escolares'},
        ];
        const send = value => {
          try { bridge.postMessage(JSON.stringify(value)); } catch (_) {}
        };
        const lastSegment = value => {
          try {
            const parsed = new URL(String(value), root.location.href);
            return parsed.pathname.split('/').filter(Boolean).pop() || '/';
          } catch (_) { return 'invalid'; }
        };
        const install = item => {
          const target = item.target;
          if (!target) return {label:item.label, state:'missing'};
          try {
            if (target.__sageReportDiagnosticsV1) return {label:item.label, state:'reused'};
            const originalOpen = target.open.bind(target);
            target.open = function(url, name, features) {
              let schemeAllowed = false;
              let hostAllowed = false;
              let pathAllowed = false;
              let empty = false;
              try {
                empty = String(url ?? '') === '';
                const resolved = new URL(String(url), target.location.href);
                schemeAllowed = resolved.protocol === 'https:';
                hostAllowed = resolved.hostname.toLowerCase() === 'sage.entrerios.gov.ar';
                pathAllowed = /ns_reporte_/.test(resolved.pathname.toLowerCase());
                send({event:'open', owner:item.label, url_empty:empty,
                  scheme_allowed:schemeAllowed, host_allowed:hostAllowed,
                  path_allowed:pathAllowed, last_path_segment:lastSegment(resolved.href)});
              } catch (_) {
                send({event:'open', owner:item.label, url_empty:empty,
                  scheme_allowed:false, host_allowed:false, path_allowed:false,
                  last_path_segment:'invalid'});
              }
              return originalOpen(url, name, features);
            };
            const formSubmit = target.HTMLFormElement?.prototype?.submit;
            if (formSubmit) target.HTMLFormElement.prototype.submit = function() {
              const action = this.getAttribute('action') || target.location.href;
              let parsed;
              try { parsed = new URL(action, target.location.href); } catch (_) {}
              send({event:'form_submit', owner:item.label,
                method:(this.getAttribute('method') || 'get').toUpperCase(),
                target_present:Boolean(this.getAttribute('target')),
                action_scheme:parsed?.protocol || 'invalid',
                action_host:parsed?.hostname || 'invalid',
                action_last_path_segment:parsed ? lastSegment(parsed.href) : 'invalid'});
              return formSubmit.apply(this, arguments);
            };
            const requestSubmit = target.HTMLFormElement?.prototype?.requestSubmit;
            if (requestSubmit) target.HTMLFormElement.prototype.requestSubmit = function() {
              const action = this.getAttribute('action') || target.location.href;
              let parsed;
              try { parsed = new URL(action, target.location.href); } catch (_) {}
              send({event:'form_submit', owner:item.label,
                method:(this.getAttribute('method') || 'get').toUpperCase(),
                target_present:Boolean(this.getAttribute('target')),
                action_scheme:parsed?.protocol || 'invalid',
                action_host:parsed?.hostname || 'invalid',
                action_last_path_segment:parsed ? lastSegment(parsed.href) : 'invalid'});
              return requestSubmit.apply(this, arguments);
            };
            target.document?.addEventListener('click', event => {
              const anchor = event.target?.closest?.('a');
              if (!anchor) return;
              let parsed;
              try { parsed = new URL(anchor.href, target.location.href); } catch (_) {}
              send({event:'anchor_click', owner:item.label,
                target_blank:anchor.target === '_blank',
                href_scheme:parsed?.protocol || 'invalid',
                href_host:parsed?.hostname || 'invalid',
                href_last_path_segment:parsed ? lastSegment(parsed.href) : 'invalid'});
            }, true);
            let previousPath = String(target.location.pathname || '');
            target.setInterval(() => {
              const nextPath = String(target.location.pathname || '');
              if (nextPath !== previousPath) {
                send({event:'location_change', owner:item.label, last_path_segment:lastSegment(nextPath)});
                previousPath = nextPath;
              }
            }, 250);
            const originalFetch = target.fetch;
            if (typeof originalFetch === 'function') target.fetch = function(input, init) {
              let parsed;
              try { parsed = new URL(typeof input === 'string' ? input : input.url, target.location.href); } catch (_) {}
              send({event:'fetch', owner:item.label, method:(init?.method || input?.method || 'GET').toUpperCase(),
                host:parsed?.hostname || 'invalid', last_path_segment:parsed ? lastSegment(parsed.href) : 'invalid'});
              return originalFetch.apply(this, arguments);
            };
            const originalXhrOpen = target.XMLHttpRequest?.prototype?.open;
            if (originalXhrOpen) target.XMLHttpRequest.prototype.open = function(method, url) {
              let parsed;
              try { parsed = new URL(String(url), target.location.href); } catch (_) {}
              send({event:'xhr', owner:item.label, method:String(method || 'GET').toUpperCase(),
                host:parsed?.hostname || 'invalid', last_path_segment:parsed ? lastSegment(parsed.href) : 'invalid'});
              return originalXhrOpen.apply(this, arguments);
            };
            target.__sageReportDiagnosticsV1 = true;
            send({event:'context_ready', context:item.label,
              channel_type:typeof target.SageReportBridge,
              top_channel_type:typeof target.top?.SageReportBridge,
              parent_channel_type:typeof target.parent?.SageReportBridge});
            send({event:'sage_report_probe', context:item.label});
            return {label:item.label, state:'patched'};
          } catch (_) { return {label:item.label, state:'inaccessible'}; }
        };
        const states = contexts.map(install);
        send({event:'diagnostics_ready', states});
        return true;
      })()''');
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[SAGE report] diagnostic_install_failed=true');
      }
    }
  }

  void _onSageReportMessage(JavaScriptMessage message) {
    unawaited(_handleSageReportMessage(message));
  }

  void _onSageDiagnosticMessage(JavaScriptMessage message) {
    if (!kDebugMode) return;
    try {
      dynamic value = jsonDecode(message.message);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        debugPrint(
          '[SAGE diagnostic] ${value['event'] ?? 'unknown'} ${jsonEncode(value)}',
        );
      }
    } catch (_) {
      debugPrint('[SAGE diagnostic] message_invalid=true');
    }
  }

  Future<void> _handleSageReportMessage(JavaScriptMessage message) async {
    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(message.message);
      if (decoded is Map) payload = Map<String, dynamic>.from(decoded);
    } catch (_) {
      if (kDebugMode) debugPrint('[SAGE report bridge] message_received=false');
      return;
    }
    if (payload?['type'] != 'sage_report_url' || payload?['url'] is! String) {
      if (kDebugMode) debugPrint('[SAGE report bridge] message_received=false');
      return;
    }
    if (kDebugMode) debugPrint('[SAGE report bridge] message_received=true');
    if (kDebugMode) debugPrint('[SAGE report V3] message_received=true');
    final uri = Uri.tryParse(payload!['url'] as String);
    if (uri == null || !_isAllowedReportUri(uri)) {
      if (kDebugMode) debugPrint('[SAGE report bridge] uri_allowed=false');
      return;
    }
    if (kDebugMode) debugPrint('[SAGE report bridge] uri_allowed=true');
    if (kDebugMode) debugPrint('[SAGE report V3] uri_allowed=true');
    final pending = _pendingReportUrl;
    if (pending != null && !pending.isCompleted) {
      pending.complete(uri);
      return;
    }
    await _procesarDescargaWeb(uri: uri);
    if (kDebugMode) debugPrint('[SAGE report] download_started=true');
  }

  bool _isAllowedReportUri(Uri uri) {
    const allowedPaths = <String>{
      '/alumnos_v2/NS_reporte_estado_alumno_carrera.php',
      '/alumnos_v2/NS_reporte_analitico.php',
      '/alumnos_v2/NS_reporte_examenes_rendidos.php',
    };
    return uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'sage.entrerios.gov.ar' &&
        allowedPaths.contains(uri.path);
  }

  Future<void> _probeNavigationAndApply() async {
    if (_navigationProbeRunning || _isClosing) return;
    _navigationProbeRunning = true;
    try {
      final result = await _probeSageNavigation();
      final legajoResult = await _probeLegajoIfRelevant(result);
      final agentHome = await _probeAgentHome();
      final agentPersonal = await _probeAgentPersonal();
      final profiles =
          result.estado == EstadoNavegacionSage.login ||
              result.estado == EstadoNavegacionSage.sesionVencida
          ? const CapturaPerfilesSage(perfiles: [])
          : await _probeProfiles(
              openPanelIfNeeded: !_profileChoiceMade && !_profileSwitchBusy,
            );
      _profileCapture = profiles;
      unawaited(_installNavigationObservers());
      if (!mounted) return;

      if (result.shellPrivado &&
          result.estado != EstadoNavegacionSage.login &&
          result.estado != EstadoNavegacionSage.sesionVencida) {
        _privateSageShellActive = true;
      }

      if (_profileSwitchBusy || _profileHomeResetBusy || _logoutBusy) {
        return;
      }
      if (_manualNavigationActive &&
          !_navigationAwaitingTransition &&
          !_nativeLoadingVisible &&
          result.estado != EstadoNavegacionSage.login &&
          result.estado != EstadoNavegacionSage.sesionVencida) {
        return;
      }

      if (_navigationAwaitingTransition) {
        final escolaresConfirmed =
            _tipoAccionLegajo == TipoAccionLegajoSage.abrirEscolares &&
            legajoResult?.etapa == EtapaLegajoSage.escolares &&
            legajoResult!.opcionesEscolares.any(
              (option) =>
                  option.clave == 'historial_del_alumnado' ||
                  option.clave == 'nivel_superior_historial',
            );
        final legajoTransitionConfirmed =
            _tipoAccionLegajo != TipoAccionLegajoSage.abrirHistorial &&
            legajoResult?.disponible == true &&
            legajoResult!.firma != _legajoOriginSignature;
        final transitionConfirmed =
            cambioNavegacionSageConfirmado(
              resultado: result,
              firmaOrigen: _navigationOriginSignature,
              estadoOrigen: _navigationOriginState,
            ) ||
            legajoTransitionConfirmed ||
            escolaresConfirmed;
        final intermediateOtherPage =
            result.estado == EstadoNavegacionSage.otraPagina &&
            result.documentoActivo?.pathname == _navigationOriginPath;
        final transitionTimeout = _automaticMode
            ? const Duration(seconds: 18)
            : const Duration(seconds: 8);
        final timedOut =
            _navigationActionStartedAt != null &&
            DateTime.now().difference(_navigationActionStartedAt!) >
                transitionTimeout;
        if (_tipoAccionLegajo == TipoAccionLegajoSage.abrirHistorial) {
          if (!timedOut) return;
          final tipoFallido = _tipoAccionLegajo;
          setState(() {
            _navigationAwaitingTransition = false;
            _navigationActionInFlight = null;
            _legajoActionInFlight = null;
            _nativeLoadingVisible = false;
            _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
            _navigationOriginSignature = null;
            _navigationOriginState = null;
            _navigationOriginPath = null;
            _navigationActionStartedAt = null;
            _legajoOriginSignature = null;
            _usuarioSolicitoEscolares = false;
          });
          final message = _timeoutMessage(tipoFallido);
          if (_automaticMode) {
            final step = switch (tipoFallido) {
              TipoAccionLegajoSage.abrirHistorial =>
                PasoSincronizacionSageAutomatica.historial,
              TipoAccionLegajoSage.abrirEscolares =>
                PasoSincronizacionSageAutomatica.escolares,
              _ => PasoSincronizacionSageAutomatica.legajo,
            };
            _scheduleAutomaticStepRetry(
              step: step,
              message: message,
              code: CodigoErrorSincronizacionSage.tiempoAgotado,
              action: () => _recoverAutomaticStep(step),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          return;
        }
        if (transitionConfirmed &&
            (!intermediateOtherPage ||
                legajoTransitionConfirmed ||
                escolaresConfirmed)) {
          _navigationAwaitingTransition = false;
          _navigationActionInFlight = null;
          _legajoActionInFlight = null;
          _navigationOriginSignature = null;
          _navigationOriginState = null;
          _navigationOriginPath = null;
          _navigationActionStartedAt = null;
          _legajoOriginSignature = null;
          _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
        } else if (timedOut) {
          final tipoFallido = _tipoAccionLegajo;
          setState(() {
            _navigationAwaitingTransition = false;
            _navigationActionInFlight = null;
            _legajoActionInFlight = null;
            _nativeLoadingVisible = false;
            _navigationOriginSignature = null;
            _navigationOriginState = null;
            _navigationOriginPath = null;
            _navigationActionStartedAt = null;
            _legajoOriginSignature = null;
            _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
            _usuarioSolicitoEscolares = false;
          });
          final message = _timeoutMessage(tipoFallido);
          if (_automaticMode) {
            final step = switch (tipoFallido) {
              TipoAccionLegajoSage.abrirHistorial =>
                PasoSincronizacionSageAutomatica.historial,
              TipoAccionLegajoSage.abrirEscolares =>
                PasoSincronizacionSageAutomatica.escolares,
              _ => PasoSincronizacionSageAutomatica.legajo,
            };
            _scheduleAutomaticStepRetry(
              step: step,
              message: message,
              code: CodigoErrorSincronizacionSage.tiempoAgotado,
              action: () => _recoverAutomaticStep(step),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          return;
        } else {
          return;
        }
      }

      if (_automaticMode &&
          await _advanceAutomaticSync(result, legajoResult, profiles)) {
        return;
      }

      if (_nativeHistoryVisible &&
          result.estado != EstadoNavegacionSage.login &&
          result.estado != EstadoNavegacionSage.sesionVencida) {
        return;
      }
      if (await _handleStudentAutomaticLanding(result)) {
        return;
      }

      if (!_profileChoiceMade &&
          !_profileSwitchBusy &&
          profiles.perfiles.length >= 2 &&
          result.estado != EstadoNavegacionSage.login &&
          result.estado != EstadoNavegacionSage.sesionVencida) {
        setState(() {
          _nativeProfileSelectorVisible = true;
          _nativeModulesVisible = false;
          _nativeSubmodulesVisible = false;
          _nativeAgentHomeVisible = false;
          _nativeAgentPersonalVisible = false;
          _nativeAgentStudentMenuVisible = false;
          _nativeLoadingVisible = false;
        });
        return;
      }
      if (_profileChoiceMade &&
          agentHome &&
          !_nativeAgentStudentMenuVisible &&
          !_nativeHistoryVisible &&
          !_nativeLegajoVisible &&
          !_nativeSeccionesLegajoVisible &&
          !_nativeEscolaresVisible) {
        setState(() {
          _nativeAgentHomeVisible = true;
          _nativeAgentPersonalVisible = false;
          _nativeModulesVisible = false;
          _nativeSubmodulesVisible = false;
          _nativeLoadingVisible = false;
        });
        return;
      }
      if (_profileChoiceMade &&
          agentPersonal.isNotEmpty &&
          !_nativeAgentStudentMenuVisible &&
          !_nativeHistoryVisible &&
          !_nativeLegajoVisible &&
          !_nativeSeccionesLegajoVisible &&
          !_nativeEscolaresVisible) {
        setState(() {
          _agentPersonalOptions = agentPersonal;
          _nativeAgentPersonalVisible = true;
          _nativeAgentHomeVisible = false;
          _nativeModulesVisible = false;
          _nativeSubmodulesVisible = false;
          _nativeLoadingVisible = false;
        });
        return;
      }
      setState(() {
        switch (result.estado) {
          case EstadoNavegacionSage.modulos:
            _nativeHistoryVisible = false;
            _nativeModulesVisible = true;
            _nativeSubmodulesVisible = false;
            _nativeLegajoVisible = false;
            _nativeSeccionesLegajoVisible = false;
            _nativeEscolaresVisible = false;
            _nativeLoadingVisible = false;
            _navigationActionInFlight = null;
          case EstadoNavegacionSage.submodulosLegajoUnico:
            _nativeHistoryVisible = false;
            _nativeModulesVisible = false;
            _nativeSubmodulesVisible = true;
            _nativeLegajoVisible = false;
            _nativeSeccionesLegajoVisible = false;
            _nativeEscolaresVisible = false;
            _nativeLoadingVisible = false;
            _navigationActionInFlight = null;
          case EstadoNavegacionSage.listadoLegajos:
          case EstadoNavegacionSage.seccionesLegajo:
          case EstadoNavegacionSage.escolares:
            _nativeHistoryVisible = false;
            _nativeModulesVisible = false;
            _nativeSubmodulesVisible = false;
            _nativeLoadingVisible = true;
          case EstadoNavegacionSage.login:
          case EstadoNavegacionSage.sesionVencida:
            _privateSageShellActive = false;
            _showOriginalWebView = true;
            _usuarioSolicitoEscolares = false;
            _nativeHistoryVisible = false;
            _nativeModulesVisible = false;
            _nativeSubmodulesVisible = false;
            _nativeLegajoVisible = false;
            _nativeSeccionesLegajoVisible = false;
            _nativeEscolaresVisible = false;
            _nativeLoadingVisible = false;
          case EstadoNavegacionSage.otraPagina:
            if (!_navigationAwaitingTransition) {
              _usuarioSolicitoEscolares = false;
            }
            _nativeModulesVisible = false;
            _nativeSubmodulesVisible = false;
            _nativeLegajoVisible = false;
            _nativeSeccionesLegajoVisible = false;
            _nativeEscolaresVisible = false;
            _nativeLoadingVisible = false;
          case EstadoNavegacionSage.desconocido:
            if (result.shellPrivado) {
              _nativeLoadingVisible = true;
              _nativeLoadingMessage = 'Preparando tus servicios académicos…';
            }
          case EstadoNavegacionSage.error:
            _usuarioSolicitoEscolares = false;
            _nativeLegajoVisible = false;
            _nativeSeccionesLegajoVisible = false;
            _nativeEscolaresVisible = false;
            _nativeLoadingVisible = false;
        }
        _applyLegajoResult(legajoResult);
      });
    } finally {
      _navigationProbeRunning = false;
    }
  }

  Future<bool> _probeAgentHome() async {
    final portada = await ExtractorAgenteSage(_evaluateJavascript).extraer();
    if (portada == null) return false;
    _portadaAgente = portada;
    return portada.disponible;
  }

  Future<List<OpcionAgenteSage>> _probeAgentPersonal() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
          const normalize = value => String(value || '').toLowerCase()
            .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
            .replace(/\s+/g, ' ').trim();
          const keys = [
            'legajo agentes',
            'alumnos por docente nivel superior',
            'mi credencial',
            'sueldo personal',
            'alumnos por docente'
          ];
          const visible = node => {
            if (!node || !node.isConnected) return false;
            const style = node.ownerDocument?.defaultView?.getComputedStyle(node);
            if (style && (style.display === 'none' || style.visibility === 'hidden')) return false;
            const rect = node.getBoundingClientRect?.();
            if (!rect) return true;
            const win = node.ownerDocument?.defaultView;
            return rect.width > 0 && rect.height > 0 &&
              rect.bottom > 0 && rect.right > 0 &&
              rect.top < (win?.innerHeight || 0) &&
              rect.left < (win?.innerWidth || 0);
          };
          const contexts = [];
          const seen = new Set();
          const visit = win => {
            if (!win || seen.has(win)) return;
            seen.add(win);
            let doc;
            try { doc = win.document; } catch (_) { return; }
            contexts.push({win, doc, path:String(win.location.pathname || '')});
            doc.querySelectorAll('iframe').forEach(frame => {
              try { visit(frame.contentWindow); } catch (_) {}
            });
          };
          visit(window);
          const page = contexts.find(context => {
            if (context.path.toLowerCase() === '/pregase/index.php') return false;
            const matches = [...context.doc.querySelectorAll('a[href],button,[role="button"]')]
              .filter(node => visible(node) && keys.includes(normalize(node.textContent)));
            return matches.length >= 2;
          });
          if (!page) return JSON.stringify([]);
          const out = [];
          const used = new Set();
          page.doc.querySelectorAll('a[href],button,[role="button"]').forEach(node => {
            if (!visible(node)) return;
            const text = normalize(node.textContent);
            const key = keys.find(value => text === value);
            if (!key || used.has(key)) return;
            used.add(key);
            let path = null;
            try {
              const href = node.getAttribute('href');
              if (href) path = new URL(href, page.win.location.href).pathname;
            } catch (_) {}
            out.push({
              label:String(node.textContent || '').replace(/\s+/g, ' ').trim(),
              path
            });
          });
          return JSON.stringify(out);
        })()''');
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is! List) return const [];
      return [
        for (final item in value)
          if (item is Map)
            OpcionAgenteSage(
              claveCanonica: (item['label'] as String? ?? '')
                  .toLowerCase()
                  .replaceAll(' ', '_'),
              etiqueta: item['label'] as String? ?? '',
              ruta: item['path'] as String?,
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<CapturaPerfilesSage> _probeProfiles({bool openPanelIfNeeded = false}) {
    return EjecutorPerfilesSage(
      _evaluateJavascript,
    ).inspeccionar(abrirPanelSiHaceFalta: openPanelIfNeeded);
  }

  void _showUnavailableFeature(String title) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '$title no está disponible por el momento. Próximamente.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  bool _isImplementedWebOption(OpcionSubmoduloSage option) {
    final title = DetectorNavegacionSage.normalizar(option.titulo);
    return title == 'legajo unico alumno' || title == 'legajo alumnos';
  }

  void _cancelStudentAutomaticLanding() {
    _studentAutoLandingWatchdog?.cancel();
    _studentAutoLandingWatchdog = null;
    _studentAutoLandingActive = false;
  }

  void _startStudentAutomaticLanding(int transitionId) {
    _studentAutoLandingWatchdog?.cancel();
    _studentAutoLandingActive = true;
    _studentAutoLandingWatchdog = Timer(const Duration(seconds: 24), () {
      if (!mounted ||
          transitionId != _profileTransitionId ||
          !_studentAutoLandingActive) {
        return;
      }
      _studentAutoLandingActive = false;
      _studentAutoLandingWatchdog = null;
      final currentState = _lastNavigationResult?.estado;
      setState(() {
        _nativeLoadingVisible = false;
        _nativeModulesVisible =
            currentState != EstadoNavegacionSage.submodulosLegajoUnico;
        _nativeSubmodulesVisible =
            currentState == EstadoNavegacionSage.submodulosLegajoUnico;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'No se pudo completar el acceso automático. '
            'Podés continuar desde la opción resaltada.',
          ),
        ),
      );
    });
  }

  void _finishStudentAutomaticLanding() {
    _studentAutoLandingWatchdog?.cancel();
    _studentAutoLandingWatchdog = null;
    _studentAutoLandingActive = false;
    if (kDebugMode) {
      debugPrint(
        '[SAGE estudiante] automatic_landing=complete; '
        'destination=legajo_unico_alumno',
      );
    }
  }

  Future<bool> _handleStudentAutomaticLanding(
    ResultadoDeteccionNavegacionSage result,
  ) async {
    if (!_studentAutoLandingActive || _effectiveProfile != PerfilSage.alumnos) {
      return false;
    }

    final reachedStudentMenu =
        result.estado == EstadoNavegacionSage.submodulosLegajoUnico;
    if (reachedStudentMenu) {
      _finishStudentAutomaticLanding();
      return false;
    }

    if (_navigationAwaitingTransition ||
        _navigationActionInFlight != null ||
        _legajoActionInFlight != null) {
      return true;
    }

    switch (result.estado) {
      case EstadoNavegacionSage.modulos:
        final opened = await _activateSageLink(
          const OpcionSubmoduloSage(
            titulo: 'Legajo Único Alumno',
            icono: 0xe151,
            pathname: '/pregase/menuprincipal_nuevo.php',
            etiquetasAlternativas: ['legajo unico alumno'],
          ),
        );
        if (!opened) _cancelStudentAutomaticLanding();
        return true;
      case EstadoNavegacionSage.submodulosLegajoUnico:
        _finishStudentAutomaticLanding();
        return false;
      case EstadoNavegacionSage.login:
      case EstadoNavegacionSage.sesionVencida:
      case EstadoNavegacionSage.error:
        _cancelStudentAutomaticLanding();
        return false;
      case EstadoNavegacionSage.listadoLegajos:
      case EstadoNavegacionSage.seccionesLegajo:
      case EstadoNavegacionSage.escolares:
      case EstadoNavegacionSage.otraPagina:
      case EstadoNavegacionSage.desconocido:
        return true;
    }
  }

  Future<void> _selectProfile(PerfilSage profile) async {
    if (_profileSwitchBusy || _profileHomeResetBusy || _logoutBusy) return;

    _cancelStudentAutomaticLanding();
    final transitionId = ++_profileTransitionId;
    final current = _profileCapture?.activo ?? _selectedProfile;

    _ensureProbeTimer();
    _profileSwitchTarget = profile;
    _startProfileSwitchWatchdog(profile, transitionId);
    _manualNavigationActive = true;
    if (mounted) {
      setState(() {
        _privateSageShellActive = true;
        _showOriginalWebView = false;
        _profileSwitchBusy = true;
        _profileHomeResetBusy = false;
        _profileError = null;
        _nativeProfileSelectorVisible = false;
        _nativeLoadingVisible = true;
        _nativeLoadingMessage = current == profile
            ? 'Abriendo ${profile.etiqueta}…'
            : 'Cambiando a ${profile.etiqueta}…';
        _nativeHistoryVisible = false;
        _nativeModulesVisible = false;
        _nativeSubmodulesVisible = false;
        _nativeLegajoVisible = false;
        _nativeSeccionesLegajoVisible = false;
        _nativeEscolaresVisible = false;
        _nativeAgentHomeVisible = false;
        _nativeAgentPersonalVisible = false;
        _nativeAgentStudentMenuVisible = false;
        _navigationActionInFlight = null;
        _legajoActionInFlight = null;
        _navigationAwaitingTransition = false;
        _navigationOriginSignature = null;
        _navigationOriginState = null;
        _navigationOriginPath = null;
        _navigationActionStartedAt = null;
        _legajoOriginSignature = null;
        _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
        _usuarioSolicitoEscolares = false;
      });
    }

    if (current == profile) {
      if (profile == PerfilSage.agente) {
        try {
          await _probeAgentHome().timeout(const Duration(seconds: 4));
        } catch (_) {
          // La portada ya extraída sigue siendo válida como respaldo.
        }
      }
      if (!mounted || transitionId != _profileTransitionId) return;
      _completeProfileSelection(profile, transitionId);
      return;
    }

    ResultadoCambioPerfilSage dispatch;
    try {
      dispatch = await EjecutorPerfilesSage(
        _evaluateJavascript,
      ).cambiar(profile).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      if (!mounted || transitionId != _profileTransitionId) return;
      _failProfileSelection(
        'SAGE tardó demasiado en abrir el selector de perfiles. Intentá nuevamente.',
        transitionId,
      );
      return;
    } catch (_) {
      if (!mounted || transitionId != _profileTransitionId) return;
      _failProfileSelection(
        'No se pudo iniciar el cambio de perfil en SAGE.',
        transitionId,
      );
      return;
    }

    if (!mounted || transitionId != _profileTransitionId) return;

    if (!dispatch.dispatchSucceeded) {
      if (kDebugMode) {
        debugPrint(
          '[SAGE perfil] target=${profile.clave}; stage=${dispatch.stage}; '
          'avatar=${dispatch.avatarFound}; panel=${dispatch.panelOpened}; '
          'found=${dispatch.found}; dispatched=${dispatch.dispatched}; '
          'activated=${dispatch.activated}',
        );
      }
      _failProfileSelection(dispatch.errorMessage, transitionId);
      return;
    }

    final confirmed =
        dispatch.alreadyActive ||
        await _confirmProfileChange(
          profile,
          transitionId: transitionId,
        ).timeout(const Duration(seconds: 16), onTimeout: () => false);

    if (!mounted || transitionId != _profileTransitionId) return;

    if (!confirmed) {
      _failProfileSelection(
        'SAGE no confirmó el cambio a ${profile.etiqueta}. '
        'El perfil anterior sigue activo.',
        transitionId,
      );
      return;
    }

    _completeProfileSelection(profile, transitionId);
  }

  void _completeProfileSelection(PerfilSage profile, int transitionId) {
    if (!mounted || transitionId != _profileTransitionId) return;

    _stopProfileSwitchWatchdog();
    _cancelStudentAutomaticLanding();
    _profileSwitchTarget = null;
    _ensureProbeTimer();
    final previousCapture = _profileCapture;
    if (previousCapture != null) {
      _profileCapture = CapturaPerfilesSage(
        perfiles: [
          for (final item in previousCapture.perfiles)
            PerfilDisponibleSage(
              perfil: item.perfil,
              activo: item.perfil == profile,
              disponible: item.disponible,
              controlEncontrado: item.controlEncontrado,
            ),
        ],
        panelAbierto: false,
        avatarEncontrado: previousCapture.avatarEncontrado,
        avatarActivado: previousCapture.avatarActivado,
        documento: previousCapture.documento,
      );
    }

    _manualNavigationActive = false;
    setState(() {
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _selectedProfile = profile;
      _profileChoiceMade = true;
      _profileSwitchBusy = false;
      _profileHomeResetBusy = false;
      _profileError = null;
      _nativeProfileSelectorVisible = false;
      _nativeLoadingVisible = false;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = profile == PerfilSage.agente;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = profile == PerfilSage.alumnos;
      _nativeLoadingMessage = profile == PerfilSage.alumnos
          ? 'Abriendo Legajo Único Alumno…'
          : 'Preparando tus servicios académicos…';
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _navigationActionStartedAt = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
    });

    if (_automaticMode) {
      if (profile == PerfilSage.alumnos) {
        _setAutomaticState(
          EtapaSincronizacionSageAutomatica.abriendoLegajo,
          'Perfil Estudiante listo',
          detalle: 'Preparando el acceso al historial…',
          progreso: 0.30,
        );
        _requestSageProbe();
        _scheduleNavigationProbe();
      } else {
        _failAutomaticSync(
          'La sincronización requiere un perfil Estudiante.',
          code: CodigoErrorSincronizacionSage.perfilEstudianteAusente,
          step: PasoSincronizacionSageAutomatica.perfil,
          permiteReintentar: false,
        );
      }
    } else if (profile == PerfilSage.alumnos) {
      _reportPreparation(
        const EstadoPreparacionSageLaboratorio(
          mensaje: 'Perfil Estudiante listo. Abrí Nivel Superior - Historial.',
        ),
      );
      _startStudentAutomaticLanding(transitionId);
    } else {
      _reportPreparation(
        const EstadoPreparacionSageLaboratorio(
          mensaje: 'La sincronización personal requiere el perfil Estudiante.',
          bloqueado: true,
        ),
      );
      _cancelStudentAutomaticLanding();
    }

    if (kDebugMode) {
      debugPrint(
        '[SAGE perfil] target=${profile.clave}; confirmed=true; '
        'destination=${profile == PerfilSage.alumnos ? 'legajo_unico_alumno_auto' : 'home'}',
      );
    }
    _scheduleProfileLandingProbes(transitionId);
  }

  void _failProfileSelection(String message, int transitionId) {
    if (!mounted || transitionId != _profileTransitionId) return;
    _stopProfileSwitchWatchdog();
    final failedTarget = _profileSwitchTarget ?? PerfilSage.alumnos;
    _profileSwitchTarget = null;
    _ensureProbeTimer();
    if (_automaticMode) {
      _manualNavigationActive = false;
      setState(() {
        _profileSwitchBusy = false;
        _profileHomeResetBusy = false;
        _nativeLoadingVisible = false;
        _nativeProfileSelectorVisible = false;
        _profileError = message;
      });
      _scheduleAutomaticStepRetry(
        step: PasoSincronizacionSageAutomatica.perfil,
        message: message,
        code: CodigoErrorSincronizacionSage.cambioPerfil,
        action: () => _selectProfile(failedTarget),
      );
      return;
    }
    _manualNavigationActive = true;
    setState(() {
      _profileSwitchBusy = false;
      _profileHomeResetBusy = false;
      _nativeLoadingVisible = false;
      _nativeProfileSelectorVisible = true;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _profileError = message;
    });
    unawaited(_refreshProfileSelector(preserveError: true));
  }

  Future<bool> _hasStudentHomeSignature() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const normalize = value => String(value || '').toLowerCase()
          .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ').trim();
        const seen = new Set();
        const visit = win => {
          if (!win || seen.has(win)) return false;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return false; }
          const path = String(win.location.pathname || '').toLowerCase();
          const body = normalize(doc.body?.innerText || '');
          const isHome = path === '/pregase/menuprincipal_nuevo.php' &&
            body.includes('modulos');
          if (isHome && [...doc.querySelectorAll('a,button,[role="button"]')]
              .some(node => normalize(node.textContent) === 'legajo unico alumno')) {
            return true;
          }
          return [...doc.querySelectorAll('iframe')].some(frame => {
            try { return visit(frame.contentWindow); } catch (_) { return false; }
          });
        };
        return visit(window);
      })()''');
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      return value == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _confirmProfileChange(
    PerfilSage profile, {
    required int transitionId,
  }) async {
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    var attempts = 0;
    while (DateTime.now().isBefore(deadline)) {
      attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (_isClosing || !mounted || transitionId != _profileTransitionId) {
        return false;
      }

      try {
        if (profile == PerfilSage.agente) {
          final portada = await ExtractorAgenteSage(
            _evaluateJavascript,
          ).extraer();
          if (portada?.modulos.any(
                (item) => item.claveCanonica == 'legajo_unico_personal',
              ) ==
              true) {
            _portadaAgente = portada!;
            if (kDebugMode) {
              debugPrint(
                '[SAGE perfil] target=agente; confirmed=agent_home; attempts=$attempts',
              );
            }
            return true;
          }
        } else {
          final hasStudentSignature = await _hasStudentHomeSignature();
          if (hasStudentSignature) {
            if (kDebugMode) {
              debugPrint(
                '[SAGE perfil] target=alumnos; confirmed=student_home; attempts=$attempts',
              );
            }
            return true;
          }
        }

        final capture = await _probeProfiles(openPanelIfNeeded: attempts >= 4);
        _profileCapture = capture;
        if (capture.activo == profile) {
          if (kDebugMode) {
            debugPrint(
              '[SAGE perfil] target=${profile.clave}; confirmed=radio; attempts=$attempts',
            );
          }
          return true;
        }
      } catch (_) {
        // La página puede destruir el contexto JavaScript mientras recarga.
      }
    }
    if (kDebugMode) {
      debugPrint(
        '[SAGE perfil] target=${profile.clave}; confirmed=false; timeout=true',
      );
    }
    return false;
  }

  void _handleAgentOption(OpcionAgenteSage option) {
    if (option.claveCanonica == 'legajo_unico_alumno_superior') {
      unawaited(_openAgentStudentMenu());
      return;
    }
    _showUnavailableFeature(option.etiqueta);
  }

  Future<void> _openAgentStudentMenu() async {
    if (_navigationActionInFlight != null) return;
    setState(() {
      _navigationActionInFlight = 'Legajo Único Alumno';
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Abriendo Legajo Único Alumno…';
    });
    final menu = await ExtractorAgenteSage(
      _evaluateJavascript,
    ).extraerLegajoUnicoAlumno();
    if (!mounted) return;
    if (!menu.disponible) {
      setState(() {
        _navigationActionInFlight = null;
        _nativeLoadingVisible = false;
        _nativeAgentHomeVisible = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SAGE no mostró las opciones de Legajo Único Alumno.'),
        ),
      );
      return;
    }
    _manualNavigationActive = true;
    setState(() {
      _agentStudentOptions = menu.opciones;
      _navigationActionInFlight = null;
      _nativeLoadingVisible = false;
      _nativeAgentStudentMenuVisible = true;
    });
  }

  Future<void> _activateAgentStudentOption(OpcionAgenteSage option) async {
    if (option.claveCanonica != 'legajo_alumnos') {
      _showUnavailableFeature(option.etiqueta);
      return;
    }
    if (_navigationActionInFlight != null) return;
    _manualNavigationActive = false;
    _navigationOriginSignature = _lastNavigationResult?.firma;
    _navigationOriginState = _lastNavigationResult?.estado;
    _navigationOriginPath = _lastNavigationResult?.documentoActivo?.pathname;
    _navigationActionStartedAt = DateTime.now();
    setState(() {
      _navigationActionInFlight = option.etiqueta;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Abriendo ${option.etiqueta}…';
    });

    final result = await EjecutorShellAgenteSage(
      _evaluateJavascript,
    ).abrirOpcionLegajoAlumno(option);
    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _navigationActionInFlight = null;
        _nativeLoadingVisible = false;
        _nativeAgentStudentMenuVisible = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir ${option.etiqueta} en SAGE.')),
      );
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[SAGE agente] lua_option=${option.claveCanonica}; '
        'found=${result.found}; activated=${result.activated}; '
        'menu_found=${result.menuFound}; matched_by=${result.matchedBy}',
      );
    }
    _navigationAwaitingTransition = true;
    _scheduleNavigationProbe();
    unawaited(_installNavigationObservers());
  }

  Future<bool> _hasRealSageHomeDocument() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const normalize = value => String(value || '')
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ')
          .trim();
        const seen = new Set();
        const visit = win => {
          if (!win || seen.has(win)) return false;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return false; }
          const path = String(win.location.pathname || '').toLowerCase();
          if (path === '/pregase/menuprincipal_nuevo.php') {
            const body = normalize(doc.body?.innerText || '');
            if (body.includes('modulos') ||
                doc.querySelector(
                  'a.dropdown-item.menuPadre,a.menu-mobile-item',
                )) {
              return true;
            }
          }
          return [...doc.querySelectorAll('iframe')].some(frame => {
            try { return visit(frame.contentWindow); } catch (_) { return false; }
          });
        };
        return visit(window);
      })()''');
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      return value == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _returnRealSageToHome(int transitionId) async {
    if (await _hasRealSageHomeDocument()) return true;

    var dispatched = false;
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const normalize = value => String(value || '')
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ')
          .trim();
        const seen = new Set();
        const contexts = [];
        const visit = (win, depth = 0) => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          contexts.push({win, doc, depth});
          doc.querySelectorAll('iframe').forEach(frame => {
            try { visit(frame.contentWindow, depth + 1); } catch (_) {}
          });
        };
        visit(window);
        contexts.sort((a, b) => b.depth - a.depth);
        for (const context of contexts) {
          const links = [...context.doc.querySelectorAll(
            'a.camino-link[href],a[href]'
          )];
          const link = links.find(node => {
            if (normalize(node.textContent) !== 'inicio') return false;
            try {
              return new URL(
                node.getAttribute('href') || '',
                context.win.location.href,
              ).pathname.toLowerCase() ===
                  '/pregase/menuprincipal_nuevo.php';
            } catch (_) {
              return false;
            }
          });
          if (!link) continue;
          context.win.setTimeout(() => {
            try { link.click(); } catch (_) {}
          }, 0);
          return JSON.stringify({
            found:true,
            dispatched:true,
            stage:'home_breadcrumb_click_scheduled',
          });
        }
        return JSON.stringify({
          found:false,
          dispatched:false,
          stage:'home_breadcrumb_not_found',
        });
      })()''');
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        dispatched = value['dispatched'] == true;
        if (kDebugMode) {
          debugPrint(
            '[SAGE perfil] reset_home_stage=${value['stage']}; '
            'found=${value['found']}; dispatched=$dispatched',
          );
        }
      }
    } catch (_) {
      dispatched = false;
    }

    if (!dispatched) return false;

    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted ||
          _isClosing ||
          transitionId != _profileTransitionId ||
          !_profileHomeResetBusy) {
        return false;
      }
      if (await _hasRealSageHomeDocument()) {
        if (kDebugMode) {
          debugPrint('[SAGE perfil] reset_home_confirmed=true');
        }
        return true;
      }
    }
    if (kDebugMode) {
      debugPrint('[SAGE perfil] reset_home_confirmed=false; timeout=true');
    }
    return false;
  }

  Future<void> _requestProfileSelector() async {
    _cancelStudentAutomaticLanding();
    if (!mounted ||
        _profileSwitchBusy ||
        _profileHomeResetBusy ||
        _logoutBusy) {
      return;
    }

    if (await _hasRealSageHomeDocument()) {
      _showProfileSelector();
      return;
    }

    final transitionId = ++_profileTransitionId;
    _stopProfileSwitchWatchdog();
    _profileSwitchTarget = null;
    _ensureProbeTimer();
    _manualNavigationActive = true;
    setState(() {
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _profileHomeResetBusy = true;
      _profileError = null;
      _nativeProfileSelectorVisible = false;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Volviendo al inicio de SAGE…';
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _navigationActionStartedAt = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
      _historyAutoLoadRunning = false;
      _historyNeedsFreshDom = true;
      _history = null;
      _historyState = EstadoHistorialSage.esperandoPagina;
      _historyAutoAttemptedCareerIds.clear();
    });

    final returnedHome = await _returnRealSageToHome(
      transitionId,
    ).timeout(const Duration(seconds: 14), onTimeout: () => false);

    if (!mounted ||
        transitionId != _profileTransitionId ||
        !_profileHomeResetBusy) {
      return;
    }

    if (returnedHome) {
      _showProfileSelector();
      return;
    }

    _showProfileSelector(
      error:
          'SAGE no pudo volver a su pantalla inicial. '
          'Podés reintentar el cambio de perfil.',
    );
  }

  void _showProfileSelector({String? error}) {
    if (!mounted) return;

    _cancelStudentAutomaticLanding();
    _profileTransitionId++;
    _stopProfileSwitchWatchdog();
    _profileSwitchTarget = null;
    _ensureProbeTimer();
    _manualNavigationActive = true;
    setState(() {
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _profileChoiceMade = false;
      _profileSwitchBusy = false;
      _profileHomeResetBusy = false;
      _profileSelectorPreparing = true;
      _authTransitionCoverVisible = true;
      _authTransitionCoverMessage = 'Preparando selector de perfil…';
      _profileError = error;
      _nativeProfileSelectorVisible = false;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = false;
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _navigationActionStartedAt = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
    });
    unawaited(_refreshProfileSelector(preserveError: error != null));
  }

  Future<void> _refreshProfileSelector({bool preserveError = false}) async {
    CapturaPerfilesSage capture;
    try {
      capture = await _probeProfiles(
        openPanelIfNeeded: true,
      ).timeout(const Duration(seconds: 8));
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _profileSelectorPreparing = false;
        _nativeProfileSelectorVisible = true;
        if (!preserveError) {
          _profileError =
              'SAGE tardó demasiado en mostrar los perfiles disponibles.';
        }
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _profileSelectorPreparing = false;
        _nativeProfileSelectorVisible = true;
        if (!preserveError) {
          _profileError = 'No se pudieron leer los perfiles de SAGE.';
        }
      });
      return;
    }

    if (!mounted ||
        _profileSwitchBusy ||
        _profileHomeResetBusy ||
        _logoutBusy) {
      return;
    }
    setState(() {
      _profileSelectorPreparing = false;
      _nativeProfileSelectorVisible = true;
      _profileCapture = capture;
      _selectedProfile = capture.activo ?? _selectedProfile;
      if (!preserveError) {
        _profileError = capture.perfiles.length < 2
            ? 'SAGE no expuso los dos perfiles disponibles.'
            : null;
      }
    });
  }

  void _exitSageToAppHome() {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    try {
      final onClose = widget.onClose;
      if (onClose != null) {
        onClose();
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      _isClosing = false;
    }
  }

  void _resetPrivateSageStateForLogin() {
    _cancelStudentAutomaticLanding();
    _cancelLoginTransitionWatchdog();
    _profileTransitionId++;
    _profileSwitchTarget = null;
    _privateSageShellActive = false;
    _showOriginalWebView = !_automaticMode;
    _nativeHistoryVisible = false;
    _nativeModulesVisible = false;
    _nativeSubmodulesVisible = false;
    _nativeLegajoVisible = false;
    _nativeSeccionesLegajoVisible = false;
    _nativeEscolaresVisible = false;
    _nativeLoadingVisible = false;
    _nativeAgentHomeVisible = false;
    _nativeAgentPersonalVisible = false;
    _nativeAgentStudentMenuVisible = false;
    _nativeProfileSelectorVisible = false;
    _profileChoiceMade = false;
    _profileSwitchBusy = false;
    _profileHomeResetBusy = false;
    _logoutBusy = false;
    _profileSelectorPreparing = false;
    _authCoverReleaseScheduled = false;
    _authTransitionCoverVisible = false;
    _authTransitionCoverMessage = 'Cargando SAGE…';
    _loginDocumentReady = true;
    _selectedProfile = null;
    _profileCapture = null;
    _profileError = null;
    _portadaAgente = const PortadaAgenteSage();
    _agentPersonalOptions = const [];
    _agentStudentOptions = const [];
    _manualNavigationActive = false;
    _nativeLoadingMessage = 'Preparando tus servicios académicos…';
    _navigationActionInFlight = null;
    _lastNavigationResult = null;
    _navigationOriginSignature = null;
    _navigationOriginState = null;
    _navigationOriginPath = null;
    _navigationActionStartedAt = null;
    _navigationAwaitingTransition = false;
    _legajoExtraction = null;
    _legajoActionInFlight = null;
    _legajoOriginSignature = null;
    _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
    _usuarioSolicitoEscolares = false;
    _historyState = EstadoHistorialSage.esperandoPagina;
    _history = null;
    _historyAutoLoadRunning = false;
    _historyNeedsFreshDom = false;
    _reportInFlight = false;
    _selectedStudentRecord = null;
    _lastTrajectorySignature = null;
    _historyAutoAttemptedCareerIds.clear();
    if (_automaticMode) {
      _automaticRunId++;
      _automaticWatchdog?.cancel();
      _automaticRetryTimer?.cancel();
      _automaticFlowActive = false;
      _automaticActionBusy = false;
      _automaticCredentialsBusy = false;
      _automaticProfileMisses = 0;
      _automaticCompleting = false;
      _automaticDocumentsPreparing = false;
      _automaticDocumentRequestRunning = false;
      _automaticDocumentRequestCompleted = false;
      _automaticSessionReused = false;
      _automaticStepAttempts.clear();
      _automaticState = const EstadoSincronizacionSageAutomatica(
        etapa: EtapaSincronizacionSageAutomatica.credenciales,
        titulo: 'Conectar con SAGE',
        paso: PasoSincronizacionSageAutomatica.sesion,
      );
    }
  }

  Future<void> _confirmAndLogoutSage() async {
    if (!mounted ||
        _logoutBusy ||
        _profileSwitchBusy ||
        _profileHomeResetBusy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            'Vas a volver a la pantalla de inicio de sesión de SAGE.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _logoutSage();
    }
  }

  Future<Map<String, dynamic>> _dispatchLogoutDomStep() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const normalize = value => String(value || '')
          .toLowerCase()
          .normalize('NFD')
          .replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ')
          .trim();
        const seen = new Set();
        const contexts = [];
        const visit = (win, depth = 0) => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          contexts.push({win, doc, depth});
          doc.querySelectorAll('iframe').forEach(frame => {
            try { visit(frame.contentWindow, depth + 1); } catch (_) {}
          });
        };
        visit(window);
        contexts.sort((a, b) => a.depth - b.depth);

        for (const context of contexts) {
          const links = [...context.doc.querySelectorAll('a[href]')];
          const target = links.find(node => {
            let path = '';
            try {
              path = new URL(
                node.getAttribute('href') || '',
                context.win.location.href,
              ).pathname.toLowerCase();
            } catch (_) {
              return false;
            }
            if (path !== '/pregase/cierre_session.php') return false;
            const label = normalize(node.textContent);
            return label === 'cerrar sesion' ||
              node.classList.contains('btn-danger');
          });
          if (!target) continue;
          context.win.setTimeout(() => {
            try { target.click(); } catch (_) {}
          }, 0);
          return JSON.stringify({
            found:true,
            dispatched:true,
            panelDispatched:false,
            stage:'logout_click_scheduled',
            pathname:'/pregase/cierre_session.php',
          });
        }

        for (const context of contexts) {
          const userButton = context.doc.querySelector('button.btn.btn-user');
          if (!userButton) continue;
          try {
            userButton.click();
            return JSON.stringify({
              found:false,
              dispatched:false,
              panelDispatched:true,
              stage:'user_panel_click_dispatched',
            });
          } catch (_) {}
        }

        return JSON.stringify({
          found:false,
          dispatched:false,
          panelDispatched:false,
          stage:'logout_control_not_found',
        });
      })()''');

      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        return value.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {
      // El resultado estructurado de error se devuelve debajo.
    }
    return const {
      'found': false,
      'dispatched': false,
      'panelDispatched': false,
      'stage': 'logout_script_error',
    };
  }

  Future<bool> _dispatchOfficialLogoutControl() async {
    var result = await _dispatchLogoutDomStep();
    if (kDebugMode) {
      debugPrint(
        '[SAGE sesión] stage=${result['stage']}; '
        'found=${result['found']}; dispatched=${result['dispatched']}; '
        'panel_dispatched=${result['panelDispatched']}',
      );
    }
    if (result['dispatched'] == true) return true;

    if (result['panelDispatched'] == true) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      result = await _dispatchLogoutDomStep();
      if (kDebugMode) {
        debugPrint(
          '[SAGE sesión] retry_stage=${result['stage']}; '
          'found=${result['found']}; dispatched=${result['dispatched']}',
        );
      }
      return result['dispatched'] == true;
    }
    return false;
  }

  void _scheduleLogoutOnOpen(Uri? uri) {
    if (!widget.logoutOnOpen ||
        _logoutOnOpenHandled ||
        uri == null ||
        _isLoginUri(uri) ||
        !uri.path.toLowerCase().startsWith('/pregase/')) {
      return;
    }
    _logoutOnOpenHandled = true;
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted || _isClosing || _logoutBusy) return;
      unawaited(_logoutSage());
    });
  }

  bool _isLoginUri(Uri? uri) {
    if (uri == null || uri.host.toLowerCase() != 'sage.entrerios.gov.ar') {
      return false;
    }
    final path = uri.path.toLowerCase();
    return path == '/login' || path.startsWith('/login/');
  }

  Future<bool> _waitForLoginAfterLogout(int transitionId) async {
    final deadline = DateTime.now().add(const Duration(seconds: 16));
    while (DateTime.now().isBefore(deadline)) {
      if (!mounted || _isClosing || transitionId != _logoutTransitionId) {
        return false;
      }
      final current = Uri.tryParse(await _controller.currentUrl() ?? '');
      if (_isLoginUri(current) && _loginDocumentReady) return true;
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    final current = Uri.tryParse(await _controller.currentUrl() ?? '');
    return _isLoginUri(current) && _loginDocumentReady;
  }

  Future<void> _logoutSage() async {
    _cancelStudentAutomaticLanding();
    _cancelLoginTransitionWatchdog();
    if (!mounted ||
        _logoutBusy ||
        _profileSwitchBusy ||
        _profileHomeResetBusy) {
      return;
    }

    final transitionId = ++_logoutTransitionId;
    _stopProfileSwitchWatchdog();
    _profileSwitchTarget = null;
    setState(() {
      _logoutBusy = true;
      _authTransitionCoverVisible = true;
      _authTransitionCoverMessage = 'Cerrando sesión…';
      _loginDocumentReady = false;
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Cerrando sesión…';
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
    });

    final dispatched = await _dispatchOfficialLogoutControl().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (!mounted || transitionId != _logoutTransitionId) return;

    if (!dispatched) {
      setState(() {
        _logoutBusy = false;
        _authTransitionCoverVisible = false;
        _nativeLoadingVisible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'SAGE no mostró el control oficial para cerrar la sesión.',
          ),
        ),
      );
      return;
    }

    final confirmed = await _waitForLoginAfterLogout(transitionId);
    if (!mounted || transitionId != _logoutTransitionId) return;

    if (confirmed) {
      _stopProfileSwitchWatchdog();
      await _syncStateRepository.registrarSesionCerrada();
      widget.onSesionCerrada?.call();
      setState(_resetPrivateSageStateForLogin);
      if (kDebugMode) {
        debugPrint('[SAGE sesión] logout_confirmed=true; pathname=/login/');
      }
      return;
    }

    setState(() {
      _logoutBusy = false;
      _authTransitionCoverVisible = false;
      _nativeLoadingVisible = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'SAGE no confirmó el cierre de sesión. Podés volver a intentarlo.',
        ),
      ),
    );
    if (kDebugMode) {
      debugPrint('[SAGE sesión] logout_confirmed=false; timeout=true');
    }
  }

  void _showAgentHome() {
    if (!mounted) return;
    _manualNavigationActive = true;
    setState(() {
      _nativeAgentHomeVisible = true;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeProfileSelectorVisible = false;
      _nativeLoadingVisible = false;
      _navigationActionInFlight = null;
    });
  }

  void _activateAgentOption(OpcionAgenteSage option) {
    _showUnavailableFeature(option.etiqueta);
  }

  Future<ResultadoExtraccionLegajoSage?> _probeLegajoIfRelevant(
    ResultadoDeteccionNavegacionSage result,
  ) async {
    final path = result.documentoActivo?.pathname.toLowerCase() ?? '';
    final relevant =
        path == '/dic/listar2.php' ||
        path == '/dic/tabs.php' ||
        result.documentoActivo?.frameId.toLowerCase() ==
            'frm_alumnos_escolares' ||
        result.estado == EstadoNavegacionSage.listadoLegajos ||
        result.estado == EstadoNavegacionSage.seccionesLegajo ||
        result.estado == EstadoNavegacionSage.escolares ||
        _nativeLegajoVisible ||
        _nativeSeccionesLegajoVisible ||
        _nativeEscolaresVisible ||
        _tipoAccionLegajo != TipoAccionLegajoSage.ninguna ||
        _navigationAwaitingTransition;
    if (!relevant) return null;
    final extraction = await ExtractorLegajoSage(_evaluateJavascript).extraer();
    _legajoExtraction = extraction;
    if (kDebugMode && extraction.etapa != EtapaLegajoSage.ninguna) {
      debugPrint(
        '[SAGE legajo] stage=${extraction.etapa.name}; '
        'state=${extraction.estado.name}; frame=${extraction.frameId}; '
        'path=${extraction.pathname}; profiles=${extraction.perfiles.length}; '
        'sections=${extraction.secciones.length}; '
        'school_options=${extraction.opcionesEscolares.length}',
      );
      if (extraction.etapa == EtapaLegajoSage.escolares) {
        debugPrint(
          '[SAGE escolares detect] parent_found=${extraction.parentFrameFound}; '
          'parent_path=${extraction.pathname}; '
          'child_found=${extraction.childFrameFound}; '
          'child_ready=${extraction.childReady}; '
          'child_path=${extraction.childPathname}; '
          'tabs_count=${extraction.opcionesEscolares.length}; '
          'historial_alumnado_found=${extraction.opcionesEscolares.any((option) => normalizarLegajoSage(option.titulo) == 'historial del alumnado')}; '
          'nivel_superior_historial_found=${extraction.opcionesEscolares.any((option) => normalizarLegajoSage(option.titulo) == 'nivel superior - historial')}; '
          'state=escolaresDisponible',
        );
      }
      if (extraction.etapa == EtapaLegajoSage.secciones ||
          extraction.etapa == EtapaLegajoSage.escolares) {
        debugPrint(
          '[SAGE secciones detect] tabs_found=true; '
          'tabs_frame=${extraction.frameId}; tabs_path=${extraction.pathname}; '
          'extracted_sections=${extraction.secciones.length}; '
          'school_control_found=${extraction.historyControlFound}; '
          'school_child_exists=${extraction.childFrameFound}; '
          'user_requested_school=$_usuarioSolicitoEscolares; '
          'native_sections_visible=$_nativeSeccionesLegajoVisible; '
          'web_visible=${webViewSageVisible(historial: _nativeHistoryVisible, modulos: _nativeModulesVisible, submodulos: _nativeSubmodulesVisible, carga: _nativeLoadingVisible, legajo: _nativeLegajoVisible, secciones: _nativeSeccionesLegajoVisible, escolares: _nativeEscolaresVisible)}',
        );
      }
    }
    return extraction;
  }

  void _applyLegajoResult(ResultadoExtraccionLegajoSage? extraction) {
    if (extraction == null) return;
    if (extraction.estado == EstadoExtraccionLegajoSage.cargando) {
      if (!_nativeHistoryVisible) {
        _nativeLoadingVisible = true;
        _nativeLoadingMessage = 'Preparando la información de tu legajo…';
      }
      return;
    }
    if (!extraction.disponible) return;
    _navigationActionInFlight = null;
    _legajoActionInFlight = null;
    _nativeLoadingVisible = false;
    _nativeModulesVisible = false;
    _nativeSubmodulesVisible = false;
    switch (extraction.etapa) {
      case EtapaLegajoSage.miLegajo:
        _nativeLegajoVisible = true;
        _nativeSeccionesLegajoVisible = false;
        _nativeEscolaresVisible = false;
      case EtapaLegajoSage.secciones:
        _nativeLegajoVisible = false;
        _nativeSeccionesLegajoVisible = true;
        _nativeEscolaresVisible = false;
      case EtapaLegajoSage.escolares:
        _nativeLegajoVisible = false;
        if (_usuarioSolicitoEscolares) {
          _nativeSeccionesLegajoVisible = false;
          _nativeEscolaresVisible = true;
        } else {
          _nativeSeccionesLegajoVisible = true;
          _nativeEscolaresVisible = false;
        }
      case EtapaLegajoSage.ninguna:
        break;
    }
  }

  Future<void> _probeHistoryAndApply() async {
    if (_historyProbeRunning || _isClosing) return;
    _historyProbeRunning = true;
    try {
      final result = await _historialController.cargar(
        _evaluateJavascript,
        timeout: const Duration(seconds: 3),
      );
      if (kDebugMode) {
        debugPrint(
          '[SAGE historial] extraction_state=${result.estado.name}; '
          'frame_detected=${result.pantallaDetectada}; '
          'master_loader_visible=${result.masterLoaderVisible}; '
          'career_row_count=${result.careerRowCount}',
        );
      }
      if (!mounted) return;
      if (_profileSwitchBusy ||
          _profileHomeResetBusy ||
          _nativeProfileSelectorVisible) {
        return;
      }
      if (_manualNavigationActive &&
          !_navigationAwaitingTransition &&
          !_nativeLoadingVisible) {
        return;
      }
      if (result.pantallaDetectada) {
        setState(() {
          _navigationAwaitingTransition = false;
          _navigationActionInFlight = null;
          _legajoActionInFlight = null;
          _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
          _usuarioSolicitoEscolares = false;
          _legajoOriginSignature = null;
          _nativeModulesVisible = false;
          _nativeSubmodulesVisible = false;
          _nativeLegajoVisible = false;
          _nativeSeccionesLegajoVisible = false;
          _nativeEscolaresVisible = false;
          _nativeLoadingVisible = false;
          if (result.historial != null) {
            _history = _historyNeedsFreshDom
                ? result.historial!
                : _mergeMasterHistory(result.historial!);
            _historyNeedsFreshDom = false;
          }
          _historyState = result.estado;
          _nativeHistoryVisible = true;
        });
        if (kDebugMode) {
          debugPrint('[SAGE historial] frame_detected');
          debugPrint('[SAGE historial] native_view_visible=true');
        }
        final careers = _history?.carreras;
        if (_effectiveProfile != PerfilSage.alumnos) {
          _reportPreparation(
            const EstadoPreparacionSageLaboratorio(
              mensaje:
                  'La sincronización personal requiere el perfil Estudiante.',
              bloqueado: true,
            ),
          );
        } else if (result.estado == EstadoHistorialSage.disponible &&
            careers != null &&
            careers.isNotEmpty) {
          _reportPreparation(
            EstadoPreparacionSageLaboratorio(
              mensaje: _documentDownloadMode
                  ? 'Historial detectado. Preparando el documento…'
                  : 'Historial detectado. Preparando ${careers.length} carrera(s)…',
              progreso: 0,
            ),
          );
          if (_documentDownloadMode) {
            unawaited(_tryDownloadRequestedDocument());
          } else {
            unawaited(_autoLoadAllCareers(careers));
          }
        }
      } else if (!_nativeHistoryVisible &&
          result.estado != EstadoHistorialSage.esperandoPagina) {
        setState(() => _historyState = result.estado);
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint('[SAGE] historial probe: error de evaluación');
      }
      if (mounted && !_nativeHistoryVisible) {
        setState(() => _historyState = EstadoHistorialSage.error);
      }
    } finally {
      _historyProbeRunning = false;
    }
  }

  Future<ResultadoDeteccionNavegacionSage> _probeSageNavigation() async {
    try {
      final raw = await _evaluateJavascript(r'''(() => {
        const root = window;
        const known = /(modulo|submodulo|legajo|certificado|inscrip|consulta|tutor|alumno|ingresar|sesion|escolares|personal|servicio|nivel|historial)/i;
        const output = {host:'', pathname:'', hasMain:false, headings:[], links:[], documents:[]};
        const seen = new Set();
        const visit = (win, depth = 0, frameId = 'root', frameName = '', isRoot = false) => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          if (!doc) return;
          try {
            const host = String(win.location.hostname || '');
            const pathname = String(win.location.pathname || '');
            const normalize = value => String(value || '')
              .toLowerCase()
              .normalize('NFD')
              .replace(/[\u0300-\u036f]/g, '')
              .replace(/\s+/g, ' ')
              .trim();
            const hasList2 = Boolean(doc.querySelector('#list2'));
            const hasTabs = pathname.toLowerCase() === '/dic/tabs.php';
            const hasSchoolFrame = String(frameId).toLowerCase() === 'frm_alumnos_escolares';
            const hasHistoryOption = [...doc.querySelectorAll('a.tab_a,a[href],button,[role="button"],[onclick],td,li')]
              .some(node => normalize(node.textContent || node.value).includes('nivel superior - historial'));
            let visible = true;
            if (!isRoot) {
              const frame = win.frameElement;
              const rect = frame?.getBoundingClientRect?.();
              const style = frame ? getComputedStyle(frame) : null;
              visible = Boolean(
                frame && style?.display !== 'none' &&
                style?.visibility !== 'hidden' &&
                Number(style?.opacity ?? 1) !== 0 && rect &&
                rect.width > 0 && rect.height > 0,
              );
            }
            const headings = [];
            const links = [];
            if (isRoot) {
              output.host = host;
              output.pathname = pathname;
              output.hasMain = Boolean(doc.querySelector('iframe#Main'));
            }
            doc.querySelectorAll('h1,h2,h3,h4,.ui-widget-header,.titulo').forEach(node => {
              const text = String(node.textContent || '').replace(/\s+/g,' ').trim();
              if (text && known.test(text)) headings.push(text.slice(0,120));
            });
            const title = String(doc.title || '').replace(/\s+/g,' ').trim();
            if (title && known.test(title)) headings.push(title.slice(0,120));
            doc.querySelectorAll('*').forEach(node => {
              const text = normalize(node.textContent);
              if (text === 'modulos' || text === 'submodulos') {
                headings.push(text);
              }
            });
            doc
              .querySelectorAll(
                'a[href],[onclick],button,[role="button"],td,li,div,span',
              )
              .forEach(anchor => {
              const text = String(anchor.textContent || '').replace(/\s+/g,' ').trim();
              if (!text || !known.test(text)) return;
              let parsed;
              try { parsed = new URL(anchor.getAttribute('href') || win.location.href, win.location.href); } catch (_) { return; }
              const sameHost = parsed.hostname.toLowerCase() === host.toLowerCase();
              if (!sameHost && parsed.hostname) return;
              links.push({text:text.slice(0,160), pathname:parsed.pathname, hrefValid:true});
            });
            output.documents.push({
              host, pathname, frameId, frameName, depth, visible,
              hasList2, hasTabs, hasSchoolFrame, hasHistoryOption,
              headings:[...new Set(headings)], links:links.slice(0,80),
            });
            doc.querySelectorAll('iframe').forEach((frame, index) => {
              try {
                const childId = String(frame.id || `iframe-${depth + 1}-${index}`);
                const childName = String(frame.name || '');
                visit(frame.contentWindow, depth + 1, childId, childName);
              } catch (_) {}
            });
          } catch (_) {}
        };
        visit(root, 0, 'root', '', true);
        output.headings = [...new Set(output.headings)];
        output.links = output.documents.flatMap(document => document.links).slice(0,80);
        return JSON.stringify(output);
      })()''');
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is! Map) {
        return const ResultadoDeteccionNavegacionSage(
          estado: EstadoNavegacionSage.desconocido,
          documentoActivo: null,
          firma: '',
          shellPrivado: false,
        );
      }
      final capture = CapturaNavegacionSage.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      final result = _navigationDetector.detectarResultado(capture);
      _lastNavigationResult = result;
      if (kDebugMode) {
        debugPrint(
          '[SAGE navegación] selected_path=${result.documentoActivo?.pathname ?? '/'}; '
          'selected_frame=${result.documentoActivo?.frameId ?? 'root'}; '
          'documents=${capture.documentos.length}; state=${result.estado.name}; '
          'signature=${result.firma}',
        );
      }
      return result;
    } catch (_) {
      return const ResultadoDeteccionNavegacionSage(
        estado: EstadoNavegacionSage.error,
        documentoActivo: null,
        firma: '',
        shellPrivado: false,
      );
    }
  }

  Future<bool> _activateSageLink(OpcionSubmoduloSage option) async {
    if (!_isImplementedWebOption(option)) {
      _showUnavailableFeature(option.titulo);
      return false;
    }
    if (_navigationActionInFlight != null) return false;
    _manualNavigationActive = false;
    final activeDocument = _lastNavigationResult?.documentoActivo;
    _navigationOriginSignature = _lastNavigationResult?.firma;
    _navigationOriginState = _lastNavigationResult?.estado;
    _navigationOriginPath = activeDocument?.pathname;
    _navigationActionStartedAt = DateTime.now();
    _navigationAwaitingTransition = false;
    setState(() {
      _navigationActionInFlight = option.titulo;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeProfileSelectorVisible = false;
      _profileSwitchBusy = false;
      _profileError = null;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Abriendo ${option.titulo}…';
    });
    final labels = <String>[option.titulo, ...option.etiquetasAlternativas];
    final normalizedLabels = labels.map(DetectorNavegacionSage.normalizar);
    final domPathCandidates = activeDocument?.enlaces.where((link) {
      if (!link.hrefValido || link.pathname.isEmpty) return false;
      final text = DetectorNavegacionSage.normalizar(link.texto);
      return normalizedLabels.any(
        (label) => text == label || text.contains(label),
      );
    }).toList();
    domPathCandidates?.sort((a, b) {
      final aText = DetectorNavegacionSage.normalizar(a.texto);
      final bText = DetectorNavegacionSage.normalizar(b.texto);
      final aExact = normalizedLabels.contains(aText) ? 1 : 0;
      final bExact = normalizedLabels.contains(bText) ? 1 : 0;
      return bExact.compareTo(aExact) != 0
          ? bExact.compareTo(aExact)
          : aText.length.compareTo(bText.length);
    });
    final nonCurrentDomPathCandidates = domPathCandidates
        ?.where(
          (candidate) =>
              candidate.pathname.toLowerCase() !=
              activeDocument?.pathname.toLowerCase(),
        )
        .toList();
    final domPathCandidate =
        nonCurrentDomPathCandidates != null &&
            nonCurrentDomPathCandidates.isNotEmpty
        ? nonCurrentDomPathCandidates.first
        : (domPathCandidates != null && domPathCandidates.isNotEmpty
              ? domPathCandidates.first
              : null);
    final officialPath = option.pathname ?? domPathCandidate?.pathname;
    final pathJson = jsonEncode(officialPath);
    final labelsJson = jsonEncode(labels);
    final documentJson = jsonEncode({
      'frameId': activeDocument?.frameId ?? '',
      'frameName': activeDocument?.frameName ?? '',
      'pathname': activeDocument?.pathname ?? '',
      'depth': activeDocument?.profundidad ?? 0,
    });
    try {
      final raw = await _evaluateJavascript('''(() => {
        const expectedPath = $pathJson;
        const expectedDocument = $documentJson;
        const labels = $labelsJson.map(value => String(value).toLowerCase()
          .normalize('NFD').replace(/[\\u0300-\\u036f]/g,'')
          .replace(/\\s+/g,' ').trim());
        const seen = new Set();
        const normalize = value => String(value || '').toLowerCase()
          .normalize('NFD').replace(/[\\u0300-\\u036f]/g,'')
          .replace(/\\s+/g,' ').trim();
        const documents = [];
        const collect = (win, depth = 0, frameId = 'root', frameName = '') => {
          if (!win || seen.has(win)) return;
          seen.add(win);
          let doc;
          try { doc = win.document; } catch (_) { return; }
          if (!doc) return;
          documents.push({
            win, doc, depth, frameId, frameName,
            pathname:String(win.location.pathname || ''),
          });
          doc.querySelectorAll('iframe').forEach((frame, index) => {
            try {
              collect(
                frame.contentWindow,
                depth + 1,
                String(frame.id || ('iframe-' + (depth + 1) + '-' + index)),
                String(frame.name || ''),
              );
            } catch (_) {}
          });
        };
        collect(window);
        const target = documents.find(item =>
          item.frameId === String(expectedDocument.frameId || '') &&
          item.frameName === String(expectedDocument.frameName || '') &&
          item.pathname.toLowerCase() === String(expectedDocument.pathname || '').toLowerCase() &&
          item.depth === Number(expectedDocument.depth || 0)
        );
        if (!target) return JSON.stringify({found:false, activated:false});
        const selector = [
          'a[href]', 'button', 'input[type="button"]',
          'input[type="submit"]', '[role="button"]', '[onclick]',
          'td', 'li', 'div'
        ].join(',');
        const actionableSelector = [
          'a[href]', 'button', 'input[type="button"]',
          'input[type="submit"]', '[role="button"]', '[onclick]'
        ].join(',');
        const nodeDepth = node => {
          let depth = 0;
          let current = node;
          while (current?.parentElement) {
            depth++;
            current = current.parentElement;
          }
          return depth;
        };
        const candidates = [];
        target.doc.querySelectorAll(selector).forEach(node => {
          const text = normalize(node.textContent || node.value);
          let parsed = null;
          try {
            const href = node.getAttribute?.('href');
            if (href) parsed = new URL(href, target.win.location.href);
          } catch (_) {}
          if (parsed?.hostname && parsed.hostname.toLowerCase() !== 'sage.entrerios.gov.ar') return;
          const pathMatch = Boolean(expectedPath && parsed &&
            parsed.pathname.toLowerCase() === String(expectedPath).toLowerCase());
          const exact = labels.some(label => text === label);
          const textMatch = labels.some(label => text.includes(label));
          if (!pathMatch && !textMatch) return;
          candidates.push({node, text, exact, pathMatch, depth:nodeDepth(node)});
        });
        candidates.sort((a, b) =>
          Number(b.exact) - Number(a.exact) ||
          Number(b.pathMatch) - Number(a.pathMatch) ||
          a.text.length - b.text.length ||
          b.depth - a.depth
        );
        if (!candidates.length) {
          return JSON.stringify({found:false, activated:false});
        }
        const resolveActionable = node => {
          if (node.matches?.(actionableSelector)) return node;
          const descendant = node.querySelector?.(actionableSelector);
          if (descendant) return descendant;
          const ancestor = node.closest?.(actionableSelector);
          if (ancestor) return ancestor;
          let current = node.parentElement;
          let levels = 0;
          while (current && levels < 5) {
            if (current.matches?.(actionableSelector)) return current;
            const jq = target.win.jQuery;
            if (jq && typeof jq._data === 'function') {
              const events = jq._data(current, 'events');
              if (events?.click?.length) return current;
            }
            current = current.parentElement;
            levels++;
          }
          return null;
        };
        const candidate = candidates[0];
        const actionable = resolveActionable(candidate.node);
        if (!actionable) {
          return JSON.stringify({found:true, activated:false});
        }
        let mechanism = null;
        let activated = false;
        const jq = target.win.jQuery;
        const jqEvents = jq && typeof jq._data === 'function'
          ? jq._data(actionable, 'events')
          : null;
        if (actionable.matches?.(actionableSelector)) {
          actionable.click();
          mechanism = 'native_click';
          activated = true;
        } else if (jqEvents?.click?.length) {
          jq(actionable).trigger('click');
          mechanism = 'jquery_click';
          activated = true;
        }
        return JSON.stringify({
          found:true,
          activated,
          mechanism,
          tag:String(actionable.tagName || '').toUpperCase(),
          frameId:target.frameId,
          pathnameBefore:target.pathname,
          matchedBy:candidate.exact ? 'exact_text' : (candidate.pathMatch ? 'pathname' : 'text'),
        });
      })()''');
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      final found = decoded is Map && decoded['found'] == true;
      final activated = decoded is Map && decoded['activated'] == true;
      final activationSucceeded = activacionNavegacionSageExitosa(
        found: found,
        activated: activated,
      );
      if (!mounted) return activationSucceeded;
      if (kDebugMode && decoded is Map) {
        debugPrint(
          '[SAGE acción] option=${option.titulo}; '
          'frame=${decoded['frameId'] ?? ''}; tag=${decoded['tag'] ?? ''}; '
          'mechanism=${decoded['mechanism'] ?? ''}; found=$found; '
          'activated=$activated; matched_by=${decoded['matchedBy'] ?? ''}',
        );
      }
      if (!activationSucceeded) {
        setState(() {
          _navigationActionInFlight = null;
          _nativeLoadingVisible = false;
        });
        unawaited(_showNavigationActionFailure(option));
        return false;
      }
      _navigationAwaitingTransition = true;
      _scheduleNavigationProbe();
      unawaited(_installNavigationObservers());
      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _navigationActionInFlight = null;
          _nativeLoadingVisible = false;
        });
        unawaited(_showNavigationActionFailure(option));
      }
      return false;
    }
  }

  Future<void> _showNavigationActionFailure(OpcionSubmoduloSage option) async {
    if (!mounted) return;
    if (_automaticMode) {
      final normalized = option.titulo.toLowerCase();
      final step = normalized.contains('legajo')
          ? PasoSincronizacionSageAutomatica.legajo
          : PasoSincronizacionSageAutomatica.historial;
      _scheduleAutomaticStepRetry(
        step: step,
        message: 'No se pudo abrir ${option.titulo} en SAGE.',
        code: step == PasoSincronizacionSageAutomatica.legajo
            ? CodigoErrorSincronizacionSage.abrirLegajo
            : CodigoErrorSincronizacionSage.abrirHistorial,
        action: () async {
          await _activateSageLink(option);
        },
      );
      return;
    }
    final retry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No se pudo abrir la opción'),
        content: const Text('No se pudo activar esta opción en SAGE.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _showOriginalNavigation();
            },
            child: const Text('Ver página original'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
    if (retry == true) unawaited(_activateSageLink(option));
  }

  void _openLegajoModule() {
    unawaited(
      _activateSageLink(
        const OpcionSubmoduloSage(
          titulo: 'Legajo Único Alumno',
          icono: 0xe151,
          pathname: '/pregase/menuprincipal_nuevo.php',
          etiquetasAlternativas: ['legajo unico alumno'],
        ),
      ),
    );
  }

  void _showOriginalNavigation() {
    if (!mounted) return;
    _manualNavigationActive = false;
    setState(() {
      _showOriginalWebView = true;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeProfileSelectorVisible = false;
      _nativeLoadingVisible = false;
      _legajoActionInFlight = null;
      _navigationActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
    });
  }

  List<SeccionLegajoSage> _seccionesDisponibles() {
    final result = <SeccionLegajoSage>[...?_legajoExtraction?.secciones];
    final hasSchool = result.any(
      (section) =>
          section.clave == 'escolares' ||
          normalizarLegajoSage(section.titulo) == 'escolares',
    );
    if (!hasSchool) {
      result.add(
        SeccionLegajoSage(
          clave: 'escolares',
          titulo: 'Escolares',
          firmaTecnica: 'contract:escolares',
          frameId: _legajoExtraction?.frameId ?? '',
          pathname: _legajoExtraction?.pathname ?? '/dic/tabs.php',
          controlEncontrado: false,
        ),
      );
    }
    return result;
  }

  Future<void> _activateLegajoProfile(PerfilLegajoSage profile) async {
    if (_legajoActionInFlight != null) return;
    _selectedStudentRecord = profile;
    _manualNavigationActive = false;
    _usuarioSolicitoEscolares = false;
    _beginLegajoAction('Abriendo tu legajo…', TipoAccionLegajoSage.abrirPerfil);
    final result = await EjecutorLegajoSage(
      _evaluateJavascript,
    ).abrirPerfil(profile);
    _logLegajoAction(result);
    if (!mounted) return;
    if (!result.success) {
      _usuarioSolicitoEscolares = false;
      _endLegajoAction();
      await _showLegajoActionFailure(
        'No se pudo abrir este legajo.',
        () => _activateLegajoProfile(profile),
      );
      return;
    }
    _navigationAwaitingTransition = true;
    _scheduleNavigationProbe();
    unawaited(_installNavigationObservers());
  }

  Future<void> _activateLegajoSection(SeccionLegajoSage section) async {
    final isSchool =
        section.clave == 'escolares' ||
        normalizarLegajoSage(section.titulo) == 'escolares';
    if (!isSchool) {
      _showUnavailableFeature(section.titulo);
      return;
    }
    if (_legajoActionInFlight != null) return;
    _manualNavigationActive = false;
    _usuarioSolicitoEscolares = true;
    _beginLegajoAction(
      isSchool ? 'Abriendo Escolares…' : 'Abriendo sección…',
      isSchool
          ? TipoAccionLegajoSage.abrirEscolares
          : TipoAccionLegajoSage.abrirSeccion,
    );
    final executor = EjecutorLegajoSage(_evaluateJavascript);
    final result = await (isSchool
        ? executor.activarPestanaEscolares()
        : executor.activarSeccion(section));
    _logLegajoAction(result);
    if (!mounted) return;
    if (!result.success) {
      if (isSchool) _usuarioSolicitoEscolares = false;
      _endLegajoAction();
      await _showLegajoActionFailure(
        isSchool
            ? 'No se pudo abrir la sección Escolares.'
            : 'No se pudo abrir esta sección.',
        () => _activateLegajoSection(section),
      );
      return;
    }
    _navigationAwaitingTransition = true;
    _scheduleNavigationProbe();
    unawaited(_installNavigationObservers());
  }

  Future<void> _activateEscolarOption(OpcionEscolarSage option) async {
    final normalizedTitle = normalizarLegajoSage(option.titulo);
    final isHistory =
        option.clave == 'nivel_superior_historial' ||
        option.clave == 'historial_del_alumnado' ||
        normalizedTitle == 'nivel superior - historial' ||
        normalizedTitle == 'historial del alumnado' ||
        (normalizedTitle.contains('nivel superior') &&
            normalizedTitle.contains('historial'));
    if (!isHistory) {
      _showUnavailableFeature(option.titulo);
      return;
    }
    if (_legajoActionInFlight != null) return;
    _manualNavigationActive = false;
    _beginLegajoAction(
      isHistory ? 'Cargando tu historial académico…' : 'Abriendo opción…',
      isHistory
          ? TipoAccionLegajoSage.abrirHistorial
          : TipoAccionLegajoSage.abrirSeccion,
    );
    final executor = EjecutorLegajoSage(_evaluateJavascript);
    final result = await (isHistory
        ? executor.activarNivelSuperiorHistorial()
        : executor.activarEscolares(option));
    _logLegajoAction(result);
    if (!mounted) return;
    if (!result.success) {
      if (isHistory) _usuarioSolicitoEscolares = false;
      _endLegajoAction();
      await _showLegajoActionFailure(
        isHistory
            ? 'No se pudo abrir el Historial académico.'
            : 'No se pudo abrir esta opción.',
        () => _activateEscolarOption(option),
      );
      return;
    }
    _navigationAwaitingTransition = true;
    _scheduleNavigationProbe();
    unawaited(_installNavigationObservers());
  }

  void _beginLegajoAction(String message, TipoAccionLegajoSage tipo) {
    _legajoOriginSignature = _legajoExtraction?.firma;
    _legajoActionInFlight = message;
    _tipoAccionLegajo = tipo;
    _navigationOriginSignature = _lastNavigationResult?.firma;
    _navigationOriginState = _lastNavigationResult?.estado;
    _navigationOriginPath = _lastNavigationResult?.documentoActivo?.pathname;
    _navigationActionStartedAt = DateTime.now();
    if (mounted) {
      setState(() {
        _navigationActionInFlight = message;
        _nativeLoadingVisible = true;
        _nativeLoadingMessage = message;
      });
    }
  }

  void _endLegajoAction() {
    _legajoActionInFlight = null;
    _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
    if (!mounted) return;
    setState(() {
      _navigationActionInFlight = null;
      _nativeLoadingVisible = false;
    });
  }

  String _timeoutMessage(TipoAccionLegajoSage tipo) => switch (tipo) {
    TipoAccionLegajoSage.abrirHistorial =>
      'SAGE no pudo abrir el Historial académico.',
    TipoAccionLegajoSage.abrirEscolares =>
      'No se pudo abrir la sección Escolares.',
    TipoAccionLegajoSage.abrirPerfil => 'No se pudo abrir este legajo.',
    _ => 'SAGE no confirmó el cambio de pantalla.',
  };

  Future<void> _showLegajoActionFailure(
    String message,
    Future<void> Function() retry,
  ) async {
    if (!mounted) return;
    if (_automaticMode) {
      final normalized = message.toLowerCase();
      final step = normalized.contains('historial')
          ? PasoSincronizacionSageAutomatica.historial
          : normalized.contains('escolares')
          ? PasoSincronizacionSageAutomatica.escolares
          : PasoSincronizacionSageAutomatica.legajo;
      final code = switch (step) {
        PasoSincronizacionSageAutomatica.historial =>
          CodigoErrorSincronizacionSage.abrirHistorial,
        PasoSincronizacionSageAutomatica.escolares =>
          CodigoErrorSincronizacionSage.abrirEscolares,
        _ => CodigoErrorSincronizacionSage.abrirLegajo,
      };
      _scheduleAutomaticStepRetry(
        step: step,
        message: message,
        code: code,
        action: retry,
      );
      return;
    }
    final shouldRetry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No se pudo continuar'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _showOriginalNavigation();
            },
            child: const Text('Ver página original'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
    if (shouldRetry == true) await retry();
  }

  void _logLegajoAction(ResultadoAccionLegajoSage result) {
    if (!kDebugMode) return;
    debugPrint(
      '[SAGE legajo action] type=${_tipoAccionLegajo.name}; '
      'key=${result.matchedBy}; frame=${result.frameId}; '
      'path=${result.pathnameBefore}; mechanism=${result.mechanism}; '
      'found=${result.found}; dispatched=${result.dispatched}; '
      'activated=${result.activated}; candidates=${result.candidateCount}; '
      'tag=${result.tag}; class_tab=${result.classTab}; '
      'has_onclick=${result.hasOnclick}; has_href=${result.hasHref}; '
      'matched_by=${result.matchedBy}',
    );
  }

  HistorialNivelSuperiorSage _mergeMasterHistory(
    HistorialNivelSuperiorSage master,
  ) {
    final previous = <String, CarreraHistorialSage>{
      for (final career in _history?.carreras ?? const <CarreraHistorialSage>[])
        career.gridRowId: career,
    };
    return HistorialNivelSuperiorSage(
      carreras: master.carreras
          .map((career) {
            final old = previous[career.gridRowId];
            if (old == null || !old.materiasCargadas) return career;
            return career.copyWith(
              materias: old.materias,
              materiasCargadas: true,
            );
          })
          .toList(growable: false),
    );
  }

  Future<void> _autoLoadAllCareers(List<CarreraHistorialSage> careers) async {
    if (!mounted ||
        _historyAutoLoadRunning ||
        _effectiveProfile != PerfilSage.alumnos) {
      return;
    }
    _historyAutoLoadRunning = true;
    try {
      for (var index = 0; index < careers.length; index++) {
        final original = careers[index];
        final currentHistory = _history;
        if (currentHistory == null) return;
        CarreraHistorialSage current = original;
        for (final item in currentHistory.carreras) {
          if (item.gridRowId == original.gridRowId) {
            current = item;
            break;
          }
        }
        if (current.materiasCargadas) {
          _reportPreparation(
            EstadoPreparacionSageLaboratorio(
              mensaje: 'Preparando carreras ${index + 1} de ${careers.length}…',
              progreso: (index + 1) / careers.length,
            ),
          );
          continue;
        }
        if (_historyAutoAttemptedCareerIds.contains(current.gridRowId)) {
          _reportPreparation(
            EstadoPreparacionSageLaboratorio(
              mensaje:
                  'La lectura de ${current.nombre} quedó incompleta. Tocá actualizar dentro de Historial para reintentar.',
              bloqueado: true,
            ),
          );
          return;
        }
        _historyAutoAttemptedCareerIds.add(current.gridRowId);
        _reportPreparation(
          EstadoPreparacionSageLaboratorio(
            mensaje:
                'Leyendo ${current.nombre} (${index + 1}/${careers.length})…',
            progreso: index / careers.length,
          ),
        );
        final result = await _expandHistoryCareer(current);
        if (!mounted) return;
        if (result.estado != EstadoCargaMateriasSage.disponible &&
            result.estado != EstadoCargaMateriasSage.vacio) {
          _reportPreparation(
            EstadoPreparacionSageLaboratorio(
              mensaje:
                  'No se pudo completar ${current.nombre}. Volvé a intentarlo desde Historial.',
              bloqueado: true,
            ),
          );
          return;
        }
      }
      _emitTrajectoryIfReady();
    } finally {
      _historyAutoLoadRunning = false;
    }
  }

  Future<List<DocumentoAcademicoSage>> _detectAcademicDocuments(
    HistorialNivelSuperiorSage history,
  ) async {
    final documents = <DocumentoAcademicoSage>[];
    for (var index = 0; index < history.carreras.length; index++) {
      if (!mounted || _isClosing) break;
      final career = history.carreras[index];
      _setAutomaticState(
        EtapaSincronizacionSageAutomatica.preparandoDocumentos,
        'Preparando documentos',
        detalle:
            'Revisando ${career.nombre} (${index + 1}/${history.carreras.length})…',
        progreso: 0.94 + ((index + 1) / history.carreras.length) * 0.035,
        paso: PasoSincronizacionSageAutomatica.documentos,
      );
      try {
        final prepared = await _historialController.asegurarSubgrillaLista(
          _evaluateJavascript,
          career,
          reportTitle:
              TipoDocumentoAcademicoSage.situacionAcademica.tituloReporte,
          restoreOriginal: false,
          timeout: const Duration(seconds: 8),
        );
        if (prepared.estado != EstadoSubgrillaSage.expandedReady) continue;
        void add(TipoDocumentoAcademicoSage type, bool available) {
          if (!available) return;
          documents.add(
            DocumentoAcademicoSage(
              tipo: type,
              gridRowId: career.gridRowId,
              careerKey: career.careerKey,
              carrera: career.nombre,
              institucion: career.institucion,
            ),
          );
        }

        add(
          TipoDocumentoAcademicoSage.situacionAcademica,
          prepared.academicButtonFound,
        );
        add(
          TipoDocumentoAcademicoSage.analitico,
          prepared.transcriptButtonFound,
        );
        add(TipoDocumentoAcademicoSage.libreta, prepared.recordButtonFound);
      } catch (_) {
        // Los documentos son complementarios; la trayectoria se guarda igual.
      }
    }
    return List<DocumentoAcademicoSage>.unmodifiable(documents);
  }

  Future<void> _prepareDocumentsAndCompleteAutomaticSync(
    TrayectoriaSageLaboratorio trajectory,
  ) async {
    if (_automaticDocumentsPreparing || _automaticCompleting) return;
    _automaticDocumentsPreparing = true;
    try {
      final history = _history;
      final documents = history == null
          ? const <DocumentoAcademicoSage>[]
          : await _detectAcademicDocuments(history);
      await _completeAutomaticSync(trajectory.conDocumentos(documents));
    } finally {
      _automaticDocumentsPreparing = false;
    }
  }

  CarreraHistorialSage? _requestedDocumentCareer() {
    final request = widget.documentoSolicitado;
    final history = _history;
    if (request == null || history == null) return null;
    final requestedKey = request.careerKey.trim().toLowerCase();
    for (final career in history.carreras) {
      if (requestedKey.isNotEmpty &&
          career.careerKey.trim().isNotEmpty &&
          career.careerKey.trim().toLowerCase() == requestedKey) {
        return career;
      }
      if (request.gridRowId.trim().isNotEmpty &&
          career.gridRowId.trim() == request.gridRowId.trim()) {
        return career;
      }
      if (career.nombre.trim().toLowerCase() ==
              request.carrera.trim().toLowerCase() &&
          career.institucion.trim().toLowerCase() ==
              request.institucion.trim().toLowerCase()) {
        return career;
      }
    }
    return null;
  }

  Future<void> _tryDownloadRequestedDocument() async {
    if (!_documentDownloadMode ||
        _automaticDocumentRequestRunning ||
        _automaticDocumentRequestCompleted ||
        _automaticCompleting ||
        !mounted) {
      return;
    }
    final request = widget.documentoSolicitado;
    if (request == null) {
      _failAutomaticSync(
        'No se indicó qué documento debe descargarse.',
        code: CodigoErrorSincronizacionSage.documentoNoDisponible,
        step: PasoSincronizacionSageAutomatica.documentos,
        permiteReintentar: false,
      );
      return;
    }
    final career = _requestedDocumentCareer();
    if (career == null) {
      _failAutomaticSync(
        'SAGE no encontró la carrera asociada al documento.',
        code: CodigoErrorSincronizacionSage.documentoNoDisponible,
        step: PasoSincronizacionSageAutomatica.documentos,
      );
      return;
    }

    _automaticDocumentRequestRunning = true;
    _automaticWatchdog?.cancel();
    _automaticRetryTimer?.cancel();
    _setAutomaticState(
      EtapaSincronizacionSageAutomatica.descargandoDocumento,
      'Preparando ${request.tipo.etiqueta}',
      detalle: request.carrera.trim().isEmpty
          ? 'Generando el PDF desde SAGE…'
          : 'Generando el PDF de ${request.carrera}…',
      progreso: 0.94,
      paso: PasoSincronizacionSageAutomatica.documentos,
    );
    try {
      final file = await _openHistoryReport(
        career,
        request.tipo.tituloReporte,
        silent: true,
      );
      if (file == null) {
        throw const ErrorSincronizacionSageAutomatica(
          'SAGE no pudo generar el documento solicitado.',
          codigo: CodigoErrorSincronizacionSage.descargaDocumento,
        );
      }
      _automaticDocumentRequestCompleted = true;
      widget.onDocumentoDescargado?.call(file);
      _setAutomaticState(
        EtapaSincronizacionSageAutomatica.completada,
        'Documento descargado',
        detalle: request.tipo.etiqueta,
        progreso: 1,
        paso: PasoSincronizacionSageAutomatica.documentos,
      );
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted && widget.cerrarAlCompletar) _exitSageToAppHome();
    } catch (error) {
      _scheduleAutomaticStepRetry(
        step: PasoSincronizacionSageAutomatica.documentos,
        message: error is ErrorSincronizacionSageAutomatica
            ? error.mensaje
            : 'No se pudo descargar el documento de SAGE.',
        code: error is ErrorSincronizacionSageAutomatica
            ? error.codigo
            : CodigoErrorSincronizacionSage.descargaDocumento,
        action: () async {
          _automaticDocumentRequestRunning = false;
          await _tryDownloadRequestedDocument();
        },
      );
    } finally {
      _automaticDocumentRequestRunning = false;
    }
  }

  void _emitTrajectoryIfReady() {
    if (!mounted || _effectiveProfile != PerfilSage.alumnos) return;
    final history = _history;
    if (history == null || history.carreras.isEmpty) return;
    if (history.carreras.any((career) => !career.materiasCargadas)) return;
    final trajectory = ConstructorTrayectoriaSageLaboratorio.construir(
      historial: history,
      perfil: _selectedStudentRecord,
    );
    if (!trajectory.listaParaSincronizar) {
      const status = EstadoPreparacionSageLaboratorio(
        mensaje: 'SAGE no entregó materias suficientes para sincronizar.',
        bloqueado: true,
      );
      _reportPreparation(status);
      return;
    }
    final signature = trajectory.carreras
        .map(
          (career) => <String>[
            career.gridRowId,
            for (final subject in career.materias)
              '${subject.idSage}|${subject.nombre}|${subject.estadoOriginal}|${subject.anio ?? ''}',
          ].join('::'),
        )
        .join('||');
    if (_lastTrajectorySignature == signature) return;
    _lastTrajectorySignature = signature;
    if (_documentDownloadMode) {
      unawaited(_tryDownloadRequestedDocument());
      return;
    }
    if (_automaticMode) {
      unawaited(_prepareDocumentsAndCompleteAutomaticSync(trajectory));
      return;
    }
    widget.onTrayectoriaLista?.call(trajectory);
    _reportPreparation(
      EstadoPreparacionSageLaboratorio(
        mensaje:
            '${trajectory.totalMaterias} materias listas para sincronizar.',
        progreso: 1,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${trajectory.totalMaterias} materias preparadas.'),
          action: SnackBarAction(
            label: 'VOLVER',
            onPressed: _exitSageToAppHome,
          ),
        ),
      );
  }

  Future<void> _refreshHistory() async {
    if (!mounted) return;
    _historyAutoAttemptedCareerIds.clear();
    final previousHistory = _history;
    _historyNeedsFreshDom = true;
    setState(() {
      _historyState = EstadoHistorialSage.cargandoCarreras;
      _nativeHistoryVisible = true;
    });
    try {
      var refreshed = await _historialController.actualizar(
        _evaluateJavascript,
      );
      if (!refreshed && await _controller.canGoBack()) {
        await _controller.goBack();
        await Future<void>.delayed(const Duration(milliseconds: 700));
        refreshed = await _historialController.actualizar(_evaluateJavascript);
      }
      final result = await _historialController.cargar(_evaluateJavascript);
      if (!mounted) return;
      final effectiveState =
          result.historial == null &&
              previousHistory != null &&
              (result.estado == EstadoHistorialSage.esperandoPagina ||
                  result.estado == EstadoHistorialSage.cargandoCarreras)
          ? EstadoHistorialSage.error
          : result.estado;
      setState(() {
        _history = result.historial ?? previousHistory;
        if (result.historial != null) _historyNeedsFreshDom = false;
        _historyState = effectiveState;
      });
      if (result.historial?.carreras.isNotEmpty ?? false) {
        if (_documentDownloadMode) {
          unawaited(_tryDownloadRequestedDocument());
        } else {
          unawaited(_autoLoadAllCareers(result.historial!.carreras));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _historyState = EstadoHistorialSage.error);
    }
  }

  Future<ResultadoMateriasSage> _expandHistoryCareer(
    CarreraHistorialSage career,
  ) async {
    if (!mounted) {
      return ResultadoMateriasSage(
        estado: EstadoCargaMateriasSage.error,
        materias: const [],
        gridRowId: career.gridRowId,
      );
    }
    setState(() => _historyState = EstadoHistorialSage.cargandoMaterias);
    try {
      final result = await _historialController.expandirYCargarMaterias(
        _evaluateJavascript,
        career,
      );
      if (kDebugMode) {
        debugPrint(
          '[SAGE sync] restoring_history_frame=true; '
          'master_grid_ready=${result.requestedGridRow}; '
          'current_row_resolved=${result.masterRowFound}; '
          'row_expanded=${result.expandCalled}; '
          'dynamic_grid_ready=${result.dynamicTableFound}; '
          'b2_ready=${!result.subgridLoaderVisible}; '
          'state=${result.estado.name}',
        );
      }
      if (result.estado != EstadoCargaMateriasSage.disponible &&
          result.estado != EstadoCargaMateriasSage.vacio) {
        if (mounted) {
          setState(() {
            _historyState = _history == null
                ? EstadoHistorialSage.error
                : EstadoHistorialSage.disponible;
          });
        }
        return result;
      }
      final updated = career.copyWith(
        gridRowId: result.gridRowId,
        materias: result.materias,
        materiasCargadas: true,
      );
      final current = _history;
      if (current != null && mounted) {
        final careers = current.carreras
            .map(
              (item) =>
                  item.gridRowId == career.gridRowId ||
                      (item.internalId != null &&
                          item.internalId == career.internalId &&
                          item.nombre == career.nombre)
                  ? updated
                  : item,
            )
            .toList(growable: false);
        setState(() {
          _history = HistorialNivelSuperiorSage(carreras: careers);
          _historyState = EstadoHistorialSage.disponible;
        });
        _emitTrajectoryIfReady();
      }
      return result;
    } catch (_) {
      if (mounted) {
        setState(() {
          _historyState = _history == null
              ? EstadoHistorialSage.error
              : EstadoHistorialSage.disponible;
        });
      }
      return ResultadoMateriasSage(
        estado: EstadoCargaMateriasSage.error,
        materias: const [],
        gridRowId: career.gridRowId,
      );
    }
  }

  Future<File?> _openHistoryReport(
    CarreraHistorialSage career,
    String title, {
    bool silent = false,
  }) async {
    if (_reportInFlight) return null;
    if (_historyState == EstadoHistorialSage.cargandoCarreras) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esperá a que termine la actualización.'),
          ),
        );
      }
      return null;
    }
    setState(() => _reportInFlight = true);
    final pending = Completer<Uri>();
    _pendingReportUrl = pending;
    if (!silent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparando reporte…')));
    }
    try {
      await _installReportBridge();
      await _installReportDiagnostics();
      final report = await _historialController.pulsarReporte(
        _evaluateJavascript,
        career,
        title,
      );
      if (kDebugMode) {
        debugPrint(
          '[SAGE sync] current_row_resolved=${report.rowResolved}; '
          'dynamic_grid_ready=${report.subgridReady}; '
          'pager_ready=${report.pagerFound}; '
          'report_button_ready=${report.reportButtonFound}; '
          'report_click_dispatched=${report.estado == EstadoReporteSage.iniciado}; '
          'state=${report.estado.name}',
        );
      }
      if (report.estado == EstadoReporteSage.iniciado) {
        try {
          final uri = await pending.future.timeout(const Duration(seconds: 8));
          final file = await _procesarDescargaWeb(
            uri: uri,
            abrirAlCompletar: true,
          );
          if (kDebugMode && file != null) {
            debugPrint('[SAGE report V3] download_started=true');
          }
          return file;
        } on TimeoutException {
          if (kDebugMode) debugPrint('[SAGE report] timeout=true');
          if (mounted && !silent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SAGE no generó el enlace del reporte.'),
              ),
            );
          }
          return null;
        }
      }
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_reportErrorMessage(report.estado))),
        );
      }
      return null;
    } finally {
      if (identical(_pendingReportUrl, pending)) _pendingReportUrl = null;
      if (mounted) setState(() => _reportInFlight = false);
    }
  }

  String _reportErrorMessage(EstadoReporteSage state) => switch (state) {
    EstadoReporteSage.channelUnavailable =>
      'No se pudo conectar el reporte con la aplicación.',
    EstadoReporteSage.bridgeInstallFailed =>
      'No se pudo preparar la descarga del reporte.',
    EstadoReporteSage.reportFunctionMissing =>
      'SAGE no mostró la función del reporte.',
    EstadoReporteSage.reportFunctionStructureChanged =>
      'SAGE cambió la forma de generar este reporte.',
    EstadoReporteSage.reportFunctionTransformUnsafe =>
      'No se pudo preparar el reporte de forma segura.',
    EstadoReporteSage.reportFunctionCompileBlocked =>
      'El navegador de SAGE bloqueó la preparación del reporte.',
    EstadoReporteSage.reportFunctionPatchFailed =>
      'No se pudo conectar el reporte con la aplicación.',
    EstadoReporteSage.carreraAmbigua =>
      'La carrera seleccionada no es unívoca en SAGE.',
    EstadoReporteSage.carreraNoEncontrada =>
      'No se encontró la carrera actual en SAGE.',
    EstadoReporteSage.subgrillaCargando =>
      'SAGE todavía está cargando el detalle de materias.',
    EstadoReporteSage.subgridNoExpandido =>
      'No se pudo abrir el detalle de materias.',
    EstadoReporteSage.pagerNoEncontrado =>
      'No se encontró el paginador de la carrera.',
    EstadoReporteSage.botonNoEncontrado =>
      'No se encontró ese reporte en la subgrilla.',
    EstadoReporteSage.clickError => 'SAGE no permitió ejecutar el reporte.',
    EstadoReporteSage.timeout => 'SAGE no generó el enlace del reporte.',
    _ => 'No se pudo iniciar el reporte de SAGE.',
  };

  void _showOriginalHistory() {
    if (!mounted) return;
    unawaited(_restoreThenShowOriginal());
  }

  Future<void> _restoreThenShowOriginal() async {
    await _installReportBridge();
    await _historialController.instalarReportesV3(_evaluateJavascript);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _showOriginalWebView = true;
        _nativeHistoryVisible = false;
      });
    }
  }

  Future<void> _loadInitialPage() async {
    _loadRequestCount++;
    if (kDebugMode) {
      debugPrint(
        '[SAGE] loadRequest inicial #$_loadRequestCount; '
        'host=${_initialUri.host}; ruta=/login/; composición=predeterminada',
      );
    }
    await _controller.loadRequest(_initialUri);
  }

  void _logFirstPageTiming() {
    final startedAt = _firstPageStartedAt;
    if (!kDebugMode || startedAt == null) return;
    debugPrint(
      '[SAGE] primera apertura hasta onPageFinished: '
      '${DateTime.now().difference(startedAt).inMilliseconds} ms; '
      'loadRequest=$_loadRequestCount',
    );
    _firstPageStartedAt = null;
  }

  FutureOr<NavigationDecision> _handleNavigationRequest(
    NavigationRequest request,
  ) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    if (uri.scheme == 'blob') {
      _logPdfDiagnostic(uri, source: 'navigation');
      _showDownloadFailure(
        'Este PDF se genera como blob dentro de SAGE. No se descargó para evitar una extracción insegura.',
      );
      return NavigationDecision.prevent;
    }

    if (_isPdfDownloadUri(uri) && _canStayInWebView(uri)) {
      _logPdfDiagnostic(uri, source: 'navigation');
      unawaited(_procesarDescargaWeb(uri: uri));
      return NavigationDecision.prevent;
    }

    if (_canStayInWebView(uri)) {
      return NavigationDecision.navigate;
    }

    if (_canOpenExternally(uri)) {
      unawaited(_openExternal(uri));
    }
    return NavigationDecision.prevent;
  }

  bool _canStayInWebView(Uri uri) {
    final host = uri.host.toLowerCase();
    return uri.scheme == 'https' &&
        (host == 'sage.entrerios.gov.ar' ||
            host.endsWith('.sage.entrerios.gov.ar'));
  }

  bool _canOpenExternally(Uri uri) {
    const externalSchemes = <String>{
      'mailto',
      'tel',
      'sms',
      'whatsapp',
      'intent',
      'market',
    };
    return externalSchemes.contains(uri.scheme) ||
        uri.scheme == 'http' ||
        uri.scheme == 'https';
  }

  bool _isPdfUrl(Uri uri) {
    return uri.path.toLowerCase().endsWith('.pdf');
  }

  bool _isPdfDownloadUri(Uri uri) {
    final lastSegment = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last.toLowerCase();
    return _isPdfUrl(uri) || lastSegment.startsWith('ns_reporte_');
  }

  void _logPdfDiagnostic(Uri uri, {required String source}) {
    if (!kDebugMode) return;
    final route = _safeRoute(uri);
    final kind = uri.scheme == 'blob' ? 'blob' : 'GET candidato por URL';
    debugPrint(
      '[SAGE] diagnóstico PDF: origen=$source; host=${uri.host}; '
      'ruta=$route; método=$kind; mime=solo disponible en respuesta HTTP; '
      'content-disposition=solo disponible en respuesta HTTP; '
      'termina-en-pdf=${_isPdfDownloadUri(uri)}; host-sage=${_canStayInWebView(uri)}; '
      'sesión=WebView; ventana=misma',
    );
  }

  String _safeRoute(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return '/';
    final visible = segments.take(2).join('/');
    return '/$visible${segments.length > 2 ? '/…' : ''}';
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // La navegación se cancela si no hay una aplicación disponible.
    }
  }

  String _errorMessage(WebResourceError error) {
    return 'No se pudo cargar SAGE. Revisá tu conexión e intentá nuevamente.';
  }

  Future<void> _retry() async {
    _navigationProgress.value = 0;
    _mainFrameError.value = null;
    await _controller.reload();
  }

  bool get _hasResolvedNativeSageScreen =>
      _nativeHistoryVisible ||
      _nativeModulesVisible ||
      _nativeSubmodulesVisible ||
      _nativeLegajoVisible ||
      _nativeSeccionesLegajoVisible ||
      _nativeEscolaresVisible ||
      _nativeAgentHomeVisible ||
      _nativeAgentPersonalVisible ||
      _nativeAgentStudentMenuVisible ||
      _nativeProfileSelectorVisible;

  void _scheduleAuthCoverReleaseIfReady() {
    if (!_authTransitionCoverVisible ||
        _authCoverReleaseScheduled ||
        !_privateSageShellActive ||
        _logoutBusy ||
        _profileSwitchBusy ||
        _profileHomeResetBusy ||
        _profileSelectorPreparing ||
        !_hasResolvedNativeSageScreen) {
      return;
    }

    _authCoverReleaseScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authCoverReleaseScheduled = false;
      if (!mounted ||
          !_authTransitionCoverVisible ||
          !_privateSageShellActive ||
          _logoutBusy ||
          _profileSwitchBusy ||
          _profileHomeResetBusy ||
          _profileSelectorPreparing ||
          !_hasResolvedNativeSageScreen) {
        return;
      }

      setState(() {
        _authTransitionCoverVisible = false;
        _authTransitionCoverMessage = 'Cargando SAGE…';
      });
    });
  }

  bool get _hasNativeSageScreen =>
      _nativeHistoryVisible ||
      _nativeModulesVisible ||
      _nativeSubmodulesVisible ||
      _nativeLegajoVisible ||
      _nativeSeccionesLegajoVisible ||
      _nativeEscolaresVisible ||
      _nativeAgentHomeVisible ||
      _nativeAgentPersonalVisible ||
      _nativeAgentStudentMenuVisible ||
      _nativeProfileSelectorVisible ||
      _nativeLoadingVisible;

  bool get _shouldCoverWebView =>
      _privateSageShellActive && !_showOriginalWebView;

  bool get _nativeFallbackLoading =>
      _shouldCoverWebView && !_hasNativeSageScreen;

  bool get _showNativeSageSurface =>
      _hasNativeSageScreen || _nativeFallbackLoading;

  bool get _sageHomeVisible => _nativeModulesVisible || _nativeAgentHomeVisible;

  bool get _canUseSageBack =>
      !_nativeProfileSelectorVisible &&
      !_nativeLoadingVisible &&
      !_nativeFallbackLoading &&
      !_sageHomeVisible;

  PerfilSage? get _effectiveProfile =>
      _selectedProfile ?? _profileCapture?.activo;

  Future<void> _requestSageHome() async {
    _cancelStudentAutomaticLanding();
    if (!mounted ||
        _profileSwitchBusy ||
        _profileHomeResetBusy ||
        _logoutBusy) {
      return;
    }

    final profile = _effectiveProfile;
    if (profile == null) {
      _showProfileSelector();
      return;
    }

    if (await _hasRealSageHomeDocument()) {
      _showSageHome();
      return;
    }

    final transitionId = ++_profileTransitionId;
    _stopProfileSwitchWatchdog();
    _profileSwitchTarget = null;
    _ensureProbeTimer();
    _manualNavigationActive = true;
    setState(() {
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _profileHomeResetBusy = true;
      _profileError = null;
      _nativeProfileSelectorVisible = false;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Volviendo al inicio de SAGE…';
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _navigationActionStartedAt = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
      _historyAutoLoadRunning = false;
      _historyNeedsFreshDom = true;
      _history = null;
      _historyState = EstadoHistorialSage.esperandoPagina;
      _historyAutoAttemptedCareerIds.clear();
    });

    final returnedHome = await _returnRealSageToHome(
      transitionId,
    ).timeout(const Duration(seconds: 14), onTimeout: () => false);

    if (!mounted ||
        transitionId != _profileTransitionId ||
        !_profileHomeResetBusy) {
      return;
    }

    _showSageHome();
    if (!returnedHome && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'SAGE no confirmó el regreso al inicio. '
              'El cambio de perfil volverá a intentarlo automáticamente.',
            ),
          ),
        );
    }
  }

  void _showSageHome() {
    if (!mounted) return;
    _cancelStudentAutomaticLanding();
    final profile = _effectiveProfile;
    if (profile == null) {
      _showProfileSelector();
      return;
    }
    _manualNavigationActive = true;
    setState(() {
      _privateSageShellActive = true;
      _showOriginalWebView = false;
      _profileChoiceMade = true;
      _profileHomeResetBusy = false;
      _nativeHistoryVisible = false;
      _nativeModulesVisible = profile == PerfilSage.alumnos;
      _nativeSubmodulesVisible = false;
      _nativeLegajoVisible = false;
      _nativeSeccionesLegajoVisible = false;
      _nativeEscolaresVisible = false;
      _nativeAgentHomeVisible = profile == PerfilSage.agente;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeProfileSelectorVisible = false;
      _nativeLoadingVisible = false;
      _navigationActionInFlight = null;
      _legajoActionInFlight = null;
      _navigationAwaitingTransition = false;
      _navigationOriginSignature = null;
      _navigationOriginState = null;
      _navigationOriginPath = null;
      _navigationActionStartedAt = null;
      _legajoOriginSignature = null;
      _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
      _usuarioSolicitoEscolares = false;
      _historyAutoLoadRunning = false;
      _historyNeedsFreshDom = true;
      _history = null;
      _historyState = EstadoHistorialSage.esperandoPagina;
      _historyAutoAttemptedCareerIds.clear();
    });
  }

  bool _handleSageBackStep() {
    if (!mounted ||
        !_showNativeSageSurface ||
        _nativeLoadingVisible ||
        _nativeFallbackLoading) {
      return false;
    }
    _manualNavigationActive = true;
    if (_nativeHistoryVisible) {
      setState(() {
        _nativeHistoryVisible = false;
        _nativeEscolaresVisible = true;
      });
      return true;
    }
    if (_nativeEscolaresVisible) {
      setState(() {
        _nativeEscolaresVisible = false;
        _nativeSeccionesLegajoVisible = true;
      });
      return true;
    }
    if (_nativeSeccionesLegajoVisible) {
      setState(() {
        _nativeSeccionesLegajoVisible = false;
        _nativeLegajoVisible = true;
      });
      return true;
    }
    if (_nativeLegajoVisible) {
      setState(() {
        _nativeLegajoVisible = false;
        if (_effectiveProfile == PerfilSage.agente) {
          _nativeAgentStudentMenuVisible = true;
        } else {
          _nativeSubmodulesVisible = true;
        }
      });
      return true;
    }
    if (_nativeAgentPersonalVisible || _nativeAgentStudentMenuVisible) {
      _showAgentHome();
      return true;
    }
    if (_nativeSubmodulesVisible) {
      setState(() {
        _nativeSubmodulesVisible = false;
        _nativeModulesVisible = true;
      });
      return true;
    }
    if (_nativeModulesVisible || _nativeAgentHomeVisible) {
      _showProfileSelector();
      return true;
    }
    return false;
  }

  Widget _buildCurrentNativeSageScreen() {
    if (_nativeLoadingVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-loading'),
        child: PantallaCargaSage(mensaje: _nativeLoadingMessage),
      );
    }
    if (_nativeProfileSelectorVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-profile-selector'),
        child: PantallaSelectorPerfilSage(
          perfiles: _profileCapture?.perfiles ?? const [],
          onSelect: _selectProfile,
          busy: _profileSwitchBusy || _logoutBusy,
          error: _profileError,
          onRetry: () {
            unawaited(_requestProfileSelector());
          },
          onBack: _exitSageToAppHome,
        ),
      );
    }
    if (_nativeHistoryVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-history'),
        child: PantallaHistorialSage(
          historial: _history,
          estado: _historyState,
          onExpandCareer: _expandHistoryCareer,
          onReport: (career, title) async {
            await _openHistoryReport(career, title);
          },
          onRefresh: _refreshHistory,
          onShowOriginal: _showOriginalHistory,
          onBack: _handleBack,
          reportsEnabled: !_reportInFlight,
        ),
      );
    }
    if (_nativeEscolaresVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-school-options'),
        child: PantallaEscolaresSage(
          opciones: _legajoExtraction?.opcionesEscolares ?? const [],
          onSelect: (option) => unawaited(_activateEscolarOption(option)),
          onBack: widget.onClose ?? _showOriginalNavigation,
          loadingTitle: _navigationActionInFlight,
        ),
      );
    }
    if (_nativeSeccionesLegajoVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-student-sections'),
        child: PantallaSeccionesLegajoSage(
          secciones: _seccionesDisponibles(),
          onSelect: (section) => unawaited(_activateLegajoSection(section)),
          onBack: widget.onClose ?? _showOriginalNavigation,
          loadingTitle: _navigationActionInFlight,
        ),
      );
    }
    if (_nativeLegajoVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-student-records'),
        child: PantallaMiLegajoSage(
          perfiles: _legajoExtraction?.perfiles ?? const [],
          onSelect: (profile) => unawaited(_activateLegajoProfile(profile)),
          onBack: widget.onClose ?? _showOriginalNavigation,
          loadingTitle: _navigationActionInFlight,
        ),
      );
    }
    if (_nativeAgentStudentMenuVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-agent-student-menu'),
        child: PantallaLegajoAlumnoAgenteSage(
          opciones: _agentStudentOptions,
          onSelect: (option) => unawaited(_activateAgentStudentOption(option)),
          onBack: _showAgentHome,
          busy: _navigationActionInFlight != null,
        ),
      );
    }
    if (_nativeAgentPersonalVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-agent-personal-menu'),
        child: PantallaLegajoPersonalSage(
          opciones: _agentPersonalOptions,
          onSelect: _activateAgentOption,
          onBack: _showAgentHome,
          busy: _navigationActionInFlight != null,
        ),
      );
    }
    if (_nativeSubmodulesVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-student-modules'),
        child: PantallaSubmodulosSage(
          onSelect: (option) => unawaited(_activateSageLink(option)),
          onBack: widget.onClose ?? _showOriginalNavigation,
          loadingTitle: _navigationActionInFlight,
        ),
      );
    }
    if (_nativeAgentHomeVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-agent-home'),
        child: PantallaPortadaAgenteSage(
          onSelect: _handleAgentOption,
          onBack: _showProfileSelector,
          portada: _portadaAgente,
          busy: _navigationActionInFlight != null,
        ),
      );
    }
    if (_nativeModulesVisible) {
      return KeyedSubtree(
        key: const ValueKey('sage-student-home'),
        child: PantallaModulosSage(
          onOpenLegajo: _openLegajoModule,
          onRefresh: _retry,
          onBack: _showProfileSelector,
          loadingTitle: _navigationActionInFlight,
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey('sage-loading'),
      child: PantallaCargaSage(
        mensaje:
            _navigationActionInFlight == null && _legajoActionInFlight == null
            ? 'Cargando la siguiente pantalla…'
            : _nativeLoadingMessage,
      ),
    );
  }

  Future<void> _handleBack() async {
    if (_isClosing || _logoutBusy) return;
    if (_nativeProfileSelectorVisible) {
      _exitSageToAppHome();
      return;
    }
    if (_handleSageBackStep()) return;
    _isClosing = true;
    try {
      if (_nativeHistoryVisible) {
        if (mounted) {
          widget.onClose?.call();
          if (widget.onClose == null) Navigator.of(context).pop();
        }
        return;
      }
      if (await _controller.canGoBack()) {
        await _controller.goBack();
        return;
      }
      if (mounted) {
        widget.onClose?.call();
        if (widget.onClose == null) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      _isClosing = false;
    }
  }

  Future<File?> _procesarDescargaWeb({
    required Uri uri,
    String? userAgent,
    String? contentDisposition,
    String? mimeType,
    int? contentLength,
    bool abrirAlCompletar = true,
  }) async {
    if (!_canStayInWebView(uri) || !_isPdfDownloadUri(uri)) return null;
    final now = DateTime.now();
    if (_activeDownloadUri == uri &&
        _activeDownloadStartedAt != null &&
        now.difference(_activeDownloadStartedAt!) <
            const Duration(seconds: 5)) {
      return null;
    }

    _activeDownloadUri = uri;
    _activeDownloadStartedAt = now;
    _navigationProgress.value = 100;
    _mainFrameError.value = null;
    try {
      return await _downloadPdf(
        uri,
        userAgentHint: userAgent,
        contentDispositionHint: contentDisposition,
        mimeTypeHint: mimeType,
        contentLengthHint: contentLength,
        abrirAlCompletar: abrirAlCompletar,
      );
    } finally {
      _activeDownloadUri = null;
      _activeDownloadStartedAt = null;
    }
  }

  Future<File?> _downloadPdf(
    Uri initialUri, {
    String? userAgentHint,
    String? contentDispositionHint,
    String? mimeTypeHint,
    int? contentLengthHint,
    bool abrirAlCompletar = true,
  }) async {
    _downloadState.value = const _DownloadState.downloading();
    try {
      final response = await _sendPdfRequest(
        initialUri,
        userAgentHint: userAgentHint,
      );
      final contentType = (mimeTypeHint ?? response.headers['content-type'])
          ?.split(';')
          .first
          .trim()
          .toLowerCase();
      final contentDisposition =
          contentDispositionHint ?? response.headers['content-disposition'];
      _logPdfResponse(initialUri, response, contentType, contentDisposition);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.stream.drain();
        throw StateError('Respuesta HTTP no exitosa.');
      }

      final looksLikePdf =
          contentType == 'application/pdf' ||
          _isPdfDownloadUri(initialUri) ||
          (contentDisposition?.toLowerCase().contains('.pdf') ?? false);
      if (!looksLikePdf) {
        await response.stream.drain();
        throw StateError('La respuesta no fue un PDF directo.');
      }

      final directory = await _downloadDirectory();
      final fileName = _safeFileName(
        _filenameFromContentDisposition(contentDisposition) ??
            _filenameFromUri(initialUri),
      );
      final file = await _nextAvailableFile(directory, fileName);
      final temporaryFile = File('${file.path}.part');
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }

      var receivedBytes = 0;
      final totalBytes = contentLengthHint ?? response.contentLength;
      final sink = temporaryFile.openWrite();
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          _downloadState.value = _DownloadState.downloading(
            progress: totalBytes == null || totalBytes <= 0
                ? null
                : receivedBytes / totalBytes,
          );
        }
        await sink.flush();
        await sink.close();
      } catch (_) {
        await sink.close();
        rethrow;
      }

      final savedFile = await temporaryFile.rename(file.path);
      _downloadState.value = _DownloadState.completed(savedFile);
      if (mounted && abrirAlCompletar) {
        await _openPdfViewer(savedFile);
      }
      return savedFile;
    } catch (_) {
      _showDownloadFailure(
        'No se pudo descargar el documento. Verificá la sesión de SAGE e intentá nuevamente.',
      );
      return null;
    }
  }

  Future<http.StreamedResponse> _sendPdfRequest(
    Uri initialUri, {
    String? userAgentHint,
  }) async {
    var currentUri = initialUri;
    for (var redirect = 0; redirect <= 5; redirect++) {
      if (!_canStayInWebView(currentUri)) {
        throw StateError('La redirección salió del dominio permitido.');
      }

      final cookies = await _cookieManager.getCookies(domain: currentUri);
      final userAgent = userAgentHint ?? await _controller.getUserAgent();
      final request = http.Request('GET', currentUri)
        ..followRedirects = false
        ..maxRedirects = 0;
      request.headers['Accept'] =
          'application/pdf,application/octet-stream;q=0.9,*/*;q=0.8';
      if (userAgent != null && userAgent.isNotEmpty) {
        request.headers['User-Agent'] = userAgent;
      }
      final cookieHeader = cookies
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .join('; ');
      if (cookieHeader.isNotEmpty) {
        request.headers['Cookie'] = cookieHeader;
      }

      final response = await _httpClient.send(request);
      if (!response.isRedirect) return response;

      final location = response.headers['location'];
      await response.stream.drain();
      if (location == null || location.isEmpty) {
        throw StateError('La redirección no indicó destino.');
      }
      final nextUri = currentUri.resolve(location);
      if (!_canStayInWebView(nextUri)) {
        throw StateError('La redirección salió del dominio permitido.');
      }
      currentUri = nextUri;
    }
    throw StateError('Se excedió el límite de redirecciones.');
  }

  void _logPdfResponse(
    Uri uri,
    http.StreamedResponse response,
    String? contentType,
    String? contentDisposition,
  ) {
    if (!kDebugMode) return;
    debugPrint(
      '[SAGE] respuesta PDF: host=${uri.host}; ruta=${_safeRoute(uri)}; '
      'método=GET; status=${response.statusCode}; '
      'mime=${contentType ?? 'ausente'}; '
      'content-disposition=${contentDisposition == null ? 'ausente' : 'presente'}; '
      'longitud=${response.contentLength ?? 'desconocida'}',
    );
  }

  Future<Directory> _downloadDirectory() async {
    if (Platform.isAndroid) {
      final directories = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (directories != null && directories.isNotEmpty) {
        await directories.first.create(recursive: true);
        return directories.first;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _nextAvailableFile(Directory directory, String fileName) async {
    var candidate = File('${directory.path}${Platform.pathSeparator}$fileName');
    var suffix = 1;
    while (await candidate.exists()) {
      final dot = fileName.lastIndexOf('.');
      final base = dot <= 0 ? fileName : fileName.substring(0, dot);
      final extension = dot <= 0 ? '' : fileName.substring(dot);
      candidate = File(
        '${directory.path}${Platform.pathSeparator}$base ($suffix)$extension',
      );
      suffix++;
    }
    return candidate;
  }

  String? _filenameFromContentDisposition(String? header) {
    if (header == null || header.trim().isEmpty) return null;
    for (final part in header.split(';')) {
      final value = part.trim();
      final lower = value.toLowerCase();
      if (lower.startsWith('filename*=')) {
        var encoded = value.substring('filename*='.length).trim();
        final separator = encoded.indexOf("''");
        if (separator >= 0) encoded = encoded.substring(separator + 2);
        encoded = _stripQuotes(encoded);
        try {
          return Uri.decodeComponent(encoded);
        } catch (_) {
          return encoded;
        }
      }
      if (lower.startsWith('filename=')) {
        return _stripQuotes(value.substring('filename='.length).trim());
      }
    }
    return null;
  }

  String _filenameFromUri(Uri uri) {
    final lastSegment = uri.pathSegments.isEmpty
        ? ''
        : uri.pathSegments.last.trim();
    return lastSegment.isEmpty ? 'sage_documento.pdf' : lastSegment;
  }

  String _stripQuotes(String value) {
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  String _safeFileName(String value) {
    final buffer = StringBuffer();
    const invalidCharacters = r'<>:"/\|?*';
    for (final rune in value.runes) {
      if (rune < 32 || invalidCharacters.contains(String.fromCharCode(rune))) {
        buffer.write('_');
      } else {
        buffer.writeCharCode(rune);
      }
    }
    var result = buffer.toString().trim();
    if (result.isEmpty || result == '.' || result == '..') {
      result = 'sage_documento.pdf';
    }
    if (!result.toLowerCase().endsWith('.pdf')) result = '$result.pdf';
    return result;
  }

  void _showDownloadFailure(String message) {
    _downloadState.value = _DownloadState.failed(message);
  }

  Future<void> _openDownloadedFile(File file) async {
    if (!await file.exists()) {
      _showDownloadFailure('El archivo ya no está disponible.');
      return;
    }
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay un visor de PDF disponible.')),
      );
    }
  }

  Future<void> _openPdfViewer(File file) async {
    if (!await file.exists() || !mounted) return;
    final name = file.uri.pathSegments.isEmpty
        ? 'Documento de SAGE'
        : file.uri.pathSegments.last;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PantallaVisorPdfSage(rutaArchivo: file.path, nombreArchivo: name),
      ),
    );
  }

  Future<void> _shareDownloadedFile(File file) async {
    if (!await file.exists()) {
      _showDownloadFailure('El archivo ya no está disponible.');
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(title: 'Documento de SAGE', files: [XFile(file.path)]),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo compartir el PDF.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _historyPollTimer?.cancel();
    _navigationDebounceTimer?.cancel();
    _profileSwitchWatchdog?.cancel();
    _studentAutoLandingWatchdog?.cancel();
    _loginTransitionWatchdog?.cancel();
    _automaticWatchdog?.cancel();
    _automaticRetryTimer?.cancel();
    _httpClient.close();
    _navigationProgress.dispose();
    _mainFrameError.dispose();
    _downloadState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final theme = widget.themeOverride ?? parentTheme;
    final scheme = theme.colorScheme;
    final nativeSurfaceVisible = !_automaticMode && _showNativeSageSurface;
    final webViewVisible =
        _automaticMode ||
        (!_shouldCoverWebView &&
            webViewSageVisible(
              historial: _nativeHistoryVisible,
              modulos: _nativeModulesVisible,
              submodulos: _nativeSubmodulesVisible,
              carga: _nativeLoadingVisible,
              legajo: _nativeLegajoVisible,
              secciones: _nativeSeccionesLegajoVisible,
              escolares: _nativeEscolaresVisible,
              agente: _nativeAgentHomeVisible,
              agentePersonal: _nativeAgentPersonalVisible,
              agenteAlumno: _nativeAgentStudentMenuVisible,
              perfil: _nativeProfileSelectorVisible,
            ));

    if (!_automaticMode) {
      _scheduleAuthCoverReleaseIfReady();
    }

    return Theme(
      data: widget.themeOverride ?? temaMensajesLaboratorioSage(context),
      child: Builder(
        builder: (themedContext) => PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (_automaticMode) {
              _exitSageToAppHome();
            } else {
              unawaited(_handleBack());
            }
          },
          child: Scaffold(
            appBar:
                _automaticMode ||
                    nativeSurfaceVisible ||
                    _authTransitionCoverVisible
                ? null
                : construirAppBarSage(
                    themedContext,
                    title: widget.title,
                    leading: IconButton(
                      tooltip: 'Volver',
                      onPressed: widget.onClose ?? _handleBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    actions: [
                      if (_privateSageShellActive)
                        IconButton(
                          tooltip: 'Cerrar sesión',
                          onPressed: _logoutBusy
                              ? null
                              : () => unawaited(_confirmAndLogoutSage()),
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      IconButton(
                        tooltip: 'Recargar SAGE',
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
            body: Stack(
              children: [
                const SizedBox.expand(),
                Visibility(
                  visible: webViewVisible,
                  maintainState: true,
                  child: ExcludeSemantics(
                    excluding: _automaticMode,
                    child: IgnorePointer(
                      ignoring: _automaticMode,
                      child: WebViewWidget(
                        key: const ValueKey('sage-webview-persistent'),
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
                if (nativeSurfaceVisible)
                  Positioned.fill(
                    bottom:
                        BarraNavegacionSage.height +
                        MediaQuery.paddingOf(context).bottom,
                    child: ColoredBox(
                      color: theme.scaffoldBackgroundColor,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        reverseDuration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            fit: StackFit.expand,
                            clipBehavior: Clip.hardEdge,
                            children: [
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildCurrentNativeSageScreen(),
                      ),
                    ),
                  ),
                if (nativeSurfaceVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BarraNavegacionSage(
                      canGoBack: _canUseSageBack,
                      homeSelected: _sageHomeVisible,
                      profileSelected: _nativeProfileSelectorVisible,
                      busy:
                          _profileSwitchBusy ||
                          _profileHomeResetBusy ||
                          _logoutBusy ||
                          _nativeLoadingVisible ||
                          _nativeFallbackLoading ||
                          _navigationAwaitingTransition ||
                          _navigationActionInFlight != null ||
                          _legajoActionInFlight != null,
                      onBack: () => _handleSageBackStep(),
                      onHome: () {
                        unawaited(_requestSageHome());
                      },
                      onChangeProfile: () {
                        unawaited(_requestProfileSelector());
                      },
                      onLogout: () {
                        unawaited(_confirmAndLogoutSage());
                      },
                    ),
                  ),
                if (!_automaticMode)
                  ValueListenableBuilder<int>(
                    valueListenable: _navigationProgress,
                    builder: (context, progress, _) {
                      if (progress >= 100) return const SizedBox.shrink();
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: progress == 0 ? null : progress / 100,
                          minHeight: 2,
                          color: scheme.primary,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      );
                    },
                  ),
                if (!_automaticMode && _authTransitionCoverVisible)
                  Positioned.fill(
                    child: ColoredBox(
                      color: theme.scaffoldBackgroundColor,
                      child: PantallaCargaSage(
                        mensaje: _authTransitionCoverMessage,
                      ),
                    ),
                  ),
                if (!_automaticMode)
                  ValueListenableBuilder<String?>(
                    valueListenable: _mainFrameError,
                    builder: (context, error, _) {
                      if (error == null) return const SizedBox.shrink();
                      return Positioned.fill(
                        child: ColoredBox(
                          color: theme.scaffoldBackgroundColor,
                          child: _ErrorView(message: error, onRetry: _retry),
                        ),
                      );
                    },
                  ),
                if (!_automaticMode)
                  ValueListenableBuilder<_DownloadState>(
                    valueListenable: _downloadState,
                    builder: (context, state, _) {
                      if (state.phase == _DownloadPhase.idle) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        left: 16,
                        right: 16,
                        bottom: 96,
                        child: _DownloadCard(
                          state: state,
                          onView: state.file == null
                              ? null
                              : () => _openPdfViewer(state.file!),
                          onShare: state.file == null
                              ? null
                              : () => _shareDownloadedFile(state.file!),
                          onOpenExternally: state.file == null
                              ? null
                              : () => _openDownloadedFile(state.file!),
                          onDismiss: () => _downloadState.value =
                              const _DownloadState.idle(),
                        ),
                      );
                    },
                  ),
                if (_automaticMode)
                  Positioned.fill(
                    child: PantallaSincronizacionSageAutomatica(
                      estado: _automaticState,
                      loginDisponible: _loginDocumentReady,
                      procesandoCredenciales: _automaticCredentialsBusy,
                      onIngresar: _submitAutomaticCredentials,
                      onReintentar: _automaticState.permiteReintentar
                          ? _retryAutomaticSync
                          : null,
                      onCancelar: _exitSageToAppHome,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _DownloadPhase { idle, downloading, completed, failed }

class _DownloadState {
  const _DownloadState({
    required this.phase,
    this.progress,
    this.file,
    this.message,
  });

  const _DownloadState.idle() : this(phase: _DownloadPhase.idle);

  const _DownloadState.downloading({double? progress})
    : this(phase: _DownloadPhase.downloading, progress: progress);

  const _DownloadState.completed(File file)
    : this(phase: _DownloadPhase.completed, file: file);

  const _DownloadState.failed(String message)
    : this(phase: _DownloadPhase.failed, message: message);

  final _DownloadPhase phase;
  final double? progress;
  final File? file;
  final String? message;
}

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({
    required this.state,
    required this.onView,
    required this.onShare,
    required this.onOpenExternally,
    required this.onDismiss,
  });

  final _DownloadState state;
  final VoidCallback? onView;
  final VoidCallback? onShare;
  final VoidCallback? onOpenExternally;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDownloading = state.phase == _DownloadPhase.downloading;
    final isFailed = state.phase == _DownloadPhase.failed;
    final title = isDownloading
        ? 'Descargando documento…'
        : isFailed
        ? 'No se pudo descargar'
        : 'Documento descargado';

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            if (isDownloading) ...[
              LinearProgressIndicator(value: state.progress),
              if (state.progress != null) ...[
                const SizedBox(height: 6),
                Text('${(state.progress! * 100).round()} %'),
              ],
            ],
            if (isFailed && state.message != null)
              Text(
                state.message!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            if (state.phase == _DownloadPhase.completed &&
                state.file != null) ...[
              Text(
                state.file!.uri.pathSegments.last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Ver'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Compartir'),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Más opciones',
                    onSelected: (value) {
                      if (value == 'external') onOpenExternally?.call();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'external',
                        child: Text('Abrir con otra aplicación'),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.more_horiz_rounded),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
