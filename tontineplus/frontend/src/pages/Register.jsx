import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth";
import Erreur from "../components/Erreur";

export default function Register() {
  const { inscription } = useAuth();
  const [nomComplet, setNomComplet] = useState("");
  const [telephone, setTelephone] = useState("+237");
  const [password, setPassword] = useState("");
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErreur("");
    setEnvoi(true);
    try {
      await inscription({ nom_complet: nomComplet.trim(), telephone: telephone.trim(), password });
      navigate(location.state?.depuis ?? "/", { replace: true });
    } catch (err) {
      setErreur(err.message);
    } finally {
      setEnvoi(false);
    }
  };

  return (
    <div className="carte mx-auto mt-10 max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Inscription</h1>
      <Erreur message={erreur} />
      <form onSubmit={handleSubmit} className="space-y-4">
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Nom complet</span>
          <input value={nomComplet} onChange={(e) => setNomComplet(e.target.value)}
                 className="champ" autoComplete="name" required />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Numéro de téléphone</span>
          <input type="tel" value={telephone} onChange={(e) => setTelephone(e.target.value)}
                 className="champ" autoComplete="tel" placeholder="+237690000000" required />
          <span className="mt-1 block text-xs text-gray-500">Format international, ex. +237690000000</span>
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Mot de passe</span>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
                 className="champ" autoComplete="new-password" minLength={8} required />
          <span className="mt-1 block text-xs text-gray-500">8 caractères minimum, pas uniquement des chiffres</span>
        </label>
        <button type="submit" className="bouton w-full" disabled={envoi}>
          {envoi ? "Création du compte…" : "S'inscrire"}
        </button>
      </form>
      <p className="mt-4 text-center text-sm text-gray-600">
        Déjà inscrit ?{" "}
        <Link to="/login" state={location.state} className="text-marque-600 hover:underline">Se connecter</Link>
      </p>
    </div>
  );
}
