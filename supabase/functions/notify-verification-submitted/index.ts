import { createClient } from "jsr:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

type VerificationStatus = "pending" | "approved" | "rejected";

type VerificationRequestRow = {
  id: string;
  device_id: string;
  matter_id: string;
  matter_name: string;
  career_id: string;
  status: VerificationStatus;
};

type AdminDeviceRow = {
  device_id: string;
};

type DevicePushTokenRow = {
  device_id: string;
  push_token: string;
};

type DeviceProfileRow = {
  device_label: string | null;
  reference_name: string | null;
};

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
const FIREBASE_CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "";
const FIREBASE_PRIVATE_KEY = (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "").replace(
  /\\n/g,
  "\n",
);

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const { requestId } = await req.json();
    if (!requestId || typeof requestId !== "string") {
      return json({ error: "requestId is required" }, 400);
    }

    const { data: requestRow, error: requestError } = await supabase
      .from("verification_requests")
      .select("id,device_id,matter_id,matter_name,career_id,status")
      .eq("id", requestId)
      .maybeSingle<VerificationRequestRow>();

    if (requestError) {
      throw requestError;
    }

    if (!requestRow) {
      return json({ ok: false, skipped: "request_not_found" }, 404);
    }

    if (requestRow.status !== "pending") {
      return json({ ok: true, skipped: "request_not_pending" }, 202);
    }

    const { data: adminRows, error: adminError } = await supabase
      .from("admin_devices")
      .select("device_id")
      .eq("enabled", true)
      .returns<AdminDeviceRow[]>();

    if (adminError) {
      throw adminError;
    }

    const adminDeviceIds = (adminRows ?? [])
      .map((row) => row.device_id.trim())
      .filter((value) => value.length > 0);

    if (adminDeviceIds.length === 0) {
      return json({ ok: true, skipped: "no_admin_devices" }, 202);
    }

    const { data: tokenRows, error: tokenError } = await supabase
      .from("device_push_tokens")
      .select("device_id,push_token")
      .in("device_id", adminDeviceIds)
      .eq("enabled", true)
      .returns<DevicePushTokenRow[]>();

    if (tokenError) {
      throw tokenError;
    }

    if (!tokenRows || tokenRows.length === 0) {
      return json({ ok: true, skipped: "no_admin_push_tokens" }, 202);
    }

    if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
      return json({ ok: true, skipped: "firebase_not_configured" }, 202);
    }

    const { data: profileRow } = await supabase
      .from("device_profiles")
      .select("device_label,reference_name")
      .eq("device_id", requestRow.device_id)
      .maybeSingle<DeviceProfileRow>();

    const accessToken = await getFirebaseAccessToken();
    const message = buildMessage(requestRow, profileRow);

    const sent: string[] = [];
    const failed: Array<{ token: string; error: string }> = [];

    for (const tokenRow of tokenRows) {
      const token = tokenRow.push_token;
      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
              message: {
                token,
                notification: {
                  title: message.title,
                  body: message.body,
                },
                data: {
                  screen: "admin_verification",
                  requestId: requestRow.id,
                  matterId: requestRow.matter_id,
                  careerId: requestRow.career_id,
                  sourceDeviceId: requestRow.device_id,
                  status: requestRow.status,
                },
                android: {
                  priority: "high",
                  notification: {
                    channel_id: "verification_updates",
                    sound: "default",
                  },
                },
              },
            }),
          },
        );

        if (!response.ok) {
          const errorText = await response.text();
          if (shouldDisableToken(response.status, errorText)) {
            await disableToken(token);
          }
          failed.push({
            token,
            error: errorText,
          });
          continue;
        }

        sent.push(token);
      } catch (error) {
        failed.push({
          token,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }

    return json({
      ok: true,
      requestId: requestRow.id,
      status: requestRow.status,
      adminDevices: adminDeviceIds.length,
      sent: sent.length,
      failed,
    });
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

async function getFirebaseAccessToken() {
  const jwt = new JWT({
    email: FIREBASE_CLIENT_EMAIL,
    key: FIREBASE_PRIVATE_KEY,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const tokens = await jwt.authorize();
  if (!tokens.access_token) {
    throw new Error("No se pudo obtener el access token de Firebase");
  }
  return tokens.access_token;
}

async function disableToken(pushToken: string) {
  const { error } = await supabase
    .from("device_push_tokens")
    .update({
      enabled: false,
      updated_at: new Date().toISOString(),
    })
    .eq("push_token", pushToken);

  if (error) {
    console.error("No se pudo deshabilitar token inválido", error);
  }
}

function shouldDisableToken(status: number, errorText: string) {
  if (status === 404) return true;

  const normalized = errorText.toUpperCase();
  return normalized.includes("UNREGISTERED") ||
    normalized.includes("REGISTRATION_TOKEN_NOT_REGISTERED") ||
    normalized.includes("INVALID_ARGUMENT") ||
    normalized.includes("INVALID REGISTRATION TOKEN") ||
    normalized.includes("INVALID_REGISTRATION");
}

function buildMessage(
  request: VerificationRequestRow,
  profile: DeviceProfileRow | null,
) {
  const submitter = resolveSubmitterLabel(profile, request.device_id);
  return {
    title: "Nueva solicitud para revisar",
    body:
      `Llegó una verificación de ${request.matter_name} enviada por ${submitter}. ` +
      "Cuando puedas, revisá la evidencia y dejá tu devolución.",
  };
}

function resolveSubmitterLabel(
  profile: DeviceProfileRow | null,
  _fallbackDeviceId: string,
) {
  const referenceName = (profile?.reference_name ?? "").trim();

  if (referenceName.length > 0) {
    return referenceName;
  }
  return "un estudiante";
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
