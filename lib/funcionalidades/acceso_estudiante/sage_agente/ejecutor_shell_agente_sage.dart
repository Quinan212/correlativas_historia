import 'dart:convert';

import '../sage_legajo/extractor_legajo_sage.dart';
import 'modelos_agente_sage.dart';

class ResultadoAccionShellAgenteSage {
  const ResultadoAccionShellAgenteSage({
    required this.found,
    required this.activated,
    this.menuFound = false,
    this.matchedBy = '',
  });

  final bool found;
  final bool activated;
  final bool menuFound;
  final String matchedBy;

  bool get success => found && activated;
}

class EjecutorShellAgenteSage {
  const EjecutorShellAgenteSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<ResultadoAccionShellAgenteSage> abrirOpcionLegajoAlumno(
    OpcionAgenteSage opcion,
  ) async {
    try {
      final raw = await _evaluateJavascript(_script(opcion.etiqueta));
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        return ResultadoAccionShellAgenteSage(
          found: value['found'] == true,
          activated: value['activated'] == true,
          menuFound: value['menuFound'] == true,
          matchedBy: value['matchedBy']?.toString() ?? '',
        );
      }
    } catch (_) {}
    return const ResultadoAccionShellAgenteSage(found: false, activated: false);
  }

  static String _script(String label) =>
      '''(() => {
    const wanted = ${jsonEncode(label)};
    const normalize = value => String(value || '').toLowerCase()
      .normalize('NFD').replace(/[\\u0300-\\u036f]/g, '')
      .replace(/\\s+/g, ' ').trim();
    const compact = value => normalize(value).replace(/[^a-z0-9]+/g, ' ').trim();
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
    const shell = contexts.find(item => item.path.toLowerCase() === '/pregase/index.php')
      || contexts.find(item => item.doc.querySelector('button.menuItem,button.menuItemMobile'))
      || contexts[0];
    if (!shell) return JSON.stringify({found:false, activated:false, menuFound:false});
    const luaButton = [...shell.doc.querySelectorAll('button.menuItem,button.menuItemMobile')]
      .find(node => compact(node.textContent) === 'l u a' || normalize(node.textContent) === 'legajo unico alumno') || null;
    const resolveMenu = control => {
      if (!control) return null;
      const id = control.getAttribute('aria-controls');
      if (id) {
        const byId = shell.doc.getElementById(id);
        if (byId) return byId;
      }
      const target = control.getAttribute('data-bs-target') || control.getAttribute('data-target');
      if (target?.startsWith('#')) {
        const byTarget = shell.doc.querySelector(target);
        if (byTarget) return byTarget;
      }
      const parent = control.closest('.dropdown,.btn-group,li,nav,div');
      const nested = parent?.querySelector('.dropdown-menu,[role="menu"]');
      if (nested) return nested;
      let sibling = control.nextElementSibling;
      while (sibling) {
        if (sibling.matches?.('.dropdown-menu,[role="menu"]')) return sibling;
        sibling = sibling.nextElementSibling;
      }
      return null;
    };
    let menu = resolveMenu(luaButton);
    if (luaButton && menu && !menu.classList.contains('show')) {
      try { luaButton.click(); } catch (_) {}
      menu = resolveMenu(luaButton) || menu;
    }
    const roots = menu ? [menu] : [shell.doc];
    const candidates = [];
    roots.forEach(root => root.querySelectorAll('a,button,[role="menuitem"]').forEach(node => {
      const text = normalize(node.textContent || node.value);
      if (text !== normalize(wanted)) return;
      const href = node.getAttribute?.('href');
      let path = '';
      try { if (href) path = new URL(href, shell.win.location.href).pathname; } catch (_) {}
      candidates.push({node, text, path, exact:true});
    }));
    if (!candidates.length) {
      return JSON.stringify({
        found:false,
        activated:false,
        menuFound:Boolean(menu),
        matchedBy:'none'
      });
    }
    const candidate = candidates[0].node;
    const actionable = candidate.matches?.('a[href],button,[role="button"],[onclick]')
      ? candidate
      : candidate.closest?.('a[href],button,[role="button"],[onclick]');
    if (!actionable) {
      return JSON.stringify({
        found:true,
        activated:false,
        menuFound:Boolean(menu),
        matchedBy:'exact_text'
      });
    }
    try {
      shell.win.setTimeout(() => {
        try { actionable.click(); } catch (_) {}
      }, 0);
      return JSON.stringify({
        found:true,
        activated:true,
        menuFound:Boolean(menu),
        matchedBy:'exact_text_in_lua'
      });
    } catch (_) {
      return JSON.stringify({
        found:true,
        activated:false,
        menuFound:Boolean(menu),
        matchedBy:'exact_text_in_lua'
      });
    }
  })()''';
}
