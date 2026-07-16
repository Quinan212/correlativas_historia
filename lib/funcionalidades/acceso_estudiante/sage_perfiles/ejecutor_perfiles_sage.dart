import 'dart:convert';

import '../sage_legajo/extractor_legajo_sage.dart';
import 'detector_perfiles_sage.dart';
import 'modelos_perfiles_sage.dart';

class ResultadoCambioPerfilSage {
  const ResultadoCambioPerfilSage({
    required this.profile,
    this.avatarFound = false,
    this.panelOpened = false,
    this.found = false,
    this.dispatched = false,
    this.activated = false,
    this.confirmed = false,
    this.alreadyActive = false,
    this.stage = '',
  });

  final PerfilSage profile;
  final bool avatarFound;
  final bool panelOpened;
  final bool found;
  final bool dispatched;
  final bool activated;
  final bool confirmed;
  final bool alreadyActive;
  final String stage;

  bool get dispatchSucceeded =>
      alreadyActive || (avatarFound && panelOpened && found && dispatched && activated);

  bool get success => dispatchSucceeded && (confirmed || alreadyActive);

  String get errorMessage {
    if (!avatarFound) return 'No se encontró el botón de usuario de SAGE.';
    if (!panelOpened) return 'El panel “Mi perfil” no llegó a abrirse.';
    if (!found) {
      return 'Se abrió “Mi perfil”, pero no se encontró ${profile.etiquetaSage}.';
    }
    if (!dispatched || !activated) {
      return 'Se encontró ${profile.etiquetaSage}, pero su control no pudo activarse.';
    }
    return 'SAGE recibió el clic, pero no confirmó el cambio de perfil.';
  }
}

class EjecutorPerfilesSage {
  const EjecutorPerfilesSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;
  static const DetectorPerfilesSage _detector = DetectorPerfilesSage();

