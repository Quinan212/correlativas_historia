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
        jsonEncode(carrera.internalId ?? ''),
        jsonEncode(carrera.nombre),
        jsonEncode(carrera.institucion),
      ),
    );
    final decoded = _decode(raw);
    return ResultadoResolverFilaSage(
      estado: switch (decoded?['state']?.toString()) {
        'resolved' => EstadoResolverFilaSage.resuelta,
        'waiting' => EstadoResolverFilaSage.esperandoPagina,
        'incompatible' => EstadoResolverFilaSage.incompatible,
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
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (!await restaurarPantallaOriginal(evaluateJavascript)) {
      return const ResultadoSubgrillaSage(estado: EstadoSubgrillaSage.missing);
    }
    final deadline = DateTime.now().add(timeout);
    var expansionRequested = false;
    ResultadoSubgrillaSage? last;
    while (DateTime.now().isBefore(deadline)) {
      final raw = await evaluateJavascript(
        _prepareSubgridScript(
          jsonEncode(carrera.internalId ?? ''),
          jsonEncode(carrera.nombre),
          jsonEncode(carrera.institucion),
          jsonEncode(reportTitle),
          !expansionRequested,
        ),
      );
      last = _parseSubgridResult(raw);
      if (last.expandCalled) expansionRequested = true;
      if (last.estado == EstadoSubgrillaSage.expandedReady) return last;
      if (last.estado == EstadoSubgrillaSage.missing) return last;
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
    );
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
    final raw = await evaluateJavascript(
      _reportScript(jsonEncode(prepared.gridRowId), jsonEncode(title)),
    );
    final state = _decode(raw)?['state']?.toString();
    return ResultadoReporteSage(
      estado: state == 'started'
          ? EstadoReporteSage.iniciado
          : EstadoReporteSage.error,
      rowResolved: true,
      subgridReady: true,
      pagerFound: prepared.pagerFound,
      reportButtonFound: true,
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

  static String _resolveRowScript(
    String internalIdArgument,
    String careerArgument,
    String institutionArgument,
  ) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const internalId = $internalIdArgument;
    const careerName = $careerArgument;
    const institution = $institutionArgument;
    if (!frame || !win) return JSON.stringify({state:'waiting'});
    if (win.location.host !== 'sage.entrerios.gov.ar') return JSON.stringify({state:'incompatible'});
    if (!win.location.pathname.endsWith('/alumnos_v2/NS_historial_alumnado.php')) return JSON.stringify({state:'waiting'});
    const gridElement = frame.querySelector('#list9');
    if (!gridElement || !win.jQuery?.fn?.jqGrid) return JSON.stringify({state:'waiting'});
    const grid = win.jQuery(gridElement);
    let rowIds = [];
    try { rowIds = (grid.jqGrid('getDataIDs') || []).map(String); } catch (_) {}
    const normalize = value => String(value ?? '').trim().replace(/\\s+/g, ' ').toLowerCase();
    let resolvedId = rowIds.find(rowId => {
      let data = {};
      try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
      return internalId !== '' && String(data.id ?? '') === String(internalId);
    });
    if (!resolvedId) {
      const wantedCareer = normalize(careerName);
      const wantedInstitution = normalize(institution);
      resolvedId = rowIds.find(rowId => {
        let data = {};
        try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
        return normalize(data.carrera) === wantedCareer && normalize(data.suborganizacion) === wantedInstitution;
      });
    }
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
        'career_not_found' ||
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
    String internalIdArgument,
    String careerArgument,
    String institutionArgument,
    String titleArgument,
    bool allowExpand,
  ) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const internalId = $internalIdArgument;
    const careerName = $careerArgument;
    const institution = $institutionArgument;
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
    let gridRowId = rowIds.find(rowId => {
      let data = {};
      try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
      return internalId !== '' && String(data.id ?? '') === String(internalId);
    });
    if (!gridRowId) {
      const wantedCareer = normalize(careerName);
      const wantedInstitution = normalize(institution);
      gridRowId = rowIds.find(rowId => {
        let data = {};
        try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
        return normalize(data.carrera) === wantedCareer && normalize(data.suborganizacion) === wantedInstitution;
      });
    }
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

  static String _reportScript(String idArgument, String titleArgument) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const gridRowId = $idArgument;
    const title = $titleArgument;
    if (!frame || !win?.jQuery) return JSON.stringify({state:'error'});
    const masterRow = frame.getElementById(String(gridRowId));
    const subgridContainer = masterRow?.nextElementSibling;
    const dynamicTable = Array.from(
      subgridContainer?.querySelectorAll('table') || [],
    ).find(table => String(table.id).endsWith('_t'));
    if (!masterRow || !dynamicTable) return JSON.stringify({state:'subgrid_not_expanded'});
    const pager = frame.getElementById('p_' + dynamicTable.id);
    if (!pager) return JSON.stringify({state:'pager_not_found'});
    const button = pager.querySelector('.ui-pg-button[title="' + title + '"]');
    if (!button) return JSON.stringify({state:'report_button_not_found'});
    try {
      const targetElements = [button, ...button.querySelectorAll('[target]')];
      const originalTargets = targetElements.map(item => item.getAttribute('target'));
      targetElements.forEach(item => item.setAttribute('target', '_self'));
      win.jQuery(button).trigger('click');
      setTimeout(() => {
        const currentPath = String(win.location.pathname || '').toLowerCase();
        if (!currentPath.endsWith('/ns_historial_alumnado.php')) {
          try { win.history.back(); } catch (_) {}
        }
      }, 2500);
      targetElements.forEach((item, index) => {
        const target = originalTargets[index];
        if (target == null) item.removeAttribute('target');
        else item.setAttribute('target', target);
      });
      return JSON.stringify({state:'started'});
    } catch (_) {
      return JSON.stringify({state:'error'});
    }
  })()''';
}
