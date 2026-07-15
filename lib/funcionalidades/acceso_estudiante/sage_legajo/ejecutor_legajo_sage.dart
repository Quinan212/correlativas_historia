import 'dart:convert';

import 'extractor_legajo_sage.dart';
import 'modelos_legajo_sage.dart';

class EjecutorLegajoSage {
  const EjecutorLegajoSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<ResultadoAccionLegajoSage> abrirPerfil(PerfilLegajoSage perfil) =>
      _execute(
        label: '',
        rowId: perfil.rowId,
        mode: 'profile',
        expectedFrame: perfil.frameId,
        expectedPath: perfil.pathname,
      );

  Future<ResultadoAccionLegajoSage> activarSeccion(SeccionLegajoSage section) =>
      _execute(
        label: section.titulo,
        mode: 'control',
        expectedFrame: section.frameId,
        expectedPath: section.pathname,
      );

  Future<ResultadoAccionLegajoSage> activarEscolares(
    OpcionEscolarSage option,
  ) => _execute(
    label: option.titulo,
    mode: 'control',
    expectedFrame: option.frameId,
    expectedPath: option.pathname,
  );

  Future<ResultadoAccionLegajoSage> activarPestanaEscolares() =>
      _executeTab('escolares');

  Future<ResultadoAccionLegajoSage> activarNivelSuperiorHistorial() =>
      _executeTab('nivel_superior_historial');

