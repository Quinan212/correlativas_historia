import 'dart:async';
import 'dart:convert';

import 'extractor_historial_sage.dart';
import 'modelos_historial_sage.dart';

class ControladorHistorialSage {
  ControladorHistorialSage({ExtractorHistorialSage? extractor})
    : _extractor = extractor ?? const ExtractorHistorialSage();

  final ExtractorHistorialSage _extractor;

  Future<ResultadoExtraccionHistorial> cargar(
    EvaluarJavascript evaluateJavascript, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    ResultadoExtraccionHistorial? last;
    while (DateTime.now().isBefore(deadline)) {
      last = await _extractor.leer(evaluateJavascript);
      if (last.estado == EstadoHistorialSage.disponible ||
          last.estado == EstadoHistorialSage.vacio ||
          last.estado == EstadoHistorialSage.incompatible ||
          last.estado == EstadoHistorialSage.sesionVencida) {
        return last;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    return last ??
        const ResultadoExtraccionHistorial(
          estado: EstadoHistorialSage.error,
          mensaje: 'SAGE no terminó de cargar el historial.',
        );
  }

  Future<ResultadoResolverFilaSage> resolverFilaActual(
    EvaluarJavascript evaluateJavascript,
    CarreraHistorialSage carrera,
  ) async {
    final raw = await evaluateJavascript(
      _resolveRowScript(
        jsonEncode(carrera.careerContextId ?? ''),
        jsonEncode(carrera.careerKey),
        jsonEncode(carrera.gridRowId),
        jsonEncode(carrera.nombre),
        jsonEncode(carrera.institucion),
        jsonEncode(carrera.anioInicio?.toString() ?? ''),
      ),
    );
    final decoded = _decode(raw);
    return ResultadoResolverFilaSage(
      estado: switch (decoded?['state']?.toString()) {
        'resolved' => EstadoResolverFilaSage.resuelta,
        'waiting' => EstadoResolverFilaSage.esperandoPagina,
        'incompatible' => EstadoResolverFilaSage.incompatible,
        'career_ambiguous' => EstadoResolverFilaSage.carreraAmbigua,
        'career_not_found' => EstadoResolverFilaSage.carreraNoEncontrada,
        _ => EstadoResolverFilaSage.error,
      },
      gridRowId: decoded?['gridRowId']?.toString(),
      masterFound: decoded?['masterFound'] == true,
    );
  }

  Future<ResultadoSubgrillaSage> asegurarSubgrillaLista(
    EvaluarJavascript evaluateJavascript,
    CarreraHistorialSage carrera, {
    String? reportTitle,
    bool restoreOriginal = true,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (restoreOriginal &&
        !await restaurarPantallaOriginal(evaluateJavascript)) {
      return const ResultadoSubgrillaSage(estado: EstadoSubgrillaSage.missing);
    }
    final deadline = DateTime.now().add(timeout);
    var expansionRequested = false;
    ResultadoSubgrillaSage? last;
    while (DateTime.now().isBefore(deadline)) {
      final raw = await evaluateJavascript(
        _prepareSubgridScript(
          jsonEncode(carrera.careerContextId ?? ''),
          jsonEncode(carrera.careerKey),
          jsonEncode(carrera.gridRowId),
          jsonEncode(carrera.nombre),
          jsonEncode(carrera.institucion),
          jsonEncode(carrera.anioInicio?.toString() ?? ''),
          jsonEncode(reportTitle),
          !expansionRequested,
        ),
      );
      last = _parseSubgridResult(raw);
      if (last.expandCalled) expansionRequested = true;
      if (last.estado == EstadoSubgrillaSage.expandedReady) return last;
      if (last.estado == EstadoSubgrillaSage.missing ||
          last.estado == EstadoSubgrillaSage.careerAmbiguous) {
        return last;
      }
      await Future<void>.delayed(const Duration(milliseconds: 350));
    }
    return last == null
        ? const ResultadoSubgrillaSage(estado: EstadoSubgrillaSage.timeout)
        : ResultadoSubgrillaSage(
            estado: EstadoSubgrillaSage.timeout,
            gridRowId: last.gridRowId,
            dynamicTableId: last.dynamicTableId,
            masterFound: last.masterFound,
            expanded: last.expanded,
            dynamicTableFound: last.dynamicTableFound,
            b2Ready: last.b2Ready,
            pagerFound: last.pagerFound,
            academicButtonFound: last.academicButtonFound,
            transcriptButtonFound: last.transcriptButtonFound,
            recordButtonFound: last.recordButtonFound,
            expandCalled: last.expandCalled,
          );
  }

  Future<ResultadoMateriasSage> expandirYCargarMaterias(
    EvaluarJavascript evaluateJavascript,
    CarreraHistorialSage carrera, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final prepared = await asegurarSubgrillaLista(
      evaluateJavascript,
      carrera,
      timeout: timeout,
    );
    final gridRowId = prepared.gridRowId;
    if (gridRowId == null ||
        prepared.estado != EstadoSubgrillaSage.expandedReady) {
      return ResultadoMateriasSage(
        estado: prepared.estado == EstadoSubgrillaSage.missing
            ? EstadoCargaMateriasSage.filaNoEncontrada
            : EstadoCargaMateriasSage.timeout,
        materias: const [],
        gridRowId: gridRowId ?? carrera.gridRowId,
        requestedGridRow: gridRowId != null,
        masterRowFound: prepared.masterFound,
        expandCalled: prepared.expandCalled,
        dynamicTableFound: prepared.dynamicTableFound,
      );
    }
    final result = await _extractor.leerMateriasConEstado(
      evaluateJavascript,
      gridRowId,
    );
    return ResultadoMateriasSage(
      estado: result.estado,
      materias: result.materias,
      gridRowId: gridRowId,
      dynamicTableId: result.dynamicTableId,
      subgridLoaderVisible: result.subgridLoaderVisible,
      subjectRowCount: result.subjectRowCount,
      requestedGridRow: true,
      masterRowFound: prepared.masterFound,
      expandCalled: prepared.expandCalled,
      subgridContainerFound: prepared.dynamicTableFound,
      dynamicTableFound: result.dynamicTableFound,
    );
  }

  Future<ResultadoReporteSage> pulsarReporte(
    EvaluarJavascript evaluateJavascript,
    CarreraHistorialSage carrera,
    String title,
  ) async {
    final prepared = await asegurarSubgrillaLista(
      evaluateJavascript,
      carrera,
      reportTitle: title,
      restoreOriginal: false,
    );
    if (prepared.estado == EstadoSubgrillaSage.careerAmbiguous) {
      return const ResultadoReporteSage(
        estado: EstadoReporteSage.carreraAmbigua,
      );
    }
    if (prepared.gridRowId == null ||
        prepared.estado == EstadoSubgrillaSage.missing) {
      return ResultadoReporteSage(
        estado: EstadoReporteSage.carreraNoEncontrada,
        pagerFound: prepared.pagerFound,
      );
    }
    if (prepared.estado != EstadoSubgrillaSage.expandedReady) {
      return ResultadoReporteSage(
        estado: EstadoReporteSage.subgrillaCargando,
        rowResolved: prepared.gridRowId != null,
        pagerFound: prepared.pagerFound,
      );
    }
    final buttonFound = switch (title) {
      'Imprimir la Situación Académica del alumno en la carrera' =>
        prepared.academicButtonFound,
      'Imprimir listado de materias aprobadas' =>
        prepared.transcriptButtonFound,
      _ => prepared.recordButtonFound,
    };
    if (!buttonFound) {
      return ResultadoReporteSage(
        estado: EstadoReporteSage.botonNoEncontrado,
        rowResolved: true,
        subgridReady: true,
        pagerFound: prepared.pagerFound,
      );
    }
    final patchRaw = await evaluateJavascript(_v3BootstrapScript());
    final patch = _decode(patchRaw);
    final patchState = patch?['state']?.toString();
    if (patchState != 'ready') {
      return ResultadoReporteSage(
        estado: switch (patchState) {
          'channel_unavailable' => EstadoReporteSage.channelUnavailable,
          'report_function_missing' => EstadoReporteSage.reportFunctionMissing,
          'report_function_structure_changed' =>
            EstadoReporteSage.reportFunctionStructureChanged,
          'report_function_transform_unsafe' =>
            EstadoReporteSage.reportFunctionTransformUnsafe,
          'report_function_compile_blocked' =>
            EstadoReporteSage.reportFunctionCompileBlocked,
          _ => EstadoReporteSage.reportFunctionPatchFailed,
        },
        rowResolved: true,
        subgridReady: true,
        pagerFound: prepared.pagerFound,
        reportButtonFound: true,
      );
    }
    final raw = await evaluateJavascript(
      _reportScript(jsonEncode(prepared.gridRowId), jsonEncode(title)),
    );
    final decoded = _decode(raw);
    final state = decoded?['state']?.toString();
    return ResultadoReporteSage(
      estado: switch (state) {
        'click_dispatched' => EstadoReporteSage.iniciado,
        'channel_unavailable' => EstadoReporteSage.channelUnavailable,
        'bridge_install_failed' => EstadoReporteSage.bridgeInstallFailed,
        'report_function_missing' => EstadoReporteSage.reportFunctionMissing,
        'report_function_structure_changed' =>
          EstadoReporteSage.reportFunctionStructureChanged,
        'report_function_transform_unsafe' =>
          EstadoReporteSage.reportFunctionTransformUnsafe,
        'report_function_compile_blocked' =>
          EstadoReporteSage.reportFunctionCompileBlocked,
        'report_function_patch_failed' =>
          EstadoReporteSage.reportFunctionPatchFailed,
        'career_ambiguous' => EstadoReporteSage.carreraAmbigua,
        'subgrid_not_expanded' => EstadoReporteSage.subgridNoExpandido,
        'pager_not_found' => EstadoReporteSage.pagerNoEncontrado,
        'report_button_not_found' => EstadoReporteSage.botonNoEncontrado,
        'click_error' => EstadoReporteSage.clickError,
        _ => EstadoReporteSage.error,
      },
      rowResolved: true,
      subgridReady: true,
      pagerFound: prepared.pagerFound,
      reportButtonFound: true,
      bridgePatched: _int(decoded?['patched']) ?? 0,
      functionOwner: decoded?['functionOwner']?.toString(),
      inlineOnclick: decoded?['inlineOnclick'] == true,
      jqueryHandlers: decoded?['jqueryHandlers'] == true,
    );
  }

  Future<bool> restaurarPantallaOriginal(
    EvaluarJavascript evaluateJavascript,
  ) async {
    final raw = await evaluateJavascript(r'''(() => {
      const main = document.querySelector('iframe#Main');
      const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
      const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
      const win = escolares?.contentWindow;
      if (!win) return JSON.stringify({restored:false});
      const path = String(win.location.pathname || '').toLowerCase();
      if (path.endsWith('/ns_historial_alumnado.php')) {
        return JSON.stringify({restored:true, action:'already_original'});
      }
      try {
        win.history.back();
        return JSON.stringify({restored:true, action:'frame_back'});
      } catch (_) {
        return JSON.stringify({restored:false});
      }
    })()''');
    try {
      var value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      return value is Map && value['restored'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> instalarReportesV3(EvaluarJavascript evaluateJavascript) async {
    final decoded = _decode(await evaluateJavascript(_v3BootstrapScript()));
    return decoded?['state'] == 'ready';
  }

  Future<bool> actualizar(EvaluarJavascript evaluateJavascript) async {
    if (!await restaurarPantallaOriginal(evaluateJavascript)) return false;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await evaluateJavascript(r'''(() => {
      const main = document.querySelector('iframe#Main');
      const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
      const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
      const win = escolares?.contentWindow;
      const grid = escolares?.contentDocument?.querySelector('#list9');
      if (win?.jQuery && grid) win.jQuery(grid).trigger('reloadGrid');
      return true;
    })()''');
    return true;
  }

  Map<String, dynamic>? _decode(String raw) {
    try {
      var value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } catch (_) {
      return null;
    }
  }

  int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String _resolveRowScript(
    String contextIdArgument,
    String careerKeyArgument,
    String gridRowIdArgument,
    String careerArgument,
    String institutionArgument,
    String startYearArgument,
  ) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const contextId = $contextIdArgument;
    const careerKey = $careerKeyArgument;
    const currentGridRowId = $gridRowIdArgument;
    const careerName = $careerArgument;
    const institution = $institutionArgument;
    const startYear = $startYearArgument;
    if (!frame || !win) return JSON.stringify({state:'waiting'});
    if (win.location.host !== 'sage.entrerios.gov.ar') return JSON.stringify({state:'incompatible'});
    if (!win.location.pathname.endsWith('/alumnos_v2/NS_historial_alumnado.php')) return JSON.stringify({state:'waiting'});
    const gridElement = frame.querySelector('#list9');
    if (!gridElement || !win.jQuery?.fn?.jqGrid) return JSON.stringify({state:'waiting'});
    const grid = win.jQuery(gridElement);
    let rowIds = [];
    try { rowIds = (grid.jqGrid('getDataIDs') || []).map(String); } catch (_) {}
    const normalize = value => String(value ?? '').trim().replace(/\\s+/g, ' ').toLowerCase();
    const rowData = rowId => {
      let data = {};
      try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
      return data;
    };
    const rowContext = data => String(
      data.idsuborgCarrera ?? data.idsuborg_carrera ?? data.careerContextId ?? '',
    );
    const rowCareerKey = data => [
      data.carrera ?? '', data.suborganizacion ?? '', data.anio_inscripcion ?? '',
    ].map(value => normalize(value)).join('|');
    const uniqueMatch = predicate => {
      const matches = rowIds.filter(rowId => predicate(rowData(rowId), rowId));
      return matches.length === 1 ? matches[0] : matches.length > 1 ? 'ambiguous' : '';
    };
    let resolvedId = contextId === '' ? '' : uniqueMatch(data => rowContext(data) === contextId);
    if (resolvedId === 'ambiguous') return JSON.stringify({state:'career_ambiguous'});
    if (!resolvedId) {
      resolvedId = uniqueMatch(data => (careerKey !== '' && rowCareerKey(data) === careerKey) || (
        normalize(data.carrera) === normalize(careerName) &&
        normalize(data.suborganizacion) === normalize(institution) &&
        (startYear === '' || normalize(data.anio_inscripcion) === normalize(startYear))
      ));
    }
    if (resolvedId === 'ambiguous') return JSON.stringify({state:'career_ambiguous'});
    if (!resolvedId && rowIds.map(String).includes(String(currentGridRowId))) resolvedId = String(currentGridRowId);
    if (!resolvedId) return JSON.stringify({state:'career_not_found'});
    const masterRow = frame.getElementById(String(resolvedId));
    return JSON.stringify({
      state: masterRow?.matches('tr.jqgrow') ? 'resolved' : 'master_dom_row_not_found',
      gridRowId:String(resolvedId), masterFound:Boolean(masterRow)
    });
  })()''';

  ResultadoSubgrillaSage _parseSubgridResult(String raw) {
    final decoded = _decode(raw);
    return ResultadoSubgrillaSage(
      estado: switch (decoded?['state']?.toString()) {
        'expanded_ready' => EstadoSubgrillaSage.expandedReady,
        'expanded_loading' => EstadoSubgrillaSage.expandedLoading,
        'collapsed' => EstadoSubgrillaSage.collapsed,
        'stale_subgrid' => EstadoSubgrillaSage.staleSubgrid,
        'career_not_found' => EstadoSubgrillaSage.missing,
        'career_ambiguous' => EstadoSubgrillaSage.careerAmbiguous,
        'master_row_not_found' ||
        'master_dom_row_not_found' => EstadoSubgrillaSage.missing,
        _ => EstadoSubgrillaSage.error,
      },
      gridRowId: decoded?['gridRowId']?.toString(),
      dynamicTableId: decoded?['dynamicTableId']?.toString(),
      masterFound: decoded?['masterFound'] == true,
      expanded: decoded?['expanded'] == true,
      dynamicTableFound: decoded?['dynamicTableFound'] == true,
      b2Ready: decoded?['b2Ready'] == true,
      pagerFound: decoded?['pagerFound'] == true,
      academicButtonFound: decoded?['academicButtonFound'] == true,
      transcriptButtonFound: decoded?['transcriptButtonFound'] == true,
      recordButtonFound: decoded?['recordButtonFound'] == true,
      expandCalled: decoded?['expandCalled'] == true,
    );
  }

  static String _prepareSubgridScript(
    String contextIdArgument,
    String careerKeyArgument,
    String gridRowIdArgument,
    String careerArgument,
    String institutionArgument,
    String startYearArgument,
    String titleArgument,
    bool allowExpand,
  ) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const contextId = $contextIdArgument;
    const careerKey = $careerKeyArgument;
    const currentGridRowId = $gridRowIdArgument;
    const careerName = $careerArgument;
    const institution = $institutionArgument;
    const startYear = $startYearArgument;
    const reportTitle = $titleArgument;
    const allowExpand = ${allowExpand ? 'true' : 'false'};
    if (!frame || !win) return JSON.stringify({state:'waiting'});
    if (win.location.host !== 'sage.entrerios.gov.ar') return JSON.stringify({state:'incompatible'});
    if (!win.location.pathname.endsWith('/alumnos_v2/NS_historial_alumnado.php')) return JSON.stringify({state:'waiting'});
    const gridElement = frame.querySelector('#list9');
    if (!gridElement || !win.jQuery?.fn?.jqGrid) return JSON.stringify({state:'waiting'});
    const grid = win.jQuery(gridElement);
    let rowIds = [];
    try { rowIds = (grid.jqGrid('getDataIDs') || []).map(String); } catch (_) {}
    const normalize = value => String(value ?? '').trim().replace(/\\s+/g, ' ').toLowerCase();
    const rowData = rowId => {
      let data = {};
      try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
      return data;
    };
    const rowContext = data => String(
      data.idsuborgCarrera ?? data.idsuborg_carrera ?? data.careerContextId ?? '',
    );
    const rowCareerKey = data => [
      data.carrera ?? '', data.suborganizacion ?? '', data.anio_inscripcion ?? '',
    ].map(value => normalize(value)).join('|');
    const uniqueMatch = predicate => {
      const matches = rowIds.filter(rowId => predicate(rowData(rowId), rowId));
      return matches.length === 1 ? matches[0] : matches.length > 1 ? 'ambiguous' : '';
    };
    let gridRowId = contextId === '' ? '' : uniqueMatch(data => rowContext(data) === contextId);
    if (gridRowId === 'ambiguous') return JSON.stringify({state:'career_ambiguous'});
    if (!gridRowId) {
      gridRowId = uniqueMatch(data => (careerKey !== '' && rowCareerKey(data) === careerKey) || (
        normalize(data.carrera) === normalize(careerName) &&
        normalize(data.suborganizacion) === normalize(institution) &&
        (startYear === '' || normalize(data.anio_inscripcion) === normalize(startYear))
      ));
    }
    if (gridRowId === 'ambiguous') return JSON.stringify({state:'career_ambiguous'});
    if (!gridRowId && rowIds.map(String).includes(String(currentGridRowId))) gridRowId = String(currentGridRowId);
    if (!gridRowId) return JSON.stringify({state:'career_not_found'});
    const masterRow = frame.getElementById(String(gridRowId));
    if (!masterRow?.matches('tr.jqgrow')) return JSON.stringify({state:'master_dom_row_not_found', gridRowId:String(gridRowId)});
    const expansionCell = masterRow.querySelector('td.ui-sgcollapsed');
    const expanded = Boolean(expansionCell?.classList.contains('sgexpanded'));
    const subgridContainer = masterRow.nextElementSibling;
    const tables = Array.from(subgridContainer?.querySelectorAll('table') || []);
    const dynamicTable = tables.find(table => String(table.id).endsWith('_t') && table.classList.contains('scroll')) ||
      tables.find(table => String(table.id).endsWith('_t'));
    const dynamicTableFound = Boolean(dynamicTable);
    let expandCalled = false;
    if ((!expanded || !dynamicTableFound) && allowExpand) {
      try { grid.jqGrid('expandSubGridRow', String(gridRowId)); expandCalled = true; } catch (_) {}
    }
    if (!dynamicTableFound || !expanded) return JSON.stringify({
      state: expandCalled ? 'expanded_loading' : (!expanded ? 'collapsed' : 'stale_subgrid'),
      gridRowId:String(gridRowId), masterFound:true, expanded, dynamicTableFound, expandCalled
    });
    const tableApi = win.jQuery(dynamicTable);
    let initialized = true;
    try { tableApi.jqGrid('getGridParam', 'colModel'); } catch (_) { initialized = false; }
    const isVisible = element => {
      if (!element) return false;
      const style = element.ownerDocument.defaultView?.getComputedStyle(element);
      return element.getClientRects().length > 0 && style?.display !== 'none' && style?.visibility !== 'hidden' && style?.opacity !== '0';
    };
    let dataIds = [];
    let records = 0;
    try { dataIds = tableApi.jqGrid('getDataIDs') || []; records = Number(tableApi.jqGrid('getGridParam', 'records') || 0); } catch (_) {}
    const loader = frame.getElementById('load_' + dynamicTable.id);
    const b2Ready = initialized && !(isVisible(loader) && dataIds.length === 0 && records === 0);
    const pager = frame.getElementById('p_' + dynamicTable.id);
    const button = title => pager?.querySelector('.ui-pg-button[title="' + title + '"]');
    const academicButton = button('Imprimir la Situación Académica del alumno en la carrera');
    const transcriptButton = button('Imprimir listado de materias aprobadas');
    const recordButton = button('Imprimir libreta de calificaciones');
    const pagerFound = Boolean(pager);
    const requestedButton = Boolean(
      academicButton && transcriptButton && recordButton,
    );
    return JSON.stringify({
      state: b2Ready && pagerFound && requestedButton ? 'expanded_ready' : 'expanded_loading',
      gridRowId:String(gridRowId), masterFound:true, expanded:true,
      dynamicTableFound, dynamicTableId:String(dynamicTable.id), b2Ready,
      pagerFound, academicButtonFound:Boolean(academicButton),
      transcriptButtonFound:Boolean(transcriptButton), recordButtonFound:Boolean(recordButton),
      expandCalled
    });
      })()''';

  static String _v3BootstrapScript() => r'''(() => {
    const root = window;
    const diagnosticBridge = root.SageDiagnosticBridge;
    const sendDebug = (event, fields = {}) => {
      try {
        diagnosticBridge?.postMessage(JSON.stringify({event:'v3_' + event, ...fields}));
      } catch (_) {}
    };
    const main = root.document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const escolaresWin = escolares?.contentWindow;
    const bridge = root.SageReportBridge || escolaresWin?.SageReportBridge || escolaresWin?.top?.SageReportBridge;
    if (!bridge || typeof bridge.postMessage !== 'function') {
      return JSON.stringify({state:'channel_unavailable'});
    }
    if (!escolaresWin) return JSON.stringify({state:'report_function_missing'});

    const names = [
      ['imprimir_estado_alumno', 'estado_alumno'],
      ['imprimir_analitico', 'analitico'],
      ['imprimir_examenes_rendidos', 'examenes_rendidos'],
    ];
    const targets = [
      'window.location.href', 'document.location.href', 'parent.location.href',
      'top.location.href', 'self.location.href', 'location.href',
    ];
    const hash = source => {
      let value = 2166136261;
      for (let index = 0; index < source.length; index += 1) {
        value = Math.imul(value ^ source.charCodeAt(index), 16777619) >>> 0;
      }
      return value.toString(16);
    };
    const identifier = value => /[A-Za-z0-9_$]/.test(value || '');
    const skip = (source, index) => {
      const quote = source[index];
      if (quote === '\'' || quote === '"' || quote === '`') {
        let cursor = index + 1;
        while (cursor < source.length) {
          if (source[cursor] === '\\') cursor += 2;
          else if (source[cursor] === quote) return cursor + 1;
          else cursor += 1;
        }
        return source.length;
      }
      if (quote === '/' && source[index + 1] === '/') {
        const end = source.indexOf('\n', index + 2);
        return end < 0 ? source.length : end + 1;
      }
      if (quote === '/' && source[index + 1] === '*') {
        const end = source.indexOf('*/', index + 2);
        return end < 0 ? source.length : end + 2;
      }
      return index;
    };
    const whitespace = (source, index) => {
      while (index < source.length && /\s/.test(source[index])) index += 1;
      return index;
    };
    const expressionEnd = (source, start) => {
      let parentheses = 0;
      let brackets = 0;
      let braces = 0;
      let index = start;
      while (index < source.length) {
        const next = skip(source, index);
        if (next !== index) { index = next; continue; }
        const character = source[index];
        if (character === '(') parentheses += 1;
        else if (character === ')' && parentheses > 0) parentheses -= 1;
        else if (character === '[') brackets += 1;
        else if (character === ']' && brackets > 0) brackets -= 1;
        else if (character === '{') braces += 1;
        else if (character === '}') {
          if (braces > 0) braces -= 1;
          else if (parentheses === 0 && brackets === 0) return index;
        } else if (character === ';' && parentheses === 0 && brackets === 0 && braces === 0) {
          return index;
        }
        index += 1;
      }
      return source.length;
    };
    const assignments = source => {
      const found = [];
      let index = 0;
      while (index < source.length) {
        const next = skip(source, index);
        if (next !== index) { index = next; continue; }
        const target = targets.find(value => {
          if (!source.startsWith(value, index)) return false;
          return !identifier(index === 0 ? '' : source[index - 1]);
        });
        if (!target) { index += 1; continue; }
        let equals = whitespace(source, index + target.length);
        if (source[equals] !== '=' || source[equals + 1] === '=') {
          index += target.length;
          continue;
        }
        const start = whitespace(source, equals + 1);
        const end = expressionEnd(source, start);
        found.push({target, targetStart:index, expressionStart:start, expressionEnd:end});
        index = end;
      }
      return found;
    };
    const unsafeMechanism = source => {
      const lower = source.toLowerCase();
      return ['window.open', 'form.submit', 'requestsubmit', 'fetch(',
        'xmlhttprequest', 'location.assign', 'location.replace']
        .some(value => lower.includes(value));
    };
    const installEmitter = () => {
      if (escolaresWin.__flutterCaptureSageReportV3?.__sageV3Emitter) return true;
      escolaresWin.__flutterCaptureSageReportV3 = function(reportType, rawValue) {
        try {
          sendDebug('patched_function_called', {value:true});
          const resolved = new URL(String(rawValue), escolaresWin.location.href);
          const normalizedPath = resolved.pathname.toLowerCase().replace(/\/+$/, '');
          const allowedPaths = new Set([
            '/alumnos_v2/ns_reporte_estado_alumno_carrera.php',
            '/alumnos_v2/ns_reporte_analitico.php',
            '/alumnos_v2/ns_reporte_examenes_rendidos.php',
          ]);
          const schemeAllowed = resolved.protocol === 'https:';
          const hostAllowed = resolved.hostname.toLowerCase() === 'sage.entrerios.gov.ar';
          const pathAllowed = allowedPaths.has(normalizedPath);
          sendDebug('scheme_allowed', {value:schemeAllowed});
          sendDebug('host_allowed', {value:hostAllowed});
          sendDebug('path_allowed', {value:pathAllowed});
          if (!schemeAllowed || !hostAllowed || !pathAllowed) {
            bridge.postMessage(JSON.stringify({
              type:'sage_report_rejected', reportType, schemeAllowed, hostAllowed,
              pathAllowed, lastSegment:resolved.pathname.split('/').filter(Boolean).pop()?.toLowerCase() || '',
            }));
            return;
          }
          bridge.postMessage(JSON.stringify({type:'sage_report_url', reportType, url:resolved.href}));
          sendDebug('bridge_message_sent', {value:true});
        } catch (_) {
          bridge.postMessage(JSON.stringify({type:'sage_report_capture_error', reportType}));
        }
      };
      escolaresWin.__flutterCaptureSageReportV3.__sageV3Emitter = true;
      return true;
    };
    const patchOne = (name, reportType) => {
      const original = escolaresWin[name];
      if (typeof original !== 'function') return {state:'report_function_missing', name};
      if (original.__flutterSageReportPatchedV3) return {state:'patched', name, reused:true};
      const source = Function.prototype.toString.call(original);
      const found = assignments(source);
      const functionHash = hash(source);
      sendDebug('function_found', {value:true, name});
      sendDebug('function_hash', {value:functionHash, name});
      sendDebug('assignment_count', {value:found.length, name});
      if (found.length === 0) return {state:'report_function_structure_changed', name};
      if (found.length !== 1) return {state:'report_function_transform_unsafe', name};
      if (unsafeMechanism(source)) return {state:'report_function_transform_unsafe', name};
      const assignment = found[0];
      const transformedSource = source.slice(0, assignment.targetStart) +
        'return window.__flutterCaptureSageReportV3(' + JSON.stringify(reportType) + ', ' +
        source.slice(assignment.expressionStart, assignment.expressionEnd) + ')' +
        source.slice(assignment.expressionEnd);
      let transformed;
      try {
        transformed = escolaresWin.Function('return (' + transformedSource + ')')();
      } catch (_) {
        return {state:'report_function_compile_blocked', name};
      }
      if (typeof transformed !== 'function') return {state:'report_function_compile_blocked', name};
      transformed.__flutterSageReportPatchedV3 = true;
      transformed.__flutterSageOriginalHash = functionHash;
      transformed.__flutterSageOriginalFunction = original;
      escolaresWin[name] = transformed;
      sendDebug('transform_safe', {value:true, name});
      sendDebug('compile_success', {value:true, name});
      sendDebug('patch_installed', {value:true, name});
      return {state:'patched', name};
    };
    root.__flutterInstallSageReportV3 = () => {
      if (!installEmitter()) return {state:'report_function_patch_failed'};
      const results = names.map(item => patchOne(item[0], item[1]));
      const failed = results.find(item => item.state !== 'patched');
      if (failed) return failed;
      return {state:'ready', patched:results.length, results};
    };
    const result = root.__flutterInstallSageReportV3();
    return JSON.stringify(result);
  })()''';

  static String _reportScript(String idArgument, String titleArgument) =>
      '''(() => {
    const root = window;
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const gridRowId = $idArgument;
    const title = $titleArgument;
    if (!frame || !win?.jQuery) return JSON.stringify({state:'subgrid_not_expanded'});
    const masterRow = frame.getElementById(String(gridRowId));
    const subgridContainer = masterRow?.nextElementSibling;
    const dynamicTable = Array.from(subgridContainer?.querySelectorAll('table') || [])
      .find(table => String(table.id).endsWith('_t'));
    if (!masterRow || !dynamicTable) return JSON.stringify({state:'subgrid_not_expanded'});
    const pager = frame.getElementById('p_' + dynamicTable.id);
    if (!pager) return JSON.stringify({state:'pager_not_found'});
    const button = pager.querySelector('.ui-pg-button[title="' + title + '"]');
    if (!button) return JSON.stringify({state:'report_button_not_found'});
    const patch = root.__flutterInstallSageReportV3?.();
    if (!patch || patch.state !== 'ready') return JSON.stringify(patch || {state:'report_function_patch_failed'});
    const inlineOnclick = Boolean(button.getAttribute('onclick')) || typeof button.onclick === 'function';
    let jqueryHandlers = false;
    try { jqueryHandlers = Boolean(win.jQuery._data?.(button, 'events')?.click?.length); } catch (_) {}
    if (jqueryHandlers) win.jQuery(button).trigger('click');
    else if (inlineOnclick) button.click();
    else return JSON.stringify({state:'click_error'});
    return JSON.stringify({state:'click_dispatched', patched:patch.patched || 0,
      functionOwner:'escolares', inlineOnclick, jqueryHandlers});
  })()''';
}
