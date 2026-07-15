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

import '../sage_historial/controlador_historial_sage.dart';
import '../sage_historial/modelos_historial_sage.dart';
import '../sage_historial/pantalla_historial_sage.dart';
import '../sage_legajo/ejecutor_legajo_sage.dart';
import '../sage_legajo/extractor_legajo_sage.dart';
import '../sage_legajo/modelos_legajo_sage.dart';
import '../sage_legajo/pantalla_escolares_sage.dart';
import '../sage_legajo/pantalla_mi_legajo_sage.dart';
import '../sage_legajo/pantalla_secciones_legajo_sage.dart';
import '../sage_agente/modelos_agente_sage.dart';
import '../sage_agente/extractor_agente_sage.dart';
import '../sage_agente/ejecutor_shell_agente_sage.dart';
import '../sage_agente/pantalla_portada_agente_sage.dart';
import '../sage_agente/pantalla_legajo_personal_sage.dart';
import '../sage_agente/pantalla_legajo_alumno_agente_sage.dart';
import '../sage_perfiles/ejecutor_perfiles_sage.dart';
import '../sage_perfiles/modelos_perfiles_sage.dart';
import '../sage_perfiles/pantalla_selector_perfil_sage.dart';
import '../sage_navegacion/detector_navegacion_sage.dart';
import '../sage_navegacion/modelos_navegacion_sage.dart';
import '../sage_navegacion/pantalla_carga_sage.dart';
import '../sage_navegacion/pantalla_modulos_sage.dart';
import '../sage_navegacion/barra_navegacion_sage.dart';
import '../sage_navegacion/pantalla_submodulos_sage.dart';
import 'pantalla_visor_pdf_sage.dart';

