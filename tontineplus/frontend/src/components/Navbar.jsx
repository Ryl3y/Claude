import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../auth";

export default function Navbar() {
  const { utilisateur, deconnexion } = useAuth();
  const navigate = useNavigate();

  const seDeconnecter = async () => {
    await deconnexion();
    navigate("/login");
  };

  return (
    <nav className="bg-marque-900 text-ivoire">
      <div className="mx-auto flex max-w-4xl items-center justify-between gap-4 px-4 py-3">
        <Link to="/" aria-label="TONTINE+, accueil">
          <img src="/logo-horizontal-blanc.svg" alt="TONTINE+" className="h-7 w-auto" />
        </Link>
        <div className="flex items-center gap-4 text-sm">
          {utilisateur ? (
            <>
              <span className="hidden sm:inline opacity-80">{utilisateur.nom_complet}</span>
              <Link to="/create-group" className="hover:underline">Créer une tontine</Link>
              <button className="hover:underline" onClick={seDeconnecter}>Déconnexion</button>
            </>
          ) : (
            <>
              <Link to="/login" className="hover:underline">Connexion</Link>
              <Link to="/register" className="hover:underline">Inscription</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}
