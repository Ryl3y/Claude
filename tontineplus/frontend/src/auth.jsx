import { createContext, useCallback, useContext, useEffect, useState } from "react";
import { Navigate, useLocation } from "react-router-dom";
import { api, jetons } from "./api";

const ContexteAuth = createContext(null);

export function AuthProvider({ children }) {
  const [utilisateur, setUtilisateur] = useState(null);
  const [chargement, setChargement] = useState(true);

  const chargerProfil = useCallback(async () => {
    const moi = await api("/moi/");
    setUtilisateur(moi.utilisateur);
    return moi;
  }, []);

  // Au démarrage, reprend la session si un jeton de renouvellement est présent.
  useEffect(() => {
    if (!jetons.refresh()) {
      setChargement(false);
      return;
    }
    chargerProfil()
      .catch(() => jetons.effacer())
      .finally(() => setChargement(false));
  }, [chargerProfil]);

  const connexion = async (telephone, password) => {
    jetons.definir(
      await api("/auth/connexion/", { methode: "POST", corps: { telephone, password }, reessai: false })
    );
    await chargerProfil();
  };

  const demanderCode = (telephone) =>
    api("/auth/code/demande/", { methode: "POST", corps: { telephone }, reessai: false });

  // Un numéro inconnu renvoie l'erreur « nom_requis » : on redemande alors avec le nom.
  const connexionParCode = async (telephone, code, nomComplet) => {
    const reponse = await api("/auth/code/verification/", {
      methode: "POST",
      corps: { telephone, code, nom_complet: nomComplet ?? "" },
      reessai: false,
    });
    jetons.definir(reponse);
    setUtilisateur(reponse.utilisateur);
  };

  const inscription = async (donnees) => {
    const reponse = await api("/auth/inscription/", { methode: "POST", corps: donnees, reessai: false });
    jetons.definir(reponse);
    setUtilisateur(reponse.utilisateur);
  };

  const deconnexion = async () => {
    try {
      await api("/auth/deconnexion/", { methode: "POST", corps: { refresh: jetons.refresh() } });
    } finally {
      jetons.effacer();
      setUtilisateur(null);
    }
  };

  return (
    <ContexteAuth.Provider
      value={{ utilisateur, chargement, connexion, demanderCode, connexionParCode, inscription, deconnexion }}
    >
      {children}
    </ContexteAuth.Provider>
  );
}

export const useAuth = () => useContext(ContexteAuth);

export function RouteProtegee({ children }) {
  const { utilisateur, chargement } = useAuth();
  const location = useLocation();
  if (chargement) return <p className="p-6 text-center text-gray-500">Chargement…</p>;
  if (!utilisateur) return <Navigate to="/login" replace state={{ depuis: location.pathname }} />;
  return children;
}
