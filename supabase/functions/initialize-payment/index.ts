import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: req.headers.get("Authorization")! } },
    });

    const { amount, fund, paymentMethod, isRecurring, gateway, email, feeCovered } = await req.json();

    const authRes = await supabase.auth.getUser();
    if (authRes.error) throw new Error("Unauthorized");
    const user = authRes.data.user;

    // Calculate fee (e.g. 1.5% for Paystack)
    const feeAmount = feeCovered ? amount * 0.015 : 0;
    const totalAmount = amount + feeAmount;
    
    // Convert to minor units for Paystack
    const amountInKobo = Math.round(totalAmount * 100);

    const gatewayRef = `KH-${crypto.randomUUID()}`;

    // Insert pending donation
    const { data: donation, error: insertError } = await supabase
      .from("donations")
      .insert({
        donor_id: user.id,
        amount: totalAmount,
        net_amount: amount,
        fee_amount: feeAmount,
        fee_covered: feeCovered,
        currency: "GHS",
        fund: fund.toLowerCase().replace(" ", "_"),
        payment_method: paymentMethod,
        status: "pending",
        gateway: gateway,
        gateway_ref: gatewayRef,
        is_recurring: isRecurring,
      })
      .select("id")
      .single();

    if (insertError) throw insertError;

    let checkoutUrl = "";

    if (gateway === "paystack") {
      const paystackRes = await fetch("https://api.paystack.co/transaction/initialize", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${Deno.env.get("PAYSTACK_SECRET_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          amount: amountInKobo,
          reference: gatewayRef,
          currency: "GHS",
          channels: paymentMethod === 'card' ? ['card'] : ['mobile_money'],
          metadata: {
            donation_id: donation.id,
            is_recurring: isRecurring,
            fund: fund,
            custom_fields: [
              { display_name: "Fund", variable_name: "fund", value: fund }
            ]
          },
        }),
      });
      const paystackData = await paystackRes.json();
      if (!paystackData.status) throw new Error(paystackData.message);
      checkoutUrl = paystackData.data.authorization_url;
    } else if (gateway === "flutterwave") {
      const flwRes = await fetch("https://api.flutterwave.com/v3/payments", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${Deno.env.get("FLUTTERWAVE_SECRET_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          tx_ref: gatewayRef,
          amount: totalAmount,
          currency: "GHS",
          payment_options: paymentMethod === 'card' ? "card" : "mobilemoneygh",
          customer: { email: email },
          meta: { donation_id: donation.id, is_recurring: isRecurring },
        }),
      });
      const flwData = await flwRes.json();
      if (flwData.status !== "success") throw new Error(flwData.message);
      checkoutUrl = flwData.data.link;
    }

    // Update donation with checkout url
    await supabase.from("donations").update({ authorization_url: checkoutUrl }).eq("id", donation.id);

    return new Response(JSON.stringify({ checkoutUrl, donationId: donation.id, gatewayRef }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
