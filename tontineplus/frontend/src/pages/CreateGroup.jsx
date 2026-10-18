import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../api";
import Erreur from "../components/Erreur";
import { fcfa } from "../format";

const VIDE = {
  nom: "",
  description: "",
  montant_cotisation: "",
  frequence: "mensuelle",
  mode_attribution: "ordre_fixe",
  nb_membres_max: 10,
  penalite_retard: 0,
  date_debut: "",
};

export default function CreateGroup() {
  const [form, setForm] = useState(VIDE);
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);
  const navigate = useNavigate();

  const changer = (champ) => (e) => setForm({ ...form, [champ]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErreur("");
    setEnvoi(true);
    try {
      const tontine = await api("/tontines/", {
        methode: "POST",
        corps: {
          ...form,
          montant_cotisation: Number(form.montant_cotisation),
          nb_membres_max: Number(form.nb_membres_max),
          penalite_retard: Number(form.penalite_retard),
          date_debut: form.date_debut || null,
        },
      });
      navigate(`/group/${tontine.id}`);
    } catch (err) {
      setErreur(err.message);
      setEnvoi(false);
    }
  };

  const caisse = Number(form.montant_cotisation) * Number(form.nb_membres_max);

  return (
    <div className="carte mx-auto max-w-xl">
      <h1 className="mb-6 text-2xl font-bold">Créer une tontine</h1>
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
            <span className="mb-1 block text-sm font-medium">Cotisation par tour (FCFA)</span>
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
            <span className="mb-1 block text-sm font-medium">Nombre maximum de membres</span>
            <input type="number" min={2} max={100} value={form.nb_membres_max}
                   onChange={changer("nb_membres_max")} className="champ" required />
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Ordre de passage</span>
            <select value={form.mode_attribution} onChange={changer("mode_attribution")} className="champ">
              <option value="ordre_fixe">Ordre fixe (choisi par le président)</option>
              <option value="tirage_au_sort">Tirage au sort au démarrage</option>
            </select>
          </label>
          <label className="block">
            <span className="mb-1 block text-sm font-medium">Pénalité de retard (FCFA)</span>
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
            Avec {form.nb_membres_max} membres, chaque bénéficiaire ramassera {fcfa(caisse)}.
          </p>
        )}
        <button type="submit" className="bouton w-full" disabled={envoi}>
          {envoi ? "Création…" : "Créer la tontine"}
        </button>
      </form>
    </div>
  );
}
