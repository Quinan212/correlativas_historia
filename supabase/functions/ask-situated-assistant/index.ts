import { createClient } from "jsr:@supabase/supabase-js@2";

type AssistantChunkRow = {
  id: number;
  document_id: string;
  chunk_index: number;
  chunk_text: string;
  source_ref: string;
  assistant_documents: {
    title: string;
    source_type: string;
  } | null;
};

type CurriculumNodeRow = {
  career_id: string;
  career_name: string;
  materia_id: string;
  materia_nombre: string;
  materia_normalized: string;
  anio: number | null;
  tipo: string | null;
  formato: string | null;
};

type CurriculumEdgeRow = {
  from_materia_nombre: string;
  to_materia_nombre: string;
  requirement_type: string | null;
  source_ref: string;
};

type SourceItem = {
  title: string;
  reference: string;
};

type QueryIntent =
  | "curriculum_habilita"
  | "curriculum_requisitos"
  | "curriculum_anio"
  | "curriculum_tipo_formato"
  | "open_qa";

type StructuredAnswer = {
  answer: string;
  sources: SourceItem[];
  intent: QueryIntent;
  resolvedCareerId?: string | null;
  resolvedMateriaId?: string | null;
  resolvedMateriaNombre?: string | null;
  evidenceCount?: number | null;
};

type ClarificationCandidate = {
  career_name: string;
  materia_nombre: string;
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash-lite";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ status: "error", answer: "Method not allowed", sources: [] }, 405);
  }

  try {
    const body = await req.json();
    const question = normalizeText(body?.question);
    const contextType = normalizeText(body?.context_type) || "uso_app";
    const contextId = normalizeText(body?.context_id);
    const deviceId = normalizeText(body?.device_id);

    if (!question) {
      return json({ status: "error", answer: "Falta la pregunta.", sources: [] }, 400);
    }

    if (!deviceId) {
      return json({ status: "error", answer: "Falta device_id.", sources: [] }, 400);
    }

    if (isGreetingQuestion(question)) {
      const greetingAnswer =
        "Hola. Contame la carrera y la materia (o solo la materia) y te digo correlativas, requisitos y año.";
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "ok",
        answer: greetingAnswer,
        intent: "open_qa",
        evidenceCount: 0,
      });
      return json({
        status: "ok",
        answer: greetingAnswer,
        sources: [],
      });
    }

    if (isAmbiguousCurriculumPrompt(question)) {
      const askDetailAnswer =
        "Necesito un poco mas de detalle para responder bien. Decime la materia completa y la carrera. Ejemplo: \"¿Que correlativas tiene Didactica de las Ciencias Sociales en Historia?\"";
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "ok",
        answer: askDetailAnswer,
        intent: "open_qa",
        evidenceCount: 0,
      });
      return json({
        status: "ok",
        answer: askDetailAnswer,
        sources: [],
      });
    }

    if (isTooShortCurricularFragment(question)) {
      const shortPromptAnswer =
        "Te leo, pero esa consulta quedó muy corta. Decime la materia completa y la carrera (Historia, Geografía o Ciencia Política) y te respondo puntual.";
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "ok",
        answer: shortPromptAnswer,
        intent: "open_qa",
        evidenceCount: 0,
      });
      return json({
        status: "ok",
        answer: shortPromptAnswer,
        sources: [],
      });
    }

    const clarificationCandidates = await findClarificationCandidates(question);
    if (clarificationCandidates.length > 0) {
      const lines = clarificationCandidates
        .slice(0, 4)
        .map((item) => `- ${item.materia_nombre} (${item.career_name})`);
      const clarificationAnswer = [
        "La consulta quedó incompleta. ¿Te referís a alguna de estas materias?",
        ...lines,
        "",
        "Decime el nombre completo de la materia y la carrera, y sigo con la respuesta.",
      ].join("\n");

      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "ok",
        answer: clarificationAnswer,
        intent: "open_qa",
        evidenceCount: 0,
      });
      return json({
        status: "ok",
        answer: clarificationAnswer,
        sources: [],
      });
    }

    const curriculumAnswer = await maybeAnswerCurriculumQuestion(question, contextId);
    if (curriculumAnswer != null) {
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "ok",
        answer: curriculumAnswer.answer,
        intent: curriculumAnswer.intent,
        resolvedCareerId: curriculumAnswer.resolvedCareerId ?? null,
        resolvedMateriaId: curriculumAnswer.resolvedMateriaId ?? null,
        resolvedMateriaNombre: curriculumAnswer.resolvedMateriaNombre ?? null,
        evidenceCount: curriculumAnswer.evidenceCount ?? null,
      });

      return json({
        status: "ok",
        answer: curriculumAnswer.answer,
        sources: curriculumAnswer.sources,
      });
    }

    const evidence = await retrieveEvidence(question);
    const weakEvidence = hasWeakEvidence(question, evidence);
    if (evidence.length === 0) {
      const noEvidenceAnswer =
        "No encuentro respaldo suficiente en Steiman o en los textos de la app para responder eso con precision.";
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "no_evidence",
        answer: noEvidenceAnswer,
        intent: "open_qa",
        evidenceCount: 0,
      });
      return json({
        status: "no_evidence",
        answer: noEvidenceAnswer,
        sources: [],
      });
    }
    if (weakEvidence) {
      const weakEvidenceAnswer =
        "No encuentro respaldo suficiente en Steiman o en los textos de la app para responder eso con precision.";
      await saveQuery({
        deviceId,
        question,
        contextType,
        contextId,
        status: "no_evidence",
        answer: weakEvidenceAnswer,
        intent: "open_qa",
        evidenceCount: evidence.length,
      });
      return json({
        status: "no_evidence",
        answer: weakEvidenceAnswer,
        sources: [],
      });
    }

    const sources = buildSources(evidence);
    let answer = "";
    if (!GEMINI_API_KEY) {
      answer = buildFallbackAnswer(evidence);
    } else {
      answer = await askGemini(question, evidence);
    }

    const sanitizedAnswer = answer.trim().length === 0
      ? buildFallbackAnswer(evidence)
      : answer.trim();
    const finalAnswer = cleanAnswerText(sanitizedAnswer);

    await saveQuery({
      deviceId,
      question,
      contextType,
      contextId,
      status: "ok",
      answer: finalAnswer,
      intent: "open_qa",
      evidenceCount: evidence.length,
    });

    return json({
      status: "ok",
      answer: finalAnswer,
      sources,
    });
  } catch (error) {
    console.error(error);
    return json(
      {
        status: "error",
        answer: error instanceof Error ? error.message : String(error),
        sources: [],
      },
      500,
    );
  }
});

