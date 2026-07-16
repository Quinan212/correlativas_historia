import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const { device_id, push_token, platform } = await req.json();
    const deviceId = typeof device_id === "string" ? device_id.trim() : "";
    const pushToken = typeof push_token === "string" ? push_token.trim() : "";
    const targetPlatform = typeof platform === "string" && platform.trim().length > 0
      ? platform.trim()
      : "android";

    if (!deviceId) {
      return json({ error: "device_id is required" }, 400);
    }

    if (!pushToken) {
      return json({ error: "push_token is required" }, 400);
    }

    const now = new Date().toISOString();
    const { error } = await supabase
      .from("device_push_tokens")
      .upsert({
        device_id: deviceId,
        push_token: pushToken,
        platform: targetPlatform,
        enabled: true,
        updated_at: now,
        last_seen_at: now,
        created_at: now,
      }, { onConflict: "push_token" });

    if (error) {
      throw error;
    }

    return json({ ok: true }, 200);
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
