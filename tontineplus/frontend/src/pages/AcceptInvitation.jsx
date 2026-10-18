import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../auth";
import Erreur from "../components/Erreur";

export default function AcceptInvitation() {
  const { code } = useParams();
  const { utilisateur } = useAuth();
  const [erreur, setErreur] = useState("");
  const [envoi, setEnvoi] = useState(false);
  const navigate = useNavigate();

  const rejoindre = async () => {
    setErreur("");
    setEnvoi(true);
    try {
      const membre = await api(`/invitations/${code}/accepter/`, { methode: "POST" });
      navigate(`/group/${membre.tontine}`, { replace: true });
    } catch (err) {
      setErreur(err.message);
      setEnvoi(false);
    }
  };

  return (
    <div className="carte mx-auto mt-10 max-w-md text-center">
      <h1 className="mb-4 text-2xl font-bold">Invitation à une tontine</h1>
      <Erreur message={erreur} />
      <p className="mb-6 text-gray-700">
        Vous allez rejoindre la tontine avec le numéro <strong>{utilisateur.telephone}</strong>.
      </p>
      <button className="bouton w-full" onClick={rejoindre} disabled={envoi}>
        {envoi ? "…" : "Rejoindre la tontine"}
      </button>
    </div>
  );
}