async function maybeAnswerCurriculumQuestion(question: string, contextId: string) {
  const asksAnio = isAnioQuestion(question);
  const asksTipoFormato = !asksAnio && isTipoFormatoQuestion(question);
  const asksHabilita = isHabilitaQuestion(question);
  const asksRequisitos = isRequisitosQuestion(question);
  if (!asksHabilita && !asksRequisitos && !asksAnio && !asksTipoFormato) return null;

  let careerId = resolveCareerId(question, contextId);
  let preDetectedNode: CurriculumNodeRow | null = null;

  if (careerId == null) {
    const { data: allNodesData, error: allNodesError } = await supabase
      .from("assistant_curriculum_nodes")
      .select("career_id,career_name,materia_id,materia_nombre,materia_normalized,anio,tipo,formato")
      .limit(1200);

    if (allNodesError) throw allNodesError;
    const allNodes = (allNodesData ?? []) as CurriculumNodeRow[];
    if (allNodes.length > 0) {
      preDetectedNode = detectMateriaFromQuestion(question, allNodes, asksAnio ? 2 : 4);
      if (asksAnio && preDetectedNode == null) {
        preDetectedNode = detectMateriaFromQuestion(question, allNodes, 1);
      }
      if (preDetectedNode != null) {
        careerId = preDetectedNode.career_id;
      }
    }
  }

  const disciplineConflict = detectDisciplineConflict(question, careerId);
  if (disciplineConflict != null) {
    return {
      answer:
        `La consulta mezcla una materia disciplinar de ${disciplineConflict} con la carrera ${careerId}. Confirmame la materia exacta para esa carrera y te respondo preciso.`,
      sources: [],
      intent: asksAnio
        ? "curriculum_anio"
        : asksTipoFormato
        ? "curriculum_tipo_formato"
        : asksRequisitos
        ? "curriculum_requisitos"
        : "curriculum_habilita",
      resolvedCareerId: careerId,
      evidenceCount: 0,
    };
  }

  if (careerId == null) {
    return {
      answer:
        "No pude ubicar la carrera con esa consulta. Decime la materia completa y la carrera. Ejemplo: \"¿Qué correlativas tiene Didáctica de las Ciencias Sociales en Historia?\"",
      sources: [],
      intent: asksRequisitos
        ? "curriculum_requisitos"
        : asksHabilita
        ? "curriculum_habilita"
        : asksAnio
        ? "curriculum_anio"
        : "curriculum_tipo_formato",
      evidenceCount: 0,
    };
  }

  const { data: nodesData, error: nodesError } = await supabase
    .from("assistant_curriculum_nodes")
    .select("career_id,career_name,materia_id,materia_nombre,materia_normalized,anio,tipo,formato")
    .eq("career_id", careerId)
    .limit(300);

  if (nodesError) throw nodesError;
  const nodes = (nodesData ?? []) as CurriculumNodeRow[];
  if (nodes.length === 0) return null;
  if (!hasStrongMateriaLexicalMatch(question, nodes, careerId)) {
    return {
      answer:
        `No pude identificar esa materia en ${nodes[0].career_name}. Escribila completa y, si queres, te sugiero la materia equivalente de esa carrera.`,
      sources: [],
      intent: asksAnio
        ? "curriculum_anio"
        : asksTipoFormato
        ? "curriculum_tipo_formato"
        : asksRequisitos
        ? "curriculum_requisitos"
        : "curriculum_habilita",
      resolvedCareerId: careerId,
      evidenceCount: 0,
    };
  }

  let detected = detectMateriaFromQuestion(question, nodes, asksAnio ? 2 : 4);
  if (detected == null && preDetectedNode != null && preDetectedNode.career_id === careerId) {
    detected = preDetectedNode;
  }
  if (asksAnio && detected == null) {
    detected = detectMateriaFromQuestion(question, nodes, 1);
  }
  if (asksAnio && detected == null) {
    return {
      answer: `No pude identificar la materia en ${careerId}. Proba escribiendo el nombre completo de la materia.`,
      sources: [],
      intent: "curriculum_anio",
      resolvedCareerId: careerId,
      evidenceCount: 0,
    };
  }
  if (asksTipoFormato && detected == null) {
    return {
      answer: `No pude identificar la materia en ${careerId}. Proba escribiendo el nombre completo de la materia.`,
      sources: [],
      intent: "curriculum_tipo_formato",
      resolvedCareerId: careerId,
      evidenceCount: 0,
    };
  }
  if (detected == null) {
    if (asksRequisitos || asksHabilita) {
      return {
        answer:
          "No pude identificar la materia con ese texto. Escribila completa y, si podés, agregá la carrera. Ejemplo: \"¿Qué correlativas tiene Didáctica de las Ciencias Sociales en Historia?\"",
        sources: [],
        intent: asksRequisitos ? "curriculum_requisitos" : "curriculum_habilita",
        resolvedCareerId: careerId,
        evidenceCount: 0,
      };
    }
    return null;
  }

  if (asksAnio) {
    if (detected.anio == null) {
      return {
        answer:
          `No tengo el año de cursada de ${detected.materia_nombre} en el plan cargado para ${detected.career_name}.`,
        sources: [],
        intent: "curriculum_anio",
        resolvedCareerId: careerId,
        resolvedMateriaId: detected.materia_id,
        resolvedMateriaNombre: detected.materia_nombre,
        evidenceCount: 0,
      };
    }
    return {
      answer: `${detected.materia_nombre} corresponde a ${detected.anio}° año en ${detected.career_name}.`,
      sources: [],
      intent: "curriculum_anio",
      resolvedCareerId: careerId,
      resolvedMateriaId: detected.materia_id,
      resolvedMateriaNombre: detected.materia_nombre,
      evidenceCount: 0,
    };
  }

  if (asksTipoFormato) {
    const tipo = detected.tipo?.trim();
    const formato = detected.formato?.trim();
    if (!tipo && !formato) {
      return {
        answer: `No tengo cargado el tipo/formato de ${detected.materia_nombre} en ${detected.career_name}.`,
        sources: [],
        intent: "curriculum_tipo_formato",
        resolvedCareerId: careerId,
        resolvedMateriaId: detected.materia_id,
        resolvedMateriaNombre: detected.materia_nombre,
        evidenceCount: 0,
      };
    }

    const parts: string[] = [];
    if (tipo) parts.push(`tipo: ${tipo}`);
    if (formato) parts.push(`formato: ${formato}`);
    return {
      answer: `${detected.materia_nombre} en ${detected.career_name} tiene ${parts.join(" | ")}.`,
      sources: [],
      intent: "curriculum_tipo_formato",
      resolvedCareerId: careerId,
      resolvedMateriaId: detected.materia_id,
      resolvedMateriaNombre: detected.materia_nombre,
      evidenceCount: 0,
    };
  }

  const baseQuery = supabase
    .from("assistant_curriculum_edges")
    .select("from_materia_nombre,to_materia_nombre,requirement_type,source_ref")
    .eq("career_id", careerId)
    .limit(120);

  const query = asksRequisitos
    ? baseQuery.eq("to_materia_id", detected.materia_id).order("from_materia_nombre", { ascending: true })
    : baseQuery.eq("from_materia_id", detected.materia_id).order("to_materia_nombre", { ascending: true });

  const { data: edgesData, error: edgesError } = await query;

  if (edgesError) throw edgesError;
  const edges = (edgesData ?? []) as Array<CurriculumEdgeRow & { from_materia_nombre: string }>;

  const prettyBaseName = detected.materia_nombre.trim();
  const careerSource = getCurriculumSource(detected.career_id, detected.career_name);
  if (asksRequisitos && isSpecialPracticaIV(detected)) {
    const yearOneToThree = nodes
      .filter((n) => (n.anio ?? 0) >= 1 && (n.anio ?? 0) <= 3)
      .map((n) => n.materia_nombre.trim())
      .filter((n) => n.length > 0)
      .sort((a, b) => a.localeCompare(b, "es"));

    return {
      answer: cleanAnswerText([
        `Para cursar ${prettyBaseName} en ${detected.career_name}, en el plan figura condicion especial:`,
        "",
        "Aprobadas (A):",
        "- Todas las unidades curriculares de 1°, 2° y 3° año.",
        "",
        `En total son ${yearOneToThree.length} materias previas del plan.`,
        "",
        "Tomalo como guia de plan y cruzalo con tu situacion academica real en la app.",
      ].join("\n")),
      sources: [careerSource],
      intent: "curriculum_requisitos",
      resolvedCareerId: careerId,
      resolvedMateriaId: detected.materia_id,
      resolvedMateriaNombre: detected.materia_nombre,
      evidenceCount: yearOneToThree.length,
    };
  }
  if (edges.length === 0) {
    if (asksRequisitos) {
      return {
        answer:
          `En ${detected.career_name}, ${prettyBaseName} no figura con correlativas requeridas en el plan cargado.`,
        sources: [careerSource],
        intent: "curriculum_requisitos",
        resolvedCareerId: careerId,
        resolvedMateriaId: detected.materia_id,
        resolvedMateriaNombre: detected.materia_nombre,
        evidenceCount: 0,
      };
    }
    return {
      answer:
        `En ${detected.career_name}, ${prettyBaseName} no figura como correlativa que habilite otras materias en el plan cargado.`,
      sources: [careerSource],
      intent: "curriculum_habilita",
      resolvedCareerId: careerId,
      resolvedMateriaId: detected.materia_id,
      resolvedMateriaNombre: detected.materia_nombre,
      evidenceCount: 0,
    };
  }

  if (asksRequisitos) {
    const aprobadas = Array.from(
      new Set(
        edges
          .filter((e) => e.requirement_type === "A")
          .map((e) => e.from_materia_nombre.trim()),
      ),
    );
    const regularizadas = Array.from(
      new Set(
        edges
          .filter((e) => e.requirement_type === "R")
          .map((e) => e.from_materia_nombre.trim()),
      ),
    );
    const sinTipo = Array.from(
      new Set(
        edges
          .filter((e) => e.requirement_type == null)
          .map((e) => e.from_materia_nombre.trim()),
      ),
    );

    const parts = [`Para cursar ${prettyBaseName} en ${detected.career_name}, en el plan figuran:`];
    if (aprobadas.length > 0) {
      parts.push("", "Aprobadas (A):", ...aprobadas.map((m) => `- ${m}`));
    }
    if (regularizadas.length > 0) {
      parts.push("", "Regularizadas (R):", ...regularizadas.map((m) => `- ${m}`));
    }
    if (sinTipo.length > 0) {
      parts.push("", "Sin tipo explicito en el plan:", ...sinTipo.map((m) => `- ${m}`));
    }
    parts.push(
      "",
      "Tomalo como guia de plan y cruzalo con tu situacion academica real en la app.",
    );

    return {
      answer: cleanAnswerText(parts.join("\n")),
      sources: [careerSource],
      intent: "curriculum_requisitos",
      resolvedCareerId: careerId,
      resolvedMateriaId: detected.materia_id,
      resolvedMateriaNombre: detected.materia_nombre,
      evidenceCount: edges.length,
    };
  }

  const uniqueTargets = Array.from(new Set(edges.map((e) => e.to_materia_nombre.trim())));
  const top = uniqueTargets.slice(0, 8);
  const restCount = uniqueTargets.length - top.length;

  const lines = top.map((name) => `- ${name}`);
  if (restCount > 0) {
    lines.push(`- ... y ${restCount} materia(s) mas.`);
  }

  const answer = [
    `En ${detected.career_name}, ${prettyBaseName} te habilita cursar:`,
    lines.join("\n"),
    "",
    "Toma esto como guia de plan y cruzalo con tu situacion de regularidad/aprobacion en la app.",
  ].join("\n");

  return {
    answer: cleanAnswerText(answer),
    sources: [careerSource],
    intent: "curriculum_habilita",
    resolvedCareerId: careerId,
    resolvedMateriaId: detected.materia_id,
    resolvedMateriaNombre: detected.materia_nombre,
    evidenceCount: uniqueTargets.length,
  };
}

