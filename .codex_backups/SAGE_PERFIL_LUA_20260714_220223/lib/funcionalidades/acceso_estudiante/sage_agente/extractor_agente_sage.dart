import 'dart:convert';

import 'modelos_agente_sage.dart';
import '../sage_legajo/extractor_legajo_sage.dart';

class ExtractorAgenteSage {
  const ExtractorAgenteSage(this._evaluateJavascript);
  final EvaluadorJavascriptLegajoSage _evaluateJavascript;

  Future<PortadaAgenteSage?> extraer() async {
    try {
      dynamic value = jsonDecode(await _evaluateJavascript(_script));
      if (value is String) value = jsonDecode(value);
      if (value is! Map || value['found'] != true) return null;
      OpcionAgenteSage option(Map<String, dynamic> item) => OpcionAgenteSage(
        claveCanonica: item['key'] as String? ?? '',
        etiqueta: item['label'] as String? ?? '',
        ruta: item['path'] as String?,
      );
      List<OpcionAgenteSage> list(String key) => [
        for (final item in value[key] as List<dynamic>? ?? const [])
          if (item is Map) option(Map<String, dynamic>.from(item)),
      ];
      return PortadaAgenteSage(
        modulos: list('modules'),
        submodulos: list('submodules'),
        informes: list('reports'),
        frameId: value['frameId'] as String? ?? '',
        pathname: value['pathname'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static const _script = r'''(() => {
    const normalize = value => String(value || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, ' ').trim();
    const canonical = value => { const t=normalize(value); if(t==='agenda') return 'agenda'; if(t==='legajo unico personal') return 'legajo_unico_personal'; if(t==='consultas') return 'consultas'; if(t.includes('listado complementario anexo')) return 'listado_complementario'; if(t.includes('reclamos listado complementario')) return 'reclamos'; if(t==='formulario de agentes') return 'formulario_agentes'; if(t==='traslado') return 'traslado'; if(t==='declaracion jurada de prestacion de servicios') return 'declaracion_jurada'; if(t==='horas extras personales') return 'horas_extras'; if(t==='documentos y manuales') return 'documentos'; if(t==='legajo agentes') return 'legajo_agentes'; if(t==='alumnos por docente nivel superior') return 'alumnos_docente_nivel_superior'; if(t==='mi credencial') return 'mi_credencial'; if(t==='sueldo personal') return 'sueldo_personal'; if(t==='alumnos por docente') return 'alumnos_docente'; if(t.includes('listado complementario - definitivo')) return 'informe_listado_definitivo'; if(t.includes('listado complementario prioritario')) return 'informe_listado_prioritario'; return null; };
    const seen=new Set(), docs=[]; const visit=win=>{if(!win||seen.has(win))return;seen.add(win);let doc;try{doc=win.document}catch(_){return}docs.push({win,doc});doc.querySelectorAll('iframe').forEach(f=>{try{visit(f.contentWindow)}catch(_){}})}; visit(window);
    const home=docs.find(c=>{const body=normalize(c.doc.body?.innerText||''); return body.includes('modulos') && [...c.doc.querySelectorAll('a[href],button')].some(e=>canonical(e.textContent||'')==='legajo_unico_personal');});
    if(!home)return JSON.stringify({found:false});
    const all=[]; home.doc.querySelectorAll('a[href],button').forEach(e=>{const label=String(e.textContent||'').replace(/\s+/g,' ').trim();const key=canonical(label);if(!key||all.some(x=>x.key===key))return;let path=null;try{path=new URL(e.getAttribute('href')||'',home.win.location.href).pathname||null}catch(_){}all.push({key,label:label.slice(0,160),path})});
    const modules=['agenda','legajo_unico_personal','consultas']; const sub=['listado_complementario','reclamos','formulario_agentes','traslado','declaracion_jurada','horas_extras','documentos']; const reports=['informe_listado_definitivo','informe_listado_prioritario']; const split=k=>all.filter(x=>k.includes(x.key)); return JSON.stringify({found:true,frameId:home.win.frameElement?.id||'root',pathname:home.win.location.pathname,modules:split(modules),submodules:split(sub),reports:split(reports)});
  })()''';
}
