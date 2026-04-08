delete from public.assistant_chunks where document_id in ('steiman_mas_didactica_nivel_superior','app_textos_sin_faq');
delete from public.assistant_documents where id in ('steiman_mas_didactica_nivel_superior','app_textos_sin_faq');
insert into public.assistant_documents (id, title, source_type, source_path, active) values ('steiman_mas_didactica_nivel_superior','Steiman - Mas didactica en nivel superior','steiman','docs/referencias/steiman_mas_didactica_nivel_superior.txt', true),('app_textos_sin_faq','Textos de la app (sin FAQ)','app_text','lib curated text (excluding lib/features/faq)', true);
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 1, '© 2008-Miño y Dávila srl

www.minoydavila.com.ar

En Madrid:

Miño-y-Dávila-editores

Arroyo Fontarrón 113, 2º A (28030)

tel-fax: (34) 91 751-1466

Madrid · España

En Buenos Aires:

Miño-y-Dávila-srl

Pje. José M. Giuffra 339 (C1064ADC)

tel-fax: (54 11) 4361-6743 

e-mail-producción: produccion@minoydavila.com.ar

e-mail-administración: administracion@minoydavila.com.ar

Buenos Aires · Argentina

© 2008-UNSAMedita de 

Universidad Nacional 

de General San Martín

Martín de Irigoyen 3100

(1650) San Martín, Buenos Aires, Argentina

e-mail: unsamedita@unsam.edu.ar

Colección Archivos de Didáctica

Serie Fichas de Investigación

Director: José Villella

Corrección general y cuidado de edición a cargo de 

Laura Petz

La maquetación y armado de interior estuvieron a cargo de

Laura Bono

El diseño de cubierta fue realizado por

Ángel Vega

P

rimera-edición 

M

arzo de 2008

ISBN: 978-84-96571-80-8

Prohibida su reproducción total o parcial, incluyendo fotocopia, 

sin la autorización expresa de los editores. 

I

mpreso en 

B

uenos Aires,

Argentina

Más didáctica

(en la educación superior)

Jorge Steiman

Indice', 'chunk 1');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 2, 'Presentación........................................................................11

Capítulo 1 

Los proyectos de cátedra. ....................................................17

Introducción.........................................................................17

1.

. El.valor.pedagógico.de.los.proyectos.de.cátedra. ..............19

. 1.1.

.El.proyecto.de.cátedra.y.el.equipo.docente...............21

. 1.2.

.El.proyecto.de.cátedra.y.los.alumnos/as. ...................22

. 1.3.

.El.proyecto.de.cátedra.y.la.institución......................22

2.

. Algunas.sugerencias.para.su.desarrollo. ...........................23

. 2.1.

.Encabezamiento.......................................................24

. 2.2.

.Actividad.académica.de.la.cátedra............................24

2.2.1.

.Investigación. ................................................25

2.2.2.

.Extensión. .....................................................27

2.2.3.

.Docencia. ......................................................27

. 2.3.

.Marco.referencial......................................................29

2.3.1.

.Marco.curricular. ...........................................30

2.3.2.', 'chunk 2');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 3, '.Marco.epistemológico...................................31

2.3.3.

.Marco.didáctico. ............................................32

2.3.4.

.Marco.institucional.......................................33

. 2.4.

.Propósitos. ...............................................................35

2.4.1.

.El.planteo.de.objetivos..................................35

2.4.2.

.El.planteo.de.expectativas.de.logro. ...............37

2.4.3.

.El.planteo.de.propósitos. ...............................41

. 2.5.

.Contenidos..............................................................44

. 2.6.

.Marco.metodológico. ................................................55

. 2.7.

.Cronograma.............................................................61

. 2.8.

.Evaluación. ...............................................................63

2.8.1.

.Evaluación.de.la.enseñanza...........................66

2.8.2.

.Evaluación.de.los.aprendizajes. ......................67

. 2.9..Bibliografía...............................................................70

Extroducción. ........................................................................72', 'chunk 3');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 4, 'Bibliografía. ...........................................................................73

Capítulo 2

El método y los recursos didácticos....................................75

Introducción.........................................................................75

1.

. La.relación.entre.el.método.y.los.recursos.didácticos.......76

2.

. Los.ejercicios...................................................................80

. 2.1.

.Características.de.los.ejercicios. ................................80

. 2.2.

.Ejemplos.de.ejercicios. ..............................................80

3.

. Las.situaciones.problemáticas. .........................................81

. 3.1.

.Características.de.las.situaciones.problemáticas.......81

. 3.2.

.Ejemplos.de.situaciones.problemáticas.....................83

4.

. Los.trabajos.prácticos. .....................................................84

. 4.1.

.La.clase.de.trabajos.prácticos...................................84

. 4.2.

.Características.del.trabajo.práctico.como.recurso.

didáctico.........................................................................85

. 4.3.

.Algunas.sugerencias.para.formalizar.la.presentación.', 'chunk 4');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 5, 'de.un.trabajo.práctico. .....................................................87

. 4

.4..Últimas.consideraciones.sobre.los.trabajos.prácticos. ....90

. 4.5.

.Un.ejemplo.de.trabajo.práctico. ................................90

. 4.6.

.Diferencias.sustantivas.entre.ejercicios,.

situaciones.problemáticas.y.trabajos.prácticos. ................92

5.

. Las.guías.de.estudio........................................................93

. 5

.1..Un.poco.de.historia.respecto.a.las.guías.d

e.estudio. ......93

. 5.2.

.Consideraciones.prácticas........................................95

. 5.3.

.Errores.más.frecuentes.en.el.uso.de.las.

. guías.de.estudio.(y.una.pequeña.licencia.para.el.humor). ....98

. 5.4.

.Un.ejemplo.de.guía.de.estudio............................... 100

6.

. Las.guías.de.lectura....................................................... 106

. 6.1.

.Características.de.las.guías.de.lectura. .................... 106

. 6.2.

.Un.ejemplo.de.guía.de.lectura................................ 108

7.

. Las.rutas.conceptuales.................................................. 111

. 7.1.

.Características.de.las.rutas.conceptuales. ............... 111

. 7.2.', 'chunk 5');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 6, '.Un.ejemplo.de.ruta.conceptual. .............................. 112

8.

. Los.casos. ...................................................................... 113

. 8.1.

.Características.de.los.casos.................................... 113

. 8.2.

.Ejemplos.de.casos.................................................. 115

Extroducción. ...................................................................... 122

Bibliografía. ......................................................................... 123

Capítulo 3

Las prácticas de evaluación............................................... 125

Introducción....................................................................... 125

1.

. La.evaluación:.una.práctica.compleja............................. 127

2

.. Algunas.desvirtuaciones.en.las.prácticas.de.evaluación... 131

. 2.1.

.“Lo.que.está.en.juego.en.la.evaluación.

es.cuánto.sabe.el/la.alumno/a”...................................... 131

. 2.2.

.“Sólo.hay.que.evaluar.lo.que.el/la.alumno/a.

tiene.que.saber”. ........................................................... 132

. 2.3.

.“El.principal.sentido.de.la.enseñanza.', 'chunk 6');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 7, 'es.que.aquéllo.que.se.enseña.será.evaluado”................. 133

. 2.4.

.“Evaluación.y.enseñanza.son.procesos.

independientes”. ........................................................... 134

. 2.5.

.“La.evaluación.es.un.punto.de.llegada”.................. 135

. 2.6.

.“La.evaluación.final.comienza.bajo.el.supuesto.

de.descubrir.qué.es.lo.que.el/la.alumno/a.no.sabe”. ....... 136

. 2.7.

.“La.corrección.de.un.parcial.escrito.

se.reduce.a.poner.una.nota”. ......................................... 136

. 2.8.

.“Las.notas.son.necesarias.e.imprescindibles”. ......... 137

. 2.9.

.“Los.‘choise’.son.objetivos”................................... 138

. 2

.10..“Proponer.la.autoevaluación.es.hacer.demagogia”... 139

. 2.11.

.“La.calidad.de.la.formación.en.la.educación.

. superior.se.soluciona.con.un.buen.sistema.

. de.exámenes.(de.ingreso.y/o.de.egreso)”. ....................... 140

. 2.12.

.“Los.docentes.necesitamos.capacitación.

. específica.sobre.herramientas.de.evaluación”. ................ 141

3.

. Y.entonces,.¿qué.es.evaluar?.......................................... 142

4.

. La.evaluación.de.las.prácticas.de.enseñanza.................. 148

. 4.1.', 'chunk 7');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 8, '.¿Qué.evaluar.en.las.prácticas.de.enseñanza?:.

el.problema.del.objeto................................................... 150

. 4.2.

.¿Cuándo.evaluar.las.prácticas.de.enseñanza?:.

el.problema.del.tiempo.................................................. 152

. 4.3.

.¿Quién.evalúa.las.prácticas.de.enseñanza?:.

el.problema.de.los.

sujetos............................................. 153

. 4.4.

.¿Cómo.evaluar.las.prácticas.de.enseñanza?:.

el.problema.de.los.instrumentos. ................................... 153

4.4.1.

.Cuando.los.docentes.nos.autoevaluamos.

y.la.información.proviene.de.nosotros.mismos...... 154

4.4.2.

.Cuando.los.docentes.nos.autoevaluamos.

y.la.información.proviene.de.los/las.alumnos/as.... 155

5.

. La.evaluación.de.las.prácticas.de.aprendizaje................. 159

. 5.1..Cuando.la.evaluación.de.las.prácticas.de.aprendizaje.

no.es.acreditación.de.los.aprendizajes........................... 161

5.1.1.

.La.evaluación.inicial.................................... 161

5.1.2.

.La.evaluación.de.seguimiento. ..................... 165

. 5.2.

.Cuando.la.evaluación.de.las.prácticas.de.aprendizaje.', 'chunk 8');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 9, 'es.acreditación.de.los.aprendizajes................................ 167

5.2.1.

.El.problema.del.objeto.(qué.evaluar).

–el.problema.de.los.criterios–. ............................... 168

5.2.2.

.El.problema.de.los.instrumentos.

(cómo.evaluar)...................................................... 171

5.2.3.

.El.problema.de.la.calificación....................... 179

5.2.4.

.El.problema.de.la.devolución....................... 186

5.2.5.

.El.problema.de.la.promoción....................... 187

. 5.3.

.Las.prácticas.de.evaluación.y.la.consideración.

de.los.errores................................................................. 194

Extroducción. ...................................................................... 205

Bibliografía. ......................................................................... 206

Capítulo 4

La evaluación como práctica institucional: 

el ‘plan de evaluación institucional’. ................................. 209

Introducción....................................................................... 209

1.

. La.evaluación.como.proyecto.institucional. .................... 212

. 1.1.', 'chunk 9');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 10, '.¿Qué.es.un.proyecto. .............................................. 218

. 1.2.

.¿Qué.es.un.proyecto.institucional.de.evaluación.

didáctica.(el

.plan.de.evaluación.institucional)?. ............. 221

2.

. Los.componentes.del.proyecto.institucional.de.

evaluación.didáctica...................................................... 226

. 2.1.

.El.marco.teórico.en.el.proyecto.institucional.

de.evaluación.didáctica. ................................................. 226

. 2.2.

.La.evaluación.de.la.enseñanza.en.el.proyecto.

institucional.de.evaluación.didáctica. ............................. 227

. 2.3.

.La.evaluación.de.los.aprendizajes.en.el.

proyecto.institucional.de.evaluación.didáctica............... 229

Extroducción. ...................................................................... 232

Bibliografía. ......................................................................... 239

 11

Presentación

C

uando.en.junio.del.2004.salió.la.primera.edición.de.¿Qué 

debatimos hoy en la didáctica?: Las prácticas de enseñanza en 

la educación superior, m i .primer.libro.sobre.temas.de.didáctica.en.

la.educación.superior,.sentí.esa.extraña.sensación.que,.supongo,.', 'chunk 10');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 11, 'compartimos.todos.aquellos.que.alguna.vez.hemos.escrito.algo:.

esa.inquieta.excitación.de.dejar.una.parte.de.uno.mismo.plasmada.

en.un.par.de.hojas,.casi.como.un.‘contrato.con.la.eternidad’..

Inevitablemente.uno.se.cuestiona.acerca.de.la.provisionalidad.

de.aquellas.cosas.que.escribe.y.desafía.a.sus.propias.contradic-

ciones

.a.comportarse.con.cierta.coherencia..Dos.años.después,.

todavía.sigo.confiando.en.aquellas.primeras.reflexiones.sobre.las.

prácticas.docentes.en.la.educación.superio

r.y.he.decidido.volver.

sobre.ellas..En.¿Qué debatimos hoy en la didáctica?,.i nicié.el.texto.

presentando.el.debate.epistemológico.que.se.da.aún.hoy.en.el.

campo.de.la.didáctica:.el.abandono.de.las.cuestiones.planteadas.

como.centrales.por.el.paradigma.normativo-instrumentalista.y.

el.creciente.desarrollo.teórico.de.nuevas.temáticas.inscriptas.en.

el.paradigma.interpretativo-crítico..Y.ciertamente,.en.ese.texto,.

recorrí.algunos.temas.de.la.didáctica.general.en.el.contexto.de.la.

educación.superior.desde.esta.lógica.interpretativa..Me.permití,.

de.todos.modos,.plantear.como.advertencia, .la.necesidad.de.

recuperar.la.línea.de.las.orientaciones prácticas.que .los.docentes.', 'chunk 11');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 12, 'le.reclamamos.a.la.didáctica,.y

a.no.como.prescripción.o.como.

norma,.sino.acaso.como.un.espacio.teórico.en.el.cual.un.campo.

12. Presentación

del.saber.pueda.poner.a.disposición.de.quienes.con.él.interac-

t

úen,.algunas.experiencias.de.la.práctica.que.puedan.servir.como.

insumos.desde.los.cuales.edificar.las.propias.resoluciones.que.la.

práctica.de.enseñar.nos.plantea.como.desafío..

Así.es.que.hoy.en.Más didáctica (en la educación superior) .

quier

o,.sin.dejar.de.transitar.mi.propio.posicionamiento.teórico.

en.el.campo.de.la.didáctica,.ofrecer.mis.reflexiones.sobre.algunas.

orientaciones prácticas.q ue.considero.necesarias.de.ser.asumidas.

por.el.campo.de.la.didáctica.general..Y.me.permito.hacerlas.luego.

de.haber.teorizado.sobre.las.prácticas.docentes.a.partir.de.mis.

propias.prácticas .en.el.texto.anterior..Y.m

e.permito.hacerlas.

porque.he.reconocido.mis.buenas.resoluciones,.mis.fracasos,.

mis.contradicciones…

CONTRADICCIONES

Recorro.una.a.una.mis.contradicciones.cotidianas.

Las.desvelo,.les.quito.la.máscara.y.el.maquillaje,

las.desnudo,.les.arranco.verdades.y.mentiras.retro,

las.pongo.en.escena.sobre.un.tablado.de.estreno,', 'chunk 12');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 13, 'y.las.paro.al.costado.de.la.ruta.exhibiéndose.

Son.tan.ingenuas.y.viejas.que.me.enternecen,

y.tan.violentas.y.profundas.que.me.desangran.

Las.desafío,.ya.expuestas,.a.una.última.apuesta

y.ellas,.gustosas.y.sobradoras,.aceptan.el.reto,

se.relamen.sabiendo.haber.cazado.una.presa.fácil.

Es.obvio,.casi.evidente,.hasta.diría.inevitable

que.mis.contradicciones,.una.vez.más,.ganen.

Más didáctica (en la educación superior) es.un.texto.que.he .

venido.escribiendo.desde.hace.algún.tiempo..Una.y.otra.vez.he.

vuelto.sobre.algunos.de.mis.enunciados,.los.he.reformulado,.

los.he.acrecentado.y.los.he.experimentado..Todo.aquello.que.he.

podido.expresar.no.sólo.es.el.resultado.de.mi.pensamiento.sino,.

fundamentalmente,.la.construcción.de.mi.práctica..Quise.escribir.

sobre.lo.que.hago,.quise.despertar.a.los.postulados.teóricos.y.

desafiarlos.a.convivir.con.los.relatos.de.mis.prácticas.aunando,.en.

el.difícil.equilibrio.que.los.entrelaza,.las.interpretaciones.acerca.

de.QUÉ.hacemos.con.las.descripciones.del.CÓMO.lo.hacemos..

Ahora.estoy.feliz,.finalmente.me.gusta.como.ha.quedado

.y.he.

decidido.que.éste.es.el.momento.de.hacerlo.circular..Esa.inquieta.', 'chunk 13');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 14, 'excitación.es.para.mí.también.un.extraño.modo.de.defender.la.

 13Más.didáctica.(en.la.educación.superior)

vida.y.de.levantar.el.estandarte.de.la.alegría.que.me.provoca.la.

escritura..Viste.como.es.esto,.cada.loco…

ACONTECIMIENTOS

Tum-tum;.tum-tum;.tum-tum

despierta.de.su.siesta.mi.corazón.adormecido

buscando.en.mi.tórax.por.donde.expandirse

La.sangre.remueve.telarañas

y.cada.una.de.mis.venas.ríe.a.carcajadas

Si.hasta.en.el.último.rincón.de.mi.biología:

en.mis.uñas,.los.nudillos,.en.la.hipófisis

hay.clima.de.fiesta,.de.acontecimiento

Acompañan.las.rodillas,.el.tobillo.y.la.nuca

se.me.transforma.el.aliento,.la.respiración,.el.bostezo

Bailan.las.muñecas,.el.codo,.los.hombros

y.un.frío.muy.cálido.me.recorre.la.espalda

La.voz,.los.ojos,.mi.estatura

servidos.en.

bandeja.se.entregan.al.milagro

de.escuchar.el.latido.ensordecedor

de.un.corazón.ex-adormecido.

Más didáctica (en la educación superior) es.un.recorrido.por.

las.prácticas.de.enseñanza.en.las.universidades.y.en.los.insti-

t

utos.superiores..Sé.que.es.un.terreno.difícil,.no.porque.me.lo.

hayan.contado,.no.porque.lo.haya.observado,.lo.sé.porque.soy.', 'chunk 14');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 15, 'docente.y.porque.comparto.desventuras.con.los.colegas.con.

quienes.trabajo.en.la.educación.superior..Éste.no.es.un.libro.

que.sale.de.los.gabinetes.o.de.los.escritorios,.es.un.libro.que.

nace.en.los.pizarrones.y.los.pupitres..Sé.también.que,.para.algu-

nos

.colegas,.la.enseñanza.en.la.educación.superior.es

.sólo.una.

cuestión.de.saber.el.libreto,.del.sólo.dominio.del.conocimiento.

de.la.ciencia.que.se.‘relata’.en.cada.clase..Pero.sé.también.que.

hay.otros.colegas.que.trabajan.desde.la.búsqueda.cotidiana.de.

mejores.formas.de.intervenir.en.las.clases,.de.mejores.propuestas.

de.enseñanza,.de.mejores.escenarios.y.situaciones.para.aprender..

Y.sé,.que.vale.la.pena.pensar.en.la.didáctica.en.el.contexto.de.la.

educación.superior..Por.favor,.no.me.digas.que.no.

14. Presentación

POSTERGACIÓN

No.me.digas.que.aquí.no.hay.cielo

ni.que.hubo.Hiroshima,

que.se.contaminan.las.aguas.con.los.deshechos.

humanos,

que

.el.hambre.mata.más.que.el.sida,

que.hay.esclavos.envejecidos,

que.se.murió.un.tipo.joven.

No.me.digas

que.no.hay.sombras.en.lo.oscuro,

que.siempre.dos.y.dos.son.cuatro,

que.primero.se.nace.y.después.se.muere,

que.viajar.es.trasladarse,', 'chunk 15');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 16, 'que.arriba.es.arriba.y.abajo.es.abajo,

que.a.lo.mejor,.que.acaso,

que.las.promesas.son.pasajeras.

No.me.digas

porque,.por.lo.menos.por.hoy,

he.decidido.postergar.mi.desazón.

Más didáctica (en la educación superior) es.mi.propia.bús-

q

ueda,.es.la.parte.de.mi.vida.en.la.cual,.como.tantos.otros,.

m

e.he.dedicado.a.buscar.uno.de.esos.tesoros.escondidos.que.

pocos.creen.que.exista..Es.mi.recopilación.de.las.pistas.y.es.mi.

búsqueda.de.los.mapas.que.indican.el.lugar,.ese.lugar,.en.el.que.

se.encuentra.el.tesoro.enterrado,.el.tesoro.de.las.preguntas..Es,.

portando.el.mapa.de.mis.respuestas,.la.búsqueda.de.mis.pregun-

t

as..Porque,.en.definitiva,.creo.que.todos.buscamos.encontrar.la.

pregunta,.la.pregunta.certera..Todo.lo.demás,.todas.las.respues-

t

as,.todos.esos.‘se.hace.así’,.‘conviene.así’,.‘te.digo.que’,.son.

sólo.distractores,.acaso.fortuitas.formas.de.resistirse.

BÚSQUEDA

¿Dónde.estás.vida.incierta.que.

no.te.encuentro?

En.la.oscura.cerrazón.de.la.noche,.sólo.lágrimas

y.el.insomnio.que.desafía.a.la.cordura.

Búhos.y.luces,.guardias.y.pesadillas,.serenos.y.sueños.

¿Dónde.estás.escondiéndote.de.mis.letanías.busconas?', 'chunk 16');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 17, '¿Cómo.puedo.esquivar.al.repartidor.de.respuestas?

Sombras.y.borracheras,.entuertos.y.encrucijadas

y.el.clamor.de.los.indecisos.golpeándome.

¿Quién.está.a.salvo.del.diluvio?

¿Y.quién.al.margen.de.la.historia?

 15Más.didáctica.(en.la.educación.superior)

Lloronas.de.cementerios.y.buscavidas.pesimistas,

astronautas.mediocres.y.cazadores.de.ornitorrincos,

hacen.fila.de.a.uno.para.salirse.del.mundo

y.yo,.confundiéndome.con.ellos,.

sorteo.una.vez.más.a.la.muerte.engañosa.

que.se.asoma.agazapada.

En.la.oscura.cerrazón.de.la.noche,.sólo.lágrimas

y.yo,.que.me.resisto,.buscándote.

Más didáctica en la (educación superior).está.armado.en.cua-

t

ro.capítulos..Si.bien.los.posteriores.se.van.apoyando.en.los.

anteriores,.nada.quita.que.puedas.elegir.tu.propio.itinerario.y.

apropiarte,.cómo.más.te.guste,.de.la.puerta.de.entrada.al.texto..

En.cada.uno.de.ellos.he.tratado.de.teorizar,.interpretar.mi.prác-

tica,

.proponer,.ejemplificar..En.los.ejemplos

.he.usado.nombres,.

son.los.nombres.de.mis.amigos.de.toda.la.vida..A.ellos,.les.

dedico.este.libro.

También.puede.ser.la.excusa.que.busqué.para.escribir.algo.

de.poesía.–algunas.están.hilvanando.esta.presentación–.y.leer.', 'chunk 17');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 18, 'a.los.poetas.que.más.quiero,.a.quienes.transcribo.a.lo.largo.del.

texto..Nunca.se.sabe.

 17

Capítulo 1

Los proyectos de cátedra

Introducción

Me inicié en la literatura un día de 1936, a los siete años, cuando 

la maestra nos dijo que escribiéramos una composición tema: “Mi 

madre”. Muchas cosas me vinieron a la cabeza, pero no podía escri-

bir nada. Entonces observé que mis compañeros escribían con una 

enorme facilidad y tuve ganas de llorar: yo era un chico de la calle, 

me costaba mucho expresarme y era el menos aplicado de todos. De 

golpe, sentado frente a la hoja en blanco pude ver a mi madre. Cami-

naba por un inmenso mercado repleto de verduras, frutas y flores, un 

mercado donde se oían las voces de quienes compraban y vendían, 

voces como de fiesta. En medio de todo eso, veía a mi hermosa y 

joven mamá que, aunque éramos muy pobres en aquella época 

de crisis, siempre compraba un ramo de flores, un pequeño y muy 

humilde ramo de flores. La cabeza se me pobló de imágenes; veía las 

mudanzas de mi familia que deambulaba de barrio en barrio durante 

la década del treinta. Y todo eso se me vino de golpe en una sola', 'chunk 18');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 19, 'metáfora de lo que era mi vida a los siete años. Y cuando vi la hoja 

en blanco, ese papel blanco que todo escritor teme y desea a la vez, 

yo escribí simplemente: “Mi mamá compra flores”. Esa era mi compo-

sición. Solamente pude escribir esas cuatro palabras. La maestra, que 

seguramente no conocía la pedagogía moderna –que se debía estar 

inventando en ese preciso momento– me puso un bonete de burro y 

me dijo: “Nunca en la vida podrás escribir, ni siquiera una carta”. Ese 

día, ese preciso día, decidí ser escritor.

(P

edro.Orgambide,.1985,.en.T odos teníamos veinte años).

18. Capítulo.1. .Los.proyectos.de.cátedra

S

eguramente.esa.maestra.de.Don.Pedro.Orgambide.no.habría.

planificado.decirle.a.Pedro.en.algún.momento:.“Nunca.en.

la.vida.podrás.escribir,.ni.siquiera.una.carta”.y.probablemente.

nunca.se.haya.enterado.que.su.exabrupto.hizo.nacer.a.un.gran.

escritor..

Seguramente.también.nosotros,.docentes.de.la.educación.

superior,.muchas.de.las.cosas.que.decidimos.o.hacemos.en.las.

aulas.jamás.las.habíamos.pensado.de.antemano..Pero.también.

y.por.el.contrario,.otras.muchas.cosas.que.decimos.o.hacemos.', 'chunk 19');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 20, 'en.nuestras.clases,.son.las.que.se.nos.ocurrieron.antes,.que.

pudimos.preverlas.y.anticiparlas..

Y.si.bien.es.cierto.que.un

.“Nunca.en.la.vida.podrás.escribir,.

ni.siquiera.una.carta”.dio.paso.a.una.genialidad.y.nadie.había.

previsto.eso,.también.alguna.vez.escuché.“Soy.arquitecto.por.

mi.profesor.de.diseño.que.me.hizo.amar.esta.profesión.a.partir.

de.las.buenas.propuestas.que.nos.traía.para.la.clase”.

En.la.educación.superior.la.entrega.del.programa.suele.ser.

vista.como.un.acto.burocrático:.como.hay.alguien.que.lo.pide,.

entonces.hay.que.presentarlo,.casi.como.un.trámite..Si.bien.en.

algunas.universidades.o.a.veces.al.interior.del.propio.sistema.

escolar.de.una.jurisdicción1.se.prescriben.o.sugieren.formatos .

para.la.entrega.de.los.programas,.cuando.no.hay.formalidades.

expuestas,.la.mayoría.de.nosotros.sólo.volcamos.un.listado.de.

los.‘temas’.que.vamos.a.enseñar.y.su.bibliografía.y.a.lo.sumo,.

según.la.ocasión,.le.adosamos.a.ello.los.objetivos.de.la.cátedra.

y.algunas.aclaraciones.respecto.a.la.evaluación.

“¿Otra.vez.presentar.el.programa,.si.ya.lo.presenté.el.año.

pasado?”.¿Cuántas.veces.escuchamos.–nos.escuchamos–.decir.', 'chunk 20');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 21, 'esto?.El.programa.es.más.una.carga.que.una.herramienta.de.tra-

b

ajo,.es.más.una.obligación.que.una.necesidad,.es.más.un.papel.

1. Por.ejemplo.en.la.provincia.de.Buenos.Aires.en.los.institutos.superiores.de.

gestión.estatal.la.Disposición.de.la.Dirección.de.Educación.Superior.Nº.30/05.

dispone.en.su.artículo.primero:.“Establecer.que.los.proyectos.de.cátedra.a.

ser.presentados.por.los.docentes.que.se.desempeñan.en.el.Nivel,.así.como.

aquellos.docentes.que.aspiren.a.desempeñarse.en.el.mismo,.conforme.a.los.

mecanismos.previstos.para.la.cobertura.de.provisionalidades .y.suplencias.

según.lo.establecido.por.la.Resolución.N°.5886/03.y.por.Actos.Públicos,.

deberán.contener,.como.mínimo,.los.tópicos.que.se.especifican.en.el.Anexo,.

que.pasa.a.formar.parte

.de.la.presente.Disposición”.

 19Más.didáctica.(en.la.educación.superior)

muerto.que.una.agenda.para.la.clase..¿Podremos.transformarlo.

en.otra.cosa?

“¿No.tenés.un.programa.ya.hecho.para.que.yo.copie?”.¿Cuán-

t

as.veces.escuchamos.–nos.escuchamos–.decir.esto?.El.programa.

es.más.un.fastidio.que.un.instrumento.de.trabajo,.es.más.una.

exigencia.que.una.presentación.pública.de.nuestras.ideas.acerca.', 'chunk 21');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 22, 'de.lo.que.haremos.desde.nuestras.intervenciones.de.enseñanza,.

es.más.una.molestia.que.un.organizador.para.la.clase..¿Podremos.

transformarlo.en.otra.cosa?

En.este.capítulo.quiero.presentar.la.idea.de.los.“proyectos.

de.cátedra”2.como.el.proyecto.de.nuestro.trabajo,.que.anticipa.

nuestras.grandes.decisiones,.las.más.relevantes

.y.que.dejamos.

asentadas.en.‘papel’.como.un.documento.para.el.trabajo.coti-

d

iano..Estoy.hablando.de.la.planificación .de.nuestro.trabajo.

docente,.del.diseño.previo,.del.programa..Pero.quiero,.en.esta.

propuesta,.involucrar.mucho.más.a.los.alumnos/as.en.él..

Voy.a.reiterar.esta.aclaración.más.de.una.vez.a.lo.largo.de.

esta.propuesta.pero.aquí.aparece.por.vez.primera:.sólo.se.trata.

de.una.propuesta,.no.excluye.otras.formas,.sólo.se.trata.de.mi.

propia.elaboración,.que.intento.compartir.porque.me.ha.resul-

ta

do.práctica..De.ninguna.manera.es.una.norma.ni.un.modelo.

para.analizar.lo.‘bien’.o

.‘mal’.hecho.en.términos.de.la.previsión.

del.propio.trabajo..Vale.que.lo.haga.explícito:.esto.sí.que.no.

quiero.que.se.transforme.en.otra.cosa.

1. El valor pedagógico de los proyectos de 

cátedra', 'chunk 22');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 23, 'Defino.al.proyecto.de.cátedra.como.una.propuesta.acadé-

m

ica.en.la.educación.superior.en.la.que.se.explicitan .ciertas.

previsiones,.decisiones.y.condiciones.para.la.práctica.didáctica.

en.el.aula.y.que.intenta.hacer.explícitos.ciertos.acuerdos.que.

2. El.término.“proyectos.de.cátedra”.es.asumido.por.la.jurisdicción.bonaerense.

tomando.la.idea.de.una.ficha.de.mi.autoría.que.he.usado.en.mi.cátedra.de.la.

UNLZ.y.que.resulta.ser.la.base.conceptual.de.este.capítulo..La.Disposición.

30/05.explicita.el.uso.bibliográfico.de.mi.ficha.

20. Capítulo.1. .Los.proyectos.de.cátedra

conforman.aquello.que.puede.objetivarse.del.contrato.didáctico.

que.se.establece.con.los.alumnos/as.y.con.la.Institución..

Estoy.utilizando.la.expresión.‘que.puede.objetivarse’.ya.que.

tomo.la.noción.de.contrato.didáctico.de.Yves.Chevallard.(1988),.

quien,.entre.otros,.considera.que.el.contrato.regula.nuestras.

acciones.sin.que.podamos.dar.una.vista.completa.de.sus.reglas.

y.al.que.‘entramos’.en.el.momento.en.que.entramos.en.el.tipo.

de.relaciones.sociales.que.el.contrato.regula..Así,.el.contrato.no.

es.algo.que.puede.rechazarse.o.aceptarse,.el.contrato.sencilla-

me', 'chunk 23');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 24, 'nte.‘es’..En.este.tipo.especial.de.intervención.en.las.p

rácticas.

sociales.que.es.la.enseñanza,.hay.de.hecho.un.contrato.didáctico.

que.regula.las.acciones.de.los.involucrados..Algunas.de.estas.

intervenciones .pueden.hacerse .explícitas. .Puede.anticiparse.

el.‘núcleo.duro’.de.contenidos.que.será.objeto.de.enseñanza,.

puede.preverse.qué.textos.se.propondrán.para.la.lectura.a.los.

alumnos/as,.puede.explicitarse.el.enfoque.epistemológico.desde.

el.que.se.realiza.la.propuesta.de.enseñanza.de.la.cátedra,.puede.

explicarse.en.qué.línea.de.investigación.está.trabajando.o.traba-

jará

.este.año.un.equipo.docente3,.y.algunas.cuantas.cosas.más.

que.intentaré.ir.desarrollando.en.este.capítulo..Las.otras.cláusu-

las,

.las.‘invisibles’,

.aquellas.de.las.que.ni.siquiera.podemos.dar.

cuenta.de.su.existencia,.aquellas.que.regulan.la.práctica.misma.

están,.existen,.sin.necesidad.de.anticiparlas.y,.sin.duda,.definen.

la.parte.sustancial.del.contrato..Aún.así,.la.previsión.de.un.plan.

de.trabajo.es.necesaria.

El.proyecto de cátedra.c onstituye,.en.este.sentido,.un.plan.de.

trabajo.hipotético.y.es.en.sí.mismo.una.herramienta.que.supera,.', 'chunk 24');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 25, 'por.su.valor.pedagógico,.los.diseños.tipo.programa de materia. .

Estoy.hablando.de.la.planificación.docente,.del.diseño.didáctico,.

pero.quiero,.a.lo.largo.de.estas.páginas,.justificar.por.qué.prefiero.

denominarlo.proyecto.de.cátedra.

3. Cuando.uso.el.plural.(‘docentes’).o.el.singular.(‘docente’).es.por.considerar.

que.la.cátedra.universitaria.suele.estar.constituida.por.más.de.un.docente.

pero.que.puede.también.ser.una.cátedra.unipersonal..En.los.institutos.supe-

r

iores.las.cátedras.son.unipersonales.aunque.algunas.experiencias.aisladas.

muestran.la.intención.de.constituirse,.a.modo.de.experiencia,.como.cátedras.

conformadas.por.más.de.un.docente..A.lo.largo.de.este.texto.aparecerá.men-

c

ionado.el.‘equipo.docente’.y.habrá.que.leerlo.también.como.‘el.docente’.

según.el.caso.

 21Más.didáctica.(en.la.educación.superior)

La.necesidad.de.su.formulación.puede.analizarse.en.relación.

con.estos.tres.componentes:

-.el.propio.docente

-.el.alumno/a

-.la.institución

1.1. El proyecto de cátedra y el equipo docente

Puede.pensarse.la.necesidad.del.proyecto.de.cátedra.en.refe-

r

encia.al.propio.equipo.docente.entendiendo .que.éste.puede.

servirle.para:', 'chunk 25');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 26, '-. organizar.mejor.el.trabajo.en.la.cátedra.en.tanto.puede.per-

mitir

.realizar.las.previsiones.necesarias.para.el.dictado.de.la.

unidad.curricular4.articulando.de.modo.racional.los.distintos.

componentes.de.la.situación.de.enseñanza;

-. evitar.las.improvisaciones.e.incoherencias.que.provocan.un.

trabajo.no.pensado.previamente.y/o.no.analizado.en.cuanto.

a.ciertas.condiciones

.que.pueden.afectarlo;

-. facilitar.el.intercambio.académico.con.sus.colegas.al.consti-

t

uirse.como.un.instrumento.de.comunicación.referido.funda-

mentalmente

.a.la.propuesta.de.enseñanza.de.cada.docente.

o.equipo.docente;

-. mejorar.el.intercambio.académico.con.los.alumnos/as,.en.

tanto.resulta.ser.un.documento.que.da.cuenta.de.una.serie.de.

previsiones.(por.ejemplo.tipo.y.cantidad.de.trabajos.prácticos.

que.habrá.que.resolver),.condiciones.(por.ejemplo.requisitos.

de.aprobación.expresados.en.los.criterios.de.acreditación).y.

decisiones.(por.ejemplo.línea.teórica.por.la.que.ha.optado.la.

cátedra).que.los.involucran.como.sujetos.de.aprendizaje;

-. disponer.de.un.material.que.p

uede.facilitar.el.análisis.y.la.

reflexión.sobre.la.propia.práctica,.toda.vez.que.por.el.sólo.', 'chunk 26');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 27, 'hecho.de.haber.elaborado.un.escrito.en.el.que.hay.explícita.

mención.de.una.serie.de.decisiones.tomadas,.su.relectura.

permite.‘volver’.sobre.las.mismas.para.pensar.desde.ellas;

4. Estoy.utilizando .el.término.‘unidad.curricular’.como.sinónimo .de.lo.que.

habitualmente.llamamos.materia.o.asignatura.

22. Capítulo.1. .Los.proyectos.de.cátedra

-. evaluar.su.propia.práctica.docente.ya.que,.habiéndose.objetivado.

una.serie.de.previsiones.que.anticipan.la.situación.de.ense-

ñ

anza,.se.dispondrá,.al.finalizar.el.período.para.el.cual.se.ha.

diseñado.el.proyecto,.de.un.texto.que.puede.permitir.cotejar.

las.intenciones.de.partida.con.las.concreciones.resultantes.

1.2. El proyecto de cátedra y los alumnos/as

Son.varias.las.razones.por.las.que.puede.expresarse.que.los.

alumnos/as.necesitan.el.proyecto.de.cátedra..Pero.entre.las.más.

relevantes.puede.decirse.que.servirá.para:

-. organizar.su.estudio.ya.que.el.proyecto.de.cátedra.explicita.

claramente .cuáles.son.los.contenidos.a.aprender,.cuál.es.

l

a.bibliografía.obligatoria.que.opera.como.soporte.teórico.

de.dichos.contenidos.y.cuáles.son.los.trabajos.prácticos.a.

resolver;

-', 'chunk 27');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 28, '. distribuir.su.propio.tiempo.de.estudio.al.estar.establecidas.

las.fechas.de.entrega.de.trabajos.y.previstas.las.fechas.de.las.

evaluaciones.parciales;

-. conocer.la.postura.de.la.cátedra.en.cuanto.a.la.orientación.

con.que.es.concebida.la.unidad.curricular.que.es.objeto.de.

enseñanza.y.la.concepción.de.aprendizaje.que.subyace.a.la.

propuesta;

-

. conocer.las.condiciones.de.evaluación.de.la.unidad.curricular.

en.cuanto.a.parciales.y.finales,.requisitos.de.entrega.de.tra-

bajos

.y.criterios.que.tomará.en.cuenta

.el.docente.o.el.equipo.

docente.para.decidir.la.aprobación;

-. contar.con.un.referente.en.el.que.encontrar.sugerencias.biblio-

gráficas

.para.la.profundización.de.ciertas.temáticas.afines.a.

la.propuesta.de.la.cátedra;

-. poseer.un.documento.escrito.que.en.cierto.sentido.‘garantiza’.

no.tener.que.enterarse.de.sus.obligaciones.académicas.de.un.

día.para.el.otro.

1.3. El proyecto de cátedra y la institución

Finalmente,.puede.pensarse.la.utilidad.del.proyecto.de.cáte-

d

ra.en.relación.con.la.Institución..Lejos.de.convertirse.en.un.ele-

 23Más.didáctica.(en.la.educación.superior)

mento.burocrático-administrativo.o.en.un.elemento.de.exclusivo.', 'chunk 28');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 29, 'control,.podrá.servir.para:

-. coordinar .acuerdos .referidos .a.la.ausencia .o.superposi-

c

ión.de.contenidos,.enfoques.epistemológicos, .propuesta.

metodológica.y.criterios.de.acreditación.propios.de.un.área;.

-. documentar.la.relación.entre.los.proyectos.académicos.de.la.

institución.y.la.concreción.de.éstos.a.través.de.las.cátedras;

-. poseer.un.elemento.más.para.la.evaluación .de.la.calidad.

académica;

-

. monitorear.la.articulación.de.los.contenidos.mínimos.pautados.

en.el.plan.de.estudios;

-. disponer.de.un.documento.de.valor.pedagógico.para.tomar.

decisiones.de.equivalencias.o,.por.el.contrario,.otorgar.pases.

a.otras.universidades.o

.institutos.superiores,.comunicando.

fehacientemente.la.propuesta.académica.de.la.cátedra.

2. Algunas sugerencias para su desarrollo

Sin.el.ánimo.de.constituir.una.receta,.muy.lejos.de.concebir.

esta.propuesta.como.una.prescripción.normativa,.pero.con.el.

afán.de.realizar.algún.tipo.de.sugerencia.práctica.que.oriente.la.

escritura,.quiero.hacer.explícitas.mis.propias.ideas.a.la.hora.de.

escribir.mis.proyectos.de.cátedra..A.modo.de.índice,.enumero.

los.apartados.que.incluyo:

-. Encabezamiento', 'chunk 29');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 30, '-. Actividad.académica.de.la.cátedra

-. Marco.referencial

-. Propósitos

-. Contenidos.

-. Marco.metodológico

-. Cronograma

-. Evaluación

-. Bibliografía.obligatoria

-. Bibliografía.de.consulta

24. Capítulo.1. .Los.proyectos.de.cátedra

2.1. Encabezamiento

El. encabezado . es. sólo. formalidad, . pero. formalidad . que.

informa.rápidamente.datos.institucionales.y.curriculares.míni-

mos.

.Sugiero.utilizar.un.enunciado.como.el.siguiente:

UNIVERSIDAD.NACIONAL.DE...

FACULTAD.DE...

Carrera:

Unidad

.curricular:

Cuatrimestre/Año.lectivo:

Cantidad.de.horas-reloj.semanales:

Equipo.de.cátedra:.Prof..Titular

Prof..Adjunto

J.T.P .

P

rof..Ayudante

Para.los.institutos.superiores,.convendría.agregar.algunos.

otros.datos.que.garanticen.la.movilidad.de.los.alumnos/as.por.

el.sistema.en.caso.de.querer.solicitar.equivalencias..He.aquí.un.

ejemplo:

I

NSTITUTO.SUPERIOR.DE.FORMACION.DOCENTE.Nº…

CARRERA.DE.PROFESORADO.DE…

Unidad.curricular:.

Curso:.

Cuatrimestre/Año.lectivo:.

Cantidad.de.horas.reloj.semanales:

Profesor/a:

Plan

.aprobado.por:.Resolución.Nº…

2.2. Actividad académica de la cátedra

La.universidad.define.su.función.social.a.partir.de.la.actividad.', 'chunk 30');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 31, 'de.docencia,.investigación.y.extensión..Creo.que.es.necesario.

que.estas.actividades.no.sólo.se.canalicen.a.partir.de.estructuras.

 25Más.didáctica.(en.la.educación.superior)

orgánicas.(existe.en.general.en.la.universidad.y.en.las.diferen-

t

es.unidades.académicas.de.una.universidad.una.Secretaría.de.

Extensión,.una.Secretaría.de.Investigaciones .y.una.Secretaría.

Académica).que.promuevan.y.estimulen.el.desarrollo.de.cada.una.

de.ellas,.sino.que.se.articulen.a.partir.de.la.actividad.académica.

de.cada.una.de.las.cátedras..Una.cátedra,.por.el.sólo.hecho.de.

serlo,.hace.docencia..Pero.una.cátedra.necesita.hacer.también.

investigación.y.puede,.con.algo.de.ingenio.y.sin.sobrecargar.su.

dedicación.habitual,.hacer.extensión..

Si.bien.en.la.norma.que.regula.la.educación.superior.aparecen.

como.nuevas.funciones.de

.los.Institutos.de.formación.docente.

la.realización.de.investigaciones.educativas.y.la.capacitación.a.

egresado/as.y.docentes.en.actividad.(en.algún.sentido.funciones.

de.extensión),.la.conformación.unipersonal.de.las.cátedras.y.el.

sistema.de.designaciones.por.hora-clase.hace.que.por.lo.menos.

por.ahora,.sea.poco.probable.la.integración.de.estas.funciones.', 'chunk 31');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 32, 'en.la.educación.superior.no.universitaria.en.relación.directa.con.

las.cátedras..En.todo.caso,.la.posibilidad.de.concursar.proyectos.

de.investigación.y/o.proyectos.de.extensión,.inserta.dichas.fun-

c

iones.en.los.institutos.superiores.de.formación.docente.pero.no.

como.una.actividad.inherente.al.desarrollo.de.las.c

átedras.sino.a.

las.iniciativas.personales.de.quienes.las.presentan.(y.al.margen.

de.la.actividad.de.la.docencia).o,.en.el.mejor.de.los.casos,.a.

programas.institucionales.consensuados.con.el.conjunto.de.los.

docentes.pero.que.son.asumidos.sólo.por.algunos.de.ellos..Por.

esta.razón.no.considero.apropiado.hacer.mención.a.este.rubro.

en.el.caso.de.cátedras.de.Institutos.Superiores..

Sin.embargo,.tal.como.lo.expresé.anteriormente,.no.concibo.

la.cátedra.universitaria.sin.integrar.las.tres.funciones.básicas..El.

proyecto.de.cátedra.puede.al.respecto,.comunicar.la.actividad.

académica.de.la.cátedra,.en.la.que.se.i

nvolucre.tanto.la.docencia.

como.la.investigación.y.la.extensión..

2.2.1. Investigación

La.investigación .es.una.actividad.inherente.a.la.vida.uni-

versitaria.

.Hacer.docencia.e.investigación.en.la.universidad.son.', 'chunk 32');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 33, 'actividades.interdependientes.y.complementarias,.por.lo.que.se.

26. Capítulo.1. .Los.proyectos.de.cátedra

desprende.que,.no.puede.pensarse.la.actividad.de.una.cátedra.al.

margen.de.algún.proyecto.de.investigación..

Si.bien.es.cierto.que.la.dedicación.a.la.investigación.es.una.

variable.directa.del.tipo.de.dedicación.administrativa.con.que.

los.miembros.de.una.cátedra.han.sido.nombrados.(me.refiero.

a.las.dedicaciones.habituales:.exclusiva-semiexclusiva-simple),.

también.es.cierto.que.la.posibilidad.de.investigar.no.queda.abso-

lutamente

.condicionada.por.ella..

En.este.sentido .el.término .‘investigación’.creo,.no.debe.

restringirse.únicamente.a.la.investigación.‘rigurosa’.y.avalada.

institucionalmente..Considero.necesario.que.una.cátedra.uni-

v

ersitaria.transite.también.la.experiencia.de.constituirse.como.

un.equipo.de

.trabajo.en.torno.a.la.investigación.que.resulte.del.

propio.interés.del.grupo..El.sistema.de.categorizaciones.para.la.

investigación.que.‘obliga’.a.que.una.investigación.esté.dirigida.

por.un.investigador.categorizado,.si.bien.garantiza.la.formación.

de.los.investigadores.en.equipos.dirigidos.por.quienes.acumulan.', 'chunk 33');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 34, 'antecedentes.y.experiencia.valiosa.en.este.tipo.de.práctica,.creo.

también.que.en.ocasiones.puede.distorsionar.y.cercenar.la.posi-

bilidad

.de.realizar.experiencias.más.autónomas.que.constituyan.

a.la.vez.aprendizajes.para.los.miembros.de.una.cátedra..

Así,.experiencias.de.investigación-acción.o.de.investigación.

educativa.pueden.resultar.posibles.de.ser.llevadas.a.cabo,.p

ueden.

dar.lugar.a.artículos.de.publicación.o.a.fichas.de.cátedra.y.resultar.

a.la.vez,.un.valioso.aporte.a.la.docencia.de.la.cátedra..Algunas.

condiciones.mínimas.parecen.al.respecto.indispensables:.

-. que.se.recorte.un.problema.de.investigación;

-. que.se.coincida.en.una.opción.metodológica;

-. que.en.función.de.la.opción.metodológica.se.indague.instru-

mentando

.algunas.técnicas.de.investigación;

-. que.se.sistematicen.informes,.análisis.y.conclusiones..

Si.se.coincidiera.con.esta.perspectiva,.la.sugerencia.que.rea-

lizo

.es.que.no.sólo.los.docentes.investigadores.hagan.mención.

a.su.trabajo.en.torno.a.la.investigación .en.sus.proyectos.de.

c

átedra,.sino.que.cada.cátedra.diseñe,.para.un.cierto.período,.

una.investigación.viable.a.la.que.también.puedan.integrarse,.si.', 'chunk 34');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 35, 'se.considerara.oportuno,.los.alumnos/as..

 27Más.didáctica.(en.la.educación.superior)

Propongo.al.respecto.que.en.el.proyecto.de.cátedra.se.deta-

l

len.aquellas.acciones.de.investigación.que.se.implementarán.

desde.la.cátedra.y.que.no.necesariamente.constituyen.líneas.de.

investigación.de.la.universidad..

2.2.2. Extensión

La.extensión, .pensada .desde.la.cátedra, .abarca.aquellas.

acciones.que.se.lleven.a.cabo.con.relación.a.otros.sujetos.que.

no.sean.los.alumnos/as.(como.empresas,.otras.instituciones,.

egresado/as,.docentes,.etc.)..

En.algunas.cátedras,.solemos.‘salir’.de.la.universidad.para.

aprender .en.situaciones .de.campo.a.partir.de.las.cuales.los.

alumnos/as.realizan.trabajos.prácticos,.monografías.o.informes.

documentados..Este.vínculo.que.se.establece.con.otro.tipo.de.

instituciones

.sociales.o.con.miembros.de.la.comunidad.(¿cuán-

tas

.veces.los.trabajos.prácticos.incluyen.encuestas.de.opinión.a.

ciudadanos?).creo.que.merece.algún.tipo.de.devolución.por.parte.

de.la.universidad.a.la.comunidad.que.la.sostiene..

Si.bien.tal.como.lo.aclaré.antes,.el.tipo.de.dedicación.es.una.

variable.de.peso,.también.aquí.creo.que.es.posible,.sin.mayores.', 'chunk 35');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 36, 'esfuerzos, .‘abrir’.una.parte.de.la.actividad .docente.con.sólo.

comunicar.al.‘afuera’.la.posibilidad.de.participar.de.ciertas.clases.

especiales.o.conferencias.abiertas,.contactarse.con.producciones.

escritas.de.la.propia.cátedra.o.de.los.alumnos/as.de.la.cátedra.

q

ue.puedan.resultar.de.interés.a.ciertos.sectores.o.brindar.algún.

otro.tipo.de.servicio.que.esté.al.alcance.de.las.posibilidades.de.

concreción.

P

ropongo.también.en.este.caso.que.en.el.proyecto.de.cátedra.

se.expliciten.las.posibilidades.de.extensión.que.la.cátedra.ofrece.

a.los.efectos.de.que.la.estructura.administrativa.correspondiente.

(¿la.Secretaría.de.Extensión?).pueda.dar.a.‘publicidad’.algo.de.lo.

que.se.dispone.y,.la.mayoría.de.las.veces,.se.desconoce..

2.2.3. Docencia

La.función.docente.resulta.ser.la.actividad.de.una.cátedra.

más.directamente.relacionada.con.la.comunicación.del.cono-

28. Capítulo.1. .Los.proyectos.de.cátedra

cimiento..No.es.mi.intención.en.este.capítulo.teorizar.sobre.la.

práctica.docente..

A.los.efectos.de.la.escritura.en.el.proyecto.de.cátedra.consi-

d

ero.oportuno.que.puedan.hacerse.explícitas.algunas.cuestiones.

tales.como:', 'chunk 36');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 37, '-. Cuál.es.la.responsabilidad.real.y.concreta.de.cada.uno.de.los.

miembros.de.la.cátedra.dentro.del.equipo.

-. Cómo.funciona.el.equipo.para.preparar.sus.clases.(frecuencia.

de.reuniones,.interrelación.clases.teóricas.y.clases.prácticas,.

estilo.de.reunión.de.cátedra,.etc.)..

-. Cómo.se.capacita.internamente.la.cátedra.(estudios,.lecturas,.

formación.de.nuevos.ayudantes,.etc.).

Los.ejemplos.son.peligrosos..Se.corre.el.riesgo.de.que.alguien.

convierta

.el.ejemplo.en.un.modelo..Pero.también,.los.ejemplos.

son.‘didácticos’.ya.que.permiten.visualizar.en.concreto.un.enun-

ciado

.teórico..Con.esta.última.intención,.y.sabiendo.del.riesgo,.

pondré.a.lo.largo.de.este.texto.un.ejemplo.de.cada.uno.de.los.

ítems.que.vaya.desarrollando..El.que.sigue,.podría.ser.el.relato.

correspondiente.a.la.Actividad de la cátedra.en .un.proyecto.de.

cátedra:.

A).Investigación

El.equipo.de.cátedra.realizará.en.los.próximos.tres.años.una.investigación.que.

pretende.sistematizar.y.analizar.los.supuestos.implícitos.en.los.instrumentos.

de.observación.en.aula.utilizados.por.los.directores/as.de.escuelas.de.educa-

ción', 'chunk 37');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 38, '.básica.a.fin.de.indagar.el.tipo.de.intervención.didáctica.que.caracteriza.la.

gestión.curricular.y.el.efecto.de.la.misma.sobre.la.modificación.de.las.prácticas.

de.los.docentes.desde.la.lógica.de.investigar.la.formación.docente.continua..A.

tal.efecto.se.trabajará.con.análisis.de.los.documentos.(grillas.de.observación.

de.clase).y.entrevistas.a.directivos.y.docentes.

B).Extensión

La.función.de.extensión.

s

e.ha.pensado.a.través.de.tres.clases.abiertas.a.las.

que.se.invitará.a.docentes.que.estén.a.cargo.de.unidades.curriculares.ligadas.

a.las.‘prácticas.de.enseñanza’.de.institutos .superiores.y.a.directores/as .de.

instituciones.escolares.en.las.que.se.trabajará.como.contenido.la.relación.entre.

la.observación, .la.práctica.pedagógica.en.el.aula.y.el.análisis.de.las.propias.

prácticas.

 29Más.didáctica.(en.la.educación.superior)

C).Docencia

La.cátedra.desarrolla.en.la.función.docente,.el.dictado.de.los.bloques.teóricos.

relativos.al.contenido.específico.de.la.disciplina.en.los.que.se.ha.optado.por.un.

carácter.teórico-práctico,.realizándose.en.forma.conjunta.actividades.de.análisis.

y.reflexión.con.actividades.de.producción.escrita.y.propuesta..', 'chunk 38');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 39, 'La.cátedra.realiza.una.reunión.semanal.de.trabajo.en.la.que.se.prepara.el.mate-

r

ial.a.trabajar.en.la.clase.y.en.la.que.se.analiza.la.marcha.de.la.cursada..Una.

vez.al.mes.la.reunión.de.equipo.es.una.reunión.de.estudio.en.la.que,.con.for-

mato

.de.seminario,.se.trabajan.nuevos

.textos.y.a.la.que.se.invita.a.participar.

a.egresado/as.de.la.carrera.

El.equipo.de.cátedra.ha.consensuado.distribuir.las.tareas.del.siguiente.modo:

-. Lic..Miguel.Panetta:.supervisión.del.trabajo.de.cátedra.en.sus.tres.funciones.

y.desarrollos.teóricos.en.docencia.

-. Lic..Ana.Villamayor:.coordinación.del.programa.de.investigación.y.desa-

rr

ollos.teóricos.en.docencia.

-. Lic..Roberto.Tubío:.organización.del.programa.de.extensión.y.desarrollos.

teórico-prácticos.en.docencia.

-. Lic..Dante.Balboni:.desarrollos.teórico-prácticos.en.docencia.y.asistencia.

operativa.a.los.otros.dos.programas..

2.3. Marco referencial

Cualquier.propuesta.de.trabajo.docente.se.fundamenta.implí-

c

itamente.en.una.serie.de.supuestos.que.le.d

an.sostén..Creo.

necesario.que.algunos.de.esos.supuestos.se.hagan.explícitos.

para.develar.el.posicionamiento.teórico.e.ideológico.de.una.cáte-

d', 'chunk 39');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 40, 'ra..Considero.que.estas.explicitaciones.constituyen.el.marco.

de.referencias.de.la.cátedra.y.por.ello.creo.apropiado.denominar.

a.este.ítem.marco referencial. .

Entiendo.al.marco.referencial.como.la.fundamentación.y.pre-

sentación

.de.la.propuesta.de.la.cátedra.específicamente.referida.

a.la.actividad.de.la.docencia.y.una.primera.anticipación.global.

del.proyecto.de.trabajo.con.los.alumnos/as.en.torno.al.conoci-

m

iento..Así,.como.primera.aproximación,.puede.funcionar.como.

el.prólogo.de.un.texto..

He.pensado.los.componentes.del.m

arco.referencial.a.los.efectos.

de.sugerir.alguna.guía.práctica.para.su.enunciado.y.así,.lo.he.con-

c

ebido.constituido.por.cuatro.marcos.(submarcos).específicos..

Las.orientaciones .prácticas, .ya.lo.he.anticipado .anterior-

mente,

.pueden.erróneamente.considerarse.como.prescripciones.

si.se.las.entiende.con.lógica.normativa..Aún.con.el.riesgo.de.

30. Capítulo.1. .Los.proyectos.de.cátedra

aburrir.con.la.misma.advertencia,.vuelvo.a.enfatizar.que.esta.pro-

p

uesta.sólo.intenta.sistematizar.mi.propia.experiencia.y.comuni-

car

.(y.socializar).un.instrumento.que.me.resulta.práctico.y.que.', 'chunk 40');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 41, 'veo.les.resulta.práctico.a.mis.alumnos/as..Desde.esta.idea.creo.

también.necesario.advertir.que.los.cuatro.marcos.específicos.

que.constituyen.el.marco.referencial,.no.son.cuatro.‘subtítulos’.

que.fragmentan.una.presentación.que.creo.conveniente.tomen.

estilo.narrativo..Con.la.natural.interrelación.que.tienen.nuestros.

propios.supuestos.teóricos,.con.igual.sentido.de.integración.

resulta.necesario.que.los.marcos.específicos.se.relacionen.entre.

sí.y.que.las.explicitaciones .que.se.hagan.al.r

eferirse.a.uno.de.

ellos,.guarden.coherencia.con.las.que.se.refieran.a.los.otros..

¿Por.qué.separarlos.aquí.entonces?.Lo.hago.sólo.a.los.efectos.

de.poder.analizar.la.elaboración.del.marco.referencial.con.algún.

grado.mayor.de.detalle..Podrá.ver.el.lector,.más.adelante,.algún.

ejemplo.en.el.que.éste.se.presenta.como.un.solo.relato.inte-

grado.

.El.marco.referencial.puede.incluir.entonces:

2.3.1. Marco curricular

La.propia.cátedra.no.es.una.cátedra.aislada,.sino.que.forma.

parte.de.un.conjunto.de.cátedras.que.un.alumno/a.cursará.para.

obtener.una.titulación..Ese.conjunto.es.llamado.habitualmente.

plan de estudios, .diseño curricular, .o.currícula5.y .es.el.que.le.da.', 'chunk 41');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 42, 'sentido.de.totalidad.a.la.formación.en.una.carrera..La.propuesta.

de.una.cátedra.tendrá.mayor.coherencia.con.el.plan.de.estudios.

al.que.la.unidad.curricular.pertenece.si.se.contempla.el.sentido.

de.dicha.totalidad.ya.que,.la.sola.experiencia.del.equipo.docente,.

no.parece.ser.un.elemento.suficiente.para.interpretar.la.direc-

cionalidad

.que.se.le.puede.dar.a.una.cátedra..De.allí.que.resulte.

necesario.analizar.los.propósitos.del.plan.de.estudios,.el.tipo.

de.necesidades.sociales.e.individuales.que.se.consideraron.en.

su.elaboración.y.otros.aspectos.con.el.fin.de.obtener

.un.mapa.

curricular.que.permita.visualizar.la.forma.en.que.se.apoyan.e.

5. Si.bien.las.nominaciones.‘plan.de.estudios’,.‘diseño.curricular’.o.‘currícula’.

se.corresponden.con.concepciones.teóricas.diferentes.acerca.de.un.mismo.

objeto,.usaré.aquí.la.denominación .‘plan.de.estudios’.de.modo.genérico.

evitando.plantear.en.este.capítulo.una.discusión.conceptual.al.respecto,.ya.

que.no.es.la.intención.teorizar.acerca.del.currículo.

 31Más.didáctica.(en.la.educación.superior)

integran.los.diferentes.contenidos.de.las.unidades.curriculares.de.', 'chunk 42');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 43, 'un.plan.de.estudios.(Díaz.Barriga,.1986)..El.análisis.que.el.equipo.

docente.realiza.del.plan.de.estudios.y.la.primera.interpretación.

que.hace.acerca.del.sentido.de.la.cátedra.en.un.determinado.

trayecto.de.formación,.puede.ser.comunicado.(y.creo.que.real-

mente

.vale.la.pena.hacerlo)..Hace.a.cierta.fundamentación.que.

subyace.a.nuestro.trabajo.

Tres.cuestiones.centrales.pueden.incluirse.aquí.considerando.

la.estructura.que.habitualmente.presenta.un.plan.de.estudios..

-. Describir.la.ubicación.de.la.unidad.curricular.en.el.plan.de.

estudios.con.relación.a.‘años’.de.cursada,.al.ciclo

.en.que.se.

encuentra.(por.ejemplo,.Ciclo.Básico.Común,.Ciclo.del.Pro-

fesor/a,

.Profesorado,.Ciclo.de.la.Licenciatura,.etc.).y.al.área/

espacio.disciplinar.al.que.pertenece.en.caso.de.que.existiera.

algún.agrupamiento.con.esta.clasificación.

-. Referirse.a.los.aportes.específicos.de.la.cátedra.al.tipo.de.

incumbencia.profesional.y.laboral.del.egresado/a.

-. Enunciar.qué.tipo.de.correlación.temática.se.vislumbra.entre.

la.propia.cátedra.y.otras.cátedras.tanto.anteriores .como.

posteriores.a.partir.de.la.lectura.que.se.haya.hecho.de.los.', 'chunk 43');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 44, 'contenidos.mínimos.de.cada.unidad.curricular.

2.3.2. Marco epistemológico

Me.parece.relevante.este.ítem..Tiene.que.ver.con.la.lectura.

y.e

l.posicionamiento .q ue.la.cátedra.realiza.en.relación.con.la.

disciplina.como.objeto.científico.y.como.producción.de.cono-

c

imiento.social.a.partir.de.lo.cual.se.desprende.su.núcleo duro.

como

.contenido.de.enseñanza..Así,.veo.que.dos.son.las.cues-

tione

s.más.importantes.que.pueden.comunicarse.en.este.ítem.

del.proyecto.de.cátedra:

-. Explicar.en.qué.línea.teórica.(dentro.de.las.opciones.posi-

bles)

.se.ubica.la.cátedra.con.relación.al.área.de.contenidos.

involucrados.en.la.misma..La.elección.de.esta.línea.supone.

tomar.‘partido’.por.un.enfoque.en.particular.o.realizar.una.

integración.de.distintas.corrientes.dentro.del.marco.c

ientífico.

y/o.tecnológico.de.la.disciplina.específica..Como.en.todos.los.

campos.del.conocimiento.existe.más.de.una.manera.de.con-

32. Capítulo.1. .Los.proyectos.de.cátedra

cebir.el.aspecto.de.la.realidad.que.se.estudia,.se.trata.aquí.de.

explicitar.claramente.cuál.es.la.corriente,.escuela,.tendencia,.

ideología.o.teoría.científica.que.sustenta.el.marco.teórico.', 'chunk 44');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 45, 'del.desarrollo.de.los.contenidos.que.la.cátedra.pondrá.como.

objeto.de.enseñanza..Las.preguntas.que.pueden.guiar.esta.

reflexión.podrían.ser.algo.así.como:.¿qué.es…. (la.disciplina).

para.nosotros/para.mí?;.¿cómo.la.concebimos/concibo.en.el.

contexto.social.del.conocimiento?

-. En.directa.relación.con.lo.enunciado.anteriormente,.surge.

entonces.la.necesidad.de.mostrar.y.justificar.el.núcleo.central.

de.contenidos.que.conforman.la.columna.vertebral.de.la.uni-

dad

.curricular,.en

.consonancia.con.los.contenidos.mínimos.

propuestos.en.el.plan.de.estudios.

2.3.3. Marco didáctico

También.me.parece.relevante.pensar.acerca.de.esta.necesaria.

definición..Si.antes.dije.que.el.marco.epistemológico.tiene.que.

ver.con.la.‘lectura’.y.el.‘posicionamiento’.que.la.cátedra.realiza.

en.relación.con.la.disciplina.como.objeto.científico.y.como.pro-

ducción

.de.conocimiento.social,.el.marco.didáctico.se.refiere.a.

la.disciplina.como.objeto.de.aprendizaje,.a.partir.de.lo.cual.se.

desprende.su.especificidad.particular.como.objeto.de.enseñanza.

y.su.entidad.como.conocimiento.comunicable.

El.marco.didáctico .se.vincula.con.el.referente.teórico.por.

el.que.opta.l', 'chunk 45');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 46, 'a.cátedra.con.relación.a.los.procesos.de.enseñar.

y.aprender.una.disciplina.en.particular..Si.bien.en.toda.situa-

c

ión.de.clase.hay.alguien.que.enseña.y.alguien.que.aprende.y.

esto.sucede.de.alguna.manera.en.particular,.la.concepción.que.

subyace.a.las.prácticas.de.dichos.procesos.puede.ser.distinta.

para.cada.situación-clase..Hoy.resulta.innegable.que.cada.disci-

plina

.tiene,.por.la.especificidad.de.su.contenido.y.sus.métodos.

de.investigación,.una.forma.que.le.es.propia.de.ser.aprehendida.

y.comunicada..Las.distintas.respuestas.a.estos.planteamientos.

también.suponen.la.elección.de.una.determinada.posición.que.

se.operativizará.en

.la.construcción.metodológica.que.concrete.

la.enseñanza..

La.reflexión.didáctica.que.intenta.comunicar.este.aspecto.

del.marco.referencial.se.refiere.a.las.concepciones.que.adopta.la.

 33Más.didáctica.(en.la.educación.superior)

cátedra.respecto.al.proceso.de.enseñar.y.al.proceso.de.aprender.

la.disciplina.que.es.objeto.de.conocimiento.en.el.aula..Las.pre-

g

untas.que.pueden.guiar.esta.reflexión.se.corresponderían.por.

ejemplo.con:.¿qué.tienen.que.‘hacer’.en.términos.cognitivos.los.', 'chunk 46');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 47, 'alumnos/as,.para.aprender.esta.disciplina?;.¿cómo.vamos/voy.

a.intervenir .en.consecuencia.desde.la.cátedra.en.términos.de.

enseñanza?

No

.estoy.diciendo.que.la.explicación.se.refiere.a.las.activida-

des

.de.trabajos.prácticos.ni.a.los.recursos.didácticos,.ni.a.nada.

que.se.relacione.con.la.concreción.metodológica..Más.bien,.se.

enmarca.en.las.opciones.teóricas.acerca.de.las.concepciones.

del.apr

endizaje,.de.la.enseñanza.y.del.conocimiento..Definir.las.

opciones teóricas .t ampoco.supone.‘copiar’.una.definición .de.

aprendizaje,.de.enseñanza.o.de.conocimiento.de.algún.texto.o.

de.algún.autor.con.el.que.se.acuerda,.sino.por.el.contrario,.hacer.

la.propia.construcción.teórica.que.pueda.surgir.de.la.reflexión.

sobre.las.prácticas.que.una.cátedra.acumula.como.experiencia.y.

que.evidencie.su.punto.de.vista.al.respecto.

2.3.4. Marco institucional

En.ocasiones.ciertas.particularidades.coyunturales.del.con-

t

exto.sociohistórico, .de.la.propia.institución .o.del.grupo.de.

alumnos/as.pueden.llegar.a.incidir.fuertemente.sobre.el.desa-

r

rollo.de.las.clases.y,.en.consecuencia,.condicionar.alguna.d

e.

las.decisiones.que.el.equipo.docente.de.la.cátedra.debe.tomar.al.', 'chunk 47');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 48, 'realizar.las.previsiones.para.la.puesta.en.marcha.de.su.proyecto.

de.cátedra..

Si.una.facultad.fuera.a.ser.sede.de.un.Congreso.de.educa-

c

ión.probablemente.las.cátedras.del.área.realizarían,.en.particular.

ese.año,.algún.tipo.de.trabajo.para.favorecer.la.presentación.de.

ponencias.o.la.participación.de.los.alumnos/as.en.algunos.de.

los.grupos.de.trabajo..Si.un.instituto.superior.cumple.un.año.

el.quincuagésimo .aniversario .de.su.creación,.probablemente.

se.realicen.en.algunas.de.las.cátedras .algún.tipo.de.trabajo.

investigativo.para.recuperar.parte.d

e.la.memoria.institucional.

‘perdida’..En.ambos.ejemplos,.la.variable.‘institucional’.condi-

c

ionará.de.alguna.manera.parte.del.trabajo.del.año.en.torno.a.los.

contenidos..Del.mismo.modo.podrían.pensarse.algunos.ejemplos.

34. Capítulo.1. .Los.proyectos.de.cátedra

relacionados.con.los.alumnos/as.o.con.el.contexto,.casos.en.los.

que,.la.incidencia.de.algún.factor.ocasional,.podría.a.modo.de.

excepción,.modificar.la.práctica.docente.habitual..

Creo.que.en.casos.como.el.ejemplo.mencionado,.vale.la.pena.

que.en.ese.marco.que.constituye.el.marco.referencial.se.haga.', 'chunk 48');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 49, 'alguna.mención.a.ello,.sencillamente.porque.se.está.comuni-

c

ando.algo.que.atravesará .la.práctica .de.la.enseñanza. .Pero.

insisto.en.el.carácter.orientativo .y.de.sugerencia.práctica.de.

este.texto.y.aclaro,.una.vez.más,.que.no.estoy.diciendo.que.un.

proyecto.de.cátedra.‘debe’.incluir.un.marco.referencial.en.el

.que.

necesariamente.se.identifiquen.un.marco.curricular,.un.marco.

epistemológico,.un.marco.didáctico.y.un.marco.institucional..

He.aquí.un.ejemplo.de.su.redacción:

MARCO.REFERENCIAL

Inserta.en.el.profesorado.y.precedida.por.correlatividad.únicamente.por.Didác-

tica

.I,.esta.cátedra,.Didáctica.IV ,.se.ubica.en.la.línea.de.análisis.de.las.unidades.

curriculares.cuyo.objeto.de.estudio.se.centra.en.torno.a.los.procesos.áulicos.

y.curriculares .en.la.carrera.de.Ciencias.de.la.Educación. .La.correlación .con.

Didáctica.I.resulta.relevante,.ya.que.se.retoma.el.estudio.realizado.acerca.del.

campo.específico.de.la.didáctica.general.para.analizarlo.ahora.en.el.contexto.

de.la.educación.superior..

Atendiendo.a.la.especificidad.del.perfil.de.la.carrera,.esta.cátedra.pretende.apor-

tar

.al.futuro.egresado/a.la.posibilidad.de', 'chunk 49');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 50, '.poder.identificar.y.poner.en.discusión.

distintas.variables.que,.centradas.en.el.eje.del.análisis.de.las.propias.prácticas,.

posibiliten.trabajar.en.torno.a.la.intervención.e.investigación.de.las.prácticas.

de.la.enseñanza.en.la.educación.superior,.con.especial.énfasis.en.el.ámbito.de.

la.formación.docente..Por.tal.razón,.se.consideró.oportuno.abordar.una.línea.de.

análisis.que.vaya.de.lo.particular.a.lo.general.con.una.secuencia.práctica-teoría-

práctica,.en.la.cual.la.reflexión.en.torno.a.la.práctica.docente.en.la.educación.

superior,.será.un.eje.que.atravesará.cada.una.de.las.clases.

Los.trabajos.de.campo,.

q

ue.complementan.la.carga.horaria.teórica.de.Didáctica.

IV ,.se.operativizarán.por.medio.de.prácticas.pedagógicas.a.través.de.la.inserción.

de.los/las.alumnos/as.en.cátedras.de.la.educación.superior.no.universitaria.

–institutos.superiores.de.formación.docente–.en.las.que.los/las.practicantes.

asumirán.todas.las.responsabilidades.inherentes.al.trabajo.docente..A.fin.de.

resolver.las.primeras.urgencias.derivadas.de.la.intervención.desde.la.enseñanza.

en.las.prácticas.pedagógicas,.la.línea.temática.de.las.primeras.clases.aborda.', 'chunk 50');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 51, 'las.prácticas.de.enseñar.y.aprender.en.la.educación.superior.y.algunos.recur-

s

os.didácticos.específicos.para.el.nivel..A.partir.de.allí,.con.un.e

ncuadre.más..

a

nalítico,.se.desarrollará.la.problemática.de.los.contenidos.y.el.conocimiento.

en.la.educación.superior.para,.sobre.el.final,.tomar.la.cuestión.específica.de.la

 35Más.didáctica.(en.la.educación.superior)

formación .docente.y.sus.lineamientos .político-curriculares, .especialmente.

dentro.del.ámbito.de.la.provincia.de.Buenos.Aires,.ubicación.geográfica.de.

esta.universidad.

La.propuesta.didáctica.parte.de.la.premisa.de.considerar.el.aula.como.un.ámbito.

de.reflexión.y.acción.que.permita.‘repreguntarse’.la.didáctica,.teorizando.acerca.

de.la.práctica.y.poniendo.en.juicio.analítico.la.teoría..Para.ello,.se.utilizarán.

diversas.estrategias.de.enseñanza.apropiadas.para.el.nivel,.las.que.serán.a.su.

vez.analizadas.teóricamente.en.cuanto.a.su.pertinencia.para.el.trabajo.en.la.

educación.superior,.sobre.el.final.de.cada.clase..

Entendemos.al.conocimiento.como.un.proceso.dialéctico.

q

ue.permite.compren-

der

.y.transformar.la.realidad,.oponiéndonos.al.saber.como.algo.dado.y.abso-

luto.', 'chunk 51');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 52, '.Optamos.por.una.didáctica.concebida.como.teoría.acerca.de.las.prácticas.

de.enseñanza.en.contextos.sociohistóricos.determinados,.cuyos.postulados.

supongan.una.interrelación.permanente.entre.la.indagación.teórica.y.la.práctica.

pedagógica.y.cuyo.objeto.de.estudio.se.centre.en.torno.a.las.prácticas.docen-

tes

.especialmente.en.el.contexto.particular.del.‘aula’,.en.tanto.espacio.social.

simbólico.condicionado .por.múltiples.variables..Esta.concepción.teórica.se.

posiciona.en.una.didáctica.de.corte.socioantropológico.que,.a.la.vez.que.intenta.

develar.los.supuestos.implícitos.en.las.prácticas.docentes,.pr

etende.‘narrar’.la.

cotidianeidad.del.aula.de.la.educación.superior..Finalmente.entendemos.que.la.

relación.docente-alumnos/as.se.inscribe.en.las.pautas.del.contrato.didáctico.

que.es.necesario.develar.y.explicitar.hasta.los.límites.de.lo.posible.

Las.características .que.habitualmente.presentan.los.alumnos/as,.en.general.

cursantes.del.último.año.de.la.carrera,.entre.los.que.se.identifican.altos.porcen-

tajes

.de.profesionales.y/o.estudiantes.del.área.de.Psicopedagogía.y,.a.la.vez,.un.

importante.grupo.con.experiencia.docente.en.los.distintos.niveles.del.sistema,.', 'chunk 52');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 53, 'ofrece.un.particular.desafío:.enriquecer.explícitamente.los.saberes.portados.por.

el.grupo.respecto.a.la.práctica.docente.a.la

.vez.que.lograr.no.perder.la.línea.de.

análisis.propia.de.la.didáctica.en.el.ámbito.de.las.Ciencias.de.la.Educación.

2.4. Propósitos 

2.4.1. El planteo de objetivos

Durante.muchos.años,.los.distintos.modelos.de.planificación.

áulica,.dieron.sustancial.importancia.a.los.objetivos,.pero.fue.

el.modelo.didáctico.tecnológico.(más.conocido.en.la.docencia.

como.modelo.conductista),.el.que.otorgó.a.la.formulación.de.

objetivos.un.lugar.de.relevancia..La.planificación.se.convirtió.así.

en.‘la’.herramienta.que.había.que.manejar.y.dentro.de.ella.los.

objetivos.en.‘el’.elemento.vedette.de.la.planificación..El.supuesto.

teórico.que.se.impuso,.con.argumentos.n

o.muy.sólidos.a.la.

hora.de.cotejar.la.teoría.con.las.prácticas.docentes,.fue.que.una.

36. Capítulo.1. .Los.proyectos.de.cátedra

buena.(entendiendo.‘buena’.por.‘correcta’.en.sentido.técnico).

formulación.de.objetivos,.era.suficiente.para.garantizar.el.éxito.

y.la.eficiencia.en.el.logro.de.resultados.de.aprendizaje.por.parte.

de.los.alumnos/as..Por.ello,.su.correcta.formulación,.pasó.a.ser.', 'chunk 53');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 54, 'un.imperativo.de.la.tarea.docente.(recordarán.algunos.colegas.

los.listados.de.verbos.que.se.usaban.al.modo.de.‘machetes’.para.

preparar.las.planificaciones)..

Desde.la.lógica.tecnológica,.los.objetivos.tratan.de.enunciar.

qué.aprendizajes,.en.relación.con.los.contenidos,.se.espera.que.

realicen.los.alumnos/as.como.‘productos’.parciales.y.finales.de.

la.cursada.de.una.unidad.curricular..Los.objetivos.r

epresentan.la.

descripción.de.la.ejecución,.entendida.como.realización.de.una.

actividad,.que.se.pretende.que.los.alumnos/as.estén.en.condi-

c

iones.de.realizar.antes.de.que.se.les.considere.competentes..

El.objetivo,.desde.este.punto.de.vista,.describe.un.resultado.

previsto,.antes.que.el.proceso.mismo.(Mager,.1979).

La.mayoría.de.los.textos.de.la.época.(la.década.de.1970),.

precisa.que.un.objetivo.es.bidimensional,.es.decir,.está.consti-

tuido

.por.dos.dimensiones:.una.está.representada.por.un.verbo.

que.como.tal.indica.qué.acción.han.de.poder.realizar.los.alum-

n

os/as;.la.otra.está.representada.por.el.contenido,.por.medio.del.

c

ual.dicha.acción.se.concretiza..Como.la.garantía.de.la.acción.

lograda.sólo.es.posible.en.la.medida.en.que.ésta.pueda.compro-

b', 'chunk 54');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 55, 'arse,.las.conductas.explícitas.en.los.objetivos.a.través.de.los.

verbos,.necesariamente,.deben.ser.observables,.es.decir,.debe.

poder.verse.la.operación.(acción).que.realizan.los.alumnos/as.

(de.allí.el.concepto.de.objetivo.operacional .u.operativo). .Por.

otra.parte,.a.los.efectos.de.poder.observar.la.conducta,.la.ope-

r

ación,.el.contenido.debe.referirse.a.una.parcela.fragmentada.

de.un.todo,.posible.de.constituirse.en.el.medio.funcional.con.

el.que.la.conducta.se.pone.de.manifiesto.en.una

.clase.y.no.en.

una.serie.de.clases..

¿Algunos.ejemplos?

 37Más.didáctica.(en.la.educación.superior)

Que.los.alumnos/as.sean.capaces.de:

-.Solucionar.problemas.aritméticos.de.porcentaje

acción.(externa.y.visible) contenido.(fragmentado)

-.Caracterizar .la.estructura .del.aparato .psíquico .según.la.

escuela.psicoanalítica

acción.(externa.y.visible) contenido.(fragmentado)

El.modelo.tecnológico.de.formulación.de.objetivos.ha.sido.

objeto.de.análisis.y.crítica.en.casi.toda.la.bibliografía.pedagó-

gica

.de.la.década.de.1980,.tanto.por.su.concepción.subyacente.

en.lo.ideológico,.como.por.sus.supuestos.teóricos.en.términos.', 'chunk 55');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 56, 'de.aprendizaje.y.enseñanza,.sobre.todo,.la.fragmentación.del.

proceso.de.aprendizaje.en.partículas.ficticias.(ya.que.aprender.

es.un.proceso.complejo.que.está.lejos.de.concretarse.por.una.

sumatoria.de.logros.parciales.y.lineales.que.se.encadenan),.el.

minucioso.afán.tecnocrático .que.invadió.las.prácticas.(cum-

p

lir.con.una.planificación.bien.hecha.fue.más.importante.que.

‘pensar’.la.clase).y.e

l.desconocimiento.del.proceso.como.algo.

inherente.al.aprendizaje.(aprender.es.un.proceso.que.supone.

avances,.retrocesos,.detenciones,.contrastaciones,.construccio-

n

es.y.deconstrucciones,.etc..de.los.que.rara.vez.el.producto.final.

logra.dar.cuenta).

2.4.2. El planteo de expectativas de logro

A.partir.de.la.formulación.de.los.C.B.C.6.y.acompañando.la.

transformación.del.sistema.educativo.en.Argentina.en.la.década.de.

1990,.un.nuevo.concepto.con.relación.a.los.logros.de.aprendizaje.

de.los.alumnos/as,.comienza.a.circular:.las.“expectativas.de.logro”..

6. CBC.se.refiere.a.los.Contenidos.Básicos.Comunes.aprobados.por.el.Consejo.

Federal.de.Cultura.y.Educación .para.todo.el.país.durante.la.gestión.de.la.

Ministro.Susana.Decibe..', 'chunk 56');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 57, '38. Capítulo.1. .Los.proyectos.de.cátedra

En.el.Marco.General.del.Diseño.Curricular.de.la.provincia.de.Bue-

n

os.Aires.(1999).las.expectativas.de.logro.son.definidas.así:

“…. las.Expectativas.de.Logro.son.metas.mínimas.a.las.

cuales.arribar,.mediante.la.selección.y.propuesta.de.los.

contenidos.socialmente.legitimados.y.las.estrategias.

didácticas.adecuadas.que.garanticen.la.adquisición.de.

competencias.

. R

especto.de.este.tema,.las.expectativas.remiten.al.

logro.de.competencias,.entendidas.éstas.como.capa-

cidades

.complejas..Las.competencias.implican.el.valor.

formativo.para.su.aplicación.en.todas.las.circunstancias.

de.la.vida,.y.por.otro,.la.posibilidad.de.adquisición.de.

saberes.específicos..

. Se.podrá.observar.que.en

.la.formulación.de.Expec-

t

ativas . de. Logro. se. requiere . explicitar . contenidos.

integradores,.ideas.globales,.que.denoten.que.todos.los.

contenidos.relevantes.están.incluidos..Las.expectativas.

jurisdiccionales.tienen.como.fin.establecer.logros.que.

garanticen.la.calidad.educativa.y.la.igualdad.de.opor-

tunidades.

.

. (…) .Las.Expectativas.de.Logro.implican:.capacidades.', 'chunk 57');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 58, 'a.desarrollar.y.contenidos.mediante.los.cuales.éstas.se.

desarrollan..La.capacidad.supone.una.potencialidad.que.

necesita.desplegarse;.en.ello.intervienen:.las.interven-

ciones

.de.todos.los.agentes.sociales.–en.particular,.las.

sistemáticas.del.docente–,.así.como.las.actitudes.del.

alumno/a.y.todos.los.sucesos.de.su.vida,.que.aún.siendo.

fortuitos.tienen.

incidencia”.

Tal.vez.quienes.hayan.impuesto.el.concepto.de expectativas 

de logro.h an .pretendido.llenar.el.vacío.que.la.caída.conceptual.de.

los.objetivos.dejó .al.descubierto..El.afán.de.precisar.qué.se.debe.

aprender.parece.ser.una.característica.natural.de.los.sistemas.

educativos..

Uno.de.los.primeros.aportes.para.llenar.el.vacío.que.dejara.

la.retirada.en.el.discurso.didáctico.de.los.objetivos.operativos,.

fue.el.de.Ángel.Díaz.Barriga..En.Didáctica y Currículum (1986) .

el.autor.mejicano.plantea.la.necesidad.de.describir.en.los.pro-

g

ramas.aquellos.aprendizajes.que.se.dan.con.cierto.grado.de.

integración.y.estructuración.en.todos.los.niveles.de.la.conducta.

 39Más.didáctica.(en.la.educación.superior)

humana.(esta.es.una.clara.respuesta.a.la.clásica.división.–que.', 'chunk 58');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 59, 'el.modelo.tecnológico.instaló–.de.formulación.de.objetivos.por.

áreas.de.la.conducta.en.los.dominios.de.lo.cognitivo,.de.lo.socio-

afectivo.y.de.lo.psicomotriz).que.permiten,.a.su.vez,.integrar.

la.información.a.lo.largo.de.un.curso..Según.su.propuesta,.la.

elaboración.de.productos.o.resultados.de.aprendizaje.(que.deno-

m

ina.objetivos terminales ).o bedece.a.una.necesidad.curricular.

de.establecer.ciertos.elementos.de.acreditación..Si.bien.él.no.

ha.vuelto.sobre.este.tema,.intuyo.que.hoy.probablemente.no.

sólo.no.resulte.de.su.interés.académico.un.planteo.como.éste,

.

sino.que.probablemente.no.acuerde.con.estas.ideas.formuladas.

contextualmente .en.otra.época..Pero.parece.indudable.que.la.

concepción.de.expectativa de logro.tiene .parte.de.sus.raíces.en.

estos.primeros.aportes.ligados.a.la.idea.de.aprendizajes.que.se.

dan.como.resultado.de.la.integración.de.la.conducta.y.la.infor-

mación

.a.lo.largo.de.un.curso.

Pero.sin.duda,.la.mayor.incidencia.se.vislumbra.en.la.biblio-

grafía

.que.sustentó.teóricamente.la.reforma.española..En.parti-

cular

,.los.aportes.de.César.Coll.(1994),.para.quien.los.objetivos.', 'chunk 59');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 60, 'terminales.deben.clasificarse.en.tres.campos:.el.del.saber,.el.del.

saber.hacer.y.el.

del.valorar..

El.campo.del.saber.se .refiere.a.la.incorporación.significativa.

de.datos,.hechos,.principios,.teorías,.conceptos,.reglas,.etc.,.que.

pasan.a.formar.parte.del.caudal.informativo.de.los.alumnos/as.y.

que.le.permitirán,.cuando.le.sea.necesario,.utilizarlos..

El.campo.del.saber hacer.s e.refiere.a.todo.tipo.de.habilida-

des,

.destrezas.y.posibilidades.prácticas.o.al.decir.de.las.nuevas.

terminologías.que.incluyen.a.todas.estas.formulaciones.a.los.

procedimientos.que.deben.incorporar.los.alumnos/as.a.propósito.

del.trabajo.con.ciertos.contenidos.específicos..Para.Coll.aprender.

procedimientos.quiere.decir.que.se.es.capaz.de.hacer.uso.de.algo.

(información,.i

nstrumentos,.tecnologías,.etc.).en.diversas.situa-

ciones

.y.de.diferentes.maneras.con.el.fin.de.resolver.problemas.

planteados.y.alcanzar.las.metas.fijadas.

Finalmente.aprender.en.el.campo.del.valorar.s ignifica .para.

Coll.que.“se.es.capaz.de.regular.el.propio.comportamiento.de.

acuerdo.con.el.principio.normativo.que.dicho.valor.estipula”..

Dentro.de.este.campo.también.se.incluyen.las.normas.y.las.', 'chunk 60');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 61, 'actitudes..

40. Capítulo.1. .Los.proyectos.de.cátedra

Si.bien.en.Argentina.la.idea.de.las.expectativas.de.logro.está.

muy.cercana.a.la.de.objetivos.terminales,.no.ha.habido.un.afán.

clasificatorio .en.lo.mostrado.más.arriba.aunque.la.referencia.

explícita.a.una.división.de.tal.tipo,.puede.observarse.en.algunos.

documentos .oficiales. .Una.vez.más,.el.Marco.General.de.los.

Diseños.Curriculares.de.la.Pcia..de.Bs..As..lo.ejemplifica:.“…la.

adquisición.de.competencias,.mediante.la.apropiación.de.conte-

nidos

.conducentes.a.un.saber,.saber.hacer.y.valorar.(…)”..

Veamos.algunos.ejemplos.en.los.que.se.evidencia.la.formu-

lación

.de.una.expectativa.de.logro.en.la.que.puede

.identificarse.

la.presencia.de.las.competencias.y.contenidos.globales:.

-. “ Al.finalizar.su.formación.los.futuros.docentes:.

. Comprenderán.la.especificidad.de.los.hechos.y.las.prácti-

c

as.educativas.como.realidad.diferenciada.de.otros.hechos.

y.prácticas.humanas.y.sociales..Comprenderán.en.particular.

las.características.de.cada.uno.de.los.elementos.del.triángulo.

didáctico.(maestro,.alumno/a,.contenido).y.sus.múltiples.

interrelaciones”.(de.los.C.B.C..para.la.formación.docente.de.', 'chunk 61');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 62, 'grado,.1997).

-. “Al.finalizar.la.Educación.Polimodal,.los.estudiantes.de.la.

Modalidad.Economía.y.Gestión.de.las.Organizaciones.estarán.

en.condiciones.de:

. Comprender.la.naturaleza.de.las.relaciones.jurídicas.de.las.

organizaciones,.s

u.actuación.responsable.ante.situaciones.

en.que.sean.parte,.las.formas.jurídicas.que.pueden.adop-

t

ar.y.las.distintas.modalidades.que.pueden.conformar.los.

agrupamientos.empresarios”.(de.los.C.B.C..para.la.educación.

polimodal,.1997).

-. “Conocimiento.y.análisis.del.proceso.histórico.latinoameri-

cano

.y.el.proceso.de.formación.de.la.Nación.Argentina”.(del.

diseño.curricular.para.la.formación.docente.de.grado.de.la.

Pcia..de.Bs..As.,.profesorado.de.tercer.ciclo.de.la.EGB.y.de.la.

educación.polimodal.en.Historia,.1999).

 41Más.didáctica.(en.la.educación.superior)

2.4.3. El planteo de propósitos

No.estoy.de.acuerdo.con.la.concepción.teórica.que.subyace.

a.la.formulación.de.las.expectativas.de.logro.ni.creo.necesario.

que.haya.que.realizar.alguna.formulación .que.pre-establezca.

los.aprendizajes.que.un.adulto.deba.o.vaya,.supuestamente,.a.

realizar..

Creo.que.la.presencia.de.las.expectativas .de.logro.en.los.', 'chunk 62');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 63, 'diseños .didácticos .alimenta .la.concepción .burocrática .de.la.

planificación.al.explicitarse.enunciados.que.dormitan.en.algún.

papel.y.que.no.orientan.las.prácticas.de.enseñanza.ni.resultan.

ser.un.referente.válido.para.la.acreditación.de.los.aprendizajes..

No.veo,.desde.este.último.punto.de.vista,.que.la

.relación.entre.

las.expectativas.de.logro.y.la.evaluación.sea.una.referencia.clara.

en.el.momento.de.tener.que.tomar.decisiones.respecto.a.qué.y.

cómo.evaluar.en.términos.de.acreditaciones..La.direccionalidad.

de.la.evaluación,.puede.obtenerse.desde.otro.eje.de.relaciones.

que.no.se.centre.en.la.lógica.binómica.expectativa .de.logro-

evaluación..

Estoy.convencido.de.que,.por.las.características.peculiares.

de.los.alumnos/as.adultos,.la.previsión.de.los.aprendizajes.que.

se.vaya.a.realizar.no.resulta.más.que.una.ilusión.y.que,.una.vez.

más,.creer.que.éstos.son.previsibles,.no.hace.más.que.aportar.a.

la.

falsa.concepción.del.grupo-clase.como.un.todo.homogéneo..

Desde.el.sentido.común.podría.afirmarse .que.siendo.los.

alumnos/as .de.la.educación.superior.adultos,.ya.poseen.una.

estructura.cognitiva.acorde.para.la.apropiación.de.cualquier.tipo.', 'chunk 63');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 64, 'de.saberes.y.una.matriz.de.aprendizaje.fuertemente.conformada..

En.el.mismo.sentido,.algún.viejo.modelo.teórico.de.la.psicología.

del.desarrollo.los.consideraría.como.sujetos.universales.y.abs-

tractos

.(en.el.sentido.de.que.todo.sujeto.de.dicha.franja.etaria.

se.comportaría.más.o.menos.igual,.independientemente.de.la.

situación.espacio-temporal.y.socio-histórica).y.con.desarrollo.

completo.(en.el.sentido.de.que.no.se.evidenciarían .y

a,.cam-

b

ios.importantes.en.su.desarrollo)..Podría.también.reafirmarse.

que.aún.siendo.alumnos/as.adultos,.su.actividad.dentro.de.una.

institución.educativa.está.regida.por.el.tipo.de.lógica.inherente.

al.tipo.de.actividad.que.en.ellas.se.lleva.a.cabo,.es.decir.que.la.

categoría.‘alumno/a’.es.una.categoría.extendible.a.todo.sujeto.

42. Capítulo.1. .Los.proyectos.de.cátedra

que.cumple.dicho.rol,.en.cualquier.momento.de.la.vida,.pero.que.

adquiere.una.contextualización .particular.para.cada.situación.

histórica.y.para.cada.si tuación .institucional.a.partir.de.la.cual.se.

define,.aunque.sólo.en.una.mínima.parte,.lo.que.ser.alumno/a.

significa.(Steiman,.2004).

Pero,.por.sobre.todas.las.cosas.por.ser.adultos,.están.pre-

c', 'chunk 64');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 65, 'edidos.por.la.historia.personal.de.cada.sujeto.y.por.el.‘lugar’.

desde.el.que.participan.(o.pueden.participar).en.las.prácticas.

sociales.dentro.de.un.determinado.orden.social.que.condiciona.

dichas.prácticas..Y.son.alumnos/as.y.como.tales,.no.parten.del.

punto.cero.en.su.inser

ción.institucional.ya.que.han.pasado.por.

otras.instituciones.escolares.previamente.y.cada.uno.de.ellas.

ha.‘modelado’.en.cada.alumno/a.una.concepción.acerca.de.la.

participación .institucional .en.las.prácticas.educativas.y.de.lo.

que.significa.aprender.dentro.de.ellas.

Así,.cada.estudiante.adulto.por.las.diferentes.prácticas.socia-

l

es.que.acumula.y.por.las.diferentes.prácticas.sociales.de.las.que.

(y.‘en.las.que’.y.‘como’).participa,.por.los.diferentes.saberes.que.

maneja,.distintos.en.cada.uno.por.sus.experiencias.anteriores,.

suele.aprender.dimensiones.muy.diferentes.de.un.mismo.objeto.

de.conocimiento..Establecer.cuál.va.a.ser.el.logro.final.de

.apren-

dizaje

.sería,.desde.esta.óptica,.una.suposición.que.se.acercaría.

a.la.magia..

Por.todo.ello.creo.que.lo.único.realmente.hipotetizable.es.

aquello.que.se.propone.el.equipo.docente.desde.la.óptica.de.', 'chunk 65');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 66, 'la.enseñanza. .Es.decir,.aquello.que.se.propone.enseñar.y.no.

aquello.que.se.propone.(o.su.expectativa).respecto.a.lo.que.los.

alumnos/as.deberían.aprender..Por.esa.razón,.prefiero.plantear.

propósitos.

L

os.propósitos.tratan.de.mostrar,.desde.la.óptica.de.la.ense-

ñ

anza,.qué.dirección.intenta.dársele.al.proceso.áulico.o.en.otros.

términos,.qué.ofrece.el.equipo.docente.en.términos.de.lo.que.

la.cátedra.puede

.garantizar.como.prácticas.que.sucederán.en.el.

aula,.ya.sea.por.posicionamiento.teórico,.por.concepción.ideo-

l

ógica,.por.propuesta.metodológica.o.por.el.uso.de.ciertos.recur-

s

os..En.ese.caso,.prima.enunciar.la.acción.docente.con.relación.al.

núcleo.central.de.contenidos.puestos.en.juego.en.la.cátedra..

 43Más.didáctica.(en.la.educación.superior)

¿Y.cómo.se.direcciona.la.evaluación?.Considero.que.el.eje.

debe.posicionarse.en.la.relación:.contenidos-método-criterios.de.

acreditación..Ya.volveré.sobre.este.aspecto.más.adelante.

Así,.en.los.propósitos,.la.acción.(el.verbo.de.la.formulación).

es.una.acción.del.docente.ya.que.hace.referencia.a.un.hacer.

propio.y.específico.del.mismo..Probablemente.las.formulaciones.', 'chunk 66');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 67, 'se.refieran.a.acciones.que.tengan.que.ver.con.el.‘promover…’.o.

el.‘facilitar…’.etc.

La.sugerencia.práctica.aquí,.es.hacer.explícitos.los.propó-

s

itos.del.equipo.docente.en.el.proyecto.de.cátedra.como.una.

manera.más.de.‘blanquear’.alguna.parte.explicitable.del.contrato.

didáctico.

He

.aquí.un.

ejemplo:.

PROPÓSITOS

-. Proponer,.en.el.contexto.de.las.prácticas.de.enseñanza.de.la.educación.

superior,.una.línea.de.debate.permanente.acerca.del.campo.de.la.didáctica.

que.someta.a.discusión.y.confrontación.el.carácter.normativo,.histórica.

configuración.del.campo,.y.el.carácter.interpretativo-crítico,.propuesta.con-

temporánea

.de.conformación.del.mismo.

-. Plantear.un.enfoque.de.indagación.que.permita.abordar.el.análisis.de.las.

prácticas.docentes.en.el.ámbito.de.la.educación.superior.

-. Favorecer.la.posibilidad.de.confrontar.las.representaciones .acerca.de.las.

prácticas.docentes.en.la.educación.superior.y.las.prácticas.mismas..

-. Ofrecer.una.propuesta.académica.honesta.en.la.que.la.responsabilidad.pr

o-

fesional

.de.la.cátedra.se.corresponda.con.el.legítimo.derecho.a.aprender.y.

estudiar.con.seriedad.y.profundidad.', 'chunk 67');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 68, '-. Adherir.a.las.posturas.que.entienden.que.desde.el.análisis.de.las.prácticas.

docentes.puede.construirse.teoría.didáctica.

Y.aquí.otros.ejemplos.sueltos.pertenecientes.a.otras.áreas.

del.conocimiento:

-. Promover.el.análisis.de.situaciones.de.la.vida.cotidiana.a.la.luz.del.Derecho.

Constitucional.

-. Brindar.los.recursos.necesarios.que.apunten.a.promover.la.presentación.

original.y.creativa.de.estrategias.de.resolución.de.problemas.relacionados.

con.la.necesidad.de.procesar.datos.

44. Capítulo.1. .Los.proyectos.de.cátedra

-. Facilitar.el.intercambio.entre.el.saber.teórico.en.el.ámbito.de.la.seguridad.

industrial.y.la.indagación.de.su.aplicación.concreta.en.las.pequeñas.y.media-

nas

.industrias.

-. Analizar.en.las.clases.teóricas.las.condiciones.socio-económicas-laborales.de.

la.Argentina.como.resultado.de.las.políticas.impuestas.por.los.organismos.

internacionales.de.crédito.y.proponer.la.resolución.de.trabajos.prácticos.que.

supongan.la.toma.de.decisión.y.de.posición.por.parte.de.los.alumnos/as.

como.partes.involucradas.en.la.actividad.económica.

2.5. Contenidos

Los.contenidos.representan.el.eje.central.de.todo.proyecto.', 'chunk 68');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 69, 'didáctico.y.es.aquello.que.primero.se.nos.representa.mental-

m

ente.a.la.hora.de.pensar.la.cátedra..Los.contenidos .son.la.

respuesta.a.una.pregunta.crucial.de.la.práctica.docente:.¿qué.

enseñar?.

La.SELECCIÓN.de .los.contenidos.que.vamos.a.enseñar .suele.

ser,.en.general,.una.de.las.decisiones.más.‘fuertes’.que.toma-

mos

.como.docentes..El.hecho.de.poder.elegir.los.contenidos.a.

enseñar.no.es,.sin.embargo,.algo.que.pueda.hacerse.al.margen.

del.escenario.global.que.representan.el.plan.de.estudios.y.el.

proyecto.curricular.institucional,.cuando.lo.hay..En.este.sentido.

la.primera.prescripción.que.atraviesa.el.trabajo.en.torno.a.los.

contenidos,.está.representada.por.la.presencia.de.los.contenidos.

mínimos.presentes.en.el.plan.de.estudios. .Cuando.me.referí.

al.marco.curricular.y.al.marco.epistemológico,.anteriormente,.

hice.alguna.mención.a.la.‘utilidad’.de.los.contenidos

.mínimos:.

garantizan,.en.cierto.sentido,.la.coherencia.en.un.trayecto.de.

formación.articulando.los.núcleos.centrales.de.cada.disciplina..

Pero.también.es.cierto.que,.a.veces,.los.planes.de.estudios.se.

desactualizan .rápidamente .o.permanecen .inertes.por.mucho.', 'chunk 69');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 70, 'tiempo.sin.incorporar.los.nuevos.contenidos.científicos, .que.

cada.vez.más.rápidamente,.se.producen.en.distintos.ámbitos..De.

modo.que,.para.buscar.el.punto.de.equilibrio,.nada.mejor.que.el.

buen.criterio.y.una.buena.articulación.entre.los.distintos.equipos.

docentes.de.las.diferentes.cátedras,.para.hacer.del.proceso.de.

selección.un.proceso.consensuado..

 45Más.didáctica.(en.la.educación.superior)

Me.pregunto.muchas.veces.qué.es.lo.que.hace.que.yo.elija.

determinados.contenidos.en.mis.cátedras,.desechando.otros..

Creo.que.no.hay.una.única.respuesta.para.una.pregunta.de.ese.

tipo..Pero.también.creo.que.resulta.por.lo.menos.ingenuo.creerle.

a.los.colegas.que.‘defienden’.la.presencia.de.ciertos.conteni-

dos

.en.su.proyecto.de.cátedra.sólo.porque.‘lo.establece.el.plan.

de.estudios’.o.‘por.temor.a.la.supervisión.de.un.inspector’..La.

enraizada.idea.de.la.libertad.de.cátedra.en.la.educación.supe-

r

ior,.da.un.margen.de.necesaria.y.sana.libertad.que.no.puede,.

ni.debe,.desaprovecharse..D

e.todos.modos,.aclaro,.libertad.no.

es.individualismo..

¿Qué.es.lo.que.hace.que.yo.elija.determinados.contenidos.

en.mis.cátedras?.Los.elijo,.entre.otras.tantas.razones.que.yo.', 'chunk 70');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 71, 'mismo.desconozco.y.de.las.que.no.puedo.dar.cuenta,.porque.

creo.que:

a). Pueden.resultar.significativos.(Ausubel,.1983).considerando.

los.tres.aspectos.sustantivos.de.la.significatividad:

-. Significatividad .psicológica: .porque.son.contenidos .a.los.

que.los.alumnos/as.pueden.otorgarle.sentido.en.razón.de.

su.potencialidad .para.ser.incorporados .a.los.esquemas.y.

estructuras . que. definen . las. capacidades . cognitivas . que.

poseen.y,.sobre.todo,.porque.pueden.facilitar.el.estableci-

miento

.de.puentes.cognitivos.y.r

elaciones.sustantivas.entre.

los.saberes.anteriores.disponibles.y.estos.nuevos.contenidos.

que.se.transformarán.en.saberes.apropiados.y.disponibles.

para.comprender.otros.nuevos.contenidos.culturales.

-. Significatividad.lógica:.porque.son.contenidos.necesarios.en.

razón.de.formar.parte.de.la.estructura.esencial.de.una.cien-

cia,

.es.decir,.por.constituir.los.‘nudos.estructurales’.(Bruner,.

1991).de.una.disciplina;.conceptos.claves.que.actúan.como.

articuladores.de.la.estructura.temática.

-. Significatividad.social:.porque.son.contenidos.de.alta.rele-

vancia

.social.relacionados.con.hechos.o.procesos.que.por.el.', 'chunk 71');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 72, 'tiempo.histórico.que.se.está.viviendo.adquieren.importancia.

particular.y/o.mayor.poder.de.transferencia,.es.decir,.posi-

b

les.de.a

plicar.en.diversas.situaciones.de.la.vida.cotidiana.

o.aplicables.a.otras.disciplinas.y/o.temáticas.de.una.misma.

disciplina.

46. Capítulo.1. .Los.proyectos.de.cátedra

b). Tienen.que.ver.con.mis.propios.intereses.ideológicos;

c). Son.el.resultado.de.las.últimas.investigaciones.o.constitu-

yen

.nuevas.categorías.conceptuales.que.circulan.a.través.de.

artículos.o.textos.de.reciente.divulgación.sin.que.ello.sea.la.

receptividad.de.lo.nuevo,.sólo.por.nuevo,.y.la.negación.de.lo.

viejo,.sólo.por.viejo.(Freire,.1969)..

d). Representan.una.necesidad.particular.analizando.el.tipo.de.

demanda.profesional.que.se.requiere.del.egresado/a.o.apor-

t

ando.a.la.diferenciación.del.egresado/a.de.una.institución.

respecto.a.otras,.en.estrecha.relación.con.el.contexto.social.

e.institucional.en.el.que.los.alumnos/as.se.está.

formando.

De.la.mano.de.la.documentación .oficial .proveniente .del.

ámbito.nacional,.y.una.vez.más,.siguiendo.el.modelo.español,.

ha.circulado.en.los.‘90.una.determinada.forma.de.pensar.la.selec-

c', 'chunk 72');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 73, 'ión.de.los.contenidos.a.partir.de.la.institucionalización.(así.apa-

r

ecen.en.los.C.B.C.7.de.la.transformación.educativa.generada.a.

partir.de.la.sanción.de.Ley.Federal.de.Educación).de.una.categoría.

de.clasificación:.los.contenidos.conceptuales,.procedimentales.

y.actitudinales. .Quisiera,.para.quien.desconoce.de.qué.estoy.

hablando,.hacer.una.brevísima.descripción.para.después.explicar.

mi.parecer.al.respecto..

Se.entiende.que.los.contenidos conceptuales .( Coll.y.otros,.

1994).se.refieren.a

l.aprendizaje.de.datos,.hechos.y.conceptos..

Los.datos.y.hechos.habitualmente.se.relacionan.con.el.manejo.

de.cierta.información.que.resulta.necesario.acopiar.en.la.memoria.

como.una.base.de.datos..Pero.para.que.los.datos.y.los.hechos.

cobren.significado,.los.alumnos/as.deben.disponer.de.conceptos.

que.les.permitan.interpretarlos..Un.concepto.no.es.un.elemento.

aislado,.sino.que.forma.parte.de.una.red.de.conceptos.interre-

l

acionada,.de.modo.que.el.aprendizaje.de.los.mismos.requiere.

establecer.una.relación.significativa.entre.conceptos.previamente.

formados..A.su.vez,.convendría.establecer.una.diferencia.entre.

conceptos.estructurantes.y.conceptos.específicos..Los.p', 'chunk 73');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 74, 'rime-

r

os.se.refieren.a.conceptos.muy.abarcativos,.de.un.alto.grado.

7. Los.Contenidos .Básicos .Comunes .son.definidos .como.el.“conjunto .de.

saberes.relevantes.que.integrarán.el.proceso.de.enseñanza.de.todo.el.país.

(…). y.la.matriz.básica.para.un.proyecto.cultural.nacional”.

 47Más.didáctica.(en.la.educación.superior)

de.abstracción.y.que.suelen.aparecer.como.subyacentes.a.un.

determinado.objeto.de.conocimiento. .Los.segundos.son.más.

particulares.y.aparecen.como.subordinados.a.los.estructurantes..

A.diferencia.de.los.datos.y.hechos,.los.conceptos.se.aprenden.

significativamente,.es.decir.por.comprensión.y.relación.

Los.contenidos procedimentales.( Coll.y.otros,.1994).han.de.

entenderse.como.aquellos.objetos.de.enseñanza.que.se.refieren.

a.un.conjunto.de.acciones.ordenadas.y.sistemáticas,.orientadas.

a.la.consecución.de.una.meta..De.modo.que.es.posible.identifi-

car

.en.el.aprendizaje.de.procedimientos.actuaciones.referidas.al.

‘saber.hacer’..No.debe.entenderse.que.estos.procedimientos.se.

refieren.exclusivamente.a.a

cciones.manuales.o.motrices;.tam-

b

ién.están.incluidos.dentro.de.ellos.las.estrategias.o.habilidades.', 'chunk 74');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 75, 'cognitivas.que.suponen.una.acción.ordenada.(como.el.análisis.

o.los.algoritmos.por.ejemplo).

Los.contenidos actitudinales.( Coll.y.otros,.1994).se.refieren.al.

aprendizaje.de.actitudes..Puede.decirse.que.una.actitud.es.una.

predisposición.relativamente.estable.de.la.conducta.en.relación.

con.un.objeto.o.sector.de.la.realidad..La.actitud.implica.un.com-

p

onente.cognitivo.(conocimientos.y.creencias),.un.componente.

afectivo.(sentimientos.y.preferencias).y.un.componente.conduc-

tual

.(acciones.manifiestas).

En.épocas.más.contemporáneas .y.de.la.mano.del.cambio.

en.las.políticas.educativas.de.los.años.2

000,.los.C.B.C..pare-

cen

.reemplazarse.paulatinamente.por.los.N.A.P .8.y.oficialmente.

comienza.a.desaparecer .la.clasificación .de.los.contenidos .en.

conceptuales,.procedimentales.y.actitudinales..

Tengo.una.natural.resistencia .a.las.clasificaciones .(estoy.

seguro.que.es.consecuencia.de.la.exacerbada.manía.clasificato-

ria

.que.sufrí.con.el.modelo.tecnológico.durante.mi.formación.de.

grado)..Pero.no.veo.mayores.inconvenientes.que.el.peligro.de.la.

8. NAP.se.refiere.a.los.Núcleos.de.Aprendizajes.Prioritarios.aprobados.por.el.', 'chunk 75');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 76, 'Consejo.Federal.de.Cultura.y.Educación.para.todo.el.país.durante.la.gestión.

del.ministro.Daniel.Filmus..En.la.documentación.oficial.se.los.define.como.

“un.conjunto.de.saberes.que.deben.formar.parte.de.la.educación.de.todos.

los.niños.y.las.niñas,.tanto.por.su.significación.subjetiva.y.social.como.por.

su.potencialidad.para.construir,.en.un.proceso.de.mediano.plazo,.una.base.

común.que.aporte.a.revertir.las.injusticias”.

48. Capítulo.1. .Los.proyectos.de.cátedra

clasificación.misma.ya.que.al.clasificar.se.disocia.una.totalidad.

indisociable.como.son.los.saberes.que.enseñamos.

En.verdad,.si.me.dan.a.elegir,.prefiero.que.cada.equipo.docente.

muestre.la.selección.de.contenidos.realizada.como.mejor.pueda.

comunicarla.(a.sí.mismo.y.a.los.otros.actores.institucionales.

involucrados). .Y.no.hay.que.olvidar.que.de.eso.se.trata:.los.

escribo .en.el.proyecto .de.cátedra .para.comunicarlos .y.para.

comunicármelos.

S

i.la.selección.de.los.contenidos.es.una.de.las.decisiones.

‘fuertes’.que.tomamos.como.docentes,.también.hay.otro.tipo.de.

decisiones.involucradas.en.nuestras.prácticas.en.torno.al.trabajo.

con.los

.contenidos..Tal.es.el.caso.de.la.decisión.respecto.al.tipo.', 'chunk 76');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 77, 'de.ORGANIZACIÓN.EPISTEMOLÓGICA. de.los.contenidos..

Por.lo.general,.la.articulación.disciplinar.que.se.presenta.en.

el.plan.de.estudios.ya.define.un.criterio.de.organización..Así,.

por.ejemplo,.la.presencia.de.las.Ciencias.Sociales.dentro.de.la.

estructura.curricular.de.la.educación.básica.o.la.perspectiva.filo-

s

ófico-pedagógico-didáctica .en.los.profesorados.de.formación.

docente.en.la.Pcia..de.Bs..As..(1999),.determinan.la.presencia.de.

un.agrupamiento.que.involucra.una.interacción.entre.disciplinas,.

interacción.que.en.las.prácticas.de.enseñanza.hay.que.resolver.

de.algún.modo.

En.un.recorrido.rápido,.entr

e.las.formas.de.organización.más.

utilizadas.pueden.enumerarse:

-. Organización.intradisciplinaria: .responde.a.una.organiza-

c

ión.en.la.cual.una.disciplina,.constituye.el.eje.del.trabajo.

en.el.aula.sin.vínculos.de.ninguna.índole.entre.ésta.y.otras,.

recorriéndose.un.camino.de.profundización.creciente.de.los.

contenidos.propios.de.esta.disciplina.

-. Organización.multidisciplinaria:.supone.el.vínculo.entre.dos.

o.más.disciplinas.sin.que.ninguna.de.ellas.pierda.su.identi-

dad

.específica..El.ámbito.de.la.interacción.se.da.a.partir.de.', 'chunk 77');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 78, 'la.formulación.de.un.problema.(en.la.medida.de.lo.posible.

extraído.de.la.vida.real).para.cuya.resolución.se.requiere.de

.la.

intervención.de.dos.o.más.disciplinas.que.se.ocupan.simul-

táneamente

.de.la.resolución.del.mismo..Cuando.el.plan.de.

estudios.ha.definido.una.organización.básicamente.intradis-

c

iplinar,.la.posibilidad.de.la.organización.multidisciplinaria.es.

 49Más.didáctica.(en.la.educación.superior)

posible.sólo.a.partir.de.acuerdos.y.trabajos.mancomunados.

entre.dos.o.más.docentes.o.por.la.conformación.de.equipos.

de.cátedra.en.los.que.participen.profesionales.con.titulaciones.

de.grado.o.posgrado.pertenecientes.a.distintos.campos.del.

saber.

-

. Organización.interdisciplinaria:.implica.un.marco.general.en.

el.que.cada.una.de.las.disciplinas.en.contacto.pierde.sus.pro-

pias

.fronteras,.confluyendo.en.una.integración.tal.que.se.ven.

modificadas.las.terminologías.específicas.de.cada.una.de.ellas,.

sus.metodologías.de.estudio/investigación,.sus.conceptos,.

etc..“La.enseñanza.basada.en.la.interdisciplinariedad.tiene.un.

gran.poder.estructurante.ya.que.los.conceptos,.marcos.teó-

ricos,

.pr

ocedimientos,.etc..a.los.que.se.enfrenta.el.alumnado.', 'chunk 78');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 79, 'se.encuentran.organizados.en.torno.a.redes.más.globales,.a.

estructuras.conceptuales.y.metodológicas.compartidas.por.

varias.disciplinas..Además.tiene.la.ventaja.de.que.después.

incluso.es.más.fácil.realizar.transferencias.de.los.aprendizajes.

así.adquiridos.a.otros.campos.disciplinares.más.tradicionales”.

(Torres.Santomé,.1994)..La.organización.interdisciplinaria.de.

las.Ciencias.Sociales,.por.ejemplo,.llevaría.a.que.los.alumnos/

as.trabajaran.contenidos.de.la.realidad.social.sin.identificarse.

claramente.cuándo.el.enfoque.es.estrictamente .histórico,.

cuándo.es.político.o.cuándo.es.geográfico.

A.la.vez.que.tomamos.decisiones.respecto.a.la.organización.

epistemológica.l

o.hacemos.con.la.ORGANIZACIÓN.DIDÁCTICA.

de

.los.contenidos..La.forma.más.habitual.consiste.en.el.agrupa-

miento

.por.unidades.didácticas..

Una.unidad.consiste.en.una.agrupación.coherente.e.interre-

l

acionada.de.contenidos.en.torno.a.una.idea-eje..Cada.unidad.

resulta.ser.una.totalidad .temática .en.la.que,.los.conceptos,.

principios.o.teorías.involucradas.tienen.relación.entre.sí..En.la.

práctica, .dos.cosas.convendría .tener.en.cuenta:.por.un.lado.', 'chunk 79');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 80, 'que.las.unidades.no.sean.demasiado.extensas.y.por.otro,.que.

las.unidades.permitan.una.correlación.natural.entre.los.temas.

evitando.que.aparezcan.como.partes.inconexas.y.encerradas.en.

sí.mismas..

Dentro.del.p

royecto.de.cátedra,.junto.a.cada.unidad.se.puede.

especificar.la.bibliografía.obligatoria.(suele.ser.esto.mucho.más.

50. Capítulo.1. .Los.proyectos.de.cátedra

orientador.para.los.alumnos/as).o.ésta.podría.aparecer.en.un.

apartado.final.

Junto . al. proceso . de. organización, . tomamos . decisiones.

respecto.a.la.SECUENCIACIÓN.de.los.contenidos,.es.decir,.al.

ordenamiento.que.les.daremos,.de.lo.cual.resulta.una.secuencia.

en.la.que.se.identifica.qué.se.enseñará.primero,.qué.después.y.

así.cada.contenido..En.este.proceso.de.secuenciación.intervie-

n

en.cuestiones.de.tiempo.e.importancia:.solemos.realizar.una.

primera.apreciación.acerca.de.qué.tiempo-clase.destinaremos.a.

cada.contenido.de.acuerdo.a.su.relevancia..

Miguel.A..Zabalza.(1997).presenta.las.posibles.secuencias.

como.“lineales”.o.“complejas”..Dentro.de.las.lineales,.utiliza.

como.c

ategorías,.la.importancia.y.el.tiempo.dado.a.un.contenido..', 'chunk 80');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 81, 'La.misma.importancia.otorgada.a.los.contenidos.constituye.una.

secuencia.homogénea,.mientras.que.la.presencia.de.contenidos.

de.mayor.y.menor.importancia,.una.secuencia.heterogénea..A.su.

vez,.el.mismo.tiempo.de.desarrollo.otorgado.a.todos.los.conte-

nidos

.constituye.una.secuencia.equidistante,.mientras.que.uni-

d

ades.que.duran.más.unas.que.otras,.constituyen.una.secuencia.

no.equidistante..La.combinación.de.estas.posibilidades.da.lugar,.

según.el.autor,.a.las.siguientes.secuencias:

-. Secuencia.lineal.homogénea.y.equidistante:.a.todos.los.con-

t

enidos.o.unidades.se.les.otorga.la.misma.importancia .y.

el.mismo.tiempo

.de.desarrollo.(por.ejemplo,.por.considerar.

igualmente.relevantes.a.las.cuatro.unidades.de.una.unidad.

curricular,.se.destinan.dos.meses.de.desarrollo.a.cada.una.de.

ellas).

-

. Secuencia.lineal.homogénea.y.no.equidistante:.a.pesar.de.ser.

considerados.todos.los.contenidos.de.igual.importancia,.el.

diferente.tiempo.que.se.le.otorga.a.cada.uno.de.ellos.puede.

deberse.a.la.complejidad.de.los.conceptos.involucrados,.a.la.

ausencia.de.saberes.previos.al.respecto,.etc..

-. Secuencia.lineal.heterogénea.y.equidistante:.los.contenidos.', 'chunk 81');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 82, 'son.diferentes.en.cuanto.a.la.importancia.que.tienen,.pero.a.

pesar.de.ello,.todos.reciben.el.mismo

.tiempo.de.desarrollo..

La.diferencia.en.su.importancia.se.marca.por.utilizarse,.en.

aquellos.más.relevantes,.más.medios.y.recursos.o.pautarse.

 51Más.didáctica.(en.la.educación.superior)

trabajos.prácticos,.trabajos.de.campo,.etc.,.que.consumen.

más.tiempo.extra-áulico.

-. Secuencia.lineal.heterogénea.y.no.equidistante:.se.van.combi-

n

ando.contenidos.de.mayor.y.menor.importancia.y.duraciones.

diferentes,.ya.sea.en.función.de.esa.relevancia.o.en.función.

de.necesidades.de.repaso,.profundización,.etc.

Entre.las.secuencias.complejas.(aquellas.en.las.cuales.no.se.

sigue.un.desarrollo.en.el.que.de.un.tema.se.pasa.a.otro.sin.que.el.

primero.sea.retomado.o.recapitulado.en.una.nueva.oportunidad).

pueden.enumerarse:

-. Secuencia.compleja.con.retroactividad:.es.una.ordenación.en.

la.que.se.prevén.saltos.hacia.delante.o.saltos.hacia.atrás,.

s

obre.

todo.en.el.sentido.de.ir.aclarando.qué.los.contenidos.que.

se.están.desarrollando.en.una.unidad.resultan.de.aplicación.

en.otra.que.se.desarrollará.más.adelante,.o.la.vuelta.a.rever.', 'chunk 82');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 83, 'contenidos.ya.desarrollados.en.unidades.anteriores.a.fin.de.

garantizar.un.mejor.aprovechamiento.de.los.contenidos.que.

se.están.desarrollando.en.un.determinado.momento.

-. Secuencia .compleja .convergente: .el.mismo.contenido .se.

toma.desde.distintos.puntos.de.vista.o.bien.se.lo.aborda.

desde.distintos.planos.de.análisis..Esta.forma.de.considerar.

la.entrada.a.un.mismo.contenido.desde.distintos.puntos.de.

partida.genera.la.necesidad.de.introducir.nuevos

.conceptos.

o.procedimientos.y.por.ello.cada.plano.de.análisis.o.punto.

de.vista.se.convierte.a.su.vez.en.una.unidad.diferente.

-. Secuencia .compleja .con.alternativas: .en.un.determinado.

momento.del.año.al.pasar.de.una.unidad.de.contenidos.a.

otra,.aparece.la.posibilidad.de.que.los.alumnos/as.opten.por.

abordar.temáticas.diversas.cada.uno.de.ellos.(o.por.grupos).

relacionados.con.el.nudo.central.de.dicha.unidad;.el.abordar.

temáticas.diversas.no.supone.que.un.grupo.deba.‘estudiar’.

todas.las.temáticas.consideradas.por.los.otros.grupos.sino.

que.sólo.profundizarán.aquella.alternativa.por.la.que.han.

optado.

F

inalmente,.t

ras.un.proceso.de.complejas.decisiones,.explici-

tamos', 'chunk 83');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 84, '.en.el.proyecto.de.cátedra.la.PRESENTACIÓN.de.los.con-

52. Capítulo.1. .Los.proyectos.de.cátedra

tenidos..La.presentación.puede.realizarse.a.dos.niveles:.a.través.

de.una.visión.sintética.y.a.través.de.una.visión.analítica.

En.la.visión sintética,.c on.algún.tipo.de.representación.gráfica,.

al.estilo.de.los.mapas.o.redes.conceptuales.o.los.cuadros.sinóp-

ticos

.pueden.mostrarse.las.relaciones.entre.los.contenidos.que.

resultan.ser.los.más.relevantes.(en.concordancia.con.los.núcleos.

centrales.explicitados.en.el.marco.referencial).

Los.mapas.y.redes.conceptuales.están.formados.por.nodos.

y.líneas.de.unión.entre.los.nodos..Tal.como.lo.expresa.Lydia.

Galovsky.Kurman.(1996),.los.nodos.representan.los.conceptos.

o.atributos.específicos.de.un.tema.o.d

isciplina.y.se.muestran.

enmarcados.en.alguna.figura.geométrica..Las.líneas.de.unión.

entre.los.nodos.son.flechas.que.indican.el.sentido.direccional.de.

la.lectura.y.sobre.las.cuales.se.escribe.una.leyenda.que.aclara.el.

significado.de.la.relación.que.existe.entre.dos.nodos.(por.ejem-

p

lo:.‘se.clasifica.en’,.‘son.ejemplos.de’,.‘utiliza’,.‘da.por.resul-

tado’,', 'chunk 84');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 85, '.‘están.en’,.etc.),.de.modo.que.se.establece.una.cadena.de.

conceptos.en.una.oración.nuclear.con.sentido..

Un.mapa,.tal.como.lo.presenta.Antonio.Notoria.(1994),.se.

diferencia.de.una.red.en.razón.de.que.el.primero.está.constituido.

por.conceptos.j

erárquicamente.planteados.y.cuya.lectura.sólo.

puede.hacerse.de.arriba.hacia.abajo,.es.decir.desde.conceptos.

generales.hacia.conceptos.particulares..

Pero.ambos,.redes.y.mapas,.no.son.más.que.herramientas.

gráficas.que.intentan.mostrar.la.concepción.global.e.interrela-

c

ionada.de.los.contenidos.de.una.unidad.curricular..Resulta.poco.

relevante.si.la.red.o.el.mapa.responden.a.la.ortodoxia.propuesta.

por.los.autores.para.su.construcción.

En.la.visión analítica.los .contenidos.se.presentan.agrupados.

en.unidades.y.desagregando.temas.y.subtemas.de.cada.unidad..

En.este.sentido,.es.preferible.utilizar.algún.tipo.de.codificación.

unificada.entre.el.cuerpo.docente,.ya.que.e

l.criterio.que.se.adopte.

estará.comunicando.al.lector.(sobre.todo.a.los.alumnos/as).un.

sistema.de.relevancia.otorgado.a.los.contenidos.

Así,.el.trabajo.con.los.contenidos.supone.en.nuestra.práctica,.', 'chunk 85');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 86, 'una.serie.de.decisiones.que,.en.parte,.ya.han.sido.anticipadas.en.

el.marco.referencial..

 53Más.didáctica.(en.la.educación.superior)

C

O

N

T

E

N

I

D

O

S

SELECCIÓN Elección

Intradisciplinar

Or

ganización.

Epistemológica

Agrupamiento

.

disciplinar Multidisciplinar

ORGANIZACIÓN Interdisciplinar

Or

ganización.

Didáctica

Agrupamiento

.

didáctico

Unidades

.

didácticas

Lineal

SECUENCIACIÓN Ordenamiento

Complejo

V

isión.analítica

PRESENTACIÓN Comunicación

V

isión.sintética

En.un.seminario.en.el.que.tomé.el.tema.de.los.proyectos.de.

cátedra,.un.colega.me.pidió.que.le.ayudara.a.transformar.sus.

contenidos.analíticos.en.una.visión.sintética..Sin.omitir.opinión.

acerca.de.los.contenidos.en.sí,.sino.sólo.tratando.de.organizar.

en.una.red.de.relaciones.los.que.él.había.seleccionado,.esto.es.

lo.que.logramos.armar.como.visión.sintética.de.su.Taller.sobre.

“Grupo.y.dinámicas.de.grupos”..

54. Capítulo.1. .Los.proyectos.de.cátedra

CONTENIDOS:.VISIÓN.ANALÍTICA

GRUPOS

pueden.ser

primarios

secundarios

manifiestan

Características.propias

se.pueden.

analizar

con

.

campos.de

fuerzas.y.

tensiones

hacen.a.la cohesión

de.

inclusión Pertenencia', 'chunk 86');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 87, 'evidencia.la.

relación.entre

el.grupo.y.

el.sujeto.

comportamientos.

típicosroles.y.

estatusEstructura

v

a

r

i

a

b

l

e

de

organización

funcionamiento

de

Interacción

se.evidencia. prácticas.grupales

en.los

talleristas entre

liderazgo

a.través.de.

dinámicas.de.grupo

en.un.taller,.en.tanto.el.

coordinador.las.prevé,.son

técnicas.de.dinámica.de.grupoa.veces.presentan

‘vicios’.en.la.práctica.grupal

para.favorecer.la.intimidad el.taller

de.conocimiento de.trabajo

para.favorecer el.trabajo

para.favorecer.la.cohesión

de.mantenimiento.

de.la.vida.del.grupo

de

en.las

útiles.para.

aplicar.en

ellos

La.visión.analítica.nos.es.más.conocida..Pero,.aún.así,.qui-

s

iera.mostrar.un.ejemplo.en.el.que.los.contenidos .aparecen.

desagregados,.codificados.numéricamente.y.la.bibliografía.obli-

gatoria

.junto.a.la.unidad:

 55Más.didáctica.(en.la.educación.superior)

CONTENIDOS:.VISIÓN.ANALÍTICA

UNIDAD.Nº.6

Un.caso.de.especial.análisis:.las.prácticas.en.la.formación.docente.inicial,.las.

prácticas.en.la.formación.docente.continua:

1.. Las.prácticas.pedagógicas.en.la.formación.docente

1.1..El.alumno/a.practicante', 'chunk 87');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 88, '1.2..Las.tensiones.que.atraviesan.las.prácticas

1.3..El.docente.de.la.unidad.curricular.‘Prácticas.de.la.Enseñanza’

2.. ¿Reflexionar .sobre.la.propia.práctica?.¿Investigar .las.propias.prácticas?.

¿Analizar.las.propias.prácticas?

3.. El.análisis.didáctico.de.las.prácticas.de.enseñanza

3.1..Los.supuestos.implícitos

3.2..Las.macrodecisiones.y.las.microdecisiones

3.3..Algunas.experiencias.de.análisis.didáctico.de.prácticas

Bibliografía.de.lectura.obligatoria:

EDELSTEIN,.Gloria.(1995):.Imágenes e imaginación. Iniciación a la docencia , .

Bs..As.,.Kapelusz..

——(2000):. “El.análisis.didáctico.de.las.prácticas

.de.la.enseñanza..Una.refe-

r

encia.disciplinar.para.la.reflexión.crítica”,.Revista del IICE ,.N º..17,.Bs..

As.,.Miño.y.Dávila.

HEVÍA,.Ricardo.y.otros.(1990):.T alleres de Educación Democrática, .Programa.

Interdisciplinario.de.Investigación.en.Educación,.Santiago.de.Chile.

PASILLAS,.Miguel.A..y.FURLÁN,.Alfredo.(1988):.“El.docente.investigador .de.su.

propia.práctica”,.Revista Argentina de Educación, .Nº..12,.Año.VII,.Asocia-

ción

.de.Graduados.en.Ciencias.de.la.Educación,.Buenos.Aires.', 'chunk 88');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 89, 'SCHÖN,.Donald.(1987):.La formación de profesionales reflexivos. hacia un nuevo 

diseño de la enseñanza y el aprendizaje en las profesiones,.B arcelona,.Paidós,.

cap..1.

PÉREZ.GÓMEZ,.Ángel.(1993):.La reflexión y experimentación como ejes de la 

formación de profesores, .Universidad.de.Málaga..

2.6. Marco metodológico

Es.casi.una.tontería,.pero.pasé.mucho.tiempo.pensando.el.

nombre.que.iba.a.sugerir.para.este.ítem..

En.algún.momento.lo.llamé.encuadre metodológico..P ero.El 

Pequeño Larousse Ilustrado.t erminó.de.convencerme.de.que.no.

era.una.buena.idea:

56. Capítulo.1. .Los.proyectos.de.cátedra

“encuadrar:.encajar,.ajustar.//.encerrar,.comprender.//.

determinar.los.límites.de.una.cosa”.

Ciertamente.la.idea.del.método.es.todo.lo.contrario..Si.hay.

algo.que.va.a.encerrarme.o.limitarme,.eso.no.puede.ser.objeto.de.

mi.trabajo.en.el.aula..Además,.‘encuadrar’.me.suena.a.poner.en.

cuadra.y.‘cuadra’,.según.mi.pequeño.ayudante,.es.una.formación.

de.la.infantería.en.forma.de.cuadrilátero..Lo.descarté.

En.alguna.otra.época,.me.sumé.a.quienes.daban.por.llamar.

a.esto:.“estrategias.didácticas”..Pero…

“estrategia:.arte.de.dirigir.las.operaciones.militares.//.', 'chunk 89');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 90, 'habilidad.para.dirigir.un.asunto”.

Otra.vez,.un.término.militar.que.se.mete .con.el.didáctico..Ya.

tenemos.suficiente.con.la.intromisión.del.discurso.económico:.

capital.cultural,.eficiencia,.eficacia,.organizaciones…

Creo.que.la.palabra.método.no .puede.dejar.de.estar.porque.

así.fue.como.Comenio.lo.denomina.en.su.Didáctica Magna, .al.

fin.y.al.cabo.la.piedra.fundacional.del.campo,.preocupado.por.

indicar.el.tipo.de.comportamiento.que.el.verdadero.maestro.debe.

asumir.ante.sus.discípulos.

Gloria.Edelstein.(1996).en.la.línea.de.análisis.del.propio.Ángel.

Díaz.Barriga.(1985).y.de.Alfredo.Forlán.(1986),.entre.otros,.afirma.

que.es.el.propio.docente.quien.construye.su.propuesta.de.tra-

b

ajo,.de.allí.que.retome,.tal.c

omo.ella.lo.afirma,.‘tentativamente’.

la.categoría.de construcción metodológica..D os.cuestiones.resul-

t

an.importantes.para.la.consideración.del.método:.no.podrán.

obviarse.ni.las.características.específicas.del.contenido,.ni.las.

de.los.sujetos.(reales.y.concretos).que.aprenden..De.allí.que.el.

método.‘exija’.ser.una.construcción.para.cada.situación.didáctica.

en.particular,.desechando.la.posibilidad.de.pensar.en.un.modelo.', 'chunk 90');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 91, 'único.y.generalizable,.en.‘el’.método..

Coincido .plenamente .con.el.planteo .de.Edelstein, .pero,.

por.un.lado.considero.a.la.construcción .metodológica .como.

una.decisión.del.ámbito.de.la.práctica.misma.y.prefiero.el.uso.

del.término.marco metodológico .p ara.una.decisión.d el.ámbito.

del.diseño..Por.otro,.evidentemente .en.un.exceso.semántico.

tozudo.y.quisquilloso,.pero.que.no.puedo.evitar,.le.temo.a.la.

palabra.‘construcción’.por.la.deformación.monstruosa.que.ha.

 57Más.didáctica.(en.la.educación.superior)

significado .en.las.prácticas.docentes.el.trabajo.desde.y.en.el.

constructivismo..(¿Cómo.haremos.para.volver.a.la.fuente.con-

ceptual

.de.una.teorización.sobre.el.aprendizaje.que.tan.mal.ha.

sido.interpretada,.en.general,.en.las.aulas?).

A.ver.con.el.Larousse:

“marco:.cerco.que.rodea.algunas.cosas”.

Creo.que.estoy.cerca.y.por.ahora.también.yo,.provisoria-

mente,

.adoptaré.esta.categoría:.la.de.marco.metodológico..Por-

q

ue.veo.en.el.método.aquello.que.rodea.la.situación.didáctica.

de.la.enseñanza.y.el.aprendizaje.

No.es.el.caso.de.este.capítulo.analizar.la.cuestión.del.método.

sino.realizar.alguna.sugerencia.práctica.referida.a.qué.comu-

n', 'chunk 91');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 92, 'icar.al.r

especto.en.el.proyecto.de.cátedra..Pero,.es.necesa-

r

io.por.lo.menos.dejar.en.claro,.cuales.son.las.decisiones.aquí.

involucradas.

Q

uiero . retomar . algunos . cuestionamientos . que. ya. he.

expuesto.en:.¿Qué debatimos hoy en la Didáctica? Las prácticas 

de enseñanza en la educación superior .(2004), .al.referirme.a.las.

situaciones.de.aprendizaje.en.la.educación.superior..

Con.relación.a.la.definición.del.marco.metodológico .con-

s

iderando.las.particularidades .del.grupo.de.alumnos/as .y.los.

enfoques.situacionalistas.y.contextualistas.(Baquero,.2002).del.

aprendizaje:

-

. la.idea.de.los.instrumentos.culturales.como.mediadores.en.

la.situación.de.aprendizaje;

-. la.idea.del.escenario.del.aula,.como.un.particular.escenario.

sociocultural.en.el.cual.los.docentes.intervenimos.de.algún.

modo;.

-

. la.idea.de.participación guiada.( Rogoff,.1997).como.una.situa-

c

ión.interpersonal.de.implicación.en.una.situación.cultural.en.

la.que.docentes.y.alumnos/as.se.implican.y.se.constituyen.

mutuamente.en.situaciones.de.aprendizaje.y.de.enseñanza;.

-. la.falsa.idea.de.afirmar.que.no.hay.otra.forma.de.enseñar.que.', 'chunk 92');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 93, 'no.sea.a.través.de.la.transmisión.oral.(la.exposición,.la.clase.

magistral).y.que.no.hay.otra.forma.de.aprender.que.no.sea.a.

través.de.la.escucha.atenta;

58. Capítulo.1. .Los.proyectos.de.cátedra

-. la.falsa.idea.de.sostener.que.no.hay.otra.forma.de.hacer.

práctica.que.no.sea.previamente.pasando.por.la.teoría.

Con.relación.a.la.definición.del.marco.metodológico.consi-

derando

.las.particularidades.del.contenido:

-. la.idea.que.por.la.naturaleza.epistemológica.que.le.es.propia,.

cada.disciplina.tiene.su.particular.forma.de.producir.nuevos.

conocimientos;.

-. la.idea.que,.a.consecuencia.de.lo.anterior,.las.teorizaciones.de.

una.disciplina.transformadas.en.contenido.escolar,.tienen.su.

particular.forma.de.ser.tratadas.en.el.contexto.del.aula.para.

convertirlas.en.objeto.de.enseñanza;.

-. la.falsa.idea.de.naturalizar.que.en.la.e

ducación.superior.el.

saber.del.experto-docente.cubre.toda.necesidad.didáctica.de.

preparar.situaciones.no.convencionales.para.aprender.

Es.decir,.quiero.enfatizar.que.la.cuestión.del.método.de.ense-

ñ

anza.es.una.cuestión.de.necesaria.decisión..Pero.es.una.decisión.

que.puede.tomarse.siempre.y.cuando.la.preceda.una.reflexión.', 'chunk 93');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 94, 'e.indagación.sobre.las.producciones.referidas.a.propuestas.de.

enseñanza.de.las.disciplinas.(Didácticas.Específicas).y.sobre.el.

contexto.sociocultural.del.aula.

Recién.ahora.podemos.ir.a.lo.nuestro..¿Qué.comunicar.en.el.

proyecto.de.cátedra?.El.marco.metodológico.explicita.la.secuencia.

didáctica.por.la.que.se.ha.optado..Y.al.decir.secuencia.didáctica,.

me

.refiero.a.la.organización.de.la.clase.en.términos.de.‘actividad.

secuenciada.a.proponer’.(estoy.considerando.la.actividad.en.el.

amplio.sentido,.incluyendo.también.la.actividad.cognitiva)..Estoy.

pensando.la.clase.como.un.gran.segmento.en.el.que.puedo.ir.

definiendo.segmentos.parciales,.cada.uno.de.los.cuales.tiene.

una.intencionalidad .propia.(Edelstein,.2000).y.en.los.que,.en.

consecuencia,.se.hace.algo.diferenciado.

Y.vuelvo.otra.vez.sobre.lo.dicho..La.intencionalidad.de.cada.

segmento.que.define.un.hacer.diferenciado,.es.consecuencia.de.

la.especificidad.del.contenido.como.objeto.de.enseñanza.y.de.la.

particularidad.contextual.del.grupo.como.sujeto

.de.aprendizaje..

No.hay.un.modelo.único..

¿Pero.entonces.cada.clase.tiene.su.propio.marco.metodológico?.', 'chunk 94');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 95, 'Considero.que.no,.por.las.mismas.razones.antes.expuestas..Hay.

 59Más.didáctica.(en.la.educación.superior)

dos.invariantes.en.cada.situación-clase:.el.contenido.a.enseñar.

y.el.grupo-clase..

En.general.todos.adoptamos.un.propio.estilo,.y.salvo.raras.

excepciones, .nuestras.clases.de.tal.unidad.curricular .con.tal.

grupo.tienden.a.tener.un.algo.uniforme .que.las.caracteriza..

¿Qué.al.grupo-clase.recién.lo.conocemos.una.vez.que.la.unidad.

curricular.se.pone.en.marcha?.Seguramente,.pero.un.proyecto.de.

cátedra.no.se.confecciona.antes.de.haber.conocido.a.ese.grupo..

Quiero.decir.que.un.proyecto.de.cátedra.se.‘entrega’.después.de.

haber.tenido.un.par.de.clases..Ese.‘algo.uniforme’.que.caracteriza.

la.propuesta.de.enseñanza.en.términos

.de.actividad.en.la.clase.

y.que.supone.un.‘hacer.algo’.según.la.intencionalidad.propia.de.

cada.segmento.de.la.clase,.parece.ser.el.marco.metodológico.

Una.última.referencia.a.los.segmentos.de.la.clase..¿Es.posi-

ble

.pensar.que.haya.algún.común.denominador.en.todas.nues-

tras

.clases,.en.las.que.se.pueda.identificar.a.grandes.rasgos.un.

segmento.inicial,.un.segmento.de.desarrollo.y.un.segmento.de.', 'chunk 95');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 96, 'cierre?.No.creo.que.esto.pueda.ser.‘ley’.pero.entiendo.que.una.

forma.de.organizar.los.segmentos.de.la.clase.es.pensar.en.los.tres.

segmentos.antes.mencionados.como.tres.grandes.momentos,.

como.una

.macroestructura.en.la.que.puedan.diferenciarse.otros.

segmentos.más.pequeños.con.intencionalidades.propias..

Creo . conveniente . que . la. clase . tenga . un. ‘inicio’. con.

intencionalidad.propia,.en.la.que.se.puedan.recuperar.los.saberes.

anteriores .del.grupo.relacionados .con.el.contenido .que.será.

objeto.de.enseñanza.en.esa.clase.en.los.que.pueda.anticiparse,.

antes.de.desarrollarla.analíticamente,.la.temática.de.la.clase.y.

las.grandes.categorías.conceptuales.que.se.trabajarán..Varios.

autores,.entre.ellos.Lauro.De.Oliveira.Lima.(1986),.pensaron.este.

segmento.como.momento sincrético.(por .síncresis,.captación.de.

la.totalidad).de.la.clase.

Resulta.casi.obvio.que.una.clase.tiene.un.gran

.segmento.en.

el.que.la.actividad.cognitiva.fundamental.parece.ser.la.de.analizar.

conceptos..Desde.viejos.textos.hasta.propuestas.un.poco.más.

contemporáneas.se.suele.llamar.a.esto.el.momento analítico.o .

de.desarrollo.de.la.clase..', 'chunk 96');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 97, 'Desde.diferentes.teorías.de.aprendizaje.se.enfatizó.un.sentido.

u.otro.para.el.tercer.momento.de.la.clase..La.‘fijación’,.entendida.

como.aplicación.de.un.aprendizaje.en.un.nuevo.contexto.o.como.

60. Capítulo.1. .Los.proyectos.de.cátedra

simple.repetición.de.una.ejercitación.ya.realizada.fue.durante.la.

vigencia.del.modelo.conductista,.la.finalización.obligada.de.una.

clase..Con.afán.gestáltico,.para.otros,.la.clase.debía.tener.un.

cierre.que.recompusiera.la.estructura.total.de.la.clase.(por.la.ley.

de.cierre.de.la.teoría.de.la.Gestalt)..No.creo.que.necesariamente.

la.clase.‘deba’.tener.un.momento sintético .f inal.formalizado,.

pues.a.medida.que.se.van.haciendo.análisis.también.la.actividad.

cognitiva.de.los.sujetos.va.produciendo.síntesis.parciales.que.se.

van.integrando.en.síntesis.cada.vez.más.abarcativas.y.totaliza-

d

oras.(Edelstein.y.Rodríguez,.1974),.pero.tampoco.me.p

arece.

que.favorezca.al.buen.aprendizaje.el.que.la.actividad.quede.a.

medias.y/o.inconclusa.porque.el.tiempo.de.la.clase.se.acabó.y.

sólo.referenciemos:.“seguimos.en.la.próxima”.

Finalmente,.dos.últimas.cuestiones..Una.referida.a.que,.comu-

n', 'chunk 97');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 98, 'icar.en.el.marco.metodológico.los.recursos.didácticos.(entendi-

d

os.como.ciertos.soportes.materiales.para.la.enseñanza.como.lo.

son.tanto.el.pizarrón.como.una.guía.de.estudio).no.creo.que.sea.

necesario..La.otra.a.que.por.la.particularidad.de.la.organización.

universitaria.–las.clases.divididas.en.teóricas.y.prácticas–.quizás.

haya.que.pensar.que.en.el.marco.metodológico.puede.diferen-

c

iarse.también.el.t

ipo.de.trabajo.propuesto.para.la.una.(la.clase.

teórica).y.para.la.otra.(la.clase.de.trabajos.prácticos)..

Si.me.pidieran.hacer.alguna.referencia.al.estilo.en.el.que.se.

muestra.el.marco.metodológico,.por.supuesto.que.desecho.cual-

quier

.esquema.encolumnado.en.el.que.se.correspondan.mecá-

nicamente

.la.actividad.fragmentada.de.docentes.y.alumnos/as,.

tal.como:

Actividad del docente Actividad de los alumnos/as

P

resentación.explicativa.del.marco.

teórico Interr ogación.sobre.dudas

Propuesta.de.trabajo.en.grupos Resolución.del.protocolo.de.trabajos.

prácticos.Nº.1

Por.el.contrario,.prefiero.el.estilo.narrativo..Como.es.habitual.

ya,.aquí.presento.un.ejemplo:

 61Más.didáctica.(en.la.educación.superior)

MARCO.METODOLÓGICO', 'chunk 98');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 99, 'En.las.clases.teóricas,.se.comenzará.con.una.dinámica.grupal.corta.a.partir.de.

la.cual.se.recuperará.el.contenido.trabajado.en.la.clase.anterior.a.los.efectos.

de.articular.la.presentación.secuenciada.del.contenido.y.facilitar.una.primera.

incursión.global.en.el.contenido.de.la.clase.del.día..Posteriormente,.se.intro-

d

ucirán.las.temáticas.nuevas.a.través.de.una.presentación.oral.que.realizará.

el.profesor/a.titular,.apoyando.la.misma.con.la.construcción.en.el.pizarrón.de.

esquemas.conceptuales.que.permitan.ir.visualizando.los.conceptos.centrales.

relacionados..Una.vez.que.el.tema.esté.presentado.y.sólo.como.escenario.con-

ceptual

.de.trabajo,

.se.trabajará.con.problemáticas.reales.extraídas.de.organiza-

c

iones.industriales.ante.las.que.los.alumnos/as,.operando.en.grupos.reducidos,.

deberán.hipotetizar.soluciones.y/o.analizar.variables.constitutivas.haciendo.

uso.del.marco.brindado.en.la.presentación.inicial.y.de.las.lecturas.bibliográficas.

que.deberán.haber.realizado.previamente..La.clase.finalizará.con.la.puesta.en.

común.del.trabajo.grupal.y,.si.fuera.necesario,.una.nueva.intervención.teórica.', 'chunk 99');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 100, 'del.docente.en.la.que.se.tomarán.en.particular.las.dudas.y/o.errores.concep-

tuales

.que.se.hayan.evidenciado.en.el.trabajo.previo.

En.las.clases.de.trabajos.prácticos, .los.ayudantes.coordinados .por.el.J.T.P .,.

brindarán.guías.de.t

rabajo.en.las.que.prevalecerán.situaciones.problemáticas.

del.tipo.‘análisis.de.casos’.las.que.serán.resueltas.por.los.alumnos/as.haciendo.

uso.del.marco.brindado.en.el.teórico..Cada.guía.de.trabajo.será.entregada.

individualmente.por.los.alumnos/as.a.la.semana.siguiente.de.su.tratamiento.

en.clase,.a.fin.de.ser.supervisada.

2.7. Cronograma

El.cronograma.tiene.que.ver.con.una.distribución.en.el.tiempo.

de.los.contenidos.previstos.en.las.unidades.didácticas.así.como.

cierta.aproximación.previsible.al.tiempo.en.que.se.efectuarán.las.

evaluaciones.parciales.y/o.la.entrega.de.trabajos.prácticos.

Una.vez.más.estoy.pensando.en.qué.comunicar.al.respecto..

Creo.que.s

on.los.alumnos/as.quienes.más.necesitan.saber.cómo.

está.previsto.el.desarrollo.de.la.cátedra,.sobre.todo,.porque.los.

involucra.en.cuanto.a.los.tiempos.que.se.les.demandarán.para.

cierto.tipo.de.producciones.o.para.sistematizar.su.estudio..Por.', 'chunk 100');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 101, 'ello,.no.veo.que.tenga.sentido.un.enunciado.muy.general..¿A.

quién.le.sirve.que.en.el.proyecto.de.cátedra.se.explicite.algo.así.

como?:

Unidad

.Nº1:.abril

Unidad.Nº2:.mayo

Unidad.Nº3:.junio-julio

62. Capítulo.1. .Los.proyectos.de.cátedra

Creo.que.un.cronograma.bien.detallado.puede.servirle.a.los.

alumnos/as.para:

-. conocer.sus.obligaciones.académicas.a.lo.largo.del.desarrollo.

de.la.cátedra.en.el.cuatrimestre.o.el.año,.según.sea.el.caso;

-. poder.anticipar.las.lecturas.bibliográficas.que.se.trabajarán.

en.cada.clase;

-. poder.distribuir.mejor.su.tiempo.de.preparación.para.la.entrega.

de.trabajos;

-. poder.distribuir.mejor.su.tiempo.de.estudio.para.evaluaciones.

parciales;

-

. enterarse.del.contenido.y.los.textos.trabajados.en.caso.de.

ausencia.a.la.clase;

-. conocer.la.correspondencia.entre.los.contenidos.desagregados.

en.las.unidades.didácticas.y.los.textos.de.lectura.obligatoria.

que.toman.

en.su.desarrollo.dichos.contenidos..

He.usado.últimamente .un.esquema.como.el.que.a.conti-

n

uación.muestro.y.ha.sido.bien.recibido.por.los.alumnos/as..

No.digo.que.un.cronograma.‘deba’.ser.así,.sólo.que.si.estamos.', 'chunk 101');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 102, 'comunicando,.debe.servir.a.tal.efecto..También.podrá.objetarse.

que.no.siempre.puede.preverse.con.tal.grado.de.exactitud..Es.

cierto,.pero.nada.impide.que.las.modificaciones.puedan.comu-

n

icarse.oralmente..De.todos.modos,.insisto.con.el.carácter.de.

sugerencia.u.orientación.práctica.de.este.texto.

A.los.efectos.de.que.sea.comprendido.el.ejemplo,.el.lector.

tendrá.que.imaginar.una.unidad.didáctica.enunciada,.por.ejem-

plo,

.

de.este.modo:

Unidad.Nº.1

1.. xxxxxxxxxx

1.1.. xxxxxxxxxxx

1.2.. xxxxxxxxxxx

2.. xxxxxxxxxx

3.. xxxxxxxxxx

3.1.. xxxxxxxxxxxxx

3.2.. etc.

 63Más.didáctica.(en.la.educación.superior)

CRONOGRAMA

Semana Contenido T exto de trabajo en clase 

3ª

.Agosto. Presentación –

4ª

.Agosto. Unidad.1:.puntos.1.y.2 Davini.(cap..1).-.Feldfeber

1ª.Septiembre. Unidad.1:.punto.3.1. Apple .(cap.8).-.Giroux.(cap.2).

2ª.Septiembre. Unidad.1:.punto.3.2 Perrenoud.-.Jackson.(cap.4)

3ª.Septiembre. Unidad.2:.puntos.1..y.2.1.-.2.2 De.Alba.-.McEwan.(int.).

-.Torres.(cap.8).

4ª.Septiembre. Unidad.2:.punto.2.3 Alliaud.-.Achilli.-.Sandoval.

Flores.

1ª.Octubre. Evaluación.de.la.enseñanza.

Unidad.2:.puntos.2.4..y.2.5 Pérez.Gómez.-.Birgin', 'chunk 102');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 103, '2ª.Octubre. 1er.parcial.presencial –

3ª

.Octubre. Unidad.3:.punto.1 Davini.(cap.4).-.Edelstein-

4ª.Octubre. Unidad.3:.puntos.2.1.y.2.2. Barco.-.Edelstein.(cap.3)

1ª.Noviembre. Unidad.3:.punto.2.3.

y.2.4. Messina.-.Ball.(cap..5)

2ª.Noviembre. Unidad.3:.punto.3 Freire.-.Campos.(cap..7)

3ª.Noviembre. Unidad.4:.punto.1 Davini.(cap..3).-.Rockwell.

4ª.Noviembre. Unidad.4:.puntos.2.y.3 Edelstein.(cap..2).-.Porlán

1ª.Diciembre.

Entrega.2º.parcial.

domiciliario..Evaluación.de.la.

enseñanza

–

2ª

.Diciembre. Primer.llamado.examen.final –

3ª

.Diciembre. Segundo.llamado.examen.

final –

En

.el.presente.cronograma.la.cita.del.texto.sin.especificar.capítulo,.corresponde.

a.la.lectura.completa.del.artículo.o.libro.

2.8. Evaluación

A.fin.de.comprender.mejor.la.idea.de.este.apartado.del.pro-

yecto

.de.cátedra,.habrá.que.comenzar.por.no.restringir.el.con-

c

epto.de.evaluación.al.universo.de.‘evaluar.a.los.alumnos/as’..Se.

podría.decir,.en.todo.caso,.que.éste.será.uno.de.los.aspectos.de.

dicho.proceso,.pero.que.también,.en.este.sentido.amplio,.se.debe.

incluir.como.objeto.de.evaluación.la.propuesta.de.enseñanza..

64. Capítulo.1. .Los.proyectos.de.cátedra', 'chunk 103');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 104, 'Aclarado . este . primer . supuesto, . se. puede . entonces.

conceptualizar.los.términos.involucrados..Si.bien.más.adelante.

desarrollaré.especialmente.un.capítulo.referido.a.la.evaluación,.

me.resulta.necesario.anticipar.aquí.un.acercamiento.a.la.defini-

c

ión.que.el.lector.volverá.a.encontrar.luego.en.dicho.capítulo..

Defino.a.la.evaluación.didáctica.como.un.proceso.que,.a.partir.

del.conocimiento.y.comprensión.de.cierta.información,.permite,.

a.partir.de.una.actitud.dialógica,.emitir.un.juicio.de.valor.acerca.

de.las.prácticas.de.enseñanza.y./o.las.prácticas.de.aprendizaje.en.

un.contexto.sociohistórico.determinado.en.el.cual.intervienen.

con.particularidad.significante.lo.social.amplio,.la

.institución,.el.

objeto.de.conocimiento,.el.grupo.de.alumnos/as.y.el.docente.y.

que.posibilita.tanto.tomar.decisiones.referidas.a.las.prácticas.de.

referencia.como.exige.comunicar.a.docentes.y/o.alumnos/as.–por.

medio.de.enunciados.argumentativos–.el.juicio.de.valor.emitido.

y.las.orientaciones.que,.derivadas.de.éste,.resulten.necesarias.

para.la.mejora.de.la.práctica.

Desde.esta.concepción,.el.concepto.de.evaluación.es.mucho.', 'chunk 104');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 105, 'más.abarcativo.que.lo.que.habitualmente.se.relaciona.con.par-

c

iales,.finales.y.notas,.ya.que,.tal.como.expresara.antes,.también.

la.enseñanza.es.objeto.de.evaluación.

Dentro.de.este.proceso.denominado.‘evaluación’,.aparece.a.su.

vez.e

l.proceso.de.acreditación,.e ntendido.como.el.reconocimiento.

institucional.de.los.aprendizajes.adquiridos.por.los.alumnos/as,.

constatados.a.través.del.uso.de.ciertos.instrumentos.(trabajos.

escritos,.exámenes.orales,.trabajos.prácticos,.etc.).y.comunica-

dos

.a.través.de.una.escala.convencional.conceptual.(Aprobado/

Desaprobado;.MB/B/R/M),.numérica.(1/10).o.alfabética.(A-B-C-

D-E).que.resulta.de.la.consideración.de.ciertos.criterios.que.se.

han.priorizado.para.tomar.la.decisión.al.respecto..

Alguna.aclaración .necesaria .respecto .al.uso.del.término.

criterios de acreditación ..E ntiendo.a.los.‘criterios’.como.aque-

l

las.características .expresadas.como.cualidades.más.o.menos.

específicas.en.relación.con.los.contenidos.de.un.determinado.

área.del.conocimiento.y.q

ue.se.especifican,.en.general,.como.

procedimientos .cognitivos .o.prácticos.que.se.espera.pongan.

en.juego.los.alumnos/as.en.su.proceso.de.apropiación.de.los.', 'chunk 105');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 106, 'contenidos,.como.por.ejemplo,.aplicar.pertinentemente.fórmulas.

preestablecidas.o.relacionar.categorías.conceptuales,.etc..

 65Más.didáctica.(en.la.educación.superior)

Al.referirme.antes.a.las.expectativas .de.logro,.expresé.mi.

desacuerdo.con.la.necesidad.de.su.formulación.y.dije.que,.a.mi.

parecer,.el.eje.de.la.evaluación.podía.colocarse.en.la.relación.

contenidos-método-criterios.de.acreditación.

Quiero,.brevemente,.explayarme.sobre.dicha.cuestión..

En.primer.lugar.la.inclusión.del.método.en .la.relación.conte-

n

ido-método-criterios.de.acreditación.como.eje.de.la.evaluación,.

se.corresponde.con.una.cuestión.ética.y.profesional..La.construc-

c

ión.metodológica.es.la.que.define.el.tipo.de.actividad.que.se.rea-

liza

.en.una.clase..La.propuesta.de.actividad.en.la.clase.es.la.que.

pone.a.los.alumnos/as.en.situación.de

.operar.con.determinados.

procedimientos.cognitivos.o.prácticos..De.modo.que,.sería.casi.

lógico.pensar.que,.el.tipo.de.procedimiento.que.fuera.objeto.de.

trabajo.en.la.clase.desde.la.construcción.metodológica.realizada,.

debería.ser.el.requerido.en.el.momento.de.las.acreditaciones..Si.', 'chunk 106');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 107, 'en.clase.se.trabajó.‘escuchando’.no.resultaría.pertinente.en.el.

momento.de.acreditar.requerir.el.‘análisis.de.un.caso’..Y.aquí.

no.acepto.la.contra.argumentación .referida.a.“que.los.alum-

n

os/as.recién.pueden.hacerlo.después.de.haber.comprendido.

cierto.marco.teórico”..Siempre,.una.conducta.de.ese.tipo,.me.

ha.parecido.una.‘traición’..Tampoco.el.extremo.contrario,.casos

.

en.los.que.la.clase.es.un.lugar.de.complejo.trabajo.cognitivo.y.la.

acreditación.final.es.una.exposición.en.la.que.la.opinión.vaciada.

de.contenido.ocupa.el.lugar.de.la.conceptualización..Esto.no.me.

parece.una.traición,.sino.una.burla.

En.segundo.lugar.la.inclusión.del.contenido.cr eo. que.define.

claramente.en.el.objeto.de.saber.que.debe.ser.apropiado,.las.

categorías.conceptuales.que.resultan.ser.el.eje.estructurante.del.

mismo..Y.en.plural,.categorías conceptuales ,.p orque.analítica-

m

ente.están.desagregadas.en.la.presentación.de.los.contenidos.y.

presentes.en.la.bibliografía.que.resulta.ser.de.lectura.obligatoria..

Y.son.

varias.

Finalmente,.la.inclusión.de.los.criterios de acreditación.cr eo.

que.sin.cerrar.ni.delimitar .en.extremo,.expresan.ciertas.cua-

l', 'chunk 107');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 108, 'idades.que.los.alumnos/as.deben.poner.de.manifiesto.en.su.

trabajo.con.los.contenidos.y.que.pueden.resultar.orientadoras.

tanto.para.los.docentes.(con.relación.a.las.tareas.solicitadas.en.

su.propuesta.de.acreditación).como.para.los.alumnos/as.(con.

relación.a.la.‘manera’.de.estudiar)..

66. Capítulo.1. .Los.proyectos.de.cátedra

Sólo.a.los.efectos.de.poner.sobre.la.mesa.un.ejemplo.sencillo,.

quiero.ejemplificar.esta.relación.de.tres.antes.descripta:

En.el.ítem.de.los.contenidos.se.explicitan.en.distintas.unida-

d

es.‘Estado.y.Educación.y.Práctica.Docente’..En.el.ítem.del.marco.

metodológico.se.menciona.que.se.trabajará.en.pequeños.grupos.

realizando.recapitulaciones.conceptuales.para.incluir.los.nuevos.

contenidos.en.red.con.los.anteriores.analizándolos.desde.dife-

r

entes.perspectivas..En.el.ítem.evaluación.se.explica.como.uno.de.

los.criterios.que.se.requerirá.‘relación.entre.conceptos’..Con.este.

escenario,.una.tarea.solicitada.en.una.instancia.de.acreditación.

que.requiera:.“relacionar.estado,.educación.y.p

ráctica.docente.

desde.una.perspectiva.política.y.una.perspectiva.curricular”.la.

considero.muy.pertinente..El.equipo.docente.viene.trabajando.en.', 'chunk 108');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 109, 'esa.línea,.a.los.alumnos/as.no.les.‘cae’.como.sorpresa.

Hechas.estas.primeras.apreciaciones,.quiero.referirme.a.qué.

se.puede.comunicar.al.respecto.en.el.proyecto.de.cátedra.

Intentaré.mantener.la.lógica.del.desarrollo.al.circunscribir.las.

necesidades.conceptuales.sólo.a.los.efectos.de.la.comunicación.

que.supone.hablar.de.la.evaluación.en.el.proyecto.de.cátedra9.

Tal.lo.dicho,.entiendo.entonces.que.la.evaluación.puede.espe-

ci

ficarse.en.términos.de.evaluación de la enseñanza y evaluación 

del aprendizaje.

2.8.1. Evaluación de la enseñanza

He.conversado.más.de.una.vez.sobre.este.aspecto .con.mis.

colegas..No.he.encontrado.siempre.el.mismo.tipo.de.respuesta..

A.grandes.rasgos.podría.decir.que.mientras.un.grupo.considera.

que.los.alumnos/as.no.están.en.condiciones.de.emitir.juicios.

de.valor.y/o.brindar.información .válida.referida.a.la.actividad.

que.realiza.el.equipo.docente.(y.entonces.‘no.se.debe.hacer’),.

otro.grupo.ve.con.absoluta.naturalidad.el.dar.participación.a.los.

alumnos/as.en.el.momento.de.evaluar.qué,.cómo.y.cuándo.se.

está.enseñando.en.la.cátedra..En.definitiva.prima,.por.sobre.todo.

aquí,.una.cuestión.de.tipo.ideológica..', 'chunk 109');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 110, 'Personalmente.considero.relevante.poder.evaluar.la.ense-

ñ

anza.a.t

iempo,.a.fin.de.redireccionarla.si.no.está.cumpliendo.

9. En.el.capítulo.3.puede.verse.el.desarrollo.ampliado.de.esta.temática..

 67Más.didáctica.(en.la.educación.superior)

con.su.cometido:.el.ser.una.intervención.intencionada.que.posi-

bilite

.las.prácticas.de.aprendizaje..

Hablar.de.la.enseñanza.como.objeto.de.la.evaluación.supone.

poder.emitir.algún.juicio.de.valor.sobre.ella.para.poder.tomar,.a.

tiempo,.las.decisiones.que.sea.necesario.tomar..Estas.decisiones.

tienen.que.ver.aquí.con.la.multiplicidad.de.variables.involucradas.

en.la.práctica.de.enseñar..¿Qué.información.es.necesaria.obtener.

para.poder.tomar.decisiones.a.tiempo.y.redireccionar.la.propuesta.

de.enseñanza.si.fuera.necesario?.Sólo.algunos.ejemplos:

-. si.los.contenidos.presentados.clase.a.clase.se.evidencian.

articulados.entre.sí;.

-. si.los.contenidos.presentados.s

on.posibles.de.ser.significados;

-. si.las.exposiciones.teóricas.ayudar.a.clarificar.los.conceptos;.

-. si.la.propuesta.de.trabajos.prácticos.ayuda.a.vincular.los.con-

tenidos

.con.las.realidades.prácticas.a.las.que.se.refieren;', 'chunk 110');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 111, '-. si.la.organización.de.la.cursada.resulta.pertinente;

-. si.los.miembros.de.la.cátedra.están.funcionando.como.un.ver-

d

adero.equipo.en.el.que.se.complementan.todos.los.docentes.

sin.contradicciones.entre.sí.(me.refiero.a.‘sin.contradicciones’.

en.la.organización.de.la.cursada).

La.evaluación de la enseñanza.hace

 .referencia.a.poder.obte-

n

er.información.con.respecto.a.algunas.de.estas.cuestiones.(y.

todas.aquellas.que.los.docentes.consideren.necesarias) .a.f

in.

de.poder.valorar.–y.corregir.si.fuera.necesario– .la.propuesta.

de.la.cátedra..Evidentemente.las.fuentes.de.información.serán.

el.equipo.docente.de.la.cátedra,.haciendo.su.autocrítica,.y.los.

alumnos/as.

2.8.2. Evaluación de los aprendizajes

Con.la.misma.lógica.con.que.se.evalúa.la.enseñanza.creo.que.

es.necesario.también.evaluar.los.aprendizajes..No.me.refiero.aquí.

a.la.acreditación.propiamente.dicha,.sino.a.los.juicios.de.valor.

que.cada.alumno/a.pueda.dar.respecto.a.qué,.cómo.y.cuándo.

está.aprendiendo.y.a.los.que.el.propio.equipo.docente.pueda.dar.

respecto.a.su.visión.del.escenario-clase.como.situación.d

e.apren-

d

izaje..Considero.imprescindible.sistematizar.estas.prácticas.de.', 'chunk 111');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 112, 'autoevaluación.de.los.alumnos/as.(no.estoy.diciendo.autocalifica-

68. Capítulo.1. .Los.proyectos.de.cátedra

ción).para.generar.mayor.grado.de.compromiso.con.el.propio.estu-

d

io.y.develar.ciertos.obstáculos.que.pueden.estar.‘molestando’.en.

el.proceso.de.aprender.de.cada.alumno/a.como.sujeto.individual.y.

de.la.clase,.como.situación.colectiva.de.aprendizaje.

Pero.por.supuesto.que.el.mayor.grado.de.interés.del.pro-

yecto

.de.cátedra.en.el.rubro.evaluación.para .el.lector.alumno/a.

radica.en.clarificar.las.reglas.de.juego.que.podrán.llegar.a.definir.

la.aprobación.o.no.de.la.unidad.curricular..Es.decir,.para.el.lec-

t

or.alumno/a.importa.y.mucho.el.sistema.de.acreditación..De.

modo.que,.cuanto.más.explícita.esté.la.pr

opuesta.de.la.cátedra,.

mejor..

Cuando.digo.sistema de acreditación ,.u so.deliberadamente.

la.palabra.sistema,.porque.veo.involucrados.una.serie.de.ele-

mentos

.articulados.entre.sí,.interviniendo.en.toda.situación.de.

acreditación.

C

onsidero,.entre.ellos,.como.relevantes.de.ser.comunicados:.

-. si.no.aparecen.en.el.cronograma,.las.fechas.estimadas.de.

los.parciales.(estimadas.porque.puede.decirse.por.ejemplo:.', 'chunk 112');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 113, '“Primera.evaluación.parcial.al.finalizar.la.unidad.Nº.2”);

-. el.formato.que.se.propondrá.para.las.evaluaciones.parciales.

(si.escrito.u.oral,.presencial.o.domiciliario,.individual.o.grupal,.

etc.);

-

. la.nota.de.aprobación.en.cada.caso.y/o.el.‘cuantum’.que.

define.el.‘aprobado’.de.la.

evaluación.parcial;

-. las.posibilidades.(cuántas).y.fechas.estimadas.de.recupera-

torios

.a.evaluaciones.parciales.desaprobadas;

-. si.existe.un.sistema.de.promoción.sin.examen.final.o.si.el.

examen.final.varía.en.su.formato.en.función.de.las.notas.

obtenidas.en.los.parciales;.

-. el.formato.del.examen.final;

-. los.criterios.de.acreditación.

 69Más.didáctica.(en.la.educación.superior)

Veamos.el.ejemplo:

EVALUACIÓN

a). Evaluación.de.la.enseñanza.

. Se

.priorizará.la.búsqueda.de.información.referida.a.los.factores.que.puedan.

incidir.como.relevantes.en.favorecer.u.obstaculizar.el.proceso.de.apren-

dizaje

.de.los.alumnos/as,.fundamentalmente.con.relación.a.la.estructura.

de.la.clase.teórica,.a.la.propuesta.de.trabajos.prácticos.y.a.la.bibliografía.

de.lectura.obligatoria..Dos.veces.a.lo.largo.de.la.cursada,.en.clases.de.tra-

bajos', 'chunk 113');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 114, '.prácticos,.se.dedicará.una.hora.a.dialogar.sistemáticamente.con.el.

grupo.con.respecto.a.dichas.cuestiones.y.a.la.propia.percepción.que.tienen.

respecto.a.sus.procesos.de.aprendizaje,.realizándose.un.registro.escrito.

de

.esta.actividad.para.ser.discutida.en.la.siguiente.reunión.del.equipo.de.

cátedra..Finalizada.la.cursada.se.tomará.una.encuesta.de.opinión.de.tipo.

anónima.

b)

. Evaluación.de.los.aprendizajes

. Al.comienzo.de.la.cursada,.se.dedicará.una.clase.a.diagnosticar.a.través.

de.una.encuesta.cerrada.y.algunas.dinámicas.de.trabajo.grupal.en.qué.

estado.efectivo.se.encuentran.los.saberes.aprendidos.anteriormente.en.

otras.cátedras.correlativas.a.fin.de.poder.seleccionar.con.criterio.de.realidad.

la.propuesta.de.contenidos.que.realizará.esta.cátedra..

. . A.los.efectos.de.la.acreditación,.se.tomarán.dos.pruebas.parciales.

presenciales,.escritas.e.individuales.del.tipo

.de.resolución.de.situaciones.

problemáticas,.la.primera.al.finalizar.la.unidad.Nro..2.y.la.segunda.al.fina-

lizar

.la.unidad.Nro..4.cuya.aprobación.se.hará.obteniendo.4.o.más.puntos..

La.obtención.de.la.nota.se.definirá.por.la.puntuación.que.se.le.asigne.a.', 'chunk 114');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 115, 'cada.criterio.de.acreditación.en.cada.una.de.las.problemáticas.planteadas.

y.que.acompañará.la.propuesta.del.parcial..Habrá.un.recuperatorio.para.

cada.parcial,.que.se.instrumentará.a.los.quince.días.de.tomada.la.prueba..

Cualquiera.fuera.la.nota.obtenida.en.los.parciales,.la.acreditación.final.

será.con.un.examen.oral.e.individual.en

.el.que.los.alumnos/as.deberán.en.

principio.exponer.un.temática.original.cuya.condición.será.que.involucre.

varios.contenidos.de.diferentes.unidades,.para.responder.luego.a.una.serie.

de.problemáticas.que.les.serán.presentadas.en.una.ficha..

Serán.criterios.de.acreditación:

-. lectura.de.la.totalidad.de.la.bibliografía.obligatoria;

-. análisis.desagregado.de.los.conceptos.y.planteos.teóricos.contenidos.en.

los.textos.de.lectura.obligatoria;

-. relación.entre.conceptos;

-. síntesis.de.la.totalidad.conceptual.en.un.marco.teórico.organizado;

-. uso.de.vocabulario.específico;

-. toma.de.decisiones.pertinentes.ante.situaciones.problemáticas.hipotetizadas.

70. Capítulo.1. .Los.proyectos.de.cátedra

2.9. Bibliografía

Existen.varias.‘normas’.acreditadas.para.las.citas.bibliográfi-

cas.', 'chunk 115');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 116, '.Sólo.a.los.efectos.de.enunciar.el.caso.más.sencillo.de.la.cita.

de.un.texto.editado,.he.aquí.algunas.normas.generales:

-. Primero:.el.apellido.(en.mayúsculas).y.a.continuación.los.

nombres.o.el.nombre.de.pila.del.autor.precedidos.por.una.

coma..Igual.caso.si.el.texto.ha.sido.escrito.por.dos.o.tres.

autores..Si.el.número.de.autores.es.mayor.a.tres,.se.utiliza.sólo.

el.primero.y.se.escribe.“et.al”.o.en.castellano.“y.otros”.

-. Segundo:.el.año.de.edición.(entre.paréntesis).y.dos.puntos.

-. Tercero:.el.nombr

e.completo.del.texto.(en.cursiva)..Cuando.

hubiera.subtítulo.se.transcribirá.precedido.por.un.punto.y.

también.en.cursiva..Luego.coma.

-. Cuarto:.el.lugar.de.edición.y.luego.coma.

-. Quinto:.la.editorial.y.luego.coma.

-. Sexto:.(si.se.desea.esta.aclaración).el/los.capítulo/s.que.serán.

de.lectura.obligatoria.

En.un.ejemplo:

MERLO,.Germán.(2006):.Retrato de una actriz. Inés Giorgetti en el teatro argentino, .

Buenos.Aires,.Editorial.Tablas,.capítulo.3.

En.algunos.otros.casos,.en.los.que.la.cita.bibliográfica.no.

corresponde.a.un.libro,.se.siguen.normas.como.éstas:

-. Si.se.cita.un.capítulo.de.un.texto.contenido.en.una.edición.', 'chunk 116');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 117, 'o.compilación.de.varios.autores,.la.cita.se.realiza.así:

. APELLIDO,.Nombre.del.autor,.“Título.del.artículo.o.capítulo”,.

en,.APELLIDO.y.nombre.del.compilador,.Fecha:.Título de la 

obra colectiva.

 (en.cursiva),.Lugar,.Editorial,.Páginas.

Ejemplo:

BERNATENE,.Silvia:.“Diez.años.en.la.cuatro”,.en.BERNATENE,.Silvia.(Comp.),.

(2006):.Búsquedas del lugar en el mundo, .Córdoba,.Yacanto,.pp..60-82.

 71Más.didáctica.(en.la.educación.superior)

-. Si.la.cita.corresponde.a.un.artículo.en.revista,.se.usa.este.

criterio:

. A

PELLIDO,.Nombre.del.autor,.Fecha:.“Título.del.artículo”,.Nom-

bre de la revista,.v olumen.y.número.del.fascículo,.páginas.

Ejemplo:

MONI,.Ana.M..(1998):.“Tango,.psicología.y.otros”,.La ciencia y el arte, .vol..6,.

nº.10,.pp..23-38..

-. Si.la.cita.corresponde.a.un.artículo.en.un.periódico.o.revista.

de.circulación.masiva:.

. APELLIDO,.Nombre.del.autor,.Fecha:.“Título.del.artículo”,.

Nombre de la revista/periódico, .Lugar,.Páginas.

Ejemplo:

STORNI,.Alejandro..(2001,.Abril.13):.“La.búsqueda.del.jabalí”..Página 12, .Bs..

As,.p..14.

-. Si.es.un.artículo.que.aparece.en.un.página.de.Internet.y.

es.un.duplicado.de.una.versión.impresa.en.una.revista,.se.', 'chunk 117');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 118, 'utiliza.el.mismo.formato.para.artículo.de.revista,.poniendo.

entre.paréntesis.cuadrados.[Versión.electrónica].después.del.

título.del.artículo..Si.en.cambio,.el.artículo.corresponde.a.

una.publicación.en.serie.que.sólo.está.disponible.en.versión.

electrónica.se.procede.así:

. APELLIDO,.Nombre.del.autor,.“Título.del.artículo”,.Nombre de 

la publicación en serie..E dición..Localización.en.el.documento.

fuente,.disponibilidad.y.acceso,.[Fecha.de.consulta]..ISSN.

Ejemplo:

MISIRLIS,.Graciela,.“Didáctica.e.inclusión”..Red de Cátedras de Didáctica General, .

30.de.julio.de.2004,.vol..2,.Nº.4,.<http://www.didac.org.ar/textos/index.

html>, .[Consulta:.21.de.junio.de.2007].ISSN.0717-3458.

La.sugerencia.realizada.aquí.es.diferenciar.la.bibliografía.obli-

g

atoria.de.la.bibliografía.de.consulta..La.primera.se.refiere.a.la.

72. Capítulo.1. .Los.proyectos.de.cátedra

que.los.alumnos/as.tendrán.que.leer.indefectiblemente.porque.

sostiene.conceptualmente.el.desarrollo.de.la.unidad.curricular.

y.se.la.considera.indispensable .a.los.efectos.del.aprender..La.

segunda.es.aquella.que.orienta.la.lectura.optativa.de.alguna.', 'chunk 118');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 119, 'temática.y.la.permite.profundizar.o.leer.desde.otro.marco.teórico.

e.ideológico..

Por.ello,.resulta.mucho.más.orientador.que.la.bibliografía.

obligatoria.acompañe.a.cada.unidad.didáctica.y.que.la.biblio-

grafía

.de.consulta.se.presente.temáticamente.

Extroducción

NO SÉ ME IMPORTA UN PITO (fragmento)

“No sé me importa un pito que las mujeres 

tengan los senos como magnolias o como pasas de higo; 

un cutis de durazno o de papel de lija.

Le doy una importancia igual a cero, 

al hecho de que amanezcan con un aliento afrodisíaco 

o con un aliento insecticida. 

Soy perfectamente capaz de soportarles 

una nariz que sacaría el primer premio 

en una exposición de zanahorias; 

¡pero eso sí! –y en esto soy irreductible– no les perdono, 

bajo ningún pretexto, que no sepan volar” (Oliverio .Girondo,.1932,.

en.Espantapájaros (al alcance de todos)).

Creo.que.no.es.necesaria .la.aclaración .pero.por.si.acaso.

quiero.quedarme.tranquilo:.los.proyectos.de.cátedra.no.sirven.

para.volar.

 73Más.didáctica.(en.la.educación.superior)

AUSUBEL, . D.; . NOVACK, . J.. y.

HANESIAN, . H.. (1983): . Psi-

cología Educativa ,. M éxico,.

Trillas.

B

AQUERO, . Ricardo . (2002): . La', 'chunk 119');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 120, 'transmisión educativa desde 

una perspectiva contextualista, .

Bs.. As., . Posgrado . de. ges-

t

ión . institucional, . Flacso.

(Mimeo).

B

RUNER, . Jerome . (1991): . Actos 

de significado. Más allá de la 

revolución cognitiva ,.M adrid,.

Alianza.

C

OLL,.César.(1994):.Psicología y 

Currículum,.P rimera.Edición.en.

Argentina,.Bs..As.,.Paidós.

—— .y.otros.(1994):.Los conteni-

dos en la reforma. Enseñanza 

y aprendizaje de conceptos, 

procedimientos y actitudes ,

 .

Primera.Edición.en.Argentina,.

Bs..As.,.Santillana.

CHEVALLARD,.Yves.(s/f):.Acerca de 

la noción de contrato didáctico. .

Falculté.des.Sciences.Sociales.

du.Huminy..(Traducción),.ficha.

de.la.cátedra.de.Didáctica.IV.

de. la. Facultad . de. Ciencias.

Sociales.de.la.UNLZ.

—— .(1988):.Sur l’analyse didacti-

que. Deux études sur les notions 

de contrat et de situation,.M

 ar-

s

ella,.Publicación.del.IREM.de.

Aix.

DE

.OLIVEIRA.LIMA,.Lauro.(1986):.

Educación por la inteligencia , .

Bs..As.,.Humanitas..

DÍAZ. BARRIGA, . Ángel . (1986):.

Didáctica y currículum,.C uarta.

Edición, . México, . Ediciones.

Nuevomar.

D

irección.G

eneral.de.Cultura.y.Edu-

cación

.de.la.Provincia.de.Bue-

n', 'chunk 120');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 121, 'os.Aires..Consejo.General.de.

Cultura.y.Educación.(1999):.

Resolución 13298/99: Marco 

General.

 .

—— .(1999):.Resolución 13259/99: 

Diseño Curricular para el tercer 

ciclo de la EGB y la Educación 

Polimodal en Historia.

 .

Dirección . General . de. Cultura . y.

Educación.de.la.Provincia.de.

Buenos . Aires. . Dirección . de.

Educación . Superior . (2005):.

Disposición 30. .

EDELSTEIN, . Gloria . (1996): . “Un.

capítulo.pendiente:.el.método.

en.el.debate.didáctico .con-

t

emporáneo”, . en. A.. W. de.

Camilloni.y.otras:.Corrientes 

didácticas contemporáneas , .

Bs..As.,.Paidós.

— —(2000):. El análisis didáctico de 

las prácticas de la enseñanza. 

Una referencia disciplinar para 

la reflexión crítica sobre el tra-

bajo docente,

 .en.la.Revista.del.

Instituto.e.Investigaciones.en.

Ciencias.de.la.Educación,.Año.

IX,.núm..17,.Bs..As,.Facultad.

de. Filosofía . y. Letras, . UBA,.

Miño.y.Dávila.

—— . y. RODRÍGUEZ, . Azucena.

(1974):.El método: factor uni-

ficador y definitorio de la ins-

Bibliografía

74. Capítulo.1. .Los.proyectos.de.cátedra

trumentación didáctica,.en.la.

Revista.Ciencias.de.la.Educa-

ción,

.Año.4,.Nº.12,.Bs..As.', 'chunk 121');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 122, 'FREIRE,.Paulo.(1969):.La educación 

como práctica de la libertad , .

Bs..As.,.Siglo.XXI..

FURLÁN,.Alfredo.(1989):.Aporta-

ciones a la Didáctica de la Edu-

cación Superior ,.M éxico.D.F.,.

ENEP.Iztacala,.UNAM.

GALAGOVSKY . KURMAN, . Lydia.

(1996): . Redes conceptuales. 

Aprendizaje, comunicación, 

memoria, .Primera.Edición,.Bs..

As.,.Lugar.Editorial.

GIRONDO,.Oliverio.(1991):.Obras 

de Oliverio Girondo ,.B uenos.

Aires,.Losada.

MAGER, . Robert . (1979): . Formu-

lación operativa de objetivos 

didácticos ,. C uarta . Edición,.

Madrid,.Marova.

Ministerio.de.Cultura.y.Educación.

de.la.Nación..Consejo.Fede-

r

al.de.Cultura .y.Educación..

(1997): . Contenidos Básicos 

Comunes para la Formación 

Docente de Grado ,. P

 rimera.

Edición.

—

— .(1997):.Contenidos Básicos 

para la Educación Polimodal , .

Primera.Edición.

—— .(2004):.Núcleos prioritarios de 

aprendizaje, .Primera.Edición.

ONTORIA,.Antonio.y.otros.(1994):.

Mapas conceptuales ,.T ercera.

Edición,.Madrid,.Narcea.Edi-

ciones.

ORGAMBIDE,

.Pedro.(1985):.T odos 

teníamos veinte años, .Buenos.

Aires,.Editorial.Pomaire.

ROGOFF ,.B

árbara.(1997):.“Los.tres.

planos.de.la.actividad.socio-cul-

t', 'chunk 122');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 123, 'ural:.apropiación.participativa,.

participación.guiada.y.apren-

d

izaje”,.en.J..Wertsch.y.otros:.

La mente sociocultural. Aproxi-

maciones teóricas y aplicadas,

 .

Madrid,.Fundación.Infancia.y.

Aprendizaje.

S

TEIMAN,.Jorge.(2004): ¿Qué deba-

timos hoy en la didáctica? Las 

prácticas de enseñanza en la 

educación superior ,.B

 s..As.,.

Baudino.Ediciones-UNSAM.

TORRES . SANTOMÉ, . Jurjo.

(1994): . Globalización e 

interdisciplinariedad: el currí-

culum integrado ,. M adrid,.

Morata.

Z

ABALZA,.Miguel.(1997):.Diseño 

y desarrollo curricular,.M adrid,.

Narcea.

 75

Capítulo 2

El método y los recursos 

didácticos 

Introducción

TÁCTICA Y ESTRATEGIA 

Mi táctica es 

mirarte 

aprender como sos 

quererte como sos 

mi táctica es 

hablarte

y escucharte 

construir con palabras 

un puente indestructible

mi táctica es 

quedarme en tu recuerdo 

no sé cómo ni sé 

con qué pretexto 

pero quedarme en vos 

mi táctica es 

ser franco 

y saber que sos franca 

y que no nos vendamos

simulacros 

para que entre los dos

no haya telón 

ni abismos 

76. Capítulo.2. .El.método.y.los.recursos.didácticos

E', 'chunk 123');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 124, 'n.el.capítulo.anterior,.al.plantear.el.marco metodológico, .des-

e

chamos.el.nombre.de.estrategias.d idácticas. .Claro.que.el.

término,.en.la.letra.de.Mario.Benedetti,.suena.tan.tierno.que.dan.

ganas.de.andar.construyendo.‘estrategias’.por.doquier.

En.este.capítulo.plantearemos.algunas.cuestiones.que.tie-

nen

.que.ver.con.las.‘estrategias’.que.usamos.los.docentes.para.

enseñar.aunque.no.utilizaremos.ciertamente.tampoco.aquí.el.

término.objetado. .Seguimos .pensando .que.la.“construcción.

metodológica”.(Forlán,.1986;.Edelstein,.1996).es.una.categoría.

conceptual.que.sostiene.con.acierto.la.idea.de.las.intervenciones.

secuenciadas.de.enseñanza..

Intentamos.pues.traer.al.campo.de.la.didáctica.y.en.el.con-

texto

.de.la.educación.superior,.algunas.líneas.que.nos.permitan.

a.nosotros.mismos.y.a.quien.quiera.hacer.de.su.práctica.una.

pregunta.constante,.una.reflexión.referida.a.algo.tan.elemental,.

tan.primario,.tan.obvio.como.lo.es.el.uso.de.algunos.recursos.

didácticos..¿Tan.necesario?.(“Mi.estrategia.es./.en.cambio./.más.

profunda.y.más./.simple./.mi.estrategia.es./.que.un.día.cualquiera.

/.no.sé.cómo.ni.sé./.con.qué.pretexto./.por.fin.me.necesites”).', 'chunk 124');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 125, '1. La relación entre el método y los recursos 

didácticos

Hemos.expuesto, .en.el.capítulo .anterior, .algunas .ideas.

que. fijan . nuestro . posicionamiento . respecto . a. la. cuestión.

metodológica. .D

ecíamos .al.respecto, .que.esta.construcción 

metodológica.n o.es.una.construcción.idiosincrática.adecuada.a.la.

propia.personalidad.o.la.propia.experiencia.únicamente,.sino.que.

mi estrategia es 

en cambio 

más profunda y más 

simple 

mi estrategia es 

que un día cualquiera 

no sé cómo ni sé 

con qué pretexto 

por fin me necesites.

(Mario

.Benedetti,.1974,.en Poemas de otros).

 77Más.didáctica.(en.la.educación.superior)

está.determinada.por.la.naturaleza.epistemológica.del.contenido.

y.las.características.particulares.de.los.alumnos/as.que.aprenden,.

desdeñando.así.la.posibilidad.de.considerar.conceptualmente.

la.existencia.de.un.método.único.o.un.método.generalizable.

a.distintas.situaciones.de.clase.y.aceptando.que.sea.propia.de.

cada.situación.didáctica.en.particular,.en.función.de.qué.se.está.

enseñando.y.a.quién.se.está.enseñando..

En.palabras .de.la.propia.Edelstein .podemos.resumir.esta.

idea:.', 'chunk 125');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 126, '“Definir.lo.metodológico.implica.el.acercamiento.a.un.

objeto.que.se.rige.por.una.lógica.particular.en.su.cons-

trucción.

.A.ello.hay.que.responder.en.primera.instan-

c

ia..P

enetrar.en.esa.lógica.para.luego,.en.su.segundo.

momento, .atender.al.problema .de.cómo.abordar.el.

objeto.de.su.lógica.particular.a.partir.de.las.peculiari-

d

ades.del.sujeto.que.aprende..(…) .Como.expresión.de.su.

carácter.singular.cobra.relevancia,.así.mismo.reconocer.

que.la.construcción.metodológica.se.conforma.en.el.

marco.de.situaciones.o.ámbitos.también.particulares,.

es.decir,.se.construye.casuísticamente.en.relación.con.

el.contexto.(áulico,.institucional, .social.y.cultural)”.

(Edelstein,.1996).

Para.la.autora.cordobesa.resulta.necesario.considerar.un.ter-

cer

.elemento:.

“En.relación.con.esta.cuestión,.Avanzini.(1985).se.refiere.

a.un.tercer.elemento.o.parámetro.determinante.e

n.lo.

relativo.al.método.junto.a.la.disciplina.y.el.alumno,.

en.sus.peculiaridades,.que.es.el.tema.de.las.finalida-

des.

.Ello.implica.la.adopción.de.una.postura.axiológica,.

una.posición.en.relación.con.la.ciencia,.la.cultura.y.la.

sociedad..Yo.hablaría.en.este.caso.de.intencionalidades.', 'chunk 126');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 127, '–intentando.reafirmar.la.diferenciación.de.una.ética.uti-

litarista,

.de.la.eficiencia.basada.en.el.pragmatismo–.que.

por.cierto.inciden.también.en.las.formas.de.apropiación.

cuya.interiorización.se.propone”.(Edelstein,.1996).

Desde.aquí.podemos .afirmar .entonces .que.contenido .a.

enseñar,.sujeto.que.lo.aprende.e.intencionalidad, .conforman.

una.unidad.indisoluble.a.la.hora

.de.pensar.en.lo.metodológico..

Afirmamos . también . nosotros . la. no. neutralidad . de. esta.

temática.en.la.didáctica..Hemos.dicho.en.otro.trabajo.también..

78. Capítulo.2. .El.método.y.los.recursos.didácticos

(Steiman, .2004), .asumiendo .los.supuestos .socioculturalis-

t

as.para.interpretar .la.vida.del.aula.(Baquero,.1998),.que.en.

la.situación.didáctica.es.necesario.analizar.la.injerencia.de.los.

instrumentos .culturales .como.mediadores.en.la.situación.de.

aprendizaje.y.que.es.necesario.considerar.el.escenario.del.aula,.

como.un.particular.escenario.sociocultural.en.el.cual.los.docen-

t

es.intervenimos.de.algún.modo.y.‘en’.algún.tipo.de.actividad.

(Baquero,.1996).

Hemos.adherido.a.la.idea.de.“participación.guiada”.(Rogoff,.', 'chunk 127');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 128, '1997).como.una.situación.interpersonal.de.imbricación.en.una.

situación.cultural.en.la.que.docentes.y.alumnos/as.se.implican.

y.se.constituyen.mutuamente.en.situaciones.de.a

prendizaje.y.

de.enseñanza.y.que.por.ello,.a.su.vez,.la.enseñanza.se.define.

como.un.tipo.de.especial.intervención.en.las.prácticas.sociales.

de.los.sujetos..

En.este.contexto,.en.el.que.los.instrumentos.culturales.son.

definidos.como.mediadores.en.la.situación.de.aprendizaje.(Lave,.

2001),.queremos.traer.al.debate.didáctico,.algunos.temas.que,.

por.ser.viejos,.por.haber.quedado.‘pegados’.a.perimidos.modelos.

explicativos.del.aprendizaje.o.por.haber.sido.la.esencia.discursiva.

del.paradigma.normativo.de.la.didáctica,.han.desaparecido.del.

campo..

Es.entonces.en.la.línea.que.aquí.presentamos.desde.donde.

planteamos.este.capítulo..Queremos.hacer

.eje.en.algunos.‘ins-

trumentos’

.para.trabajar.metodológicamente.en.las.aulas.de.la.

educación.superior..

“Las.técnicas.y.procedimientos,.en.la.visión.que.sos-

tengo,

.se.constituyen,.en.consecuencia,.en.instrumen-

tos

.válidos,.formas.operativas.articuladas.en.una.pro-

puesta

.global.signada.por.un.estilo.de.formación,.que.', 'chunk 128');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 129, 'integra.a.modo.de.enfoque,.perspectivas.de.corte.filosó-

f

ico-ideológico,.ético,.estético,.científico.y.pedagógico” 

(Edelstein,

.1996).

No.hablaremos .nosotros .de.procedimientos .ni.de.técni-

c

as.porque.la.intención.no.es.proponer.formas.secuenciadas.

de.intervención..Nos.limitaremos.a.presentar.algunos recursos 

didácticos..E ntendemos, .genéricamente.a.los.recursos.didácticos.

como.los.materiales.de.apoyo.a.la.enseñanza.

 79Más.didáctica.(en.la.educación.superior)

En.el.escenario.de.los.instrumentos.culturales,.queremos.res-

c

atar.la.idea.del.recurso.didáctico.para,.desde.aquí,.abrir.una.línea.

de.discusión.en.torno.a.algunos.de.ellos.que.dentro.de.la.opción.

metodológica.que.construya.cada.docente,.fundamentalmente.

(aunque.no.excluyente).en.el.campo.disciplinar.de.las.ciencias.

sociales.y.en.las.situaciones.de.aprendizaje.que.requieren.en.

general.del.uso.de.textos,.pueden.constituir.un.instrumento.de.

trabajo.didáctico.y.para.los.que,.en.ocasiones,.necesitamos.algún.

tipo.de.sugerencia.práctica.desde.donde.pensarlos.

Lo.que.sigue.no.es.ni.más.ni.menos.que.la.sistematización.

de.algunas.de.n

uestras.prácticas.en.las.que.usamos.recursos.', 'chunk 129');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 130, 'didácticos.para.trabajar.textos..Es.nuestro.parecer.sobre.lo.que.

nosotros.mismos.hacemos..Y.es,.desde.allí,.parte.de.nuestra.

construcción.instrumental.

Ya.afirmamos,.también.en.el.capítulo.anterior,.que.no.es.la.

intención.dar.modelos,.ni.recetas,.ni.delimitar.el.buen.hacer.del.

hacer.erróneo..Son.sencillamente,.las.ganas.de.poner.a.dispo-

sición

.de.los.colegas.algunos.de.los.recursos.que.nos.han.ser-

vido

.como.apoyo.a.la.enseñanza.para.que.también.otro.docente.

pueda.pensar.desde.ellos.su.propia.construcción.instrumental.

Pero.es.también.querer.aportar.al.campo.de.la.didáctica.desde.

un.lugar

.que.creemos.no.puede.perderse:.el.de.las.orientaciones.

prácticas.(Steiman,.2004)..Si.bien.es.cierto.que.el.paradigma.nor-

m

ativo.no.logró.dar.respuestas.a.las.prácticas.y,.por.el.contrario,.

mató.la.autonomía,.alejó.la.posibilidad.de.la.iniciativa.propia,.

sepultó.lo.diferente.bajo.el.epitafio.de.lo.erróneo,.también.es.

cierto.que.el.paradigma.interpretativo.necesita.alimentarse.de.

buenas.prácticas.para.ser,.además.de.un.aporte.a.la.interpreta-

c

ión.de.la.vida.del.aula,.un.aporte.a.las.posibilidades.de.intervenir.', 'chunk 130');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 131, 'desde.la.enseñanza.de.modos.diferentes..Porque.el.riesgo.está.

en,.despejando.la.reflexión.instrumental.de.l

a.cotidianeidad,.dejar.

que.la.estereotipia.se.vea.como.natural.y.que.las.rutinas.hechas.

tradición,.se.instalen.en.las.conciencias.y.en.las.prácticas.para,.

otra.vez.y.sin.pretenderlo,.hacer.de.las.aulas.un.movimiento.de.

constante.inercia.

80. Capítulo.2. .El.método.y.los.recursos.didácticos

2. Los ejercicios

2.1. Características de los ejercicios

Tomamos.aquí.la.noción.de.ejercicio.como.la.aplicación.mecá-

nica

.de.rutinas.de.procedimientos.que.admiten.una.única.forma.

de.resolución,.como.en.el.caso.de.las.fórmulas.matemáticas,.en.

las.que.no.aparece.un.contexto.real.sobre.el.que.se.aplican..

Un.ejercicio.no.tiene.continuidad.más.allá.de.sí:.empieza.y.

termina.con.la.resolución.del.mismo.y.su.planteo.deriva.de.la.

necesidad.de.aplicar.un.procedimiento.preestablecido.

No.vemos.implicado.el.‘formato’.de.presentación.en.la.dife-

r

enciación.entre.ejercicios.y.problemas..De.hecho,.consideramos.

que.muchos.de.los.que.habitualmente.llamamos.problemas,.por-

q

ue.s

on.presentados.con.enunciados,.se.corresponden.con.la.', 'chunk 131');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 132, 'categoría.de.lo.que.estamos.denominando.ejercicios,.en.tanto.

sus.características.son.las.antes.descriptas:

-. es. aplicación . mecánica . de. rutinas . de. procedimientos.

preestablecidos;

-

. admite.una.única.forma.de.resolución;

-. no.aparece.un.contexto.real.sobre.el.que.se.aplica..

2.2. Ejemplos de ejercicios

Vemos.en.estas.propuestas,.ejemplos.de.ejercicios:

 81Más.didáctica.(en.la.educación.superior)

-. Considerando.el.siguiente.enunciado:.‘Si.l.es.la.longitud.de.un.segmento.

elegido.sobre.uno.de.los.lados.del.xôy.y.l´.es.la.longitud.de.su.proyección.

ortogonal.sobre.el.otro.lado.del.ángulo,.entonces.el.cociente.l´./.l.es.

constante,.o.sea,.no.depende.del.segmento.elegido’..Compruebe.el.enun-

ciado

.en.el.siguiente.gráfico,.marcando.sobre.la.semirrecta.ox,.los.puntos.

a,.b,.c,.d,.de.manera.que.se.verifiquen.las.longitudes.indicadas.para.los.

segmentos1.

oa.=.2.cm

bc.=.2,5.cm

ab.=.1.cm

cd.=.3.cm

-. Graficar.en.ejes.cartesianos:.y.=.x.·.

2

-. ¿Cómo.es.la.imagen.de.un.objeto.colocado.a.50.cm..de.una.lente.conver-

gente

.de.25.cm..de.distancia.focal?

-. Una.muestra.gaseosa.que.ocupa.540.cm3.a.0,97.atm..tiene.una.masa.de.', 'chunk 132');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 133, '0,55.grs..y.se.encuentra.a.98.ºC..Se.sabe.que.la.fórmula.de.la.sustancia.

que.contiene.puede.ser.C2H6O.ó.CH40..Considérese.C=12.grs.;.H=1grs..

y.O=16.grs..¿De.cuál.se.trata?

-. Une.con.flechas.indicando.la.relación.entre.la.provincia.y.su.capital:

*.Bs..As. *.Trelew

*.Misiones *.Rosario

*.Chubut *.Santa.Fe

*.Santa.Cruz *.La.Plata.

*.Santa.Fe *.Posadas

*.Río.Gallegos

o

x

/

/

y

3. Las situaciones problemáticas 1

3.1. Características de las situaciones problemáticas

Ahora,.tomamos.la.noción.de.situación problemática.como .

una.situación.a.resolver.que.puede.involucrar.una.o.más.solu-

ciones

.y.en.la.que.puede.intervenir.una.o.más.variables..En.este.

sentido.estamos.considerando.de.igual.manera.al.problema.y.a.

1. Este.ejemplo.se.ha.extraído.de:.Villella,.José.y.otros.(1998):.Matemática: 

Acerca del concepto de función, .D ocumentos.para.la.Capacitación.Docente,.

Bs..As.,.Universidad.Nacional.de.General.San.Martín.

82. Capítulo.2. .El.método.y.los.recursos.didácticos

la.situación.problemática..Una.situación.problemática.se.pre-

senta

.con.un.relato.breve.y.para.su.resolución.se.aplican.varios.

procedimientos.rutinarios.y/o.algún.procedimiento.nuevo,.pero.', 'chunk 133');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 134, 'por.sobre.todo,.se.trabaja.en.torno.a.ciertas.hipótesis.ya.que.

una.situación.problemática.es.tal,.si.se.presenta.inserta.en.un.

recorte.mínimo.de.la.realidad.que.funciona.como.contexto.y.ante.

la.cual.hay.que.dar.algún.tipo.de.respuesta.porque.la.situación.

se.constituye.como.un.‘desafío’.a.resolver..

Desde.esta.concepción,.la.situación.problemática.exige.un.

primer.trabajo.de.delimitación.del.problema.y.puede.incluir.la.

recolección,.clasificación.y.c

rítica.de.datos.o.el.manejo.de.ciertos.

datos.dados..En.este.caso.resulta.más.valioso.si,.en.la.mayor.

medida.posible,.dicha.situación.tiene.relación.con.alguna.prác-

tica

.o.situación.laboral.futura.

En.síntesis,.consideramos.a.la.situación.problemática.como.

un.recurso.a.partir.del.cual.el.trabajo.de.la.clase.se.organiza.en.

torno.a:

-. contextualizarse.en.un.recorte.de.la.realidad.que.le.da.sentido;

-. poner.en.juego.varios.procedimientos.rutinarios.y/o.proce-

dimientos

.nuevos;

-. manejar.datos.que.pueden.exigir.o.no.un.trabajo.previo.de.

búsqueda,.selección,.clasificación.y/o.crítica.de.los.mismos;.

-. elaborar.algún.tipo.de.hipótesis

.que.oriente.la.búsqueda.de.

la.o.las.soluciones;', 'chunk 134');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 135, '-. tomar.decisiones;

-. obtener.soluciones.únicas.o.admitir.varias.soluciones.posibles.

Atendiendo .a.estas.características, .una.situación.proble-

m

ática.supone.un.trabajo.de.iniciativa.personal.y.una.lectura.

particular.de.la.situación.que.se.está.planteando.ante.la.cual,.

en.algún.momento,.se.deberá.tomar.alguna.decisión.para.seguir.

avanzando.

P

ensamos.a.las.situaciones .problemáticas .como.recursos.

disparadores.de.la.clase,.esto.es,.para.contextualizar.un.conte-

n

ido.dentro.de.una.situación.problema.que.le.de.sentido.antes.de.

analizar.sus.categorías.conceptuales;.pensamos.las.situaciones.

problemáticas.para.poner.en.situación.contextual.y.en.un.t

rabajo.

básicamente.analítico.los.contenidos.ya.trabajados.en.una.clase;.

pensamos.también.las.situaciones.problemáticas.para.cerrar.una.

clase.dejando.abierto.el.desafío.de.problematizar.el.contenido.

 83Más.didáctica.(en.la.educación.superior)

3.2. Ejemplos de situaciones problemáticas

Algunos.ejemplos.de.situaciones.problemáticas:2

-. Un.clásico.juego.de.niños.es.el.‘teléfono’.construido.con.dos.recipientes.de.

hojalata.(latas.de.arvejas.o.tomates).a.los.que.se.les.ha.quitado.la.tapa.y.', 'chunk 135');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 136, 'se.los.ha.unido.mediante.un.hilo,.para.lo.cual.se.habrán.perforado.conve-

nientemente

.las.bases.de.las.latas..Considere.este.juego.para.responder2:

a). ¿Se.puede.hablar.a.grandes.distancias?

b). ¿Cómo.interviene.la.tensión.del.hilo.en.la.calidad.de.la.transmisión?

c). ¿Se.pueden.reemplazar.las.latas.por.vasitos.de.plástico?.¿Eso.mejora.

o.empeora.la.calidad.de.la.transmisión?

d). ¿Qué.pasa.si.alguien.aprieta.el.hilo.con.los.dedos?.¿Se

.ve.alterada.

la.propagación?

e). Si.Ud..fuera.docente.de.un.séptimo.grado.de.la.Educación.Primaria,.

¿a.los.fines.de.tratar.qué.contenidos.podría.utilizar.esta.experiencia.

con.sus.alumnos/as?

-. En.una.conversación.entre.amigos.ha.salido.el.tema.de.los.embarazos.no.

deseados..A.medida.que.se.discute.el.tema.las.posiciones.se.polarizan..

Mientras.un.grupo.defiende.el.derecho.de.las.madres.a.abortar,.otro.defiende.

el.derecho.de.los.niños.a.nacer..En.ese.contexto:

a). ¿Cuál.sería.tu.posición?

b). ¿Qué.respuesta.darías.desde.diferentes.enfoques.de.la.ética?

c). ¿Qué.nuevas.variables.incluirías.para.relativizar.las.posiciones?;.

¿podría

.variar.la.posición.ética.con.la.inclusión.de.nuevas.variables.

en.la.situación?', 'chunk 136');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 137, '-. En.un.medio.de.comunicación.televisivo.en.un.panel.especializado.alguien.

está.afirmando.que.el.hombre.pampeano.de.campo.es.callado.e.introvertido.

porque.su.horizonte.es.muy.amplio.y.distante..Si.estuvieras.formando.parte.

del.panel,.¿en.qué.acordarías.y.en.qué.no.con.la.afirmación.vertida?

-. La.empresa,.una.empresa.familiar.y.pequeña.que.ha.colocado.en.el.mercado.

de.los.kioscos.de.Rosario.una.nueva.línea.de.golosinas,.lleva.un.período.

de.seis.meses.de.baja.en.las.ventas..En.la.reunión.de.los

.socios.hay.tres.

propuestas:

a)

. venderla.antes.que.decaiga.más.aún,

b). contratar.un.Gerente.de.Marketing,

c). contratar.un.Licenciado.en.Administración,

¿Qué.datos.pedirías.para.analizar.cada.una.de.las.tres.propuestas?

2. El.ejemplo.citado.se.ha.extraído.de:.Tricárico,.Hugo.y.otros.(1998):.Física 

2: Campos y ondas ,.D ocumentos .para.la.Capacitación .Docente, .Bs..As.,.

Universidad.Nacional.de.General.San.Martín.

84. Capítulo.2. .El.método.y.los.recursos.didácticos

4. Los trabajos prácticos

Resulta.familiar.el.término.trabajos prácticos ..D e.hecho.en.

la.educación.superior.universitaria.es.habitual.la.organización.', 'chunk 137');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 138, 'académica.en.clases.teóricas.y.clases.de.trabajos.prácticos..A.fin.

de.no.confundir.el.uso.de.los.términos,.en.primer.lugar.queremos.

establecer.la.diferencia.entre.la.‘clase.de.trabajos.prácticos’.y.el.

‘trabajo.práctico’.como.recurso.didáctico.

4.1. La clase de trabajos prácticos 

Cuando.se.habla.de.la.clase.de.‘trabajos.prácticos’.(T.P .),.sole-

mos

.referirnos.a.una.clase.que,.generalmente.a.cargo.de.un.Jefe.

de.Trabajos.Prácticos.(J.T.P .),.resulta.ser.una.clase.que.‘sigue’.a.

una.teórica..Observando.diversas.cátedras.podremos.encontrar,.

seguramente,.formas

.diferentes.de.organizar.la.clase.de.T.P ..Así,.

algunos,.la.consideran.como.una.clase.aclaratoria.del.teórico..

Para.otros,.la.clase.de.T.P ..es.el.lugar.donde.se.hacen.prácticas.

(de.laboratorio,.de.ejercitación,.de.trabajo.en.talleres,.etc.),.las.

que,.en.el.mejor.de.los.casos,.resultan.directamente.relacionadas.

con.la.teoría.presentada.en.la.‘clase.teórica’,.aunque,.también.las.

hay,.a.veces,.autónomas.o.con.su.propia.secuencia,.al.margen.

del.desarrollo.que.se.sigue.en.los.teóricos..También.solemos.

encontrar.cátedras.que.dividen.su.proyecto.en.contenidos.que.', 'chunk 138');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 139, 'se.desarrollan.en.los.teóricos.y.contenidos.que.s

e.desarrollan.en.

las.clases.de.T.P .,.sin.establecer.ninguna.diferencia.entre.ambas.

instancias.

C

onsideramos.que.la.clase.de.trabajos.prácticos.puede.ser.

una.clase.dedicada.a.una.forma.especial.de.trabajo.que.le.da.

una.identidad.particular,.distinta.de.una.clase.‘teórica’.y.cuya.

particularidad.radica.en.el.tipo.de.trabajo.cognitivo.–el.análisis.

aplicado–.que.se.implica.en.la.propuesta.didáctica.y.en.el.tipo.de.

situaciones.de.aprendizaje.que.se.proponen:.el.trabajo.en.torno.

a.situaciones.o.problemas.concretos.

Si.hay.un.escenario.didáctico.en.donde.deben.‘pasar’.cosas.

es,.justamente,.en.la.clase.de.trabajos.prácticos..Es,.así

.enten-

d

ido,.un.espacio.en.el.que.el.alumno/a.puede.hipotetizar,.demos-

t

rar,.probar,.resolver,.analizar,.aplicar,.decidir,.discutir.en.forma.

 85Más.didáctica.(en.la.educación.superior)

sistemática.y.manifiesta,.a.través.de.las.distintas.situaciones.

didácticas.que.esta.clase.puede.proponer.

Es.esperable.que.la.clase.de.T.P ..resulte.ser.una.continuación.

de.la.clase.teórica,.en.tanto.se.constituye.fundamentalmente.', 'chunk 139');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 140, 'en.un.ámbito.de.análisis.aplicado,.pero.a.su.vez,.por.la.par-

t

icularidad.universitaria.de.requerirse.la.asistencia.obligatoria.

únicamente.a.la.clase.de.trabajos.prácticos,.sería.necesario.que.

éstas.se.secuencien.entre.sí.conservando.algún.tipo.de.lógica.

interna.que.les.de.coherencia.y.continuidad..

En.este.contexto.cabe.pensar.la.clase.de.trabajos.prácticos.

como.una.clase.en.la.que.se.realizan.diversas.actividades.entr

e.

las.cuales.la.guía.de.trabajos.prácticos.sólo.resulta.ser.una.de.

las.opciones.en.términos.de.recursos.didácticos.

4.2. Características del trabajo práctico 

 como recurso didáctico

Una.propuesta.de.trabajo.práctico.puede.adquirir.formatos.

variables..Pero.en.nuestra.propia.concepción,.en.la.que.aquí.utili-

z

aremos,.su.particularidad,.aquello.que.lo.diferencia.de.cualquier.

otro.recurso,.está.dado.en.que:

-. resulta.ser.una.propuesta.en.la.que.se.hacen.intervenir.dife-

r

entes.categorías.teóricas.–que.pueden.estar.previamente.

dadas.o.no–.para.interpretar.una.situación.de.la.práctica;

-. permite.diferentes.opciones.de.resolución.y,.en.consecuencia,.

exige.algún.tipo.de.toma.de.decisiones;.

-. e', 'chunk 140');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 141, 'xige,.explícitamente,.la.fundamentación.teórica.interviniente;

-. se.presenta.a.partir.de.un.contexto.global.devenido,.pre-

f

erentemente, .del.desempeño.profesional.y.de.la.práctica.

laboral..

Así.planteado,.un.trabajo.práctico.no.es.una.serie.de.ejerci-

cios.

.Tener.que.resolver.ejercicios,.puede.que.sea.una.necesidad.

dentro.de.un.T.P ..(en.tanto.sea.cálculo.aplicado),.pero.éste.no.

se.limita.sólo.a.eso..Con.la.misma.lógica,.un.trabajo.práctico.

tampoco.es.una.serie.de.problemas.desarticulados.entre.sí.

Consideramos .al.trabajo.práctico.como.una.propuesta.de.

interpretación.y.fundamentación.teórica.que.parte.de.una.situa-

86. Capítulo.2. .El.método.y.los.recursos.didácticos

ción.problemática.global.que.contextualiza .a.cada.una.de.las.

tareas.a.realizar..Su.esencia.está.dada.por.varias.acciones.de.

análisis.que.deben.realizarse.(diversas.en.cuanto.al.tipo.de.tra-

b

ajo.cognitivo.que.exigen).y.una.síntesis.o.informe.elaborado.por.

el.propio.sujeto.en.el.cual.se.fundamentan.los.procedimientos.

seleccionados.para.su.resolución.y/o.los.resultados.o.conclu-

s

iones.a.las.que.se.arriba,.en.el.que.ha.de.intervenir .el.o.los.', 'chunk 141');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 142, 'marcos.teóricos.seleccionados.(convenientemente.brindado.por.

la.bibliografía.de.lectura.obligatoria).

Así,.exige.un.‘hacer’,.pero.es.un.‘hacer’.que.implica.no.sólo.

una.resolución.práctica,.s

ino.un.hacer.en.el.que.la.necesidad.

de.trabajar.con.análisis.y.síntesis.parciales,.con.una.síntesis.

integradora.final.y.con.la.explicitación.del.fundamento.y.marco.

teórico,.evitan.una.aplicación.mecánica.y.exclusivamente.ins-

trumental.

U

n.trabajo.práctico.tiene.un.contexto.global.y.real,.cons-

t

ituyéndose .en.un.‘todo’.en.el.que.cada.parte.tiene.sentido.

en.función.de.esa.totalidad.que.le.da.significado. .Su.planteo.

deviene.de.la.necesidad.de.‘situar’.al.contenido.en.el.ámbito.de.

la.práctica.laboral-profesional .y.de.enfrentar.al.alumno/a.con.

ese.contenido.desde.la.óptica.de.su.inscripción.en.situaciones.

prácticas,.de.la.toma

.de.decisiones,.de.la.necesidad.de.elegir,.de.

la.exigencia.de.fundamentar..Siempre.tiene.que.ver.con.situacio-

nes

.contextualizadas.e.implica.para.su.realización.diversas.acti-

v

idades.y.caminos.que.exigirán,.preferentemente,.una.elección.

de.medios.y.no.una.salida.unilateral..Por.ello,.es.muy.probable.', 'chunk 142');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 143, 'que.algunas.de.las.tareas.propias.de.un.trabajo.práctico.sean.

trabajos.en.un.campo.real..Aún.así,.cabe.diferenciarlo .de.un.

trabajo de campo.ya .que.se.entiende.a.éste.como.un.trabajo.de.

intervención.en.un.campo.de.la.realidad..En.un.T.P ..la.secuencia.

de.actividades.propuestas,.pone.al.alumno/a.en.contacto.directo.

c

on.una.práctica.real.del.contexto.social,.a.fin.de.que.experi-

mente

.situaciones.cercanas.al.desempeño.de.una.profesión.sin.

necesaria.intervención .en.dicha.realidad..Por.ejemplo,.un.T.P ..

podría.pedir.la.elaboración.de.un.plan.de.asesoramiento.a.una.

Casa del Niño.r especto.a.las.relaciones.institución-comunidad,.

mientras.que.un.Trabajo.de.Campo,.requeriría.que.dicho.aseso-

ramiento

.se.haga.efectivo.

 87Más.didáctica.(en.la.educación.superior)

Un.trabajo.práctico.no.debería.funcionar.como.la.única.ins-

t

ancia.de.articulación.entre.la.teoría.y.la.práctica.porque.esto.

daría.por.supuesto.que.ambas.circulan.en.la.clase.desarticuladas.

entre.sí.y,.ciertamente,.una.buena.práctica.pedagógica.las.articula.

de.hecho..En.todo.caso.será.un.recurso,.que.dentro.de.la.opción.

metodológica.construida.para.facilitar.el.trabajo.de.los.alumnos/', 'chunk 143');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 144, 'as.en.torno.al.objeto.de.conocimiento.en.cuestión,.podrá.favo-

r

ecer.la.circulación.de.teoría.y.práctica.como.dos.dimensiones.

de.tratamiento.de.un.mismo.contenido.disciplinar.

4.3. Algunas sugerencias para formalizar 

 la presentación de un trabajo práctico

Considerando .ahora.al.trabajo.p ráctico.como.un.recurso.

didáctico, .creemos.conveniente .que.se.presente.con.un.pro-

t

ocolo-guía..Dicho.protocolo.podría.constar.de.las.siguientes.

partes:

1.

. Encabezamiento:.mínimamente.conviene.que.conste.el.nom-

br

e.de.la.Institución,.el.nombre.de.la.facultad.o.escuela.(en.

el.caso.de.la.educación.superior.universitaria),.el.nombre.de.

la.carrera.y.el.nombre.de.la.cátedra.

2.. Tareas.del.trabajo:.referencia.pautada.de.cada.una.de.las.acti-

vidades

.que.se.le.proponen.realizar.al.alumno/a.a.lo.largo.del.

T.P .

3.

. Bibliografía: .referencia.explícita.a.los.textos.que,.desde.el.

marco.de.la.fundamentación,.es.necesario.hacer.intervenir.

para.resolver.el.

T.P .

4.. Carácter.de.elaboración:.referencia.a.la.cantidad.de.miembros.

que.pueden.conformar.un.grupo.(si.el.trabajo.fuera.grupal).o.

explicitación.de.qué.partes.pueden.elaborarse.grupalmente.', 'chunk 144');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 145, 'y.qué.partes.deben.ser.resueltas.necesariamente.en.forma.

individual,.o.referencia.a.que.el.trabajo.se.resuelve.únicamente.

en.forma.individual.

5.. Fecha.de.entrega:.explicitación.del.tiempo.estimado.para.la.

resolución.y/o.fecha.de.entrega.del.trabajo.resuelto.

6.. Criterios .de.evaluación: .enunciación .de.los.criterios .que.

considerará.la.cátedra.para.valorar.la.producción.escrita.que.

entregue.el.alumno/a.y.que,.en.consecuencia,.determinarán.

88. Capítulo.2. .El.método.y.los.recursos.didácticos

la.aprobación.o.no.del.trabajo.si.éste.se.utilizara.a.los.fines.

de.acreditaciones.

Una.vez.presentado .el.protocolo-guía, .entonces, .el.tra-

b

ajo.práctico.está.en.marcha..Podrá.desarrollarse.en.el.ámbito.

institucional.(el.aula,.laboratorios,.talleres,.etc.).o.fuera.de.la.

institución..

Nuestra.propia.práctica.con.el.uso.de.trabajos.prácticos.nos.

ha.hecho.pensar.en.la.conveniencia.de.tener.en.cuenta:

a). En.el.momento.de.construir.la.propuesta,.no.olvidar.que.se.

trata.de.un.recurso.que.lo.pensamos.al.servicio.del.aprender.

y.no.al.servicio.del.acreditar..Esta.forma.de.concebirlo.nos.

recuerda.que,.como.recurso.didáctico,.

m

ás.que.‘comprobar.si.', 'chunk 145');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 146, 'saben.hacer.algo’,.lo.estamos.pensando.para.que.‘aprendan.

a.hacer.algo’.

b). Al.momento.de.la.presentación,.realizar.una.lectura.del.proto-

colo

-guía.a.fin.de.hacer.aclaraciones.y.facilitar.la.formulación.

de.preguntas.por.parte.de.los.alumnos/as.

c). Una.consideración.especial.requiere.el.‘cuidado’.a.tener.en.

cuenta.en.la.asignación.de.la.tarea..El.verbo.que.utilizamos.

habitualmente.para.definir.la.acción,.requiere.de.ciertas.expli-

caciones

.que.si.son.escritas.mejor.aún..Cuando.requerimos.

‘analizar’,.en.ocasiones.resulta.necesario.hacer.explícitos.los.

procedimientos.involucrados.en.un.análisis.ya.que.no.siempre.

los.alumnos/as.entienden.por.‘

análisis’.lo.mismo.que.nosotros.

estamos.entendiendo..Varios.ejemplos.de.la.comprensión.

confusa.de.las.tareas.que.asignamos.podrían.mencionarse.

pero.sólo.como.muestra,.¿qué.entenderán.nuestros.alum-

n

os/as.cuando.les.solicitamos.por.ejemplo:.“formulen.una.

serie.de.hipótesis.que.justifiquen…”; .“comparen.eligiendo.

diferentes.variables…”?

d). Tras.la.presentación,.dedicar.un.tiempo.a.hipotetizar.posibles.

formas.de.resolución.(no.particularmente.para.cada.tarea,.sino.', 'chunk 146');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 147, 'en.forma.general).a.fin.de.anticipar.posibles.dificultades.que.

pudieran.surgir.durante.la.resolución.

e). Durante.el.período.de.resolución.(más.aún.si.no.se.resolviera.

en.el.ámbito.de.la.institución.y.llevara.más.de.una.semana),.

dedicar

.un.tiempo.de.la.clase.a.comentarios.y.brindar.aseso-

ramiento

.particular.a.cada.grupo.

 89Más.didáctica.(en.la.educación.superior)

f). Antes.de.la.entrega.definitiva,.resulta.conveniente.que.los.

alumnos/as.muestren.‘borradores’.o.esquemas.parciales.de.su.

producción.escrita.a.fin.de.poder.supervisar.el.estado.de.avance.

de.la.misma.y.realizar.orientaciones.si.fuera.necesario.

g). Un.apartado.especial.merece.el.tema.de.la.evaluación .de.

los.trabajos.prácticos..Al.referirnos.a.la.evaluación.estamos.

considerando .que.si.un.T.P ..es.entregado, .exige.ser.eva-

luado.

.La.evaluación.se.refiere.a.algún.tipo.de.valoración.y.

señalamientos.sobre.la.producción.escrita,.considerando.los.

criterios.de.evaluación.establecidos..No.estamos.diciendo.que.

exige.una.calificación,.sino.que.exige.una.evaluación.cualita-

tiva

.para.su.devolución..Siendo.el.T.P ..un.recurso.didáctico,.y.', 'chunk 147');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 148, 'tal.lo.dicho.estar.al.servicio.del.aprendizaje.en.primer.lugar,.

estos.señalamientos.resultan.mucho.más.provechosos.si.no.

se.limitan.únicamente.a.comunicar.una.calificación.numé-

rica

.(como.el.caso.de.la.escala.habitual.1/10).o.conceptual.

(como.el.caso.de.‘aprobado’).sino.que,.en.la.medida.en.que.

se.acompañe.de.una.serie.de.apreciaciones.que.orientan.al.

alumno/a.en.la.revisión.de.su.trabajo,.tanto.en.los.aspectos.

más.destacables.de.la.producción.como.en.aquellos.en.los.

que.el.desempeño.no.fuera.del.todo.satisfactorio.o.se

.mani-

festaran

.errores.en.la.resolución.parcial.de.una.tarea.o.en.la.

intervención.de.categorías.conceptuales,.lo.convierten.en.un.

recurso.sobre.el.que.es.necesario.volver.a.pensar.para.seguir.

aprendiendo.

h)

. Finalmente,.tras.la.devolución.de.los.trabajos.entregados,.

dedicar.un.tiempo.(o.una.clase).a.la.puesta.en.común.de.las.

resoluciones.a.fin.de.comparar,.compartir.dificultades,.apreciar.

los.distintos.puntos.de.vista.dados.a.la.resolución,.etc.

90. Capítulo.2. .El.método.y.los.recursos.didácticos

4.4. Últimas consideraciones 

 sobre los trabajos prácticos

Ningún.recurso.tiene.valor.por.sí..Pero.si.se.tuviéramos.que.', 'chunk 148');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 149, 'rescatar.algunas.de.las.virtudes.propias.de.los.trabajos.prácticos,.

podríamos.enumerar,.entre.otras,.las.siguientes.que.nos.pare-

c

en.relevantes.con.relación.a.la.propuesta.de.uso.de.trabajos.

prácticos:

-

. facilitar.un.contacto.directo.con.algunas.implicancias.deriva-

das

.de.la.práctica.laboral-profesional;

-. concretizar.una.propuesta.de.trabajo.apoyada.en.la.idea.del.

aprendizaje.autónomo;

-. integrar.aspectos.de.la.teoría.con.la.relación.directa.de.éstos.

en.el.campo.de.las.prácticas;

-. instar.al.trabajo.con.bibliografía.desde.un.contexto.que.le.da.

sentido.y.

a.significación;

-. producir.informes.escritos.(una.necesidad.de.la.práctica.labo-

ral

.no.siempre.desarrollada.en.el.ámbito.de.la.Universidad,.

sobre.todo.en.carreras.más.afines.a.la.Tecnología);

-. poner.a.prueba.la.necesidad.de.tomar.decisiones.y.el.trabajo.

en.equipo.cooperativo.

4.5. Un ejemplo de trabajo práctico

Aquí.un.ejemplo.de.un.protocolo-guía.de.trabajo.práctico:

INSTITUTO.SUPERIOR.DE.FORMACIÓN.DOCENTE.Nº.

PROFESORADO.EN.LENGUA.Y.LITERATURA

ESPACIO.DE.LA.PRÁCTICA.DOCENTE

Curso:.Segundo

Docentes:

TR

ABAJO.PRÁCTICO.Nº.3

1.. Tareas.del.trabajo', 'chunk 149');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 150, 'a). Observen.una.clase.de.Lengua.en.la.educación.secundaria.y.realicen.un.

registro.textual.de.lo.que.acontece.en.la.clase.sin.ningún.tipo.de.valoración.

o.interpretación.

b). Transcriban.textualmente.el.registro.de.la.observación.

c). Analicen.el.registro.extrayendo.párrafos.textuales.del.mismo.y.explicitando.

junto.a.cada.uno.de.los.párrafos.el.marco.conceptual.que.les.permite.realizar.

el.análisis..Consideren.como.mínimas.variables.de.análisis.las.siguientes:

 91Más.didáctica.(en.la.educación.superior)

-. propósitos.explícitos.de.la.clase

-. macrohabilidades.trabajadas

-. microhabilidades.trabajadas

-. segmentos.didácticos.con.intencionalidad.diferenciada

d). Elaboren.un.informe.final.a.modo.de.conclusión.en.el.que.se.presente.la.

relación.entre.las.propuestas.didácticas.para.la.enseñanza.de.la.Lengua.y.la.

Literatura.y.la.práctica.docente.sin.ningún.tipo.de.valoraciones.con.relación.

a.la.clase.observada.

2.. Bibliografía.obligatoria.a.considerar

BURBULES,.Nicholas.(1999):.El diálogo en la enseñanza, .Bs..As.,.Amorrortu.

EDELSTEIN,.Gloria.(2000):.“El.análisis.didáctico.de.las.prácticas.de.la.enseñanza..', 'chunk 150');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 151, 'Una.referencia.disciplinar.para.la.reflexión.crítica”,.Revista del IICE, .Nº.17,.

Bs..As.,.Miño.y.Dávila.

HALLIDAY ,.M..(1998):.El lenguaje como semiótica social ,.B s..As.,.Fondo.d e.

Cultura.Económica.

Pcia..Bs..As..Dirección.General.de.Cultura.y.Educación.(1995):.Documento 

curricular B-1 de Lengua, .La.Plata,.primer.volumen.

3.. Carácter.de.elaboración

Las.tareas.‘a’,.‘b’.y.‘c’.podrán.realizarse.en.grupos.de.no.más.de.cuatro.miem-

br

os..La.tarea.‘d’.deberá.resolverse.en.forma.individual.

4.. Criterios.de.evaluación

Se.considerará:

-. la.resolución.de.la.totalidad.de.las.tareas.del.trabajo.

-. la.aplicación .de.los.marcos.teóricos.de.las.lecturas.bibliográficas .en.la.

resolución.del.trabajo.

-. la.evidencia.de.uso.de.lenguaje.didáctico.específico.

-. la.fundamentación.de.los.conceptos.involucrados.en.los.diferentes.análisis.

5.. Fecha.de.entrega

El.trabajo.deberá.ser.entregado.la.primera.semana.

de.mayo.

A.los.recursos.hasta.aquí.presentados.(ejercicios,.situaciones.

problemáticas,.trabajos.prácticos).creemos.que.no.debe.conside-

r

árselos.como.‘mejores’.o.‘peores’.recursos.sino.que,.en.función.', 'chunk 151');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 152, 'de.la.especificidad.del.contenido.y.las.características.generales.

del.curso,.la.pertinencia.de.uno.sobre.los.otros,.será.una.de.las.

tantas.decisiones.que.en.ese.ambiente.del.aula,.tenemos.que.

tomar.a.fin.de.construir.buenas.situaciones.de.aprendizaje..A.

modo.de.síntesis,.planteamos.en.el.cuadro.siguiente.las.que.

creemos.son.las.notas.distintivas.entre.estos.tres.recursos.

92. Capítulo.2. .El.método.y.los.recursos.didácticos

4.6. Diferencias sustantivas entre ejercicios, 

 situaciones problemáticas y trabajos prácticos

EJERCICIO SIT. PROBLEMÁTICA TRABAJO PRÁCTICO

Aplicación

.mecánica.

de.rutinas.de.procedi-

mientos

Análisis

.de.situaciones.

prácticas.y.puesta.en.

juego.de.varias.rutinas.

de.procedimientos.y/o.

procedimientos.nuevos

Análisis,.interpretación.

y.fundamentación.de.

situaciones.prácticas.

haciendo.intervenir.teo-

rías

.o.marcos.concep-

tuales

.y.procedimientos

Solución.única

Una.o.más.soluciones.

que.obligan.a.optar.por.

una.de.ellas

Resoluciones.variadas.

que.obligan.a.optar.

y.justificar.tanto.la.

opción.como.el.desa-

rrollo

Sin

.contexto Con.un.contexto.

limitado

En

.un.contexto.global.

y.real

Cada.ejercicio.conforma.', 'chunk 152');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 153, 'una.unidad.con.princi-

pio

.y.fin.de.resolución

Cada.problema.con-

forma

.una.unidad.

con.principio.y.fin.de.

resolución

Cada

.tarea.del.trabajo.

práctico.se.referencia.en.

un.todo.mayor.que.

se.

mantiene.a.lo.largo.del.

trabajo

Sin

.proyección.hacia.la.

futura.práctica.laboral-

profesional

Con

.o.sin.proyección.

hacia.la.futura.práctica.

laboral-profesional

P

referentemente.con.

proyección.hacia.la.

futura.práctica.laboral-

profesional

P

ropuesta.de.alto.nivel.

de.abstracción

Propuesta.intermedia.

entre.lo.abstracto.y.lo.

concreto

P

ropuesta.de.alto.nivel.

de.significación.con.

lo.real

El.contenido.justifica.la.

aplicación.de.un.proce-

dimiento

.preestablecido

El.contenido.justifica.la.

elección.de.los.procedi-

mientos

El

.contenido,.la.práctica.

laboral-profesional.y.la.

vida.cotidiana.justifi-

can

.la.elección.de.los.

procedimientos

Es

.ejercicio.en.tanto.

permite.ejercitar

Es.problema.en.tanto.

permite.resolver.

desafíos

Es

.trabajo.práctico.en.

tanto.implica.análisis.e.

interpretación.funda-

mentados

 93Más.didáctica.(en.la.educación.superior)

5. Las guías de estudio

5.1. Un poco de historia respecto', 'chunk 153');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 154, 'a las guías de estudio

Los.docentes.hemos.oído.hablar.de.guías.de.estudio.desde.

hace.más.de.tres.décadas..Nacidas.de.la.mano.del.modelo.tecno-

lógico

.y.recuperando.el.énfasis.en.la.necesidad.de.la.motivación.

esgrimida.por.la.escuela.nueva,.se.presentó.a.sí.misma.como.

la.mejor.alternativa.para.paliar.el.déficit.de.comprensión.en.los.

alumnos/as,.la.única.alternativa.para.dinamizar.las.clases.en.las.

que.aún.se.mantenían.las.características.del.verbalismo.tradi-

c

ional.y.la.‘solución.mágica’.para.la.mayoría.de.los.problemas.

escolares..Vaya.a.saberse.por.qué,.acaso.p

or.cuestiones.fortuitas.

o.por.la.buena.‘prensa’.que.adquirió.rápidamente.entre.nosotros,.

se.convirtió.en.‘EL’.recurso.y,.como.ya.resulta.habitual.en.la.

docencia,.la.‘moda.pedagógica’.de.turno..

En.este.contexto, .las.guías.de.estudio, .logran.enraizarse.

en.las.prácticas.escolares.dentro.de.lo.que.se.llamó.el.Método 

del Estudio Dirigido .( Echegaray.de.Juárez,.1979).cuya.caracte-

r

ística.principal.radicó.en.el.aprendizaje.de.ciertas.técnicas.de.

trabajo.intelectual.y.el.desarrollo.de.actividades.de.investigación,.

pautadas.a.través.de.las.guías..Se.generaliza.de.este.modo.la.', 'chunk 154');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 155, 'necesidad.de.una.metodología.de.trabajo.que.facilite.a.los.alum-

nos/as

.el.apr

endizaje.del.‘saber.estudiar’:.lectura.global,.lectura.

por.párrafos,.subrayado,.síntesis,.recitación.y.repaso.–de.allí.que.

se.la.conociera.como.la.técnica.2L,.2S,.2R–.

Por.la.misma.época.los.planes.de.estudios.empiezan.a.reflejar.

la.incorporación.de.una.nueva.unidad.curricular:.Metodología de 

Estudio..A ún .en.el.ámbito.de.la.educación.superior,.leer.com-

pr

ensivamente,.subrayar,.sintetizar,.realizar.cuadros.sinópticos,.

realizar.anotaciones.marginales.en.un.texto.y.otras.‘técnicas’.se.

transformaron.en.contenidos.curriculares..El.supuesto.teórico,.

característica.esencial.del.modelo.didáctico.tecnológico,.es.que.

si.el.alumno/a.desarrolla.la.capacidad.de.la.comprensión,.podrá.

aplicarla.a.diferentes.objetos.de.estudio,.e

s.decir,.será.‘compren-

sivo’

.en.cualquier.área.disciplinar..

94. Capítulo.2. .El.método.y.los.recursos.didácticos

En.la.práctica.pedagógica,.que.asumió.rápidamente.la.moda.

a.fines.de.la.década.de.1960.y.buena.parte.de.los.años.70,.las.

guías.de.estudio.se.convierten.en.prescripción.desde.los.ámbitos.', 'chunk 155');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 156, 'de.gestión.y.en.obligación.en.el.ámbito.del.aula..Los.resulta-

dos

.obtenidos.parecen.curiosos:.como.toda.moda.pedagógica,.

rápidamente.se.la.acomoda.a.la.práctica.didáctica.del.docente,.

para.variar.el.formato,.pero.no.la.esencia..Así,.por.ejemplo,.en.

la.más.arraigada.concepción.tradicional, .las.guías.de.estudio.

se.convierten.en.cuestionarios.enciclopédicos.que.se.contestan.

‘con.las.mismas.palabras.del.libro’,.sustituyendo.la.‘exposición

.

verbalista’.del.docente.por.la.‘exposición.gráfica’.del.texto..A.su.

vez,.la.nueva.unidad.curricular.no.logró,.como.era.de.esperar,.

que.los.alumnos/as.aprehendieran.una.metodología.de.estudio..

Sin.dudas.hoy,.responderíamos.que.cada.objeto.disciplinar.tiene.

su.propia.especificidad.metodológica.y.que,.por.ello,.una.meto-

dología

.general.de.estudio.no.resulta.apropiada.al.margen.de.un.

contenido.particular.

¿Podremos.rescatar.hoy.la.utilidad.de.las.guías.de.estudio.en.

las.aulas?.Veamos…

En. primer . lugar,. pareciera . que. esto . será . posible . en. la.

medida.que.se.las.considere.un.recurso.entre.otros.y.no.un.

recurso.prescriptivo..Como.tal,.entonces,

.y.dentro.de.la.opción.', 'chunk 156');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 157, 'metodológica.que.adopte.cada.uno.de.nosotros.en.función.del.

objeto.de.conocimiento.que.enseñamos,.las.guías.podrían.ser.un.

recurso.apropiado.para.‘trabajar’.textos..Esta.idea.del.‘trabajo’.

con.textos.supone.que,.según.el.propósito.que.persigamos,.la.

guía.de.estudio.puede.estar.al.servicio.de.ayudar.a.la.compren-

s

ión.del.texto.a.través.de.preguntas-clave,.o.a.la.crítica.de.las.

posturas.planteadas.en.un.texto.o.a.la.comparación.de.teorías.

presentes.en.diversos.textos.o.a.cualquier.otra.posibilidad.en.la.

cual.los.textos.sean.un.vehículo.sustancial.del.aprendizaje.

En.segundo

.lugar,.en.la.elaboración.de.las.guías.de.estudio,.

habrá.que.tener.presente.algunas.consideraciones.para.que.el.

uso.de.las.mismas.sea.un.recurso.apropiado.y.no.una.rutina.

estereotipada..Quizás.valga.la.pena.detenernos.especialmente.

en.algunas.de.estas.cuestiones.

 95Más.didáctica.(en.la.educación.superior)

5.2. Consideraciones prácticas

Acerca de su especificidad:

U

na.guía.de.estudio.nunca.reemplaza.al.texto..Por.el.contra-

r

io,.resulta.ser.un.recurso.que.facilita.el.abordaje.de.ciertas.temá-

ticas

.a.partir.de.la.lectura..Guiar.el.proceso.de.comprensión.del.', 'chunk 157');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 158, 'texto.es.una.posibilidad,.pero.su.elaboración.no.necesariamente.

debe.agotarse.en.esa.orientación.ya.que,.tal.como.expresáramos.

anteriormente,.la.guía.debe.adecuarse.a.los.propósitos.que.per-

s

igamos.con.ella:.orientar.la.comprensión,.proponer.compara-

ciones,

.facilitar.estrategias.de.crítica.fundamentada,.contrastar.

teorías,.recoger.información.de.la.vida.cotidiana.para.acrecentar.

planteos.teóricos,.etc.

Dentro.de.todas.estas.posibilidades,.aquello.que.caracteriza.

fundamentalmente.a.las.guías.de.estudio

.es.que.en.ellas,.no.se.

da.por.supuesta.la.resignificación.que.el.alumno/a.da.al.texto.

sino.que,.su.elaboración,.orienta.dicho.proceso.para,.a.partir.

de.allí.(si.se.cree.posible.y.necesario),.avanzar.con.propuestas.

que.pongan.en.juego.operaciones.cognitivas.de.mayor.comple-

jidad.

Acerca de su propuesta:

U

na.guía.de.estudio.propone.actividades.a.resolver.individual.

o.grupalmente..Estas.actividades.podrán.ser.preguntas,.planteos.

cuestionadores,.propuestas.de.ejemplos,.análisis.de.situaciones,.

búsqueda.de.información.colateral,.indagación.de.cuestiones.

en.algún.aspecto.de.la.realidad.(como.el.caso.de.entrevistas,.', 'chunk 158');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 159, 'encuestas,.registros.textuales.de.situaciones.observadas,.etc.).

u.otras..Estas.actividades.s

e.responden,.salvo.excepciones,.en.

forma.escrita.

Acerca de su estructura:

A

.fin.de.evitar.la.fragmentación.del.texto,.conviene.que.una.

guía.de.estudio.comience.con.un.planteo.inicial.en.el.cual.se.con-

textualice

.la.temática.con.sentido.de.totalidad..La.primera.pro-

p

uesta.de.actividad.planteada.convendría.que.lleve.a.una.lectura.

completa.del.texto.a.fin.de.propiciar.una.primera.aproximación.

sincrética.al.mismo..Convendría.asimismo.que.incluya.alguna.

96. Capítulo.2. .El.método.y.los.recursos.didácticos

actividad.inicial.que.facilite.una.primera.relación.entre.la.nueva.

temática.y.los.contenidos.trabajados.en.clases.anteriores.o.con.

situaciones.de.la.vida.cotidiana.que,.por.conocidas,.permitan.a.

los.alumnos/as.una.aproximación.significativa.a.la.cuestión.

A.partir.de.ello,.la.guía.puede.presentar.una.serie.de.tareas,.

entre.las.que.podrían.estar.presentes.algunas.específicamente.

relacionadas.con.el.análisis.del.texto,.secuenciadas.gradualmente.

por.nivel.de.dificultad.en.cuanto.al.tipo.de.trabajo.cognitivo.que.', 'chunk 159');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 160, 'se.pretende.poner.en.juego.a.partir.del.texto.(en.este.sentido.por.

ejemplo,.interpretar.una.serie.de.conceptos.propios.de.una.deter-

m

inada.t

eoría.resulta.ser.un.trabajo.cognitivo.de.menor.comple-

j

idad.que.contrastar.dichos.conceptos.con.otra.teoría.diferente)..

Este.proceso.analítico,.que.necesariamente.supone.identificar.y.

separar.partes.(podríamos.asemejar.el.sentido.del.término.‘par-

t

es’.a.los.diferentes.conceptos.presentes.en.un.texto),.establecer.

relaciones.entre.las.mismas,.establecer.relaciones.de.las.partes.

con.el.todo.e.ir.realizando.síntesis.parciales,.puede.constituir.el.

eje.de.trabajo.más.desarrollado.de.la.guía.

Finalmente,.tras.el.proceso.analítico,.conviene.que.la.guía.

se.cierre.con.alguna.actividad.en.la.cual.se.recupere.la.totali-

dad

.integrada.para.facilitar.la.síntesis.final.y.‘alejarse’.del.texto

.

propiciando .la.propia.elaboración .conceptual .(ya.que.damos.

por.supuesto.que.de.ninguna.manera.la.enseñanza.puede.estar.

orientada.únicamente.a.reproducir.marcos.teóricos.presentes.

en.la.bibliografía).

En.la.estructura.descripta,.podrían.identificarse .en.conse-

cuencia,

.tres.posibles.partes.de.una.guía.de.estudio:', 'chunk 160');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 161, '-. planteos.de.trabajo.que.faciliten.la.síncresis.inicial.y.una.

primera.lectura.global.de.la.bibliografía;

-. planteos.de.trabajo.que.favorezcan.el.análisis.y.las.síntesis.par-

c

iales.con.una.lectura.más.desmenuzada.de.la.bibliografía;

-. planteos.de.trabajo.que.permitan.realizar.la.síntesis.final.y.

elaborar.conceptos.propios,.opiniones.fundamentadas.o.con-

clusiones

.personales,.‘desprendiéndose’.de.la.

bibliografía.

Acerca del momento adecuado para ser utilizada:

D

iferentes.posibilidades.hacen.que.las.guías.de.estudio.resulten.

ser.un.recurso.apropiado.para.usar.en.diversas.circunstancias..

 97Más.didáctica.(en.la.educación.superior)

Una.guía.utilizada.antes.de.la.clase,.facilitaría.que.los.alum-

nos/as

.concurran.con.el.material.leído.y.de.esta.manera.se.enri-

quezca

.el.nivel.de.profundidad.que.pueda.darse.al.tratamiento.

de.los.contenidos,.la.clase.se.haga.más.participativa,.se.realice.

una.verdadera.construcción.conjunta.del.marco.conceptual.y.no.

se.fragmente.el.proceso.analítico.de.identificación.de.conceptos.

diversos.y.las.relaciones.establecidas.entre.ellos.

Una.guía.utilizada.durante.la.clase,.permitiría.prever.una.serie.', 'chunk 161');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 162, 'de.necesidades.relacionadas.fundamentalmente.con.el.material.

necesario .para.el.tratamiento .de.los.contenidos .que.de.otra.

forma,.quedarían.desarticulados.o.supeditados.a.fotocopias.s

uel-

tas

.sin.conexión.entre.sí.(tal.el.caso.del.uso.de.artículos.perio-

dísticos,

.viñetas,.relatos.de.casos,.datos.estadísticos.u.otros).y,.

en.consecuencia,.sin.relación.explicitada.con.la.bibliografía.que.

da.el.soporte.teórico.a.los.contenidos.

Una.guía.utilizada.después.de.la.clase,.ya.fuera.del.ámbito.del.

aula,.propiciaría.una.mayor.profundización.del.trabajo.iniciado.

en.ella.

Una.guía.utilizada .en.función.de.acreditaciones .parciales.

o.finales.y,.especialmente, .como.herramienta.para.el.proceso.

de.recuperación.de.aprendizajes.no.logrados.ante.fracasos.en.

las.acreditaciones.realizadas,.orientaría.la.fase.de.estudio.ante.

dichas.circunstancias.

Acerca de su uso:

U

na.guía.referida.a.un.texto.n

o.tiene.valor.‘per.se’.(Barco,.s/f)..

El.uso.reiterado.y.sistemático.de.guías.de.estudio.puede.generar.

en.los.alumnos/as.cierta.dependencia.para.abordar.textos..‘Espe-

rar

’.la.guía.para.leer.la.bibliografía.no.sólo.puede.atentar.contra.', 'chunk 162');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 163, 'la.autonomía.del.aprendizaje,.sino.también.generar.tal.grado.de.

supeditación.que.los.alumnos/as.se.acostumbren.a.que,.sin.guía,.

nada.se.hace.por.propia.iniciativa..

Por.otra.parte,.una.guía.siempre.orienta.desde.el.análisis.previo.

que.nosotros.mismos.hemos.realizado.del.texto.por.lo.que,.en.

consecuencia,.su.uso.reiterado.podría.invalidar.otro.tipo.de.pers-

p

ectivas,.ajenas.a.las.propias,.q

ue.únicamente.aparecen.cuando.el.

tratamiento.de.la.bibliografía.resulta.menos.pautado.

98. Capítulo.2. .El.método.y.los.recursos.didácticos

Acerca de ciertas precauciones en la elaboración:

E

n.la.elaboración.de.las.guías.y.particularmente.en.la.secuen-

cia

.de.las.actividades.que.presenta,.habría.que.tratar:

-. que.las.preguntas.relativas.a.la.identificación.de.la.estructura.

conceptual.del.texto.no.puedan.contestarse.mecánicamente.

identificando.‘palabras.estímulo’..Por.ejemplo,.ante.la.pre-

gunta

.“¿Qué.condiciones.plantea.el.autor.para…?”,. el.texto.

dice:.“Planteamos.las.siguientes.condiciones.para…”;

-. que.la.guía.no.pueda.resolverse.fragmentando.la.lectura.del.

texto;

-

. que.las.actividades.que.se.proponen.no.queden.desarticuladas.

entre.sí;', 'chunk 163');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 164, '-. que.si.se.pautaran.actividades.de.relevamiento.de.información.

en.algún.campo.real.(por.ejemplo.encuestas).no.queden.sin.

tratamiento.posterior

.(a.fin.de.evaluar.su.pertinencia,.con-

v

endría.preguntarse.siempre.¿para.qué.se.hace.esto.y.con.qué.

encuadre.teórico.se.relaciona?);

-. que.las.actividades.en.las.que.se.pidan.opiniones,.estén.en.las.

actividades.finales.ya.que.no.se.puede.opinar.con.fundamento.

si.antes.no.se.ha.analizado.algo;

-. que.se.analice.la.pertinencia.del.uso.e.inclusión.de.viñetas,.tiras.

humorísticas.o.materiales.similares,.que.si.bien.le.dan.cierta.

flexibilidad.y.le.quitan.formalidad.a.la.guía,.cosa.que.por.cierto.

puede.llegar.a.favorecer.el.desarrollo.de.la.misma,.también.se.

puede.correr.el.riesgo.d

e.vaciar.el.contenido.teórico.con.el.uso.

de.un.material.que.ha.sido.elaborado.para.otros.fines.(divertir,.

satirizar,.etc.).si.no.lo.usamos.convenientemente.

5.3. Errores más frecuentes en el uso de las guías de 

estudio (y una pequeña licencia para el humor)

Caso.1:.El homo hábitus .– la.guía.es.utilizada.indis.crimina-

damente–.

. U

tilizamos.todos.los.años.la.misma.guía.sin.adecuarla.ni.a.las.', 'chunk 164');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 165, 'particularidades.de.los.alumnos/as,.ni.a.los.nuevos.planteos.

teóricos.que.van.surgiendo.en.el.campo.disciplinar,.ni.al.cam-

biante

.contexto.sociohistórico.

 99Más.didáctica.(en.la.educación.superior)

Caso.2:.El homo commodus.– la.guía.es.utilizada.como.suple-

toria

.de.la.figura.del.docente–.

. Elaboramos.y.entregamos.a.los.alumnos/as.una.guía.que.

presupone.un.trabajo.de.varias.clases..En.cada.una.de.ellas,.

ingresamos.al.aula.y.sin.mediación.alguna,.mandamos.a.tra-

b

ajar.en.el.punto.que.corresponda.hasta.la.finalización.de.

nuestra.clase,.finalizada.la.cual.nos.despedimos.sin.haber.

intervenido.en.ningún.momento..Terminada.la.guía,.solicita-

mos

.su.entrega.y.suministramos.una.nueva.para.abordar.la.

temática.siguiente..El.caso.extremo.se.convierte.en.el.homo 

diarium, .caso.en.el.cual,.mientras.los.alumnos/as.trabajan.la.

guía,.nosotros.

leemos.el.diario..

Caso.3:.El homo difficilis.– la.guía.más.que.facilitar,.confunde–.

. Elaboramos.la.guía.con.tal.grado.de.complejidad.que.la.misma.

no.cumple.su.propósito,.Así,.por.ejemplo,.el.vocabulario.que.

utilizamos.resulta.más.complejo.que.el.del.texto.mismo;.ante.', 'chunk 165');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 166, 'las.tareas.que.pautamos,.los.alumnos/as.internamente.se.

preguntan.‘¿qué.hay.que.hacer?’;.las.actividades.extra-texto.

son.tan.difíciles.de.realizar.que.insumen.un.tiempo.desmedido.

y.finalmente.nunca.logran.completarse.

Caso.4:.El homo grupus.–la .guía.es.trabajada.en.un.pseudo-

grupo–.

. P

ermitimos.la.realización.de.la.totalidad.de.la.guía.en.grupos.

conformados.por.muchos.alumnos/as.(más.de.cuatr

o.ya.son.

muchos)..Como.en.la.mayoría.de.los.casos.de.trabajo.grupal,.

si.no.existen.primero.algunas.actividades.de.tipo.individual,.la.

resolución.de.la.misma.está.a.cargo.de.uno.o.dos.alumnos/as.

mientras.que.los.demás,.desentendiéndose,.hacen.de.la.clase.

un.momento.de.recreo..Después,.la.copian.y.ponen.su.nombre.

como.‘trabajo.de.equipo’..

Caso.5:.El homo cuestionarius. –la.guía.es.un.cuestionario–.

. ¡Qué.trabajo.da.elaborar .una.buena.guía!.Cuando.tenga.

tiempo.la.hago.mejor,.por.ahora… .Tomamos.el.libro.de.texto,.

y.nos.fijamos.en.los.subtítulos..Ya.está..Ahora.encabezamos.

la.pregunta.con:

.“¿A.qué.se.refiere.el.texto.cuando.se.plan-

100. Capítulo.2. .El.método.y.los.recursos.didácticos

tea… .[debe.colocarse.allí.el.subtítulo.en.cuestión]?”..También.', 'chunk 166');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 167, 'puede.reemplazarse.por:.“¿Cuál.es.la.idea.principal.de… .[debe.

colocarse.allí.el.subtítulo.en.cuestión]?”..En.algunos.formatos.

más.modernos.se.nos.puede.ocurrir.algo.así.como:.“Con.los.

conceptos.centrales.presentes.en… .[debe.colocarse.allí.el.

subtítulo.en.cuestión],.elabora.una.red.conceptual”.

¿Te.dije.que.cuando.tenga.tiempo.la.hago.mejor?.

Caso.6:.El homo guiaevaluadorus.–la .guía.es.la.única.fuente.

de.acreditaciones–.

Utilizamos.únicamente.la.evaluación.de.las.guías.para.obte-

n

er.calificaciones..Como.éstas.han.sido.elaboradas.grupalmente,.

por.un.lado,.no.logran.dar.cuenta.de.los.verdaderos.aprendiza-

jes

.realizados.por

.cada.alumno/a,.pero.por.otro.(enraizándonos.

en.una.variante.del.homo commodus) .siempre.es.mejor.corregir.

cinco.o.seis.guías.que.treinta.o.cuarenta.exámenes..El.broche.

de.oro.lo.colocamos.cuando.estamos.a.cargo.de.una.unidad.

curricular.en.la.educación.superior.y.con.esta.forma.de.trabajo.

decidimos.un.sistema.de.evaluación.con.promoción.directa..

5.4. Un ejemplo de guía de estudio

Ciertamente.mostrar.un.ejemplo.de.una.guía.de.estudio.sin.

presentar.el.texto.para.la.cual.está.hecha.resulta.complicado..', 'chunk 167');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 168, 'Aún.así.y.sólo.porque.a.lo.largo.de.este.capítulo.venimos.ejem-

p

lificando.cada.uno.de.los.recursos.q

ue.presentamos.aquí.va,.no.

un.modelo,.sino.sólo.un.recurso.que.hemos.usado.en.nuestro.

trabajo.

 101Más.didáctica.(en.la.educación.superior)

INSTITUTO.SUPERIOR.DE.FORMACIÓN.DOCENTE.Nº.

PROFESORADO.EN.EDUCACIÓN.PRIMARIA.

Unidad.curricular:.Perspectiva.Pedagógico-Didáctica.I.

Curso:.Primero.

GUÍA.DE.ESTUDIO.Nº.3

1. Bibliografía

LIBANEO,.José.C..(1986):.“Tendencias.pedagógicas.en.la.práctica.escolar”,.

Revista de Associacao Nacional de Educacao,

 .Año.3,.Sao.Paulo..(Traduc-

c

ión.al.español.sin.referencias.con.adaptación.y.agregados.elaborados.

por.la.cátedra).

2. Presentación

¿Qué.pasa.en.el.interior.de.las.escuelas.cuando.se.ponen.a.disposición.de.

los.alumnos/as.los.contenidos.socialmente.válidos?.¿Cómo.logra.esta.institu-

c

ión.cumplir.con.su.función.pedagógica.–distribuidora.de.cultura–?.¿Cómo.cada.

docente.actualiza.en.el.aula.su.práctica?

La.práctica.de.los.docentes,.supone,.aunque.no.podamos.identificarlos.c

la-

r

amente,.ciertos.supuestos.teóricos.que.justifican.y.legitiman.su.actividad.como.', 'chunk 168');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 169, 'enseñantes..Y ,.aunque.dicha.práctica.está.cargada.de.resabios.teóricos.de.diver-

s

os.referentes.teóricos.y.prácticos,.constituye.en.sí.todo.un.‘estilo.docente’..En.

ocasiones,.la.preocupación.más.importante.que.se.presenta.a.los.docentes.es.

incorporar.nuevas.‘recetas’.metodológicas.que.faciliten.y.hagan.más.efectivo.el.

trabajo..Así,.el.‘cómo.se.enseña…’. pasa.a.ocupar.el.lugar.más.relevante.de.la.

reflexión.cotidiana..Pero,.la.reflexión.acerca.del.‘cómo’.sólo.parece.ocupar.ese.

lugar.de.privilegio.si.lo.que.se.niega.es.la.reflexión.acerca.del.‘qué’..

-.

¿Qué

.se.enseña.en.el.aula?

-. ¿Qué.significación.social.tienen.los.contenidos.que.se.proponen?

-. ¿Qué.idea.de.sociedad.subyace.en.cada.propuesta.de.aprendizaje.que.se.

realiza.en.el.aula?

-. ¿Qué.concepción.acerca.del.saber.está.sosteniendo.la.práctica.de.enseñar.

de.un.docente?

-. ¿Qué.uso.del.poder.se.hace.a.diario?

-. ¿Qué.noción.de.autoridad.justifica.el.quehacer.del.docente?

-. ¿Qué.uso.se.espera.que.hagan.los.alumnos/as.de.los.saberes.que.se.enseñan?

Las.preguntas.del.‘qué’.se.introducen.en.la.dimensión.política.de.la.práctica.', 'chunk 169');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 170, 'pedagógica.y.facilitan,.a.su.vez,.un.abordaje.crítico.de.la.práctica.diaria.

.Como.

esta.práctica.es.histórica,.es.decir,.como.cada.docente.pone.en.el.‘acto.de.dar.

clase’.todo.un.bagaje.aprendido.por.la.experiencia.incorporada.a.lo.largo.de.su.

tránsito.por.el.sistema.escolar.desde.que.fue.alumno/a.en.los.jardines.de.infan-

tes,

.parece.que,.para.develar.las.prácticas.docentes.que.se.dan.en.las.escuelas,.

convendría.rastrear.en.la.historicidad.de.esta.función.social.de.la.docencia,.en.

las.tendencias.pedagógicas-didácticas.que.alimentaron.a.lo.largo.de.la.historia,.

los.presupuestos.teóricos.de.las.prácticas.docentes.

Siguiendo.el.planteo.del.texto.que.vamos.a.trabajar,.presentamos.las.ten-

dencias

.

pedagógico-didácticas.que.menciona.el.texto:

102. Capítulo.2. .El.método.y.los.recursos.didácticos

A). PEDAGOGÍAS.LIBERALES

1.. Tradicional.o.conservadora

2.. Escolanovista.o.renovada.progresivista

3.. Tecnológica

B). PEDAGOGÍAS.PROGRESISTAS

1.. Liberadora

2.. Crítica.o.de.los.contenidos

Analicemos.en.cada.una.de.ellas.algunas.variables.didácticas..

3. Trabajo con el texto:

ACTIVIDAD.Nº.1', 'chunk 170');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 171, 'a). Lean.el.artículo.de.José.C..Libaneo:.Tendencias.pedagógicas.en.la.práctica.

escolar

b)

. ¿Cuál.creen.que.es.el.objetivo.del.autor.al.plantear.esta.temática?

c). ¿Qué.aporte.realiza.para.comprender.mejor.la.vida.del.aula?

ACTIVIDAD.Nº.2

a). ¿Qué.variable.utiliza.para.clasificar.las.tendencias?.

b). ¿Qué.concepción.de.sociedad,.qué.concepción.de.educación.y.qué.concep-

ción

.de.función.social.de.la.escuela.tienen.en.común.las.tres.tendencias.

liberales?

c)

. ¿Y

.cómo.pueden.definirse.esas.mismas.concepciones.según.las.tendencias.

progresistas?

d)

. ¿Por.qué.las.llamará.‘tendencias’.y.no.‘corrientes’.o.‘modelos’?

ACTIVIDAD.Nº.3

a). Observen.los.gráficos.y/o.escritos.que.aparecen.a.continuación.y.desde.el.

marco.teórico.que.presenta.el.texto.respondan.a.los.cuestionamientos.que.

se.plantean.

Material.1

 103Más.didáctica.(en.la.educación.superior)

b). Los.gráficos.presentan.situaciones.de.aprendizaje.dentro.de.la.tendencia.

tradicional..¿Cuáles.de.las.características.referidas.a.la.concepción.de.apren-

dizaje

.de.dicha.tendencia.aparecen.evidentes.en.los.gráficos?.Fundamenten.

la.respuesta.describiendo.la.concepción.de.aprendizaje.subyacente.', 'chunk 171');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 172, 'c). Relacionen.esa.concepción.de.aprendizaje.con.las.características.que.pre-

senta

.el.autor.para.la.concepción.de.enseñanza.

d). El.autor.presenta.ciertas.notas.distintivas.de.los.contenidos.para.dicha.

tendencia.¿Qué.relación.puede.establecerse.entre.las.mismas.y.las.con-

cepciones

.de.aprendizaje.y.enseñanza?.Enúncienlas.a.través.de.hipótesis.

afirmativas.tales.como:

- si. el.contenido.es.dogmático,.entonces.el.alumno/a.sólo.debe.‘recibirlo’.

con

.pasividad.

Material.2

e). El.discurso.de.la.maestra.parece.encuadrarse.dentro.de.la.escuela.nueva..

¿Cuáles.son.los.indicadores.en.su.mensaje.que.podrían.hacer.suponer.que.se.

trata.de.una.docente.escolanovista?.Fundamenten.la.respuesta.describiendo.

los.supuestos.subyacentes.

104. Capítulo.2. .El.método.y.los.recursos.didácticos

f). ¿Qué.relación.puede.establecerse.entre.esta.propuesta.de.trabajo.en.el.aula.

y.la.concepción.de.aprendizaje.de.esta.tendencia?

g). ¿Cómo.se.conciben.los.contenidos.en.esta.tendencia?.Plantéenlos.a.través.

de.un.cuadro.comparativo.con.la.tendencia.tradicional.

Material.3

“Si.la.enseñanza.no.cambia.a.nadie,.carece.de.efectividad,.de.', 'chunk 172');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 173, 'influencia..Si.cambia.a.un.alumno/a.en.una.dirección.no.deseada,.

en.vez.de.la.dirección.deseada.(es.decir,.si.tiene.consecuencias.

indeseables.como,.por.ejemplo,.la.pérdida.de.la.motivación,.no.

puede.ser.considerada.como.una.enseñanza.eficaz..Habrá.que.

calificarla.de.deficiente,.indeseable.e.incluso.de.nociva..La

.ense-

ñanza

.será.satisfactoria,.o.eficaz,.en.la.medida.en.que.consigue.

alcanzar.las.metas.propuestas..

. (…). En.primer.lugar,.hay.que.asegurarse.de.que.existe.una.

necesidad.de.enseñanza.constatando.que.1).hay.razones.para.

aprender.y.2).los.alumnos/as.no.conocen.aún.lo.que.se.les.va.

a.enseñar..En.segundo.lugar,.hay.que.especificar.claramente.los.

resultados.u.objetivos.que.se.pretende.alcanzar.con.la.enseñanza..

Habrá.que.seleccionar.y.preparar.experiencias .de.aprendizaje.

para.los.alumnos/as,.de.acuerdo.con.los.principios.didácticos.y.

habrá.que.evaluar.la.realización.del.alumno/a.de.acuerdo.con.los.

objetivos.previamente

.elegidos..

. En.otras.palabras, .primero.decide.usted.a.dónde.quiere.

ir,.después.formula.y.administra.los.medios.para.llegar.allí.y,.

finalmente,.se.preocupa.usted.de.verificar.si.ha.llegado”.(Robert.', 'chunk 173');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 174, 'Mager,.1977,.en.Formulación operativa de objetivos didácticos).

h). La.exposición.del.autor.tiene.algunos.rasgos.que.parecen.encuadrarse.

dentro.de.las.concepciones.teóricas.de.la.tendencia.tecnológica..Hagan.un.

listado.de.palabras-clave.que.aparezcan.en.el.texto.y.que.den.cuenta.de.la.

mención.implícita.a.dicha.tendencia..Expliciten.junto.a.cada.palabra-clave.

los.supuestos.subyacentes.que.dicha.palabra-clave.sintetiza.(no.omiten.

palabras-clave.relacionadas.con.las.concepciones.de.aprendizaje,.enseñanza.

y.contenidos).

Material.4

Este.es.un.fragmento.de.un.informe.de.observación.de.una.clase.en.6to.año.

de.la.educación.primaria.de.una.escuela.del.conurbano.sur.bonaerense:

La.docente.nos.muestra.su.planificación.en.la.que.observamos.que

.los.

contenidos.conceptuales.de.Ciencias.Sociales.en.el.proyecto.que.está.desa-

r

rollando.son:.‘La.población..Distribución,.composición.social,.estructura.

ocupacional..Condiciones.de.vida..Índices.de.calidad.de.vida’.Mientras.que.en.

los.contenidos.procedimentales.figura:.‘Comparación.de.espacios.geográficos.

a.partir.de.la.relación.entre.distintas.variables.’', 'chunk 174');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 175, 'La.clase.comienza.con.un.torbellino.de.ideas.a.partir.de.una.pregunta.

planteada.por.la.docente:.¿Qué.diferencias.hay.entre.nuestro.barrio.y.el.centro.

de.Monte.Grande?.

 105Más.didáctica.(en.la.educación.superior)

Se.anotan.en.el.pizarrón.las.respuestas.de.los.chicos:.asfalto,.luz.de.

mercurio,.no.hay.zanjas,.casas.lindas,.muchos.negocios,.hay.barrenderos.

(mi.papá.trabaja.en.la.Municipalidad.–aclara.uno)…

La.docente.se.detiene.sobre.la.respuesta.‘no.hay.zanjas’.y.conversa.con.

los.chicos.sobre.el.destino.de.los.deshechos.en.nuestro.barrio..La.conver-

sación

.va.girando.hacia.la.presencia.de.los.pozos.ciegos..Después.pregunta.

‘Y.dónde.van.los.desechos.en.el.centro?.Uno.de.los.chicos.hace.mención.a.

las.cloacas..

Inmediatamente.la.docente.pregunta:.‘¿Por.qué.en.nuestro.barrio.no.hay.

cloacas?’.Algunas.de.las.respuestas.de

.los.chicos.son:.‘porque.vivimos.lejos.

del.centro,.porque.esto.es.una.villa,.porque.somos.pobres…’

(…)

La.d

ocente.pregunta.‘¿A.quién.le.corresponde.poner.las.cloacas.en.los.

barrios?’.Los.chicos.dan.respuestas.como:.‘ Al.Estado,.al.Gobierno,.a.la.Muni-

c

ipalidad,.a.los.vecinos…’ .La.docente.aprovecha.para.distinguir.esos.términos.', 'chunk 175');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 176, 'y.aclara.el.sentido.de.cada.uno.

(…)

La

.clase.finaliza.con.una.carta.que.escriben.entre.todos.dirigida.al.Inten-

d

ente.en.la.cual.solicitan.‘por.una.razón.de.justicia,.que.nos.pongan.las.

cloacas…’

i). ¿En.qué.tendencia.puede.encuadrarse.la.práctica.de.la.docente?.Fundamen-

ten

.esta.respuesta.

j). Analicen.el.registro.haciendo.intervenir.las.distintas.variables.que.presenta.

el.autor.para.describir.la.tendencia.

ACTIVIDAD.Nº.4

a). Ejemplifiquen.con.la.descripción.de.algunas.prácticas.que.hayan.observado.

en.las.escuelas.a.las.que.concurren.en.el.espacio.de.la.práctica.docente.y.

en.el.que.se.vea.la.presencia.en.dicho.ejemplo.de.alguna.de.las.tendencias.

mencionadas.en.el.artículo..

b). Analicen.el.ejemplo.dado.indicando.cuáles.son.los.ítems.que.marcan.la.con-

cor

dancia.con.alguna.de.las.tendencias.estudiadas..Por.ejemplo:.la.relación.

docente-alumno/a

.o.la.concepción.de.contenido.escolar,.o.la.concepción.

de.aprendizaje,.etc.

ACTIVIDAD.Nº.5

a). Armen.el.contenido.de.un.programa.radial.en.el.cual.los.distintos.actores.

muestren.visiones.encontradas.de.la.práctica.en.las.aulas..Se.sugiere.diseñar.

el.guión,.siguiendo.este.sencillo.esquema:', 'chunk 176');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 177, '. ¿Qué.pasa.hoy.en.las.aulas?

-. 1er.bloque:.Presentación.(escribir.el.guión)

-. 2do.bloque:.Entrevista.a….que.habla.de…

-. 3er.bloque:.Tandas.(diseñar.propagandas.acordes.con.el.tema)

-. 4to.bloque:.Música.(especificar.qué.tema.e.idea.central.de.la.letra).

-. 5to.bloque:.Los.docentes.dicen….(especificar.ideas)

-. Los.chicos.dicen….(especificar.ideas)

-. Los.

padres.dicen….(especificar.ideas)

-. Un.autor.dice….(reproducir.párrafos.textuales)

-. 6to.bloque:.Cierre.(Uds..eligen)

(No.olviden .encuadrar .la.actividad .en.el.marco.teórico .que.brinda.la..

bibliografía).

106. Capítulo.2. .El.método.y.los.recursos.didácticos

6. Las guías de lectura

6.1. Características de las guías de lectura

En.general.los.alumnos/as,.independientemente.de.su.edad.o.

la.carrera.en.que.se.encuentren,.poseen.estrategias.propias.para.

abordar.un.texto..El.‘abordaje’.de.un.texto.tiene.que.ver.con.su.

forma.de.ser.leído,.y.a.partir.de.ello,.de.interpretarlo.para.com-

pletar

.el.estudio.del.mismo..Más.allá.del.respeto.a.lo.particular,.

estas.estrategias.no.siempre.coinciden.con.las.necesidades.que.

percibimos.nosotros.como.docentes.para.un.mejor.aprendizaje..', 'chunk 177');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 178, 'De.esta.situación.surge.la.necesidad.de.orientar,.en.algunas.oca-

siones,

.esta.lectura.de.los.textos.

¿Por.qué.puede.resultar.necesaria.esta

.orientación?.Sin.afán.

de.completar.un.listado,.podrían.enumerarse,.entre.otras,.estas.

circunstancias:

-

. cuando.los.alumnos/as.no.están.acostumbrados.a.trabajar.

con.textos;

-. cuando.los.alumnos/as.manifiestan.dificultades.para.com-

pr

ender.un.texto;

-. cuando.el.texto.no.es.del.área.de.conocimiento.que.habitual-

mente

.leen.los.alumnos/as;

-. cuando.el.texto.resulta.muy.complejo.por.el.lenguaje.que.

utiliza.el.autor;

-. cuando.el.texto.plantea.temáticas.absolutamente.nuevas;

-. cuando.el.texto.presenta.en.forma.integrada.distintas.teorías.o.

corrientes.y.éstas.resulten.difíciles.de.‘aislar’.en.sus.conceptos.

básicos;

-

. cuando.el.texto.posee.mucha.información.y.se.quiere.trabajar.

sólo.con.

algunas.de.las.ideas.del.autor;

-. cuando.los.encuentros.de.clase.no.tienen.una.frecuencia.

cercana.en.el.tiempo.(por.ejemplo.en.los.regímenes.semi-

presenciales).

A

nte.estas.u.otras.situaciones.similares.se.hace.necesario.

algún.recurso.que.permita.‘sortear’.los.escollos.antes.enuncia-

dos.', 'chunk 178');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 179, '.Y.entonces,.las.guías.de.lectura.pueden.aparecer.como.un.

recurso.adecuado.para:.

 107Más.didáctica.(en.la.educación.superior)

-. facilitar.el.aprendizaje.de.los.alumnos/as.en.relación.al.trabajo.

con.un.texto;

-. orientar.el.‘enfrentamiento’.entre.el.alumno/a.y.un.texto;

-. suplir.las.clases.de.‘lectura.comentada’.

Una.guía.de.lectura.es.un.texto.narrativo.escrito,.elaborado.

por.el.docente.que.en.forma.prosada.y.a.modo.de.acompa-

ñ

amiento.(tal.como.si.el.docente.estuviera.junto.al.alumno/a.

leyendo.el.texto.con.él).orienta.la.lectura.fuera.del.ámbito.del.

aula.y.se.convierte,.por.ello,.en.un.recurso.de.trabajo.básica-

mente

.individual..

Una.guía.de.lectura.no.propone.actividades .a.resolver.ni.

suple.la.lectura.del.texto..Por.e

l.contrario,.su.especificidad.radica.

en.ser.un.recurso.que.acompaña.la.lectura:

-. contextualizando.el.texto.y/o.el.autor;.

-. anticipando.la.estructura.del.texto;

-. orientando.la.identificación.de.lo.importante.y.lo.accesorio;.

-. aclarando.conceptos;.

-. proponiendo.dónde.debe.detenerse.en.el.análisis;.

-. planteando.preguntas.que.despiertan.la.reflexión;.

-. agregando.ejemplos.que.no.están.presentes.en.el.texto;.', 'chunk 179');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 180, '-. advirtiendo.sobre.‘riesgos’.o.nudos.problemáticos.para.el.

lector;.

-. sugiriendo .reflexiones .que.pueden.exceder.el.ámbito.del.

texto;.

-. proponiendo.relaciones.con.otros.textos.o.temáticas..

A.partir.de.lo.expuesto.podemos.afirmar.que.la.elaboración.

d

e.una.guía.de.lectura.sigue.la.‘lógica’.del.texto.y.que.no.está.

constituida.por.partes.específicas.

Para.su.elaboración.sugerimos.tener.en.cuenta:

a). que.no.estaremos.presentes.cuando.los.alumnos/as.estén.

trabajando.con.ella.y,.por.lo.tanto,.no.podrán.pedirnos.expli-

caciones

.o.aclaraciones.ampliatorias;

b). que.el.lenguaje.que.utilicemos.debe.ser.más.accesible.que.el.

del.texto.y.las.aclaraciones.dadas.concretas.y.concisas;

c). que.necesitamos.haber.leído.con.tal.grado.de.profundidad.el.

texto.que.esa.lectura.nos.permita.anticiparnos.a.las.dificultades.

que.podrían.presentárseles.a.los.alumnos/as.frente.al.mismo;

108. Capítulo.2. .El.método.y.los.recursos.didácticos

d). que.la.guía.tiene.que.adecuarse.a.las.características.habituales.

que.presentan.los.alumnos/as.del.curso.en.el.que.trabajaremos.

con.ese.recurso;

e). que.la.guía.tiene.que.facilitar.y.no.confundir,.inmovilizar.o.

atemorizar;

f)', 'chunk 180');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 181, '. que. conviene . que. sea. un. ‘todo’. estructurado . y. no. una.

sumatoria.de.párrafos.dispersos;

g). que.únicamente.está.al.servicio.del.aprendizaje.

Las.guías.de.lectura .pueden.presentar .distinto .grado.de.

minuciosidad .en.el.acompañamiento .que.realizan..Así.puede.

hablarse.de.guías.específicas.para.trabajar.un.solo.texto.o.guías.

amplias.elaboradas.para.una.serie.de.textos.

Presentamos .a.continuación, .y.a.modo.de.ejemplo, .un.

extracto.

de.una.guía.de.lectura.

6.2. Un ejemplo de guía de lectura

UNIVERSIDAD.NACIONAL.DE…

FACULTAD.DE…

CARRERA.DE…

Cátedra:.

GUÍA.DE.LECTURA

TEXTO:

D

AVINI,.M..Cristina.(1995):.La formación docente en cuestión: política y peda-

gogía,.B s. .As.,.Paidós,.cap..4:.“Pedagogías.en.la.formación.de.los.docentes:.

problemas.de.la.formación.en.acción”.

La.presente.guía.intenta.acompañar.tu.lectura.del.capítulo.del.texto.arriba.

citado..La.autora.prologa.el.texto.afirmando.que.en.el.capítulo.4.“(…). se.mira.

hacia.el.interior.del.proceso.formativo.de.los.docentes.y.sus.desencuentros..El.

análisis.tiende.a.justificar.la.necesidad.de.reconstruir.una.pedagogía.propia.para.', 'chunk 181');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 182, 'la.formación.y.el.perfeccionamiento.de.los.docentes,.como.criterios.sustantivos.

de.pensamiento.y.acción”.

Es.así.que.el.capítulo.que

.vas.a.leer.comienza.anticipando.esta.cuestión..

Fijate.que.en.el.segundo.y.tercer.párrafo,.las.referencias.a.“En.este.capítulo…”.

y.“Este.capítulo.se.focalizará…”. la.autora.está.anticipando.el.eje.desde.el.cual.

tenés.que.interpretar.el.planteo.que.va.a.realizar.

Después.de.ello,.hay.una.referencia .explícita .a.ciertos.problemas .que.

habitualmente . plantean . los. docentes . en. los. procesos . formativos . y. de..

p

erfeccionamiento..Es.importante.que.puedas.enumerar.esos.problemas.pero.no.

te.quedes.prendido.de.ellos.de.manera.aislada.porque.el.objetivo.del.capítulo.es.

plantearlos.desde.el.eje.de.la.vinculación.entre.la.‘teoría’.y.l

a.‘práctica’..Estás.en.

la.página.100.y.a.lo.largo.de.ella,.se.está.anticipando.este.desarrollo..

En.la.página.101,.no.pases.por.alto.el.párrafo.en.el.cual.se.explica.que:.“La.

tesis.que.apoya.las.reflexiones.de.este.capítulo…”. .La.autora.sigue.insistiendo.

 109Más.didáctica.(en.la.educación.superior)

en.la.necesidad.de.pensar.una.pedagogía.propia.de.la.formación.docente.y.', 'chunk 182');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 183, 'siempre.es.bueno.tener.claro.desde.qué.supuestos.el.autor.escribe.

Podemos.pasar,.al.subtítulo.“La.crítica.a.la.racionalidad.técnica…”.. Aten-

ción

.ahora..Para.nosotros,.lo.que.sigue,.es.lo.más.importante.del.capítulo..La.

autora.va.a.plantear.una.“epistemología.de.la.práctica”.(acordate.que.leíste.

en.Schön.esa.acepción)..Es.decir,.mostrará,.por.lo.menos.dos.concepciones.

diferentes.referidas.a.la.práctica.y.su.vinculación.con.el.conocimiento..Tras.la.

introducción.y.su.referencia.histórica.a.las.universidades.y.las.instituciones.de.

formación.docente,.en.la.página

.103.comienza.a.caracterizar.la.concepción.de.

la.práctica.desde.la.racionalidad.técnica..

Acá.tenés.que.detenerte.si.no.tenés.claro.el.término.‘racionalidad’.y.es.nece-

s

ario.que.despejes.tus.dudas.leyendo.algo.extra..Esperá,.no.te.asustes,.que.no.se.

trata.de.algo.inaccesible.o.muy.voluminoso..Podés.buscar.en.Giroux,.Carr.y.Kem-

m

is.o.Popkewitz..Igual.te.damos.una.pista.desde.Giroux.que.la.explica.como:.

“(…) .un.conjunto.específico.de.asunciones.y.prácticas.sociales.que.

mediatizan.la.forma.en.que.los.individuos.o.grupos.se.relacionan.', 'chunk 183');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 184, 'con.el.resto.de.la.sociedad..Bajo.cualquier.forma.de.racionalidad

.

existe.un.conjunto.de.intereses.que.definen.y.cualifican.la.forma.en.

que.uno.refleja.el.mundo..Se.trata.de.un.elemento.de.gran.impor-

tancia

.epistemológica..El.conocimiento,.creencias,.expectativas.y.

bases.que.definen.una.racionalidad.dada.condicionan.y.a.su.vez.se.

encuentran.condicionadas.por.las.experiencias.en.las.que.vivimos..

La.noción.de.que.cada.experiencia.sólo.toma.sentido.específico.

desde.un.modo.de.racionalidad.que.le.confiere.inteligibilidad.es.

de.crucial.importancia”.(Giroux,.1981).

¿Te.quedan.ganas.de.profundizar.esto?.Bueno….podés.ir.a.las.fuentes:

GIROUX,.H..(1980):.“Critical.theory.and.rationality.in.citizenship.Education”,.

Currículo Inquiri 10. (4),. pp.329-366.

CARR,.W..y.KEMMIS,.S..(1988):.Teoría crítica de la enseñanza ,.B arcelona,..

Martinez

.Roca.

POPKEWITZ, .T..(1988):.Paradigma e ideología en investigación educativa , ..

Madrid,

.Mondadori..

Tranquilizate.y.no.creas.que.te.estamos.cargando… .el.texto.de.Giroux.

está.en.la.WEB.

¿Volvemos.a.lo.nuestro?.Estábamos .en.la.página.103.y.las.caracterís-

t', 'chunk 184');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 185, 'icas.de.la.‘práctica’.desde.la.racionalidad .técnica. .Fijate.que.la.autora .se.

detiene.especialmente .en.el.caso.de.la.formación .docente.y.explica.cómo.la.

tradición .eficientista .neutralizó .a.la.tradición .academicista .desde.la.lógica.

de.esta.racionalidad .técnica..Hummm… .acordate.que.el.tema.de.las.tradi-

c

iones.la.autora.lo.plantea.en.el.capítulo.1,.no.vale.preguntar.¿

qué.es.eso.

de.las.tradiciones?

En.la.página.105.empieza.a.aparecer.la.contracara,.es.decir,.una.concepción.

de.la.práctica.desde.otra.lógica.diferente.al.de.la.racionalidad.técnica,.sobre.todo.

en.la.referencia.a.Schön..No.le.da.la.autora.un.nombre.específico..Sería.bueno.

que.intentes.armar.un.cuadro.comparativo.porque.van.a.aparecer.características.

importantes.más.adelante.también..Nosotros.te.proponemos.las.variables.y.vos.

lo.vas.completando.(si.querés,.claro…. es.para.que.sistematices.las.dos.líneas.

de.pensamiento.no.para.que.nos.entregues.nada.a.nosotros):.

110. Capítulo.2. .El.método.y.los.recursos.didácticos

la.lógica.de.la.

RACIONALIDAD.

TÉCNICA

Otras

.LÓGICAS

Concepción.de.la.práctica.

como.campo

Concepción.de.la.realidad

Características.de.los.problemas.', 'chunk 185');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 186, 'de.la.práctica

Resolución.de.los.problemas.de.

la.práctica

Relación.entre.práctica.y.

aprendizaje

E

l.siguiente.subtítulo.no.es.para.que.lo.saltees.(“Disciplina.y.currículum.

formativo”).pero,.por.lo.menos.a.nosotros,.no.nos.interesa.que.te.detengas.

especialmente.en.ese.tema,.porque.en.el.subtítulo.siguiente.(“La.recuperación.

de.la.práctica:.¿un.proceso.adaptativo?”),.el.que.está.en.la.página.109,.hay.otra.

cuestión.que.creemos.relevante.y.en.la.que.vale.la.pena.demorarse.(eso.significa:.

leer.con.atención.y.más.d

e.una.vez.cada.párrafo)..Tras.las.primeras.aclaraciones.

referidas.a.la.importancia.de.la.reflexión.sobre.la.práctica.y.la.entrada.temprana.

en.el.terreno.escolar.durante.el.proceso.formativo.de.la.docencia,.en.la.página.

111.la.autora.empieza.a.plantear.algunas.señales.de.alerta.referidas.a.ciertos.

‘reduccionismos’.a.la.hora.de.pregonar.la.necesidad.de.‘aprender.de.la.práctica’..

A.partir.del.párrafo.que.comienza.con.“Sin.embargo,.una.primera.mirada…”.

(seguimos.en.la.página.111.pero.ésto.se.extiende.hasta.la.114),.sería.bueno.que.

sistematices.cada.uno.de.esos.reduccionismos.a.los.que.se.

refiere.la.autora..', 'chunk 186');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 187, 'Estamos.ahora.en.el.subtítulo.“Refinando.la.noción.de.práctica”..Fijate.

que.el.segundo.párrafo.(“La.perspectiva.de.la.práctica…”) .hay.una.apuesta.

fuerte.a.la.dimensión.ético-política .de.la.enseñanza..Volvé.sobre.la.idea.de.

‘racionalidad’.y.vas.a.ver.que.eso.se.entiende.mucho.mejor..Todo.este.subtítulo,.

en.definitiva,.se.refiere.a.ello.

¿Qué.ya.estás.cansado/a?.Nooooo…. no.cortes.la.lectura.aquí.que.ahora.

viene.el.broche.final..

Mirá,.ya.estás.en.la.página.116.frente.al.subtítulo.“Reubicando.la.teoría.

y.la.práctica:.marcos.conceptuales.incorporados,.elaborados.y.actuados”,.sí,.

tenés.razón,.¡qué.

nombre.para.un.subtítulo!

¿Vas.leyendo?.No.pases.por.alto.el.párrafo.que.empieza.con.“Tales.eviden-

cias

.muestran…”. (está.al.final.de.la.página.117).porque.a.partir.de.allí.y.hasta.

el.final.está.planteando,.a.modo.de.conclusión,.su.manera.de.ver.la.vinculación.

entre.la.teoría.y.la.práctica..

Hay.una.perlita.en.la.página.119.referida.a.la.didáctica..El.libro.es.de.1995,.

eso.significa.que.hace.más.de.diez.años,.Davini.ya.advertía.un.reclamo.que.aún.

hoy.sigue.haciéndole.al.campo..

 111Más.didáctica.(en.la.educación.superior)', 'chunk 187');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 188, 'Bueno,.una.última.intromisión.antes.que.pases.a.otra.cosa..Es.un.capítulo.

para.leer.con.atención.y.no.como.uno.más.dentro.de.la.bibliografía.de.la.cáte-

dra.

.Viste.que.dedicamos.toda.una.unidad.a.las.vinculaciones.entre.didáctica,.

prácticas.docentes.y.práctica..Bueno…. este.capítulo.es.central.dentro.de.este.

juego.de.relaciones.

7. Las rutas conceptuales

7.1. Características de las rutas conceptuales

Las.dificultades.que.presentan.nuestros.alumnos/as.para.leer.

textos.académicos.(por.ellos.mismos.manifestado).nos.han.lle-

vado

.a.pensar.el.algún.otro.tipo.de.recurso.que.permita.orientar.

la.identificación.de.las.categorías.conceptuales.que.presenta.un.

autor..Si.bien.las.g

uías.de.lectura.también.nos.sirven.para.tal.

propósito,.buscamos.un.recurso.que.pudiéramos.elaborarlo.más.

rápidamente.y.no.se.presentara.como.tan.‘guiado’..

Desde.esa.necesidad.y.conscientes.de.los.‘pro’.y.también.de.

los.‘contra’.que.puede.ocasionar.un.recurso.que.‘intervenga’.

en.la.lectura.que.un.alumno/a.hace.del.texto,.pensamos.en.las.

rutas conceptuales.

Una

.ruta.conceptual.presenta.de.forma.narrativa.una.sinté-

tica

.organización.del.texto.y.lista.su.secuencia.conceptual.enu-', 'chunk 188');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 189, 'merando

.las.categorías.conceptuales.relevantes.presentes.en.el.

mismo..Ciertamente.este.listado.es.elaborado.por.nosotros,.de.

modo.que.la.‘relevancia’.tiene.que.ver.con.lo.que.s

ubjetivamente.

consideramos.como.tal..Y.no.es.más.que.eso,.sólo.un.listado.

¿En.qué.circunstancias.podemos.utilizar.rutas conceptuales? .

Las.respuestas.son.similares.a.las.que.hemos.presentado.para.

las.guías.de.lectura..Pero.específicamente:

-. cuando.“la.comprensión.de.lo.leído.es.muy.pobre.porque.

refleja.la.dificultad.de.seguir.su.argumentación,.en.ausencia.

de.un.esquema.interpretativo.propio..Los.alumnos.carecen.

de.cierta.información.que.estos.textos.dan.por.sabida..Sin.

un.marco.conceptual, .el.lector-alumno.no.logra.sostener.

la.necesaria.perseverancia .de.leer.y.releer.para.entender”..

(Carlino,

.2002);

112. Capítulo.2. .El.método.y.los.recursos.didácticos

-. cuando.los.alumnos/as.manifiestan.serias.dificultades.para.

identificar.las.categorías.conceptuales.de.un.texto;

-. cuando.la.complejidad.del.texto.puede.hacer.que.el.lector/a.se.

‘pierda’.en.el.eje.de.desarrollo.y.descarte.por.incomprensible.

en.su.primera.lectura.algunas.categorías.que.pueden.resultar.', 'chunk 189');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 190, 'comprensibles.en.una.lectura.más.analítica;

-. cuando.la.complejidad.del.vocabulario.específico.puede.hacer.

que.el.lector/a.diluya.en.una.misma.idea.global,.diferentes.

categorías.conceptuales.específicas.

Ante.dificultades.como.éstas.o.similares,.nuestra.interven-

c

ión.a.partir.de.la.presentación.de.un.recurso.didáctico.como.

éste,.es.una.forma.de.apoyar,.con.materiales.específicamente.

pensados.para.l

os.alumnos/as,.nuestras.intervenciones.de.ense-

ñanza.

.

Pero.no.podemos.obviar.hacer.alguna.referencia.a.las.difi-

c

ultades.que.puede.ocasionar.el.uso.continuo.de.rutas.con-

c

eptuales..Si.bien.una.ruta.conceptual.intenta.ser.un.listado.

enumerativo.de.todas.las.categorías.conceptuales.presentes.en.

aquello.que.se.propone.para.la.lectura,.la.mediación.del.docente.

no.deja.de.ser.una.intromisión.en.el.contacto.necesario,.genuino.

y.personalísimo.que.un.lector.puede.y.debe.tener.con.un.texto..

Identificamos.como.problema,.que.las.rutas.conceptuales:

-. ‘digitan’.y.‘manipulan’.la.lectura.en.tanto.indican.qué.con-

ceptos

.son.los.que.hay.que.identificar.en.

la.lectura;

-. impiden.que.el.lector/a.realice.su.propio.recorrido.por.el.

texto;

-', 'chunk 190');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 191, '. limitan.la.necesaria.‘sorpresa’.de.quien.lee.y.se.siente.atrapado.

por.lo.que.personalmente.descubre.a.medida.que.lee;

-. generan.un.distanciamiento.entre.el.lector/a.y.el.texto.por.la.

‘interferencia’.de.un.lector/a.anterior.(el.docente).

7.2. Un ejemplo de ruta conceptual

Hechas.las.salvedades.necesarias,.he.aquí.un.ejemplo.de.una.

ruta.conceptual:

 113Más.didáctica.(en.la.educación.superior)

TEXTO:.

STEIMAN,.Jorge.(2004):.¿Qué debatimos hoy en la Didáctica?: Las prácticas 

de enseñanza en la educación superior, .Bs..As.,.Baudino.Ediciones,.cap..4:.“La.

narrativa.en.la.enseñanza..Bienvenidos.a.Kokura:.de.un.relato.que.entrama.

relatos.pensando.acerca.de.la.narrativa.en.el.campo.de.la.didáctica”.

RUTA.CONCEPTUAL

Organización del texto: .el.capítulo.en.cuestión.relaciona.la.noción.de.narrativa.

y.enseñanza.desde.las.hipótesis.de.P ..Jackson.y.S..Gudmundsdottir.a.partir.de.

las.cuales.se.realiza.un.libre.recorrido.por.cuestiones.vinculadas.a.la.estructura.

narrativa.del.discurso.docente.

Secuencia conceptual: .

-. noción.de.narrativa,.

-. relación.entre.narrativa.y.vida.cotidiana,

-. relación.entre.narrativa.y.enseñanza,', 'chunk 191');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 192, '-. funciones.de.los.relatos.y.enseñanza:.f

unción.epistemológica.y.función.

transformadora.(Jackson),

-. función.epistemológica:.argumentación.en.contra.del.uso.del.concepto.de.

‘transposición.didáctica’,

-. función.epistemológica:.naturaleza.narrativa.del.saber.pedagógico.sobre.

los.contenidos,.

-. relación.entre.función.transformadora.y.asignación.moral,.

-. argumentación .referida.a.la.indiferenciación .de.ambas.funciones .en.el.

aula,

-

. relación.entre.funciones.de.los.relatos.y.el.uso.de.ejemplos.en.el.aula,.

-. relación.entre.el.uso.de.relatos.y.análisis.de.las.prácticas,

-. categorías.de.Schulman.aplicadas.al.análisis.de.las.prácticas.

8. Los casos

8.1. Características de los casos

Un.caso.es.un.relato.de.tipo.narrativo.referido.a.algún.acon-

t

ecimiento.real.o.h

ipotético.que.se.presenta.con.suficiente.infor-

mación

.contextual.como.para.poder.apropiarse.del.mismo.‘casi.

como.si.lo.estuviera.observando.en.una.película’..La.información.

de.referencia.incluye.datos.y.descripción.de.hechos.y.persona-

jes

.y.se.presenta.en.torno.a.alguna.problemática.central,.en.lo.

posible.extraída.de.problemas.de.la.vida.real.', 'chunk 192');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 193, 'El.caso,.así.presentado,.es.analizado.y.‘desmenuzado’.en.sus.

partes.constitutivas.para.poder.facilitar.el.estudio.de.la.proble-

114. Capítulo.2. .El.método.y.los.recursos.didácticos

mática.que.involucra,.a.partir.de.las.preguntas.que,.presentadas.

después.del.relato.del.caso,.orientan.el.análisis..Por.supuesto.

que.estas.preguntas.no.se.refieren.ni.a.la.información.misma.que.

el.caso.presenta,.ni.a.otro.tipo.de.información.presente.en.los.

textos.ya.que.el.objeto.de.las.mismas.no.es.propiciar.el.recuerdo.

de.la.información.presentada.sino.favorecer.la.actividad.com-

pr

ensiva.para,.fundamentalmente,.realizar.un.análisis.profundo.

a.partir.de.la.puesta.en.uso.de.la.información.que.ya.debe.estar.

disponible.para.su.aplicación.por.parte.de.los.alumnos/as..

Los.modos.de.organizar.la.c

lase.para.el.trabajo.con.casos.

son.tan.variados.como.iniciativas.podamos.tener.al.respecto:.

trabajo.individual.de.análisis.a.partir.de.las.preguntas.que.el.

caso.plantea,.sesiones.de.discusión.grupal.del.caso.y.puestas.

en.común.dentro.del.grupo.grande,.etc..Para.Selma.Wassermann.

(1999),.un.buen.trabajo.con.casos.requiere:.presentar.un.caso.de.', 'chunk 193');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 194, 'buena.calidad,.formular.preguntas.críticas,.trabajar.en.pequeños.

grupos,.orientar.la.discusión.grupal,.ayudar.a.los.alumnos/as.a.

realizar.análisis.agudos.de.los.diversos.problemas.involucrados,.

inducirlos.al.esfuerzo.para.obtener.una.comprensión.profunda.y.

proponer.actividades.de.ampliación.de.la.información.presentada.

en

.el.caso..

¿Y.qué.determina.para.Wassermann.la.calidad.de.un.buen.

caso?:

-

. la.concordancia.entre.las.ideas.importantes.del.caso.y.los.

contenidos.curriculares.que.con.él.se.deseen.trabajar;.

-. una.buena.escritura.del.relato,.de.modo.tal.que.logre:.atrapar.

al.lector;.permitir.que.desde.la.base.descriptiva.presente.en.

el.relato.el.lector/a.pueda.formarse.una.imagen.mental.de.las.

personas,.los.lugares.y.los.acontecimientos;.asegurar.que.

el.lector/a.pueda.identificarse .con.los.personajes.y.sentir.

algo.por.ellos;.poseer.un.argumento.realista.y.una.trama.

equilibrada.entre.la.alta.complejidad.que.puede.hacer.densa

.

la.lectura.y.la.extrema.sencillez.que.la.puede.tornar.intras-

cendente;

-

. una.‘lecturabilidad’.accesible.que.permita.a.los.alumnos/as.

comprender.el.lenguaje,.descifrar.el.vocabulario.y.encontrarle.', 'chunk 194');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 195, 'sentido.a.la.lectura;

 115Más.didáctica.(en.la.educación.superior)

-. la.presencia.de.argumentos.en.la.trama.que.produzcan.algún.

impacto.emocional.y.hagan.poner.en.juego.los.sentimientos.

de.los.alumnos/as;

-. la.acentuación.del.dilema.a.medida.que.la.narrativa.se.desa-

r

rolla,.es.decir,.un.relato.que.más.que.finalizar.con.la.solución.

a.la.problemática.que.se.ha.ido.planteando,.por.el.contrario,.

concluye.con.más.interrogantes.que.afirmaciones;.

-. la.intensificación.de.la.tensión.entre.puntos.de.vista.conflic-

tivos.

En

.síntesis,.un.caso,.es.un.recurso.caracterizado.por:

-. un.relato.descriptivo.amplio.en.el.que.se.presentan.lugares,.

personajes.y.acontecimientos.que.intenta.implicar.cognitiva.

y.emocionalmente .a

l.lector/a .y.posicionarlo .frente.a.un.

dilema;

-

. una.serie.de.preguntas.críticas.que.se.formulan.tras.el.relato.

y.que.orientan.la.discusión.y.análisis.del.caso;.

-. un.trabajo.posterior.de.tipo.analítico.en.el.que.se.aplican.

saberes.y.procedimientos, .y.que.ocasionalmente, .puede.

requerir.de.nueva.búsqueda.de.información;.

8.2. Ejemplos de casos

He.aquí.dos.ejemplos.de.casos..El.primero.lo.hemos.cons-

t', 'chunk 195');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 196, 'ruido.especialmente.para.trabajar.un.contenido.curricular.deter-

m

inado,.mientras.que.el.segundo.es.la.descripción.de.un.caso.

real.que.nos.han.pasado.dos.colegas:

EL.AULA.8

Cuando.escuchó.lo.impensado .en.la.voz.de.María.Inés,.un.sudor.frío.

comenzó.a.recorrerle.la.espalda,.desde.la.primera.cervical.hasta.el.coxis..Quedó.

atónito.y.tieso,.como.una.imagen.congelada.en.el.tiempo,.como.una.estatua.de.

mármol..Se.miró.a.sí.mismo.y.se.vio.flaco.y.desgarbado,.con.esa.carpetita.rosa.

y.de.hojas.amarillentas.bajo.el.brazo.y.tampoco.pudo.recomponerse..

María.Inés,.la.encargada.de.dar.a.los.profesores.las.listas.de.asistencia.y.la.

asignación.de.Comisiones.elaboradas.por.el.Departamento.de.Ingreso,.Obser-

vación

.y.Seguimiento.(DIOS),.le.preguntó.tímidamente:

–.¿Le.

pasa.algo.profesor?

Él.lo.negó.con.un.suave.movimiento.de.cabeza.y.volvió.a.sentir.como.un.

puñal.filoso.la.voz.de.María.Inés.reiterándole:

116. Capítulo.2. .El.método.y.los.recursos.didácticos

–.Aula.8

El.aula.8.es.la.única.aula.de.toda.la.Facultad.en.la.cual.se.colocan.160.

bancos.universitarios..El.aula.8.se.usa.para.la.‘Comisión.que.se.desangra’.como.', 'chunk 196');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 197, 'todos.llaman.a.la.Comisión.de.ingreso.que.se.forma.con.los.anotados.a.último.

momento,.habitualmente.integrada.por.los.que.‘se.anotan.para.tener.algo.que.

hacer’.o.porque.los.padres.los.obligan.hartos.de.su.vagancia.o.inanición,.según.

mejor.que.nadie,.María.Inés.suele.contarlo..

Nunca.nadie.supo.explicar.por.qué,.dadas.esas.difíciles.características.que.

componían.la.Comisión,.se.los.colocaba.todos.juntos.e

n.la.única.aula.que.

albergaba.160.almas,.mientras.que.en.las.restantes,.las.Comisiones.del.ingreso.

no.superaban.los.45.o.a.lo.sumo.50.miembros..

El.profesor.Pelatelli.es.profesor.de.Psicología.y.hace.más.de.ocho.años.que.

tiene.a.su.cargo.la.Psicología.General.del.primer.cuatrimestre.del.ingreso,.pero.

nunca,.hasta.ahora.nunca,.le.había.tocado.el.aula.8..

Osvaldo,.así.lo.llaman.los.alumnos.al.Doctor.Pelatelli,.no.tiene.muchas.

variantes.para.dar.su.clase:.tras.el.saludo.inicial,.suele.anticipar.la.temática.del.

día.y.la.presenta.con.su.voz.ronca.sentado.sobre.l

a.tabla.del.escritorio..Nunca.se.

lo.ha.visto.utilizar.ni.siquiera.el.pizarrón..Sólo.su.voz.que.cambia.enfáticamente.

el.tono.según.la.importancia.de.lo.que.esté.explicando,.sólo.sus.gestos,.que.se.', 'chunk 197');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 198, 'tornan.grandilocuentes.y.exacerbados.cuando.pretende.plantear.interrogantes,.

sólo.sus.manos,.que.se.deslizan.sobre.imaginarios.contornos.físicos.dibujados.

en.el.aire.cuando.quiere.llamar.la.atención…

Pero.una.cosa.es.hablar.cuatro.horas.y.mirar.a.50.pares.de.ojos.y.otra.muy.

distinta.es.exponer.en.el.aula.8..Allí,.el.ruido.de.los.autos.y.colectivos.de.la.

calle.retumban.más.que.en.ningún

.lado,.allí,.ninguna.voz.(ni.aún.las.voces.que.

no.son.roncas).logran.escucharse.más.allá.de.la.undécima.u.duodécima.fila,.allí.

no.se.puede.caminar.entre.los.bancos.porque.no.queda.ningún.pasillo,.allí.los.

que.se.sientan.de.la.fila.trece.para.atrás.murmuran,.hablan.entre.sí,.mandan.

mensajes.de.texto.desde.sus.celulares.todo.el.tiempo,.todo.el.maldito.tiempo,.

las.horas.que.transcurran.hasta.que.el.profesor.tome.lista,.allí.media.clase.se.

irá.sin.importarle.nada.después.de.haber.dado.la.asistencia.sea.la.hora.que.sea,.

sea.el.tema.que.sea,.sea.

lo.que.sea.

Osvaldo.lo.pensó.una.vez.más:.el.aula.8,.¿vale.la.pena?.y.dando.media.

vuelta.sin.saludar.a.María.Inés,.se.encaminó.para.el.aula.8.

Serían.no.menos.de.150..Mitad.y.mitad.entre.varones.y.mujeres,.edad.prome-

d', 'chunk 198');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 199, 'io.18.o.19.años..Después.del.segundo.parcial.se.desangra,.pensó..Para.el.segundo.

parcial.faltan.unas.doce.clases,.pensó..¿Cuál.era.el.primer.tema?.se.preguntó.

Miró.las.cinco.hojas.que.conformaban.la.planilla.de.asistencia,.presen-

tada

.prolijamente.por.orden.alfabético..Muchos.nombres.y.apellidos.que.no.le.

decían.nada..Salteó.con.la.vista.los.renglones:.Canto,.Patricia;.G

arcía,.Silvia;.

Gianastasio,.Hugo;.Jordan,.Ana;.Martínez,.Pablo;.Saman,.José…. Saludó.a.los.

de.las.primeras.filas.e.intentó.presentar.su.materia..Un.coro.multitudinario.de.

ringtones.acompañó.melódicamente.a.su.voz.ronca.en.las.primeras.tres.frases;.

un.murmullo.rumiante.se.sumó.a.partir.de.la.cuarta.frase;.una.cumbia.latosa.

comenzó.a.sonar.en.la.calle.y.se.coló.por.cada.una.de.las.hendijas.de.los.grandes.

ventanales.a.partir.de.la.décima.frase..

Quizás.fueran.algo.más.de.150..Mitad.y.mitad.entre.ingresantes.nova-

tos

.e.ingresantes.con.fracasos.anteriores,.nota.promedio.del.secundario.5.76,.

todo.debidamente

.registrado.en.la.lista.de.asistencia.por.el.Departamento.de.

Estadística..Seis.años.de.estudio.para.recibirme.de.Psicólogo,.pensó..Cuatro.', 'chunk 199');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 200, 'años.de.Maestría.y.otros.tantos.de.Doctorado,.pensó..¿Cuantos.años.llevo.en.

la.docencia?,.se.preguntó.

 117Más.didáctica.(en.la.educación.superior)

Pudo.haber.recurrido.al.Departamento.Académico.para.tratar.de.encontrar.

allí.algún.registro.de.otro.docente.que.habiendo.pasado.por.el.aula.8.narrara.

sus.vivencias..Pero,.todos.sabían.que,.en.verdad,.las.publicaciones.del.Departa-

mento,

.tenían.más.sentido.de.marketing.que.de.registro.documentado..

A.primera.vista.eran.como.200..“Dr..Pelatelli.a.lo.largo.del.presente.año.

Ud..deberá.publicar.tres.artículos.en.la.Revista.de.la.Universidad.y.brindar.un.

mínimo.de.dos.conferencias.en.eventos.académicos.organizados.por.la.Facultad.

donde.Ud..se.desempeña.a.los.efectos.de.mantener.la.designación.de.Titular.con.

que.fuera.n

ombrado..Atentamente..Departamento.Administrativo-Docente”,.

leyó.en.la.breve.esquela.que.en.sobre.cerrado.el.Departamento.le.entregaba.

junto.a.la.lista.de.asistencia..Mitad.y.mitad.entre.los.que.seguramente.aprueben.

y.los.que.no,.pensó..Nota.máxima.en.los.parciales.un.6,.pensó..¿Cómo.hago.

para.dar.clase.acá?.se.preguntó.

PREGUNTAS.Y.TAREAS.PARA.EL.ANÁLISIS:', 'chunk 200');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 201, '1.. ¿Cuáles.son.las.creencias,.prejuicios.y.representaciones.presentes.en.el.caso.

y.que.se.manifiestan.a.través.del.pensamiento.práctico.de.algunos.de.los.

actores?.

2.. ¿Qué.tipo.de.injerencia.pueden.tener.algunas.variables.institucionales.en.

la.práctica.docente?.Hipoteticen.la.relación.de.éstas.con.el.pensamiento.

práctico.del.docente.

3.. ¿Qué.obstáculos,.desde.el.pensamiento.práctico.del.docente,.pudieron.

haberle.impedido.a.él.mismo.encontrar.algún.tipo.de.respuesta.didáctica.

al.dilema.que.la.propia.situación.le.planteaba?.

4.. Realicen.una.propuesta.concreta.que.pueda.contestar.la.pregunta.que.se.

realiza.el.docente.al.final.del.relato..Fundamenten.l

a.propuesta.con.relación.

a.cada.una.de.las.variables.didácticas.que,.a.juicio.de.uds.,.intervienen.en.

el.caso.

3.y.4

EL.ESPACIO.DE.LA.PRÁCTICA.DOCENTE:.UNA.‘NUEVA’.‘HISTORIA’3.

El.instituto.superior.de.formación.docente.Nº.8004.es.una.institución.de.

gestión.estatal.creada.en.1981..Comparte.edificio.con.una.escuela.media,.razón.

por.la.cual.su.oferta.académica.sólo.es.vespertina..Cuenta.actualmente.con:

-. Profesorado.para.el.Nivel.Inicial.(una.comisión).

-. Profesorado.para.EGB.1.y.2.(dos.comisiones).', 'chunk 201');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 202, '-. Profesorado.en.Educación.Especial.(una.comisión).

-. Bibliotecología.(una.comisión).

Está.ubicado.en.el.primer.cordón.del.conurbano.bonaerense.y.atiende.una.

comunidad.conformada.básicamente.por.sectores.de.la.población.habitualmente

3. Agradecemos.a.las.Lic..Silvia.Bernatené.y.María.Silvia.Martini.que.nos.faci-

litar

on.este.caso.y.nos.ayudaron.a.construir.las.preguntas.para.su.análisis.

4. El. nombre . de. la. Institución . ha. sido. modificado . para. preservar . la.

confidencialidad.de.la.información.

118. Capítulo.2. .El.método.y.los.recursos.didácticos

denominado .como.de.‘bajos.recursos’,.con.dificultades .de.empleabilidad .y.

trayectorias.escolares.provenientes.de.modalidades.diversas.(escuelas.medias.

comunes.y.escuelas.medias.de.adultos).

En.su.planta.funcional.cuenta.con.un.cargo.de.director,.un.cargo.de.regente,.

un.cargo.de.secretario,.un.jefe.de.área.de.la.carrera.de.Profesorado.para.EGB.

1.y.2,.un.jefe.de.área.para.la.carrera.de.Profesorado.en.Educación.Inicial,.un.

bibliotecario.y.un.preceptor.por.cada.una.de.las.carreras..El.plantel.docente.

está.constituido.por.un.total.de.58.profesores.y.profesoras.entre.los.titulares,.', 'chunk 202');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 203, 'provisionales.y.suplentes,.el.100%.con.t

itulación.acorde.para.el.desempeño.

en.el.nivel.y.en.un.85%.aproximadamente .de.sexo.femenino. .La.matrícula.

aproximada.es.de.380.alumnos/as..

La.institución.cuenta.también.con.un.‘Centro.de.copiado’.que.adquiere.

cierta.relevancia.en.la.vida.institucional,.ya.que.es.frecuentado.asiduamente.

por.alumnos,.profesores.y.personal.de.dirección..La.relevancia.se.evidencia.

en.ciertas.tareas.cotidianas.de.la.vida.institucional:.en.el.centro.de.copiado.

los.preceptores.retiran.los.materiales.impresos.que.requieren.algunas.de.las.

tareas.administrativas;.los.profesores.obtienen.información.y.retiran.el.material.

necesario.para.la.inscripción.en.los.concursos.para.la.cobertura.d

e.cátedras;.

los.alumnos.fotocopian.los.textos.que.dejan.los.profesores.como.bibliografía.

obligatoria.de.sus.cátedras;.el.personal.directivo.imprime.cada.una.de.las.reso-

l

uciones.y.disposiciones.que.por.correo.electrónico.llegan.desde.los.organismos.

centrales..

La.institución.tiene.una.Asociación.Cooperadora.organizada.y.un.CAI.(el.

Consejo.Académico.Institucional),.integrado.por.el.director.y,.elegidos.por.sus.

pares,.tres.docentes.y.dos.alumnos..', 'chunk 203');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 204, 'Entre.las.problemáticas.institucionales.que.figuran.en.su.PEI,.se.identifican.

entre.otras,.las.siguientes:

-. déficit.en.la.circulación.de.la.información;

-. escasas.experiencias.de.trabajo.en.conjunto.de.los.docentes;

-. definiciones.no.orgánicas.de.s

istemas.de.diseño,.enseñanza.y.evaluación;

-. decisiones.individuales.de.los.docentes.en.la.definición.del.contenido.a.

enseñar.y.del.sistema.de.evaluación,.acreditación.y.promoción.

El.nuevo.equipo.de.gestión,.que.está.a.cargo.desde.hace.cinco.años,.es.

estimulador.de.iniciativas.que.promuevan.la.participación,.pero.la.Institución.

tiene.una.larga.tradición.de.bajo.compromiso.al.respecto..Su.trayectoria.da.

cuenta.de.la.inexistencia.histórica.de.algún.tipo.de.organización.de.los.alum-

nos/as,

.tal.como.centro.de.estudiantes,.delegados.de.curso,.o.parecidos,.y.de.

asistencia.de.los.docentes.a.plenarios.o.reuniones.sólo.ante.citaciones.de.la.

dirección..El

.CAI,.que.funciona.desde.hace.cuatro.años,.no.representa.los.inte-

r

eses.de.las.partes.que.cada.uno.de.sus.miembros.representa,.sino.más.bien,.

se.constituye.como.un.organismo.colegiado.de.asesoramiento.a.la.dirección.', 'chunk 204');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 205, 'sobre.las.temáticas.que.desde.allí.se.presentan..

La.provincia.de.Buenos.Aires,.como.las.restantes.jurisdicciones,.ha.iniciado.

desde.el.año.1999.aproximadamente,.un.complejo.camino.de.acreditación.de.

sus.institutos.de.formación.docente.a.partir.del.cumplimiento.de.los.criterios.

acordados.federalmente.y.que.han.impulsado.a.las.instituciones.a.pensar.y.

realizar.acciones.que.hasta.entonces.no.eran.prioritarias:.articulaciones.con.

las

.Universidades,.el.diseño.y.puesta.en.marcha.de.proyectos.de.investigación,.

la.definición.de.algunos.acuerdos.que.se.plasmen.en.proyectos.institucionales,.

acciones.de.capacitación .para.sus.docentes, .etc..Este.‘nuevo’.movimiento.

institucional.ha.generado.nuevas.formas.de.intervención.de.los.integrantes.en.

la.institución,.antes.limitado.al.exclusivo.‘dictado’.de.las.clases..

 119Más.didáctica.(en.la.educación.superior)

En.la.planta.docente.conviven.en.igual.proporción.un.grupo.de.docentes.

‘históricos’,.como.ellos.mismos.suelen.nominarse,.es.decir.profesores/as.que.

ingresaron.a.la.Institución .en.la.primera.década.de.su.funcionamiento .con.

otros.que.se.han.integrado.en.los.últimos.tiempos..Algunos.de.ellos.(unos.diez.', 'chunk 205');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 206, 'docentes).son.de.los.‘fundadores’,.aunque.la.mayoría.de.este.subgrupo.ha.ini-

ciado

.sus.trámites.jubilatorios..Esta.marcada.diferenciación,.nunca.explicitada,.

es.una.de.las.mayores.‘rupturas’.que.se.visualizan.en.la.Institución:.mientras.

los.‘históricos’.adoptan.comportamientos.de.mantenimiento.del.status.quo.

institucional .–que.fuera.marcado.muy.fuertemente .por.la.gestión.a

nterior,.

promotora.de.la.creación.del.instituto.y.acuñadora.de.un.estilo.autoritario-

paternalista.que.aún.hoy.caracteriza.la.cultura.institucional–.y.su.formación.

(y.actualización).académica.se.circunscribe.a.lo.que.ha.sido.su.tránsito.por.

profesorados .o.la.universidad .durante.sus.estudios.de.grado,.los.docentes.

más.‘nuevos’.se.caracterizan.por.la.identificación.con.la.actual.gestión.y.por.

una.marcada.tendencia.a.continuar.estudios.de.Posgrado.y.a.compatibilizar.el.

trabajo.en.institutos.de.formación.docente.con.el.trabajo.en.las.cátedras.uni-

versitarias.

.Dentro.de.este.grupo,.los.pedagogos.(es.decir.aquellos.con.títulos.

de.Ciencias.de.la.E

ducación.o.afines).han.ido.construyendo.un.discurso.que.los.', 'chunk 206');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 207, 'posiciona.como.la.‘élite.intelectual’,.cuya.caracterización.más.evidente.se.da.por.

la.generación.del.debate.en.torno.a.nuevas.ideas.con.relación.a.la.organización.

curricular,.la.evaluación,.el.tratamiento.de.la.‘diferencia’.y.la.heterogeneidad.del.

alumnado.y.la.problematización.de.la.relación.entre.la.teoría.y.las.prácticas..

La.ruptura,.aún.sin.verbalización.explícita,.se.hizo.notar.en.algunas.de.las.

tramas.institucionales:.por.ejemplo,.a.la.hora.de.nominar.a.los.docentes.que.

podrían.beneficiarse.con.circuitos.de.capacitación.y/o.postitulación.gestados.

por.los.organismos.centrales.o.a.l

a.hora.de.alentar.el.diseño.de.proyectos.

especiales,.el.director.privilegia.la.presencia.de.los.profesores.‘nuevos’,.aun-

que

.más.como.garantía.de.cumplimiento.de.los.indicadores.de.la.acreditación.

institucional.que.como.motor.de.una.verdadera.innovación.curricular.al.interior.

de.la.institución..Conductas.de.este.tipo.hicieron.crecer.la.tensión.entre.los.

‘históricos’.y.los.‘nuevos’..En.la.sala.de.profesores.se.reiteran.comentarios.

como.este:.“¿Vos.te.enteraste.de.la.convocatoria.al.Proyecto.XXX?.En.el.libro.', 'chunk 207');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 208, 'de.comunicaciones.no.está.y.sin.embargo,.parece.que.‘Fulano’.sí.se.enteró….

no.sé.cómo.le.habrá.llegado

.el.dato…”. o.“.Me.tienen.cansada.con.tanto.‘bla.

bla’.teórico.si.los.alumnos.cada.vez.saben.menos”.

Esta.diferenciación .entre.los.profesores .‘históricos’.y.los.‘nuevos’,.se.

potencializa.en.la.unidad.curricular.“Espacio.de.la.Práctica.Docente”.ya.que,.

en.esta.materia.conviven,.con.un.buen.número.de.horas.a.cargo.casi.en.igual.

proporción,.parte.de.los.fundadores.más.relevantes.con.los.nuevos.que.han.ido.

accediendo.a.la.cátedra.por.vacancias.generadas.por.jubilaciones.

Aunque.en.la.Provincia.de.Bs..As..a.partir.de.las.nuevas.currículas.de.fines.

de.los.90,.se.le.dio.un.giro.importante

.a.las.‘prácticas.docentes’.introduciendo.

la.idea.de.la.práctica.como.espacio.de.aprendizaje.y.de.reflexión.más.que.como.

espacio.de.aplicación.teórica.y.de.evaluación,.esta.perspectiva.se.encarna.en.los.

‘nuevos’.como.novedad.curricular.y.se.vive.en.los.‘históricos’.como.una.nueva.

forma.de.prescripción.normativa.a.la.que.hay.que.atenerse.en.el.discurso.pero.

que.permite.‘seguir.haciendo.lo.que.siempre.hicimos’.en.los.hechos.', 'chunk 208');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 209, 'La.impronta.fundacional.de.la.institución.–en.orden.a.la.sumisión.a.los.

mandatos.de.los.reglamentos.y.las.prescripciones.de.los.organismos.centra-

l

es–.gestó.respuestas .inmediatas .en.el.‘

Espacio.de.la.Práctica.Docente’:.la.

necesidad.de.realizar.acuerdos.entre.docentes.de.una.misma.materia.y.plasmar.

dichos.acuerdos.en.documentos.escritos.se.concretó.en.la.construcción.de.un.

programa.(proyecto .de.cátedra).único.para.todos.los.docentes .del.espacio.

120. Capítulo.2. .El.método.y.los.recursos.didácticos

Estos.acuerdos.curriculares.no.pasaron.de.ser.acuerdos.para.‘los.papeles’,.ya.

que.el.programa.unificado.fue.elaborado.por.un.pequeño.grupo.de.los.‘nuevos’,.

liderados.por.el.jefe.de.área.del.profesorado.para.EGB.1.y.2..Mientras.tanto.la.

organización.y.la.línea.teórica.que.se.imprimía.a.las.prácticas.en.las.escuelas.

mostraban.a.los.‘históricos’.haciendo.lo.mismo.de.siempre:.una.impronta.

‘positivista’.dominaba.la.mirada.hacia.la.escuela.desde.la.‘observación’.de.

primer.año,.para.luego.acentuar.el.‘tecnicismo.instrumentalista’.y.cierto.‘nor-

malismo’

.moderado.en.las.prácticas.áulicas.de.segundo.y.tercer.año..Tampoco.

modificaron.s', 'chunk 209');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 210, 'us.soportes:.las.‘Guías.de.observación’,.y.la.‘Planilla.de.evaluación.

del.practicante’.estructuradas.como.listas.de.control.tanto.para.observar.como.

para.evaluar.a.los.alumnos/as.del.profesorado,.siguen.siendo.los.instrumentos.

usados.más.frecuentemente.

A.nivel.‘formal’,.esta.división.no.acarreó.mayores.problemas,.ya.que.la.

gestión.del.Instituto.se.caracteriza.por.respetar.las.ideas.y.posturas.de.los.

docentes.y.no.inmiscuirse.en.sus.decisiones.intracátedra..De.modo.que,.en.

algún.sentido,.todos.los.docentes.estaban.avalados.por.la.autoridad..Sus.deci-

siones,

.en.cualquier.caso,.eran.refrendadas.por.la.estructura.jerárquica.formal.

de.la.institución.

Así,.en.el.“Espacio.de.la.Práctica.Docente”.se.fue.evidenciando.la.forma-

ción

.de.dos.posturas.claramente.diferenciadas.en.los.hechos:.una.posicionada.

desde.un.enfoque.socio-antropológico,.tendiente.a.fomentar.la.‘reflexión.sobre.

la.práctica’,.y.otra.que.entendía.a.la.práctica.como.la.‘buena.aplicación’.de.la.

‘buena.teoría’.previamente.aprendida.(con.varias.posiciones.intermedias,.con.

zonas.‘grises’.entre.el.blanco.de.unos.y.el.negro.de.otros).', 'chunk 210');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 211, 'En.este.marco.de.situación,.a.comienzos.de.2006,.un.grupo.de.los.‘nuevos’.

del.“Espacio.de.la.Práctica.Docente”.junto.con.el.jefe.de.área.de.la.carrera.del.

profesorado.para.EGB

.1.y.2,.se.plantearon.profundizar.el.enfoque.de.reflexión.

sobre.la.práctica.a.partir.del.trabajo.con.narrativas.en.cada.uno.de.los.tres.años.

en.los.que.el.“Espacio.de.la.Práctica.Docente”.es.materia.en.la.carrera..

Convencidos.de.poder.lograr.acuerdos.válidos,.se.convoca.a.una.reunión.

antes.del.comienzo.de.las.clases,.en.el.período.de.exámenes..En.el.comienzo.

de.la.misma.se.solicita.que.cada.uno.explicite.la.forma.‘real’.en.que.trabaja.

desde.su.cátedra.a.fin.de.encontrar.los.puntos.en.común..Una.vez.más,.desde.

el.discurso,.todos.los.p

rofesores.parecen.estar.trabajando.en.la.misma.línea.

teórica.y.desde.el.mismo.enfoque.

La.presentación.del.trabajo.con.narrativas.no.ofrece.resistencias..Por.el.

contrario,.todos.los.docentes.acuerdan.formas.de.organización.del.trabajo.de.

los.alumnos/as.utilizando.una.secuencia.que.propone.comenzar.con.la.escritura.

(en.primer.año.con.el.‘diario.del.profesor’,.en.segundo.año.las.‘notas.de.campo.', 'chunk 211');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 212, 'comentadas’.y.en.tercer.año.los.‘registros.textuales’).para.continuar.con.el.taller.

de.socialización.de.las.escrituras.y.finalizar.con.el.taller.de.análisis.a.partir.de.

los.marcos.teóricos..

A.seis.meses.de.haber.acordado.la.propuesta.c

ada.uno.ha.seguido.haciendo.

lo.que.ya.venía.haciendo,.aún.los.‘nuevos’.

Mientras.tanto.los.alumnos/as.sólo.parecen.preocuparse.por.cumplimentar.

las.‘obligaciones’.académicas.que.les.requieren.los.profesores/as,.ya.les.haya.

tocado.cursar.con.uno.de.los.‘nuevos’.o.con.uno.de.los.‘históricos’.

 121Más.didáctica.(en.la.educación.superior)

PREGUNTAS.Y.TAREAS.PARA.EL.ANÁLISIS:

1.. “(…) .la.acción.institucional,.como.todo.comportamiento.social,.no.es.com-

pr

ensible.fuera.de.la.red.simbólica.que.lo.genera.y.del.universo.imaginario.

que.ella.misma.engendra,.dentro.de.un.campo.determinado.de.relaciones.

sociales,.en.el.contexto.determinado.de.una.cultura”.(Garay,.2000)..

Desde este marco teórico, ¿cómo analizan el devenir de la cultura 

institucional que se relatan en el caso?

2.

. Las.escuelas,.en.general,.son.instituciones.complejas.que.contienen.también.

a.‘sistemas.simbólicos.complejos’.(Duschatzky,.2005).Escenarios.transita-', 'chunk 212');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 213, 'dos

.por.distintos.actores,.que.conforman.una.gramática.escolar.fruto.de.

vinculaciones.para.la.producción.dentro.de.la.institución.y.de.representacio-

nes

.subjetivas.de.cada.uno.de.sus.miembros..Espacio.y.tiempo.de.la.regla,.

la.norma,

.lo.instituido;.y.también.lugar.del.acontecer,.del.movimiento,.de.

lo.singular,.lo.instituyente..

Desde este marco teórico, ¿qué tipo de vínculos en las tramas institucionales 

aparecen como obstáculos en el marco de las relaciones directivos-docentes-

alumnos/as?

3.

. Aparece.como.‘paradojal’.una.representación.de.la.institución.en.la.memoria.

de.los.actores.institucionales.(profesores).como.un.‘colectivo.institucional’.

nuclearizador.(Garay,.2006a),.y.la.realidad.que.muestra.la.fragmentación,.la.

unilateralidad.en.la.toma.de.decisiones.de.cada.cátedra.y.la.vivencia.también.

escindida.que.manifiestan.vivir.los.alumnos.desde.el.cumplimiento.de.los.

requerimientos.de.cada.profesor.para.su.materia..Este.efecto.paradojal.tam-

b

ién.se.evidencia.en.una.‘imagen’.institucional.entramada.y.coherente.desde.

lo.‘instituido’,.roles.y.funciones.desde.lo.institucional-pedagógico.b

ien.', 'chunk 213');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 214, 'estructurados,.organizando.a.partir.de.allí.la.“trama.de.relaciones.sociales.

de.trabajo”.(Garay,.2006b),.y.las.divisiones.y.conflictos.su rgidos. al.analizar.

los.vínculos.que.los.profesores.entablan.a.partir.de.la.intersubjetividad,.

cuando.se.deben.recorrer.trayectos.profesionales.que.impliquen.tomar.

decisiones.consensuadas.y.compartidas..

Desde este marco teórico, ¿cómo analizan en el relato la relación entre 

lo instituido y lo instituyente?

4.

. Los.cambios.en.las.instituciones.suponen.el.reconocimiento.de.una.real.

‘necesidad’.y.el.despertar.de.ciertas.‘demandas’.en.el.colectivo.institucional,.

como.intención.de.búsqueda,.de.‘deseo’.(Garay,.2000).

Desde este marco teórico, ¿cómo analizan lo acontecido ante las pro-

puestas de cambio en el “Espacio de la Práctica Docente” que se relata en 

el caso?

5.

. Ubíquense.en.la.posición.de.un.analista.institucional,.¿qué.propuesta.de.

intervención.creen.que.es.posible.de.concretar?

122. Capítulo.2. .El.método.y.los.recursos.didácticos

Extroducción

GENTE

Hay gente que con sólo decir una palabra

enciende la ilusión y los rosales;

que con sólo sonreir entre los ojos

nos invita a viajar por otras zonas,', 'chunk 214');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 215, 'nos hace recorrer toda la magia.

Hay gente que con sólo dar la mano

rompe la soledad, pone la mesa,

sirve el puchero, coloca las guirnaldas;

que con sólo empuñar una guitarra

hace una sinfonía de entrecasa.

Hay gente que con sólo abrir la boca

llega hasta los límites del alma,

alimenta la flor, inventa sueños,

hace cantar el agua en las tinajas

y se queda después como si nada.

Y uno se va de novio con la vida

desterrando la muerte solitaria,

porque sabe que a la vuelta de la esquina

hay gente que es así, tan necesaria

(Hamlet

.Lima.Quintana,1998,.en.Poemas de la breve palabra).

Trabajar.en.el.aula.con.algún.tipo.de.recurso.didáctico.es.

ciertamente.un.trabajo.mayor.que.sólo.‘dar’.la.clase.desde.la.

palabra..También.es.más.trabajo.para.los.alumnos/as.estudiar.

desde.los.textos.que.desde.los.apuntes.de.clase..Ciertamente.

todos.tienen.algo.más.de.trabajo.cuando.se.intenta.encarar.las.

cosas.seriamente..

Cuando.enseñamos.intervenimos.en.las.prácticas.de.aprendi-

z

aje.de.los.alumnos/as..Ese.tipo.especial.de.intervención.requiere,.

a.veces,.del.uso.de.mejores.‘instrumentos’.para.que.el.aprender.

sea.posible.y.el.enseñar.sea.una.real.intervención.', 'chunk 215');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 216, 'A.veces,.necesitamos.esas.cosas.que.s

on.tan.necesarias.y.

que.están.‘a.la.vuelta.de.la.esquina’..Solo.hay.que.tener.ganas.

de.caminar..Nunca.las.esquinas.estuvieron.lejos.

 123Más.didáctica.(en.la.educación.superior)

BAQUERO, . Ricardo . (1998):.

Vigotsky y el aprendizaje esco-

lar, .Bs..As.,.Aique.

—— .y.TERIGI,.Flavia.(1996):.“En.

búsqueda. de. una. unidad. de.

a

nálisis.del.aprendizaje.escolar”,.

Apuntes Pedagógicos.N º.2.

BARCO,.Susana.(s/f):.La organización 

de la clase en el nivel universi-

tario y la función de las guías 

de estudio como activadoras de 

las operaciones del pensamiento,

 .

mimeo.de.la.Universidad.Nacio-

n

al.del.Comahue..

BENEDETTI,.Mario.(1974):.Poemas 

de otros, .Bs..As.,.Editorial.Alfa..

Argentina.

C

ARLINO,.Paula.(2002):.Ayudar 

a leer en los primeros años de 

Universidad o de cómo conver-

tir una asignatura en ‘materia 

de cabecera’.

 (en.prensa).

DUSCHATZKY,. Silvia . (2005): . La 

escuela como frontera. Reflexio-

nes sobre la experiencia escolar 

de jóvenes de sectores popula-

res,

 .Bs..As.,.Paidós.

ECHEGARAY . DE. JUÁREZ, . Elena.

(1979):.Estudio dirigido 1. Téc-

nicas de trabajo intelectual,.B s..', 'chunk 216');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 217, 'As.,.Cuadernos.Pedagógicos,.

Kapelusz..

EDELSTEIN, . Gloria . (1996): . “Un.

capítulo.pendiente:.el.método.

en.el.debate.didáctico .con-

t

emporáneo”, . en. A.. W.. de.

Camilloni.y.otras:.Corrientes 

didácticas contemporáneas , .

Bs..As.,.Paidós.

FURLÁN,.Alfredo.(1989):.Aporta-

ciones a la Didáctica de la Edu-

cación Superior ,.M

 éxico.D.F.,.

ENEP.Iztacala,.UNAM.

GARAY,. Lucía . (2000): . Algunos 

conceptos para analizar insti-

tuciones educativas.

 .Córdoba,.

Publicación.del.Programa.de.

Análisis . institucional . de. la.

Educación..Centro.de.Investi-

g

aciones.de.la.Facultad.de.Filo-

sofía

.y.Humanidades,.Univer-

sidad

.Nacional.de.Córdoba.

—— .( 2006a): .Investigación educa-

tiva, investigadores y la cues-

tión institucional de la educa-

ción y las escuelas ,.C

 órdoba,.

CEA,.U.N.C..(Reelaboración.

sintética.de.diversos.trabajos.

de.la.autora).

—— . ( 2006b): . “La. Intervención.

Institucional.en.el.Campo.de.

la.Educación”,.en.1º Semina-

rio-taller: Prácticas de interven-

ción en asesoramiento y gestión 

pedagógica. Espacios macro 

institucionales (Material

 .com-

p

lementario),.Córdoba,.Maes-

t

ría.en.Pedagogía..Especiali-

z', 'chunk 217');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 218, 'ación. en. Asesoramiento . y.

Gestión.pedagógica..U.N.C.

LAVE,.Jean.(2001):.“La.práctica.del.

aprendizaje”,.en.S..Chaiklin.y.

J..Lave.(comps.): Estudiar las 

prácticas. Perspectivas sobre 

actividad y contexto,

 .Bs..As.,.

Amorrortu.

L

IMA.QUINTANA,.Hamlet.(1998):.

La breve palabra, .Bs..As.,.Edi-

ciones

.del.Valle.

Bibliografía

124. Capítulo.2. .El.método.y.los.recursos.didácticos

ROGOFF,. Bárbara . (1997): . “Los.

tres. planos . de. la. actividad.

socio-cultural: . apropiación.

participativa, . participación.

guiada.y.aprendizaje”, .en.J..

Wertsch . y. otros: . La mente 

sociocultural. Aproximaciones 

teóricas y aplicadas ,.M adrid,.

Fundación.Infancia.y.Apren-

dizaje.

S

TEIMAN,.Jorge.(2004):.¿Qué deba-

timos hoy en la didáctica? Las 

prácticas de enseñanza en la 

educación superior ,.B s..As.,.

Baudino.Ediciones-UNSAM.

WASSERMAN, . Sara . (1999): . El 

estudio de casos como método 

de enseñanza ,. B s. . As.,.

Amorrortu.

 125

Capítulo 3

Las prácticas de evaluación

Introducción

EL NIÑO QUE FUE A MENOS

La.señorita.Claudia.le.preguntó.a.Ferro:.

–.¿Quién.fundó.la.ciudad.de.Asunción?', 'chunk 218');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 219, 'Ferro.lo.ignora.y.lo.confiesa..La.maestra.intenta.por.otros.rumbos..

–.Tissot.

–.No.sé,.señorita.

–.Rossi.

Silencio..El.ambiente.se.pone.pesado.porque.quizá.la.señorita..

Claudia

.enseñó.aquello.el.día.anterior.

–.Maldonado.

Nada..Claudia.frunce.el.ceño.y.ensaya.unos.reproches.generales.

Frezza,.el.tano.Frezza,.lo.sabe.de.algún.modo.misterioso..Es.extraño.

el.camino.que.siguen.las.nociones:.suelen.alojarse.donde.menos.se.

piensa..

–.Nuñez..López..Dall´Asta.

Tampoco..Frezza.espera,.sobrador,.sin.levantar.la.mano..Cosa.de.

manyaorejas,.piensa.

La.señorita.Claudia.se.dirige.a.las.

niñas.y.pronuncia.el.nombre.

amado..Frezza.está.muy.lejos.para.soplar.y.la.morocha.que.lo.enlo-

quece

.no.puede.contestar.

De.pronto,.la.maestra.lo.mira..

–.Frezza.

126. Capítulo.3. .Las.prácticas.de.evaluación

Y.el.niño.taura,.que.tal.vez.necesita.anotarse.un.poroto,.se.levanta,.

mira.hacia.el.banco.de.la.morocha.y.dice.casi.triunfal:.

–.No.lo.sé.

Si.es.que.nadie.lo.sabe,.estará.bien.no.saberlo..Frezza.se.sienta.y.

se.oye.entonces,.como.una.horrible.blasfemia,.la.voz.de.Campos,.

injuriosa:

–

.¡Juan.de.Salazar!

Pasaron.los.años..La.morocha.no.conoció.el.amor.de.Frezza.ni.', 'chunk 219');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 220, 'tampoco.su.gesto.elegante.y.generoso.

Si.alguien.califica.estas.lecciones.en.alguna.Libreta.Celeste,.Frezza.

tendrá.un.nueve..Y.si.ni.siquiera.existe.esa.Libreta,.entonces.tendrá.

un.diez”.

(Alejandro.Dolina,.1988,.en.Crónicas del Ángel Gris).

S

i.hay.algo.que.al.pensarlo.se.nos.representa.a.los.docentes.

con.un.estereotipo.clásico,.eso.es.el.aula..La.imagen.mental.

inmediatamente.se.convierte.en.una.pintura.en.la.que.aparecen,.

con.ciertos.particularismos.idiosincráticos,.un.espacio.físico.en.

el.que.se.identifican.alumnos.(variarán.las.edades.según.el.caso),.

un.docente.(¿variará.el.género.según.el.caso?),.un.pizarrón.(clási-

c

amente.negro,.verde.o.los.relativamente.modernos.blancos.para.

escribir.con.fibrones).y.pupitres.o.bancos.o.mesitas…

Pero.el.aula.real,.ese.aula.en.la.que.trabajamos.todos.los.días,.

lejos.de.cualquier.estereotipo.es.increíblemente.única..Y.si

.deci-

mos

.el.‘aula.de.tercero’.se.nos.aparecen.con.nombre.y.apellido.

las.caras.borrosas,.toman.cuerpo.las.escrituras.a.medio.escribir.

del.pizarrón.y.sentimos.en.la.piel.misma.entrometerse.las.voces.

que.encierran.sus.paredes:

“… .no.entiendo”

“… .¿qué.te.puso?”

“… .no.estudié”', 'chunk 220');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 221, '“… .lo.que.pasa.que.a.mí.esta.materia.no.me.gusta”

“… .me.saqué.un.diez”

Las.voces.del.aula.son.el.registro.de.lo.que.en.ella.transcurre.y.

el.registro.de.una.parte.de.tu.historia.(¿cuántas.horas.de.tu.vida.

has.pasado.en.un.aula?)..Las.voces.del.aula.son.tu.memoria,.la.

memoria.de

.tus.alumnos/as,.la.memoria.de.tu.profesión,.la.de.la.

enseñanza,.la.del.aprendizaje..

 127Más.didáctica.(en.la.educación.superior)

Y.allí,.en.el.aula,.pensamos.nuestro.trabajo,.actuamos.y.pen-

s

amos.casi.sin.detenernos,.urgidos.por.la.espontaneidad.de.lo.

cotidiano..Quiero,.por.un.instante,.poder.pensar.‘mi’.aula..

Me.interno.en.ella.y.pienso.en.mí,.en.mi.práctica.y.pienso.

con.mis.alumnos/as.mi.enseñanza,.y.pienso.con.mis.alumnos/as.

sus.aprendizajes. .Y.pienso.el.aula.y.pienso.en.mi.esfuerzo .y.

desesfuerzo.por.plantear.un.‘escenario.didáctico’,.por.proponer.

genuinas.situaciones.de.aprendizaje..Y.pienso.el.aula.y.pienso.

mis.prácticas.de.evaluación.y.se.entrelazan.estas.reflexiones.que.

aquí.empiezo.a.construir.

Abro.las.puertas.de.mi.aula

.y.abro.las.puertas.de.cada.aula..

Y.allí.lo.veo.al.tano.Frezza.conversando.con.Dolina.acerca.de.la.', 'chunk 221');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 222, 'existencia.o.no.de.la.Libreta.Celeste.

1. La evaluación: una práctica compleja

Considerar.a.la.evaluación.como.objeto.de.análisis.y.debate.

en.el.ámbito.de.la.educación.superior.ha.comenzado.a.ser.hoy.

una.práctica.habitual.y.con.cierto.grado.de.aceptación .en.el.

interior.de.las.instituciones.y,.aunque.todavía.con.ciertas.indi-

fer

encias.y.algunos.rechazos.o.escepticismos,.lo.es.también.en.

el.conjunto.de.los.docentes..Es.que,.contrariamente.a.la.con-

c

epción.histórica.que.consideró.a.la.evaluación.como.un.pro-

c

eso.‘

natural’.(es.‘naturalmente’.como.es,.¿qué.es.lo.que.hay.

que.pensar.acerca.de.ella?).cuyo.mayor.problema.se.reducía.a.

confeccionar.un.instrumento.adecuado.y.su.mayor.conflicto.a.

soportar.la.‘cara.de.disgusto’.o.el.‘susurro.irreverente’.de.los.

desaprobados,.en.los.últimos.tiempos.se.ha.ido.tomando.con-

ciencia

.de.su.complejidad..

La.‘naturalización’.de.un.proceso.complejo.genera.inexora-

blemente

.un.reduccionismo.distorsionante:.se.cursa,.se.toman.

parciales .y.luego.finales .y.en.consecuencia, .los.alumnos/as.

aprueban.o.no,.¿qué.más?;.estudian,.demuestran.lo.que.saben.

y.en.consecuencia,.aprueban.o.no,.¿qué.más?', 'chunk 222');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 223, 'La.desnaturalización .de.un.proceso.c

omplejo.permite,.por.

el.contrario,.pensar.‘con’.la.complejidad:.es.mucho.más.que.un.

128. Capítulo.3. .Las.prácticas.de.evaluación

problema.‘de’.instrumentos,.es.mucho.más.que.un.problema.

‘de’.los.alumnos/as.

La.investigación .y.la.producción .didáctica .de.las.últimas.

décadas.han.generado.múltiples.reflexiones.sobre.esta.práctica,.

investigaciones.y.producciones.que.nos.permiten.considerarla.

hoy.desde.una.perspectiva .amplia..Así,.la.problemática.de.la.

evaluación,.puede.pensarse.también.a.partir.de.sus.implicancias.

desde.los.docentes,.desde.la.particularidad.del.contenido.que.es.

objeto.de.enseñanza,.desde.el.ámbito.de.lo.institucional,.desde.

el.marco.amplio.de.lo.social… .En.cada.práctica.de.evaluación,.

se.quiera.o.no,.se.implican.los.múltiples.factores.que.la.cons-

t

ituyen.y.que.a.l

a.vez.confluyen.en.ella..¿O.acaso.no.hemos.

escuchado.alguna.vez.las.voces1.que.a.ella.se.refieren,.directa.o.

indirectamente?:

CASO

.1:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘personales’?

-

. “No.sé.qué.me.pasó.en.el.final,.me.fui.poniendo.cada.vez.más.', 'chunk 223');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 224, 'nerviosa.y.en.un.momento.ya.no.pude.hablar.más”.(alumna.

de.carrera.universitaria .explicando .al.propio.profesor .su..

desapr

obación.en.la.última.unidad.curricular.de.la.carrera).

-. “Hoy.desaprobé.a.la.mitad,.debo.tener.un.mal.día”.(pro-

f

esor.universitario .en.las.mesas.de.examen.del.turno.de..

diciembre).

CASO

.2:.¿Constituyen

.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘sociales’?

-

. “LLene.esta.planilla.de.solicitud.del.empleo,.indicando.el.título.

que.Ud..posee,.el.promedio.de.las.notas.que.ud..ha.obtenido.

en.su.carrera.y.el.detalle.de.sus.trabajos.anteriores”.(profe-

sor

.universitario.reproduciendo.el.discurso.de.una.empleada.

del.área.de.Recursos.Humanos.de.una.empresa.considerada 

‘

grande’,.a.partir.del.relato.de.la.experiencia.que.le.había.

1. Corresponden.a.la.reconstrucción.de.relatos.de.alumnos/as.y.profesores/as.

en.Institutos.Superiores.de.Formación.Docente.y.Universidades.Nacionales.

acopiados.en.la.propia.memoria.o.en.la.memoria.de.colegas.a.quienes.he.

pedido.colaboración.al.respecto.y.de.los.cuales.podemos.recordar.el.contexto.

en.el.cual.fueron.dichos.

 129Más.didáctica.(en.la.educación.superior)', 'chunk 224');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 225, 'contado.un.ex-alumno.cuando.intentó.una.búsqueda.laboral.

y.fue.descartado.por.poseer.promedio.inferior.a.seis).

-. “Profesora,.profesora.yo.sé.que.no.hablo.bien,.pero.quiero.

seguir…. porque.en.mi.casa.nadie.estudió.y.mi.mamá.y.mi.tía.

dicen:.la.Lore.sí.que.va.a.ser.maestra”.(alumna.de.profeso-

rado,

.llorando.ante.la.desaprobación.de.la.unidad.curricular:.

“Espacio.de.la.Práctica.Docente.II”).

CASO.3:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘técnicos’?

-

. “Voy.a.tomar.un.‘múltiple-choise’.porque.son.como.150.

alumnos”.(profesora.universitaria.ante.el.primer.parcial.de.

una.unidad.curricular.del.

primer.año.de.la.carrera).

-. “La.verdad.que.no.le.entiendo.la.pregunta”.(profesora.de.

profesorado.relatando.sus.propias.dificultades.para.precisar.

las.preguntas.en.los.exámenes.orales.y.haciendo.referencia.

a.una.anécdota.personal.en.la.que.describe.el.caso.de.un.

alumno.que.le.contestó.por.tres.veces.consecutivas.la.frase.

encomillada).

CASO

.4:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘epistemológicos’?

-

. “En.esta.unidad.curricular.no.sé.qué.tomar”.(profesora.de.la.', 'chunk 225');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 226, 'profesorado.ante.la.lectura.del.Plan.de.Evaluación.Institucional.

en.el.que.se.acuerda.tomar.examen.final.en.todas.las.unidades.

curriculares.

de.la.carrera).

-. “Ésta.tendría.que.ser.promocional,.si.total.no.sirve.para.nada”.

(alumna.universitaria.analizando.el.plan.de.estudios.y.el.régi-

men

.de.evaluación.de.su.carrera).

CASO.5:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘político-institucionales’?

-

. “En.el.otro.instituto.pregunto.más.porque.hay.que.ser.más.

exigentes”.(profesor.de.Profesorado.relatando.diferencias.en.

los.exámenes.finales.entre.los.dos.institutos.estatales.de.

formación.docente.en.los.que.trabaja:.uno.‘prestigioso’.–tal.

130. Capítulo.3. .Las.prácticas.de.evaluación

como.él.mismo.lo.denominó–.de.la.ciudad.de.Buenos.Aires.

y.otro.del.conurbano.bonaerense).

-. “Profesor,.¿le.informaron.que.por.decisión.del.Consejo.Con-

s

ultivo.si.desaprobara.la.cursada.más.del.40%.de.los.alumnos,.

Ud..deberá.confeccionar.un.informe.justificando.las.causales.

de.la.reprobación?”.(profesor.universitario,.relatando.la.expe-

r

iencia.vivida.en.una.institución.que.estaba.en.proceso.de.', 'chunk 226');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 227, 'constituirse.como.universidad.privada.reconocida).

CASO.6:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘éticos’?

-

. “¿Con.lo.que.me.pagan.me.voy.a.poner.a.corregir.60.parciales?,.

no…,. doy.un.práctico.domiciliario.en.grupos.y.sólo.corrijo

.

seis.o.siete.trabajos”.(profesor.de.profesorado,.caso.típico.

del.profesor-taxi.según.su.propia.apreciación).

-. “Sentate.en.la.última.fila.que.cuando.se.llena.el.aula.no.

puede.pasar.por.los.pasillos.y.te.copias.tranquila”.(alumno.de.

carrera.universitaria.aconsejando.a.una.compañera.que.está.

estudiando.para.el.primer.parcial.de.una.unidad.curricular.

que.él.ya.cursó).

CASO.7:.¿Constituyen.y.a.la.vez.confluyen.en.las.prácticas.

de.evaluación.factores ‘ideológicos’?

-

. “Si.no.saben.ni.hablar…. no.pueden.ser.maestras;.la.forma.

de.expresarse,.de.vestirse,.de.comportarse,.también.hace.a.

la.calidad.de.un.maestro”.(profesora.comentando.su

.primera.

impresión.de.un.grupo.de.ingresantes.a.un.profesorado.antes.

de.tomar.la.evaluación.de.ingreso).

-. “Yo.no.voy.a.firmar.nada.porque.al.final.cada.profesor.puede.

tomar.lo.que.quiera”.(alumna.de.profesorado.ante.el.pedido.', 'chunk 227');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 228, 'de.un.compañero.que.promueve.hacer.un.petitorio.ante.la.

Dirección.para.invalidar.los.parciales.de.la.unidad.curricular.

‘Ciencias.Sociales.y.su.enseñanza.I’.argumentando.que.fueron.

desaprobados.los.que.no.‘pensaban’.igual.que.el.profesor).

En.cada.práctica.de.evaluación,.se.quiera.o.no,.se.implican.

múltiples.factores.de.diversa.naturaleza.que.hacen.de.ella.una.

práctica.compleja..Y.e

sta.complejidad,.enraizada.en.las.tradi-

 131Más.didáctica.(en.la.educación.superior)

ciones.históricas.que.la.han.caracterizado,.la.convierten.en.una.

práctica.sobre.la.que.es.necesario.reflexionar.intensamente.para.

hacer.posible.un.análisis.que.nos.modifique,.en.pos.de.trabajar.

con.más.profesionalidad,.con.más.justicia,.con.más.ética.

¿A.qué.me.refiero.con.las tradiciones históricas ?.A.q ue.las.

prácticas .de.evaluación .han.tenido.y.tienen.un.componente.

histórico.que.da.cuenta.de.su.constitución .como.un.tipo.de.

prácticas.en.las.que.el.único.que.evalúa.es.el.docente,.lo.único.

que.se.evalúa.es.el.saber.de.los.alumnos,.sus.resultados.son.

indiscutibles.(en.alguna.época.aún.reconociéndose.un.error.por

.

parte.de.quien.ha.evaluado),.se.la.usa.como.un.instrumento.de.', 'chunk 228');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 229, 'poder,.como.un.instrumento.de.demarcación.de.la.autoridad,.

como.un.instrumento.de.castigo… .Si.sumamos.a.la.compleji-

dad

.que.tiene.de.por.sí,.el.peso.de.sus.tradiciones,.resulta.una.

práctica.de.fáciles.desvirtuaciones..Algunas.de.ellas,.vale.la.pena.

analizarlas:.vamos.por.ellas..

2. Algunas desvirtuaciones 

 en las prácticas de evaluación

La.educación.superior.tiene.sus.particularidades .y.la.eva-

l

uación.en.la.educación.superior.tiene.sus.propias.‘patologías’ 

(

Santos.Guerra,.1996)..Creo.necesario .tomar.algunas.de.las.

que.considero.desvirtuaciones.más.relevantes.de.las.prácticas.

de.evaluación.en.la.educación.superior,.con.el

.mismo.afán.que.

expuse.más.arriba:.reflexionar.intensamente .para.hacer.posi-

b

le.un.análisis.que.nos.modifique,.en.pos.de.trabajar.con.más.

profesionalidad,.con.más.justicia,.con.más.ética.

2.1. “Lo que está en juego en la evaluación 

 es cuánto sabe el/la alumno/a”

Dos.consideraciones .por.lo.menos.se.desprenden.de.esta.

desvirtuación..La.primera.es.la.idea.errónea.de.que.lo.que.está.

en.juego.en.la.evaluación.es.una.cuestión.de.cantidad.de.apren-

d

izajes.(‘cuánto.sabe…’) .más.que.una.cuestión.de.calidad.(‘qué.', 'chunk 229');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 230, 'y.cómo.lo.sabe’)..La.pregunta.por.el.‘qué’,.se.refiere.a.la.conside-

132. Capítulo.3. .Las.prácticas.de.evaluación

ración.acerca.de.qué.tipo.de.aprendizajes.se.han.logrado,.dando.

por.hecho.que,.la.acumulación.de.información.es.el.más.precario.

de.los.aprendizajes.en.comparación.con.otros.de.mayor.relevan-

c

ia,.como.por.ejemplo,.los.procedimientos.de.análisis.de.las.cate-

gorías

.conceptuales.implicadas.en.un.contenido,.las.relaciones.

entre.las.diversas.categorías.conceptuales.presentes.en.diferen-

t

es.contenidos.o.la.resolución.de.problemáticas.haciendo.uso.de.

los.contenidos..He.aquí,.una.sustitución:.evaluamos.cierto.tipo.

de.‘enunciación’.de.los.contenidos.y.no.un.determinado.tipo.de.

trabajo.cognitivo.(o.determinados.tipos.de.trabajos.cognitivos).

con.esos.contenidos..Quiero.decir.que.n

os.contentamos.con.que.

los.alumnos/as.hagan.referencia.verbal.a.los.contenidos,.hablen.

(o.escriban).acerca.de.ellos,.‘repitiéndolos’.tal.como.aparecen.

en.los.textos.(en.el.mejor.de.los.casos).o.en.sus.cuadernos.

de.apuntes.de.clases.(algo.bastante.frecuente.y.es.el.peor.de.

los.casos).en.lugar.de.requerir.algún.tipo.de.reelaboración,.de.', 'chunk 230');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 231, 'análisis.complejo,.de.relaciones.sustantivas,.de.integración.de.

conceptualizaciones.diversas,.etc..con.esos.contenidos..

La.segunda.derivación.es.la.limitación.del.proceso.de.evalua-

ción

.al.ámbito.del.aprendizaje.de.los.alumnos/as..En.todo.caso.

evaluar.los.aprendizajes.será.uno.de.los.objetos.a

.evaluar,.pero.

por.cierto.también.la.enseñanza.necesita.ser.evaluada..Ya.volveré.

sobre.este.punto.más.adelante.

2.2. “Sólo hay que evaluar lo que el/la alumno/a 

 tiene que saber”

Lo.que.quiero.decir.es.que,.a.veces,.sólo.evaluamos.un.saber.

prefijado.dentro.de.una.estructura .de.saberes.que.nosotros,.

arbitrariamente,.hemos.considerado.como.lo.más.relevante.en.

el.campo.disciplinar.de.aquello.que.enseñamos..Insisto.con.la.

idea.de.‘solo.evaluamos’,.porque.coincido.con.la.necesidad.de.

establecer.con.claridad.el.objeto.de.la.evaluación..Pero,.¿cuántas.

veces.a.consecuencia.de.ello,.descartamos.otros.procedimientos.

de.indagación.que.permitan.a.los.a

lumnos/as.poner.en.evidencia.

otros.saberes.relacionados.con.el.contenido.disciplinar.y.que.no.

hemos.preestablecido.como.lo.necesariamente.aprendible?

 133Más.didáctica.(en.la.educación.superior)', 'chunk 231');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 232, 'Cada.alumno/a.adulto/a,.por.las.diferentes.prácticas.socia-

l

es.en.las.que.participa,.por.las.diferentes.historias.personales.

que.acumula,.por.los.diferentes.componentes.de.su.estructura.

cognitiva, .suele.aprender.dimensiones .muy.diferentes .de.un.

mismo.objeto.de.conocimiento..¿Cómo.delimitar.de.manera.tan.

definitiva.qué.es.exactamente .lo.que.tiene.que.aprender?.¿Es.

justo.desaprobar.a.quien.maneja.otro.saber.–del.campo.discipli-

nar

.específico–.que.no.sea.el.saber.preestablecido?

No.soy.ingenuo,.pero.conozco.más.de.un.alumno/a.que.sabe.

mucho.más.y.que.sabe.diferente.de.lo.que.yo.espero.que.sepa.

2.3. “El principal sentido de la enseñanza es que 

 

aquéllo que se enseña será evaluado”

.

A.veces.enseñamos.para.evaluar,.es.decir,.sólo.enseñamos,.

porque.eso.que.enseñamos .lo.vamos.a.evaluar..A.veces,.en.

nuestra.primera.clase,.cuando.estamos.presentando.la.unidad.

curricular,.sólo.nos.limitamos.a.hacer.una.minuciosa.explicación.

de.las.condiciones.requeridas.para.aprobarla..A.veces.creemos.

que.los.alumnos/as.sólo.están.en.la.clase.porque.tienen.que.

aprobar..Pareciera.que.la.razón.del.tránsito.de.un.alumno/a.por.', 'chunk 232');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 233, 'las.aulas.tuviera.por.única.finalidad.el.ser.evaluado..Creo.que.

inevitablemente,.cuando.éste.es.el.supuesto.de.base,.el.interés.

por.el.conocimiento.y.el.a

prendizaje.se.sustituyen.por.un.interés.

utilitario,.en.tanto.que.se.estudia.en.primer.lugar.para.aprobar.y.

luego.(y.en.ocasiones.ni.siquiera.ello).para.aprender..

Si.les.preguntáramos.a.nuestros.alumnos/as.cuáles.son.sus.

objetivos/deseos/metas .para.el.presente.año.en.la.Facultad.o.

el.Profesorado, .¿cuántos .nos.contestarían: .“aprobar.todo.lo.

que.estoy.cursando”?;.¿cuántos.nos.contestarían: .“aprender.

mucho”?.

Por.supuesto.que.no.quiero.ser.simplista..Sé.que.‘aprobar’.

pone.en.juego.tiempos.de.la.vida.personal,.que.resulta.ser.un.

desafío.a.la.autoestima,.que.implica.no.volver.a.gastar.en.colecti-

v

os.y.apuntes.para.una.unidad.c

urricular.que.se.ha.cursado,.que.

supone.superar.una.dificultad… .Pero.me.interesa.que.lo.veamos.

desde.los.docentes,.desde.nosotros..¿Cuánto.tenemos.que.ver.

nosotros.en.hacer.de.la.evaluación.y.sus.consecuencias.(aprobar.

134. Capítulo.3. .Las.prácticas.de.evaluación

o.no.aprobar).el.eje.primordial.del.aprendizaje?.¿Cuántas.veces.', 'chunk 233');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 234, 'nuestro.interés.por.enseñar.queda.sepultado.bajo.nuestra.pre-

ocupación

.por.evaluar?.¿Cuántas.veces.lo.único.que.realmente.

preparamos.con.antelación.es.la.prueba.que.vamos.a.tomar?

2.4. “Evaluación y enseñanza son procesos 

independientes”

Quiero.plantear.ahora.otro.extremo..En.ciertas.ocasiones,.

consideramos.a.la.enseñanza.y.a.la.evaluación.como.dos.pro-

cesos

.sin.relación.entre.sí..Más.grave.resulta.ser.esta.distorsión.

en.el.ámbito.universitario,.en.donde.es.bastante.habitual.que.la.

enseñanza.esté.a.cargo.de.docentes.adjuntos.o.jefes.de.trabajos.

prácticos.y.la.evaluación.sea.diseñada.por.el.docente

.titular..Si.

la.cátedra.es.un.verdadero.equipo.de.trabajo.esta.división.de.

funciones.no.tendría.porque.convertirse.en.un.problema.ya.que.

todos.los.integrantes.están.al.tanto.de.los.que.está.sucediendo.

en.la.cursada.de.la.unidad.curricular..Pero.si.esto.no.es.así…. es.

esperable.que.el.tipo.de.tareas.(consignas.de.prueba).solicitadas.

en.la.evaluación.no.necesariamente .se.correspondan .con.los.

contenidos.realmente.enseñados..¿Quiénes.‘sufren’.las.conse-

cuencias?

.La.respuesta.es.obvia.

La.enseñanza.y.la.evaluación.no.pueden.estar.disociadas..', 'chunk 234');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 235, 'Arriesgo.a.decir.que.si.evaluamos.contenidos.o.requerimos.cierto.

tipo.de.trabajo.c

ognitivo.con.los.contenidos.que.no.han.sido.

previamente.objeto.de.enseñanza,.estamos.‘traicionando’.a.los.

alumnos/as.(y.que.hayan.sido.objeto.de.enseñanza.supone.que.

han.sido.trabajados.de.ese.modo.en.las.clases.o.que.se.han.deri-

v

ado.trabajos.de.elaboración.domiciliarios.de.ese.modo)..Arriesgo.

a.decir.que.cuando.se.nos.ocurre.‘innovar’.en.el.momento.de.

la.evaluación.presentando.formatos.(por.ejemplo.un.formato.de.

prueba.escrita).que.no.han.sido.trabajados.previamente.durante.

nuestras.intervenciones.de.enseñanza,.estamos.‘traicionando’.

a.los.alumnos/as.

 135Más.didáctica.(en.la.educación.superior)

2.5. “La evaluación es un punto de llegada”

No.quiero.entrar.en.la.dicotomía.proceso-producto.por.dos.

razones:.por.un.lado,.mucho.se.ha.escrito.acerca.de.ello,.pero.

por.otro,.creo.que.es.una.falsa.antinomia:.evaluamos.procesos.

y.productos..

Cuando.manifiesto .que.tomamos.la.evaluación .como.un.

punto.de.llegada,.me.refiero.a.que.a.veces,.una.vez.tomada.una.

prueba.parcial.o.un.examen.final.solemos.considerar.que.algo.', 'chunk 235');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 236, 'terminó.y.algo.nuevo.empieza..El.tema.es.que.esa.evaluación.

supone.alguna.comunicación.de.la.apreciación.que.hacemos.del.

rendimiento.evidenciado,.digo,.supone.comunicar.una.nota..El.

problema.es.q

ue,.cuando.esa.nota.no.evidencia.un.buen.ren-

dimiento

.académico.de.algunos.alumnos/as,.¿algo.terminó?.Un.

supuesto.de.ese.tipo,.¿no.deja.librado.a.la.buena.suerte.de.los.

alumnos/as.el.qué.hacer.ante.lo.no.aprendido?.¿Ya.no.hay.más.

nada.que.enseñar.acerca.de.aquello.que.no.se.ha.aprendido?.

¿No.necesitan.los.alumnos/as.algún.tipo.de.orientación,.algún.

nuevo.tipo.de.intervención.de.enseñanza.para.poder.aprender.

lo.no.aprendido?

Vuelvo.sobre.la.ingenuidad..Sé.que.no.podemos.atender.a.

cada.uno.en.especial,.sé.que.hay.un.tiempo.para.enseñar.que.lo.

delimita.la.duración.del.cuatrimestre.o.d

el.año,.sé.que.en.algunas.

oportunidades.un.desaprobado.es.sólo.una.cuestión.de.‘falta.de.

estudio’,.sé.que.en.algunas.carreras.tenemos.comisiones.muy.

numerosas,.pero.aún.así,.creo.que.no.podemos.quedarnos.con.

un.simple:.“para.la.próxima.vez.estudiá.más”,.porque.sé.también.

que.en.muchos.casos,.arriesgo.a.decir.en.muchísimos.casos,.ese.', 'chunk 236');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 237, 'alumno/a.que.desaprobó.estudió.o.cree.que.estudió.o.hizo.todo.

lo.que.estaba.a.su.alcance.para.estudiar..Su.problema.es.que.no.

aprendió.todavía.cómo.hacerlo,.no.logró.internalizar.el.tipo.de.

lógica.particular.que.caracteriza.a.las.categorías.conceptuales.y

.

problemas.que.trata.un.campo.determinado.del.conocimiento,.

no.logró.entender.el.planteo.de.los.textos.o.la.resolución.de.los.

problemas..¿Qué.nos.hace.suponer.que.la.próxima.vez.podrá.

lograrlo.sin.ningún.tipo.de.nueva.intervención.desde.la.ense-

ñ

anza?.¿Por.qué.creemos.que.un.recuperatorio.es.sólo.una.nueva.

oportunidad .de.demostrar .que.se.aprendió.lo.que.había.que.

136. Capítulo.3. .Las.prácticas.de.evaluación

aprender.y.que.no.nos.corresponde.hacer.nada.entre.la.primera.

evaluación.y.ese.recuperatorio?

2.6. “La evaluación final comienza bajo el supuesto de 

 descubrir qué es lo que el/la alumno/a no sabe”

La.evaluación.final.es.‘detectivesca’,.se.trata.de.descubrir.al.

‘asesino.de.conceptos’.y.esa.alumna.con.cara.angelical.que.está.

sentada.frente.a.nosotros.rindiendo.el.final.es.‘sospechosa’;.tam-

bién

.lo.es.aquel.alumno.trajeado.que.viene.del.trabajo,.y.el.que.', 'chunk 237');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 238, 'se.sienta.siempre.en.la.última.fila.y.hasta.ese.que.se.sacó.10.en.

los.parciales..Hay.que.‘pescar’.qué.es.lo.que.no.saben.porque….

¿

Por.qué.ese.manto.de.sospecha?.¿Por.qué.pareciera.que.siempre.

tratamos.de.hurgar.allí,.en.lo.más.cercano.al.desconocimiento?.

¿Por.qué.tendemos.a.convertir.el.examen.final.en.exactamente.

lo.contrario.a.lo.que.una.evaluación.de.cierre.debiera.ser:.un.

momento.de.‘gloria’?.

El.examen.final.es.todo.un.tema.en.sí.mismo..Salvo.algunas.

excepciones,.no.coincido.en.términos.generales.con.la.promo-

ción

.directa..Sigo.pensando.que.el.examen.final.permite.rever.la.

unidad.curricular.trabajada.a.lo.largo.de.un.curso,.permite.esta-

b

lecer.una.integración.y.un.conjunto.de.relaciones.conceptuales.

nuevas.que.sólo.se.l

ogran.cuando.se.trabaja.con.esa.totalidad.

que.es.la.unidad.curricular,.cuando.se.retrabaja.con.ella..Pero.

tampoco.adhiero.a.convertir.esa.instancia.en.un.cazabobos,.a.

hacer.de.ello.un.ping-pong.de.preguntas.acerca.de.cuestiones.

deshilvanadas.entre.sí,.a.convertirlo.en.un.‘martirio’..

Pero.lo.que.me.preocupa,.es.que,.en.general,.ni.siquiera.nos.

cuestionamos.qué.es.lo.que.estamos.proponiendo.como.ins-

tancia', 'chunk 238');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 239, '.de.cierre.final.y.tendemos.a.‘tomar’.examen.casi.como.en.

un.juicio,.pero.sin.abogados.defensores..Y.algo.que.todavía.me.

preocupa.más:.que.ni.siquiera.nos.damos.cuenta.

2.7. “La corrección de un parcial escrito 

 se reduce a poner una nota”

La.‘corrección’.tiene.estilos.de.lo.más.diversos:.devolvemos.

una.prueba.con.la.nota.y.ningún.señalamiento,.devolvemos.con.

 137Más.didáctica.(en.la.educación.superior)

‘cruces’.en.los.párrafos.en.los.que.aparecen.errores.y.una.nota,.

devolvemos.con.brevísimos.comentarios.al.tipo.de.‘mal.elabo-

r

ado’,.‘error.conceptual’,.‘falta.de.lectura’,.‘no’.y.una.nota..Parece.

que.siempre,.lo.que.nos.une,.es.que.devolvemos.marcando.el.

error.y.calificando.a.partir.de.ello..

Siendo.así.las.cosas,.hay.algunas.cuestiones.que.tendremos.

que.pensar.seriamente..Por.ejemplo:.¿cómo.hace.un.alumno/a.

para.revisar.su.error.si.no.se.lo.orienta.al.respecto?.Escuchemos.

sus.comentarios:.“yo.se.lo.expliqué.pero.no.como.él.quería”;.

“quiere.que.lo.ponga.con.las.palabras.del.libro”..¿Quién.n

o.escu-

chó

.alguna.vez.esto?.¿Es.que.los.alumnos/as.son.tan.necios.que.

no.se.dan.cuenta.cuando.se.equivocan.y.nos.echan.la.culpa.a.', 'chunk 239');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 240, 'nosotros.de.sus.fracasos?.¿O.es.que.nosotros.no.logramos.que.

una.evaluación.devuelta.sea.un.disparador.para.el.aprendizaje?

Y.además,.¿por.qué.las.buenas.resoluciones .tienden.a.no.

recibir.ningún.tipo.de.estímulo?.¿Por.qué.creemos.que.la.nota.

es.suficiente.y.que.un.alumno/a.entenderá.que.una.nota.alta.

demuestra…? .¿Qué.demuestra?.Un.alumno/a.puede.entender.

que.una.nota.alta.demuestra.que.estudió,.otro.que.hizo.un.buen.

desarrollo.conceptual,.otro.que.estuvo

.original,.¿por.qué.no.les.

comunicamos.a.sus.autores.lo.que.nos.produce.a.nosotros.la.

lectura.de.un.buen.parcial?

Una.vez.más.no.quiero.ponerme.en.el.lugar.de.los.idealis-

mos.

.Sé.que.acumulamos.horas-clase.a.lo.largo.del.día,.sé.que.

las.horas-corrección.no.parecen.estar.contempladas.en.nuestro.

salario,.sé.que.estamos.frente.a.cursos.numerosos..Pero.saben.

qué,.cuando.éstos.no.son.los.condicionantes,.cuando.los.cursos.

son.de.pocos.estudiantes,.cuando.nosotros.podemos.trabajar.

en.mejores.condiciones,.actuamos.de.la.misma.manera..Es.para.

pensarlo.

2.8. “Las notas son necesarias e imprescindibles”

La. legión . de. los. defensores . d e. las. notas . tiene . muchos.', 'chunk 240');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 241, 'adherentes..Escuchamos.al.respecto.distinto.tipo.de.argumen-

t

aciones:.que.estimulan.a.los.más.aptos,.que.si.no.existieran.los.

alumnos/as.estudiarían.sólo.lo.mínimo.para.aprobar,.que.son.

138. Capítulo.3. .Las.prácticas.de.evaluación

un.referente.para.dar.cuenta.de.cómo.va.el.estudio,.que.en.el.

mercado.laboral.el.promedio.del.título.tiene.mucho.peso….

Contra.los.argumentos.es.posible.contra-argumentar:.que.se.

puede.estimular.de.maneras.muy.diversas.y.no.sólo.con.notas,.

que.las.experiencias.en.las.que.se.han.usado.escalas.más.reduci-

d

as.que.las.numéricas,.incluyendo.las.bipolares.de.aprobado-des-

a

probado,.no.evidenciaron.que.los.estudiantes.estudiaran.menos.

o.peor.por.ello,.que.se.puede.referenciar.la.marcha.del.estudio.

con.cualquier.otro.tipo.de.comunicaciones,.que.la.escuela.no.

puede.usar.notas.sólo.porque.el.mercado.las.necesita…

La. legión . d

e. los. detractores . de. las. notas . tiene . menos.

adherentes. . Pero . esos . pocos . argumentan . que . generan.

competitividad,.que.son.arbitrarias.(¿qué.diferencia.real.hay.entre.

un.cinco.y.un.seis?),.que.llevan.inevitablemente.a.trabajar.con.

patrones.de.medida…', 'chunk 241');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 242, 'Personalmente .me.resulta.mucho.más.coherente .usar.la.

escala.‘aprobado-desaprobado’..Creo.que.el.mito.es.creer.que.

no.hay.evaluación.sin.nota.y.el.mayor.problema.es.la.deificación.

de.las.notas.y.el.reduccionismo.de.la.evaluación.a.una.cuestión.

de.calificaciones..Creo.que.también.podemos.desnaturalizar.el.

uso.de.la.nota.y.pensar.que.podría.ser.posible.evaluar.sin.atarnos.

a.las

.notas.o.evaluar.combinando.devoluciones.cualitativas.con.

escalas.cuantitativas..A.lo.mejor,.probando,.nos.sale.mejor.

2.9. “Los ‘choise’2 son objetivos”

Tenemos.invasión.de.pruebas.tipo.múltiple-choise. .En.los.

ingresos.se.reproducen.cual.conejos..Entiendo.que.resulta.un.

instrumento.operativo.cuando.las.comisiones.de.alumnos/as.son.

masivas..Pero.desestimo.el.carácter.de.‘objetivas’.para.quien.las.

defiende.como.tales..En.todo.caso,.lo.objetivo.de.los.choise,.es.la.

sumatoria.de.puntajes.que.da.como.resultado.una.calificación..

La.supuesta.objetividad.se.pierde.si.las.analizamos.en.cuanto.

a.su.elaboración: .¿la.tarea.(los.ítems).seleccionada .evalúa.lo.

verdaderamente.importante?;.¿es.ésta.u

na.representación.valiosa.', 'chunk 242');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 243, '2. Tomo.aquí.el.nombre.genérico .de.‘choise’.para.denominar .a.las.‘pruebas.

objetivas’.–a.las.que.me.referiré.más.adelante–.ya.que.así.se.las.reconoce.

en.general.en.la.cotidianeidad.de.las.instituciones.de.educación.superior.

 139Más.didáctica.(en.la.educación.superior)

de.aquello.que.supuestamente.debía.aprenderse?;.¿lo.que.se.ha.

colocado.como.bibliografía.obligatoria,.permite.aprender.concep-

tos

.y.trabajos.cognitivos.con.esos.conceptos.para.responder.a.

lo.que.se.pregunta.en.una.tarea?.

La.supuesta.objetividad.se.pierde.también.si.la.analizamos.

en.cuanto.a.la.asignación.de.puntaje:.¿la.asignación.de.puntajes.

a.la.tarea.permite.valorar.discriminando.los.saberes.relevantes.

de.los.saberes.no.tan.relevantes?.

Todas.las.respuestas.posibles.a.estas.preguntas.indican.el.

carácter.‘subjetivo’.de.cualquier.propuesta.de.evaluación.

2.10. “Proponer la autoevaluación es hacer demagogia”

Estoy.hablando.de.autoevaluación,.no.de.autocalificación..

Estoy.hablando.de.un.procedimiento.p

or.el.cual,.necesariamente,.

todos.tendríamos.que.pasar.para.poder.revisar.nuestras.prácticas.

de.enseñanza.y.por.el.cual.todos.los.alumnos/as.tendrían.que.', 'chunk 243');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 244, 'poder.pasar.para.revisar.sus.prácticas.de.aprendizaje.

Autoevaluarse.es.poder.emitir.un.juicio.valorativo.sobre.un.

proceso.que.se.está.viviendo.(por.ejemplo.el.enseñar.o.el.apren-

der)

.y.sobre.los.resultados.provisorios.alcanzados,.hasta.cierto.

momento,.en.dicho.proceso..Autoevaluarse.es.poder.analizar.

con.criticidad,.identificando.obstáculos,.descubriendo.logros,.es.

poder.hacer.un.ejercicio.metacognitivo,.es.el.más.democrático.

de.los.procedimientos .porque.hace.partícipe.a.todos.los.que.

han.estado.involucrados.en.un.proceso.áulico,

.empezando.por.

uno.mismo..

Autocalificarse.es.otra.cuestión..Poner.a.los.alumnos/as.en.

la.‘obligación’.de.colocarse.una.nota.o.solicitar.una.opinión.al.

respecto.de.qué.nota.se.asignarían,.en.principio,.no.estoy.de.

acuerdo..Y.no.lo.estoy,.por.lo.menos,.dentro.del.contexto.en.el.

cual.llevamos.a.cabo.este.tipo.de.prácticas:.sin.discusión.previa.

respecto.de.los.criterios.con.que.se.asignan.notas,.sin.discusión.

previa.respecto.de.qué.es.lo.ponderable.en.la.evaluación.que.se.

propone,.ni.una.discusión.sobre.lo.que.se.propone.y.ni.sobre.el.

trabajo.que.se.propone.

con.un.objeto.de.conocimiento..', 'chunk 244');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 245, '140. Capítulo.3. .Las.prácticas.de.evaluación

Y.además,.por.una.cuestión.de.tender.al.mayor.equilibrio.

objetivo.posible,.me.parece.que.ese.trabajo.‘engorroso’.es.obli-

gación

.de.los.docentes.

2.11. “La calidad de la formación en la educación 

 superior se soluciona con un buen sistema de 

 exámenes (de ingreso y/o de egreso)”

Los.años.’90.dejaron.huellas.profundas.en.el.sistema.educa-

tivo.

.Las.políticas.educativas.–de.neto.corte.neoliberal–,.insta-

lar

on.la.racionalidad.evaluativa.bajo.el.slogan.del.mejoramiento.

de.la.calidad..De.allí.que.‘calidad’.y.‘evaluación’.se.tornaron.inse-

parables.

.He.aquí.la.primera.faceta.de.esta.distorsión:.concebir.

el.mejoramiento.de.la.calidad.desde.la.concepción.que.deposita.

en

.la.evaluación.la.mágica.solución.de.la.mejora..

La.reducción.presupuestaria.o.la.mediáticamente .llamada.

‘racionalidad.en.el.gasto’,.conllevó.a.la.necesidad.de.actuar.al.

interior.del.sistema.atendiendo.las.nuevas.demandas,.con.igual.

o.–en.términos.reales–.menor.presupuesto.para.el.área,.es.decir.

‘haciendo.más’.con.‘menos.gasto’..El.discurso.político.sepultó.los.

históricos.postulados.de.la.ampliación.de.oportunidades.educa-

t', 'chunk 245');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 246, 'ivas.gestadas.en.la.década.de.1960.para.instalar.lentamente.dos.

ideas.complementarias:.la.idea.de.la.restricción.al.ingreso.para.

garantizar.la.calidad.del.sistema.formativo,.junto.a.la.idea.del.

control.de.la.idoneidad.d

e.los.egresados.para.garantizar.la.calidad.

del.ejercicio.profesional..Y.en.ambos.casos.el.instrumento,.es.el.

examen:.examen.de.ingreso,.examen.de.egreso..A.pesar.de.ello,.

en.Argentina.se.ha.resistido.particularmente.esta.lógica.desde.

nuestra.más.pura.tradición:.las.ideas.reformistas.del.año.1918..

“[De.esta.manera,.el].examen.aparece.permanentemente.

como.un.espacio.sobredeterminado..En.este.espacio.se.

tiene.la.mirada.puesta..Es.observado.por.los.responsa-

b

les.de.la.política.educativa,.por.los.directivos.de.las.

instituciones.escolares,.por.los.padres.de.familia,.por.

los.alumnos.y.finalmente.por.los.mismos.docentes..Si.

bien.cada.g

rupo.social.puede.tener.su.representación.en.

relación.con.el.papel.que.juega.el.examen,.todos.estos.

grupos.coinciden.en.términos.globales.en.esperar.que.a.

 141Más.didáctica.(en.la.educación.superior)

través.del.examen.se.obtenga.un.conocimiento.‘objetivo’.', 'chunk 246');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 247, 'sobre.el.saber.de.cada.estudiante..Pero.el.examen.es.sólo.

un.instrumento.que.no.puede.por.sí.mismo.resolver.

los.problemas.que.se.han.generado.en.otras.instancias.

sociales..No.puede.ser.justo.cuando.la.estructura.social.

es.injusta;.no.puede.mejorar.la.calidad.de.la.educación.

cuando.existe.una.drásticas.disminución.del.subsidio.y.

los.docentes.se.encuentran.mal.retribuidos;.no.pueden.

mejorar.los.procesos.de.aprendizaje.de.los.estudiantes.

cuando.se.atiende.ni.a.la.conformación.intelectual.de.

los.docentes.ni.al.estudio.de.los.procesos.de.apren-

der

.de.cada

.sujeto,.ni.a.un.análisis.de.sus.condiciones.

materiales..Todos.estos.problemas,.y.muchos.otros.que.

convergen.detrás.del.examen,.no.pueden.ser.resueltos.

favorablemente.sólo.a.través.de.este.instrumento.(social)”.

(Díaz.Barriga,.1990).

2.12. “Los docentes necesitamos capacitación 

 específica sobre herramientas de evaluación”

Quiero.cerrar.estas.distorsiones .con.esta.última.aprecia-

c

ión..Escucho.con.mucha.frecuencia.reclamos.institucionales.

acerca.de.la.necesidad.de.instrumentar.procesos.de.capacitación.

docente.referidos.a.temáticas.de.evaluación..No.es.que.no.crea.', 'chunk 247');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 248, 'que.necesitemos.capacitación.–por.cierto.una.práctica.bastante.

relegada.en.la.educación.superior–.pero.el.problema.radica.en.

que.la.demanda.es.una.d

emanda.‘técnica’..Es.decir,.es.un.reclamo.

centrado.únicamente.en.una.actualización.de.los.docentes.en.

torno.al.‘aprender.a.tomar.mejores.exámenes’..Quiero.volver.a.

citar.a.Díaz.Barriga.porque.creo.que.mejor.que.nadie.plantea.con.

precisión.el.problema.de.convertir.una.cuestión.de.fondo.–la.

evaluación.como.problema.social.y.político–.en.una.cuestión.de.

forma.–la.evaluación.como.problema.de.instrumentos–.

“(…) .el.examen.es.un.espacio.donde.se.realiza.una.

multitud.de.inversiones.de.las.relaciones.sociales.y.de.

las.pedagógicas..(…) .Es.un.espacio.que.invierte.las.rela-

ciones

.de.saber.y.de.poder..De.tal.manera

.que.presenta.

como.si.fueran.relaciones.de.saber,.las.que.fundamen-

talmente

.son.de.poder.(…)..

142. Capítulo.3. .Las.prácticas.de.evaluación

Los.problemas.de.orden.social:.posibilidad.de.acceso.a.la.

educación,.justicia.social,.estratos.de.empleo,.estructura.

de.la.inversión.para.el.desarrollo.industrial,.etc..son.

trasladados.a.problemas.de.orden.técnico:.objetividad,.', 'chunk 248');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 249, 'validez, c onfiabilidad. .La.discusión.que.se.realiza.en.este.

nivel.de.la.problemática desconoce .la.conformación.de.

la.misma” (Díaz .Barriga,.1990).

También.Susana.Celman.interroga,.desde.otra.lógica,.el.pro-

blema

.‘secundario’.de.la.mejora.de.los.exámenes:.

“La.mejora.de.los.exámenes.comienza.mucho.antes,.

cuando.me.pregunto:.¿Qué.enseño?.¿Por.qué.enseño.

eso.y.no.otras.cosas?.¿De.qué.modo.lo.enseño?.¿Pueden.

aprenderlo.mis.alumnos?.¿Qué.hago.para.contribuir

.a.

un.aprendizaje.significativo?.¿Qué.otras cosas .dejan.de.

aprender?.¿Por.qué?” (Celman, .1998). 

He.aquí,.en.ambos.autores,.una.clara.alocución.respecto.de.

aquello.a.lo.que.quiero.referirme..El.problema.de.la.evaluación.en.

la.educación.superior.(cuando.se.lo.reconoce.como.problema).

no.se.soluciona.capacitando.a.los.docentes.para.que.elaboremos.

mejores.‘choise’,.o.tomemos.parciales.con.problemáticas.que.

eviten.la.repetición.memorística.de.los.contenidos..El.problema.

de.las.prácticas.de.evaluación.en.la.educación.superior.no.es,.en.

principio,.un.problema.técnico,.un.problema.de.herramientas.para.

evaluar..Si.bien,.soy.de.los.que.adhieren.a.l

a.necesidad.de.inscribir.', 'chunk 249');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 250, 'una.Didáctica.que.trabaje.en.torno.a.sugerencias.prácticas.y.de.

ciertas.pautas.de.acción.(Steiman,.2004),.creo.a.la.vez,.que.no.se.

puede,.en.el.interior.de.las.instituciones.de.la.educación.superior,.

obviar.el.debate.en.torno.a.la.significación.social.implicada.en.las.

prácticas.de.evaluación.de.las.que.participamos.

3. Y entonces, ¿qué es evaluar?

Defino.la.evaluación.como.un.proceso.que,.a.partir.del.cono-

c

imiento.y.comprensión.de.cierta.información,.permite.emitir.un.

juicio.de.valor.acerca.de.un.aspecto.de.la.realidad.en.el.cual.se.

 143Más.didáctica.(en.la.educación.superior)

interviene.en.un.determinado.contexto.sociohistórico3.particular.

y.que,.a.la.vez.que.posibilita.tomar.decisiones,.exige.desde.el.

diálogo.con.quien.esté.involucrado,.argumentar.justificaciones.

del.juicio.de.valor.realizado..En.el .ámbito.del.aula,.ese.aspecto.

de.la.realidad.se.refiere,.fundamentalmente, .a.las.prácticas.de.

enseñar.y.aprender,.y.es.por.ello.que.quisiera.llamar.a.este.pro-

c

eso:.evaluación.didáctica..En.síntesis,.defino.a.la.evaluación.

didáctica .como.un.proceso.que,.a.partir.del.conocimiento .y.

comprensión .de.cierta.información, .permite,.desde.una.acti-', 'chunk 250');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 251, 't

ud.dialógica,.emitir.un.juicio.de.valor.acerca.de.las.prácticas.

de.enseñanza.y/o.l

as.prácticas.de.aprendizaje.en.un.contexto.

sociohistórico .determinado .en.el.cual.intervienen .con.parti-

c

ularidad.significante.lo.social.amplio,.la.institución,.el.objeto.

de.conocimiento,.el.grupo.de.alumnos/as.y.el/la.docente.y.que.

posibilita.tanto.el.tomar.decisiones.referidas.a.las.prácticas.de.

referencia.como.exige.comunicar.a.docentes.y/o.alumnos/as.–por.

medio.de.enunciados.argumentativos–.el.juicio.de.valor.emitido.

y.las.orientaciones.que,.derivadas.de.éste,.resulten.necesarios.

para.la.mejora.de.la.práctica...

Así,.la.evaluación.no.es.una.práctica.espontánea.o.de.intui-

c

ión.pragmática.(De.Ketele,.1993).sino.una.práctica.instituida.

(Barbier,.1993),.es.u

na.práctica.deliberada.y.socialmente.organi-

zada,

.de.innegables.consecuencias.personales.y.sociales..

Así.definida,.convendría.entonces.diferenciar.la.evaluación.

didáctica.de.por.lo.menos.dos.prácticas.con.las.que,.en.ocasio-

nes,

.suele.asimilársela:

-. La.evaluación.como.control:.existe.control.cada.vez.que.la.

evaluación.sólo.trata.de.una.serie.de.operaciones.cuyo.apa-

r', 'chunk 251');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 252, 'ente.resultado.es.la.emisión.de.una.información .referida.

al.funcionamiento.concreto.de.una.actividad.de.formación.

(Barbier,.1993)..La.evaluación.como.control.intenta.garanti-

zar

.que.algo.previsto.está.sucediendo,.tal.como.había.sido.

previsto.y,.en.caso.de.que.así.no.sea,.‘corregir’.su.desvío..

3. No.quisiera .abusar.del.uso.del.término.‘sociohistórico’.el.cual.aparece.a.

veces.indiscriminadamente .ligado .a.cualquier .tipo.de.discurso .‘social’.y.

supuestamente .’crítico’..Pero.lo.veo.aquí.pertinente .para.referirme .a.los.

contextos.particulares.de.sociedad,.escuela,.objeto.de.conocimiento,.grupo.

de.alumnos/as,.docente,.configurados.en.un.tiempo.y.un.espacio.

144. Capítulo.3. .Las.prácticas.de.evaluación

-. La.evaluación.como.medición:.la.evaluación.reconoce.una.

larga.historia.en.la.que.se.concibió.al.proceso.evaluador.

como.un.proceso.de.medición..El.paradigma.docimológico.

(De.Ketele,.1993).redujo.la.evaluación.a.la.examinación,.de.

allí.el.término.‘docimología’.que.se.refiere.a.la.‘ciencia.de.los.

exámenes’..De.la.mano.de.la.pedagogía.experimental.esta.

concepción,.aunque.con.rasgos.distintivos.en.diferentes.déca-

das,', 'chunk 252');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 253, '.entiende.que.la.evaluación.es.una.cuestión.de.puntajes.

asignados.a.pruebas.o.una.actividad.de.comparación.entre.

una.producción.escolar.que.debe.evaluarse.y.un.modelo.de.

referencia..La.existencia.de.un.modelo.de

.referencia.obliga.a.

instalar.un.‘patrón.de.medida’.desde.el.cual.comparar..Y.así.

dadas.las.cosas,.la.evaluación.entonces.se.estandariza.y.se.

convierte.en.un.proceso.que.se.define.con.exclusividad.desde.

su.aspecto.técnico:.la.decisión.acerca.del.instrumento.que.

se.utilizará.para.‘medir’.y.al.cual.todos.los.sujetos.evaluados.

deberán.‘acomodarse’..Esta.concepción.‘matemática’.de.la.

evaluación.considera.que.el.evaluar.es.una.cuestión.que.se.

resuelve.determinando.qué.es.lo.que.hay.que.medir.y.cómo.

va.hacérselo.(Ebel,.1977).

Hecha.esta.diferenciación,.quiero.desagregar.entonces.la.defi-

ni

ción.dada.para.presentar.algunos.problemas.inherentes.a

.las.

prácticas.de.evaluación.que.iré.desarrollando.más.adelante:

-. “(…). proceso.que”:.aparece.desde.aquí.la.referencia.a.la.eva-

l

uación.como.proceso.y.no.como.punto.de.llegada,.como.

resultado.o.como.una.instancia.desarticulada.entre.las.prácti-

c', 'chunk 253');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 254, 'as.que.involucra.(concretamente.las.de.enseñar.y.aprender)..

La.idea.procesual.de.la.evaluación.la.presenta.como.un.con-

junto

.de.acciones.que.se.realizan.y.suceden.en.el.tiempo.con.

una.determinada.intencionalidad..La.idea.de.proceso,.así,.no.

sólo.se.vincula.con.la.idea.de.la.continuidad,.intencionalidad.y.

tiempo.sino.también.con.la.idea.de.integración.de.las.acciones.

ent

re.sí.para.que.el.proceso.se.constituya.como.un.acontecer.

articulado.y.coherente..Cuando.evaluamos.o.nos.evaluamos.

necesitamos.asumir.esta.concepción.procesual.para.no.con-

vertirla

.en.una.‘instancia’.fragmentada.y.arbitraria.

-. “(…) .a.partir.del.conocimiento.y.comprensión.de.cierta.infor-

mación

”:.la.referencia.al.conocimiento.y.comprensión.de.la.

 145Más.didáctica.(en.la.educación.superior)

información.plantea.en.primer.lugar.la.pregunta.referida.a.qué.

es.lo.que.se.desea.conocer.y.comprender.y.luego,.y.en.razón.

de.ello,.la.pregunta.referida.a.cómo.se.hará.para.conocer.y.

comprender.esa.información..

-. “(…) .desde.una.actitud.dialógica”:.la.evaluación.didáctica.

no.puede.concebirse.en.ningún.caso.como.un.proceso.uni-

lateral,', 'chunk 254');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 255, '.sencillamente.porque,.por.lo.menos.hay.dos.partes.

involucradas..Si.cualquiera.de.ellas.asumiera.una.actitud.de.

imposición,.de.autoritarismo,.de.soberbia.o.de.indiferencia,.

atentaría.contra.el.carácter.esencialmente.humano.que.es.

propio.de.cualquier.actividad.pedagógica..Sin.diálogo.no.es.

posible.c

onocer,.ni.comprender,.ni.valorar,.ni.tomar.deci-

siones.

.O.más.aún,.sin.diálogo.probablemente.aquello.que.

se.crea.conocer.y.comprender.no.será.tal.y.aquello.que.se.

valore.y.se.decida.no.será.adecuado..Siempre.vigente,.nadie.

mejor.que.él.para.aclararlo:.“No.hay.palabra.verdadera.que.

no.sea.una.unión.inquebrantable.entre.acción.y.reflexión.y,.

por.ende,.que.no.sea.praxis..De.ahí.que.decir.la.palabra.ver-

dadera

.sea.transformar.el.mundo.(…).. Existir,.humanamente.

es.pronunciar.el.mundo,.es.transformarlo.(…). .Si.diciendo.

la.palabra.con.que.pronunciando.el.mundo.los.hombres.lo.

transforman,.el.diálogo.se

.impone.como.el.camino.mediante.

el.cual.los.hombres.ganan.significación.como.tales.(…). .Dado.

que.el.diálogo.es.el.encuentro.de.los.hombres.que.pronun-

cian

.el.mundo,.no.puede.existir.una.pronunciación.de.unos.', 'chunk 255');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 256, 'a.otros..Es.un.acto.creador..De.ahí.que.no.pueda.ser.mañoso.

instrumento.del.cual.eche.mano.un.sujeto.para.conquistar.a.

otro” (F reire,.1974)..

-. “(…) .emitir.un.juicio.de.valor”:.ahora.la.referencia.del.análisis.

nos.obliga.a.detenernos.en.la.idea.del.“juicio.de.valor”,.que.

en.correspondencia.con.la.idea.referida.a.que.“exige.comu-

nicar

.a.docentes.y/o.alumnos/as.–por.medio

.de.enunciados.

argumentativos–.el.juicio.de.valor.emitido.y.las.orientaciones.

que,.derivadas.de.éste,.resulten.necesarios.para.la.mejora.de.

la.práctica”.nos.obliga.a.pensar.tanto.en.el.problema.de.quién.

emite.el.juicio.valorativo.como.en.el.problema.de.la.devolu-

ción

.de.la.evaluación.y.en.aquello.que.se.suscita.a.partir.de.

la.evaluación.realizada..Y.estamos.aquí.frente.a,.lo.que.por.

lo.menos.para.mí,.constituye.uno.de.los.nudos.centrales.de.

146. Capítulo.3. .Las.prácticas.de.evaluación

la.evaluación:.¿qué.hay.después.de.una.evaluación.formali-

z

ada?,.¿qué.es.necesario.hacer.después.de.una.evaluación.

formalizada?

-. “

(…) .acerca.de.las.prácticas.de.enseñanza.y/o.las.prácticas.

de.aprendizaje”:.se.desprende.de.este.enunciado.el.tema.', 'chunk 256');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 257, 'del.‘qué’.evaluar.y.desde.allí.al.problema.de.los.criterios.de.

evaluación.

-

. “(…). en.un.contexto.sociohistórico.determinado.en.el.cual.

intervienen.con.particularidad.significante.lo.social.amplio,.la.

institución,.el.objeto.de.conocimiento,.el.grupo.de.alumnos/as.

y.el/la.docente”:.estamos.aquí.frente.a.ciertos.condicionantes.

o,.si.se.quiere,.frente.a.variables.contextuales.que.direccionan,.

que.favorecen.u.obstaculizan,.que.h

acen.que.los.factores.

intervinientes.(véase.punto.1:.“La.evaluación:.una.práctica.

compleja”).sean.de.mayor.o.menor.peso,.que.exigen.ser.con-

siderados

.a.lo.largo.de.todo.el.proceso.evaluador.

-. “(…). posibilita.tomar.decisiones.referidas.a.las.prácticas.de.

referencia”,.nos.hace.detener.particularmente.en.el.sentido.

de.la.evaluación.y.especialmente.en.las.decisiones.a.tomar.a.

partir.de.la.comprensión.de.la.vinculación.entre.la.información.

que.se.obtiene.y.las.prácticas.de.enseñanza.y.de.aprendizaje.

involucradas.

R

ealizadas.las.primeras.aclaraciones.conceptuales.y.definido.

mi.propio.posicionamiento.respecto.a.las.prácticas.de.evaluación,.

considero.ahora.necesario.desarrollar.algunos

.planteos.concep-

tuales', 'chunk 257');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 258, '.y.algunas.sugerencias.prácticas.que.anticipo.a.partir.del.

esquema.enunciativo.que.muestro.más.adelante.y.aunque.no.

seguiré.el.orden.organizativo.que.muestra.el.mismo.(sólo.intento.

mostrar.las.dimensiones.a.las.que.me.referiré),.consideraré.cada.

una.de.dichas.temáticas.en.las.páginas.siguientes.

Me.permito.realizar.antes.dos.aclaraciones:

-. la.primera.tiene.que.ver.con.las.hipótesis.hasta.aquí.vertidas:.

considero.crucial.abordar.la.evaluación.como.una.práctica.

compleja.y.partir.de.una.posición.que.asuma.la.necesidad.

de.desnaturalizar .las.prácticas.instaladas.para.trabajar.en.

 147Más.didáctica.(en.la.educación.superior)

torno.a.nuestras.propias.desvirtuaciones.y.a.nuestras.buenas.

resoluciones;

-

. la.segunda,.es.que.habiéndome.referido.en.primerísimo.lugar.

a.las.razones.que.motivan.la.puesta.en.marcha.de.un.proceso.

complejo.como.es.la.evaluación,.que.se.direcciona.de.modo.

diferente.según.sean.unas.u.otras.las.intenciones.de.quien.

evalúa.y.los.usos.que.se.hagan.de.sus.resultados,.entonces.

ahora.me.permito.incluir.algunas.ideas.y.propuestas.relacio-

nadas

.con.el.carácter.práctico.de.la.evaluación,.ya.que.a.la.', 'chunk 258');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 259, 'vez.que.veo.la.necesidad.de.instalar.un.debate.sobre.el.sen-

tido

.y.la.direccionalidad.de.las.prácticas,.también

.me.parece.

necesario.abordar.cuestiones.referidas.a.la.instrumentación,.

a.la.dimensión.‘técnica’.a.la.cual.me.he.referido.antes..Para.

trabajar.esta.dimensión.correré.el.riesgo.de.ejemplificar.sólo.

a.los.efectos.de.mostrar.mis.propias.elaboraciones.prácticas.

que.de.ninguna.manera.podrán.universalizarse.ni.tomarse.

como.modelos.

LA.

EVALUACIÓN.

COMO.UNA.

PRÁCTICA.

COMPLEJA

El

.problema.acerca.del.objeto.

de.la.evaluación

las.prácticas.de.la.enseñanza.

como.objeto

las.prácticas.de.aprendizaje.

como.objeto

El.problema.acerca.del.sujeto.

de.la.evaluación

el.docente.como.sujeto.

evaluador

el

.alumno/a.como.sujeto.

evaluador

El

.problema.acerca.de.los.

instrumentos.de.la.

evaluación

instrumentos

.de.evaluación.

de.la.enseñanza

instrumentos.de.evaluación.

de.los.aprendizajes

El.problema.acerca.de.los.

momentos.de.la.evaluación

la.evaluación.inicial

la.evaluación.de.seguimiento

la.evaluación.parcial

la.evaluación.final

148. Capítulo.3. .Las.prácticas.de.evaluación

4. La evaluación de las prácticas de enseñanza', 'chunk 259');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 260, 'He.definido.a.la.evaluación.didáctica.como.un.proceso.que.

permite.emitir.un.juicio.de.valor.acerca.de.las.prácticas.de.ense-

ñanza

.y/o.las.prácticas.de.aprendizaje..Al.adentrarnos.así.en.el.

objeto.de.la.evaluación,.en.la.pregunta.referida.a.‘qué’.evaluamos,.

distinguimos.claramente.estos.dos.objetos..Quiero,.en.primer.

lugar,.referirme.a.la.evaluación.de.las.prácticas.de.enseñanza.

Es.inevitable.que.al.hablar.de.‘evaluación.de.la.enseñanza’.se.

genere.algún.tipo.de.controversia..Las.tradiciones,.los.mitos,.las.

profecías.autocumplidas.imponen.falaces.argumentos.para.des-

estimar

.la.necesidad.de.evaluar.sistemáticamente.la.enseñanza..

En.los.debates.que.s

olemos.tener.en.el.interior.de.las.institucio-

n

es.de.educación.superior,.seguramente.hemos.escuchado,.más.

de.una.vez,.algunas.voces.refiriéndose.a.ello.con.discursos.que.

lo.plantean.más.o.menos.así:

-. “la.evaluación.a.los.docentes.se.inscribe.dentro.de.las.políticas.

neoliberales.de.evaluación.de.calidad”;

-. “sería.un.avasallamiento.a.la.libertad.de.cátedra”;

-. “los.alumnos.no.están.en.condiciones.de.opinar.respecto.a.

lo.que.hacemos.los.docentes”;', 'chunk 260');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 261, '-. “a.través.de.los.aprendizajes.que.evidencian.haber.alcanzado.

los.alumnos,.se.puede.tener.una.precisa.idea.del.acierto.o.no.

de.las.decisiones.tomadas.en.la.propuesta.de.

enseñanza”;.

-. “los.docentes.continuamente .nos.evaluamos .a.nosotros..

mismos”.

Cr

eo.que.en.todas.estas.afirmaciones.se.comete.algún.tipo.

de.error.y.quisiera.analizarlas.una.por.una..

“La evaluación a los docentes se inscribe dentro de las políticas 

neoliberales de evaluación de calidad”..

. N o .veo.conveniente .que.invalidemos .la.evaluación .de.la.

enseñanza.por.asimilarla.a.posibles.usos.que.las.políticas.

neoliberales.puedan.hacer.de.los.resultados..Es.más,.adhiero.

a.la.necesidad.de.evaluar.la.práctica.profesional.en.cualquier.

profesión.de.la.que.se.trate..En.todo.caso,.resistamos.todo.

intento.de.instalar.dispositivos.que.se.generen.desde.unidades.

centrales.o.todo.sistema.impuesto.‘desde.arriba’.al.respecto,.

pero.no.dejemos.de.participar .en.l

a.propia.evaluación .de.

 149Más.didáctica.(en.la.educación.superior)

la.enseñanza.porque.nos.enajenaríamos.en.nuestro.propio.

trabajo.

“Sería un avasallamiento a la libertad de cátedra”.', 'chunk 261');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 262, '. E n .nombre.de.la.libertad.de.cátedra.se.comete.más.de.un.

abuso..Y.nada.más.y.nada.menos,.porque.se.la.toma.desde.su.

contrasentido,.esto.es,.desde.una.concepción.que.considera.

que.por.la.libertad.se.puede.imponer.una.idea.contrade-

mocrática:

.“nadie.se.meta.conmigo”..Este.discurso.no.sólo.

desconoce.la.esencia.misma.de.la.libertad.de.cátedra.sino.que.

se.convierte.en.un.artilugio.hegemónico.al.tomar.el.discurso.

crítico.para.volverlo.autoritario..

“Los alumnos no están en condiciones de opinar respecto a lo 

que hacemos los docentes”. 

. Me

.recuerda.al.famoso.censor.de.la.dictadura,.que,.por.hacer.

un.bien.a.la

.sociedad,.no.sólo.decidía.qué.películas.se.podían.

ver.y.cuáles.no.en.el.cine,.sino,.aún.dentro.de.las.que.sí.se.

podían.ver,.qué.escenas.sí.y.qué.escenas.no,.sencillamente.

porque.no.estábamos.‘maduros’.como.sociedad.para.decidir.

por.nosotros.mismos..Es.el.mismo.argumento:.porque.los.

alumnos/as.son.‘inmaduros’.o.porque.son.‘niños’.o.porque.

‘no.saben’.no.pueden.emitir.opinión.alguna.respecto.a.una.

práctica.que.los.involucra.directamente..¿Y.entonces.quién?.

“A través de los aprendizajes que evidencian haber alcanzado', 'chunk 262');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 263, 'los alumnos, se puede tener una precisa idea del acierto o no de las 

decisiones tomadas en la propuesta de enseñanza”. 

. Esta

.afirmación.reduce.los.efectos.de.la.enseñanza.a.los.efec-

tos

.del.aprendizaje.y.estos.últimos.son.acaso.sólo.indicios.

que.pueden

.orientar.algún.análisis.sobre.nuestras.prácticas.

de.enseñanza,.pero.no.son.ni.pueden.ser.suficientes.porque.

la.enseñanza.es.una.práctica.de.tal.grado.de.complejidad.que.

no.puede.subsumirse.a.evidencias.que.se.manifiestan.a.través.

de.procesos.indirectos.(aunque.interdependientes).a.ella..

“Los docentes continuamente nos evaluamos a nosotros 

mismos”. 

. C reo .que.no.es.cierto,.ni.es.posible..Para.evaluar.hay.que.

disponer.de.información,.hay.que.sistematizar.un.procedi-

m

iento,.hay.que.objetivar.la.problemática,.hay.que.tener.

150. Capítulo.3. .Las.prácticas.de.evaluación

espíritu.democrático..No.podemos.evaluar.nuestra.práctica.

mientras.dormitamos.en.el.colectivo.o.en.la.sala.de.profesores.

cuando.compartimos.penurias.con.los.colegas..Si.queremos.

hacerlo.con.responsabilidad.profesional.habrá.que.construir.

el.hábito.de.la.evaluación.y.habrá.que.hacerlo.asumiendo.una.', 'chunk 263');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 264, 'posición.de.humildad.que.nos.aleje.de.todo.atisbo.de.sober-

b

ia.autosuficiente.y.habrá.que.asumirla.más.que.como.un.

deber,.como.un.derecho.que.nos.corresponde..Como.decía.el.

gran.maestro,.“enseñar.exige.humildad,.tolerancia.y.lucha.en.

defensa.de.los.derechos.de.los.educadores.(…). .Mi.respuesta.a.

la.ofensa.a.la.educación.es.l

a.lucha.política.conciente,.crítica.y.

organizada.contra.los.ofensores..Acepto.incluso.abandonarla,.

cansado,.a.la.espera.de.mejores.días..Lo.que.no.es.posible.es.

permanecer.en.ella.y.envilecerla.con.el.desdén.por.mí.mismo.

y.por.los.educandos”.(Freire,.1999).

4.1. ¿Qué evaluar en las prácticas de enseñanza?: 

 el problema del objeto

Pues.bien,.aquí.estamos.tras.habernos.adentrado.en.el.‘qué’.

de.la.evaluación.y.habernos.centrado.en.las.prácticas.de.ense-

ñ

anza.como.objeto.de.la.evaluación..Pero.ahora.es.necesario.

decidir.el.‘qué’.evaluar.de.las.prácticas.de.enseñanza..Segura-

m

ente,.y.concebida .como.intervención .intencionada .en.una.

práctica.social,

.la.enseñanza.adquiere.en.cada.docente.una.par-

t

icularidad.casi.idiosincrásica..Pero.también,.ciertas.recurrencias.', 'chunk 264');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 265, 'y.ciertas.variables.implicadas.en.toda.práctica.de.enseñar.hacen.

posible.enumerar.algunos.de.sus.componentes.como.una.prác-

t

ica.compartida .de.la.cual.participamos .en.general.todos.los.

docentes.con.ciertos.rasgos.en.común.y.que.pueden.constituir.

aquí.algunos.de.los.aspectos.a.evaluar:.

-. RESPECTO . A. LA. PREVISIÓN . DE. LOS. CONTENIDOS . A..

E

NSEÑAR:.

•. la.selección.que.hemos.hecho;

•. la.secuencia.por.la.que.hemos.optado;

•. la.organización.epistemológica;

•. la.organización.didáctica.

 151Más.didáctica.(en.la.educación.superior)

-. RESPECTO.A.LA.PRESENTACIÓN.DE.LOS.CONTENIDOS.A.

ENSEÑAR:.

•. la.claridad.en.la.presentación.oral;

•. la.posibilidad.de.ser.significados;

•. la.vinculación.con.las.prácticas.sociales;

•. la.vinculación.con.las.prácticas.profesionales;

•. la.articulación.que.se.evidencia.clase.a.clase.

-. RESPECTO.A.LAS.FORMAS.DE.INTERVENCIÓN:.

•. la.calidad.de.las.exposiciones .orales:.en.cuanto.son.

favorecedoras.de.la.presentación.comprensiva,.global.e.

integrada.de.los.contenidos;

•. las.preguntas.que.se.formulan.en.clase:.en.cuanto.son.

orientadoras.para.favorecer.la.comprensión;', 'chunk 265');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 266, '•. los.momentos.de.intercambio.dialogados:.en.cuanto.

son.intercambio.conceptual.de.ideas.fundamentadas;

•. las.orientaciones.que.s

e.dan.a.las.preguntas.de.los.alum-

n

os/as:.en.cuanto.son.orientadoras.para.favorecer.la.

comprensión;

•

. la.calidad.de.los.trabajos.prácticos.(u.otros.recursos.

didácticos.utilizados):.como.favorecedores.de.la.vincula-

ción

.con.las.realidades.prácticas.a.las.que.se.refieren;

•. la.calidad.de.las.actividades.grupales.de.discusión.pro-

p

uestas:.como.favorecedoras.del.intercambio.conceptual.

con.los.pares;

•. la.calidad.de.las.actividades.grupales.de.producción.pro-

p

uestas:.en.cuanto.ser.favorecedoras.de.trabajos.escritos.

originales.que.eviten.la.reproducción.textual.

-. RESPECTO.A.LA.ORGANIZACIÓN.GENERAL.DE.LA.CURSADA:

•. la.distribución.del.tiempo;

•. el.uso.de.los.espacios.del.aula;

•. la.secuencia

.entre.clases.teóricas.y.clases.de.trabajos.

prácticos;

•. e

l.funcionamiento.de.los.miembros.de.la.cátedra.como.

equipo.de.trabajo.(cuando.la.cátedra.no.es.unipersonal);

•. el.vínculo.entre.los.miembros.de.la.cátedra.y.los.alum-

nos/as;

•

. la.atención.a.las.consultas.personales.', 'chunk 266');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 267, '152. Capítulo.3. .Las.prácticas.de.evaluación

-. RESPECTO.A.LA.EVALUACIÓN:

•. la.relación.entre.contenidos.enseñados.y.contenidos.

evaluados;

•

. la.relación.entre.tareas.de.prueba.solicitadas.y.tareas.de.

enseñanza.en.clase.realizadas;

•. los.criterios.de.acreditación.utilizados;

•. la.propuesta.de.parciales;

•. la.asignación.de.calificaciones;

•. la.propuesta.de.examen.final.

4.2. ¿Cuándo evaluar las prácticas de enseñanza?: 

 el problema del tiempo

La.pregunta.referida.a.‘cuándo’.evaluar.la.enseñanza.es.de.res-

p

uesta.rápida..Si.consideramos.los.tipos.de.evaluación.en.cuanto.

a.su.intención.y.el.momento.en.el.cual.se.realizan,.rápidamente.

se.identifican.la.‘evaluación.inicial.o.diagnóstica’,.la.‘evaluación.

de.seguimiento.o.formativa’.y.la.‘

evaluación.de.cierre.o.final’..

Si.llevamos.estas.tres.categorías.(habitualmente.utilizadas.con.

referencia.a.la.evaluación.de.los.aprendizajes).al.ámbito.de.la.eva-

l

uación.de.las.prácticas.de.enseñanza,.creo.que.habría.que.tomar.

fundamentalmente.las.dos.últimas..Es.decir,.me.parece.relevante.

que.se.realicen.prácticas.de.evaluación.de.la.enseñanza.durante.', 'chunk 267');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 268, 'la.cursada.y.no.sólo.al.final..Porque.la.información.que.podemos.

obtener.–a.tiempo–.a.los.efectos.de.emitir.un.juicio.de.valor.refe-

r

ido.a.la.enseñanza,.podría.permitir.realizar.los.ajustes.necesarios.

en.nuestra.propuesta..Cuando.me.refiero.‘a.tiempo’,.quiero.decir,.

cuando.todavía.e

s.posible.de.ser.modificada,.cuando.un.cambio.

puede.favorecer.de.mejor.manera.nuestras.intervenciones.de.ense-

ñ

anza,.cuando.es.posible.aún.recuperar.tiempos.del.aprender.

Pasa.que,.en.general,.realizamos.a.los.alumnos/as,.algún.tipo.

de.encuesta.de.opinión.referida.a.la.cursada.cuando.ésta.termina..

La.información.que.obtenemos,.sobre.todo.cuando.da.cuenta.de.

algunos.puntos.débiles.en.nuestras.intervenciones,.ya.no.sirve.

para.cambiar.con.ese.grupo.y,.siguiendo.la.lógica.conceptual.de.

la.categoría.‘construcción.metodológica’,.¿quién.puede.asegu-

r

arnos.que.un.cambio.en.nuestra.práctica.realizado.a.partir.de.

 153Más.didáctica.(en.la.educación.superior)

cierta.evidencia.que.obtenemos.con.un.determinado.grupo.de.

alumnos/as.sea.pertinente.para.un.futuro.nuevo.grupo?.

4.3. ¿Quién evalúa las prácticas de enseñanza?: 

 el problema de los sujetos', 'chunk 268');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 269, 'Quiero.presentar.la.pregunta.referida.a.‘quién’.evalúa.sin.nue-

v

os.argumentos..Lo.he.dicho.y.lo.sigo.sosteniendo:.los.docentes.

necesitamos.evaluar.nuestras.propias.prácticas..Pero.para.que.

ello.sea.posible,.necesitamos.asumir.una.actitud.humilde,.tal.

como.ya.lo.expresé.anteriormente.y.recurrir.a.un.pensamiento.

elucidante.(Palou,.1998).que.permita.dilucidar.los.conflictos.para.

transformar.los.dilemas.en.problemas.y.así.encontrar.formas.de.

resolverlos..

Ahora.bien,.también.resulta.ineludible .que.a

lgún.tipo.de.

información.para.hacerlo,.provenga.de.forma.directa.de.los.alum-

nos/as.

.Si.alguien.creyera.que.pedir.opinión.a.los.alumnos/as.es.

ya.una.evaluación.realizada.por.ellos.hacia.nosotros,.puede.ser,.

realmente.no.me.preocupa.discutir.eso,.porque.también.acepto.

que.los.alumnos/as.evalúen.nuestras.prácticas.

4.4. ¿Cómo evaluar las prácticas de enseñanza?: 

 el problema de los instrumentos

Finalmente,.quiero.realizar.algunas.sugerencias.prácticas.para.

plantear.el.‘cómo’.evaluar.las.prácticas.de.enseñanza..Decidido.

qué.es.lo.que.queremos.saber,.podemos.prever.de.qué.modo.

instrumentaremos.dicha.búsqueda..Insisto.con.la.aclaración.de.', 'chunk 269');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 270, 'no.considerar .un.ejemplo.como.un.modelo.y.c

reo.necesario.

explicitarlos.por.su.valor.didáctico.como.concreción.operativa.

de.una.idea.teórica..Bajo.esos.supuestos,.he.aquí.algunas.pro-

puestas.

154. Capítulo.3. .Las.prácticas.de.evaluación

4.4.1. Cuando los docentes nos autoevaluamos 

 y la información proviene de nosotros 

 mismos

He.aquí.algunos.ejemplos.entre.los.múltiples.instrumen-

t

os.posibles.de.ser.usados.para.autoevaluar.las.prácticas.de.la..

enseñanza:

-

. Frases.incompletas:.participando.la.totalidad.del.equipo.de.

cátedra,.se.puede.exponer.la.opinión.de.cada.docente.ante.

ciertas.cuestiones.que,.a.fin.de.ponerlas.en.discusión,.se.

pueden.presentar.como.frases.incompletas..Algunos.ejemplos.

podrían.ser:

•. nuestro.mayor.logro.con.los.alumnos/as.fue…

•. lo.peor.que.hicimos.fue…

•. un.texto.que.podría.reemplazarse.es…

•. a.nuestros.trabajos.prácticos.les.falta…

•. no.nos.decidimos.a.asumir.que…

•. lo.que.más.me.preocupa.es…

•. podríamos.hacer.un.cambio.en…

-. Registros.textuales:.en.cada.clase,.un.miembro.de.la.cátedra.

(cuando.se.trata.de.cátedras.que.no.son.unipersonales).puede.', 'chunk 270');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 271, 'asumir.el.rol.de.observador.pasivo.y.registrar.la.oralidad.de.

la.clase,.confeccionando.un.registro.textual.de.los.discursos.

en.la.clase..Los.registros.dan.cuenta.de.todo.lo.que.‘se.dice’.

y.adoptan.formatos.parecidos.a.

éste:

“Docente–.Hoy.vamos.a.hablar.de.una.temática.de.absoluta.

importancia.para.la.gestión.de.recursos.humanos.

en.los.distintos.tipos.de.organizaciones.

Alumno–. (Interrumpiendo).¿Profesor,.cuáles.son.los.distintos.

tipos.de.organizaciones?

Docente–. Está.haciendo.una.pregunta.muy.elemental.para.

estar.en.segundo.año.de.la.carrera,.en.cualquier.

texto.básico.puede.encontrar.la.respuesta..Bien,.

como.les.decía,.a.la.hora.de.analizar.la.gestión.de.

recursos.humanos.(…)”.

 155Más.didáctica.(en.la.educación.superior)

La.oralidad .da.cuenta.del.pensamiento .práctico .(Pérez.y.

Gimeno.Sacristán, .1988).y.en.él.anidan.nuestros.prejuicios,.

nuestras.creencias,.nuestras.representaciones,.nuestras.ideolo-

g

ías..Muchas.veces,.sin.ser.concientes.de.ello,.afloran.en.nuestro.

discurso.y.se.convierten.en.verdaderos.obstáculos.para.el.apren-

d

izaje.de.los.alumnos..¿Realizará.alguna.vez.una.nueva.pregunta.', 'chunk 271');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 272, 'quien.ha.recibido.por.respuesta:.“está.haciendo.una.pregunta.

muy.elemental.para.estar.en.segundo.año.de.la.carrera…”?

Haciendo .uso.de.los.registros .que.se.posean, .cuando.el.

equipo.de.cátedra.se.reúne.formalmente,.se.puede.hacer.la.lec-

tura

.de.alguno.de.ellos.a.fin.de.poder.analizar

.algún.nudo.pro-

blemático

.de.las.categorías.didácticas.implicadas.en.la.clase..La.

cátedra.podrá.analizar.y.evaluar.algunos.aspectos.de.las.inter-

venciones

.de.enseñanza.y,.ciertamente,.podrán.autoproponerse.

mejoras.en.las.mismas..Según.sea.la.riqueza.de.la.discusión.que.

se.genere.y.la.disponibilidad.de.tiempo,.podrán.analizarse.o.no.

otros.registros.

-. Problemas.focalizados:.la.cátedra.puede.realizar.un.listado.

de.los.distintos.aspectos.que.hacen.a.su.actividad.acadé-

mica,

.seleccionar.uno.de.ellos.y.lo.analizarlo.profundamente.

a.fin.de.encontrar .dentro.de.él,.la.cuestión .que.resulte.

sustancialmente.problemática..Luego.decidir.una.estrategia.

de.solución.a.implementar

.y.finalmente.ponerla.en.práctica..

A.fin.de.evaluar.si.ésta.ha.resultado.beneficiosa,.convendría.

llevar.un.registro.de.las.acciones.que.se.van.realizando.al.

respecto.', 'chunk 272');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 273, '4.4.2. Cuando los docentes nos autoevaluamos y 

 la información proviene de los/las alumnos/as

Entre.algunos.de.los.instrumentos.de.posible.utilización.para.

recabar.información.respecto.de.la.enseñanza.por.parte.de.los.

alumnos/as,.muestro.aquí.algunos.ejemplos:

-. Opiniones.breves:.convendría.generar.también.desde.la.dis-

t

ribución.física.en.el.aula,.cierto.clima.de.‘escucha’.y.reflexión.

(por.ejemplo.que.el.grupo.mueva.sus.sillas.y.se.siente.en.

forma.circular).para.que,.alumno/a.por.alumno/a.exprese.de

.

156. Capítulo.3. .Las.prácticas.de.evaluación

manera.sintética.su.parecer.acerca.de.ciertas.cuestiones.que.

el.docente.pueda.presenta.oralmente,.como.por.ejemplo:

•. mi.opinión.frente.a.las.clases.teóricas…

•. mi.opinión.frente.a.las.clases.de.trabajos.prácticos…

•. un.aspecto.que.debiera.ser.mejorado…

•. mi.análisis.de.una.dificultad.que.no.pudo.ser.

. solucionada.hasta.ahora…

•. mi.parecer.respecto.a.que.lo.distintivo.de.esta.cátedra.

es…

-

. Cuestionarios .abiertos: .es.un.instrumento .de.resolución.

escrita.e.individual.que.puede.contestarse.en.forma.anónima..

Habitualmente.un.cuestionario.abierto.se.confecciona.con.', 'chunk 273');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 274, 'una.serie.de.preguntas.cuyas.respuestas.no.pueden.realizarse.

con.una.sola.palabra.(del.tipo.‘sí’,.‘no’,.‘bien’.u.otras.simila-

r

es)..Por.el.contrario,.un.cuestionario.no.delimita.de.antemano.

las

.alternativas.de.respuesta.posibles.y.deja.libertad.para.que.

quien.contesta.se.exprese.a.través.de.su.propia.redacción.

y.lo.haga.según.lo.que.considere.oportuno.manifestar..Por.

ejemplo:

•. ¿Qué.opinión.en.general.te.has.formado.de.esta.cátedra.

a.lo.largo.de.la.cursada?

•. ¿Qué.aspectos.que.resulten.ser.responsabilidad.de.la.cáte-

d

ra,.valorás.como.muy.positivos.para.tu.aprendizaje?

•. ¿Qué.obstáculos.encontraste.para.poder.seguir.el.ritmo.

de.la.cursada.clase.a.clase?

•. ¿Qué.modificarías.de.lo.realizado.hasta.ahora.dentro.

de.los.límites.de.lo.posible.de.implementar.inmedia-

tamente?

-

. Trabajos.grupales:.dinámicas.diferentes.de.organización.de.

grupos.a.través.de.las.cuales,.según.sea.la.tarea.asignada,.

se.podrá.brindar.una.instancia.para.que,.en.primer.lugar,.los.

alumnos/as.distribuidos.en.subgrupos.discutan.su.parecer.y

.

 157Más.didáctica.(en.la.educación.superior)

en.segundo.lugar.lo.comuniquen.a.la.cátedra..Por.ejemplo,.a.', 'chunk 274');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 275, 'través.de.un.‘pequeño.grupo.de.discusión’:

•. Enumeren.tres.aspectos.sustancialmente.positivos.de.

la.cursada

•. Enumeren.tres.aspectos.negativos.de.la.cursada

•. Propongan.un.cambio.necesario.en.la.cursada

•. Si.esta.cátedra.fuera….

-. una.película,.¿cuál.sería.y.por.qué?

-. un.estado.del.tiempo,.¿cuál.sería.y.por.qué?

-. un.color,.¿cuál.sería.y.por.qué?

-. un.personaje.histórico,.¿cuál.sería.y.por.qué?

-. un.juguete,.¿cuál.sería.y.por.qué?

-. Escalas.de.valoración:.también.se.trata.de.un.instrumento.

escrito.e.individual.que.puede.ser.contestado.en.forma.anó-

nima.

.Se.puede.realizar.una.lista.de.aspectos,.colocando.una.

valoración .(como.podría.ser:.muy.bueno,.b

ueno,.regular,.

malo).a.cada.uno.de.ellos..En.este.casos,.cada.alumno/a.

selecciona.la.valoración.que.considera.apropiada.para.cada.

uno.de.los.aspectos.señalados..Puede.completarse.con.dos.o.

tres.preguntas.abiertas.que.amplíen.la.información.requerida.

ya.que.al.contestarse.sólo.colocando.cruces.no.hay.explica-

ciones

.acerca.de.por.qué.se.valora.como.se.lo.hace..He.aquí.

un.ejemplo.que.puede.utilizarse.al.finalizar.una.cursada4:.', 'chunk 275');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 276, '4. Obsérvese .que.los.tres.últimos.ítems.de.esta.escala.se.referencian .sobre.

el.aprendizaje .y.no.sobre.la.enseñanza, .a.los.efectos .que.la.información.

cotejada.pueda.ser.contextualizada.

158. Capítulo.3. .Las.prácticas.de.evaluación

Superadas

Cumplidas

P

oco.cumplidas

No.cumplidas

Respecto.a.las.expectativas.con.que.iniciaste.la.

cursada,.ahora.las.evaluás.como:

Muy.bueno

Bueno

Regular

Malo

El.nivel.académico.de.la.cátedra.

La.selección.de.los.contenidos.realizada.por.la.cátedra.

La.selección.de.textos.bibliográficos.realizada.por.la.

cátedra

La

.claridad.con.que.se.presentaron.las.temáticas

La.articulación.de.los.contenidos.clase.a.clase

La.calidad.de.los.bloques.expositivos

La.calidad.de.las.actividades.grupales.propuestas

La.metodología.de.trabajo.empleada.en.las.clases

La.articulación.teoría-práctica

La.propuesta.de.organización.de.la.cursada

El.funcionamiento.de.los.miembros.de.la.cátedra.como.

equipo.de.trabajo

El.vínculo.académico.establecido.entre.los.docentes.y.

los.alumnos/as

La.propuesta.de.trabajos.prácticos

El.asesoramiento.realizado.por.la.cátedra.ante.

consultas.personales

La.propuesta.de.evaluación.

en.los.exámenes.parciales', 'chunk 276');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 277, 'La.propuesta.de.evaluación.para.el.examen.final

Tu.propio.aprendizaje.construido.en.esta.cursada

El.seguimiento.personal.que.pudiste.hacer.de.la.

cursada

T

u.propia.responsabilidad.puesta.en.juego.en.la.

cursada

Aspectos

.sustancialmente.positivos:.

……………………………………………………………………………………

……………………………..…………………………………………………….

Aspectos

.sustancialmente.negativos:.

……………………………………………………………………………………

……………………………..……………………………………………….........

¿Alguna

.sugerencia?.

 159Más.didáctica.(en.la.educación.superior)

5. La evaluación de las prácticas de aprendizaje

Creo.necesario.volver.una.vez.más.sobre.el.concepto.de.eva-

l

uación.didáctica.que.he.enunciado, .para.retomar.la.relación.

entre.evaluación.y.aprendizajes..Al.comienzo.de.este.capítulo.la.

he.planteado.como.un.proceso.que,.a.partir.del.conocimiento.

y.comprensión.de.cierta.información,.permite,.desde.una.acti-

t

ud.dialógica,.emitir.un.juicio.de.valor.acerca.de.las.prácticas.

de.enseñanza.y/o.las.prácticas.de.aprendizaje.en.un.contexto.

sociohistórico.determinado.en.el.cual.intervienen.con.particu-

laridad

.significante.lo.social.amplio,.la.institución,.el.objeto.de.', 'chunk 277');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 278, 'conocimiento,.el.grupo.de.alumnos/as.y.el/la.docente.y.que.tanto.

posibilita.tomar.decisiones.r

eferidas.a.las.prácticas.de.referencia.

como.exige.comunicar.a.docentes.y/o.alumnos/as.–por.medio.

de.enunciados.argumentativos–.el.juicio.de.valor.emitido.y.las.

orientaciones.que,.derivadas.de.éste,.resulten.necesarios.para.la.

mejora.de.la.práctica...

Mis.primeras.aclaraciones.entonces.se.refieren.a.que.la.eva-

l

uación.de.los.aprendizajes.en.la.educación.superior.también.

supone:

-

. conocer.y.comprender.qué.es.lo.que.sabe.un.alumno/a.cuando.

es.evaluado,.o.por.lo.menos,.qué.tipo.de.manifestación.del.

saber.se.expresa.cuando.es.evaluado.utilizando.un.determi-

n

ado.instrumento.(por.ejemplo.poder.preguntarnos.si.cuando.

un.alumno/a.contesta.con.estilo

.‘telegramático’.–tipo.tele-

grama–

.a.una.de.nuestras.preguntas.en.un.examen.parcial.

escrito.hay.problemas.con.el.saber.específico.o.con.el.manejo.

de.la.lengua.escrita);

-. poseer.una.actitud.dialógica.lo.cual.supone.primariamente.

saber.comunicar.y.saber.escuchar.en.toda.y.cualquier.cir-

cunstancia

.(por.ejemplo.cuando.un.alumno/a.nos.pregunta,.

no.siempre.de.buen.modo,.por.qué.ha.sido.desaprobado);', 'chunk 278');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 279, '-. tomar.decisiones.una.vez.que.la.información.que.obtenemos.

ha.sido.comprendida.(por.ejemplo.elaborar.rutas.conceptuales.

para.orientar.el.estudio.si.una.gran.parte.de.una.comisión.ha.

desaprobado.en.un.parcial);.

-. realizar.una.devolución.o

rientativa.de.las.producciones.de.los.

alumnos/as.(por.ejemplo.devolver.un.parcial.con.enunciados.

cualitativos.y.no.sólo.la.asignación.de.una.calificación).

160. Capítulo.3. .Las.prácticas.de.evaluación

Si.bien,.lo.primero.que.todos.pensamos.cuando.nos.referi-

mos

.a.la.evaluación.de.los.aprendizajes.es.en.parciales.y.finales,.

de.la.definición.se.desprende.que.el.proceso.de.evaluación.de.

los.aprendizajes.no.se.reduce.a.la.asignación.de.calificaciones..

Por.ello.conviene.entonces.diferenciar .primero.evaluación .de.

acreditación..Se.trata.de.un.proceso.de.acreditación.cuando.la.

evaluación.realiza.un.reconocimiento.institucional.de.los.apren-

dizajes

.adquiridos.por.los.alumnos/as,.constatados.a.través.del.

uso.de.ciertos.instrumentos.(parciales.escritos,.finales.orales,.

trabajos.prácticos,.etc.).y.comunicados.a.través.de.una.escala.

convencional.conceptual.(Aprobado/Desaprobado;.MB/B/R/M,.

etc.),.numérica.(', 'chunk 279');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('steiman_mas_didactica_nivel_superior', 280, '1/10).o.alfabética.(A-B-C-D-E) .que.resulta.de.

la.consideración.de.ciertos.criterios.que.se.han.priorizado.para.

tomar.la.decisión.al.respecto..En.este.proceso.la.‘calificación’.

resulta.ser.esa.instancia.de.la.acreditación.en.la.que.el.docente.

o.equipo.docente.comunica.al.alumno/a.a.través.de.una.escala.

convencional.sus.apreciaciones.y.su.juicio.valorativo.en.relación.

con.los.aprendizajes.realizados..

¿Por.qué.me.refiero.a.la.acreditación.como.proceso?.Porque.la.

‘certificación’.no.se.reduce.a.tomar.una.prueba,.corregirla.y.califi-

c

arla..El.proceso.se.inicia.con.la.decisión.acerca.de.qué.(qué.con-

tenidos,

.qué.trabajos.cognitivos).se

.solicitará.a.los.alumnos/as,.

cómo.se.lo.solicitará.(con.qué.instrumento),.cómo.se.asignará.

la.calificación.(con.qué.escala,.desde.qué.criterios,.cómo.se.asig-

n

ará.la.calificación,.con.relación.a.cuántos.puntos.por.cada.tarea.

solicitada.o.cuántos.puntos.por.cada.criterio.establecido),.cómo.

se.devolverá.(qué.tipo.de.orientaciones .para.que.el.alumno/a.

pueda.rever.su.propio.proceso.de.aprendizaje)..¿Cuándo.termina.

este.proceso.así.iniciado?.Seguramente.no.pueda.establecerse.

un.punto.de.cierre..', 'chunk 280');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 1, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] No se encontró el array "materias" en el HTML
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] const\s+pdfUrl\s*=\s*''([^'']+)''
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] \'') { escape = true; } else if (ch == "
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ) { inSingle = false; } continue; } if (inDouble) { if (escape) { escape = false; } else if (ch == r''\'') { escape = true; } else if (ch == ''
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ) { inDouble = false; } continue; } if (ch == "
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ) { inSingle = true; continue; } if (ch == ''', 'texto app chunk 1');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 2, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ) { inDouble = true; continue; } if (ch ==
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ) { depth++; } else if (ch ==
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] : isSpecial, }; if (text != null && text.trim().isNotEmpty) { out[
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/data/html_source_loader.dart] ] = text.trim(); } det.add(out); } map[
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/calculadora_screen.dart] pantalla/pantalla_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/correlativas_list.dart] No es correlativa con otras materias.', 'texto app chunk 2');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 3, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] \b(iii|3|tercera|3ro|tercero)\b
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Todas las UC de 1°, 2° y 3° año
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Práctica Docente II - Educación Secundaria y Práctica Docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Practica Docente II - Educacion Secundaria y Practica Docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Sujeto de la Educación Secundaria', 'texto app chunk 3');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 4, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Sujetos de la Educación Secundaria
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Didáctica de las Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Didactica de las Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Procesos Sociales, políticos, económicos y culturales del Feudalismo y la Modernidad', 'texto app chunk 4');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 5, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Procesos sociales, políticos, económicos y culturales Americanos I
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Procesos Sociales, políticos, económicos y culturales Americanos I
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Organización del Espacio Geográfico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Organizacion del Espacio Geografico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Sistema Urbano y Desarrollo Rural Argentino', 'texto app chunk 5');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 6, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Problemática de la Ciencia Política II
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_pd_especiales.dart] Problematica de la Ciencia Politica II
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Con las condiciones formales actuales del plan, esta cursada todavía no aparece habilitada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Podés cursar con restricciones
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Con las condiciones formales actuales del plan, esta cursada aparece habilitada con algunas restricciones.', 'texto app chunk 6');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 7, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Puede cursar sin restricciones
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Con las condiciones formales actuales del plan, esta cursada aparece habilitada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Podés cursar con restricciones
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Puede cursar sin restricciones
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Lectura del escenario actual', 'texto app chunk 7');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 8, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Esta lectura ordena condiciones formales del plan. Igual, conviene cruzarla con la propuesta de cátedra, los cronogramas y las condiciones institucionales de este año.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/panel/panel_resultado.dart] Sugerencia de recorrido: $strategy
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/banner_colapsable_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/bloque_autor_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/bloque_selectores_calculadora.dart', 'texto app chunk 8');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 9, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/resumen_materia_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/tarjeta_hero_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/tarjeta_paso_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] widgets/tarjeta_placeholder_calculadora.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] Elegí la carrera de referencia', 'texto app chunk 9');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 10, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] La lectura cambia según el plan y la institución que tomás como referencia.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] Elegí el año donde se ubica la materia para leer sus condiciones de cursada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] Seleccioná la materia que querés revisar para ver qué escenario se abre hoy.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] Seleccioná un año y una materia para leer las condiciones de cursada de ese tramo.', 'texto app chunk 10');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 11, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/pantalla_calculadora.dart] Seleccioná una carrera para habilitar esta lectura situada del plan.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/bloque_autor_calculadora.dart] Desarrollo y curaduría inicial: Alan Gabriel Maillet.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/bloque_autor_calculadora.dart] Material didáctico de apoyo, pensado para leer condiciones reales de cursada y acompañar decisiones concretas desde una mirada estudiantil.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/bloque_selectores_calculadora.dart] -- Seleccioná una materia --', 'texto app chunk 11');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 12, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/bloque_selectores_calculadora.dart] -- Seleccioná una materia --
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/tarjeta_hero_calculadora.dart] Esta pantalla no busca reducir el recorrido a un sí o un no aislado.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/tarjeta_hero_calculadora.dart] Te ayuda a leer, en contexto, qué condiciones ya cumpliste, cuáles siguen pendientes
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/calculadora/pantalla/widgets/tarjeta_hero_calculadora.dart] y qué escenario de cursada se abre hoy para la materia que estás mirando.', 'texto app chunk 12');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 13, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] pantalla/pantalla_mapa_correlatividades.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Mapa de Correlatividades: ¿Qué Me Falta?
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Con ¿Qué Me Falta? podés ver al instante qué materias te faltan para cursar o rendir. Seleccionás la materia en un mapa interactivo y el sistema te muestra sus correlativas previas y posteriores. Así sabés exactamente qué te habilita a seguir avanzando.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Educación Secundaria en Geografía', 'texto app chunk 13');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 14, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Resolución N° 0766 C.G.E. | Expte. Grabado N° (1507261) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Educación Secundaria en Historia
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Resolución N° 0765 C.G.E. | Expte. Grabado N° (1506606) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.', 'texto app chunk 14');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 15, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Artes Visuales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Resolución N° 0440/23 C.G.E. | Expte. Grabado N° (1943528) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Música con Orientación en Educación Musical
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"', 'texto app chunk 15');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 16, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Resolución N° 2867/23 C.G.E. | Expte. Grabado N° (2856760) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Educación Física
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Instituto Superior de las Especialidades de la Educación Física
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Resolución N° 0338/23 C.G.E. | Expte. Grabado N° (1943502) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado de Educación Secundaria en Ciencia Política', 'texto app chunk 16');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 17, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Régimen de Correlatividades Vigente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Este sistema está basado en el régimen de correlatividades actual para la carrera de
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] que se cursa en $articuloCentro
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Entendé los colores y etiquetas del mapa.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Formación común y transversal.', 'texto app chunk 17');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 18, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Materia regular teórica/práctica.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Estudio intensivo de un tema específico.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Espacio práctico de producción.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Combinación aplicada de seminario.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Definido por la institución (UDI).
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Abreviatura del nombre de la materia.', 'texto app chunk 18');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 19, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Requisito especial (ej. tener todas aprobadas).
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] © 2025 Alan Gabriel Maillet — Autor original Todos los derechos reservados.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Material educativo didáctico, creado con la única intención de facilitarle la vida a los estudiantes.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Seleccioná el tipo de carrera
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/cascada_screen.dart] Elegí primero el tipo de carrera
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] panel_detalle/panel_detalle_materia.dart', 'texto app chunk 19');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 20, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] pr[aá]ctica\s+profesional\s+docente\s+(iv|4)
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] \b(iii|3|tercera|3ro|tercero)\b
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Todas las UC de 1°, 2° y 3° año
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Práctica Docente II - Educación Secundaria y Práctica Docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Practica Docente II - Educacion Secundaria y Practica Docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Sujeto de la Educación Secundaria', 'texto app chunk 20');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 21, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Sujetos de la Educación Secundaria
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Didáctica de las Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Didactica de las Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Procesos Sociales, políticos, económicos y culturales del Feudalismo y la Modernidad
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Procesos sociales, políticos, económicos y culturales Americanos I', 'texto app chunk 21');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 22, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Procesos Sociales, políticos, económicos y culturales Americanos I
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Organización del Espacio Geográfico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Organizacion del Espacio Geografico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Sistema Urbano y Desarrollo Rural Argentino
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Problemática de la Ciencia Política II
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Problematica de la Ciencia Politica II', 'texto app chunk 22');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 23, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Todas las UC de 1°, 2° y 3° año (APROBADAS)
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] Todas las UC de Primer año (APROBADAS)
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/detail_panel.dart] No es correlativa con otras materias.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/grilla/grilla_materias.dart] widgets/tarjeta_materia_grilla.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/grilla/utils/estilos_chips.dart] práctica profesional docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/grilla/utils/estilos_chips.dart] practica profesional docente', 'texto app chunk 23');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 24, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/inicio_mapa_screen.dart] pantalla/pantalla_inicio_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] utils/reglas_practicas_detalle.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] secciones/correlativas_requeridas.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] secciones/materias_que_habilita.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] componentes/controles_superiores.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] DetailPanel: selectedId null', 'texto app chunk 24');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 25, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] No pudimos recuperar la materia seleccionada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] DetailPanel: plan null for selectedId=$selectedId
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] Cargando correlativas, comunidad y referencias...
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] No encontramos esa materia en el plan cargado.', 'texto app chunk 25');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 26, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] Esta ficha reúne relaciones formales del plan y referencias de cursada. Conviene leerla junto con la propuesta de cátedra y las condiciones concretas de este tramo.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/panel_detalle_materia.dart] Cargando referencias, fotos y docentes vinculados...
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/secciones/correlativas_requeridas.dart] Todas las UC de 1°, 2° y 3° año (APROBADAS)
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/secciones/correlativas_requeridas.dart] Todas las UC de Primer año (APROBADAS)', 'texto app chunk 26');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 27, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/secciones/materias_que_habilita.dart] No es correlativa con otras materias.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] pr[aá]ctica\s+profesional\s+docente\s+(iv|4)
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] \b(iii|3|tercera|3ro|tercero)\b
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Todas las UC de 1°, 2° y 3° año
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Práctica Docente II - Educación Secundaria y Práctica Docente', 'texto app chunk 27');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 28, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Practica Docente II - Educacion Secundaria y Practica Docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Sujeto de la Educación Secundaria
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Sujetos de la Educación Secundaria
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Didáctica de las Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Didactica de las Ciencias Sociales', 'texto app chunk 28');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 29, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Procesos Sociales, políticos, económicos y culturales del Feudalismo y la Modernidad
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Procesos sociales, políticos, económicos y culturales Americanos I
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Procesos Sociales, políticos, económicos y culturales Americanos I', 'texto app chunk 29');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 30, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Organización del Espacio Geográfico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Organizacion del Espacio Geografico Americano
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Sistema Urbano y Desarrollo Rural Argentino
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Problemática de la Ciencia Política II
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/panel_detalle/utils/reglas_practicas_detalle.dart] Problematica de la Ciencia Politica II', 'texto app chunk 30');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 31, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/banner_colapsable_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/callout_examenes.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/tarjeta_autor_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/tarjeta_leyenda_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/tarjeta_presentacion_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] widgets/tarjeta_regimen_correlatividades.dart', 'texto app chunk 31');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 32, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] Una lectura situada del recorrido de cursada
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_inicio_mapa.dart] Desde aca podes ubicarte en el plan, leer la referencia normativa que acompana cada carrera y entrar a las herramientas principales con mas contexto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] utils/decoraciones_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/banner_colapsable_mapa.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/barra_controles_una_linea.dart', 'texto app chunk 32');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 33, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/callout_examenes.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/selector_carrera_standalone.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/tablero_anios_desktop.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] widgets/tarjeta_regimen_correlatividades.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] Mapa de correlatividades y recorrido', 'texto app chunk 33');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 34, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] Elegí una carrera para abrir el mapa
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] Esta pantalla organiza correlatividades, bloqueos y habilitaciones del plan, pero no agota el sentido formativo de cada materia. Sirve para leer relaciones, ubicar tramos y preparar decisiones concretas de cursada con más contexto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/pantalla_mapa_correlatividades.dart] Primero elegí una carrera. Cuando la selecciones, se abren la referencia normativa, los filtros y la grilla para empezar a leer ese recorrido en contexto.', 'texto app chunk 34');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 35, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/barra_controles_una_linea.dart] estado_requiere_carrera.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/barra_controles_una_linea.dart] institution_selection_overlay.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/barra_controles_una_linea.dart] Seleccioná una carrera para habilitar institución, búsqueda, filtros y descarga.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/callout_examenes.dart] Cruza la lectura del plan con fechas, llamados y coloquios para tomar decisiones concretas sobre inscripción, correlativas pendientes y próximos movimientos de cursada.', 'texto app chunk 35');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 36, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/selector_carrera_standalone.dart] institution_selection_overlay.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/selector_carrera_standalone.dart] Seleccioná el tipo de carrera
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/selector_carrera_standalone.dart] Elegí primero el tipo de carrera
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_autor_mapa.dart] Desarrollo y curaduria inicial: Alan Gabriel Maillet.', 'texto app chunk 36');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 37, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_autor_mapa.dart] Material didactico de apoyo, pensado para hacer mas clara la lectura del plan y acompanar decisiones concretas de cursada desde una mirada estudiantil.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Lee los colores y las etiquetas dentro del contexto del plan.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Formacion comun y transversal.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Materia regular, teorica o practica.', 'texto app chunk 37');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 38, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Estudio intensivo de un tema especifico.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Espacio practico de produccion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Combinacion entre seminario y taller.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Definido por la institucion (UDI).
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Abreviatura usada para hacer más legible la materia dentro del mapa.', 'texto app chunk 38');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 39, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_leyenda_mapa.dart] Condición especial que no se explica solo por una correlativa puntual.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] premium_feature_accordion.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Ubica rapido una materia cuando quieres revisar un tramo puntual del plan.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Puedes buscar por nombre o por codigo para abrir una consulta puntual y mirar con mas detalle la parte del recorrido formativo que te interesa.', 'texto app chunk 39');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 40, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Ayuda a entrar por una duda concreta sin perder el resto del contexto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Sirve para revisar decisiones de cursada, regularidad o examen.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Mira que condiciones tienes que cumplir antes de llegar a esa materia.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] El mapa muestra las correlativas que la condicionan para que puedas leer que te falta hoy y por que ese recorrido aparece ordenado de ese modo.', 'texto app chunk 40');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 41, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Distingue si el requisito es por aprobacion o por regularidad.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Hace visible que el avance no depende solo de una materia aislada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Descubre que nuevas posibilidades se abren cuando apruebas una correlativa importante.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] No solo ves lo que falta hacia atras. Tambien puedes mirar como una materia reorganiza lo que viene despues dentro del plan.', 'texto app chunk 41');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 42, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Ayuda a detectar materias clave dentro del plan.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Permite pensar el avance como una trama y no como una lista suelta.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Ordena la vista por carrera, ano o tipo para leer el plan desde un recorte mas manejable.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Antes de explorar, puedes ajustar los filtros para acotar la consulta y leer solo el tramo del plan que necesitas en este momento.', 'texto app chunk 42');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 43, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Reduce ruido cuando el plan tiene muchas materias.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Te deja empezar desde un recorte situado y no desde el mapa entero.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Cada materia abre su red para que sigas relaciones sin perder el contexto del plan.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Al tocar una materia puedes moverte por sus conexiones y entender mejor como se encadenan las condiciones de cursada, aprobacion y avance.', 'texto app chunk 43');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 44, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Convierte una lista estatica en una lectura mas relacional.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Facilita seguir recorridos sin salir de la herramienta.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Usa lo que ves para decidir que conviene cursar, regularizar o rendir en el siguiente tramo.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] La herramienta no solo responde una duda puntual. Tambien sirve para ordenar decisiones reales de cursada con mas criterio y menos intuicion aislada.', 'texto app chunk 44');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 45, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Ayuda a priorizar materias con mayor efecto sobre el resto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Te da una base mas clara para conversar y planear la siguiente cursada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Lectura interactiva del plan
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Mapa de Correlatividades Que me falta
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_presentacion_mapa.dart] Consulta, interpreta y ordena tu recorrido de cursada', 'texto app chunk 45');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 46, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] estado_requiere_carrera.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] premium_feature_accordion.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] tarjeta_acordeon_inicio.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] El marco de lectura cambia con la carrera que estes viendo
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Base normativa de la carrera activa', 'texto app chunk 46');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 47, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Aqui ves la referencia normativa de la carrera seleccionada, junto con el recorte del plan que se esta leyendo en esta vista.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Esta referencia acompaña la carrera que estas viendo para interpretar correlativas, avance y alcance del plan sin mezclar marcos de otra carrera o institución.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Selecciona una carrera para ver la referencia', 'texto app chunk 47');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 48, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Selecciona una carrera para cargar la referencia normativa
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Cuando elijas una carrera, este bloque mostrará la institución y la norma que corresponden a esa vista.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Este panel se actualiza con la carrera elegida para mostrar la institución, el alcance y la norma de referencia que ordenan esa lectura.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Identifica rápido sobre qué carrera se aplica esta referencia.', 'texto app chunk 48');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 49, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] La lectura del mapa toma esta carrera como referencia para interpretar correlativas, alcances y condiciones visibles en la grilla.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Se actualiza automáticamente cuando cambias de carrera.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Muestra la institución que sostiene la referencia usada en esta vista.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Este dato te ayuda a ubicar el plan correcto cuando comparas carreras o revisas documentos de distintas instituciones.', 'texto app chunk 49');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 50, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Se mantiene sincronizado con la carrera seleccionada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Aclara desde que marco se interpretan las correlativas y el avance de la carrera.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] El sistema usa el régimen vigente de esta carrera para ordenar la lectura del mapa y evitar mezclar reglas de otro plan o institución.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] La vista adapta correlativas, avance y alcance al plan activo.', 'texto app chunk 50');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 51, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Sirve como contexto antes de revisar materias puntuales.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Todavía no hay una norma cargada para mostrar en este panel.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resume la norma usada como apoyo para interpretar esta carrera.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Cuando se incorpore la referencia documental de esta carrera, va a aparecer acá con el mismo formato que el resto de los planes.', 'texto app chunk 51');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 52, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Esta referencia documental acompaña la lectura de la carrera activa y te da una base concreta para ubicar el régimen correspondiente.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Referencia normativa en actualizacion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Mientras tanto, el mapa sigue tomando la carrera activa como contexto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Te sirve para contrastar la lectura visual con su respaldo documental.', 'texto app chunk 52');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 53, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Explica dónde encontrar la descarga del respaldo documental vinculado a la carrera.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Si necesitas revisar el texto original, puedes usar el boton de descarga del panel de controles sin salir del flujo principal del mapa.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] La descarga se gestiona desde el panel de controles.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Te permite contrastar la lectura visual con el documento fuente.', 'texto app chunk 53');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 54, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Educacion Secundaria en Geografia
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resolucion N 0766 C.G.E. | Expte. Grabado N (1507261) | Provincia de Entre Rios - Consejo General de Educacion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Educacion Secundaria en Historia', 'texto app chunk 54');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 55, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resolucion N 0765 C.G.E. | Expte. Grabado N (1506606) | Provincia de Entre Rios - Consejo General de Educacion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Artes Visuales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Escuela Secundaria y Superior N 1 "Cesareo Bernaldo de Quiros"', 'texto app chunk 55');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 56, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resolucion N 0440/23 C.G.E. | Expte. Grabado N (1943528) | Provincia de Entre Rios - Consejo General de Educacion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Musica con Orientacion en Educacion Musical
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Escuela Secundaria y Superior N 1 "Cesareo Bernaldo de Quiros"
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resolucion N 2867/23 C.G.E. | Expte. Grabado N (2856760) | Provincia de Entre Rios - Consejo General de Educacion.', 'texto app chunk 56');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 57, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Educacion Fisica
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Instituto Superior de las Especialidades de la Educacion Fisica
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Resolucion N 0338/23 C.G.E. | Expte. Grabado N (1943502) | Provincia de Entre Rios - Consejo General de Educacion.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado de Educacion Secundaria en Ciencia Politica', 'texto app chunk 57');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 58, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/pantalla/widgets/tarjeta_regimen_correlatividades.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/visualization_grid.dart] práctica profesional docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/cascada/visualization_grid.dart] practica profesional docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] JSON invalido: esperaba "careers" como Map en $assetPath
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] Formato de JSON inesperado en $assetPath
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] No se encontro el array "materias" en $assetPath', 'texto app chunk 58');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 59, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] const\s+pdfUrl\s*=\s*''([^'']+)''
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] \'') { escape = true; } else if (ch == "
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ) { inSingle = false; } continue; } if (inDouble) { if (escape) { escape = false; } else if (ch == r''\'') { escape = true; } else if (ch == ''
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ) { inDouble = false; } continue; } if (ch == "
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ) { inSingle = true; continue; } if (ch == ''', 'texto app chunk 59');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 60, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ) { inDouble = true; continue; } if (ch ==
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ) { depth++; } else if (ch ==
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] : isSpecial, }; if (text != null && text.trim().isNotEmpty) { out[
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ] = sanitizeText(text.trim()); } det.add(out); } map[
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/data/examenes_repo.dart] ).toString()); if (nombre.contains(
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/examenes_screen.dart] pantalla/pantalla_examenes.dart', 'texto app chunk 60');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 61, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/models/examen_event.dart] Campo "$key" vacio en evento: $j
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/examenes_visibility.dart] Los proximos llamados seran en las mesas extraordinarias de mayo. Volve pronto.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/logica_examenes.dart] \s*[-–—]?\s*(comision|comisión|division|división|grupo)\s+([ab])\b
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/pantalla_examenes.dart] sheet/route_sheet_examenes.dart
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/pantalla_examenes.dart] Lectura situada de mesas y llamados', 'texto app chunk 61');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 62, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/pantalla_examenes.dart] Esta pantalla no reemplaza cronogramas de cátedra ni avisos institucionales. Sirve para cruzar el plan con fechas publicadas, coloquios y movimientos concretos de cursada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/pantalla_examenes.dart] Buscar materia, código o tramo...
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/sheet/widgets_sheet_examenes.dart] Volve pronto para ver las proximas fechas publicadas.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/widgets/lista_materias.dart] No hay materias para los filtros seleccionados.', 'texto app chunk 62');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 63, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/examenes/pantalla/widgets/lista_materias.dart] A definir · consultar con docente de catedra
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] Bloques literales del DOCX con estilo visual unificado
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] ¿Qué palabras necesito comprender para desenvolverme en una institución de nivel superior?
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] La vida académica está regulada por un conjunto de normativas (leyes, decretos, resoluciones, disposiciones, circulares) con alcance a nivel nacional, provincial e institucional.', 'texto app chunk 63');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 64, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] Una normativa es un documento que contiene reglas, obligaciones, derechos y garantías. En este caso vienen a ordenar la vida en las instituciones y a regular la actividad que desarrollan los sujetos que las habitan, quienes suponen ciertos consensos para vivir en comunidad. Pueden ser disposiciones, resoluciones, decretos, leyes, estatutos, acuerdos, entre otros.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] ¿Qué es un Diseño Curricular?', 'texto app chunk 64');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 65, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] El término diseño curricular hace referencia a lo que en muchas ocasiones denominamos Plan de Estudios de una carrera, pero va más allá y abarca otros aspectos que permiten organizar y desarrollar el plan educativo. El diseño curricular busca satisfacer las necesidades formativas de las y los estudiantes y se plasma en un documento detallando las características y proyectando los alcances de la formación.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] Las y los docentes encuentran en él una guía para llevar adelante la enseñanza y les posibilita la planificación general de las actividades académicas, establece la organización de las unidades curriculares, su modalidad de cursado, como así también lo que se denomina el régimen de correlati', 'texto app chunk 65');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 66, 'vidades para cada carrera.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_03.dart] Cada diseño curricular es aprobado por el Consejo General de Educación a través de una Resolución y, periódicamente junto al Ministerio de Educación de Nación, se realiza una evaluación de la implementación de los mismos a los efectos de ir respondiendo a las necesidades de formación de cada una de las provincias.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Continuidad literal del documento de ingresantes', 'texto app chunk 66');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 67, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Una materia es correlativa cuando su aprobación depende de la aprobación de otra asignatura previa. Que una unidad curricular (UC) sea correlativa con otra implica que para aprobar la segunda debemos primero tener aprobada/s la/s unidad/es que en el plan de estudios figuren como requisito para aprobar o cursar ese espacio.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] ¿Cómo se organizan las diferentes materias de las carreras?', 'texto app chunk 67');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 68, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Cada carrera o diseño curricular está organizado en unidades curriculares o materias, se entiende por “unidad curricular” a aquellas unidades de conocimientos que, adoptando distintas modalidades o formatos pedagógicos, forman parte constitutiva del plan, organizan la enseñanza. Las unidades curriculares están clasificadas en tres formatos diferentes y por lo tanto también prevén formas de evaluación que le son propias.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Asignatura: se refiere a una materia o disciplina específica que se estudia o se enseña en el currículo escolar. Cada asignatura tiene un conjunto de objetivos de aprendizaje y contenidos específicos que los estudiantes deben dominar. Estas materias se imparten a lo largo de u', 'texto app chunk 68');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 69, 'n año académico, y su estudio contribuye al desarrollo de habilidades, conocimientos y competencias en los estudiantes.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Seminario: posee una naturaleza técnica y académica, cuyo objetivo es llevar a cabo un estudio profundo de determinadas cuestiones o asuntos. En un seminario, se busca fomentar el debate, las ideas propias y originales, y poner a prueba el espíritu crítico de los participantes. Se considera un espacio educativo complementario al aula de clases, donde se promueve la participación activa de los estudiantes y se busca generar conocimientos y poner en práctica los saberes académicos.', 'texto app chunk 69');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 70, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Taller: los talleres son unidades curriculares orientadas a promover la resolución práctica de situaciones a partir de la interacción y reflexión de los sujetos en forma cooperativa. Se propone para la evaluación, la presentación de trabajos parciales y/o finales, de producción individual o colectiva según la propuesta didáctica de los docentes de la unidad curricular.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Práctica docente: son trabajos de participación progresiva de los estudiantes en instituciones formales y no formales, escuelas, aulas, desde ayudantías iniciales pasando por prácticas de enseñanza de contenido curriculares delimitados, hasta la residencia con proyectos de enseñanza extendidos en el tiempo.', 'texto app chunk 70');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 71, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Unidades de definición institucional (UDI): estas unidades permiten recuperar las experiencias educativas, construidas en la trayectoria formativa del establecimiento educativo.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Trabajos de campo: espacios sistemáticos de síntesis e integración de conocimientos a través de la realización de trabajos de indagación en terreno e intervenciones en campos acotados.', 'texto app chunk 71');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 72, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_04.dart] Homologaciones: en cuanto a los estudiantes que hayan estudiado otra carrera (parcial o finalizada) pueden homologar los espacios curriculares aprobados. La institución brindará el tiempo y los requisitos que son necesarios para que puedan presentar la documentación.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Cierre de la sección académica + transición a correlatividades
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] ¿Cómo y cuáles son las instancias de evaluación para aprobar una materia?', 'texto app chunk 72');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 73, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Para acreditar o aprobar una materia se requiere cumplimentar determinadas actividades de acuerdo a la condición de cursado en la que te encuentres y en función a los requerimientos establecidos por los docentes de cada una de ellas. De acuerdo a los Diseños Curriculares y al Régimen Académico Marco (RAM), podemos identificar algunas instancias evaluativas que te permitirán conocer los requerimientos para aprobar cada materia.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Son instancias que acreditan parcialmente una materia a través de exámenes/evaluaciones (orales o escritas). Cada una con sus correspondientes recuperatorios y deben ser tomados en diferentes etapas del cursado según lo establezca el proyecto de cátedra de cada materia,', 'texto app chunk 73');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 74, 'en concordancia con el RAM y el diseño curricular.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Son actividades generalmente domiciliarias, pueden ser individuales o grupales que requieren actividades extras de las realizadas en clase. Tienen la misma importancia de aprobación que un parcial para la acreditación de las unidades curriculares.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Es una instancia de evaluación oral, que define la aprobación de una cátedra, y que se caracteriza por la defensa de un trabajo práctico o la exposición de un tema específico. Este tipo de instancia se realiza una vez adquirida la condición de promoción.', 'texto app chunk 74');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 75, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Unidades Curriculares y Regímenes de Correlatividades
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] A continuación, les presentamos las unidades curriculares para los cuatro años de cada una de las carreras del profesorado. Estos diseños fueron aprobados por el Consejo General de Educación de la provincia de Entre Ríos en el año 2014 (Historia y Geografía) y 2015 (Ciencias Políticas).
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/features/experimental/pages/page_05.dart] Cada año tiene unidades curriculares correspondientes a tres áreas de formación: campo de la formación general, campo de la formación específica y campo de la formación en la práctica profesional.', 'texto app chunk 75');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 76, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/models/materia.dart] pr[\u00e1a]ctica\\s+profesional\\s+docente
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado en Ciencia Política
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado en Artes Visuales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado en Lengua y Literatura
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado Superior de Ciencias Sociales
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Profesorado Superior de Ciencias Sociales', 'texto app chunk 76');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 77, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Instituto Superior de Formación Docente N° 1 "Cesáreo Bernaldo de Quirós"
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Podés cursar con restricciones
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Para habilitar esta cursada, primero tenés que regularizar o aprobar las correlativas pendientes.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Podés cursar y hacer actividades o trabajos prácticos si la cátedra lo habilita.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Los parciales y la promoción no quedan habilitados hasta que apruebes las correlativas pendientes en una mesa de examen.', 'texto app chunk 77');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 78, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Podés hacer actividades, rendir parciales y acceder a la promoción.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Si cumplís con la asistencia y las notas requeridas, no hace falta rendir final.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Podés cursar y hacer actividades o trabajos prácticos.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Para rendir parciales o acceder a la promoción, primero tenés que aprobar las correlativas que hoy figuran regularizadas.', 'texto app chunk 78');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 79, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Si no las aprobás a tiempo en una mesa de examen, no vas a poder promocionar y vas a quedar en condición regular si cumplís los requisitos de la cursada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Seleccioná una materia para empezar.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Tenés que marcar el estado de estas correlativas: $nombresPend.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Marca cada una como no regularizada, regularizada o aprobada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Completá los estados y volvé a revisar el escenario.', 'texto app chunk 79');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 80, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Regularizá o aprobá las correlativas que faltan antes de inscribirte.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Según el reglamento, esta cursada no debería quedar plenamente habilitada hasta que apruebes todas las (A) pendientes: $missingNames. En algunos casos la cátedra puede permitir una cursada condicionada si te comprometés a aprobarlas pronto en una mesa habilitada.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Hablá con la cátedra y priorizá aprobar las (A) en la próxima mesa.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Sostené las notas y la asistencia para llegar a la promoción.', 'texto app chunk 80');
insert into public.assistant_chunks (document_id, chunk_index, chunk_text, source_ref) values ('app_textos_sin_faq', 81, '[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Aprobá las (R) cuanto antes para habilitar la evaluación completa y la posibilidad de promocionar.
[C:/Users/alanm/StudioProjects/correlativas_historia/lib/shared/providers/app_state.dart] Revisa y completa el estado de las correlativas.', 'texto app chunk 81');