function detectMateriaFromQuestion(question: string, nodes: CurriculumNodeRow[], minScore = 4) {
  const normalizedQuestion = normalizeForMatch(question);
  const qTokens = tokenizeMatch(normalizedQuestion);
  const qMeaningfulTokens = qTokens.filter((t) => !isOrdinalToken(t) && !isStopwordToken(t));
  const qPracticeLevel = extractPracticeLevel(normalizedQuestion);
  const qOrdinalLevel = extractOrdinalLevel(normalizedQuestion);
  if (qTokens.length === 0) return null;

  if (normalizedQuestion.includes("practica docente") && qPracticeLevel != null) {
    const roman = toRoman(qPracticeLevel);
    const direct = nodes.find((n) =>
      n.materia_normalized.includes(`practica docente ${roman}`) ||
      n.materia_normalized.includes(`practica docente ${qPracticeLevel}`)
    );
    if (direct != null) return direct;
  }

  let best: CurriculumNodeRow | null = null;
  let bestScore = 0;

  for (const node of nodes) {
    const name = node.materia_normalized;
    const nTokens = tokenizeMatch(name);
    if (nTokens.length === 0) continue;
    const nMeaningfulTokens = nTokens.filter((t) => !isOrdinalToken(t) && !isStopwordToken(t));

    let score = 0;
    if (normalizedQuestion.includes(name)) score += 8;

    for (const token of qTokens) {
      if (name.includes(token)) score += 1;
    }

    const overlap = nTokens.filter((t) => qTokens.includes(t)).length;
    score += overlap * 2;
    const meaningfulOverlap = nMeaningfulTokens.filter((t) => qMeaningfulTokens.includes(t)).length;
    score += meaningfulOverlap * 3;
    if (qMeaningfulTokens.length > 0 && meaningfulOverlap === 0) {
      score -= 20;
    }

    if (qPracticeLevel != null) {
      const nodePracticeLevel = extractPracticeLevel(name);
      if (nodePracticeLevel === qPracticeLevel) {
        score += 10;
      } else if (nodePracticeLevel != null) {
        score -= 8;
      }
    }

    if (qOrdinalLevel != null) {
      const nodeOrdinalLevel = extractOrdinalLevel(name);
      if (nodeOrdinalLevel === qOrdinalLevel) {
        score += 8;
      } else if (nodeOrdinalLevel != null) {
        score -= 12;
      }
    }

    if (score > bestScore) {
      best = node;
      bestScore = score;
    }
  }

  return bestScore >= minScore ? best : null;
}

