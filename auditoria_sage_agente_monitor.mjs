import fs from 'node:fs';
import path from 'node:path';

const output = process.argv[2] || 'C:\\Users\\alanm\\Desktop\\auditoria_sage_agente_20260714_activada';
const marker = path.join(output, 'DETENER_OBSERVACION');
const files = ['eventos.jsonl', 'network.jsonl', 'frames.jsonl', 'controles.jsonl', 'transiciones.jsonl', 'errores.jsonl'];
fs.mkdirSync(output, { recursive: true });
for (const name of files) fs.closeSync(fs.openSync(path.join(output, name), 'a'));
fs.mkdirSync(path.join(output, 'dom_snapshots'), { recursive: true });
fs.mkdirSync(path.join(output, 'capturas'), { recursive: true });

const append = (name, value) => fs.appendFileSync(path.join(output, name), `${JSON.stringify({ timestamp: new Date().toISOString(), ...value })}\n`);
const sanitizeText = value => {
  const text = String(value ?? '').replace(/\s+/g, ' ').trim();
  if (!text || text.length > 160 || /@|\b\d{6,}\b/i.test(text)) return '';
  return text;
};
const sanitizePath = value => { try { return new URL(String(value), 'https://sage.entrerios.gov.ar/').pathname; } catch { return ''; } };

const targets = await fetch('http://127.0.0.1:9222/json/list').then(r => r.json());
const target = targets.find(item => item.type === 'page' && String(item.url).startsWith('https://sage.entrerios.gov.ar/'));
if (!target?.webSocketDebuggerUrl) throw new Error('No se encontró la pestaña SAGE con WebSocket CDP.');

const socket = new WebSocket(target.webSocketDebuggerUrl);
let sequence = 0;
const pending = new Map();
const send = (method, params = {}) => new Promise((resolve, reject) => {
  const id = ++sequence;
  pending.set(id, { resolve, reject });
  socket.send(JSON.stringify({ id, method, params }));
  setTimeout(() => { if (pending.delete(id)) reject(new Error(`timeout:${method}`)); }, 15000);
});

const capture = async reason => {
  try {
    const result = await send('Runtime.evaluate', { returnByValue: true, awaitPromise: true, expression: `(() => {
      const clean = v => String(v ?? '').replace(/\\s+/g, ' ').trim();
      const safe = v => { const t = clean(v); return !t || t.length > 160 || /@|\\b\\d{6,}\\b/i.test(t) ? '' : t; };
      const pathOf = v => { try { return new URL(String(v), location.href).pathname; } catch (_) { return ''; } };
      const installClickObserver = doc => { if (doc.defaultView.__sageAuditClickObserver) return; doc.defaultView.__sageAuditClickObserver = true; doc.defaultView.__sageAuditClicks = []; doc.addEventListener('click', event => { const target = event.target?.closest?.('button,a,input,label,[role="radio"],[role="button"]'); if (!target) return; const input = target.matches('input') ? target : target.querySelector('input'); const label = target.closest('label')?.textContent || target.textContent || target.getAttribute('aria-label') || ''; const text = safe(label); if (!text && !input) return; doc.defaultView.__sageAuditClicks.push({ tag:target.tagName.toLowerCase(), text, id:target.id || '', className:safe(target.className), inputType:input?.type || '', checked:input?.checked === true, path:pathOf(target.getAttribute('href') || '') }); }, true); };
      const docs = []; const seen = new Set();
      const visit = (win, depth = 0, parent = '') => { if (!win || seen.has(win)) return; seen.add(win); let doc; try { doc = win.document; } catch (_) { return; }
        installClickObserver(doc);
        const frame = win.frameElement; const frameId = frame?.id || frame?.name || (depth === 0 ? 'root' : '');
        const controls = [...doc.querySelectorAll('a,button,[role="tab"],[role="button"]')].map(e => ({ tag:e.tagName.toLowerCase(), text:safe(e.textContent || e.getAttribute('aria-label')), path:pathOf(e.getAttribute('href') || ''), id:e.id || '', className:safe(e.className) })).filter(e => e.text);
        docs.push({ depth, parent, frameId, frameName:frame?.name || '', pathname:String(win.location.pathname || ''), readyState:doc.readyState, accessible:true, headings:[...doc.querySelectorAll('h1,h2,h3,h4')].map(e=>safe(e.textContent)).filter(Boolean).slice(0,20), controls:controls.slice(0,100) });
        [...doc.querySelectorAll('iframe')].forEach(f => { try { visit(f.contentWindow, depth + 1, frameId); } catch (_) {} });
      }; visit(window); const clickEvents = []; seen.forEach(win => { try { clickEvents.push(...(win.__sageAuditClicks || []).splice(0)); } catch (_) {} }); return { host:location.hostname, pathname:location.pathname, title:document.title, readyState:document.readyState, docs, clickEvents };
    })()` });
    const value = result?.result?.result?.value;
    if (!value) return;
    append('frames.jsonl', { event:'structural_capture', reason, host:value.host, pathname:value.pathname, title:value.title, readyState:value.readyState, frames:value.docs.map(({controls,...frame}) => frame) });
    append('controles.jsonl', { event:'controls_capture', reason, frames:value.docs.map(frame => ({ frameId:frame.frameId, pathname:frame.pathname, controls:frame.controls })) });
    for (const click of value.clickEvents || []) append('controles.jsonl', { event:'click_observed', frame:'same-origin', control:click });
    fs.writeFileSync(path.join(output, 'dom_snapshots', `${Date.now()}.json`), JSON.stringify(value));
  } catch (error) { append('errores.jsonl', { event:'capture_error', message:String(error.message || error).slice(0,200) }); }
};

