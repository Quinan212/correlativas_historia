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
        return JSON.stringify({found:true,activated:true,mechanism:'jqgrid_ondblclickrow',frameId:target.frameId,pathnameBefore:target.pathname});
      }
      const jqEvents = target.win.jQuery?._data?.(row,'events');
      if (jqEvents?.dblclick?.length) {
        target.win.jQuery(row).trigger('dblclick');
        return JSON.stringify({found:true,activated:true,mechanism:'jquery_dblclick',frameId:target.frameId,pathnameBefore:target.pathname});
      }
      row.dispatchEvent(new MouseEvent('dblclick',{bubbles:true,cancelable:true,view:target.win}));
      return JSON.stringify({found:true,activated:true,mechanism:'dom_dblclick',frameId:target.frameId,pathnameBefore:target.pathname});
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
      return JSON.stringify({found:true,activated:true,mechanism:'native_click',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
    }
    if (events?.click?.length) {
      jq(actionable).trigger('click');
      return JSON.stringify({found:true,activated:true,mechanism:'jquery_click',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
    }
    return JSON.stringify({found:true,activated:false,mechanism:'',label:wanted,frameId:item.frameId,pathnameBefore:item.pathname,matchedBy:item.exact?'exact_text':'text'});
      })()''';

  String _tabScript(String key) =>
      '''(() => {
    const wantedKey = String($key);
    const normalize = value => String(value || '').toLowerCase().normalize('NFD')
      .replace(/[\\u0300-\\u036f]/g,'').replace(/[–—]/g,'-').replace(/:/g,' - ')
      .replace(/\\s*-\\s*/g,' - ').replace(/\\s+/g,' ').trim();
    const canonicalTabKey = value => {
      const text = normalize(value);
      if (text === 'escolares') return 'escolares';
      if (text === 'nivel superior - historial' || text === 'nivel superior historial') return 'nivel_superior_historial';
      if (text === 'historial del alumnado') return 'historial_del_alumnado';
      if (text === 'personales') return 'personales';
      if (text === 'servicios') return 'servicios';
      if (text === 'transporte') return 'transporte';
      return null;
    };
    const visible = element => {
      const style = element?.ownerDocument?.defaultView?.getComputedStyle(element);
      const rect = element?.getClientRects?.();
      return Boolean(rect?.length && style?.display !== 'none' && style?.visibility !== 'hidden' && style?.opacity !== '0');
    };
    const seen = new Set();
    const docs = [];
    const visit = (win, depth = 0) => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      try {
        docs.push({win, doc:win.document, frameId:String(win.frameElement?.id || ''), frameName:String(win.frameElement?.name || ''), pathname:String(win.location.pathname || '')});
        win.document.querySelectorAll('iframe').forEach(frame => { try { visit(frame.contentWindow, depth + 1); } catch (_) {} });
      } catch (_) {}
    };
    visit(window);
    const target = docs.find(item =>
      (item.frameId.toLowerCase() === 'frm_alumnos' || item.frameName.toLowerCase() === 'frm_alumnos') &&
      item.pathname.toLowerCase() === '/dic/tabs.php'
    ) || docs.find(item => item.pathname.toLowerCase() === '/dic/tabs.php');
    if (!target) return JSON.stringify({found:false,activated:false});
    const candidates = [...target.doc.querySelectorAll('a.tab_a,a[onclick],[role="tab"],button[onclick]')]
      .map(node => ({node,key:canonicalTabKey(node.textContent || node.innerText || node.value),rendered:visible(node),isTab:node.matches?.('a.tab_a,[role="tab"]') === true}))
      .filter(item => item.key === wantedKey)
      .sort((a,b) => Number(b.isTab)-Number(a.isTab) || Number(b.rendered)-Number(a.rendered));
    const candidate = candidates[0];
    if (!candidate) return JSON.stringify({found:false,activated:false,frameId:target.frameId,pathnameBefore:target.pathname,matchedBy:wantedKey});
    const actionable = candidate.node.closest?.('a.tab_a,a[href],[onclick],[role="tab"],button') || candidate.node;
    if (typeof actionable.click === 'function') {
      actionable.click();
      return JSON.stringify({found:true,activated:true,mechanism:'native_click',frameId:target.frameId || target.frameName,pathnameBefore:target.pathname,matchedBy:wantedKey});
    }
    const jq = target.win.jQuery;
    const events = jq?._data?.(actionable,'events');
    if (events?.click?.length) {
      jq(actionable).trigger('click');
      return JSON.stringify({found:true,activated:true,mechanism:'jquery_click',frameId:target.frameId || target.frameName,pathnameBefore:target.pathname,matchedBy:wantedKey});
    }
    return JSON.stringify({found:true,activated:false,mechanism:'',frameId:target.frameId || target.frameName,pathnameBefore:target.pathname,matchedBy:wantedKey});
  })()''';
}