function isHabilitaQuestion(question: string) {
  const q = normalizeForMatch(question);
  return /habilita|habilitan|que materias|puedo cursar|me abre|abre/.test(q);
}

function isRequisitosQuestion(question: string) {
  const q = normalizeForMatch(question);
  return /necesito|requisit|correlativ|tener|aprobad|regularizad|para cursar|para poder cursar/.test(q);
}

function isAnioQuestion(question: string) {
  const q = normalizeForMatch(question);
  const raw = question.toLowerCase();
  const hasYearWordRaw = /(año|anio|ano|aÃ±o)/.test(raw);
  const hasQuestionCueRaw = /(de que|de qué|que|qué|en que|en qué|a que|a qué)/.test(raw);
  const asksAnoByPhrase = /de que ano es|de que a o es|que ano es|en que ano esta|que ano curs|a que ano pertenece|de que curso es/.test(q);
  const asksAnoByKeywords = q.includes("ano") && (q.includes("de que") || q.includes("en que") || q.includes("a que"));
  return asksAnoByPhrase || asksAnoByKeywords || (hasYearWordRaw && hasQuestionCueRaw);
}

function isTipoFormatoQuestion(question: string) {
  const q = normalizeForMatch(question);
  return /que tipo|que formato|de que tipo es|es taller|es seminario|es asignatura|que tipo de materia/.test(q);
}