socket.addEventListener('message', async event => {
  const message = JSON.parse(event.data);
  if (message.id && pending.has(message.id)) { const item = pending.get(message.id); pending.delete(message.id); if (message.error) item.reject(new Error(message.error.message)); else item.resolve(message); return; }
  const params = message.params || {};
  if (message.method === 'Page.frameNavigated') append('transiciones.jsonl', { event:'frame_navigated', frameId:params.frame?.id || '', parentFrameId:params.frame?.parentId || '', name:sanitizeText(params.frame?.name), host:'sage.entrerios.gov.ar', pathname:sanitizePath(params.frame?.url) });
  if (message.method === 'Page.frameStartedLoading' || message.method === 'Page.frameStoppedLoading' || message.method === 'Page.frameAttached' || message.method === 'Page.frameDetached') append('frames.jsonl', { event:message.method, frameId:params.frameId || '', parentFrameId:params.parentFrameId || '' });
  if (message.method === 'Network.requestWillBeSent') append('network.jsonl', { event:'request', requestId:params.requestId, frameId:params.frameId || '', method:params.request?.method || '', pathname:sanitizePath(params.request?.url), resourceType:params.type || '' });
  if (message.method === 'Network.responseReceived') append('network.jsonl', { event:'response', requestId:params.requestId, frameId:params.frameId || '', status:params.response?.status || 0, pathname:sanitizePath(params.response?.url), resourceType:params.type || '' });
  if (message.method === 'Network.loadingFailed') append('errores.jsonl', { event:'network_error', requestId:params.requestId, frameId:params.frameId || '', errorText:sanitizeText(params.errorText), resourceType:params.type || '' });
  if (message.method === 'Runtime.consoleAPICalled') append('errores.jsonl', { event:'console', level:params.type || '', message:(params.args || []).map(arg => sanitizeText(arg.value || arg.description)).filter(Boolean).join(' ').slice(0,300) });
  if (message.method === 'Log.entryAdded') append('errores.jsonl', { event:'log', level:params.entry?.level || '', message:sanitizeText(params.entry?.text) });
  if (message.method === 'Page.frameNavigated') await capture('frameNavigated');
});

socket.addEventListener('open', async () => {
  await send('Page.enable'); await send('Network.enable'); await send('Runtime.enable'); await send('Log.enable');
  append('eventos.jsonl', { event:'monitor_started', host:'sage.entrerios.gov.ar', pathname:'/pregase/index.php', cdp:'127.0.0.1:9222', personalData:'omitida' });
  await capture('startup');
  const timer = setInterval(async () => { if (fs.existsSync(marker)) { clearInterval(timer); append('eventos.jsonl', { event:'monitor_stopped' }); socket.close(); return; } await capture('poll'); }, 4000);
});

socket.addEventListener('error', error => append('errores.jsonl', { event:'socket_error', message:String(error.message || error).slice(0,200) }));
socket.addEventListener('close', () => process.exit(0));
