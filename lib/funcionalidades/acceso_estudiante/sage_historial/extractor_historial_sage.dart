import 'dart:convert';

import 'modelos_historial_sage.dart';

typedef EvaluarJavascript = Future<String> Function(String source);

class ExtractorHistorialSage {
  const ExtractorHistorialSage();

  Future<ResultadoExtraccionHistorial> leer(
    EvaluarJavascript evaluateJavascript,
  ) async {
    final raw = await evaluateJavascript(_readCareersScript);
    final decoded = _decode(raw);
    if (decoded == null) {
      return const ResultadoExtraccionHistorial(
        estado: EstadoHistorialSage.error,
        mensaje: 'La respuesta de SAGE no fue válida.',
      );
    }

    final state = decoded['state'];
    final screenDetected = decoded['screenDetected'] == true;
    final masterLoaderVisible = decoded['masterLoaderVisible'] == true;
    final careerRowCount = _int(decoded['careerRowCount']) ?? 0;
    if (state is String && state != 'ready') {
      return ResultadoExtraccionHistorial(
        estado: _stateFromString(state),
        mensaje: decoded['message'] as String?,
        pantallaDetectada: screenDetected,
        masterLoaderVisible: masterLoaderVisible,
        careerRowCount: careerRowCount,
      );
    }

    final rawCareers = decoded['careers'];
    if (rawCareers is! List) {
      return const ResultadoExtraccionHistorial(
        estado: EstadoHistorialSage.incompatible,
        mensaje: 'La grilla principal no tiene el esquema esperado.',
      );
    }

    final careers = rawCareers
        .whereType<Map>()
        .map(
          (row) => CarreraHistorialSage(
            gridRowId: _string(row['gridRowId'] ?? row['id']),
            internalId: _nullableString(row['internalId']),
            nombre: _string(row['career']),
            institucion: _string(row['institution']),
            anioInicio: _int(row['startYear']),
            estado: _nullableString(row['status']),
            estadoInscripcion: _nullableString(row['enrollmentStatus']),
            cursando: _int(row['inProgress']) ?? 0,
            regulares: _int(row['regular']) ?? 0,
            aprobadas: _int(row['approved']) ?? 0,
            materias: const [],
          ),
        )
        .where((career) => career.gridRowId.isNotEmpty)
        .toList(growable: false);

    return ResultadoExtraccionHistorial(
      estado: careers.isEmpty
          ? EstadoHistorialSage.vacio
          : EstadoHistorialSage.disponible,
      historial: HistorialNivelSuperiorSage(carreras: careers),
      pantallaDetectada: screenDetected,
      masterLoaderVisible: masterLoaderVisible,
      careerRowCount: careerRowCount,
    );
  }

  Future<List<MateriaHistorialSage>> leerMaterias(
    EvaluarJavascript evaluateJavascript,
    String gridRowId,
  ) async {
    final result = await leerMateriasConEstado(evaluateJavascript, gridRowId);
    return result.materias;
  }

  Future<ResultadoMateriasSage> leerMateriasConEstado(
    EvaluarJavascript evaluateJavascript,
    String gridRowId,
  ) async {
    final argument = jsonEncode(gridRowId);
    final raw = await evaluateJavascript(_readSubjectsScript(argument));
    final decoded = _decode(raw);
    final rows = decoded?['subjects'];
    if (rows is! List) {
      return ResultadoMateriasSage(
        estado: _materiasStateFromString(decoded?['state']?.toString()),
        materias: const [],
        gridRowId: gridRowId,
        dynamicTableId: decoded?['dynamicTableId']?.toString(),
        requestedGridRow: decoded?['requestedGridRow'] == true,
        masterRowFound: decoded?['masterRowFound'] == true,
        subgridContainerFound: decoded?['subgridContainerFound'] == true,
        dynamicTableFound: decoded?['dynamicTableFound'] == true,
      );
    }
    final subjects = rows
        .whereType<Map>()
        .map(
          (row) => MateriaHistorialSage(
            id: _string(row['id']),
            nombre: _string(row['name']),
            estado: _string(row['status']),
            anio: _int(row['year']),
          ),
        )
        .toList(growable: false);
    return ResultadoMateriasSage(
      estado: _materiasStateFromString(decoded?['state']?.toString()),
      materias: subjects,
      gridRowId: gridRowId,
      dynamicTableId: decoded?['dynamicTableId']?.toString(),
      subgridLoaderVisible: decoded?['subgridLoaderVisible'] == true,
      subjectRowCount: _int(decoded?['subjectRowCount']) ?? subjects.length,
      requestedGridRow: decoded?['requestedGridRow'] == true,
      masterRowFound: decoded?['masterRowFound'] == true,
      subgridContainerFound: decoded?['subgridContainerFound'] == true,
      dynamicTableFound: decoded?['dynamicTableFound'] == true,
    );
  }

