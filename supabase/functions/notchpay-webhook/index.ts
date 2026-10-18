// Edge Function : Notch Pay annonce le résultat d'un paiement.
// Pas de compte Supabase : l'appel est authentifié par sa signature
// (secret NOTCH_WEBHOOK_HASH), puis le paiement est relu chez Notch Pay
// (secret NOTCH_PUBLIC_KEY). Aucune clé dans le code ni dans le dépôt.
import { withSupabase } from "npm:@supabase/server@1";
import {
  NOTCH_API,
  signatureValide,
  traiterEvenement,
  type Transaction,
} from "./logique.ts";

export default {
  fetch: withSupabase({ auth: "none" }, async (req, ctx) => {
    if (req.method !== "POST") return new Response(null, { status: 405 });
    const hash = Deno.env.get("NOTCH_WEBHOOK_HASH");
    const clePublique = Deno.env.get("NOTCH_PUBLIC_KEY");
    if (!hash || !clePublique) return new Response(null, { status: 503 });

    const corps = await req.text();
    const signature = req.headers.get("x-notch-signature") ?? "";
    if (!(await signatureValide(corps, signature, hash))) {
      console.warn("notchpay-webhook : signature invalide");
      return new Response(null, { status: 403 });
    }
    let evenement: unknown;
    try {
      evenement = JSON.parse(corps);
    } catch {
      return new Response(null, { status: 400 });
    }

    const admin = ctx.supabaseAdmin;
    try {
      const issue = await traiterEvenement(evenement, {
        lirePaiement: async (referenceNotch) => {
          const r = await fetch(
            `${NOTCH_API}/payments/${encodeURIComponent(referenceNotch)}`,
            { headers: { Authorization: clePublique, Accept: "application/json" } },
          );
          if (r.status === 404) return null;
          if (!r.ok) throw new Error(`Notch Pay : ${r.status}`);
          const t = (await r.json())?.transaction;
          return t ? (t as Transaction) : null;
        },
        confirmer: async (reference, notch, montant) => {
          const { error } = await admin.rpc("confirmer_paiement_abonnement", {
            p_reference: reference,
            p_reference_notch: notch,
            p_montant: montant,
          });
          // Référence « kassa-… » absente de la base (autre environnement) :
          // définitif, inutile que Notch Pay réessaie.
          if (error?.message?.startsWith("paiement inconnu")) return false;
          if (error) throw error;
          return true;
        },
        echouer: async (reference) => {
          const { error } = await admin.rpc("echouer_paiement_abonnement", {
            p_reference: reference,
          });
          if (error) throw error;
        },
      });
      console.log(`notchpay-webhook : ${issue}`);
      return Response.json({ recu: true, issue });
    } catch (e) {
      // 500 : Notch Pay renverra l'événement plus tard.
      console.error("notchpay-webhook :", e);
      return new Response(null, { status: 500 });
    }
  }),
};
