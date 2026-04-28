from pathlib import Path
from docx import Document
from docx.shared import Pt


base = Path.home() / "Desktop"
txt_path = base / "Psicologia_y_Educacion_respuestas_con_paginas.txt"
docx_path = base / "Psicologia_y_Educacion_respuestas_con_paginas.docx"

items = [
    {
        "pregunta": "1. ¿Qué es la Psicología?",
        "citas": [
            ("p. 20", "Los campos de la Psicología refieren a los distintos temas que los psicólogos han investigado."),
            ("p. 21", "Es necesario, entonces, acudir a ella para fundamentar las decisiones que se toman en el ámbito de la educación y de la enseñanza."),
            ("p. 22", "Para ser un buen profesor conviene contar con una sólida formación psicológica."),
        ],
    },
    {
        "pregunta": "2. ¿Qué aporte brinda la Psicología a la educación?",
        "citas": [
            ("p. 21", "Es necesario, entonces, acudir a ella para fundamentar las decisiones que se toman en el ámbito de la educación y de la enseñanza."),
            ("p. 21", "Está conformada por teorías que ayudan a analizar y comprender el fenómeno educativo y mejorar el aprendizaje y desarrollo humano mediante la práctica educativa."),
            ("p. 22", "El conocimiento acerca de las cuestiones psicológicas colabora en la comprensión, planificación y mejora sustantiva de los procesos educativos."),
        ],
    },
    {
        "pregunta": "3. ¿Cómo llega a constituirse la Psicología como ciencia independiente? ¿Qué problemáticas tuvo?",
        "citas": [
            ("p. 24", "Capítulo 2. Constitución del sujeto psíquico."),
            ("p. 24", "Desde su nacimiento, el ser humano se encuentra inmerso en una compleja red de relaciones, en una trama de vinculaciones reales."),
            ("p. 25", "No existe un sujeto desde el momento mismo del nacimiento. Éste se va constituyendo como sujeto a partir del resultado de complejos procesos de transformaciones, de experiencias singulares, siempre en relación con el medio social y cultural."),
        ],
        "nota": "Observación: estas páginas no desarrollan literalmente la independencia histórica de la Psicología; el tramo visible corresponde al capítulo sobre constitución del sujeto psíquico.",
    },
    {
        "pregunta": "4. ¿Qué son los campos de la Psicología? ¿Qué nos permite darnos cuenta eso?",
        "citas": [
            ("p. 20", "Los campos de la Psicología refieren a los distintos temas que los psicólogos han investigado."),
            ("p. 20", "Algunos psicólogos se dedicaron al estudio del aprendizaje dando origen a la Psicología Educativa o Educacional; otros, se inclinaron por las enfermedades psíquicas lo que dio origen a la Psicología Clínica, y así sucesivamente."),
            ("p. 20", "La falta de unidad es preocupación de muchos científicos, algunos ya se refieren a las psicologías o al mencionar a la Psicología utilizan la expresión estudios psicológicos."),
        ],
    },
    {
        "pregunta": "5. ¿El accionar docente se basa en experiencia, vocación o fundamentos psicológicos?",
        "citas": [
            ("p. 21", "Es necesario, entonces, acudir a ella para fundamentar las decisiones que se toman en el ámbito de la educación y de la enseñanza."),
            ("p. 22", "Para ser un buen profesor conviene contar con una sólida formación psicológica."),
            ("p. 22", "Este conocimiento proporciona al profesor un marco de referencia de conocimiento científico importante para observar a los alumnos, al proceso de aprendizaje y a la misma situación de aprendizaje."),
        ],
    },
    {
        "pregunta": "6. ¿Qué aporte al campo educativo han brindado los psicólogos?",
        "citas": [
            ("p. 30", "Freud describe minuciosamente la naturaleza de los mecanismos psíquicos con especial referencia al inconsciente y a sus manifestaciones, aborda el estudio de la sexualidad infantil, las características del deseo humano, como también el análisis y tratamiento de enfermedades nerviosas como la neurosis."),
            ("p. 31", "Quizás, su contribución más significativa dentro del pensamiento moderno es el intento de darle al inconsciente un status científico."),
            ("p. 32", "A lo largo de su vida, Freud fue construyendo un conjunto de ideas sobre el funcionamiento psíquico que dieron lugar a dos teorías sucesivas y complementarias."),
            ("p. 33", "La inteligencia es la capacidad de operar creativamente en la realidad y de apropiarse de esa realidad para sobrevivir."),
        ],
        "nota": "Observación: el tramo visible de estas páginas desarrolla Freud y el psicoanálisis; no aparece una síntesis literal de aportes de psicólogos al campo educativo.",
    },
    {
        "pregunta": "7. ¿Cuál es la relación entre Psicología del desarrollo y Psicología educacional?",
        "citas": [
            ("p. 22", "Dos campos de la Psicología aportan conocimientos significativos para el docente: la Psicología del Desarrollo y la Psicología Educativa."),
            ("p. 22", "El primero, Psicología del Desarrollo, considera los cambios en el comportamiento como consecuencia del desarrollo humano, y el segundo -Psicología Educativa- los cambios como consecuencia de la enseñanza y del aprendizaje."),
        ],
    },
    {
        "pregunta": "8. ¿A qué hacemos referencia cuando hablamos de complejidad del acto educativo?",
        "citas": [
            ("p. 22", "Teniendo en cuenta la complejidad del acto educativo, es necesario plantear que el desarrollo humano, no sólo depende de procesos madurativos individuales, sino que se realiza dentro de un contexto social y esto significa enseñar y aprender de forma permanente."),
            ("p. 22", "La Psicología se ocupa del estudio de esos factores, de su interacción permanente y qué papel juegan en la situación de enseñanza y aprendizaje."),
            ("p. 22", "Los factores internos o externos pueden facilitar o inhibir el aprendizaje."),
        ],
    },
    {
        "pregunta": "9. Cuando hablamos de desarrollo humano, ¿qué factores debemos tener en cuenta?",
        "citas": [
            ("p. 22", "Teniendo en cuenta la complejidad del acto educativo, es necesario plantear que el desarrollo humano, no sólo depende de procesos madurativos individuales, sino que se realiza dentro de un contexto social y esto significa enseñar y aprender de forma permanente."),
            ("p. 22", "El desarrollo humano, no sólo depende de procesos madurativos individuales, sino que se realiza dentro de un contexto social."),
            ("p. 25", "El sujeto está sujetado a un orden biológico, sujetado a estructuras anátomo fisiológicas que posibilitan la adaptación al medio natural manteniendo la vida orgánica."),
        ],
    },
]

lines = [
    "Psicología y Educación - citas textuales por página",
    "",
    "Fuente: psicologia_y_educacion__1.pdf",
    "Base: Psicologia_y_Educacion_respuestas.docx",
    "",
]

for item in items:
    lines.append(item["pregunta"])
    for page, quote in item["citas"]:
        lines.append(f"{page}: “{quote}”")
    if "nota" in item:
        lines.append(f"Nota: {item['nota']}")
    lines.append("")

txt_path.write_text("\n".join(lines), encoding="utf-8-sig")

doc = Document()
styles = doc.styles
styles["Normal"].font.name = "Times New Roman"
styles["Normal"].font.size = Pt(12)

for line in lines:
    doc.add_paragraph(line)

doc.save(str(docx_path))
print(txt_path)
print(docx_path)
