import { assertEquals } from "jsr:@std/assert@1";
import {
  type Dependances,
  demanderPaiement,
  lireSaisie,
  PRIX_FCFA,
  type Saisie,
} from "./logique.ts";

Deno.test("saisie : opérateur et numéro camerounais", () => {
  assertEquals(lireSaisie({ operateur: "cm.mtn", telephone: "+237 677 12 34 56" }), {
    operateur: "cm.mtn",
    telephone: "237677123456",
  });
  assertEquals(lireSaisie({ operateur: "cm.orange", telephone: "237699000000" })?.operateur, "cm.orange");
  assertEquals(lireSaisie({ operateur: "cm.yoomee", telephone: "237677123456" }), null);
  assertEquals(lireSaisie({ operateur: "cm.mtn", telephone: "677123456" }), null);
  assertEquals(lireSaisie({ operateur: "cm.mtn", telephone: "237777123456" }), null);
  assertEquals(lireSaisie(null), null);
  assertEquals(lireSaisie({ operateur: "cm.mtn" }), null);
});

type Appel = { url: string; init?: RequestInit };

function faux(reponses: Response[], recente = false) {
  const appels: Appel[] = [];
  const journal: string[] = [];
  const d: Dependances = {
    clePublique: "pk_test_x",
    fetch: ((url: string, init?: RequestInit) => {
      appels.push({ url, init });
      const r = reponses.shift();
      if (!r) return Promise.reject(new Error("réseau"));
      return Promise.resolve(r);
    }) as typeof fetch,
    nouvelleReference: () => "kassa-00000000-0000-4000-8000-000000000001",
    demandeRecente: () => Promise.resolve(recente),
    noterDemande: (ref, s) => {
      journal.push(`demande ${ref} ${s.operateur}`);
      return Promise.resolve();
    },
    noterReferenceNotch: (ref, notch) => {
      journal.push(`notch ${ref} ${notch}`);
      return Promise.resolve();
    },
    noterEchec: (ref) => {
      journal.push(`echec ${ref}`);
      return Promise.resolve();
    },
  };
  return { d, appels, journal };
}

const saisie: Saisie = { operateur: "cm.mtn", telephone: "237677123456" };

Deno.test("paiement : création puis débit Mobile Money", async () => {
  const { d, appels, journal } = faux([
    Response.json({ transaction: { reference: "trx.abc" } }, { status: 201 }),
    Response.json({ transaction: { status: "processing" } }, { status: 202 }),
  ]);
  const r = await demanderPaiement(saisie, d);
  assertEquals(r.statut, 200);
  assertEquals(appels[0].url, "https://api.notchpay.co/payments");
  const corps = JSON.parse(appels[0].init!.body as string);
  assertEquals(corps.amount, PRIX_FCFA);
  assertEquals(corps.currency, "XAF");
  assertEquals(corps.reference, "kassa-00000000-0000-4000-8000-000000000001");
  assertEquals((appels[0].init!.headers as Record<string, string>).Authorization, "pk_test_x");
  assertEquals(appels[1].url, "https://api.notchpay.co/payments/trx.abc");
  assertEquals(appels[1].init!.method, "PUT");
  assertEquals(JSON.parse(appels[1].init!.body as string), {
    channel: "cm.mtn",
    data: { phone: "+237677123456" },
  });
  assertEquals(journal, [
    "demande kassa-00000000-0000-4000-8000-000000000001 cm.mtn",
    "notch kassa-00000000-0000-4000-8000-000000000001 trx.abc",
  ]);
});

Deno.test("paiement : refus de Notch Pay, demande notée en échec", async () => {
  const { d, journal } = faux([
    Response.json({ transaction: { reference: "trx.abc" } }, { status: 201 }),
    Response.json({ message: "Invalid phone" }, { status: 422 }),
  ]);
  const r = await demanderPaiement(saisie, d);
  assertEquals(r, { statut: 502, corps: { code: "notchpay_debit" } });
  assertEquals(journal.at(-1), "echec kassa-00000000-0000-4000-8000-000000000001");
});

Deno.test("paiement : Notch Pay injoignable", async () => {
  const { d, journal } = faux([]);
  const r = await demanderPaiement(saisie, d);
  assertEquals(r.statut, 502);
  assertEquals(journal.at(-1), "echec kassa-00000000-0000-4000-8000-000000000001");
});

Deno.test("paiement : une demande déjà en cours bloque la suivante", async () => {
  const { d, appels } = faux([], true);
  const r = await demanderPaiement(saisie, d);
  assertEquals(r, { statut: 429, corps: { code: "demande_en_cours" } });
  assertEquals(appels.length, 0);
});
