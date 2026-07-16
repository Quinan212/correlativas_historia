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

    let student: Record<string, unknown> | null = null;

    const studentId = stringValue(
      user.user_metadata?.academic_student_id ?? "",
    );
    const email = stringValue(user.email);
    const isAnonymous = user.is_anonymous === true;
    let dni = "";

    if (isAnonymous) {
      const requestCareerId = body?.career_id != null
        ? stringValue(body.career_id)
        : "historia";
      const rawDni = body?.dni != null ? stringValue(body.dni) : "";
      const guestDni = rawDni || user.id.replace(/-/g, "").slice(0, 9);
      const guestName = body?.first_name != null
        ? stringValue(body.first_name)
        : "Invitado";

      const { data: existingStudent, error: lookupError } = await supabase
        .from("academic_students")
        .select(
          "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
        )
        .eq("dni", guestDni)
        .eq("career_id", requestCareerId)
        .maybeSingle();
      if (lookupError) throw lookupError;

      if (existingStudent) {
        student = existingStudent;
      } else if (action === "load") {
        const { data: newStudent, error: createError } = await supabase
          .from("academic_students")
          .insert({
            dni: guestDni,
            first_name: guestName,
            last_name: "",
            career_id: requestCareerId,
            is_demo: true,
            cohort_year: new Date().getFullYear(),
            current_year: 1,
          })
          .select(
            "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
          )
          .single();
        if (createError) throw createError;
        const result = await buildLoadResponse(supabase, newStudent);
        return json(result);
      }
      student = existingStudent;
    } else {
      dni = email.includes("@") ? email.split("@")[0] : "";
      const { data: foundStudent, error: studentError } = await supabase
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
      student = foundStudent;
    }

    if (!student) {
      if (isAnonymous && action === "load") {
        const rawDni = body?.dni != null ? stringValue(body.dni) : "";
        const guestDni = rawDni || user.id.replace(/-/g, "").slice(0, 9);
        const guestCareer = body?.career_id != null
          ? stringValue(body.career_id)
          : "historia";
        const guestName = body?.first_name != null
          ? stringValue(body.first_name)
          : "Invitado";
        const { data: newStudent, error: createError } = await supabase
          .from("academic_students")
          .insert({
            dni: guestDni,
            first_name: guestName,
            last_name: "",
            career_id: guestCareer,
            is_demo: true,
            cohort_year: new Date().getFullYear(),
            current_year: 1,
          })
          .select(
            "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
          )
          .single();
        if (createError) throw createError;
        const result = await buildLoadResponse(supabase, newStudent);
        return json(result);
      }
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

      // Año actual y cohorte: editables por cualquier usuario.
      const currentYear = body?.current_year != null
        ? parseInt(body.current_year)
        : undefined;
      if (currentYear !== undefined && (currentYear < 1 || currentYear > 4)) {
        return json({ ok: false, error: "Año actual invalido (1 a 4)" }, 400);
      }
      const cohortYear = body?.cohort_year != null
        ? parseInt(body.cohort_year)
        : undefined;
      if (
        cohortYear !== undefined && (cohortYear < 2015 || cohortYear > 2026)
      ) {
        return json({ ok: false, error: "Cohorte invalida (2015 a 2026)" }, 400);
      }

      // Nombre, DNI, carrera y división son editables por cualquier usuario.
      const isDemo = student.is_demo === true;
      const firstName = body?.first_name !== undefined
        ? nullableString(body.first_name)
        : undefined;
      if (body?.first_name !== undefined && !firstName) {
        return json({ ok: false, error: "Nombre requerido" }, 400);
      }
      const lastName = body?.last_name !== undefined
        ? nullableString(body.last_name)
        : undefined;
      if (body?.last_name !== undefined && !lastName) {
        return json({ ok: false, error: "Apellido requerido" }, 400);
      }
      const requestedDni = body?.dni !== undefined
        ? (nullableString(body.dni)?.replaceAll(/\D/g, "") || null)
        : undefined;
      if (requestedDni !== undefined && !/^\d{7,9}$/.test(requestedDni ?? "")) {
        return json({ ok: false, error: "DNI invalido" }, 400);
      }
      if (requestedDni && requestedDni !== student.dni) {
        const { data: dniOwner, error: dniLookupError } = await supabase
          .from("academic_students")
          .select("id")
          .eq("dni", requestedDni)
          .neq("id", studentUuid)
          .maybeSingle();
        if (dniLookupError) throw dniLookupError;
        if (dniOwner) return dniAlreadyExists();
      }
      const careerId = body?.career_id !== undefined
        ? nullableString(body.career_id)
        : undefined;
      if (careerId !== undefined && careerId && !VALID_CAREERS.has(careerId)) {
        return json({ ok: false, error: "Carrera invalida" }, 400);
      }
      const division = body?.division !== undefined
        ? nullableString(body.division)?.toUpperCase() ?? null
        : undefined;
      if (division !== undefined && !["A", "B"].includes(division ?? "")) {
        return json({ ok: false, error: "Division invalida (A o B)" }, 400);
      }

      const updatePayload: Record<string, unknown> = {
        contact_phone: contactPhone,
        contact_email: contactEmail,
      };
      if (currentYear !== undefined) updatePayload.current_year = currentYear;
      if (cohortYear !== undefined) updatePayload.cohort_year = cohortYear;
      if (firstName !== undefined) updatePayload.first_name = firstName;
      if (lastName !== undefined) updatePayload.last_name = lastName;
      if (requestedDni !== undefined) updatePayload.dni = requestedDni;
      if (careerId !== undefined) updatePayload.career_id = careerId;
      if (division !== undefined) updatePayload.division = division;

      const { data: updatedStudent, error: updateError } = await supabase
        .from("academic_students")
        .update(updatePayload)
        .eq("id", studentUuid)
        .select(
          "id, dni, first_name, last_name, career_id, is_demo, cohort_year, current_year, division, is_new_student, is_repeating, enrollment_status, contact_phone, contact_email, notes",
        )
        .single();

      if (updateError?.code === "23505") return dniAlreadyExists();
      if (updateError) throw updateError;

      if (
        requestedDni && requestedDni !== student.dni && !isDemo &&
        user.is_anonymous !== true
      ) {
        const { error: authUpdateError } = await supabase.auth.admin.updateUserById(
          user.id,
          {
            email: `${requestedDni}@correlativas.local`,
            email_confirm: true,
          },
        );
        if (authUpdateError) {
          const { error: rollbackError } = await supabase
            .from("academic_students")
            .update({
              dni: student.dni,
              first_name: student.first_name,
              last_name: student.last_name,
              career_id: student.career_id,
              division: student.division,
              current_year: student.current_year,
              cohort_year: student.cohort_year,
              contact_phone: student.contact_phone,
              contact_email: student.contact_email,
            })
            .eq("id", studentUuid);
          if (rollbackError) console.error("DNI rollback failed", rollbackError);
          if (authUpdateError.message.toLowerCase().includes("already")) {
            return dniAlreadyExists();
          }
          throw authUpdateError;
        }
      }

      await supabase.from("academic_student_history").insert({
        student_id: studentUuid,
        event_type: "contact_update",
        payload: {
          contact_phone: contactPhone,
          contact_email: contactEmail,
          ...(currentYear !== undefined && { current_year: currentYear }),
          ...(cohortYear !== undefined && { cohort_year: cohortYear }),
          ...(firstName !== undefined && { first_name: firstName }),
          ...(lastName !== undefined && { last_name: lastName }),
          ...(requestedDni !== undefined && { dni: requestedDni }),
          ...(careerId !== undefined && { career_id: careerId }),
          ...(division !== undefined && { division }),
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
    const result = await buildLoadResponse(supabase, student);
    return json(result);
  } catch (error) {
    console.error("student-access error", error);
    const detail = error instanceof Error
      ? error.message
      : typeof error === "object" && error !== null
      ? JSON.stringify(error)
      : String(error);
    return json(
      { ok: false, error: detail },
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

function dniAlreadyExists() {
  return json(
    {
      ok: false,
      code: "dni_already_exists",
      error: "Ese DNI ya pertenece a otro usuario",
    },
    409,
  );
}

async function buildLoadResponse(
  supabase: ReturnType<typeof createClient>,
  student: Record<string, unknown>,
) {
  const studentUuid = stringValue(student.id);
  const [{ data: subjects }, { data: history }, { data: selfSubjects }] =
    await Promise.all([
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

  return {
    ok: true,
    student,
    subjects: subjects ?? [],
    history: history ?? [],
    self_subjects: selfSubjects ?? [],
  };
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
