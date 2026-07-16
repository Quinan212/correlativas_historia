import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const verificationBucket = "verification-evidence";
const matterPhotosBucket = "matter-community-photos";

type CleanupAction =
  | "clear_matter_reviews"
  | "clear_teacher_reviews"
  | "clear_photos"
  | "clear_verifications"
  | "reset_all";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const { device_id, action } = await req.json();
    const deviceId = typeof device_id === "string" ? device_id.trim() : "";
    const cleanupAction = typeof action === "string"
      ? action.trim() as CleanupAction
      : "";

    if (!deviceId) {
      return json({ error: "device_id is required" }, 400);
    }

    if (!cleanupAction) {
      return json({ error: "action is required" }, 400);
    }

    const validActions = new Set<CleanupAction>([
      "clear_matter_reviews",
      "clear_teacher_reviews",
      "clear_photos",
      "clear_verifications",
      "reset_all",
    ]);

    if (!validActions.has(cleanupAction)) {
      return json({ error: "invalid action" }, 400);
    }

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

    const summary: Record<string, number | string> = {
      action: cleanupAction,
      matter_reviews_deleted: 0,
      teacher_reviews_deleted: 0,
      photos_deleted: 0,
      verification_requests_deleted: 0,
      verification_permissions_deleted: 0,
      verification_files_removed: 0,
      photo_files_removed: 0,
    };

    if (
      cleanupAction === "clear_matter_reviews" || cleanupAction === "reset_all"
    ) {
      summary.matter_reviews_deleted = await deleteAllRows("matter_reviews");
    }

    if (
      cleanupAction === "clear_teacher_reviews" || cleanupAction === "reset_all"
    ) {
      summary.teacher_reviews_deleted = await deleteAllRows("teacher_reviews");
    }

    if (cleanupAction === "clear_photos" || cleanupAction === "reset_all") {
      const photos = await fetchRows("matter_photo_posts", "id, image_path");
      summary.photo_files_removed = await removeStorageFiles(
        matterPhotosBucket,
        photos.map((row) => stringValue(row.image_path)),
      );
      summary.photos_deleted = await deleteRowsByIds("matter_photo_posts", photos);
    }

    if (
      cleanupAction === "clear_verifications" || cleanupAction === "reset_all"
    ) {
      const verifications = await fetchRows(
        "verification_requests",
        "id, image_path",
      );
      summary.verification_files_removed = await removeStorageFiles(
        verificationBucket,
        verifications.map((row) => stringValue(row.image_path)),
      );
      summary.verification_requests_deleted = await deleteRowsByIds(
        "verification_requests",
        verifications,
      );

      const permissions = await fetchRows("device_subject_permissions", "id");
      summary.verification_permissions_deleted = await deleteRowsByIds(
        "device_subject_permissions",
        permissions,
      );
    }

    return json({ ok: true, summary }, 200);
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

async function fetchRows(table: string, columns: string) {
  const { data, error } = await supabase
    .from(table)
    .select(columns);

  if (error) throw error;
  return (data ?? []) as Record<string, unknown>[];
}

async function deleteAllRows(table: string) {
  const rows = await fetchRows(table, "id");
  return await deleteRowsByIds(table, rows);
}

async function deleteRowsByIds(
  table: string,
  rows: Record<string, unknown>[],
) {
  const ids = rows
    .map((row) => stringValue(row.id))
    .filter((value) => value.isNotEmpty);

  if (ids.length === 0) return 0;

  for (const chunk of chunked(ids, 500)) {
    const { error } = await supabase
      .from(table)
      .delete()
      .in("id", chunk);

    if (error) throw error;
  }

  return ids.length;
}

async function removeStorageFiles(bucket: string, paths: string[]) {
  const cleanPaths = paths.filter((value) => value.isNotEmpty);
  if (cleanPaths.length === 0) return 0;

  let removed = 0;
  for (const chunk of chunked(cleanPaths, 100)) {
    const { error } = await supabase.storage.from(bucket).remove(chunk);
    if (error) {
      console.error(error);
      continue;
    }
    removed += chunk.length;
  }

  return removed;
}

function stringValue(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function chunked<T>(items: T[], size: number) {
  const chunks: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
