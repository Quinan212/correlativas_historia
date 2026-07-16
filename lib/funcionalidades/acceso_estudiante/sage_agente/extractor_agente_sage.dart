import 'dart:convert';

import '../sage_legajo/extractor_legajo_sage.dart';
import 'modelos_agente_sage.dart';

class ExtractorAgenteSage {
  const ExtractorAgenteSage(this._evaluateJavascript);

  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<PortadaAgenteSage?> extraer() async {
    try {
      final value = _decode(await _evaluateJavascript(_homeScript));
      if (value['found'] != true) return null;
      return PortadaAgenteSage(
        accesosSuperiores: _list(value, 'topAccesses'),
        modulos: _list(value, 'modules'),
        submodulos: _list(value, 'submodules'),
        informes: _list(value, 'reports'),
        frameId: value['frameId']?.toString() ?? '',
        pathname: value['pathname']?.toString() ?? '',
        shellPathname: value['shellPathname']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  Future<MenuLegajoAlumnoAgenteSage> extraerLegajoUnicoAlumno() async {
    try {
      var value = _decode(await _evaluateJavascript(_luaMenuScript));
      var options = _list(value, 'options');
      if (options.isEmpty && value['buttonFound'] == true) {
        await _evaluateJavascript(_openLuaMenuScript);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        value = _decode(await _evaluateJavascript(_luaMenuScript));
        options = _list(value, 'options');
      }
      return MenuLegajoAlumnoAgenteSage(
        opciones: options,
        shellPathname: value['shellPathname']?.toString() ?? '',
        menuEncontrado: value['menuFound'] == true,
      );
    } catch (_) {
      return const MenuLegajoAlumnoAgenteSage();
    }
  }

  static Map<String, dynamic> _decode(String raw) {
    dynamic value = jsonDecode(raw);
    if (value is String) value = jsonDecode(value);
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  static List<OpcionAgenteSage> _list(
    Map<String, dynamic> value,
    String key,
  ) => [
    for (final item in value[key] as List<dynamic>? ?? const [])
      if (item is Map)
        OpcionAgenteSage(
          claveCanonica: item['key']?.toString() ?? '',
          etiqueta: item['label']?.toString() ?? '',
          ruta: item['path']?.toString(),
          sigla: item['shortLabel']?.toString(),
          icono: _iconForKey(item['key']?.toString() ?? ''),
        ),
  ];

  static int _iconForKey(String key) {
    if (key.contains('legajo_unico_alumno') || key == 'legajo_alumnos') {
      return 0xe151;
    }
    if (key.contains('legajo_unico_personal') || key == 'legajo_agentes') {
      return 0xe7fd;
    }
    if (key == 'mi_credencial') return 0xe8a1;
    if (key.contains('informe') || key.contains('listado')) return 0xe8d2;
    if (key.contains('inscripcion')) return 0xe150;
    return 0xe8b6;
  }

  static const _homeScript = r'''(() => {
    const normalize = value => String(value || '').toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/\s+/g, ' ').trim();
    const compact = value => normalize(value).replace(/[^a-z0-9]+/g, ' ').trim();
    const canonical = value => {
      const t = normalize(value);
      const c = compact(value);
      if (c === 'l u p') return 'legajo_unico_personal_superior';
      if (c === 'l u a') return 'legajo_unico_alumno_superior';
      if (t === 'agenda') return 'agenda';
      if (t === 'legajo unico personal') return 'legajo_unico_personal';
      if (t === 'consultas') return 'consultas';
      if (t.includes('listado complementario anexo')) return 'listado_complementario';
      if (t.includes('reclamos listado complementario')) return 'reclamos';
      if (t === 'formulario de agentes') return 'formulario_agentes';
      if (t === 'traslado') return 'traslado';
      if (t === 'declaracion jurada de prestacion de servicios') return 'declaracion_jurada';
      if (t === 'horas extras personales') return 'horas_extras';
      if (t === 'documentos y manuales') return 'documentos';
      if (t.includes('listado complementario - definitivo')) return 'informe_listado_definitivo';
      if (t.includes('listado complementario prioritario')) return 'informe_listado_prioritario';
      return null;
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
    const shell = contexts.find(item => item.path.toLowerCase() === '/pregase/index.php')
      || contexts.find(item => item.doc.querySelector('button.menuItem,button.menuItemMobile'))
      || contexts[0];
    const home = contexts.find(item => {
      const body = normalize(item.doc.body?.innerText || '');
      return body.includes('modulos') && [...item.doc.querySelectorAll('a[href],button')]
        .some(node => normalize(node.textContent) === 'legajo unico personal');
    });
    const topAccesses = [];
    if (shell) {
      const used = new Set();
      shell.doc.querySelectorAll('button.menuItem,button.menuItemMobile').forEach(node => {
        const raw = String(node.textContent || '').replace(/\s+/g, ' ').trim();
        const c = compact(raw);
        let key = null;
        let label = null;
        let shortLabel = null;
        if (c === 'l u p' || normalize(raw) === 'legajo unico personal') {
          key = 'legajo_unico_personal_superior';
          label = 'Legajo Único Personal';
          shortLabel = 'L.U.P.';
        } else if (c === 'l u a' || normalize(raw) === 'legajo unico alumno') {
          key = 'legajo_unico_alumno_superior';
          label = 'Legajo Único Alumno';
          shortLabel = 'L.U.A.';
        }
        if (!key || used.has(key)) return;
        used.add(key);
        topAccesses.push({key, label, shortLabel, path:null});
      });
    }
    const all = [];
    if (home) {
      home.doc.querySelectorAll('a[href],button').forEach(node => {
        const label = String(node.textContent || '').replace(/\s+/g, ' ').trim();
        const key = canonical(label);
        if (!key || key.endsWith('_superior') || all.some(item => item.key === key)) return;
        let path = null;
        try {
          const href = node.getAttribute('href');
          if (href) path = new URL(href, home.win.location.href).pathname || null;
        } catch (_) {}
        all.push({key, label:label.slice(0, 160), path});
      });
    }
    const moduleKeys = ['agenda', 'legajo_unico_personal', 'consultas'];
    const submoduleKeys = [
      'listado_complementario', 'reclamos', 'formulario_agentes',
      'traslado', 'declaracion_jurada', 'horas_extras', 'documentos'
    ];
    const reportKeys = ['informe_listado_definitivo', 'informe_listado_prioritario'];
    const select = keys => all.filter(item => keys.includes(item.key));
    return JSON.stringify({
      found:Boolean(home),
      frameId:home?.win.frameElement?.id || 'root',
      pathname:home?.path || '',
      shellPathname:shell?.path || '',
      topAccesses,
      modules:select(moduleKeys),
      submodules:select(submoduleKeys),
      reports:select(reportKeys),
    });
  })()''';

  static const _luaMenuScript = r'''(() => {
    const normalize = value => String(value || '').toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/\s+/g, ' ').trim();
    const compact = value => normalize(value).replace(/[^a-z0-9]+/g, ' ').trim();
    const definitions = [
      ['legajo_alumnos', 'legajo alumnos'],
      ['certificado_alumno_regular_ns', 'certificado de alumno regular. n. superior'],
      ['inscripcion_nueva_materia_ns', 'inscripcion a una nueva materia (nivel superior)'],
      ['mis_inscripciones_anuales', 'mis inscripciones anuales'],
      ['inscripcion_anual_obligatoria_ns', 'inscripcion anual obligatoria (nivel superior)'],
      ['consulta_tutor_alumnos', 'consulta para tutor/alumnos'],
      ['notas_por_alumnos', 'notas por alumnos'],
    ];
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
    if (!shell) return JSON.stringify({buttonFound:false, menuFound:false, options:[]});
    const buttons = [...shell.doc.querySelectorAll('button.menuItem,button.menuItemMobile')];
    const button = buttons.find(node => {
      const text = normalize(node.textContent);
      return compact(node.textContent) === 'l u a' || text === 'legajo unico alumno';
    }) || null;
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
    const menu = resolveMenu(button);
    const roots = menu ? [menu] : [shell.doc];
    const options = [];
    const used = new Set();
    roots.forEach(root => root.querySelectorAll('a,button,[role="menuitem"]').forEach(node => {
      const label = String(node.textContent || '').replace(/\s+/g, ' ').trim();
      const text = normalize(label);
      const definition = definitions.find(item => text === item[1]);
      if (!definition || used.has(definition[0])) return;
      used.add(definition[0]);
      let path = null;
      try {
        const href = node.getAttribute('href');
        if (href) path = new URL(href, shell.win.location.href).pathname || null;
      } catch (_) {}
      options.push({key:definition[0], label, path});
    }));
    return JSON.stringify({
      buttonFound:Boolean(button),
      menuFound:Boolean(menu),
      shellPathname:shell.path,
      options,
    });
  })()''';

  static const _openLuaMenuScript = r'''(() => {
    const normalize = value => String(value || '').toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, ' ').trim();
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
    const button = shell ? [...shell.doc.querySelectorAll('button.menuItem,button.menuItemMobile')]
      .find(node => {
        const text = String(node.textContent || '').toLowerCase()
          .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
          .replace(/\s+/g, ' ').trim();
        return normalize(node.textContent) === 'l u a' || text === 'legajo unico alumno';
      }) : null;
    if (!button) return JSON.stringify({found:false, activated:false});
    try {
      button.click();
      return JSON.stringify({found:true, activated:true});
    } catch (_) {
      return JSON.stringify({found:true, activated:false});
    }
  })()''';
}
