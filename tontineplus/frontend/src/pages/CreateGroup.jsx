import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { api } from "../api";
import Erreur from "../components/Erreur";
import { fcfa } from "../format";

const VIDE = {
  nom: "",
  description: "",
  montant_cotisation: "",
  frequence: "mensuelle",
  nb_places: 10,
  penalite_retard: 0,
  date_debut: "",
};

const CHAMPS = Object.keys(VIDE);

export default function CreateGroup() {
  const navigate = useNavigate();
  const creer = async (corps) => {
    const tontine = await api("/tontines/", { methode: "POST", corps });
    navigate(`/group/${tontine.id}`);
  };
  return <FormulaireTontine titre="Créer une tontine" bouton="Créer la tontine" initial={VIDE} enregistrer={creer} />;
}

// Modification des paramètres, possible tant que la tontine n'a pas démarré.
export function EditGroup() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [initial, setInitial] = useState(null);
  const [erreur, setErreur] = useState("");

  useEffect(() => {
    api(`/tontines/${id}/`)
      .then((t) => setInitial(Object.fromEntries(CHAMPS.map((c) => [c, t[c] ?? ""]))))
      .catch((err) => setErreur(err.message));
  }, [id]);

  const modifier = async (corps) => {
    await api(`/tontines/${id}/`, { methode: "PATCH", corps });
    navigate(`/group/${id}`);
  };

  if (!initial) return erreur ? <Erreur message={erreur} /> : <p className="text-gray-500">Chargement…</p>;
  return <FormulaireTontine titre="Modifier la tontine" bouton="Enregistrer" initial={initial} enregistrer={modifier} />;
}

function FormulaireTontine({ titre, bouton, initial, enregistrer }) {
  const [form, setForm] = useState(initial);
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);

  const changer = (champ) => (e) => setForm({ ...form, [champ]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErreur("");
    setEnvoi(true);
    try {
      await enregistrer({
        ...form,
        montant_cotisation: Number(form.montant_cotisation),
        nb_places: Number(form.nb_places),
        penalite_retard: Number(form.penalite_retard),
        date_debut: form.date_debut || null,
      });
    } catch (err) {
      setErreur(err.message);
      setEnvoi(false);
    }
  };

  const caisse = Number(form.montant_cotisation) * Number(form.nb_places);

  return (
    <div className="carte mx-auto max-w-xl">
      <h1 className="mb-6 text-2xl font-bold">{titre}</h1>
      <Erreur message={erreur} />
      <form onSubmit={handleSubmit} className="space-y-4">
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Nom de la tontine</span>
          <input value={form.nom} onChange={changer("nom")} className="champ" required maxLength={120} />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Description</span>
          <textarea value={form.description} onChange={changer("description")} className="champ" rows={3} />
        </label>
        <div className="grid gap-4 sm:grid-cols-2">
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Cotisation par nom et par tour (FCFA)</span>
            <input type="number" min={1} step={1} value={form.montant_cotisation}
                   onChange={changer("montant_cotisation")} className="champ" required />
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Fréquence</span>
            <select value={form.frequence} onChange={changer("frequence")} className="champ">
              <option value="hebdomadaire">Hebdomadaire</option>
              <option value="quinzaine">Toutes les 2 semaines</option>
              <option value="mensuelle">Mensuelle</option>
            </select>
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Nombre de places (noms)</span>
            <input type="number" min={2} max={100} value={form.nb_places}
                   onChange={changer("nb_places")} className="champ" required />
            <span className="mt-1 block text-xs text-gray-500">Un tour par nom ; un membre peut prendre plusieurs noms.</span>
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Pénalité de retard par nom (FCFA)</span>
            <input type="number" min={0} step={1} value={form.penalite_retard}
                   onChange={changer("penalite_retard")} className="champ" />
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Date du premier tour</span>
            <input type="date" value={form.date_debut} onChange={changer("date_debut")} className="champ" />
          </label>
        </div>
        {caisse > 0 && (
          <p className="rounded bg-blue-50 p-3 text-sm text-blue-900">
            Avec {form.nb_places} noms, chaque tour, le bénéficiaire ramassera {fcfa(caisse)}.
          </p>
        )}
        <button type="submit" className="bouton w-full" disabled={envoi}>
          {envoi ? "Enregistrement…" : bouton}
        </button>
      </form>
    </div>
  );
}
