import { couleurStatut, libelle } from "../format";

export default function Badge({ valeur }) {
  return (
    <span className={`inline-block rounded-full px-2 py-0.5 text-xs font-medium ${couleurStatut(valeur)}`}>
      {libelle(valeur)}
    </span>
  );
}
