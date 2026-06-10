import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const DEFAULT_PASSWORD = "Correlativas.2026";
const VALID_CAREERS = new Set([
  "artes_visuales",
  "musica",
  "historia",
  "geografia",
  "politica",
]);
const VALID_ACADEMIC_PERIODS = new Set([
  "febrero",
  "mayo_extraordinaria",
  "julio",
  "diciembre",
  "regular",
  "cursada",
  "tif",
  "equivalencia",
  "ajuste",
]);

type StudentPayload = {
  id?: string;
  dni: string;
  first_name: string;
  last_name: string;
  career_id: string;
  is_demo: boolean;
  cohort_year?: number | null;
  current_year?: number | null;
  division?: string | null;
  is_new_student: boolean;
  is_repeating: boolean;
  enrollment_status: string;
  initial_password: string;
  must_change_password: boolean;
  notes?: string | null;
};

type SubjectPayload = {
  id?: string;
  student_id: string;
  career_id: string;
  subject_id: string;
  subject_name: string;
  subject_year?: number | null;
  status: string;
  condition_status: string;
  detail_status?: string | null;
  credit_type?: string | null;
  academic_period?: string | null;
  source_date?: string | null;
  grade?: number | null;
  condition_deadline?: string | null;
  notes?: string | null;
  admin_note?: string | null;
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "Method not allowed" }, 405);
  }

  try {
    const body = await req.json();
    const deviceId = stringValue(body.device_id);
    const action = stringValue(body.action);

    if (!deviceId) return json({ ok: false, error: "device_id is required" }, 400);
    if (!action) return json({ ok: false, error: "action is required" }, 400);

    const allowed = await isAdminDevice(deviceId);
    if (!allowed) return json({ ok: false, error: "admin access required" }, 403);

    if (action === "list") {
      const careerId = stringValue(body.career_id);
      let query = supabase
        .from("academic_students")
        .select(
          "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, initial_password, must_change_password, notes, created_at, updated_at",
        )
        .order("last_name")
        .order("first_name");

      if (careerId) query = query.eq("career_id", careerId);

      const { data, error } = await query;
      if (error) throw error;

      const studentRows = data ?? [];
      const studentIds = studentRows
        .map((row: any) => row?.id?.toString())
        .filter((id: string | undefined): id is string => Boolean(id));

      const subjectCountsByStudent = new Map<string, number>();
      if (studentIds.length > 0) {
        const { data: subjectRows, error: subjectError } = await supabase
          .from("academic_student_subjects")
          .select("student_id")
          .in("student_id", studentIds);
        if (subjectError) throw subjectError;
        for (const subject of subjectRows ?? []) {
          const studentId = stringValue((subject as any)?.student_id);
          if (!studentId) continue;
          subjectCountsByStudent.set(
            studentId,
            (subjectCountsByStudent.get(studentId) ?? 0) + 1,
          );
        }
      }

      const enrichedStudents = studentRows.map((row: any) => ({
        ...row,
        academic_progress_count:
          subjectCountsByStudent.get(row?.id?.toString() ?? "") ?? 0,
      }));

      return json({ ok: true, students: enrichedStudents });
    }

    if (action === "upsert") {
      const student = normalizeStudent(body.student);
      const validation = validateStudent(student);
      if (validation) return json({ ok: false, error: validation }, 400);

      const payload = toRow(student, deviceId);
      const { data, error } = await supabase
        .from("academic_students")
        .upsert(payload, { onConflict: "dni" })
        .select()
        .single();
      if (error) throw error;

      await insertHistory(data.id, "student_upsert", payload, deviceId);
      return json({ ok: true, student: data });
    }

    if (action === "list_subjects") {
      const studentId = stringValue(body.student_id);
      if (!studentId) {
        return json({ ok: false, error: "student_id is required" }, 400);
      }

      const { data, error } = await supabase
        .from("academic_student_subjects")
        .select(
          "id, student_id, career_id, subject_id, subject_name, subject_year, status, condition_status, detail_status, credit_type, academic_period, source_period, source_date, grade, condition_deadline, notes, admin_note, updated_at",
        )
        .eq("student_id", studentId)
        .order("subject_year")
        .order("subject_name");
      if (error) throw error;
      return json({ ok: true, subjects: data ?? [] });
    }

    if (action === "list_history") {
      const studentId = stringValue(body.student_id);
      if (!studentId) {
        return json({ ok: false, error: "student_id is required" }, 400);
      }

      const { data: studentRow, error: studentError } = await supabase
        .from("academic_students")
        .select("id, is_demo")
        .eq("id", studentId)
        .maybeSingle();
      if (studentError) throw studentError;
      if (!studentRow || studentRow.is_demo === true) {
        return json({ ok: true, history: [] });
      }

      const { data, error } = await supabase
        .from("academic_student_history")
        .select("id, event_type, payload, created_at")
        .eq("student_id", studentId)
        .order("created_at", { ascending: false })
        .limit(80);
      if (error) throw error;
      return json({ ok: true, history: data ?? [] });
    }

    if (action === "list_subject_roster") {
      const careerId = stringValue(body.career_id);
      const subjectId = stringValue(body.subject_id);
      if (!careerId) {
        return json({ ok: false, error: "career_id is required" }, 400);
      }
      if (!subjectId) {
        return json({ ok: false, error: "subject_id is required" }, 400);
      }

      const { data, error } = await supabase
        .from("academic_student_subjects")
        .select(
          "id, student_id, career_id, subject_id, subject_name, subject_year, status, condition_status, detail_status, credit_type, academic_period, source_period, source_date, grade, condition_deadline, notes, admin_note, updated_at, academic_students!inner(dni, first_name, last_name, current_year, division, is_demo)",
        )
        .eq("career_id", careerId)
        .eq("subject_id", subjectId)
        .order("subject_name")
        .order("last_name", { referencedTable: "academic_students", ascending: true })
        .order("first_name", { referencedTable: "academic_students", ascending: true });
      if (error) throw error;
      const roster = (data ?? []).filter(
        (row: any) => row?.academic_students?.is_demo !== true,
      );
      return json({ ok: true, roster });
    }

    if (action === "upsert_subject") {
      const subject = normalizeSubject(body.subject);
      const validation = await validateSubject(subject);
      if (validation) return json({ ok: false, error: validation }, 400);

      const payload = subjectToRow(subject, deviceId);
      const { data, error } = await supabase
        .from("academic_student_subjects")
        .upsert(payload, { onConflict: "student_id,subject_id" })
        .select()
        .single();
      if (error) throw error;

      await insertHistory(subject.student_id, "subject_upsert", payload, deviceId);
      return json({ ok: true, subject: data });
    }

    if (action === "bulk_upsert_subjects") {
      const rawSubjects = Array.isArray(body.subjects) ? body.subjects : [];
      const normalized = rawSubjects.map(normalizeSubject);
      const errors: string[] = [];
      const rows: Record<string, unknown>[] = [];

      for (let index = 0; index < normalized.length; index++) {
        const subject = normalized[index];
        const validation = await validateSubject(subject);
        if (validation) {
          errors.push(`Materia ${index + 1}: ${validation}`);
          continue;
        }
        rows.push(subjectToRow(subject, deviceId));
      }

      if (errors.length > 0) {
        return json({ ok: false, error: errors.join("\n") }, 400);
      }

      if (rows.length === 0) {
        return json({ ok: false, error: "No hay materias para guardar" }, 400);
      }

      const { data, error } = await supabase
        .from("academic_student_subjects")
        .upsert(rows, { onConflict: "student_id,subject_id" })
        .select();
      if (error) throw error;

      for (const subject of data ?? []) {
        await insertHistory(subject.student_id, "subjects_bulk_upsert", subject, deviceId);
      }

      return json({ ok: true, subjects: data ?? [], count: data?.length ?? 0 });
    }

    if (action === "bulk_upsert") {
      const rawStudents = Array.isArray(body.students) ? body.students : [];
      const normalized = rawStudents.map(normalizeStudent);
      const errors: string[] = [];
      const rows: Record<string, unknown>[] = [];

      normalized.forEach((student, index) => {
        const validation = validateStudent(student);
        if (validation) {
          errors.push(`Fila ${index + 1}: ${validation}`);
          return;
        }
        rows.push(toRow(student, deviceId));
      });

      if (errors.length > 0) {
        return json({ ok: false, error: errors.join("\n") }, 400);
      }

      if (rows.length === 0) {
        return json({ ok: false, error: "No hay alumnos para cargar" }, 400);
      }

      const { data, error } = await supabase
        .from("academic_students")
        .upsert(rows, { onConflict: "dni" })
        .select();
      if (error) throw error;

      for (const student of data ?? []) {
        await insertHistory(student.id, "student_bulk_upsert", student, deviceId);
      }

      return json({ ok: true, students: data ?? [], count: data?.length ?? 0 });
    }

    return json({ ok: false, error: "invalid action" }, 400);
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

async function isAdminDevice(deviceId: string) {
  const { data, error } = await supabase
    .from("admin_devices")
    .select("device_id")
    .eq("device_id", deviceId)
    .eq("enabled", true)
    .maybeSingle();
  if (error) throw error;
  return data != null;
}

function normalizeSubject(raw: unknown): SubjectPayload {
  const obj = raw && typeof raw === "object" ? raw as Record<string, unknown> : {};
  return {
    id: stringValue(obj.id) || undefined,
    student_id: stringValue(obj.student_id) || stringValue(obj.studentId),
    career_id: stringValue(obj.career_id) || stringValue(obj.careerId),
    subject_id: stringValue(obj.subject_id) || stringValue(obj.subjectId),
    subject_name: stringValue(obj.subject_name) || stringValue(obj.subjectName),
    subject_year: numberValue(obj.subject_year ?? obj.subjectYear),
    status: stringValue(obj.status) || "cursando",
    condition_status: stringValue(obj.condition_status) ||
      stringValue(obj.conditionStatus) ||
      "habilitada",
    detail_status: stringValue(obj.detail_status) ||
      stringValue(obj.detailStatus) ||
      null,
    credit_type: stringValue(obj.credit_type) || stringValue(obj.creditType) ||
      null,
    academic_period: stringValue(obj.academic_period) ||
      stringValue(obj.academicPeriod) ||
      stringValue(obj.source_period) ||
      null,
    source_date: dateValue(obj.source_date ?? obj.sourceDate),
    grade: decimalValue(obj.grade),
    condition_deadline: dateValue(obj.condition_deadline ?? obj.conditionDeadline),
    notes: stringValue(obj.notes) || null,
    admin_note: stringValue(obj.admin_note) || stringValue(obj.adminNote) || null,
  };
}

async function validateSubject(subject: SubjectPayload) {
  if (!subject.student_id) return "student_id requerido";
  if (!subject.subject_id) return "Materia requerida";
  if (!subject.subject_name) return "Nombre de materia requerido";
  if (!VALID_CAREERS.has(subject.career_id)) return "Carrera no habilitada";
  if (!["cursando", "regular", "aprobada", "no_regularizada"].includes(subject.status)) {
    return "Estado de materia invalido";
  }
  if (!["habilitada", "condicional", "bloqueada"].includes(subject.condition_status)) {
    return "Condicion de cursada invalida";
  }
  if (
    subject.academic_period != null &&
    !VALID_ACADEMIC_PERIODS.has(subject.academic_period)
  ) {
    return "Periodo academico invalido";
  }
  if (subject.subject_year != null && (subject.subject_year < 1 || subject.subject_year > 4)) {
    return "Año de materia invalido";
  }

  const { data, error } = await supabase
    .from("academic_students")
    .select("id, career_id")
    .eq("id", subject.student_id)
    .maybeSingle();
  if (error) throw error;
  if (!data) return "Alumno inexistente";
  if (data.career_id !== subject.career_id) {
    return "La materia no corresponde a la carrera del alumno";
  }
  return "";
}

function subjectToRow(subject: SubjectPayload, deviceId: string) {
  const row: Record<string, unknown> = {
    student_id: subject.student_id,
    career_id: subject.career_id,
    subject_id: subject.subject_id,
    subject_name: subject.subject_name,
    subject_year: subject.subject_year,
    status: subject.status,
    condition_status: subject.condition_status,
    detail_status: subject.detail_status,
    credit_type: subject.credit_type,
    academic_period: subject.academic_period,
    source_period: subject.academic_period,
    source_date: subject.source_date,
    grade: subject.grade,
    condition_deadline: subject.condition_deadline,
    notes: subject.notes,
    admin_note: subject.admin_note,
    updated_by_device_id: deviceId,
  };
  if (subject.id) row.id = subject.id;
  return row;
}

function normalizeStudent(raw: unknown): StudentPayload {
  const obj = raw && typeof raw === "object" ? raw as Record<string, unknown> : {};
  return {
    id: stringValue(obj.id) || undefined,
    dni: normalizeDni(obj.dni),
    first_name: stringValue(obj.first_name) || stringValue(obj.firstName),
    last_name: stringValue(obj.last_name) || stringValue(obj.lastName),
    career_id: stringValue(obj.career_id) || stringValue(obj.careerId) ||
      "artes_visuales",
    is_demo: boolValue(obj.is_demo ?? obj.isDemo, false),
    cohort_year: numberValue(obj.cohort_year ?? obj.cohortYear),
    current_year: numberValue(obj.current_year ?? obj.currentYear),
    division: stringValue(obj.division) || null,
    is_new_student: boolValue(obj.is_new_student ?? obj.isNewStudent, true),
    is_repeating: boolValue(obj.is_repeating ?? obj.isRepeating, false),
    enrollment_status: stringValue(obj.enrollment_status) || "active",
    initial_password: stringValue(obj.initial_password) || DEFAULT_PASSWORD,
    must_change_password: boolValue(obj.must_change_password, true),
    notes: stringValue(obj.notes) || null,
  };
}

function validateStudent(student: StudentPayload) {
  if (!student.dni) return "DNI requerido";
  if (!/^\d{7,9}$/.test(student.dni)) return "DNI invalido";
  if (!student.first_name) return "Nombre requerido";
  if (!student.last_name) return "Apellido requerido";
  if (!VALID_CAREERS.has(student.career_id)) return "Carrera no habilitada";
  if (
    student.current_year != null &&
    (student.current_year < 1 || student.current_year > 4)
  ) {
    return "Año debe estar entre 1 y 4";
  }
  return "";
}

function toRow(student: StudentPayload, deviceId: string) {
  const row: Record<string, unknown> = {
    dni: student.dni,
    first_name: student.first_name,
    last_name: student.last_name,
    career_id: student.career_id,
    is_demo: student.is_demo,
    cohort_year: student.cohort_year,
    current_year: student.current_year,
    division: student.career_id === "artes_visuales" ? "A" : student.division,
    is_new_student: student.is_new_student,
    is_repeating: student.is_repeating,
    enrollment_status: student.enrollment_status,
    initial_password: student.initial_password,
    must_change_password: student.must_change_password,
    notes: student.notes,
    updated_by_device_id: deviceId,
  };
  if (student.id) row.id = student.id;
  if (!student.id) row.created_by_device_id = deviceId;
  return row;
}

async function insertHistory(
  studentId: string,
  eventType: string,
  payload: unknown,
  deviceId: string,
) {
  const { error } = await supabase.from("academic_student_history").insert({
    student_id: studentId,
    event_type: eventType,
    payload,
    admin_device_id: deviceId,
  });
  if (error) console.error(error);
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function normalizeDni(value: unknown) {
  return String(value ?? "").replace(/\D/g, "").trim();
}

function numberValue(value: unknown) {
  if (value == null || value === "") return null;
  const parsed = Number.parseInt(String(value).trim(), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function decimalValue(value: unknown) {
  if (value == null || value === "") return null;
  const normalized = String(value).trim().replace(",", ".");
  const parsed = Number.parseFloat(normalized);
  return Number.isFinite(parsed) ? parsed : null;
}

function dateValue(value: unknown) {
  const text = stringValue(value);
  return text || null;
}

function boolValue(value: unknown, fallback: boolean) {
  if (typeof value === "boolean") return value;
  if (typeof value === "string") {
    const text = value.trim().toLowerCase();
    if (["true", "si", "sí", "1", "nuevo", "recursante"].includes(text)) {
      return true;
    }
    if (["false", "no", "0"].includes(text)) return false;
  }
  return fallback;
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
