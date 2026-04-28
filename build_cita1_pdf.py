from pathlib import Path
import re
from html import escape


def u(text: str) -> str:
    return text.encode("utf-8").decode("unicode_escape")


base = Path(r"C:\Users\alanm\Desktop\Javier\EPISTEMOLOGIA")
outdir = base / "extraidos_lectura"
outdir.mkdir(exist_ok=True)

apa_text = (outdir / "norma_apa_7_2021_texto.txt").read_text(
    encoding="utf-8", errors="replace"
)
activity_text = next(outdir.glob("actividad *.txt")).read_text(
    encoding="utf-8", errors="replace"
)

m = re.search(
    r"Cita de cita\s+Es la referencia.*?\(Hernández et al\., 2003, como se citó\s+en Pérez, 2011, p\. 17\)\.",
    apa_text,
    re.S,
)
apa_block = (
    m.group(0).strip()
    if m
    else u(
        "No se pudo extraer autom\\u00e1ticamente el apartado de APA."
    )
)

parts = re.split(r"(Cita \d+ \(pp?\. [^)]+\))", activity_text)
quote1 = ""
for i in range(1, len(parts), 2):
    if parts[i].startswith("Cita 1"):
        body = parts[i + 1]
        m2 = re.search(r"^(.*?\(Moradiellos, 2001, pp\. 140-141\)\.)", body, re.S)
        quote1 = m2.group(1).strip() if m2 else body.strip()
        break

html = f"""<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<title>{u('Cita 1 APA justificada y cita completa v4')}</title>
<style>
  @page {{ size: A4; margin: 2cm 2.2cm; }}
  body {{ font-family: Georgia, "Times New Roman", serif; color: #111; font-size: 11.5pt; line-height: 1.55; }}
  h1 {{ font-size: 17pt; text-align: center; margin: 0 0 0.7cm 0; line-height: 1.25; }}
  h2 {{ font-size: 12.5pt; margin: 0.55cm 0 0.2cm 0; line-height: 1.3; }}
  p {{ margin: 0 0 0.28cm 0; text-align: justify; }}
  .lead {{ margin-bottom: 0.45cm; }}
  .formula {{ margin-left: 1.1cm; margin-right: 1.1cm; font-style: italic; text-align: left; }}
  blockquote {{ margin: 0.35cm 1.2cm 0.45cm 1.2cm; padding: 0; }}
  blockquote p {{ text-align: justify; margin-bottom: 0.22cm; }}
</style>
</head>
<body>
<h1>{u('Cita 1, cita de cita y justificaci\\u00f3n en APA 7')}</h1>
<p class="lead">{u('Documento elaborado a partir del PDF de normas APA y del archivo \\u201cactividad La Historiograf\\u00eda Internacional FECHA 14 de abril\\u201d.')}</p>
<h2>1. {u('Qu\\u00e9 dice el PDF de APA')}</h2>
<p>{u('El PDF \\u201cNORMA APA s\\u00e9ptima edici\\u00f3n 19 MAYO 2021 (2)\\u201d indica que la ')}<strong>{u('cita de cita')}</strong>{u(' se usa cuando se trabaja con un documento secundario y no est\\u00e1 disponible la fuente original. Tambi\\u00e9n aclara que deben nombrarse tanto la fuente originaria como la fuente consultada y que este recurso debe usarse con moderaci\\u00f3n.')}</p>
<blockquote><p>{escape(apa_block).replace(chr(10), "<br>")}</p></blockquote>
<h2>2. {u('Por qu\\u00e9 esto aplica a la cita 1')}</h2>
<p>{u('En la cita 1 del archivo de fecha 14 de abril, la fuente consultada es ')}<strong>Moradiellos (2001)</strong>. {u('Dentro de ese pasaje, Moradiellos incorpora una cita en bloque atribuida a ')}<strong>Lawrence Stone</strong>. {u('Por eso, si se quiere citar espec\\u00edficamente ese bloque interno y no se consult\\u00f3 directamente la obra de Stone, corresponde tratarlo como ')}<strong>{u('cita de cita')}</strong>{u(' o ')}<strong>{u('fuente secundaria')}</strong>.</p>
<h2>3. {u('F\\u00f3rmula sugerida')}</h2>
<p>{u('Cita entre par\\u00e9ntesis:')}</p>
<p class="formula">(Stone, 1979, {u('como se cit\\u00f3 en')} Moradiellos, 2001, p. 140)</p>
<p>{u('Cita narrativa:')}</p>
<p class="formula">Stone (1979, {u('como se cit\\u00f3 en')} Moradiellos, 2001, p. 140) {u('sostiene que')} ...</p>
<h2>4. {u('Cita 1 completa')}</h2>
<blockquote><p>{escape(quote1).replace(chr(10), "<br>")}</p></blockquote>
<h2>5. {u('Observaci\\u00f3n final')}</h2>
<p>{u('Si lo que se cita es el pasaje completo de Moradiellos, la referencia sigue siendo a Moradiellos. Si lo que se quiere destacar es espec\\u00edficamente el bloque interno atribuido a Stone, entonces la formulaci\\u00f3n m\\u00e1s precisa, siguiendo el PDF de APA revisado, es la de cita de cita.')}</p>
</body>
</html>
"""

html_path = outdir / "Cita 1 APA justificada y cita completa v4.html"
html_path.write_text(html, encoding="utf-8")
print(html_path)
