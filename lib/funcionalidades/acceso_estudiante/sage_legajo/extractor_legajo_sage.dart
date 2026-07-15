import 'dart:convert';

import 'modelos_legajo_sage.dart';

typedef EvaluadorJavascriptLegajoSage = Future<String> Function(String source);

class ExtractorLegajoSage {
  const ExtractorLegajoSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<ResultadoExtraccionLegajoSage> extraer() async {
    try {
      final raw = await _evaluateJavascript(_script);
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is! Map) return _error();
      return _decode(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return _error();
    }
  }

  ResultadoExtraccionLegajoSage _decode(Map<String, dynamic> json) {
    final stage = json['stage'] as String? ?? '';
    final state = _state(json['state'] as String? ?? 'error');
    final profiles = [
      for (final item in json['profiles'] as List<dynamic>? ?? const [])
        if (item is Map) _profile(Map<String, dynamic>.from(item)),
    ];
    final sections = [
      for (final item in json['sections'] as List<dynamic>? ?? const [])
        if (item is Map) _section(Map<String, dynamic>.from(item)),
    ];
    final options = [
      for (final item in json['schoolOptions'] as List<dynamic>? ?? const [])
        if (item is Map) _schoolOption(Map<String, dynamic>.from(item)),
    ];
    final etapa = switch (stage) {
      'listadoLegajos' => EtapaLegajoSage.miLegajo,
      'seccionesLegajo' => EtapaLegajoSage.secciones,
      'escolares' => EtapaLegajoSage.escolares,
      _ => EtapaLegajoSage.ninguna,
    };
    return ResultadoExtraccionLegajoSage(
      etapa: etapa,
      estado: state,
      firma: json['signature'] as String? ?? '',
      frameId: json['frameId'] as String? ?? '',
      pathname: json['pathname'] as String? ?? '',
      perfiles: profiles,
      secciones: sections,
      opcionesEscolares: options,
      parentFrameFound: json['parentFrameFound'] == true,
      childFrameFound: json['childFrameFound'] == true,
      childReady: json['childReady'] == true,
      historyGridFound: json['historyGridFound'] == true,
      childPathname: json['childPathname'] as String? ?? '',
      historyControlFound: json['historyControlFound'] == true,
    );
  }

