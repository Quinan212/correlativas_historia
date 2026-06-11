import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

const VALID_CAREERS = new Set([
  "artes_visuales",
  "musica",
  "historia",
  "geografia",
  "politica",
  "filosofia",
  "fisica",
  "biologia",
  "comunicacion_social",
  "psicologia",
  "lengua_literatura",
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

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ ok: false, error: "Method not allowed" }, 405);
  }

  try {
    const body = await req.json().catch(() => ({}));
    const action = stringValue(body?.action || "load") || "load";

    const authHeader = req.headers.get("Authorization") ?? "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!token) {
      return json({ ok: false, error: "Authorization token required" }, 401);
    }

    const { data: userData, error: userError } = await supabase.auth.getUser(
      token,
    );
    if (userError) throw userError;

    const user = userData.user;
    if (!user) {
      return json({ ok: false, error: "User not found" }, 404);
    }

    const studentId = stringValue(
      user.user_metadata?.academic_student_id ?? "",
    );
    const email = stringValue(user.email);
    const dni = email.includes("@") ? email.split("@")[0] : "";

    const { data: student, error: studentError } = await supabase
      .from("academic_students")
      .select(
        "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
      )
      .or(
        studentId
          ? `id.eq.${studentId},dni.eq.${dni}`
          : `dni.eq.${dni}`,
      )
      .maybeSingle();
    if (studentError) throw studentError;

    if (!student) {
      return json({ ok: false, error: "Student profile not found" }, 404);
    }

    const studentUuid = stringValue(student.id);

    // ─── update_contact ─────────────────────────────────────
    if (action === "update_contact") {
      const contactPhone = nullableString(body?.contact_phone);
      const contactEmail = nullableString(body?.contact_email);

      if (contactEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contactEmail)) {
        return json({ ok: false, error: "E-mail invalido" }, 400);
      }

      const { data: updatedStudent, error: updateError } = await supabase
        .from("academic_students")
        .update({
          contact_phone: contactPhone,
          contact_email: contactEmail,
        })
        .eq("id", studentUuid)
        .select(
          "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
        )
        .single();

      if (updateError) throw updateError;

      await supabase.from("academic_student_history").insert({
        student_id: studentUuid,
        event_type: "contact_update",
        payload: {
          contact_phone: contactPhone,
          contact_email: contactEmail,
        },
      });

      return json({
        ok: true,
        student: updatedStudent,
      });
    }

    // ─── upsert_self_subject (alumno autogestiona) ──────────
    if (action === "upsert_self_subject") {
      const subjectId = stringValue(body.subject_id);
      const subjectName = stringValue(body.subject_name);
      const subjectYear = body.subject_year != null
        ? parseInt(body.subject_year)
        : null;
      const status = stringValue(body.status) || "cursando";
      const academicPeriod = nullableString(body.academic_period);
      const sourceDate = nullableString(body.source_date);
      const grade = body.grade != null ? parseFloat(body.grade) : null;
      const notes = nullableString(body.notes);

      if (!subjectId || !subjectName) {
        return json(
          { ok: false, error: "Materia y nombre son requeridos" },
          400,
        );
      }

      if (!["cursando", "regular", "aprobada", "no_regularizada"].includes(status)) {
        return json({ ok: false, error: "Estado invalido" }, 400);
      }

      if (academicPeriod != null && !VALID_ACADEMIC_PERIODS.has(academicPeriod)) {
        return json({ ok: false, error: "Periodo academico invalido" }, 400);
      }

      const payload: Record<string, unknown> = {
        student_id: studentUuid,
        career_id: stringValue(student.career_id),
        subject_id: subjectId,
        subject_name: subjectName,
        subject_year: subjectYear,
        status,
        condition_status: "habilitada",
        academic_period: academicPeriod,
        source_period: academicPeriod,
        source_date: sourceDate,
        grade,
        notes,
        admin_note: "Auto-reportado por el alumno",
      };

      const existingId = nullableString(body.id);
      if (existingId) {
        payload.id = existingId;
      }

      const { data: saved, error: upsertError } = await supabase
        .from("academic_student_subjects")
        .upsert(payload, { onConflict: "student_id,subject_id" })
        .select()
        .single();

      if (upsertError) throw upsertError;

      await supabase.from("academic_student_history").insert({
        student_id: studentUuid,
        event_type: "self_subject_upsert",
        payload: {
          subject_name: subjectName,
          status,
          academic_period: academicPeriod,
          grade,
        },
      });

      return json({ ok: true, subject: saved });
    }

    // ─── delete_self_subject (alumno borra lo que cargó) ────
    if (action === "delete_self_subject") {
      const subjectId = stringValue(body.subject_id);
      if (!subjectId) {
        return json({ ok: false, error: "subject_id requerido" }, 400);
      }

      // Solo permite borrar materias auto-reportadas (admin_note = "Auto-reportado por el alumno")
      const { data: existing, error: findError } = await supabase
        .from("academic_student_subjects")
        .select("id, subject_name, admin_note")
        .eq("student_id", studentUuid)
        .eq("subject_id", subjectId)
        .eq("admin_note", "Auto-reportado por el alumno")
        .maybeSingle();

      if (findError) throw findError;
      if (!existing) {
        return json(
          { ok: false, error: "Solo podes borrar materias que cargaste vos" },
          403,
        );
      }

      const { error: deleteError } = await supabase
        .from("academic_student_subjects")
        .delete()
        .eq("id", existing.id);

      if (deleteError) throw deleteError;

      await supabase.from("academic_student_history").insert({
        student_id: studentUuid,
        event_type: "self_subject_delete",
        payload: { subject_name: existing.subject_name },
      });

      return json({ ok: true, deleted: true });
    }

    // ─── list_self_subjects ─────────────────────────────────
    if (action === "list_self_subjects") {
      const { data: selfSubjects, error: selfError } = await supabase
        .from("academic_student_subjects")
        .select(
          "id, student_id, career_id, subject_id, subject_name, subject_year, status, condition_status, detail_status, credit_type, academic_period, source_period, source_date, grade, notes, admin_note, updated_at",
        )
        .eq("student_id", studentUuid)
        .eq("admin_note", "Auto-reportado por el alumno")
        .order("subject_year")
        .order("subject_name");

      if (selfError) throw selfError;

      return json({ ok: true, subjects: selfSubjects ?? [] });
    }

    // ─── load (trayectoria completa) ────────────────────────
    const [{ data: subjects, error: subjectsError }, {
      data: history,
      error: historyError,
    }, {
      data: selfSubjects,
      error: selfError,
    }] = await Promise.all([
      supabase
        .from("academic_student_subjects")
        .select(
          "id, student_id, career_id, subject_id, subject_name, subject_year, status, detail_status, condition_status, credit_type, academic_period, source_period, source_date, grade, notes, admin_note, updated_at",
        )
        .eq("student_id", studentUuid)
        .neq("admin_note", "Auto-reportado por el alumno")
        .order("subject_year")
        .order("subject_name"),
      supabase
        .from("academic_student_history")
        .select("id, event_type, payload, created_at")
        .eq("student_id", studentUuid)
        .order("created_at", { ascending: false })
        .limit(40),
      supabase
        .from("academic_student_subjects")
        .select(
          "id, student_id, career_id, subject_id, subject_name, subject_year, status, detail_status, condition_status, credit_type, academic_period, source_period, source_date, grade, notes, admin_note, updated_at",
        )
        .eq("student_id", studentUuid)
        .eq("admin_note", "Auto-reportado por el alumno")
        .order("subject_year")
        .order("subject_name"),
    ]);

    if (subjectsError) throw subjectsError;
    if (historyError) throw historyError;
    if (selfError) throw selfError;

    return json({
      ok: true,
      student,
      subjects: subjects ?? [],
      history: history ?? [],
      self_subjects: selfSubjects ?? [],
    });
  } catch (error) {
    return json(
      {
        ok: false,
        error: error instanceof Error ? error.message : String(error),
      },
      500,
    );
  }
});

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function stringValue(value: unknown) {
  return String(value ?? "").trim();
}

function nullableString(value: unknown) {
  const text = stringValue(value);
  return text.length ? text : null;
}

function parseInt(value: unknown) {
  if (value == null || value === "") return null;
  const parsed = Number.parseInt(String(value).trim(), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function parseFloat(value: unknown) {
  if (value == null || value === "") return null;
  const normalized = String(value).trim().replace(",", ".");
  const parsed = Number.parseFloat(normalized);
  return Number.isFinite(parsed) ? parsed : null;
}