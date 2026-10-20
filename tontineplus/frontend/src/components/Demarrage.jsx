// Écran de démarrage : même rendu que le contenu initial de index.html, pour un passage sans saut.
export default function Demarrage() {
  return (
    <div className="demarrage" role="status" aria-label="Chargement">
      <img src="/symbole.svg" alt="" />
      <span>Chacun son tour. Tous ensemble.</span>
    </div>
  );
}
