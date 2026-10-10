// Demande de paiement de l'abonnement Kassa Pro avec Notch Pay :
// 1. vérifier la saisie, 2. noter la demande, 3. créer le paiement chez
// Notch Pay, 4. lancer le débit Mobile Money (le client valide sur son
// téléphone). La confirmation arrive ensuite par notchpay-webhook.

/** Prix de Kassa Pro, en FCFA, pour un mois. */
export const PRIX_FCFA = 5000;

export const NOTCH_API = "https://api.notchpay.co";

export const OPERATEURS = ["cm.mtn", "cm.orange"] as const;
export type Operateur = (typeof OPERATEURS)[number];

/**
 * Une demande en attente bloque les nouvelles pendant ce temps : plus que
 * les 3 minutes d'attente de l'app, pour qu'une validation tardive sur le
 * téléphone ne se cumule pas avec une nouvelle demande (double débit).
 */
export const DELAI_ENTRE_DEMANDES_MS = 5 * 60 * 1000;

export type Saisie = { operateur: Operateur; telephone: string };

/** Lit et vérifie le corps envoyé par l'app ; null s'il est invalide. */
export function lireSaisie(corps: unknown): Saisie | null {
  if (typeof corps !== "object" || corps === null) return null;
  const { operateur, telephone } = corps as Record<string, unknown>;
  if (typeof operateur !== "string" || typeof telephone !== "string") {
    return null;
  }
  if (!(OPERATEURS as readonly string[]).includes(operateur)) return null;
  const chiffres = telephone.replace(/\D/g, "");
  // Numéro camerounais : 237 puis 9 chiffres commençant par 6 ou 2.
  if (!/^237[62]\d{8}$/.test(chiffres)) return null;
  return { operateur: operateur as Operateur, telephone: chiffres };
}

export type Dependances = {
  clePublique: string;
  fetch: typeof fetch;
  /** Nouvelle référence « kassa-<uuid> ». */
  nouvelleReference: () => string;
  /** Vrai si la boutique a déjà une demande en attente récente. */
  demandeRecente: () => Promise<boolean>;
  noterDemande: (reference: string, saisie: Saisie) => Promise<void>;
  noterReferenceNotch: (reference: string, notch: string) => Promise<void>;
  noterEchec: (reference: string) => Promise<void>;
};

export type Resultat =
  | { statut: 200; corps: { reference: string; statut: "en_attente" } }
  | { statut: 400 | 429 | 502; corps: { code: string } };

export async function demanderPaiement(
  saisie: Saisie,
  d: Dependances,
): Promise<Resultat> {
  if (await d.demandeRecente()) {
    return { statut: 429, corps: { code: "demande_en_cours" } };
  }
  const reference = d.nouvelleReference();
  await d.noterDemande(reference, saisie);
  const entetes = {
    Authorization: d.clePublique,
    "Content-Type": "application/json",
    Accept: "application/json",
  };
  try {
    const init = await d.fetch(`${NOTCH_API}/payments`, {
      method: "POST",
      headers: entetes,
      body: JSON.stringify({
        amount: PRIX_FCFA,
        currency: "XAF",
        customer: { phone: `+${saisie.telephone}` },
        reference,
        description: "Kassa Pro : 1 mois",
      }),
    });
    const referenceNotch = init.ok
      ? (await init.json())?.transaction?.reference
      : undefined;
    if (typeof referenceNotch !== "string" || referenceNotch === "") {
      await d.noterEchec(reference);
      return { statut: 502, corps: { code: "notchpay_initialisation" } };
    }
    await d.noterReferenceNotch(reference, referenceNotch);

    const debit = await d.fetch(
      `${NOTCH_API}/payments/${encodeURIComponent(referenceNotch)}`,
      {
        method: "PUT",
        headers: entetes,
        body: JSON.stringify({
          channel: saisie.operateur,
          data: { phone: `+${saisie.telephone}` },
        }),
      },
    );
    if (!debit.ok) {
      await d.noterEchec(reference);
      return { statut: 502, corps: { code: "notchpay_debit" } };
    }
    return { statut: 200, corps: { reference, statut: "en_attente" } };
  } catch (_) {
    await d.noterEchec(reference);
    return { statut: 502, corps: { code: "notchpay_injoignable" } };
  }
}
