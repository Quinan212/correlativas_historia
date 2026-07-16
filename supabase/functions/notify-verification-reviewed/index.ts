import { createClient } from "jsr:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

type VerificationStatus = "pending" | "approved" | "rejected";

type VerificationRequestRow = {
  id: string;
  device_id: string;
  matter_id: string;
  matter_name: string;
  status: VerificationStatus;
  review_note: string | null;
};

type DevicePushTokenRow = {
  push_token: string;
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
      .select("id,device_id,matter_id,matter_name,status,review_note")
      .eq("id", requestId)
      .maybeSingle<VerificationRequestRow>();

    if (requestError) {
      throw requestError;
    }

    if (!requestRow) {
      return json({ ok: false, skipped: "request_not_found" }, 404);
    }

    if (requestRow.status === "pending") {
      return json({ ok: true, skipped: "request_still_pending" }, 202);
    }

    const { data: tokenRows, error: tokenError } = await supabase
      .from("device_push_tokens")
      .select("push_token")
      .eq("device_id", requestRow.device_id)
      .eq("enabled", true)
      .returns<DevicePushTokenRow[]>();

    if (tokenError) {
      throw tokenError;
    }

    if (!tokenRows || tokenRows.length == 0) {
      return json({ ok: true, skipped: "no_push_tokens" }, 202);
    }

    if (!FIREBASE_PROJECT_ID || !FIREBASE_CLIENT_EMAIL || !FIREBASE_PRIVATE_KEY) {
      return json({ ok: true, skipped: "firebase_not_configured" }, 202);
    }

    const accessToken = await getFirebaseAccessToken();
    const message = buildMessage(requestRow);

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
                  screen: "verification",
                  requestId: requestRow.id,
                  matterId: requestRow.matter_id,
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

function buildMessage(request: VerificationRequestRow) {
  if (request.status === "approved") {
    return {
      title: "Verificación lista",
      body:
        `La verificación de ${request.matter_name} ya quedó aprobada. ` +
        "Desde ahora podés compartir referencias sobre esta materia y sus docentes.",
    };
  }

  const note = (request.review_note ?? "").trim();
  return {
    title: "Revisión lista",
    body: note.length === 0
      ? `La revisión de ${request.matter_name} ya quedó lista. Revisá la solicitud y, si hace falta, volvé a enviarla.`
      : `La revisión de ${request.matter_name} ya quedó lista. Revisá la observación cargada y, si hace falta, volvé a enviarla.`,
  };
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json",
    },
  });
}
