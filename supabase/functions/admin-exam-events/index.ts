import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const EVENT_COLUMNS = [
  "id",
  "career_id",
  "anio",
  "fecha",
  "hora",
  "materia",
  "instancia",
  "docentes",
  "division",
  "acta_url",
  "suspendido",
  "legacy",
  "estado",
  "titulo_estado",
  "mensaje_estado",
  "fecha_reprogramada",
  "hora_reprogramada",
  "acta_habilitada",
  "visible",
  "updated_at",
  "updated_by_device_id",
].join(", ");

const VALID_STATUSES = new Set([
  "activa",
  "suspendida",
  "cancelada",
  "reprogramada",
]);

type JsonObject = Record<string, unknown>;

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
  estado?: string;
  titulo_estado?: string | null;
  mensaje_estado?: string | null;
  fecha_reprogramada?: string | null;
  hora_reprogramada?: string | null;
  acta_habilitada?: boolean;
  visible?: boolean;
  expected_updated_at?: string | null;
};

class HttpError extends Error {
  constructor(
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "Method not allowed" }, 405);
  }

  try {
    const body = objectValue(await req.json());
    const deviceId = stringValue(body.device_id);
    const action = stringValue(body.action);

    if (!deviceId) throw new HttpError("device_id is required", 400);
    if (!action) throw new HttpError("action is required", 400);

    await requireAdminDevice(deviceId);

    if (action === "delete") {
      const id = stringValue(body.id);
      if (!id) throw new HttpError("id is required", 400);
      return await deleteEvent(id, deviceId);
    }

    if (action !== "upsert") {
      throw new HttpError("invalid action", 400);
    }

    const rawEvent = objectValue(body.event);
    const event = normalizeEvent(rawEvent);
    const current = event.id ? await fetchEvent(event.id) : null;

    if (event.id && !current) {
      throw new HttpError("La mesa ya no existe o fue eliminada.", 404);
    }

    assertFreshVersion(event.expected_updated_at, current?.updated_at);

    const payload = buildPayload({
      raw: rawEvent,
      event,
      current,
      deviceId,
    });

    const isUpdate = current != null;
    const query = isUpdate
      ? supabase.from("exam_events").update(payload).eq("id", current.id)
      : supabase.from("exam_events").insert(payload);

    const { data, error } = await query.select(EVENT_COLUMNS).single();
    if (error) throw error;

    await writeAudit({
      examEventId: data.id,
      action: isUpdate ? "update" : "insert",
      deviceId,
      previousData: current,
      newData: data,
    });

    return json({ ok: true, event: data }, 200);
  } catch (error) {
    console.error(error);
    const status = error instanceof HttpError ? error.status : 500;
    return json(
      {
        ok: false,
        error: error instanceof Error ? error.message : String(error),
      },
      status,
    );
  }
});

async function requireAdminDevice(deviceId: string) {
  const { data, error } = await supabase
    .from("admin_devices")
    .select("device_id, enabled")
    .eq("device_id", deviceId)
    .eq("enabled", true)
    .maybeSingle();

  if (error) throw error;
  if (!data) throw new HttpError("admin access required", 403);
}

async function fetchEvent(id: string) {
  const { data, error } = await supabase
    .from("exam_events")
    .select(EVENT_COLUMNS)
    .eq("id", id)
    .maybeSingle();

  if (error) throw error;
  return data as JsonObject | null;
}

async function deleteEvent(id: string, deviceId: string) {
  const current = await fetchEvent(id);
  if (!current) {
    throw new HttpError("La mesa ya no existe o fue eliminada.", 404);
  }

  const { error } = await supabase.from("exam_events").delete().eq("id", id);
  if (error) throw error;

  await writeAudit({
    examEventId: id,
    action: "delete",
    deviceId,
    previousData: current,
    newData: null,
  });

  return json({ ok: true }, 200);
}