class PantallaSage extends StatefulWidget {
  const PantallaSage({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<PantallaSage> createState() => _PantallaSageState();
}

class _PantallaSageState extends State<PantallaSage> {
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
  bool _nativeAgentHomeVisible = false;
  bool _nativeAgentPersonalVisible = false;
  bool _nativeAgentStudentMenuVisible = false;
  List<OpcionAgenteSage> _agentPersonalOptions = const [];
  List<OpcionAgenteSage> _agentStudentOptions = const [];
  bool _nativeProfileSelectorVisible = false;
  bool _profileChoiceMade = false;
  bool _profileSwitchBusy = false;
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
  ResultadoExtraccionLegajoSage? _legajoExtraction;
  String? _legajoActionInFlight;
  String? _legajoOriginSignature;
  TipoAccionLegajoSage _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
  bool _usuarioSolicitoEscolares = false;
  int _loadRequestCount = 0;

  @override
  void initState() {
    super.initState();
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
        final uri = Uri.tryParse(url);
        final isPrivatePregase =
            uri != null &&
            uri.host.toLowerCase() == 'sage.entrerios.gov.ar' &&
            uri.path.toLowerCase().startsWith('/pregase/') &&
            !uri.path.toLowerCase().startsWith('/login/');
        if (isPrivatePregase && mounted) {
          setState(() {
            _nativeLoadingVisible = true;
            _nativeLoadingMessage = 'Preparando tus servicios académicos…';
          });
        }
      },
      onPageFinished: (_) {
        _navigationProgress.value = 100;
        _mainFrameError.value = null;
        _logFirstPageTiming();
        unawaited(_installNavigationObservers());
        _requestSageProbe();
      },
      onWebResourceError: (error) {
        if (error.isForMainFrame != true) return;
        if (_activeDownloadUri != null) {
          _navigationProgress.value = 100;
          return;
        }
        _navigationProgress.value = 100;
        _mainFrameError.value = _errorMessage(error);
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
    _historyPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _requestSageProbe(),
    );
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
      final profiles = result.estado == EstadoNavegacionSage.login ||
              result.estado == EstadoNavegacionSage.sesionVencida
          ? const CapturaPerfilesSage(perfiles: [])
          : await _probeProfiles(
              openPanelIfNeeded: !_profileChoiceMade && !_profileSwitchBusy,
            );
      _profileCapture = profiles;
      unawaited(_installNavigationObservers());
      if (!mounted) return;

      if (_profileSwitchBusy) return;
      if (_manualNavigationActive &&
          !_navigationAwaitingTransition &&
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
        final timedOut =
            _navigationActionStartedAt != null &&
            DateTime.now().difference(_navigationActionStartedAt!) >
                const Duration(seconds: 8);
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_timeoutMessage(tipoFallido))));
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_timeoutMessage(tipoFallido))));
          return;
        } else {
          return;
        }
      }

      if (_nativeHistoryVisible &&
          result.estado != EstadoNavegacionSage.login &&
          result.estado != EstadoNavegacionSage.sesionVencida) {
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
      final raw = await _evaluateJavascript(
        r'''(() => {
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
        })()''',
      );
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

  Future<CapturaPerfilesSage> _probeProfiles({
    bool openPanelIfNeeded = false,
  }) {
    return EjecutorPerfilesSage(
      _evaluateJavascript,
    ).inspeccionar(abrirPanelSiHaceFalta: openPanelIfNeeded);
  }

  Future<void> _selectProfile(PerfilSage profile) async {
    if (_profileSwitchBusy) return;
    _manualNavigationActive = false;
    final current = _profileCapture?.activo;
    if (current == profile) {
      setState(() {
        _selectedProfile = profile;
        _profileChoiceMade = true;
        _nativeProfileSelectorVisible = false;
        _profileError = null;
        _nativeLoadingVisible = true;
        _nativeLoadingMessage = 'Cargando ${profile.etiqueta}…';
      });
      _requestSageProbe();
      return;
    }

    setState(() {
      _profileSwitchBusy = true;
      _profileError = null;
    });

    final dispatch = await EjecutorPerfilesSage(
      _evaluateJavascript,
    ).cambiar(profile);
    if (!mounted) return;

    if (!dispatch.dispatchSucceeded) {
      setState(() {
        _profileSwitchBusy = false;
        _profileError = dispatch.errorMessage;
      });
      if (kDebugMode) {
        debugPrint(
          '[SAGE perfil] target=${profile.clave}; stage=${dispatch.stage}; '
          'avatar=${dispatch.avatarFound}; panel=${dispatch.panelOpened}; '
          'found=${dispatch.found}; dispatched=${dispatch.dispatched}; '
          'activated=${dispatch.activated}',
        );
      }
      return;
    }

    setState(() {
      _nativeProfileSelectorVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Cambiando a ${profile.etiqueta}…';
    });

    final confirmed = dispatch.alreadyActive ||
        await _confirmProfileChange(profile);
    if (!mounted) return;

    if (!confirmed) {
      setState(() {
        _profileSwitchBusy = false;
        _nativeLoadingVisible = false;
        _nativeProfileSelectorVisible = true;
        _profileError = dispatch.errorMessage;
      });
      return;
    }

    setState(() {
      _selectedProfile = profile;
      _profileChoiceMade = true;
      _profileSwitchBusy = false;
      _profileError = null;
      _nativeProfileSelectorVisible = false;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeLoadingVisible = true;
      _nativeLoadingMessage = 'Cargando ${profile.etiqueta}…';
    });
    _requestSageProbe();
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

  Future<bool> _confirmProfileChange(PerfilSage profile) async {
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    var attempts = 0;
    while (DateTime.now().isBefore(deadline)) {
      attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (_isClosing) return false;

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

        final capture = await _probeProfiles(
          openPanelIfNeeded: attempts >= 4,
        );
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
    _activateAgentOption(option);
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
          content: Text(
            'SAGE no mostró las opciones de Legajo Único Alumno.',
          ),
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

  void _showProfileSelector() {
    if (!mounted) return;
    _manualNavigationActive = true;
    setState(() {
      _profileChoiceMade = false;
      _profileError = null;
      _nativeProfileSelectorVisible = true;
      _nativeAgentHomeVisible = false;
      _nativeAgentPersonalVisible = false;
      _nativeAgentStudentMenuVisible = false;
      _nativeModulesVisible = false;
      _nativeSubmodulesVisible = false;
      _nativeLoadingVisible = false;
    });
    unawaited(_refreshProfileSelector());
  }

  Future<void> _refreshProfileSelector() async {
    final capture = await _probeProfiles(openPanelIfNeeded: true);
    if (!mounted) return;
    setState(() {
      _profileCapture = capture;
      if (capture.perfiles.length < 2) {
        _profileError = 'SAGE no expuso los dos perfiles disponibles.';
      }
    });
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
    unawaited(_activateSageLink(option.asWebOption()));
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
      if (_manualNavigationActive && !_navigationAwaitingTransition) return;
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
        if (result.estado == EstadoHistorialSage.disponible &&
            careers != null &&
            careers.isNotEmpty) {
          unawaited(_autoLoadFirstCareer(careers.first));
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
    if (_legajoActionInFlight != null) return;
    _manualNavigationActive = false;
    final isSchool =
        section.clave == 'escolares' ||
        normalizarLegajoSage(section.titulo) == 'escolares';
    if (isSchool) _usuarioSolicitoEscolares = true;
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
    if (_legajoActionInFlight != null) return;
    _manualNavigationActive = false;
    final isHistory =
        option.clave == 'nivel_superior_historial' ||
        normalizarLegajoSage(option.titulo) == 'nivel superior - historial';
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

  Future<void> _autoLoadFirstCareer(CarreraHistorialSage career) async {
    if (_historyAutoLoadRunning ||
        _historyAutoAttemptedCareerIds.contains(career.gridRowId) ||
        career.materiasCargadas) {
      return;
    }
    _historyAutoAttemptedCareerIds.add(career.gridRowId);
    _historyAutoLoadRunning = true;
    if (kDebugMode) debugPrint('[SAGE historial] expanding_career');
    try {
      await _expandHistoryCareer(career);
    } finally {
      _historyAutoLoadRunning = false;
    }
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
        unawaited(_autoLoadFirstCareer(result.historial!.carreras.first));
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

  Future<void> _openHistoryReport(
    CarreraHistorialSage career,
    String title,
  ) async {
    if (_reportInFlight) return;
    if (_historyState == EstadoHistorialSage.cargandoCarreras) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esperá a que termine la actualización.'),
          ),
        );
      }
      return;
    }
    setState(() => _reportInFlight = true);
    final pending = Completer<Uri>();
    _pendingReportUrl = pending;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preparando reporte…')));
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
        debugPrint('[SAGE report] button_found=${report.reportButtonFound}');
        debugPrint('[SAGE report] inline_onclick=${report.inlineOnclick}');
        debugPrint('[SAGE report] jquery_handlers=${report.jqueryHandlers}');
        debugPrint('[SAGE report] bridge_patched=${report.bridgePatched}');
        debugPrint(
          '[SAGE report] function_owner=${report.functionOwner ?? 'missing'}',
        );
        debugPrint(
          '[SAGE report] click_dispatched=${report.estado == EstadoReporteSage.iniciado}',
        );
      }
      if (report.estado == EstadoReporteSage.iniciado) {
        try {
          final uri = await pending.future.timeout(const Duration(seconds: 5));
          await _procesarDescargaWeb(uri: uri);
          if (kDebugMode) debugPrint('[SAGE report V3] download_started=true');
        } on TimeoutException {
          if (kDebugMode) debugPrint('[SAGE report] timeout=true');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SAGE no generó el enlace del reporte.'),
              ),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_reportErrorMessage(report.estado))),
        );
      }
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
    if (mounted) setState(() => _nativeHistoryVisible = false);
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

