// Confirmation des paiements Notch Pay. On ne croit jamais le contenu de
// l'événement : la signature est vérifiée, puis le paiement est relu chez
// Notch Pay (statut, montant, devise) avant de prolonger l'abonnement.

export const NOTCH_API = "https://api.notchpay.co";

const encodeur = new TextEncoder();

/** HMAC-SHA256 en hexadécimal, comme Notch Pay (x-notch-signature). */
export async function signer(corps: string, cle: string): Promise<string> {
  const k = await crypto.subtle.importKey(
    "raw",
    encodeur.encode(cle),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", k, encodeur.encode(corps));
  return [...new Uint8Array(sig)]
    .map((o) => o.toString(16).padStart(2, "0"))
    .join("");
}

/** Comparaison à temps constant. */
export function egaux(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

export async function signatureValide(
  corps: string,
  signature: string,
  cle: string,
): Promise<boolean> {
  if (!signature) return false;
  return egaux(await signer(corps, cle), signature.trim().toLowerCase());
}

export type Transaction = {
  reference: string;
  trxref: string;
  status: string;
  amount: number;
  currency: string;
};

export type Dependances = {
  /** Relit le paiement chez Notch Pay ; null s'il est introuvable. */
  lirePaiement: (referenceNotch: string) => Promise<Transaction | null>;
  confirmer: (reference: string, notch: string, montant: number) => Promise<void>;
  echouer: (reference: string) => Promise<void>;
};

export type Issue =
  | "signature_invalide"
  | "illisible"
  | "ignore"
  | "confirme"
  | "echoue"
  | "en_cours";

const ECHECS = new Set(["failed", "canceled", "cancelled", "expired"]);

/**
 * Traite un événement déjà authentifié. Lève une exception si Notch Pay
 * ou la base sont injoignables (Notch Pay renverra l'événement).
 */
export async function traiterEvenement(
  evenement: unknown,
  d: Dependances,
): Promise<Issue> {
  if (typeof evenement !== "object" || evenement === null) return "illisible";
  const donnees = (evenement as { data?: Record<string, unknown> }).data ?? {};
  const referenceNotch = typeof donnees.reference === "string"
    ? donnees.reference
    : typeof donnees.id === "string"
    ? donnees.id
    : null;
  if (!referenceNotch) return "illisible";

  const trx = await d.lirePaiement(referenceNotch);
  // Seulement nos paiements d'abonnement (référence « kassa-… »).
  if (!trx || !trx.trxref?.startsWith("kassa-")) return "ignore";

  if (trx.status === "complete") {
    if (trx.currency !== "XAF") return "ignore";
    await d.confirmer(trx.trxref, trx.reference, trx.amount);
    return "confirme";
  }
  if (ECHECS.has(trx.status)) {
    await d.echouer(trx.trxref);
    return "echoue";
  }
  return "en_cours";
}