function buildPayload({
  raw,
  event,
  current,
  deviceId,
}: {
  raw: JsonObject;
  event: ExamEventPayload;
  current: JsonObject | null;
  deviceId: string;
}) {
  const statusProvided = hasAny(raw, ["estado"]);
  const titleProvided = hasAny(raw, ["titulo_estado", "tituloEstado"]);
  const messageProvided = hasAny(raw, ["mensaje_estado", "mensajeEstado"]);
  const rescheduledDateProvided = hasAny(raw, [
    "fecha_reprogramada",
    "fechaReprogramada",
  ]);
  const rescheduledTimeProvided = hasAny(raw, [
    "hora_reprogramada",
    "horaReprogramada",
  ]);
  const actEnabledProvided = hasAny(raw, [
    "acta_habilitada",
    "actaHabilitada",
  ]);
  const visibleProvided = hasAny(raw, ["visible"]);

  const careerId = event.career_id || stringValue(current?.career_id);
  const materia = event.materia || stringValue(current?.materia);
  const instancia = event.instancia || stringValue(current?.instancia);

  if (!careerId) throw new HttpError("career_id is required", 400);
  if (!materia) throw new HttpError("materia is required", 400);
  if (!instancia) throw new HttpError("instancia is required", 400);
  if (!["llamado_1", "llamado_2", "coloquio"].includes(instancia)) {
    throw new HttpError("instancia is invalid", 400);
  }

  const currentStatus = normalizeStatus(current?.estado) ||
    (booleanValue(current?.suspendido, false) ? "suspendida" : "activa");
  const status = statusProvided
    ? normalizeStatus(event.estado)
    : currentStatus || "activa";

  if (!status || !VALID_STATUSES.has(status)) {
    throw new HttpError("estado is invalid", 400);
  }

  const title = titleProvided
    ? nullableString(event.titulo_estado)
    : nullableString(current?.titulo_estado);
  const message = messageProvided
    ? nullableString(event.mensaje_estado)
    : nullableString(current?.mensaje_estado);
  const rescheduledDate = rescheduledDateProvided
    ? event.fecha_reprogramada ?? null
    : nullableString(current?.fecha_reprogramada);
  const rescheduledTime = rescheduledTimeProvided
    ? event.hora_reprogramada ?? null
    : timeValue(current?.hora_reprogramada);

  if (status === "reprogramada" && (!rescheduledDate || !rescheduledTime)) {
    throw new HttpError(
      "Una mesa reprogramada requiere nueva fecha y nueva hora.",
      400,
    );
  }

  const normalizedEvent: ExamEventPayload = {
    ...event,
    career_id: careerId,
    materia,
    instancia,
    anio: event.anio ?? numberValue(current?.anio),
  };
  const derivedYear = deriveAnio(normalizedEvent);

  return {
    career_id: careerId,
    anio: derivedYear,
    fecha: hasAny(raw, ["fecha"]) ? event.fecha ?? null : current?.fecha ?? null,
    hora: hasAny(raw, ["hora"])
      ? event.hora ?? null
      : timeValue(current?.hora),
    materia,
    instancia,
    docentes: hasAny(raw, ["docentes"])
      ? event.docentes ?? []
      : arrayOfStrings(current?.docentes),
    acta_url: hasAny(raw, ["acta_url", "actaUrl"])
      ? event.acta_url ?? null
      : nullableString(current?.acta_url),
    estado: status,
    titulo_estado: status === "activa"
      ? null
      : title || defaultTitle(status),
    mensaje_estado: status === "activa"
      ? null
      : message || defaultMessage(status),
    fecha_reprogramada: status === "reprogramada" ? rescheduledDate : null,
    hora_reprogramada: status === "reprogramada" ? rescheduledTime : null,
    acta_habilitada: actEnabledProvided
      ? event.acta_habilitada ?? true
      : booleanValue(current?.acta_habilitada, true),
    visible: visibleProvided
      ? event.visible ?? true
      : booleanValue(current?.visible, true),
    suspendido: status === "suspendida" || status === "cancelada",
    updated_by_device_id: deviceId,
  };
}

function normalizeEvent(raw: JsonObject): ExamEventPayload {
  return {
    id: stringValue(raw.id),
    career_id: stringValue(raw.career_id) || stringValue(raw.careerId),
    anio: numberValue(raw.anio),
    fecha: dateValue(raw.fecha),
    hora: timeValue(raw.hora),
    materia: stringValue(raw.materia),
    instancia: stringValue(raw.instancia),
    docentes: arrayOfStrings(raw.docentes),
    acta_url: nullableString(raw.acta_url ?? raw.actaUrl),
    estado: normalizeStatus(raw.estado),
    titulo_estado: nullableString(raw.titulo_estado ?? raw.tituloEstado),
    mensaje_estado: nullableString(raw.mensaje_estado ?? raw.mensajeEstado),
    fecha_reprogramada: dateValue(
      raw.fecha_reprogramada ?? raw.fechaReprogramada,
    ),
    hora_reprogramada: timeValue(
      raw.hora_reprogramada ?? raw.horaReprogramada,
    ),
    acta_habilitada: optionalBoolean(
      raw.acta_habilitada ?? raw.actaHabilitada,
    ),
    visible: optionalBoolean(raw.visible),
    expected_updated_at: nullableString(raw.expected_updated_at),
  };
}

