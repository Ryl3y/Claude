import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../auth";
import Erreur from "../components/Erreur";

// Connexion par code SMS (par défaut, crée aussi le compte) ou par mot de passe.
export default function Login() {
  const [mode, setMode] = useState("sms");
  const location = useLocation();
  const navigate = useNavigate();
  const continuer = () => navigate(location.state?.depuis ?? "/", { replace: true });

  return (
    <div className="carte mx-auto mt-10 max-w-md">
      <img src="/symbole.svg" alt="" className="mx-auto mb-4 h-16 w-16" />
      <h1 className="mb-1 text-center text-2xl font-bold">Connexion</h1>
      <p className="mb-6 text-center text-sm text-gray-500">Chacun son tour. Tous ensemble.</p>
      {mode === "sms" ? <ParCode continuer={continuer} /> : <ParMotDePasse continuer={continuer} />}
      <div className="mt-6 space-y-2 border-t pt-4 text-center text-sm text-gray-600">
        <button className="text-marque-600 hover:underline" onClick={() => setMode(mode === "sms" ? "mdp" : "sms")}>
          {mode === "sms" ? "Se connecter avec un mot de passe" : "Recevoir un code par SMS"}
        </button>
        {mode === "mdp" && (
          <p>
            Pas encore de compte ?{" "}
            <Link to="/register" state={location.state} className="text-marque-600 hover:underline">S'inscrire</Link>
          </p>
        )}
      </div>
    </div>
  );
}

function ChampTelephone({ valeur, onChange, desactive }) {
  return (
    <label className="block">
      <span className="mb-1 block text-sm font-medium">Numéro de téléphone</span>
      <input type="tel" value={valeur} onChange={(e) => onChange(e.target.value)} className="champ"
             autoComplete="tel" placeholder="+237690000000" disabled={desactive} required />
    </label>
  );
}

function ParCode({ continuer }) {
  const { demanderCode, connexionParCode } = useAuth();
  const [telephone, setTelephone] = useState("+237");
  const [code, setCode] = useState("");
  const [nomComplet, setNomComplet] = useState("");
  const [etape, setEtape] = useState("numero"); // numero → code → (nom si nouveau compte)
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);

  const executer = async (action) => {
    setErreur("");
    setEnvoi(true);
    try {
      await action();
    } catch (err) {
      if (err.code === "nom_requis") setEtape("nom");
      else setErreur(err.message);
    } finally {
      setEnvoi(false);
    }
  };

  const envoyerCode = (e) => {
    e.preventDefault();
    executer(async () => {
      await demanderCode(telephone.trim());
      setEtape("code");
    });
  };

  const valider = (e) => {
    e.preventDefault();
    executer(async () => {
      await connexionParCode(telephone.trim(), code.trim(), etape === "nom" ? nomComplet.trim() : "");
      continuer();
    });
  };

  if (etape === "numero") {
    return (
      <form onSubmit={envoyerCode} className="space-y-4">
        <Erreur message={erreur} />
        <ChampTelephone valeur={telephone} onChange={setTelephone} />
        <button type="submit" className="bouton w-full" disabled={envoi}>
          {envoi ? "Envoi…" : "Recevoir un code par SMS"}
        </button>
        <p className="text-center text-xs text-gray-500">Pas encore de compte ? Il sera créé à la première connexion.</p>
      </form>
    );
  }

  return (
    <form onSubmit={valider} className="space-y-4">
      <Erreur message={erreur} />
      <ChampTelephone valeur={telephone} desactive />
      {etape === "nom" ? (
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Bienvenue ! Votre nom complet</span>
          <input value={nomComplet} onChange={(e) => setNomComplet(e.target.value)} className="champ"
                 autoComplete="name" autoFocus required />
        </label>
      ) : (
        <label className="block">
          <span className="mb-1 block text-sm font-medium">Code reçu par SMS</span>
          <input value={code} onChange={(e) => setCode(e.target.value.replace(/\D/g, "").slice(0, 6))}
                 className="champ text-center text-2xl tracking-widest" inputMode="numeric"
                 autoComplete="one-time-code" pattern="[0-9]{6}" placeholder="______" autoFocus required />
        </label>
      )}
      <button type="submit" className="bouton w-full" disabled={envoi}>
        {envoi ? "Vérification…" : etape === "nom" ? "Créer mon compte" : "Valider"}
      </button>
      <button type="button" className="w-full text-sm text-marque-600 hover:underline"
              onClick={() => { setEtape("numero"); setCode(""); setErreur(""); }}>
        Changer de numéro ou renvoyer un code
      </button>
    </form>
  );
}

function ParMotDePasse({ continuer }) {
  const { connexion } = useAuth();
  const [telephone, setTelephone] = useState("+237");
  const [password, setPassword] = useState("");
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErreur("");
    setEnvoi(true);
    try {
      await connexion(telephone.trim(), password);
      continuer();
    } catch (err) {
      setErreur(err.status === 401 ? "Numéro ou mot de passe incorrect." : err.message);
    } finally {
      setEnvoi(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Erreur message={erreur} />
      <ChampTelephone valeur={telephone} onChange={setTelephone} />
      <label className="block">
        <span className="mb-1 block text-sm font-medium">Mot de passe</span>
        <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
               className="champ" autoComplete="current-password" required />
      </label>
      <button type="submit" className="bouton w-full" disabled={envoi}>
        {envoi ? "Connexion…" : "Se connecter"}
      </button>
    </form>
  );
}
