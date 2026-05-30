// @ts-nocheck

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const chapaSecretKey = Deno.env.get('CHAPA_SECRET_KEY')!;

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    const payload = await req.json();

    // SAFE tx_ref extraction
    const txRef =
      payload?.tx_ref ??
      payload?.trx_ref ??
      payload?.reference ??
      payload?.data?.tx_ref ??
      '';

    if (!txRef) {
      return new Response(JSON.stringify({ error: 'Missing tx_ref' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // VERIFY PAYMENT WITH CHAPA
    const verifyResponse = await fetch(
      `https://api.chapa.co/v1/transaction/verify/${encodeURIComponent(txRef)}`,
      {
        headers: {
          Authorization: `Bearer ${chapaSecretKey}`,
        },
      }
    );

    const verifyPayload = await verifyResponse.json();

    const status =
      verifyPayload?.data?.status?.toString()?.toLowerCase() ??
      verifyPayload?.status?.toString()?.toLowerCase() ??
      '';

    //  NOT SUCCESSFUL PAYMENT
    if (!verifyResponse.ok || !['success', 'completed', 'paid'].includes(status)) {
      return new Response(
        JSON.stringify({
          error: 'Payment not completed',
          status,
          details: verifyPayload,
        }),
        {
          status: 202,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // GET METADATA (NEW IMPORTANT PART)
    const metadata = verifyPayload?.data?.meta || {};
    const source = metadata?.source || 'mobile';
    const dbType = metadata?.db || 'supabase';

    // ROUTE BASED ON SOURCE
    if (dbType === 'supabase') {
      // 📱 MOBILE (Supabase DB)
      const { error: updateError } = await supabase
        .from('donations')
        .update({
          payment_status: 'completed',
          paid_at: new Date().toISOString(),
        })
        .eq('payment_reference', txRef);

      if (updateError) {
        return new Response(JSON.stringify({ error: updateError.message }), {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
    }

    // 🌐 WEBSITE (External PostgreSQL API)
    if (dbType === 'postgres') {
      await fetch('https://YOUR-WEBSITE-API.com/payment-webhook', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          tx_ref: txRef,
          status: 'completed',
          amount: verifyPayload?.data?.amount,
          metadata,
        }),
      });
    }

    return new Response(JSON.stringify({ ok: true, routed_to: dbType }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unexpected error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});