import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

type ExamEventPayload = {
  id?: string;
  career_id?: string;
  anio?: number | null;
  fecha?: string | null;
  hora?: string | null;
  materia?: string;
  instancia?: string;
  docentes?: string[];
  acta_url?: string | null;
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const body = await req.json();
    const deviceId = stringValue(body.device_id);
    const action = stringValue(body.action);

    if (!deviceId) return json({ error: "device_id is required" }, 400);
    if (!action) return json({ error: "action is required" }, 400);

    const { data: adminRow, error: adminError } = await supabase
      .from("admin_devices")
      .select("device_id, enabled")
      .eq("device_id", deviceId)
      .eq("enabled", true)
      .maybeSingle();

    if (adminError) throw adminError;
    if (!adminRow) {
      return json({ error: "admin access required" }, 403);
    }

    if (action === "delete") {
      const id = stringValue(body.id);
      if (!id) return json({ error: "id is required" }, 400);

      const { error } = await supabase.from("exam_events").delete().eq("id", id);
      if (error) throw error;
      return json({ ok: true }, 200);
    }

    if (action !== "upsert") {
      return json({ error: "invalid action" }, 400);
    }

    const event = normalizeEvent(body.event);
    if (!event.career_id) {
      return json({ error: "career_id is required" }, 400);
    }
    if (!event.materia) {
      return json({ error: "materia is required" }, 400);
    }
    if (!event.instancia) {
      return json({ error: "instancia is required" }, 400);
    }

    event.anio = deriveAnio(event);

    const payload: Record<string, unknown> = {
      career_id: event.career_id,
      anio: event.anio,
      fecha: event.fecha,
      hora: event.hora,
      materia: event.materia,
      instancia: event.instancia,
      docentes: event.docentes,
      acta_url: event.acta_url,
    };

    if (event.id) {
      payload.id = event.id;
    }

    const { data, error } = await supabase
      .from("exam_events")
      .upsert(payload, { onConflict: "id" })
      .select(
        "id, career_id, anio, fecha, hora, materia, instancia, docentes, acta_url",
      )
      .single();

    if (error) throw error;

    return json({ ok: true, event: data }, 200);
  } catch (error) {
    console.error(error);
    return json(
      {
        ok: false,
        error: error instanceof Error ? error.message : String(error),
      },
      500,
    );
  }
});

function normalizeEvent(raw: unknown): ExamEventPayload {
  if (!raw || typeof raw !== "object") return {};
  const obj = raw as Record<string, unknown>;

  return {
    id: stringValue(obj.id),
    career_id: stringValue(obj.career_id) || stringValue(obj.careerId),
    anio: numberValue(obj.anio),
    fecha: dateValue(obj.fecha),
    hora: timeValue(obj.hora),
    materia: stringValue(obj.materia),
    instancia: stringValue(obj.instancia),
    docentes: Array.isArray(obj.docentes)
      ? obj.docentes.map((value) => stringValue(value)).filter(Boolean)
      : [],
    acta_url: stringValue(obj.acta_url) || stringValue(obj.actaUrl) || null,
  };
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function numberValue(value: unknown) {
  if (value == null) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const parsed = Number.parseInt(String(value).trim(), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function dateValue(value: unknown) {
  const text = stringValue(value);
  return text || null;
}

function timeValue(value: unknown) {
  const text = stringValue(value);
  return text || null;
}

function deriveAnio(event: ExamEventPayload) {
  if (event.anio != null) return event.anio;

  const careerId = (event.career_id ?? "").toLowerCase();
  const materia = normalizeText(event.materia ?? "");
  const instancia = (event.instancia ?? "").toLowerCase();

  if (careerId === "historia" && instancia === "coloquio") {
    if (/\bpractica docente i\b/.test(materia)) return 1;
    if (/\bdidactica de las ciencias sociales\b/.test(materia)) return 2;
    if (/\bpractica docente ii\b/.test(materia)) return 2;
    if (/\bepistemologia de la historia\b/.test(materia)) return 3;
    if (/\bpractica docente iii\b/.test(materia)) return 3;
  }

  if (careerId === "geografia" && instancia === "coloquio") {
    if (/\bpractica docente iii\b/.test(materia)) return 3;
  }

  if (careerId === "politica" && instancia === "coloquio") {
    if (/\bdidactica de las ciencias sociales\b/.test(materia)) return 2;
    if (/\bpractica docente ii\b/.test(materia)) return 2;
    if (/\bpractica docente iii\b/.test(materia)) return 3;
  }

  return event.anio;
}

function normalizeText(value: string) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ")
    .trim();
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
