import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth";
import Erreur from "../components/Erreur";

export default function Login() {
  const { connexion } = useAuth();
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
      await connexion(telephone.trim(), password);
      navigate(location.state?.depuis ?? "/", { replace: true });
    } catch (err) {
      setErreur(err.status === 401 ? "Numéro ou mot de passe incorrect." : err.message);
    } finally {
      setEnvoi(false);
    }
  };

  return (
    <div className="carte mx-auto mt-10 max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Connexion</h1>
      <Erreur message={erreur} />
      <form onSubmit={handleSubmit} className="space-y-4">
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Numéro de téléphone</span>
          <input type="tel" value={telephone} onChange={(e) => setTelephone(e.target.value)}
                 className="champ" autoComplete="tel" required />
        </label>
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Mot de passe</span>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
                 className="champ" autoComplete="current-password" required />
        </label>
        <button type="submit" className="bouton w-full" disabled={envoi}>
          {envoi ? "Connexion…" : "Se connecter"}
        </button>
      </form>
      <p className="mt-4 text-center text-sm text-gray-600">
        Pas encore de compte ?{" "}
        <Link to="/register" state={location.state} className="text-blue-600 hover:underline">S'inscrire</Link>
      </p>
    </div>
  );
}