  EstadoCargaMateriasSage _materiasStateFromString(String? value) {
    switch (value) {
      case 'ready':
        return EstadoCargaMateriasSage.disponible;
      case 'empty':
        return EstadoCargaMateriasSage.vacio;
      case 'loading':
        return EstadoCargaMateriasSage.cargando;
      case 'row_not_found':
        return EstadoCargaMateriasSage.filaNoEncontrada;
      case 'table_not_found':
        return EstadoCargaMateriasSage.tablaNoEncontrada;
      case 'timeout':
        return EstadoCargaMateriasSage.timeout;
      default:
        return EstadoCargaMateriasSage.error;
    }
  }

  EstadoHistorialSage _stateFromString(String value) {
    switch (value) {
      case 'waiting':
        return EstadoHistorialSage.esperandoPagina;
      case 'loading':
        return EstadoHistorialSage.cargandoCarreras;
      case 'sessionExpired':
        return EstadoHistorialSage.sesionVencida;
      case 'incompatible':
        return EstadoHistorialSage.incompatible;
      default:
        return EstadoHistorialSage.error;
    }
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

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final result = _string(value);
    return result.isEmpty ? null : result;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static const _readCareersScript = r'''(() => {
    const screenDetected = false;
    if (document.querySelector('input[type="password"]')) return JSON.stringify({state:'sessionExpired'});
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    if (!frame || !win) return JSON.stringify({state:'waiting', screenDetected});
    if (frame.querySelector('input[type="password"]')) return JSON.stringify({state:'sessionExpired'});
    if (win.location.host !== 'sage.entrerios.gov.ar') return JSON.stringify({state:'incompatible'});
    if (!win.location.pathname.endsWith('/alumnos_v2/NS_historial_alumnado.php')) return JSON.stringify({state:'waiting'});
    const detected = true;
    const grid = frame.querySelector('#list9');
    if (!grid) return JSON.stringify({state:'waiting', screenDetected:detected});
    if (!win.jQuery || !win.jQuery.fn?.jqGrid) return JSON.stringify({state:'incompatible', screenDetected:detected});

    const isVisible = (element) => {
      if (!element) return false;
      const style = element.ownerDocument.defaultView?.getComputedStyle(element);
      return element.getClientRects().length > 0 &&
        style?.display !== 'none' &&
        style?.visibility !== 'hidden' &&
        style?.opacity !== '0';
    };
    const $grid = win.jQuery(grid);
    const loader = frame.querySelector('#load_list9');
    const loaderVisible = isVisible(loader);
    let rowIds = [];
    let records = 0;
    try {
      rowIds = $grid.jqGrid('getDataIDs') || [];
      records = Number($grid.jqGrid('getGridParam', 'records') || 0);
    } catch (_) {}
    const domRows = Array.from(frame.querySelectorAll('#list9 tbody tr.jqgrow'));
    const careerRowCount = Math.max(
      rowIds.length,
      Number.isFinite(records) ? records : 0,
      domRows.length,
    );
    if (loaderVisible && careerRowCount === 0) {
      return JSON.stringify({
        state:'loading', screenDetected:detected,
        masterLoaderVisible:loaderVisible, careerRowCount, careers:[]
      });
    }

    let rows = [];
    if (rowIds.length > 0) {
      rows = rowIds.map(gridRowId => {
        let data = {};
        try { data = $grid.jqGrid('getRowData', gridRowId) || {}; } catch (_) {}
        return {...data, gridRowId:String(gridRowId), internalId:String(data.id ?? '')};
      });
    }
    if (!Array.isArray(rows) || rows.length === 0) {
      const text = (row, name) =>
        row?.querySelector(`td[aria-describedby="list9_${name}"]`)?.textContent?.trim() ?? '';
      const rowElements = rowIds.length > 0
        ? rowIds.map(rowId => domRows.find(item => String(item.id) === String(rowId)))
        : domRows;
      rows = rowElements.map((row, index) => {
        const rowId = row?.id ?? rowIds[index] ?? '';
        let data = {};
        try { data = $grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
        return {
          gridRowId: String(rowId ?? ''),
          internalId: String(data.id ?? text(row, 'id') ?? ''),
          carrera: data.carrera ?? text(row, 'carrera'),
          suborganizacion: data.suborganizacion ?? text(row, 'suborganizacion'),
          anio_inscripcion: data.anio_inscripcion ?? text(row, 'anio_inscripcion'),
          estado: data.estado ?? text(row, 'estado'),
          estado_inscripcion: data.estado_inscripcion ?? text(row, 'estado_inscripcion'),
          materias_cursando: data.materias_cursando ?? text(row, 'materias_cursando'),
          materias_regulares: data.materias_regulares ?? text(row, 'materias_regulares'),
          materias_aprobadas: data.materias_aprobadas ?? text(row, 'materias_aprobadas'),
          internalId: data.id ?? text(row, 'id')
        };
      });
    }
    const careers = rows.map(row => ({
      gridRowId: String(row.gridRowId ?? row.id ?? ''),
      internalId: String(row.internalId ?? row.id ?? ''),
      career: String(row.carrera ?? ''),
      institution: String(row.suborganizacion ?? ''),
      startYear: String(row.anio_inscripcion ?? ''),
      status: String(row.estado ?? ''),
      enrollmentStatus: String(row.estado_inscripcion ?? ''),
      inProgress: String(row.materias_cursando ?? ''),
      regular: String(row.materias_regulares ?? ''),
      approved: String(row.materias_aprobadas ?? '')
    }));
    return JSON.stringify({
      state:'ready', screenDetected:detected,
      masterLoaderVisible:loaderVisible, careerRowCount, careers
    });
  })()''';

  static String _readSubjectsScript(String idArgument) =>
      '''(() => {
    const main = document.querySelector('iframe#Main');
    const alumnos = main?.contentDocument?.querySelector('iframe#frm_alumnos');
    const escolares = alumnos?.contentDocument?.querySelector('iframe#frm_alumnos_escolares');
    const frame = escolares?.contentDocument;
    const win = escolares?.contentWindow;
    const gridRowId = $idArgument;
    if (!frame || !win?.jQuery) return JSON.stringify({state:'loading', subjects:[]});
    const gridElement = frame.querySelector('#list9');
    if (!gridElement) return JSON.stringify({state:'table_not_found', subjects:[]});
    const masterGrid = win.jQuery(gridElement);
    let existingRowIds = [];
    try { existingRowIds = masterGrid.jqGrid('getDataIDs') || []; } catch (_) {}
    if (!existingRowIds.map(String).includes(String(gridRowId))) {
      return JSON.stringify({state:'row_not_found', subjects:[], requestedGridRow:false});
    }
    const masterRow = frame.getElementById(String(gridRowId));
    if (!masterRow) return JSON.stringify({state:'row_not_found', subjects:[], requestedGridRow:true, masterRowFound:false});
    const subgridContainer = masterRow.nextElementSibling;
    const dynamicTable = Array.from(
      subgridContainer?.querySelectorAll('table') || [],
    ).find(table => String(table.id).endsWith('_t'));
    if (!dynamicTable) return JSON.stringify({state:'table_not_found', subjects:[], requestedGridRow:true, masterRowFound:true, subgridContainerFound:Boolean(subgridContainer), dynamicTableFound:false});
    const isVisible = (element) => {
      if (!element) return false;
      const style = element.ownerDocument.defaultView?.getComputedStyle(element);
      return element.getClientRects().length > 0 &&
        style?.display !== 'none' &&
        style?.visibility !== 'hidden' &&
        style?.opacity !== '0';
    };
    const tableApi = win.jQuery(dynamicTable);
    let initialized = true;
    try { tableApi.jqGrid('getGridParam', 'colModel'); } catch (_) { initialized = false; }
    if (!initialized) {
      return JSON.stringify({state:'error', subjects:[], dynamicTableId:'table[id\$="_t"]', requestedGridRow:true, masterRowFound:true, subgridContainerFound:true, dynamicTableFound:true});
    }
    const subgridLoader = frame.getElementById('load_' + dynamicTable.id);
    const subgridLoaderVisible = isVisible(subgridLoader);
    let dataIds = [];
    let records = 0;
    try {
      dataIds = tableApi.jqGrid('getDataIDs') || [];
      records = Number(tableApi.jqGrid('getGridParam', 'records') || 0);
    } catch (_) {}
    const domRows = Array.from(dynamicTable.querySelectorAll('tbody tr.jqgrow'));
    const subjectRowCount = Math.max(
      dataIds.length,
      Number.isFinite(records) ? records : 0,
      domRows.length,
    );
    if (subgridLoaderVisible && subjectRowCount === 0) {
      return JSON.stringify({state:'loading', subjects:[], subgridLoaderVisible, subjectRowCount, dynamicTableId:'table[id\$="_t"]', requestedGridRow:true, masterRowFound:true, subgridContainerFound:true, dynamicTableFound:true});
    }
    let subjects = [];
    if (dataIds.length > 0) {
      subjects = dataIds.map(subjectRowId => {
        let row = {};
        try { row = tableApi.jqGrid('getRowData', subjectRowId) || {}; } catch (_) {}
        return {
          id: String(row.id ?? subjectRowId ?? ''),
          asignatura: String(row.asignatura ?? ''),
          estado_materia: String(row.estado_materia ?? ''),
          anio_materia: String(row.anio_materia ?? ''),
        };
      });
    }
    if (!Array.isArray(subjects) || subjects.length === 0) {
      const text = (row, name) =>
        row?.querySelector('td[aria-describedby="' + dynamicTable.id + '_' + name + '"]')?.textContent?.trim() ?? '';
      subjects = domRows.map(row => ({
        id: String(row.id ?? ''),
        asignatura: text(row, 'asignatura'),
        estado_materia: text(row, 'estado_materia'),
        anio_materia: text(row, 'anio_materia'),
      }));
    }
    return JSON.stringify({state:subjects.length > 0 ? 'ready' : 'empty', subjects:subjects.map(item => ({
      id:String(item.id ?? ''), name:String(item.asignatura ?? ''), status:String(item.estado_materia ?? ''), year:String(item.anio_materia ?? '')
    })), subgridLoaderVisible, subjectRowCount, dynamicTableId:'table[id\$="_t"]', requestedGridRow:true, masterRowFound:true, subgridContainerFound:true, dynamicTableFound:true});
  })()''';
}

class ResultadoExtraccionHistorial {
  const ResultadoExtraccionHistorial({
    required this.estado,
    this.historial,
    this.mensaje,
    this.pantallaDetectada = false,
    this.masterLoaderVisible = false,
    this.careerRowCount = 0,
  });

  final EstadoHistorialSage estado;
  final HistorialNivelSuperiorSage? historial;
  final String? mensaje;
  final bool pantallaDetectada;
  final bool masterLoaderVisible;
  final int careerRowCount;
}
