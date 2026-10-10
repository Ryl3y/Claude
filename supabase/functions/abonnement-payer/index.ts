// Edge Function : l'app demande un paiement Kassa Pro (utilisateur connecté).
// Clé Notch Pay : secret NOTCH_PUBLIC_KEY (jamais dans le code ni le dépôt).
import { withSupabase } from "npm:@supabase/server@1";
import {
  DELAI_ENTRE_DEMANDES_MS,
  demanderPaiement,
  lireSaisie,
  PRIX_FCFA,
} from "./logique.ts";

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    if (req.method !== "POST") {
      return Response.json({ code: "methode" }, { status: 405 });
    }
    const clePublique = Deno.env.get("NOTCH_PUBLIC_KEY");
    if (!clePublique) {
      return Response.json({ code: "configuration" }, { status: 503 });
    }
    let corps: unknown;
    try {
      corps = await req.json();
    } catch {
      return Response.json({ code: "saisie" }, { status: 400 });
    }
    const saisie = lireSaisie(corps);
    if (!saisie) return Response.json({ code: "saisie" }, { status: 400 });

    const utilisateurId = ctx.userClaims?.id;
    if (!utilisateurId) {
      return Response.json({ code: "connexion" }, { status: 401 });
    }
    // Boutique du commerçant, lue avec ses propres droits (RLS).
    const { data: compte, error } = await ctx.supabase
      .from("utilisateurs")
      .select("boutique_id")
      .eq("id", utilisateurId)
      .is("supprime_le", null)
      .maybeSingle();
    if (error || !compte) {
      return Response.json({ code: "boutique" }, { status: 403 });
    }
    const boutiqueId = compte.boutique_id as string;
    const admin = ctx.supabaseAdmin;

    const resultat = await demanderPaiement(saisie, {
      clePublique,
      fetch,
      nouvelleReference: () => `kassa-${crypto.randomUUID()}`,
      demandeRecente: async () => {
        const depuis = new Date(Date.now() - DELAI_ENTRE_DEMANDES_MS)
          .toISOString();
        const { count } = await admin
          .from("paiements_abonnement")
          .select("reference", { count: "exact", head: true })
          .eq("boutique_id", boutiqueId)
          .eq("statut", "en_attente")
          .gte("cree_le", depuis);
        return (count ?? 0) > 0;
      },
      noterDemande: async (reference, s) => {
        const { error } = await admin.from("paiements_abonnement").insert({
          reference,
          boutique_id: boutiqueId,
          utilisateur_id: utilisateurId,
          montant: PRIX_FCFA,
          operateur: s.operateur,
        });
        if (error) throw error;
      },
      noterReferenceNotch: async (reference, notch) => {
        await admin
          .from("paiements_abonnement")
          .update({ reference_notch: notch, maj_le: new Date().toISOString() })
          .eq("reference", reference);
      },
      noterEchec: async (reference) => {
        await admin.rpc("echouer_paiement_abonnement", {
          p_reference: reference,
        });
      },
    });
    return Response.json(resultat.corps, { status: resultat.statut });
  }),
};