bool get _sageHomeVisible =>
    _nativeModulesVisible || _nativeAgentHomeVisible;

bool get _canUseSageBack =>
    !_nativeProfileSelectorVisible &&
    !_nativeLoadingVisible &&
    !_sageHomeVisible;

PerfilSage? get _effectiveProfile =>
    _selectedProfile ?? _profileCapture?.activo;

void _showSageHome() {
  if (!mounted) return;
  final profile = _effectiveProfile;
  if (profile == null) {
    _showProfileSelector();
    return;
  }
  _manualNavigationActive = true;
  setState(() {
    _profileChoiceMade = true;
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
    _tipoAccionLegajo = TipoAccionLegajoSage.ninguna;
  });
}

bool _handleSageBackStep() {
  if (!mounted || !_hasNativeSageScreen || _nativeLoadingVisible) {
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

  Widget _nativeSageLayer(Widget child) => Positioned.fill(
    bottom:
        BarraNavegacionSage.height + MediaQuery.paddingOf(context).bottom,
    child: child,
  );

  Future<void> _handleBack() async {
    if (_isClosing) return;
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

  Future<void> _procesarDescargaWeb({
    required Uri uri,
    String? userAgent,
    String? contentDisposition,
    String? mimeType,
    int? contentLength,
  }) async {
    if (!_canStayInWebView(uri) || !_isPdfDownloadUri(uri)) return;
    final now = DateTime.now();
    if (_activeDownloadUri == uri &&
        _activeDownloadStartedAt != null &&
        now.difference(_activeDownloadStartedAt!) <
            const Duration(seconds: 5)) {
      return;
    }

    _activeDownloadUri = uri;
    _activeDownloadStartedAt = now;
    _navigationProgress.value = 100;
    _mainFrameError.value = null;
    final task = _downloadPdf(
      uri,
      userAgentHint: userAgent,
      contentDispositionHint: contentDisposition,
      mimeTypeHint: mimeType,
      contentLengthHint: contentLength,
    );
    try {
      await task;
    } finally {
      _activeDownloadUri = null;
      _activeDownloadStartedAt = null;
    }
  }

  Future<void> _downloadPdf(
    Uri initialUri, {
    String? userAgentHint,
    String? contentDispositionHint,
    String? mimeTypeHint,
    int? contentLengthHint,
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
      if (mounted) {
        await _openPdfViewer(savedFile);
      }
    } catch (_) {
      _showDownloadFailure(
        'No se pudo descargar el documento. Verificá la sesión de SAGE e intentá nuevamente.',
      );
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
    _httpClient.close();
    _navigationProgress.dispose();
    _mainFrameError.dispose();
    _downloadState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_handleBack());
      },
      child: Scaffold(
        appBar:
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
                _nativeLoadingVisible
            ? null
            : AppBar(
                backgroundColor: const Color(0xFF0E5E86),
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  tooltip: 'Volver',
                  onPressed: widget.onClose ?? _handleBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: const Text('SAGE'),
                actions: [
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
              visible: webViewSageVisible(
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
              ),
              maintainState: true,
              child: WebViewWidget(
                key: const ValueKey('sage-webview-persistent'),
                controller: _controller,
              ),
            ),
            if (_nativeHistoryVisible)
              _nativeSageLayer(
                PantallaHistorialSage(
                  historial: _history,
                  estado: _historyState,
                  onExpandCareer: _expandHistoryCareer,
                  onReport: _openHistoryReport,
                  onRefresh: _refreshHistory,
                  onShowOriginal: _showOriginalHistory,
                  onBack: _handleBack,
                  reportsEnabled: !_reportInFlight,
                ),
              ),
            if (_nativeModulesVisible)
              _nativeSageLayer(
                PantallaModulosSage(
                  onOpenLegajo: _openLegajoModule,
                  onRefresh: _retry,
                  onBack: _showProfileSelector,
                  loadingTitle: _navigationActionInFlight,
                ),
              ),
            if (_nativeAgentHomeVisible)
              _nativeSageLayer(
                PantallaPortadaAgenteSage(
                  onSelect: _handleAgentOption,
                  onBack: _showProfileSelector,
                  portada: _portadaAgente,
                  busy: _navigationActionInFlight != null,
                ),
              ),
            if (_nativeAgentPersonalVisible)
              _nativeSageLayer(
                PantallaLegajoPersonalSage(
                  opciones: _agentPersonalOptions,
                  onSelect: _activateAgentOption,
                  onBack: _showAgentHome,
                  busy: _navigationActionInFlight != null,
                ),
              ),
            if (_nativeAgentStudentMenuVisible)
              _nativeSageLayer(
                PantallaLegajoAlumnoAgenteSage(
                  opciones: _agentStudentOptions,
                  onSelect: (option) =>
                      unawaited(_activateAgentStudentOption(option)),
                  onBack: _showAgentHome,
                  busy: _navigationActionInFlight != null,
                ),
              ),
            if (_nativeProfileSelectorVisible)
              _nativeSageLayer(
                PantallaSelectorPerfilSage(
                  perfiles: _profileCapture?.perfiles ?? const [],
                  onSelect: _selectProfile,
                  busy: _profileSwitchBusy,
                  error: _profileError,
                  onRetry: () => unawaited(_refreshProfileSelector()),
                ),
              ),
            if (_nativeSubmodulesVisible)
              _nativeSageLayer(
                PantallaSubmodulosSage(
                  onSelect: (option) => unawaited(_activateSageLink(option)),
                  onBack: widget.onClose ?? _showOriginalNavigation,
                  loadingTitle: _navigationActionInFlight,
                ),
              ),
            if (_nativeLegajoVisible)
              _nativeSageLayer(
                PantallaMiLegajoSage(
                  perfiles: _legajoExtraction?.perfiles ?? const [],
                  onSelect: (profile) =>
                      unawaited(_activateLegajoProfile(profile)),
                  onBack: widget.onClose ?? _showOriginalNavigation,
                  loadingTitle: _navigationActionInFlight,
                ),
              ),
            if (_nativeSeccionesLegajoVisible)
              _nativeSageLayer(
                PantallaSeccionesLegajoSage(
                  secciones: _seccionesDisponibles(),
                  onSelect: (section) =>
                      unawaited(_activateLegajoSection(section)),
                  onBack: widget.onClose ?? _showOriginalNavigation,
                  loadingTitle: _navigationActionInFlight,
                ),
              ),
            if (_nativeEscolaresVisible)
              _nativeSageLayer(
                PantallaEscolaresSage(
                  opciones: _legajoExtraction?.opcionesEscolares ?? const [],
                  onSelect: (option) =>
                      unawaited(_activateEscolarOption(option)),
                  onBack: widget.onClose ?? _showOriginalNavigation,
                  loadingTitle: _navigationActionInFlight,
                ),
              ),
            if (_nativeLoadingVisible)
              _nativeSageLayer(
                PantallaCargaSage(mensaje: _nativeLoadingMessage),
              ),
            if (_hasNativeSageScreen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BarraNavegacionSage(
                  canGoBack: _canUseSageBack,
                  homeSelected: _sageHomeVisible,
                  profileSelected: _nativeProfileSelectorVisible,
                  busy: _profileSwitchBusy ||
                      _navigationActionInFlight != null ||
                      _legajoActionInFlight != null,
                  onBack: () => _handleSageBackStep(),
                  onHome: _showSageHome,
                  onChangeProfile: _showProfileSelector,
                ),
              ),
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
                    onDismiss: () =>
                        _downloadState.value = const _DownloadState.idle(),
                  ),
                );
              },
            ),
          ],
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
