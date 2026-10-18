import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../auth";
import Badge from "../components/Badge";
import Erreur from "../components/Erreur";
import { fcfa, libelle } from "../format";

export default function Dashboard() {
  const { utilisateur } = useAuth();
  const [tontines, setTontines] = useState(null);
  const [erreur, setErreur] = useState("");

  useEffect(() => {
    api("/moi/")
      .then((moi) => setTontines(moi.tontines))
      .catch((err) => setErreur(err.message));
  }, []);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold">Bonjour, {utilisateur.nom_complet}</h1>
        <Link to="/create-group" className="bouton">Créer une tontine</Link>
      </div>
      <Erreur message={erreur} />

      {tontines === null && !erreur && <p className="text-gray-500">Chargement…</p>}

      {tontines?.length === 0 && (
        <div className="carte text-center text-gray-600">
          <p className="mb-2 font-medium">Vous n'êtes membre d'aucune tontine.</p>
          <p className="text-sm">Créez-en une, ou ouvrez le lien d'invitation qu'un président vous a envoyé.</p>
        </div>
      )}

      <ul className="grid gap-4 sm:grid-cols-2">
        {tontines?.map((t) => (
          <li key={t.id}>
            <Link to={`/group/${t.id}`} className="carte block hover:ring-2 hover:ring-marque-200">
              <div className="mb-2 flex items-start justify-between gap-2">
                <h2 className="text-lg font-semibold">{t.nom}</h2>
                <Badge valeur={t.statut} />
              </div>
              <p className="text-gray-700">
                {fcfa(t.montant_cotisation)} · {libelle(t.frequence).toLowerCase()}
              </p>
              <p className="mt-1 text-sm text-gray-500">Mon rôle : {libelle(t.mon_role)}</p>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
