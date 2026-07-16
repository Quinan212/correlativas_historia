import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const { device_id, photo_id } = await req.json();
    const deviceId = typeof device_id === "string" ? device_id.trim() : "";
    const photoId = typeof photo_id === "string" ? photo_id.trim() : "";

    if (!deviceId) {
      return json({ error: "device_id is required" }, 400);
    }

    if (!photoId) {
      return json({ error: "photo_id is required" }, 400);
    }

    const { data: adminRow, error: adminError } = await supabase
      .from("admin_devices")
      .select("device_id, enabled")
      .eq("device_id", deviceId)
      .eq("enabled", true)
      .maybeSingle();

    if (adminError) {
      throw adminError;
    }

    if (!adminRow) {
      return json({ error: "admin access required" }, 403);
    }

    const { data: photoRow, error: photoError } = await supabase
      .from("matter_photo_posts")
      .select("id, image_path, enabled")
      .eq("id", photoId)
      .maybeSingle();

    if (photoError) {
      throw photoError;
    }

    if (!photoRow) {
      return json({ error: "photo not found" }, 404);
    }

    if (photoRow.enabled === false) {
      return json({ ok: true, skipped: "already_disabled" }, 200);
    }

    const now = new Date().toISOString();
    const { error: updateError } = await supabase
      .from("matter_photo_posts")
      .update({
        enabled: false,
        updated_at: now,
      })
      .eq("id", photoId);

    if (updateError) {
      throw updateError;
    }

    const imagePath = typeof photoRow.image_path === "string"
      ? photoRow.image_path.trim()
      : "";

    if (imagePath) {
      const { error: removeError } = await supabase
        .storage
        .from("matter-community-photos")
        .remove([imagePath]);

      if (removeError) {
        console.error(removeError);
      }
    }

    return json({ ok: true, photo_id: photoId }, 200);
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

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