function isGreetingQuestion(question: string) {
  const q = normalizeForMatch(question);
  if (q.length > 24) return false;
  return /^(hola|buenas|buen dia|buenas tardes|buenas noches|que tal|como va|holis|hello|hi)$/.test(q);
}

function isAmbiguousCurriculumPrompt(question: string) {
  const q = normalizeForMatch(question);
  const tokens = tokenizeMatch(q);
  const hasCurriculumCue = /correlativ|habilita|requisit|para cursar|ano|anio|tipo|formato/.test(q);
  const hasCareer = /historia|geografia|politica|ciencia politica/.test(q);
  const isShort = tokens.length <= 5;
  return hasCurriculumCue && !hasCareer && isShort;
}

async function findClarificationCandidates(question: string) {
  const q = normalizeForMatch(question);
  if (q.length < 4) return [] as ClarificationCandidate[];
  if (isGreetingQuestion(question)) return [] as ClarificationCandidate[];

  const tokens = tokenizeMatch(q).filter((token) => !isStopwordToken(token));
  if (tokens.length === 0 || tokens.length > 4) return [] as ClarificationCandidate[];

  const hasCareer = /historia|geografia|politica|ciencia politica/.test(q);
  if (hasCareer) return [] as ClarificationCandidate[];

  const { data, error } = await supabase
    .from("assistant_curriculum_nodes")
    .select("career_name,materia_nombre,materia_normalized")
    .limit(1200);
  if (error) throw error;

  type Row = { career_name: string; materia_nombre: string; materia_normalized: string };
  const rows = (data ?? []) as Row[];
  if (rows.length === 0) return [] as ClarificationCandidate[];

  const scored = rows
    .map((row) => {
      let score = 0;
      for (const token of tokens) {
        if (row.materia_normalized.includes(token)) score += 2;
        if (row.materia_normalized.startsWith(token)) score += 1;
      }
      return { row, score };
    })
    .filter((item) => item.score >= 2)
    .sort((a, b) => b.score - a.score)
    .slice(0, 8)
    .map((item) => ({
      career_name: item.row.career_name,
      materia_nombre: item.row.materia_nombre,
    }));

  if (scored.length <= 1) return [] as ClarificationCandidate[];

  const dedup = new Set<string>();
  const out: ClarificationCandidate[] = [];
  for (const item of scored) {
    const key = `${item.materia_nombre}::${item.career_name}`;
    if (dedup.has(key)) continue;
    dedup.add(key);
    out.push(item);
  }
  return out;
}

