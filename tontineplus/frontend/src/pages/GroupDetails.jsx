import { useCallback, useEffect, useRef, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../auth";
import Badge from "../components/Badge";
import Erreur from "../components/Erreur";
import { dateCourte, fcfa, libelle, POSTES_BUREAU } from "../format";

// « Bello » ou « Bello (2e nom) » quand le membre tient plusieurs noms.
function nomAffiche(nom, nbNoms) {
  if (!nom) return "—";
  if (nbNoms <= 1) return nom.nom_complet;
  return `${nom.nom_complet} (${nom.rang === 1 ? "1er" : `${nom.rang}e`} nom)`;
}

export default function GroupDetails() {
  const { id } = useParams();
  const { utilisateur } = useAuth();
  const navigate = useNavigate();
  const [tontine, setTontine] = useState(null);
  const [tours, setTours] = useState([]);
  const [designations, setDesignations] = useState([]);
  const [erreur, setErreur] = useState("");

  const charger = useCallback(async () => {
    try {
      const detail = await api(`/tontines/${id}/`);
      setTontine(detail);
      const demarree = ["active", "terminee"].includes(detail.statut);
      setTours(demarree ? await api(`/tontines/${id}/tours/`) : []);
      setDesignations(demarree ? await api(`/tontines/${id}/designations/`) : []);
    } catch (err) {
      setErreur(err.status === 404 ? "Tontine introuvable, ou vous n'en êtes pas membre." : err.message);
    }
  }, [id]);

  useEffect(() => {
    setTontine(null);
    charger();
  }, [charger]);

  if (!tontine) {
    return erreur ? <Erreur message={erreur} /> : <p className="text-gray-500">Chargement…</p>;
  }

  const moi = tontine.membres.find((m) => m.telephone === utilisateur.telephone);
  const estPresident = moi?.role === "president";
  const auBureau = Boolean(moi) && moi.role !== "membre";
  const encaisse = ["president", "tresorier"].includes(moi?.role);
  const brouillon = tontine.statut === "brouillon";
  const nbNoms = tontine.noms.length;
  const nbNomsDe = (membreId) => tontine.membres.find((m) => m.id === membreId)?.positions.length ?? 1;
  const libelleNom = (nomId) => {
    const nom = tontine.noms.find((n) => n.id === nomId);
    return nom ? nomAffiche(nom, nbNomsDe(nom.membre_id)) : null;
  };
  // Noms qui n'ont pas encore de tour : candidats au tirage et aux désignations.
  const attribues = new Set(tours.map((t) => t.beneficiaire_nom_id).filter(Boolean));
  const nomsLibres = tontine.noms.filter((n) => !attribues.has(n.id));
  const prochainTirage = tours.find((t) => !t.beneficiaire_nom_id);

  // Exécute une action, affiche son erreur éventuelle, puis recharge la page.
  const agir = async (action) => {
    setErreur("");
    try {
      await action();
      await charger();
    } catch (err) {
      setErreur(err.message);
    }
  };

  const annuler = () =>
    window.confirm("Annuler définitivement cette tontine ?") &&
    agir(() => api(`/tontines/${tontine.id}/annuler/`, { methode: "POST" }));

  const nouveauCycle = async () => {
    setErreur("");
    try {
      const nouvelle = await api(`/tontines/${tontine.id}/nouveau-cycle/`, { methode: "POST" });
      navigate(`/group/${nouvelle.id}`);
    } catch (err) {
      setErreur(err.message);
    }
  };

  return (
    <div className="space-y-6">
      <section className="carte">
        <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
          <h1 className="text-2xl font-bold">{tontine.nom}</h1>
          <Badge valeur={tontine.statut} />
        </div>
        {tontine.description && <p className="mb-3 text-gray-700">{tontine.description}</p>}
        <dl className="grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
          <Info titre="Cotisation par nom">{fcfa(tontine.montant_cotisation)}</Info>
          <Info titre="Fréquence">{libelle(tontine.frequence)}</Info>
          <Info titre="Caisse par tour">{fcfa(tontine.montant_cotisation * nbNoms)}</Info>
          <Info titre="Pénalité de retard par nom">{fcfa(tontine.penalite_retard)}</Info>
        </dl>
        <p className="mt-3 text-sm text-gray-600">
          Le bénéficiaire de chaque tour est tiré au sort le jour de la séance. Une désignation reste possible
          si la majorité du bureau l'approuve.
        </p>
        {estPresident && brouillon && (
          <div className="mt-4 flex flex-wrap gap-2 border-t pt-4">
            <Link to={`/group/${tontine.id}/modifier`} className="bouton-secondaire">Modifier les paramètres</Link>
            <button className="bouton-secondaire text-red-700" onClick={annuler}>Annuler la tontine</button>
          </div>
        )}
        {tontine.statut === "annulee" && (
          <p className="mt-4 rounded bg-gray-100 p-3 text-sm text-gray-700">Cette tontine a été annulée.</p>
        )}
        {tontine.statut === "terminee" && (
          <div className="mt-4 rounded bg-green-50 p-3 text-sm text-green-900">
            <p>Cycle terminé : chaque nom a ramassé la caisse.</p>
            {estPresident && (
              <button className="bouton mt-2" onClick={nouveauCycle}>Lancer un nouveau cycle</button>
            )}
          </div>
        )}
      </section>

      <Erreur message={erreur} />

      <Membres
        tontine={tontine}
        nbNoms={nbNoms}
        gerer={estPresident && brouillon}
        peutNommer={estPresident && ["brouillon", "active"].includes(tontine.statut)}
        agir={agir}
      />

      {estPresident && brouillon && (
        <section className="carte space-y-6">
          <Invitation tontineId={tontine.id} complete={nbNoms >= tontine.nb_places} />
          <div className="border-t pt-4">
            <h2 className="mb-2 text-lg font-semibold">Démarrer la tontine</h2>
            <p className="mb-3 text-sm text-gray-600">
              Un tour par nom est créé ({nbNoms} {nbNoms > 1 ? "tours" : "tour"}) ; les membres et les noms sont
              ensuite figés. Les bénéficiaires seront tirés au sort séance après séance.
            </p>
            <button
              className="bouton"
              disabled={tontine.membres.length < 2}
              onClick={() =>
                window.confirm("Démarrer la tontine ? Les membres et les noms ne pourront plus changer.") &&
                agir(() => api(`/tontines/${tontine.id}/demarrer/`, { methode: "POST" }))
              }
            >
              Démarrer
            </button>
            {tontine.membres.length < 2 && <p className="mt-2 text-sm text-gray-500">Il faut au moins 2 membres.</p>}
          </div>
        </section>
      )}

      {tours.length > 0 && (
        <section className="carte">
          <h2 className="mb-4 text-lg font-semibold">Calendrier des tours</h2>
          <ul className="divide-y">
            {tours.map((tour) => (
              <Tour key={tour.id} tour={tour} encaisse={encaisse} estPresident={estPresident} moi={moi}
                    auBureau={auBureau && tontine.statut === "active"}
                    peutTirer={tour.id === prochainTirage?.id}
                    beneficiaire={libelleNom(tour.beneficiaire_nom_id)}
                    candidats={nomsLibres.map((n) => ({ id: n.id, libelle: nomAffiche(n, nbNomsDe(n.membre_id)) }))}
                    designationEnCours={designations.some((d) => d.tour_id === tour.id && d.statut === "en_attente")}
                    agir={agir} />
            ))}
          </ul>
        </section>
      )}

      {designations.length > 0 && <Designations designations={designations} agir={agir} />}

      {auBureau && <Journal tontineId={tontine.id} />}
    </div>
  );
}

function Info({ titre, children }) {
  return (
    <div>
      <dt className="text-gray-500">{titre}</dt>
      <dd className="font-medium">{children}</dd>
    </div>
  );
}

function Membres({ tontine, nbNoms, gerer, peutNommer, agir }) {
  const url = `/tontines/${tontine.id}`;
  const changerRole = (membre, role) =>
    agir(() => api(`${url}/membres/${membre.id}/role/`, { methode: "PUT", corps: { role } }));
  const retirer = (membre) =>
    window.confirm(`Retirer ${membre.nom_complet} de la tontine ?`) &&
    agir(() => api(`${url}/membres/${membre.id}/`, { methode: "DELETE" }));
  const ajouterNom = (membre) => agir(() => api(`${url}/membres/${membre.id}/noms/`, { methode: "POST" }));
  const retirerNom = (membre) => {
    const dernier = tontine.noms.filter((n) => n.membre_id === membre.id).at(-1);
    agir(() => api(`${url}/noms/${dernier.id}/`, { methode: "DELETE" }));
  };

  return (
    <section className="carte">
      <h2 className="mb-1 text-lg font-semibold">Membres ({tontine.membres.length})</h2>
      <p className="mb-4 text-sm text-gray-500">
        {nbNoms} nom{nbNoms > 1 ? "s" : ""} sur {tontine.nb_places} places. Un membre peut tenir plusieurs noms :
        il cotise et ramasse autant de fois.
      </p>
      <ul className="divide-y">
        {tontine.membres.map((m) => {
          const noms = m.positions.length;
          return (
            <li key={m.id} className="flex flex-wrap items-center justify-between gap-2 py-2">
              <div className="min-w-0">
                <span className="font-medium">{m.nom_complet}</span>
                <span className="block text-sm text-gray-500 sm:ml-2 sm:inline">{m.telephone}</span>
                <span className="block text-sm text-gray-600">{noms} nom{noms > 1 ? "s" : ""}</span>
                {gerer && (
                  <div className="flex flex-wrap gap-x-3 text-sm">
                    <button className="text-blue-600 hover:underline disabled:text-gray-400"
                            disabled={nbNoms >= tontine.nb_places} onClick={() => ajouterNom(m)}
                            aria-label={`Ajouter un nom à ${m.nom_complet}`}>+ 1 nom</button>
                    {noms > 1 && (
                      <button className="text-blue-600 hover:underline" onClick={() => retirerNom(m)}
                              aria-label={`Retirer un nom à ${m.nom_complet}`}>− 1 nom</button>
                    )}
                    {m.role !== "president" && (
                      <button className="text-red-700 hover:underline" onClick={() => retirer(m)}>Retirer</button>
                    )}
                  </div>
                )}
              </div>
              {peutNommer && m.role !== "president" ? (
                <select value={m.role} onChange={(e) => changerRole(m, e.target.value)}
                        className="champ w-auto max-w-[14rem] py-1 text-sm" aria-label={`Poste de ${m.nom_complet}`}>
                  <option value="membre">Membre</option>
                  {POSTES_BUREAU.map((poste) => <option key={poste} value={poste}>{libelle(poste)}</option>)}
                </select>
              ) : (
                m.role !== "membre" && <Badge valeur={m.role} />
              )}
            </li>
          );
        })}
      </ul>
      {peutNommer && (
        <p className="mt-3 text-xs text-gray-500">Un seul titulaire par poste : nommer quelqu'un remplace l'ancien titulaire.</p>
      )}
    </section>
  );
}

function Designations({ designations, agir }) {
  const voter = (d, approuve) =>
    agir(() => api(`/designations/${d.id}/vote/`, { methode: "POST", corps: { approuve } }));
  return (
    <section className="carte">
      <h2 className="mb-1 text-lg font-semibold">Désignations</h2>
      <p className="mb-4 text-sm text-gray-500">
        Demandes d'attribuer un tour sans tirage au sort. Acceptées à la majorité du bureau ; le membre désigné ne
        vote pas.
      </p>
      <ul className="divide-y">
        {designations.map((d) => (
          <li key={d.id} className="py-3 text-sm">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <span className="font-medium">Tour {d.tour} : désignation de {d.beneficiaire}</span>
              <Badge valeur={d.statut} />
            </div>
            <p className="text-gray-700">« {d.motif} » — proposé par {d.propose_par}</p>
            <p className="text-gray-500">
              {d.decompte.pour} pour, {d.decompte.contre} contre — majorité : {d.decompte.majorite} sur{" "}
              {d.decompte.electeurs} votant{d.decompte.electeurs > 1 ? "s" : ""}
              {d.mon_vote !== null && ` — vous avez voté ${d.mon_vote ? "pour" : "contre"}`}
            </p>
            {d.peut_voter && (
              <div className="mt-2 flex gap-2">
                <button className="bouton-secondaire" onClick={() => voter(d, true)}>Approuver</button>
                <button className="bouton-secondaire text-red-700" onClick={() => voter(d, false)}>Refuser</button>
              </div>
            )}
          </li>
        ))}
      </ul>
    </section>
  );
}

const ACTIONS_JOURNAL = {
  creation: "Création", modification: "Paramètres modifiés", annulation: "Annulation", invitation: "Invitation",
  adhesion: "Adhésion", ajout_nom: "Nom ajouté", retrait_nom: "Nom retiré", retrait_membre: "Membre retiré",
  changement_role: "Poste modifié", tirage: "Tirage au sort", designation_proposee: "Désignation proposée",
  designation_acceptee: "Désignation acceptée", designation_refusee: "Désignation refusée",
  designation_caduque: "Désignation caduque", demarrage: "Démarrage", paiement: "Paiement",
  paiement_mobile_lance: "Paiement Mobile Money lancé", confirmation_mobile_money: "Paiement Mobile Money confirmé",
  penalite_payee: "Pénalité payée", remise: "Caisse remise", fin_de_cycle: "Fin du cycle",
  nouveau_cycle: "Nouveau cycle",
};

function Journal({ tontineId }) {
  const [entrees, setEntrees] = useState(null);
  const [suivante, setSuivante] = useState(null);
  const [erreur, setErreur] = useState("");

  // Pagination par curseur : on ne garde que les paramètres de l'URL « next ».
  const charger = (parametres = "") =>
    api(`/tontines/${tontineId}/journal/${parametres}`)
      .then((page) => {
        setEntrees((avant) => [...(parametres ? avant : []), ...page.results]);
        setSuivante(page.next ? new URL(page.next).search : null);
      })
      .catch((err) => setErreur(err.message));
  const ouvrir = () => charger();

  return (
    <section className="carte">
      <div className="flex items-center justify-between gap-2">
        <h2 className="text-lg font-semibold">Journal</h2>
        {entrees === null && <button className="bouton-secondaire" onClick={ouvrir}>Afficher</button>}
      </div>
      <Erreur message={erreur} />
      {entrees && (
        <ul className="mt-3 divide-y text-sm">
          {entrees.map((e) => (
            <li key={e.id} className="flex flex-wrap justify-between gap-2 py-2">
              <span>{ACTIONS_JOURNAL[e.action] ?? e.action}{e.acteur && <span className="text-gray-500"> — {e.acteur}</span>}</span>
              <span className="text-gray-500">{dateCourte(e.cree_le)} {e.cree_le.slice(11, 16)}</span>
            </li>
          ))}
        </ul>
      )}
      {suivante && (
        <button className="bouton-secondaire mt-3" onClick={() => charger(suivante)}>Afficher plus</button>
      )}
    </section>
  );
}

function Invitation({ tontineId, complete }) {
  const [telephone, setTelephone] = useState("+237");
  const [lien, setLien] = useState("");
  const [erreur, setErreur] = useState("");

  const inviter = async (e) => {
    e.preventDefault();
    setErreur("");
    setLien("");
    try {
      const invitation = await api(`/tontines/${tontineId}/invitations/`, {
        methode: "POST",
        corps: { telephone: telephone.trim() },
      });
      setLien(`${window.location.origin}/invitation/${invitation.code}`);
      setTelephone("+237");
    } catch (err) {
      setErreur(err.message);
    }
  };

  return (
    <div>
      <h2 className="mb-2 text-lg font-semibold">Inviter un membre</h2>
      {complete ? (
        <p className="text-sm text-gray-600">Toutes les places sont prises.</p>
      ) : (
        <form onSubmit={inviter} className="flex flex-wrap gap-2">
          <input type="tel" value={telephone} onChange={(e) => setTelephone(e.target.value)}
                 className="champ max-w-xs" aria-label="Numéro de la personne à inviter" required />
          <button className="bouton">Créer le lien</button>
        </form>
      )}
      <Erreur message={erreur} />
      {lien && (
        <div className="mt-3 rounded bg-green-50 p-3 text-sm">
          <p className="mb-1 text-green-900">Envoyez ce lien à la personne (valable 7 jours) :</p>
          <div className="flex flex-wrap items-center gap-2">
            <code className="break-all rounded bg-white px-2 py-1" data-testid="lien-invitation">{lien}</code>
            <button type="button" className="bouton-secondaire" onClick={() => navigator.clipboard?.writeText(lien)}>
              Copier
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function Tour({ tour, beneficiaire, encaisse, estPresident, moi, auBureau, peutTirer, candidats,
                designationEnCours, agir }) {
  const [ouvert, setOuvert] = useState(false);
  const [proposer, setProposer] = useState(false);
  const [cotisations, setCotisations] = useState(null);
  const [aPayer, setAPayer] = useState(null);

  const chargerCotisations = () => api(`/tours/${tour.id}/cotisations/`).then(setCotisations);

  const basculer = async () => {
    if (!ouvert && cotisations === null) await chargerCotisations();
    setOuvert(!ouvert);
  };

  const encaisser = (cotisation) =>
    agir(async () => {
      await api(`/cotisations/${cotisation.id}/paiements/`, {
        methode: "POST",
        corps: { montant: cotisation.reste_a_payer, moyen: "especes" },
      });
      await chargerCotisations();
    });

  const encaisserPenalite = (penalite) =>
    agir(async () => {
      await api(`/penalites/${penalite.id}/payer/`, { methode: "POST" });
      await chargerCotisations();
    });

  const remettre = () => {
    const forcer = tour.nb_impayes > 0;
    const message = forcer
      ? `${tour.nb_impayes} cotisation(s) ne sont pas payées. Remettre quand même ${fcfa(tour.montant_collecte)} ?`
      : `Confirmer la remise de ${fcfa(tour.montant_collecte)} à ${beneficiaire} ?`;
    if (window.confirm(message)) {
      agir(() => api(`/tours/${tour.id}/remise/`, { methode: "POST", corps: { forcer } }));
    }
  };

  return (
    <li className="py-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <button onClick={basculer} className="text-left" aria-expanded={ouvert}
                aria-label={`Tour ${tour.numero}, ${dateCourte(tour.date_echeance)}, ${beneficiaire ? `pour ${beneficiaire}` : "bénéficiaire à tirer au sort"}`}>
          <span className="font-medium">Tour {tour.numero}</span>
          <span className="ml-2 text-sm text-gray-500">{dateCourte(tour.date_echeance)}</span>
          <span className="ml-2 text-sm">
            → {beneficiaire ?? <em className="text-gray-500">à tirer au sort</em>}
          </span>
        </button>
        <div className="flex items-center gap-3 text-sm">
          <span>
            {fcfa(tour.statut === "clos" ? tour.montant_remis : tour.montant_collecte)}
            {tour.statut !== "clos" && <span className="text-gray-500"> / {fcfa(tour.montant_attendu)}</span>}
          </span>
          <Badge valeur={tour.statut} />
        </div>
      </div>

      {auBureau && !beneficiaire && tour.statut !== "clos" && (
        <div className="mt-2 flex flex-wrap gap-2">
          {peutTirer && (
            <button className="bouton" onClick={() =>
              window.confirm(`Tirer au sort le bénéficiaire du tour ${tour.numero} ? Le résultat est définitif.`) &&
              agir(() => api(`/tours/${tour.id}/tirage/`, { methode: "POST" }))}>
              Tirer au sort
            </button>
          )}
          {!designationEnCours && !proposer && (
            <button className="bouton-secondaire" onClick={() => setProposer(true)}>Proposer une désignation</button>
          )}
        </div>
      )}
      {proposer && (
        <PropositionDesignation tour={tour} candidats={candidats} fermer={() => setProposer(false)} agir={agir} />
      )}

      {ouvert && cotisations && (
        <div className="mt-3 rounded bg-gray-50 p-3">
          <ul className="divide-y text-sm">
            {cotisations.map((c) => (
              <li key={c.id} className="py-2">
                <div className="flex flex-wrap items-center justify-between gap-2">
                  <span>
                    {c.membre}
                    {c.nb_noms > 1 && <span className="text-gray-500"> ({c.nb_noms} noms)</span>}
                  </span>
                  <span className="flex items-center gap-2">
                    {c.statut !== "payee" && <span className="text-gray-500">reste {fcfa(c.reste_a_payer)}</span>}
                    <Badge valeur={c.statut} />
                    {encaisse && c.statut !== "payee" && tour.statut !== "clos" && (
                      <button className="bouton-secondaire" onClick={() => encaisser(c)}>Encaisser (espèces)</button>
                    )}
                    {c.membre_id === moi?.id && c.statut !== "payee" && tour.statut !== "clos" && aPayer !== c.id && (
                      <button className="bouton-secondaire" onClick={() => setAPayer(c.id)}>Payer par Mobile Money</button>
                    )}
                  </span>
                </div>
                {c.penalites.map((p) => (
                  <div key={p.id} className="mt-1 flex flex-wrap items-center justify-between gap-2 pl-3 text-xs">
                    <span className="text-red-800">Pénalité {fcfa(p.montant)} — {p.motif}</span>
                    {p.payee ? (
                      <Badge valeur="payee" />
                    ) : encaisse ? (
                      <button className="bouton-secondaire" onClick={() => encaisserPenalite(p)}>
                        Encaisser la pénalité
                      </button>
                    ) : (
                      <span className="text-gray-500">à régler au trésorier</span>
                    )}
                  </div>
                ))}
                {aPayer === c.id && (
                  <PaiementMobile
                    cotisation={c}
                    telephone={moi.telephone}
                    fermer={() => setAPayer(null)}
                    termine={() => agir(async () => { setAPayer(null); await chargerCotisations(); })}
                  />
                )}
              </li>
            ))}
          </ul>
          {encaisse && beneficiaire && tour.statut !== "clos" && (tour.nb_impayes === 0 || estPresident) && (
            <button className="bouton mt-3" onClick={remettre}>Remettre la caisse</button>
          )}
        </div>
      )}
    </li>
  );
}

function PropositionDesignation({ tour, candidats, fermer, agir }) {
  const [nom, setNom] = useState(candidats[0]?.id ?? "");
  const [motif, setMotif] = useState("");

  const envoyer = (e) => {
    e.preventDefault();
    agir(async () => {
      await api(`/tours/${tour.id}/designations/`, { methode: "POST", corps: { nom: Number(nom), motif: motif.trim() } });
      fermer();
    });
  };

  return (
    <form onSubmit={envoyer} className="mt-2 space-y-2 rounded border bg-white p-3 text-sm">
      <p className="font-medium">Désigner le bénéficiaire du tour {tour.numero}</p>
      <select value={nom} onChange={(e) => setNom(e.target.value)} className="champ" aria-label="Nom à désigner">
        {candidats.map((c) => <option key={c.id} value={c.id}>{c.libelle}</option>)}
      </select>
      <input value={motif} onChange={(e) => setMotif(e.target.value)} className="champ" maxLength={300}
             placeholder="Motif (ex. : frais d'hôpital)" aria-label="Motif de la désignation" required />
      <p className="text-xs text-gray-500">La demande est soumise au vote du bureau ; votre proposition compte comme un vote pour.</p>
      <div className="flex gap-2">
        <button className="bouton">Soumettre au bureau</button>
        <button type="button" className="bouton-secondaire" onClick={fermer}>Annuler</button>
      </div>
    </form>
  );
}

const OPERATEURS = [
  { valeur: "mtn_momo", libelle: "MTN Mobile Money" },
  { valeur: "orange_money", libelle: "Orange Money" },
];
const ATTENTE_MAX = 40; // 40 × 3 s = 2 minutes

function PaiementMobile({ cotisation, telephone: telephoneParDefaut, fermer, termine }) {
  const [moyen, setMoyen] = useState("mtn_momo");
  const [telephone, setTelephone] = useState(telephoneParDefaut);
  const [etat, setEtat] = useState("saisie"); // saisie → attente → (réussi : termine) | echec
  const [erreur, setErreur] = useState("");
  const termineRef = useRef(termine);
  termineRef.current = termine;

  // Suit le paiement jusqu'à sa validation (ou son refus) par le payeur.
  useEffect(() => {
    if (typeof etat !== "number") return undefined;
    let essais = 0;
    const minuterie = setInterval(async () => {
      essais += 1;
      try {
        const paiement = await api(`/paiements/${etat}/`);
        if (paiement.statut === "reussi") {
          clearInterval(minuterie);
          termineRef.current();
        } else if (paiement.statut === "echoue") {
          clearInterval(minuterie);
          setErreur("Le paiement a été refusé ou annulé.");
          setEtat("saisie");
        }
      } catch (err) {
        clearInterval(minuterie);
        setErreur(err.message);
        setEtat("saisie");
      }
      if (essais >= ATTENTE_MAX) {
        clearInterval(minuterie);
        setErreur("Pas de réponse de l'opérateur. Si vous avez validé, le paiement apparaîtra plus tard.");
        setEtat("saisie");
      }
    }, 3000);
    return () => clearInterval(minuterie);
  }, [etat]);

  const lancer = async (e) => {
    e.preventDefault();
    setErreur("");
    try {
      const paiement = await api(`/cotisations/${cotisation.id}/paiements/`, {
        methode: "POST",
        corps: { moyen, telephone: telephone.trim() },
      });
      setEtat(paiement.id);
    } catch (err) {
      setErreur(err.message);
    }
  };

  if (typeof etat === "number") {
    return (
      <div className="mt-2 rounded border border-blue-200 bg-blue-50 p-3 text-sm text-blue-900" role="status">
        Demande de {fcfa(cotisation.reste_a_payer)} envoyée au {telephone}. Validez le paiement sur votre téléphone
        avec votre code secret Mobile Money…
      </div>
    );
  }

  return (
    <form onSubmit={lancer} className="mt-2 space-y-2 rounded border bg-white p-3">
      <Erreur message={erreur} />
      <p className="text-sm">Montant : <strong>{fcfa(cotisation.reste_a_payer)}</strong></p>
      <div className="flex flex-wrap gap-2">
        <select value={moyen} onChange={(e) => setMoyen(e.target.value)} className="champ max-w-[12rem]"
                aria-label="Opérateur">
          {OPERATEURS.map((o) => <option key={o.valeur} value={o.valeur}>{o.libelle}</option>)}
        </select>
        <input type="tel" value={telephone} onChange={(e) => setTelephone(e.target.value)}
               className="champ max-w-[12rem]" aria-label="Numéro à débiter" required />
      </div>
      <div className="flex gap-2">
        <button className="bouton">Payer</button>
        <button type="button" className="bouton-secondaire" onClick={fermer}>Annuler</button>
      </div>
    </form>
  );
}