  PerfilLegajoSage _profile(Map<String, dynamic> json) {
    final fields = <String, String>{};
    final rawFields = json['fields'];
    if (rawFields is Map) {
      rawFields.forEach((key, value) {
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) fields[key.toString()] = text;
      });
    }
    return PerfilLegajoSage(
      rowId: json['rowId'] as String? ?? '',
      firmaTecnica: json['signature'] as String? ?? '',
      nombreVisible: json['name'] as String? ?? '',
      camposVisibles: fields,
      frameId: json['frameId'] as String? ?? '',
      pathname: json['pathname'] as String? ?? '',
    );
  }

  SeccionLegajoSage _section(Map<String, dynamic> json) => SeccionLegajoSage(
    clave: json['key'] as String? ?? '',
    titulo: json['label'] as String? ?? '',
    firmaTecnica: json['signature'] as String? ?? '',
    frameId: json['frameId'] as String? ?? '',
    pathname: json['pathname'] as String? ?? '',
    pathnameDestino: json['targetPath'] as String?,
    controlEncontrado: json['controlFound'] != false,
  );

  OpcionEscolarSage _schoolOption(Map<String, dynamic> json) =>
      OpcionEscolarSage(
        clave: json['key'] as String? ?? '',
        titulo: json['label'] as String? ?? '',
        firmaTecnica: json['signature'] as String? ?? '',
        frameId: json['frameId'] as String? ?? '',
        pathname: json['pathname'] as String? ?? '',
        pathnameDestino: json['targetPath'] as String?,
        controlEncontrado: json['controlFound'] != false,
      );

  EstadoExtraccionLegajoSage _state(String value) => switch (value) {
    'loading' => EstadoExtraccionLegajoSage.cargando,
    'ready' => EstadoExtraccionLegajoSage.disponible,
    'empty' => EstadoExtraccionLegajoSage.vacio,
    'incompatible' => EstadoExtraccionLegajoSage.estructuraIncompatible,
    _ => EstadoExtraccionLegajoSage.error,
  };

  ResultadoExtraccionLegajoSage _error() => const ResultadoExtraccionLegajoSage(
    etapa: EtapaLegajoSage.ninguna,
    estado: EstadoExtraccionLegajoSage.error,
    firma: '',
  );

  static const _script = r'''(() => {
    const root = window;
    const seen = new Set();
    const docs = [];
    const clean = value => String(value ?? '').replace(/\s+/g, ' ').trim();
    const normalize = value => clean(value).toLowerCase().normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '').replace(/[–—]/g, '-').replace(/:/g, ' - ')
      .replace(/\s+/g, ' ').trim();
    const visible = element => {
      if (!element) return false;
      const style = element.ownerDocument.defaultView?.getComputedStyle(element);
      return element.getClientRects().length > 0 && style?.display !== 'none' &&
        style?.visibility !== 'hidden' && style?.opacity !== '0';
    };
    const hash = value => {
      let result = 2166136261;
      for (const char of String(value)) {
        result ^= char.charCodeAt(0);
        result = Math.imul(result, 16777619);
      }
      return (result >>> 0).toString(16);
    };
    const canonicalTabKey = value => {
      const text = normalize(value).replace(/\s*-\s*/g, ' - ');
      if (text === 'escolares') return 'escolares';
      if (text === 'nivel superior - historial' || text === 'nivel superior historial') return 'nivel_superior_historial';
      if (text === 'historial del alumnado') return 'historial_del_alumnado';
      if (text === 'personales') return 'personales';
      if (text === 'servicios') return 'servicios';
      if (text === 'transporte') return 'transporte';
      return null;
    };
    const tabControls = contexts => {
      const result = [];
      contexts.forEach(context => {
        let elements = [];
        try {
          elements = [...context.doc.querySelectorAll('a.tab_a,a[onclick],[role="tab"],button[onclick]')];
        } catch (_) { return; }
        elements.forEach(element => {
          const label = clean(element.textContent || element.innerText || element.value);
          const key = canonicalTabKey(label);
          if (!key) return;
          const rendered = visible(element);
          let targetPath = null;
          try {
            const href = element.getAttribute('href') || '';
            if (href && !href.toLowerCase().startsWith('javascript:')) {
              targetPath = new URL(href, context.win.location.href).pathname || null;
            }
          } catch (_) {}
          result.push({key, label:key === 'nivel_superior_historial' ? 'Nivel Superior - Historial' : label.slice(0,180), targetPath,
            signature:hash(key+'|'+context.frameId+'|'+context.pathname), frameId:context.frameId || 'root',
            pathname:context.pathname, rendered, isTab:element.matches?.('a.tab_a,[role="tab"]') === true});
        });
      });
      return result.sort((a,b) => Number(b.isTab)-Number(a.isTab) || Number(b.rendered)-Number(a.rendered) || a.frameId.localeCompare(b.frameId));
    };
    const controls = (win, labels) => {
      const result = [];
      win.document.querySelectorAll('a.tab_a,a[href],button,[role="button"],[onclick],td,li')
        .forEach(element => {
          if (!visible(element)) return;
          const label = clean(element.textContent || element.value);
          const normalized = normalize(label);
          if (!label || label.length > 180 || !labels.some(item => normalized.includes(item))) return;
          let targetPath = null;
          try { targetPath = new URL(element.getAttribute('href') || '', win.location.href).pathname || null; } catch (_) {}
          result.push({label:label.slice(0,180), targetPath, signature:hash(normalized),
            frameId:win.frameElement?.id || win.frameElement?.name || 'root',
            pathname:String(win.location.pathname || '')});
        });
      return result.filter((item, index, list) => list.findIndex(other => other.signature === item.signature) === index).slice(0, 40);
    };
    const visit = (win, depth = 0, parentFrameId = '') => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      let doc;
      try { doc = win.document; } catch (_) { return; }
      if (!doc) return;
      const pathname = String(win.location.pathname || '');
      const frameId = win.frameElement?.id || win.frameElement?.name || (depth === 0 ? 'root' : '');
      const hasList2 = Boolean(doc.querySelector('#list2'));
      const hasJqGrid = Boolean(win.jQuery?.fn?.jqGrid && hasList2);
      const isTabs = pathname.toLowerCase() === '/dic/tabs.php';
      const isSchoolFrame = String(frameId).toLowerCase() === 'frm_alumnos_escolares';
      const childReady = doc.readyState === 'interactive' || doc.readyState === 'complete';
      const historyGridFound = Boolean(doc.querySelector('#list9'));
      const historyLoaderFound = Boolean(doc.querySelector('#load_list9,[id*="load_list9"]'));
      docs.push({win, doc, pathname, frameId, parentFrameId, hasList2, hasJqGrid, isTabs, isSchoolFrame, childReady, historyGridFound, historyLoaderFound});
      doc.querySelectorAll('iframe').forEach(frame => { try { visit(frame.contentWindow, depth + 1, frameId); } catch (_) {} });
    };
    visit(root);
    const list = docs.find(item => item.hasList2 && item.hasJqGrid);
    if (list) {
      const grid = list.win.jQuery('#list2');
      let ids = [];
      let colModel = [];
      let colNames = [];
      try { ids = grid.jqGrid('getDataIDs') || []; colModel = grid.jqGrid('getGridParam','colModel') || []; colNames = grid.jqGrid('getGridParam','colNames') || []; } catch (_) {}
      const loader = list.doc.querySelector('#load_list2,[id*="load_list2"]');
      if (visible(loader) && ids.length === 0) return JSON.stringify({stage:'listadoLegajos',state:'loading',frameId:list.frameId,pathname:list.pathname,signature:list.frameId+'|'+list.pathname+'|listadoLegajos|loading'});
      const profiles = ids.map((rowId, index) => {
        let data = {};
        try { data = grid.jqGrid('getRowData', rowId) || {}; } catch (_) {}
        const fields = {};
        colModel.forEach((column, columnIndex) => {
          const name = String(column?.name || colNames[columnIndex] || '');
          const value = clean(data[name]);
          if (name && value) fields[name] = value;
        });
        const visibleValues = Object.values(fields);
        const normalizedFields = Object.entries(fields).map(([key,value]) => normalize(key)+':'+normalize(value)).join('|');
        const nameEntry = Object.entries(fields).find(([key]) => /alumno|nombre|apellido/i.test(key));
        return {rowId:String(rowId), signature:hash(String(rowId)+'|'+normalizedFields), name:clean(nameEntry?.[1] || visibleValues[0] || 'Perfil'), fields, index, frameId:list.frameId, pathname:list.pathname};
      });
      const state = profiles.length ? 'ready' : 'empty';
      return JSON.stringify({stage:'listadoLegajos',state,frameId:list.frameId,pathname:list.pathname,profiles,signature:list.frameId+'|'+list.pathname+'|listadoLegajos|'+profiles.map(item => item.signature).join(',')});
    }
    const tabs = docs.find(item => item.pathname.toLowerCase() === '/dic/tabs.php' && item.frameId.toLowerCase() === 'frm_alumnos') ||
      docs.find(item => item.pathname.toLowerCase() === '/dic/tabs.php');
    const child = docs.find(item => item.isSchoolFrame && (!tabs || !item.parentFrameId || item.parentFrameId === tabs.frameId));
    const allTabs = tabControls(docs);
    const primaryTabs = allTabs.filter(item => ['personales','escolares','servicios','transporte'].includes(item.key));
    const secondaryTabs = allTabs.filter(item => item.key === 'historial_del_alumnado' || item.key === 'nivel_superior_historial');
    if (tabs && secondaryTabs.length > 0) {
      const sections = primaryTabs.slice();
      if (!sections.some(item => item.key === 'escolares')) sections.push({key:'escolares',label:'Escolares',targetPath:null,signature:hash('escolares'),frameId:tabs.frameId,pathname:tabs.pathname,rendered:false,isTab:true,controlFound:false});
      const schoolOptions = secondaryTabs.slice();
      const hasHistory = schoolOptions.some(item => item.key === 'nivel_superior_historial');
      const ready = child?.childReady === true;
      return JSON.stringify({stage:'escolares',state:ready ? 'ready':'loading',frameId:tabs.frameId,pathname:tabs.pathname,sections,schoolOptions:schoolOptions,
        parentFrameFound:true,childFrameFound:Boolean(child),childReady:ready,historyGridFound:Boolean(child?.historyGridFound),
        childPathname:child?.pathname || '',
        historyControlFound:hasHistory,
        signature:tabs.frameId+'|'+tabs.pathname+'|escolares_disponible|'+child.pathname+'|child_ready='+ready+'|history_control='+hasHistory});
    }
    if (tabs) {
      const sections = primaryTabs.slice();
      if (!sections.some(item => item.key === 'escolares')) sections.push({key:'escolares',label:'Escolares',targetPath:null,signature:hash('escolares'),frameId:tabs.frameId,pathname:tabs.pathname,rendered:false,isTab:true,controlFound:false});
      return JSON.stringify({stage:'seccionesLegajo',state:'ready',frameId:tabs.frameId,pathname:tabs.pathname,sections,signature:tabs.frameId+'|'+tabs.pathname+'|secciones_legajo|'+sections.map(item=>item.key).sort().join(',')});
    }
    const target = docs.find(item => item.pathname.toLowerCase() === '/dic/listar2.php' || item.isTabs || item.isSchoolFrame);
    if (target) return JSON.stringify({stage:'loading',state:'loading',frameId:target.frameId,pathname:target.pathname,signature:target.frameId+'|'+target.pathname+'|loading'});
    return JSON.stringify({stage:'none',state:'error',signature:''});
  })()''';
}