function isStopwordToken(token: string) {
  return [
    "que",
    "cual",
    "cuales",
    "como",
    "donde",
    "cuando",
    "para",
    "con",
    "sin",
    "del",
    "de",
    "la",
    "el",
    "los",
    "las",
    "un",
    "una",
    "y",
    "o",
    "en",
    "necesito",
    "materias",
    "materia",
    "cursar",
    "curso",
    "correlativas",
    "correlativa",
    "requisitos",
    "requisito",
    "habilita",
    "habilitan",
    "abre",
    "tipo",
    "formato",
    "ano",
    "anio",
    "year",
  ].includes(token);
}

function isOrdinalToken(token: string) {
  return /^(i|ii|iii|iv|1|2|3|4)$/.test(token);
}

function hasStrongMateriaLexicalMatch(
  question: string,
  nodes: CurriculumNodeRow[],
  careerId: string,
) {
  let q = normalizeForMatch(question);
  if (careerId === "historia") {
    q = q.replace(/\bhistoria\b/g, " ");
  } else if (careerId === "geografia") {
    q = q.replace(/\bgeografia\b/g, " ");
  } else if (careerId === "politica") {
    q = q.replace(/\bciencia politica\b/g, " ").replace(/\bpolitica\b/g, " ");
  }
  const qTokens = tokenizeMatch(q)
    .filter((t) => !isStopwordToken(t) && !isOrdinalToken(t));
  if (qTokens.length === 0) return true;

  let maxOverlap = 0;
  for (const node of nodes) {
    const nTokens = tokenizeMatch(node.materia_normalized)
      .filter((t) => !isStopwordToken(t) && !isOrdinalToken(t));
    const overlap = nTokens.filter((t) => qTokens.includes(t)).length;
    if (overlap > maxOverlap) maxOverlap = overlap;
  }

  const required = qTokens.length >= 2 ? 2 : 1;
  return maxOverlap >= required;
}

function isTooShortCurricularFragment(question: string) {
  const q = normalizeForMatch(question);
  if (q.length < 4 || q.length > 32) return false;
  if (isGreetingQuestion(question)) return false;
  if (/historia|geografia|politica|ciencia politica/.test(q)) return false;
  if (/correlativ|habilita|requisit|para cursar|ano|anio|tipo|formato/.test(q)) return false;

  const tokens = tokenizeMatch(q).filter((token) => !isStopwordToken(token));
  if (tokens.length === 0 || tokens.length > 2) return false;

  return /didactic|practic|histori|geografi|politic|sociolog|pedagog|psicolog|econom|filosof|epistem|instituc|residenc/.test(q);
}

function resolveCareerId(question: string, contextId: string) {
  const questionMentions = extractCareerMentions(normalizeForMatch(question));
  const contextMentions = extractCareerMentions(normalizeForMatch(contextId));

  if (questionMentions.length === 1) {
    return questionMentions[0];
  }
  if (questionMentions.length > 1) {
    return questionMentions[questionMentions.length - 1];
  }

  if (contextMentions.length === 1) {
    return contextMentions[0];
  }
  if (contextMentions.length > 1) {
    return contextMentions[contextMentions.length - 1];
  }

  return null;
}

function detectDisciplineConflict(question: string, careerId: string) {
  const q = normalizeForMatch(question);
  if (q.includes("didactica de la historia") && careerId !== "historia") return "Historia";
  if (q.includes("didactica de la geografia") && careerId !== "geografia") return "Geografia";
  if (q.includes("didactica de la ciencia politica") && careerId !== "politica") {
    return "Ciencia Politica";
  }
  return null;
}

function extractCareerMentions(text: string) {
  const mentions: Array<{ idx: number; id: "historia" | "geografia" | "politica" }> = [];
  const patterns: Array<{ re: RegExp; id: "historia" | "geografia" | "politica" }> = [
    { re: /\bhistoria\b/g, id: "historia" },
    { re: /\bgeografia\b/g, id: "geografia" },
    { re: /\bciencia politica\b/g, id: "politica" },
    { re: /\bpolitica\b/g, id: "politica" },
  ];

  for (const { re, id } of patterns) {
    for (const match of text.matchAll(re)) {
      const idx = typeof match.index === "number" ? match.index : -1;
      mentions.push({ idx, id });
    }
  }

  return mentions
    .sort((a, b) => a.idx - b.idx)
    .map((m) => m.id);
}

