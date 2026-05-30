// @ts-nocheck
/**
 * Edge Function: chapa-initiate-payment
 * Purpose: Create a pending donation record in Supabase and initialize
 * a Chapa checkout session. Returns { donation_id, payment_reference, checkout_url }.
 *
 * Security:
 * - Requires `SUPABASE_SERVICE_ROLE_KEY` and `CHAPA_SECRET_KEY` in environment.
 * - This function must run server-side only (Edge Functions) to keep secrets safe.
 * - Do NOT expose service role keys to the client.
 *
 * Flow notes:
 * - Inserts donation with `payment_status: 'pending'` then calls Chapa initialize.
 * - The Chapa webhook (`chapa-webhook`) is responsible for marking donations 'completed'.
 */

// @ts-ignore
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
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
    const authorization = req.headers.get('Authorization');
    if (!authorization) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const body = await req.json();
    const campaignId = Number(body.campaignId);
    const amount = Number(body.amount);
    const isAnonymous = Boolean(body.isAnonymous);

    if (!Number.isFinite(campaignId) || !Number.isFinite(amount) || amount <= 0) {
      return new Response(JSON.stringify({ error: 'Invalid campaignId or amount' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const chapaSecretKey = Deno.env.get('CHAPA_SECRET_KEY');
    const chapaReturnUrl = Deno.env.get('CHAPA_RETURN_URL') ?? 'https://example.com/payment/success';

    if (!supabaseUrl || !supabaseServiceRoleKey || !chapaSecretKey) {
      return new Response(JSON.stringify({ error: 'Missing function environment variables' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey, {
      global: {
        headers: {
          Authorization: authorization,
        },
      },
    });

    const token = authorization.replace('Bearer ', '');
    const { data: userResult, error: userError } = await supabase.auth.getUser(token);
    if (userError || !userResult.user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('user_id, full_name, email, auth_user_id')
      .eq('auth_user_id', userResult.user.id)
      .single();

    if (profileError || !profile) {
      return new Response(JSON.stringify({ error: 'Profile not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: campaign, error: campaignError } = await supabase
      .from('campaigns')
      .select('campaign_id, title')
      .eq('campaign_id', campaignId)
      .single();

    if (campaignError || !campaign) {
      return new Response(JSON.stringify({ error: 'Campaign not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const paymentReference = `EF-${campaignId}-${crypto.randomUUID()}`;
    const donorNameParts = String(profile.full_name ?? '').trim().split(/\s+/).filter(Boolean);
    const firstName = donorNameParts[0] ?? 'EthioFund';
    const lastName = donorNameParts.length > 1 ? donorNameParts.slice(1).join(' ') : 'Supporter';

    const { data: donation, error: donationError } = await supabase
      .from('donations')
      .insert({
        campaign_id: campaign.campaign_id,
        donor_id: profile.user_id,
        amount,
        payment_status: 'pending',
        payment_provider: 'chapa',
        payment_reference: paymentReference,
        checkout_url: null,
        is_anonymous: isAnonymous,
        campaign_title: campaign.title,
      })
      .select('donation_id')
      .single();

    if (donationError || !donation) {
      return new Response(JSON.stringify({ error: donationError?.message ?? 'Failed to create donation record' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const chapaResponse = await fetch('https://api.chapa.co/v1/transaction/initialize', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${chapaSecretKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amount.toFixed(2),
        currency: 'ETB',
        email: profile.email,
        first_name: firstName,
        last_name: lastName,
        tx_ref: paymentReference,
        callback_url: `${supabaseUrl}/functions/v1/chapa-webhook`,
        return_url: chapaReturnUrl,
        customization: {
          title: 'EthioFund Donation',
          description: String(campaign.title),
        },
      }),
    });

    const chapaPayload = await chapaResponse.json();
    const checkoutUrl = chapaPayload?.data?.checkout_url?.toString?.() ?? chapaPayload?.data?.checkout_url ?? '';

    if (!chapaResponse.ok || !checkoutUrl) {
      await supabase
        .from('donations')
        .update({ payment_status: 'failed' })
        .eq('donation_id', donation.donation_id);

      return new Response(JSON.stringify({ error: chapaPayload?.message ?? 'Failed to initialize Chapa checkout' }), {
        status: 502,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    await supabase
      .from('donations')
      .update({ checkout_url: checkoutUrl })
      .eq('donation_id', donation.donation_id);

    return new Response(
      JSON.stringify({
        donation_id: donation.donation_id,
        payment_reference: paymentReference,
        checkout_url: checkoutUrl,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error instanceof Error ? error.message : 'Unexpected error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});