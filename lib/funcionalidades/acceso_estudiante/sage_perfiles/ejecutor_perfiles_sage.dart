import 'dart:convert';

import '../sage_legajo/extractor_legajo_sage.dart';
import 'modelos_perfiles_sage.dart';

class ResultadoCambioPerfilSage {
  const ResultadoCambioPerfilSage({
    required this.found,
    required this.dispatched,
    required this.activated,
    required this.confirmed,
    required this.profile,
  });

  final bool found;
  final bool dispatched;
  final bool activated;
  final bool confirmed;
  final PerfilSage profile;
  bool get success => found && dispatched && activated && confirmed;
}

class EjecutorPerfilesSage {
  const EjecutorPerfilesSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<ResultadoCambioPerfilSage> cambiar(PerfilSage perfil) async {
    try {
      final raw = await _evaluateJavascript(_script(perfil.etiquetaSage));
      dynamic value = jsonDecode(raw);
      if (value is String) value = jsonDecode(value);
      if (value is Map) {
        return ResultadoCambioPerfilSage(
          found: value['found'] == true,
          dispatched: value['dispatched'] == true,
          activated: value['activated'] == true,
          confirmed: value['confirmed'] == true,
          profile: perfil,
        );
      }
    } catch (_) {}
    return ResultadoCambioPerfilSage(
      found: false,
      dispatched: false,
      activated: false,
      confirmed: false,
      profile: perfil,
    );
  }

  String _script(String label) =>
      '''(() => {
      const wanted = ${jsonEncode(label)};
    const normalize = value => String(value || '').toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g, '').replace(/\\s+/g, ' ').trim();
    const docs = []; const seen = new Set();
    const visit = win => { if (!win || seen.has(win)) return; seen.add(win); let doc; try { doc = win.document; } catch (_) { return; } docs.push({win, doc}); doc.querySelectorAll('iframe').forEach(frame => { try { visit(frame.contentWindow); } catch (_) {} }); };
    visit(window);
    let found = false; let dispatched = false; let activated = false; let confirmed = false;
    for (const context of docs) {
      const nodes = [...context.doc.querySelectorAll('input[type="radio"],label,[role="radio"]')];
      const candidate = nodes.find(node => normalize(node.textContent || node.getAttribute('aria-label') || node.getAttribute('value')) === normalize(wanted));
      if (!candidate) continue;
      found = true;
      let input = candidate.matches('input') ? candidate : candidate.control || (candidate.htmlFor ? context.doc.getElementById(candidate.htmlFor) : null) || candidate.querySelector('input');
      if (!input) input = [...context.doc.querySelectorAll('input[type="radio"]')].find(item => normalize(item.value) === normalize(wanted));
      try {
        if (candidate.matches('input')) candidate.click();
        else if (candidate.matches('label')) candidate.click();
        else if (input?.click) input.click();
        else candidate.click();
        dispatched = true; activated = true;
      } catch (_) {}
      break;
    }
    const started = Date.now();
    while (dispatched && Date.now() - started < 8000) {
      const checked = docs.some(context => [...context.doc.querySelectorAll('input[type="radio"]')].some(input => input.checked && normalize(input.value || input.id || input.closest('label')?.textContent) === normalize(wanted)));
      const agentSignature = docs.some(context => [...context.doc.querySelectorAll('a,button')].some(node => normalize(node.textContent).includes('legajo unico personal')));
      const studentSignature = docs.some(context => [...context.doc.querySelectorAll('a,button')].some(node => normalize(node.textContent).includes('legajo alumnos')));
      confirmed = checked || (normalize(wanted) === 'agente' ? agentSignature : studentSignature);
      if (confirmed) break;
      await new Promise(resolve => setTimeout(resolve, 250));
    }
    return JSON.stringify({found, dispatched, activated, confirmed});
  })()''';
}