function normalizeForMatch(input: string) {
  const fixed = recodeLatin1Utf8(input);
  return fixed
    .toLowerCase()
    .replace(/á/g, "a")
    .replace(/é/g, "e")
    .replace(/í/g, "i")
    .replace(/ó/g, "o")
    .replace(/ú/g, "u")
    .replace(/ü/g, "u")
    .replace(/ñ/g, "n")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function tokenizeMatch(text: string) {
  return text
    .split(/\s+/)
    .filter((t) => t.length >= 3 || /^(i|ii|iii|iv|1|2|3|4)$/.test(t));
}

function extractOrdinalLevel(text: string) {
  const normalized = normalizeForMatch(text);
  if (/\b(iv|4)\b/.test(normalized)) return 4;
  if (/\b(iii|3)\b/.test(normalized)) return 3;
  if (/\b(ii|2)\b/.test(normalized)) return 2;
  if (/\b(i|1)\b/.test(normalized)) return 1;
  return null;
}

function extractPracticeLevel(text: string) {
  const normalized = normalizeForMatch(text);
  if (!normalized.includes("practica")) return null;

  if (/\b(4|iv|cuarta)\b/.test(normalized)) return 4;
  if (/\b(3|iii|tercera)\b/.test(normalized)) return 3;
  if (/\b(2|ii|segunda)\b/.test(normalized)) return 2;
  if (/\b(1|i|primera)\b/.test(normalized)) return 1;
  return null;
}

function toRoman(level: number) {
  switch (level) {
    case 1:
      return "i";
    case 2:
      return "ii";
    case 3:
      return "iii";
    case 4:
      return "iv";
    default:
      return "";
  }
}

async function retrieveEvidence(question: string) {
  const tokens = tokenize(question).slice(0, 8);
  if (tokens.length === 0) return [] as AssistantChunkRow[];

  const rowsById = new Map<number, { row: AssistantChunkRow; score: number }>();
  for (const token of tokens) {
    const { data, error } = await supabase
      .from("assistant_chunks")
      .select(`
        id,
        document_id,
        chunk_index,
        chunk_text,
        source_ref,
        assistant_documents!inner(title,source_type)
      `)
      .ilike("chunk_text", `%${escapeLike(token)}%`)
      .limit(60);

    if (error) throw error;
    const rows = (data ?? []) as AssistantChunkRow[];
    for (const row of rows) {
      if (isTechnicalChunk(row)) continue;
      const current = rowsById.get(row.id);
      rowsById.set(row.id, {
        row,
        score: (current?.score ?? 0) + 1,
      });
    }
  }

  return Array.from(rowsById.values())
    .sort((a, b) => b.score - a.score)
    .filter((entry) => entry.score >= (tokens.length >= 2 ? 2 : 1))
    .slice(0, 6)
    .map((entry) => entry.row);
}

function isTechnicalChunk(row: AssistantChunkRow) {
  const text = row.chunk_text.toLowerCase();
  if (text.includes("package:")) return true;
  if (text.includes("import '") || text.includes('import "')) return true;
  if (text.includes(" class ") || text.includes(" final ")) return true;
  if (text.includes("assets/") && !text.includes("diseño curricular")) return true;
  if (text.includes("lib/") && text.includes("providers/")) return true;
  return false;
}

function hasWeakEvidence(question: string, evidence: AssistantChunkRow[]) {
  const qTokens = tokenize(question).slice(0, 8);
  if (qTokens.length === 0) return false;
  const joined = evidence.map((e) => normalizeForMatch(e.chunk_text)).join(" ");
  const covered = qTokens.filter((token) => joined.includes(normalizeForMatch(token)));
  return covered.length < Math.min(2, qTokens.length);
}

function isSpecialPracticaIV(node: CurriculumNodeRow) {
  const n = node.materia_normalized;
  return n.includes("practica") && (n.includes(" iv ") || n.endsWith(" iv") || n.includes(" 4 ")) && (n.includes("docente") || n.includes("residencia"));
}

function buildSources(rows: AssistantChunkRow[]) {
  const seen = new Set<string>();
  const sources: SourceItem[] = [];
  for (const row of rows) {
    const title = row.assistant_documents?.title?.trim() || "Steiman";
    const reference = humanizeSourceRef(row.source_ref.trim());
    const key = `${title}|${reference}`;
    if (seen.has(key)) continue;
    seen.add(key);
    sources.push({ title, reference });
  }
  return sources.slice(0, 4);
}

function getCurriculumSource(careerId: string, careerName: string): SourceItem {
  const normalized = normalizeForMatch(careerId);
  if (normalized === "historia") {
    return {
      title: `Plan ${careerName}`,
      reference: `Diseño curricular de ${careerName} - Resolucion N° 0765 C.G.E.`,
    };
  }
  if (normalized === "geografia") {
    return {
      title: `Plan ${careerName}`,
      reference: `Diseño curricular de ${careerName} - Resolucion N° 0766 C.G.E.`,
    };
  }
  if (normalized === "politica") {
    return {
      title: `Plan ${careerName}`,
      reference: `Diseño curricular de ${careerName} - Resolucion N° 0440/23 C.G.E.`,
    };
  }
  return {
    title: `Plan ${careerName}`,
    reference: "Plan de correlatividades institucional cargado en la app.",
  };
}

function humanizeSourceRef(sourceRef: string) {
  const ref = sourceRef.trim().toLowerCase();
  if (ref.includes("assets/historia.html")) {
    return "Diseño curricular de Historia - Resolucion N° 0765 C.G.E.";
  }
  if (ref.includes("assets/geografia.html")) {
    return "Diseño curricular de Geografia - Resolucion N° 0766 C.G.E.";
  }
  if (ref.includes("assets/politica.html")) {
    return "Diseño curricular de Ciencia Politica - Resolucion N° 0440/23 C.G.E.";
  }
  return sourceRef;
}

async function askGemini(question: string, evidence: AssistantChunkRow[]) {
  const evidenceBlock = evidence
    .map((row) => {
      const title = row.assistant_documents?.title?.trim() || "Fuente";
      const sourceRef = row.source_ref.trim();
      const text = row.chunk_text.trim().slice(0, 1200);
      return `- [${title} | ${sourceRef}] ${text}`;
    })
    .join("\n");

  const prompt = [
    "Sos un asistente academico situado para una app educativa en Argentina.",
    "Responde en espanol argentino, claro, breve y con tono analitico.",
    "Reglas obligatorias:",
    "1) Usa solo la evidencia provista.",
    "2) Si no alcanza la evidencia, responde exactamente: NO_EVIDENCE.",
    "3) No inventes leyes, articulos ni autores.",
    "",
    `Pregunta: ${question}`,
    "",
    "Evidencia:",
    evidenceBlock,
    "",
    "Devolve solo la respuesta final en texto plano.",
  ].join("\n");

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.2,
          topP: 0.8,
          maxOutputTokens: 320,
        },
      }),
    },
  );

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Gemini request failed: ${body}`);
  }

  const jsonBody = await response.json();
  const text = jsonBody?.candidates?.[0]?.content?.parts?.[0]?.text?.toString() ?? "";
  if (text.trim().toUpperCase() === "NO_EVIDENCE") {
    return "";
  }
  return text;
}

function buildFallbackAnswer(evidence: AssistantChunkRow[]) {
  const evidenceTitles = Array.from(
    new Set(
      evidence
        .map((row) => row.assistant_documents?.title?.trim())
        .filter((item): item is string => Boolean(item)),
    ),
  );

  const sourceLabel = evidenceTitles.length > 0
    ? evidenceTitles.join(" y ")
    : "Steiman y los textos de la app";

  return [
    "Desde una mirada situada, la consulta se puede encarar contextualizando decisiones didacticas concretas para el grupo y la institucion.",
    "Conviene explicitar propositos, contenidos, criterios de evaluacion y ajustes posibles segun las condiciones reales de cursada.",
    `Base de evidencia: ${sourceLabel}.`,
  ].join("\n\n");
}

async function saveQuery({
  deviceId,
  question,
  contextType,
  contextId,
  status,
  answer,
  intent,
  resolvedCareerId,
  resolvedMateriaId,
  resolvedMateriaNombre,
  evidenceCount,
}: {
  deviceId: string;
  question: string;
  contextType: string;
  contextId: string;
  status: string;
  answer: string;
  intent?: QueryIntent;
  resolvedCareerId?: string | null;
  resolvedMateriaId?: string | null;
  resolvedMateriaNombre?: string | null;
  evidenceCount?: number | null;
}) {
  const { error } = await supabase
    .from("assistant_queries")
    .insert({
      device_id: deviceId,
      question,
      context_type: contextType,
      context_id: contextId.length === 0 ? null : contextId,
      status,
      answer: answer.replace(/\u0000/g, ""),
      intent: intent ?? "open_qa",
      resolved_career_id: resolvedCareerId ?? null,
      resolved_materia_id: resolvedMateriaId ?? null,
      resolved_materia_nombre: resolvedMateriaNombre ?? null,
      evidence_count: evidenceCount ?? null,
    });

  if (error) {
    console.error("assistant_queries insert failed", error);
  }
}

function tokenize(text: string) {
  const stopwords = new Set([
    "como",
    "cual",
    "cuanto",
    "donde",
    "cuando",
    "porque",
    "sobre",
    "para",
    "esta",
    "este",
    "estos",
    "estas",
  ]);

  return text
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .split(/\s+/)
    .map((item) => item.trim())
    .filter((item) => item.length >= 4 && !stopwords.has(item));
}

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function escapeLike(input: string) {
  return input.replace(/[%_]/g, "");
}

function cleanAnswerText(text: string) {
  const recoded = recodeLatin1Utf8(text);
  return recoded
    .replace(/Ã¡/g, "á")
    .replace(/Ã©/g, "é")
    .replace(/Ã­/g, "í")
    .replace(/Ã³/g, "ó")
    .replace(/Ãº/g, "ú")
    .replace(/Ã±/g, "ñ")
    .replace(/Ã¼/g, "ü")
    .replace(/Â¿/g, "¿")
    .replace(/Â¡/g, "¡")
    .replace(/â|â/g, "\"")
    .replace(/â/g, "'")
    .replace(/â|â/g, "-");
}

function recodeLatin1Utf8(input: string) {
  if (!/[ÃÂâ]/.test(input)) return input;
  try {
    const bytes = Uint8Array.from(Array.from(input).map((ch) => ch.charCodeAt(0) & 0xff));
    return new TextDecoder("utf-8", { fatal: false }).decode(bytes);
  } catch {
    return input;
  }
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