  Future<ResultadoAccionLegajoSage> _executeTab(String key) async {
    try {
      final raw = await _evaluateJavascript(_tabScript(jsonEncode(key)));
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is Map) {
        return ResultadoAccionLegajoSage.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return const ResultadoAccionLegajoSage(
      found: false,
      activated: false,
      mechanism: '',
      frameId: '',
      pathnameBefore: '',
    );
  }

  Future<ResultadoAccionLegajoSage> _execute({
    required String label,
    required String mode,
    String rowId = '',
    String expectedFrame = '',
    String expectedPath = '',
  }) async {
    try {
      final source = _script(
        label: jsonEncode(label),
        mode: jsonEncode(mode),
        rowId: jsonEncode(rowId),
        expectedFrame: jsonEncode(expectedFrame),
        expectedPath: jsonEncode(expectedPath),
      );
      final raw = await _evaluateJavascript(source);
      dynamic decoded = jsonDecode(raw);
      if (decoded is String) decoded = jsonDecode(decoded);
      if (decoded is Map) {
        return ResultadoAccionLegajoSage.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return const ResultadoAccionLegajoSage(
      found: false,
      activated: false,
      mechanism: '',
      frameId: '',
      pathnameBefore: '',
    );
  }

  String _script({
    required String label,
    required String mode,
    required String rowId,
    required String expectedFrame,
    required String expectedPath,
  }) =>
      '''(() => {
    const wanted = String($label || '').toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g,'').replace(/[–—]/g,'-').replace(/:/g,' - ').replace(/\\s+/g,' ').trim();
    const type = String($mode);
    const wantedRowId = String($rowId);
    const expectedFrameValue = String($expectedFrame);
    const expectedPathValue = String($expectedPath).toLowerCase();
    const normalize = value => String(value || '').toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g,'').replace(/[–—]/g,'-').replace(/:/g,' - ').replace(/\\s+/g,' ').trim();
    const seen = new Set();
    const docs = [];
    const visit = (win, depth = 0) => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      try {
        docs.push({win, doc:win.document, frameId:win.frameElement?.id || win.frameElement?.name || (depth === 0 ? 'root' : ''), pathname:String(win.location.pathname || '')});
        win.document.querySelectorAll('iframe').forEach(frame => { try { visit(frame.contentWindow, depth + 1); } catch (_) {} });
      } catch (_) {}
    };
    visit(window);
    if (type === 'profile') {
      const target = docs.find(item => item.frameId === expectedFrameValue && item.pathname.toLowerCase() === expectedPathValue && item.doc.querySelector('#list2')) || docs.find(item => item.doc.querySelector('#list2'));
      if (!target) return JSON.stringify({found:false,activated:false});
      const grid = target.win.jQuery?.('#list2');
      let row;
      try { row = target.doc.getElementById(wantedRowId) || target.doc.querySelector('#list2 tbody tr.jqgrow[id="'+CSS.escape(wantedRowId)+'"]'); } catch (_) {}
      if (!row) return JSON.stringify({found:false,activated:false,frameId:target.frameId,pathnameBefore:target.pathname});
      const params = grid?.jqGrid?.('getGridParam') || {};
      const rowIds = grid?.jqGrid?.('getDataIDs') || [];
      const rowIndex = rowIds.map(String).indexOf(String(wantedRowId));
      const handler = params.ondblClickRow || params.onDblClickRow;
      if (typeof handler === 'function') {
        handler.call(target.doc.querySelector('#list2'), wantedRowId, rowIndex, 0, new MouseEvent('dblclick', {bubbles:true,cancelable:true,view:target.win}));
        return JSON.stringify({found:true,dispatched:true,activated:true,mechanism:'jqgrid_ondblclickrow',frameId:target.frameId,pathnameBefore:target.pathname});
      }
      const jqEvents = target.win.jQuery?._data?.(row,'events');
      if (jqEvents?.dblclick?.length) {
        target.win.jQuery(row).trigger('dblclick');
        return JSON.stringify({found:true,dispatched:true,activated:true,mechanism:'jquery_dblclick',frameId:target.frameId,pathnameBefore:target.pathname});
      }
      row.dispatchEvent(new MouseEvent('dblclick',{bubbles:true,cancelable:true,view:target.win}));
      return JSON.stringify({found:true,dispatched:true,activated:true,mechanism:'dom_dblclick',frameId:target.frameId,pathnameBefore:target.pathname});
    }
    const candidates = [];
    docs.forEach(item => {
      if (expectedFrameValue && item.frameId !== expectedFrameValue) return;
      if (expectedPathValue && item.pathname.toLowerCase() !== expectedPathValue) return;
      item.doc.querySelectorAll('a.tab_a,a[href],button,[role="button"],[onclick],td,li').forEach(node => {
        const text = normalize(node.textContent || node.value);
        if (!text || (text !== wanted && !text.includes(wanted))) return;
        candidates.push({node,win:item.win,frameId:item.frameId,pathname:item.pathname,exact:text === wanted});
      });
    });
    candidates.sort((a,b) => Number(b.exact)-Number(a.exact) || a.node.textContent.length-b.node.textContent.length);
    const item = candidates[0];
    if (!item) return JSON.stringify({found:false,activated:false});
    const actionableSelector = 'a[href],button,input[type="button"],input[type="submit"],[role="button"],[onclick]';
    let actionable = item.node.matches?.(actionableSelector) ? item.node : item.node.querySelector?.(actionableSelector);
    if (!actionable) actionable = item.node.closest?.(actionableSelector);
    if (!actionable) actionable = item.node;
    const jq = item.win.jQuery;
    const events = jq?._data?.(actionable,'events');
    if (actionable.matches?.(actionableSelector)) {
      actionable.click();
      return JSON.stringify({found:true,dispatched:true,activated:true,mechanism:'native_click',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
    }
    if (events?.click?.length) {
      jq(actionable).trigger('click');
      return JSON.stringify({found:true,dispatched:true,activated:true,mechanism:'jquery_click',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
    }
    return JSON.stringify({found:true,activated:false,mechanism:'',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
      })()''';

  String _tabScript(String key) =>
      '''(() => {
    const wantedKey = String($key);
    const clean = value => String(value || '').replace(/\\s+/g, ' ').trim();
    const normalize = value => clean(value).toLowerCase().normalize('NFD')
      .replace(/[\\u0300-\\u036f]/g,'').replace(/[–—]/g,'-').replace(/:/g,' - ')
      .replace(/\\s*-\\s*/g,' - ').replace(/\\s+/g,' ').trim();
    const canonicalTabKey = value => {
      const text = normalize(value);
      if (text === 'personales') return 'personales';
      if (text === 'escolares') return 'escolares';
      if (text === 'servicios') return 'servicios';
      if (text === 'historial del alumnado') return 'historial_del_alumnado';
      if (text === 'nivel superior - historial' || text === 'nivel superior historial') return 'nivel_superior_historial';
      if (text === 'transporte') return 'transporte';
      return null;
    };
    const visible = element => {
      const style = element?.ownerDocument?.defaultView?.getComputedStyle(element);
      const rect = element?.getClientRects?.();
      return Boolean(rect?.length && style?.display !== 'none' && style?.visibility !== 'hidden' && style?.opacity !== '0');
    };
    const directText = node => {
      try {
        const direct = [...node.childNodes].filter(child => child.nodeType === 3).map(child => child.nodeValue || '').join(' ');
        return normalize(direct || node.getAttribute?.('title') || node.getAttribute?.('aria-label') || node.textContent || node.innerText || node.value);
      } catch (_) { return ''; }
    };
    const knownKeysInText = value => ['personales','escolares','servicios','historial_del_alumnado','nivel_superior_historial','transporte']
      .filter(item => canonicalTabKey(value) === item);
    const seen = new Set();
    const docs = [];
    const visit = (win, depth = 0, parentFrameId = '') => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      try {
        const frameElement = win.frameElement;
        const frameId = String(frameElement?.id || '');
        const frameName = String(frameElement?.name || '');
        docs.push({win, doc:win.document, frameId, frameName, pathname:String(win.location.pathname || ''), depth, parentFrameId});
        win.document.querySelectorAll('iframe').forEach(frame => { try { visit(frame.contentWindow, depth + 1, frameId || frameName); } catch (_) {} });
      } catch (_) {}
    };
    visit(window);
    const tabSelector = 'a.tab_a,.tab_a,a[onclick],[role="tab"],button[onclick]';
    const actionableSelector = 'a.tab_a,a[href],button,[role="tab"],[onclick]';
    const resolveActionable = node => {
      if (node.matches?.(actionableSelector)) return node;
      const descendant = node.querySelector?.(actionableSelector);
      if (descendant) return descendant;
      const ancestor = node.closest?.(actionableSelector);
      if (ancestor) return ancestor;
      let current = node;
      let levels = 0;
      while (current && levels < 4) {
        const jq = current.ownerDocument?.defaultView?.jQuery;
        if (jq?._data?.(current,'events')?.click?.length) return current;
        current = current.parentElement;
        levels++;
      }
      return null;
    };
    const jqueryClickCount = (win, element) => {
      try { return Number(win.jQuery?._data?.(element,'events')?.click?.length || 0); } catch (_) { return 0; }
    };
    const candidates = [];
    docs.forEach(context => {
      let nodes = [];
      try { nodes = [...context.doc.querySelectorAll(tabSelector)]; } catch (_) { return; }
      nodes.forEach(node => {
        const sources = [node, ...(node.querySelectorAll?.('a,span,label') || [])];
        let matchedKey = null;
        let matchedNode = null;
        for (const source of sources) {
          const label = directText(source);
          const keys = knownKeysInText(label);
          if (keys.length > 1) continue;
          const key = canonicalTabKey(label);
          if (key === wantedKey) { matchedKey = key; matchedNode = source; break; }
        }
        if (!matchedKey || !matchedNode) return;
        const actionable = resolveActionable(matchedNode);
        if (!actionable) return;
        const tag = String(actionable.tagName || '').toUpperCase();
        candidates.push({win:context.win, actionable, frameId:context.frameId, frameName:context.frameName, pathname:context.pathname, depth:context.depth, key:matchedKey,
          tag, classTab:actionable.matches?.('a.tab_a,.tab_a') === true,
          hasOnclick:typeof actionable.onclick === 'function' || actionable.hasAttribute?.('onclick') === true,
          hasHref:actionable.hasAttribute?.('href') === true, rendered:visible(actionable), jqueryClickCount:jqueryClickCount(context.win,actionable)});
      });
    });
    const score = item => 1000 + (item.classTab ? 300 : 0) + (item.tag === 'A' ? 200 : 0) + (item.hasOnclick ? 150 : 0) + (item.jqueryClickCount > 0 ? 120 : 0) + (item.hasHref ? 100 : 0) + (item.pathname.toLowerCase() === '/dic/tabs.php' ? 80 : 0) + (item.rendered ? 40 : 0) + item.depth;
    candidates.sort((a,b) => score(b) - score(a));
    const candidate = candidates[0];
    if (!candidate) return JSON.stringify({found:false,dispatched:false,activated:false,mechanism:'',candidateCount:0,frameId:'',pathnameBefore:'',matchedBy:wantedKey});
    const common = {found:true,candidateCount:candidates.length,frameId:candidate.frameId || candidate.frameName,pathnameBefore:candidate.pathname,matchedBy:wantedKey,tag:candidate.tag,classTab:candidate.classTab,hasOnclick:candidate.hasOnclick,hasHref:candidate.hasHref};
    if (typeof candidate.actionable.click === 'function') {
      candidate.actionable.click();
      return JSON.stringify({...common,dispatched:true,activated:true,mechanism:'native_click'});
    }
    if (candidate.jqueryClickCount > 0) {
      candidate.win.jQuery(candidate.actionable).trigger('click');
      return JSON.stringify({...common,dispatched:true,activated:true,mechanism:'jquery_click'});
    }
    return JSON.stringify({...common,dispatched:false,activated:false,mechanism:''});
  })()''';
}
