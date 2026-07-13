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

  Uri? _activeDownloadUri;
  DateTime? _activeDownloadStartedAt;
  DateTime? _firstPageStartedAt;
  bool _isClosing = false;
  bool _historyProbeRunning = false;
  bool _nativeHistoryVisible = false;
  EstadoHistorialSage _historyState = EstadoHistorialSage.esperandoPagina;
  HistorialNivelSuperiorSage? _history;
  bool _historyAutoLoadRunning = false;
  bool _historyNeedsFreshDom = false;
  bool _reportInFlight = false;
  final Set<String> _historyAutoAttemptedCareerIds = <String>{};
  Timer? _historyPollTimer;
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
      onPageStarted: (_) {
        _firstPageStartedAt ??= DateTime.now();
        _navigationProgress.value = 0;
        _mainFrameError.value = null;
      },
      onPageFinished: (_) {
        _navigationProgress.value = 100;
        _mainFrameError.value = null;
        _logFirstPageTiming();
        unawaited(_probeHistory());
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
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    if (kDebugMode &&
        Platform.isAndroid &&
        navigationDelegate.platform is AndroidNavigationDelegate) {
      // setPlatformNavigationDelegate installs the package's public
      // AndroidNavigationDelegate.androidDownloadListener on Android.
      debugPrint('[SAGE] Android DownloadListener conectado');
    }
    unawaited(
      _controller
          .setNavigationDelegate(navigationDelegate)
          .then((_) => _loadInitialPage()),
    );
    _historyPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_probeHistory()),
    );
  }

  Future<String> _evaluateJavascript(String source) {
    return _controller
        .runJavaScriptReturningResult(source)
        .then((value) => value is String ? value : jsonEncode(value));
  }

  Future<void> _probeHistory() async {
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
      if (result.pantallaDetectada) {
        setState(() {
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
          debugPrint(
            '[SAGE historial] native_view_visible=$_nativeHistoryVisible',
          );
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preparando reporte…')));
    try {
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
      if (report.estado != EstadoReporteSage.iniciado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_reportErrorMessage(report.estado))),
        );
      }
    } finally {
      if (mounted) setState(() => _reportInFlight = false);
    }
  }

  String _reportErrorMessage(EstadoReporteSage state) => switch (state) {
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
    _ => 'No se pudo iniciar el reporte de SAGE.',
  };

  void _showOriginalHistory() {
    if (!mounted) return;
    unawaited(_restoreThenShowOriginal());
  }

  Future<void> _restoreThenShowOriginal() async {
    final restored = await _historialController.restaurarPantallaOriginal(
      _evaluateJavascript,
    );
    if (!restored && await _controller.canGoBack()) {
      await _controller.goBack();
      await Future<void>.delayed(const Duration(milliseconds: 700));
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 1000));
    }
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

  Future<void> _handleBack() async {
    if (_isClosing) return;
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
        appBar: _nativeHistoryVisible
            ? null
            : AppBar(
                backgroundColor: const Color(0xFF0E5E86),
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  tooltip: 'Volver',
                  onPressed: _handleBack,
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
              visible: !_nativeHistoryVisible,
              maintainState: true,
              child: WebViewWidget(
                key: const ValueKey('sage-webview-persistent'),
                controller: _controller,
              ),
            ),
            if (_nativeHistoryVisible)
              Positioned.fill(
                child: PantallaHistorialSage(
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
