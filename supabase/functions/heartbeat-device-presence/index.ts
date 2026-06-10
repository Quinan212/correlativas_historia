import { createClient } from 'jsr:@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
      'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
  auth: { persistSession: false },
});

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      {
        status: 405,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  }

  try {
    const body = await req.json().catch(() => ({}));
    const deviceId = String(body?.device_id ?? '').trim();

    if (!deviceId) {
      return new Response(
        JSON.stringify({ error: 'device_id is required' }),
        {
          status: 400,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
        },
      );
    }

    const inferredKind = inferDeviceKind(deviceId);
    const defaultLabel = inferredKind === 'emulator'
      ? 'Emulador registrado'
      : inferredKind === 'tester'
      ? 'Tester registrado'
      : 'Dispositivo real registrado';

    const { data: existingRow, error: existingError } = await supabase
      .from('device_registry')
      .select('device_kind, label, notes')
      .eq('device_id', deviceId)
      .maybeSingle();

    if (existingError) throw existingError;

    const deviceKind = existingRow?.device_kind ?? inferredKind;
    const existingLabel = String(existingRow?.label ?? '').trim();
    const resolvedLabel = existingLabel.length === 0 ? defaultLabel : existingLabel;

    const { error } = await supabase
      .from('device_registry')
      .upsert({
        device_id: deviceId,
        device_kind: deviceKind,
        lifecycle_status: 'active',
        label: resolvedLabel,
        notes: existingRow?.notes ?? null,
        last_active_at: new Date().toISOString(),
      }, {
        onConflict: 'device_id',
      });

    if (error) throw error;

    return new Response(
      JSON.stringify({ ok: true }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : String(error),
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  }
});

function inferDeviceKind(deviceId: string) {
  if (deviceId.startsWith('emu_')) return 'emulator';
  if (deviceId.startsWith('test_') || deviceId.startsWith('tester_')) {
    return 'tester';
  }
  return 'real';
}
