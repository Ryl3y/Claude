import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import {
  type Dependances,
  egaux,
  signatureValide,
  signer,
  traiterEvenement,
  type Transaction,
} from "./logique.ts";

Deno.test("signature : HMAC-SHA256 hexadécimal (vecteur RFC 4231, cas 2)", async () => {
  assertEquals(
    await signer("what do ya want for nothing?", "Jefe"),
    "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
  );
});

Deno.test("signature : bonne acceptée, fausse ou absente refusée", async () => {
  const corps = '{"type":"payment.complete","data":{"reference":"trx.1"}}';
  const bonne = await signer(corps, "hsk_test_x");
  assertEquals(await signatureValide(corps, bonne, "hsk_test_x"), true);
  assertEquals(await signatureValide(corps, bonne.toUpperCase(), "hsk_test_x"), true);
  assertEquals(await signatureValide(corps + " ", bonne, "hsk_test_x"), false);
  assertEquals(await signatureValide(corps, bonne, "autre"), false);
  assertEquals(await signatureValide(corps, "", "hsk_test_x"), false);
  assertEquals(egaux("abc", "abd"), false);
  assertEquals(egaux("abc", "abc"), true);
});

function faux(trx: Transaction | null) {
  const journal: string[] = [];
  const d: Dependances = {
    lirePaiement: (ref) => {
      journal.push(`lire ${ref}`);
      return Promise.resolve(trx);
    },
    confirmer: (ref, notch, montant) => {
      journal.push(`confirmer ${ref} ${notch} ${montant}`);
      return Promise.resolve();
    },
    echouer: (ref) => {
      journal.push(`echouer ${ref}`);
      return Promise.resolve();
    },
  };
  return { d, journal };
}

const payee: Transaction = {
  reference: "trx.1",
  trxref: "kassa-00000000-0000-4000-8000-000000000001",
  status: "complete",
  amount: 5000,
  currency: "XAF",
};

Deno.test("paiement réussi : relu chez Notch Pay puis confirmé", async () => {
  const { d, journal } = faux(payee);
  // Même si l'événement dit autre chose, c'est la relecture qui compte.
  const issue = await traiterEvenement(
    { type: "payment.failed", data: { reference: "trx.1", amount: 1 } },
    d,
  );
  assertEquals(issue, "confirme");
  assertEquals(journal, [
    "lire trx.1",
    "confirmer kassa-00000000-0000-4000-8000-000000000001 trx.1 5000",
  ]);
});

Deno.test("paiement refusé ou expiré : noté en échec", async () => {
  for (const status of ["failed", "canceled", "expired"]) {
    const { d, journal } = faux({ ...payee, status });
    assertEquals(await traiterEvenement({ data: { reference: "trx.1" } }, d), "echoue");
    assertEquals(journal.at(-1), "echouer kassa-00000000-0000-4000-8000-000000000001");
  }
});

Deno.test("en cours, autre paiement, autre devise, inconnu : rien", async () => {
  assertEquals(await traiterEvenement({ data: { reference: "x" } }, faux({ ...payee, status: "processing" }).d), "en_cours");
  assertEquals(await traiterEvenement({ data: { reference: "x" } }, faux({ ...payee, trxref: "commande-1" }).d), "ignore");
  assertEquals(await traiterEvenement({ data: { reference: "x" } }, faux({ ...payee, currency: "EUR" }).d), "ignore");
  assertEquals(await traiterEvenement({ data: { reference: "x" } }, faux(null).d), "ignore");
  assertEquals(await traiterEvenement({ data: {} }, faux(payee).d), "illisible");
  assertEquals(await traiterEvenement("texte", faux(payee).d), "illisible");
});

Deno.test("base injoignable : l'erreur remonte (Notch Pay réessaiera)", async () => {
  const { d } = faux(payee);
  d.confirmer = () => Promise.reject(new Error("base"));
  await assertRejects(() => traiterEvenement({ data: { reference: "trx.1" } }, d));
});
