import { useCallback, useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../auth";
import Badge from "../components/Badge";
import Erreur from "../components/Erreur";
import { dateCourte, fcfa, libelle } from "../format";

export default function GroupDetails() {
  const { id } = useParams();
  const { utilisateur } = useAuth();
  const [tontine, setTontine] = useState(null);
  const [tours, setTours] = useState([]);
  const [erreur, setErreur] = useState("");

  const charger = useCallback(async () => {
    try {
      const detail = await api(`/tontines/${id}/`);
      setTontine(detail);
      setTours(detail.statut === "brouillon" ? [] : await api(`/tontines/${id}/tours/`));
    } catch (err) {
      setErreur(err.status === 404 ? "Tontine introuvable, ou vous n'en êtes pas membre." : err.message);
    }
  }, [id]);

  useEffect(() => {
    charger();
  }, [charger]);

  if (!tontine) {
    return erreur ? <Erreur message={erreur} /> : <p className="text-gray-500">Chargement…</p>;
  }

  const moi = tontine.membres.find((m) => m.telephone === utilisateur.telephone);
  const estPresident = moi?.role === "president";
  const encaisse = ["president", "tresorier"].includes(moi?.role);
  const brouillon = tontine.statut === "brouillon";
  const membresActifs = tontine.membres.filter((m) => m.statut === "actif");

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

  return (
    <div className="space-y-6">
      <section className="carte">
        <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
          <h1 className="text-2xl font-bold">{tontine.nom}</h1>
          <Badge valeur={tontine.statut} />
        </div>
        {tontine.description && <p className="mb-3 text-gray-700">{tontine.description}</p>}
        <dl className="grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
          <Info titre="Cotisation">{fcfa(tontine.montant_cotisation)}</Info>
          <Info titre="Fréquence">{libelle(tontine.frequence)}</Info>
          <Info titre="Caisse par tour">{fcfa(tontine.montant_cotisation * membresActifs.length)}</Info>
          <Info titre="Pénalité de retard">{fcfa(tontine.penalite_retard)}</Info>
        </dl>
      </section>

      <Erreur message={erreur} />

      <Membres
        tontine={tontine}
        membres={membresActifs}
        peutOrdonner={estPresident && brouillon && tontine.mode_attribution === "ordre_fixe"}
        agir={agir}
      />

      {estPresident && brouillon && (
        <section className="carte space-y-6">
          <Invitation tontineId={tontine.id} complete={membresActifs.length >= tontine.nb_membres_max} />
          <div className="border-t pt-4">
            <h2 className="mb-2 text-lg font-semibold">Démarrer la tontine</h2>
            <p className="mb-3 text-sm text-gray-600">
              Un tour par membre est généré ({membresActifs.length} {membresActifs.length > 1 ? "tours" : "tour"}),
              puis les membres sont figés.
              {tontine.mode_attribution === "tirage_au_sort" && " L'ordre de passage sera tiré au sort."}
            </p>
            <button
              className="bouton"
              disabled={membresActifs.length < 2}
              onClick={() =>
                window.confirm("Démarrer la tontine ? Les membres et l'ordre ne pourront plus changer.") &&
                agir(() => api(`/tontines/${tontine.id}/demarrer/`, { methode: "POST" }))
              }
            >
              Démarrer
            </button>
            {membresActifs.length < 2 && <p className="mt-2 text-sm text-gray-500">Il faut au moins 2 membres.</p>}
          </div>
        </section>
      )}

      {!brouillon && (
        <section className="carte">
          <h2 className="mb-4 text-lg font-semibold">Calendrier des tours</h2>
          <ul className="divide-y">
            {tours.map((tour) => (
              <Tour key={tour.id} tour={tour} encaisse={encaisse} estPresident={estPresident} agir={agir} />
            ))}
          </ul>
        </section>
      )}
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

function Membres({ tontine, membres, peutOrdonner, agir }) {
  const deplacer = (index, sens) => {
    const ordre = membres.map((m) => m.id);
    [ordre[index], ordre[index + sens]] = [ordre[index + sens], ordre[index]];
    agir(() => api(`/tontines/${tontine.id}/ordre/`, { methode: "PUT", corps: { membres: ordre } }));
  };

  return (
    <section className="carte">
      <h2 className="mb-4 text-lg font-semibold">
        Membres ({membres.length}/{tontine.nb_membres_max})
      </h2>
      <ol className="divide-y">
        {membres.map((m, i) => (
          <li key={m.id} className="flex items-center justify-between gap-2 py-2">
            <div className="min-w-0">
              <span className="mr-2 text-gray-500">{m.position_tour ?? "—"}.</span>
              <span className="font-medium">{m.nom_complet}</span>
              <span className="block text-sm text-gray-500 sm:ml-2 sm:inline">{m.telephone}</span>
            </div>
            <div className="flex shrink-0 items-center gap-2">
              {m.role !== "membre" && <Badge valeur={m.role} />}
              {peutOrdonner && (
                <>
                  <button className="bouton-secondaire" disabled={i === 0} onClick={() => deplacer(i, -1)}
                          aria-label={`Faire passer ${m.nom_complet} plus tôt`}>↑</button>
                  <button className="bouton-secondaire" disabled={i === membres.length - 1}
                          onClick={() => deplacer(i, 1)} aria-label={`Faire passer ${m.nom_complet} plus tard`}>↓</button>
                </>
              )}
            </div>
          </li>
        ))}
      </ol>
      {peutOrdonner && (
        <p className="mt-3 text-sm text-gray-500">Le numéro est l'ordre de passage : le n° 1 ramasse au premier tour.</p>
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
        <p className="text-sm text-gray-600">La tontine a atteint son nombre maximum de membres.</p>
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

function Tour({ tour, encaisse, estPresident, agir }) {
  const [ouvert, setOuvert] = useState(false);
  const [cotisations, setCotisations] = useState(null);

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

  const remettre = () => {
    const forcer = tour.nb_impayes > 0;
    const message = forcer
      ? `${tour.nb_impayes} cotisation(s) ne sont pas payées. Remettre quand même ${fcfa(tour.montant_collecte)} ?`
      : `Confirmer la remise de ${fcfa(tour.montant_collecte)} à ${tour.beneficiaire} ?`;
    if (window.confirm(message)) {
      agir(() => api(`/tours/${tour.id}/remise/`, { methode: "POST", corps: { forcer } }));
    }
  };

  return (
    <li className="py-3">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <button onClick={basculer} className="text-left" aria-expanded={ouvert}>
          <span className="font-medium">Tour {tour.numero}</span>
          <span className="ml-2 text-sm text-gray-500">{dateCourte(tour.date_echeance)}</span>
          <span className="ml-2 text-sm">→ {tour.beneficiaire}</span>
        </button>
        <div className="flex items-center gap-3 text-sm">
          <span>
            {fcfa(tour.statut === "clos" ? tour.montant_remis : tour.montant_collecte)}
            {tour.statut !== "clos" && <span className="text-gray-500"> / {fcfa(tour.montant_attendu)}</span>}
          </span>
          <Badge valeur={tour.statut} />
        </div>
      </div>

      {ouvert && cotisations && (
        <div className="mt-3 rounded bg-gray-50 p-3">
          <ul className="divide-y text-sm">
            {cotisations.map((c) => (
              <li key={c.id} className="flex flex-wrap items-center justify-between gap-2 py-2">
                <span>{c.membre}</span>
                <span className="flex items-center gap-2">
                  {c.statut !== "payee" && <span className="text-gray-500">reste {fcfa(c.reste_a_payer)}</span>}
                  <Badge valeur={c.statut} />
                  {encaisse && c.statut !== "payee" && tour.statut !== "clos" && (
                    <button className="bouton-secondaire" onClick={() => encaisser(c)}>Encaisser (espèces)</button>
                  )}
                </span>
              </li>
            ))}
          </ul>
          {encaisse && tour.statut !== "clos" && (tour.nb_impayes === 0 || estPresident) && (
            <button className="bouton mt-3" onClick={remettre}>Remettre la caisse</button>
          )}
        </div>
      )}
    </li>
  );
}