function assertFreshVersion(expectedRaw: unknown, currentRaw: unknown) {
  const expected = nullableString(expectedRaw);
  const current = nullableString(currentRaw);
  if (!expected || !current) return;

  const expectedDate = Date.parse(expected);
  const currentDate = Date.parse(current);
  if (
    Number.isFinite(expectedDate) &&
    Number.isFinite(currentDate) &&
    expectedDate !== currentDate
  ) {
    throw new HttpError(
      "La mesa cambió desde que abriste el editor. Volvé a cargarla antes de guardar.",
      409,
    );
  }
}

async function writeAudit({
  examEventId,
  action,
  deviceId,
  previousData,
  newData,
}: {
  examEventId: string;
  action: "insert" | "update" | "delete";
  deviceId: string;
  previousData: JsonObject | null;
  newData: JsonObject | null;
}) {
  const { error } = await supabase.from("exam_event_change_log").insert({
    exam_event_id: examEventId,
    action,
    device_id: deviceId,
    previous_data: previousData,
    new_data: newData,
  });

  // El registro principal ya fue guardado. Un problema aislado de auditoría se
  // informa en logs para evitar que el cliente repita una escritura exitosa.
  if (error) console.error("exam_event_change_log:", error);
}

function defaultTitle(status: string) {
  switch (status) {
    case "suspendida":
      return "MESA SUSPENDIDA";
    case "cancelada":
      return "MESA CANCELADA";
    case "reprogramada":
      return "MESA REPROGRAMADA";
    default:
      return null;
  }
}

function defaultMessage(status: string) {
  switch (status) {
    case "suspendida":
      return "Pendiente de reprogramación por la institución.";
    case "cancelada":
      return "La mesa fue cancelada por la institución.";
    case "reprogramada":
      return "La mesa tiene una nueva fecha y horario.";
    default:
      return null;
  }
}

function objectValue(value: unknown): JsonObject {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as JsonObject
    : {};
}

function hasAny(obj: JsonObject, keys: string[]) {
  return keys.some((key) => Object.prototype.hasOwnProperty.call(obj, key));
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function nullableString(value: unknown) {
  const text = stringValue(value);
  return text || null;
}

function numberValue(value: unknown) {
  if (value == null) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  const parsed = Number.parseInt(String(value).trim(), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function dateValue(value: unknown) {
  const text = stringValue(value);
  if (!text) return null;
  const match = /^\d{4}-\d{2}-\d{2}/.exec(text);
  if (!match) throw new HttpError("fecha is invalid", 400);
  return match[0];
}

function timeValue(value: unknown) {
  const text = stringValue(value);
  if (!text) return null;
  const match = /^(\d{1,2}):(\d{2})/.exec(text);
  if (!match) throw new HttpError("hora is invalid", 400);
  const hour = Number.parseInt(match[1], 10);
  const minute = Number.parseInt(match[2], 10);
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    throw new HttpError("hora is invalid", 400);
  }
  return `${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
}

function optionalBoolean(value: unknown) {
  if (value == null) return undefined;
  return booleanValue(value, false);
}

function booleanValue(value: unknown, fallback: boolean) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  const text = stringValue(value).toLowerCase();
  if (text === "true" || text === "1") return true;
  if (text === "false" || text === "0") return false;
  return fallback;
}

function arrayOfStrings(value: unknown) {
  if (!Array.isArray(value)) return [];
  return value.map(stringValue).filter(Boolean);
}

function normalizeStatus(value: unknown) {
  const status = stringValue(value).toLowerCase();
  switch (status) {
    case "activo":
      return "activa";
    case "suspendido":
      return "suspendida";
    case "cancelado":
      return "cancelada";
    case "reprogramado":
      return "reprogramada";
    default:
      return status;
  }
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

  return event.anio ?? null;
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