  Future<CapturaPerfilesSage> inspeccionar({
    bool abrirPanelSiHaceFalta = false,
  }) async {
    final first = await _evaluarCaptura(
      _inspectionScript(abrirPanelSiHaceFalta),
    );
    if (!abrirPanelSiHaceFalta || !first.avatarActivado) {
      return first;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    final second = await _evaluarCaptura(_inspectionScript(false));
    return CapturaPerfilesSage(
      perfiles: second.perfiles,
      panelAbierto: second.panelAbierto,
      avatarEncontrado: first.avatarEncontrado || second.avatarEncontrado,
      avatarActivado: first.avatarActivado || second.avatarActivado,
      documento: second.documento.isNotEmpty
          ? second.documento
          : first.documento,
    );
  }

  Future<ResultadoCambioPerfilSage> cambiar(PerfilSage perfil) async {
    final capture = await inspeccionar(abrirPanelSiHaceFalta: true);
    if (capture.activo == perfil) {
      return ResultadoCambioPerfilSage(
        profile: perfil,
        avatarFound: capture.avatarEncontrado,
        panelOpened: capture.panelAbierto,
        found: true,
        dispatched: true,
        activated: true,
        confirmed: true,
        alreadyActive: true,
        stage: 'already_active',
      );
    }

    if (!capture.avatarEncontrado || !capture.panelAbierto) {
      return ResultadoCambioPerfilSage(
        profile: perfil,
        avatarFound: capture.avatarEncontrado,
        panelOpened: capture.panelAbierto,
        found: capture.contiene(perfil),
        stage: capture.avatarEncontrado ? 'panel_not_open' : 'avatar_not_found',
      );
    }

    try {
      final raw = await _evaluateJavascript(_clickScript(perfil.etiquetaSage));
      final value = _decodeMap(raw);
      return ResultadoCambioPerfilSage(
        profile: perfil,
        avatarFound: capture.avatarEncontrado,
        panelOpened: capture.panelAbierto,
        found: value['found'] == true,
        dispatched: value['dispatched'] == true,
        activated: value['activated'] == true,
        confirmed: value['alreadyActive'] == true,
        alreadyActive: value['alreadyActive'] == true,
        stage: value['stage']?.toString() ?? 'click_result',
      );
    } catch (_) {
      return ResultadoCambioPerfilSage(
        profile: perfil,
        avatarFound: capture.avatarEncontrado,
        panelOpened: capture.panelAbierto,
        found: capture.contiene(perfil),
        stage: 'javascript_error',
      );
    }
  }

  Future<CapturaPerfilesSage> _evaluarCaptura(String source) async {
    try {
      final raw = await _evaluateJavascript(source);
      return _detector.detectar(_decodeMap(raw));
    } catch (_) {
      return const CapturaPerfilesSage(perfiles: []);
    }
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    dynamic value = jsonDecode(raw);
    if (value is String) value = jsonDecode(value);
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  static String _inspectionScript(bool openPanel) => '''(() => {
    const shouldOpen = ${openPanel ? 'true' : 'false'};
    const normalize = value => String(value || '')
      .toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g, '')
      .replace(/\\s+/g, ' ').trim();
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
    const visit = (win, depth = 0) => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      let doc;
      try { doc = win.document; } catch (_) { return; }
      contexts.push({win, doc, depth, path:String(win.location.pathname || '')});
      doc.querySelectorAll('iframe').forEach(frame => {
        try { visit(frame.contentWindow, depth + 1); } catch (_) {}
      });
    };
    visit(window);
    contexts.sort((a, b) => {
      const ar = a.path.toLowerCase() === '/pregase/index.php' ? -1 : a.depth;
      const br = b.path.toLowerCase() === '/pregase/index.php' ? -1 : b.depth;
      return ar - br;
    });
    const labelForInput = input => {
      const labels = input.labels ? [...input.labels] : [];
      const text = labels.map(label => label.textContent || '').join(' ')
        || input.closest('label')?.textContent
        || input.getAttribute('aria-label')
        || input.value
        || input.id;
      return String(text || '').replace(/\\s+/g, ' ').trim();
    };
    const collectProfiles = () => {
      const result = [];
      const used = new Set();
      for (const context of contexts) {
        context.doc.querySelectorAll('input[type="radio"]').forEach(input => {
          const label = labelForInput(input);
          const key = normalize(label);
          if (key !== 'agente' && key !== 'alumnos' || used.has(key)) return;
          used.add(key);
          result.push({
            label:key === 'agente' ? 'Agente' : 'Alumnos',
            active:input.checked === true,
            available:input.disabled !== true,
            found:true,
          });
        });
        context.doc.querySelectorAll('[role="radio"]').forEach(node => {
          const label = String(node.getAttribute('aria-label') || node.textContent || '')
            .replace(/\\s+/g, ' ').trim();
          const key = normalize(label);
          if (key !== 'agente' && key !== 'alumnos' || used.has(key)) return;
          used.add(key);
          result.push({
            label:key === 'agente' ? 'Agente' : 'Alumnos',
            active:node.getAttribute('aria-checked') === 'true' || node.classList.contains('active'),
            available:node.getAttribute('aria-disabled') !== 'true',
            found:true,
          });
        });
      }
      return result;
    };
    let profiles = collectProfiles();
    let avatar = null;
    let avatarContext = null;
    for (const context of contexts) {
      const candidates = [...context.doc.querySelectorAll(
        'button.btn-user,.btn-user,button[aria-label*="perfil" i],[title*="perfil" i]'
      )];
      avatar = candidates.find(visible) || candidates[0] || null;
      if (avatar) { avatarContext = context; break; }
    }
    const profileControlVisible = contexts.some(context =>
      [...context.doc.querySelectorAll('input[type="radio"],label,[role="radio"]')]
        .some(node => {
          const input = node.matches?.('input') ? node : node.control || node.querySelector?.('input[type="radio"]');
          const label = node.matches?.('input')
            ? labelForInput(node)
            : String(node.getAttribute?.('aria-label') || node.textContent || input?.value || '');
          const key = normalize(label);
          return (key === 'agente' || key === 'alumnos') && visible(node);
        })
    );
    let panelOpen = profileControlVisible || contexts.some(context =>
      [...context.doc.querySelectorAll('[role="dialog"],.offcanvas.show,.dropdown-menu.show,.show')]
        .some(node => visible(node) && normalize(node.textContent).includes('mi perfil'))
    );
    let avatarDispatched = false;
    if (shouldOpen && !panelOpen && avatar) {
      try {
        avatar.click();
        avatarDispatched = true;
      } catch (_) {}
    }
    return JSON.stringify({
      avatarFound:Boolean(avatar),
      avatarDispatched,
      panelOpen,
      documentPath:avatarContext?.path || '',
      profiles,
    });
  })()''';

  static String _clickScript(String label) => '''(() => {
    const wanted = ${jsonEncode(label)};
    const normalize = value => String(value || '')
      .toLowerCase().normalize('NFD').replace(/[\\u0300-\\u036f]/g, '')
      .replace(/\\s+/g, ' ').trim();
    const wantedKey = normalize(wanted);
    const contexts = [];
    const seen = new Set();
    const visit = (win, depth = 0) => {
      if (!win || seen.has(win)) return;
      seen.add(win);
      let doc;
      try { doc = win.document; } catch (_) { return; }
      contexts.push({win, doc, depth, path:String(win.location.pathname || '')});
      doc.querySelectorAll('iframe').forEach(frame => {
        try { visit(frame.contentWindow, depth + 1); } catch (_) {}
      });
    };
    visit(window);
    contexts.sort((a, b) => {
      const ar = a.path.toLowerCase() === '/pregase/index.php' ? -1 : a.depth;
      const br = b.path.toLowerCase() === '/pregase/index.php' ? -1 : b.depth;
      return ar - br;
    });
    const inputLabel = input => {
      const labels = input.labels ? [...input.labels] : [];
      return labels.map(item => item.textContent || '').join(' ')
        || input.closest('label')?.textContent
        || input.getAttribute('aria-label')
        || input.value
        || input.id;
    };
    for (const context of contexts) {
      const inputs = [...context.doc.querySelectorAll('input[type="radio"]')];
      const input = inputs.find(item => normalize(inputLabel(item)) === wantedKey);
      const labels = [...context.doc.querySelectorAll('label')];
      const labelNode = labels.find(item => normalize(item.textContent) === wantedKey);
      const roleNode = [...context.doc.querySelectorAll('[role="radio"]')]
        .find(item => normalize(item.getAttribute('aria-label') || item.textContent) === wantedKey);
      const associated = input
        || labelNode?.control
        || (labelNode?.htmlFor ? context.doc.getElementById(labelNode.htmlFor) : null)
        || labelNode?.querySelector('input[type="radio"]')
        || roleNode;
      if (!associated && !labelNode) continue;
      const alreadyActive = associated?.checked === true
        || associated?.getAttribute?.('aria-checked') === 'true'
        || associated?.classList?.contains('active') === true;
      if (alreadyActive) {
        return JSON.stringify({
          found:true, dispatched:true, activated:true,
          alreadyActive:true, stage:'already_active'
        });
      }
      try {
        let actionNode = null;
        if (labelNode && (labelNode.control || labelNode.htmlFor || labelNode.hasAttribute('onclick'))) {
          actionNode = labelNode;
        } else if (associated && typeof associated.click === 'function') {
          actionNode = associated;
        } else if (labelNode && typeof labelNode.click === 'function') {
          actionNode = labelNode;
        }
        if (!actionNode) {
          return JSON.stringify({
            found:true, dispatched:false, activated:false,
            alreadyActive:false, stage:'control_not_actionable'
          });
        }
        context.win.setTimeout(() => {
          try { actionNode.click(); } catch (_) {}
        }, 0);
        return JSON.stringify({
          found:true, dispatched:true, activated:true,
          alreadyActive:false, stage:'click_scheduled'
        });
      } catch (_) {
        return JSON.stringify({
          found:true, dispatched:false, activated:false,
          alreadyActive:false, stage:'click_error'
        });
      }
    }
    return JSON.stringify({
      found:false, dispatched:false, activated:false,
      alreadyActive:false, stage:'profile_not_found'
    });
  })()''';
}
