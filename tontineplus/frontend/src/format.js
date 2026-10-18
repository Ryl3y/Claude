const nombre = new Intl.NumberFormat("fr-FR");
const mois = ["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."];

export const fcfa = (montant) => `${nombre.format(montant ?? 0)} FCFA`;

// "2026-11-01" → "1 nov. 2026", sans passer par Date (évite le décalage de fuseau).
export function dateCourte(iso) {
  if (!iso) return "—";
  const [annee, m, jour] = iso.slice(0, 10).split("-").map(Number);
  return `${jour} ${mois.at(m - 1)} ${annee}`;
}

export const LIBELLES = {
  brouillon: "Brouillon",
  active: "Active",
  terminee: "Terminée",
  annulee: "Annulée",
  hebdomadaire: "Hebdomadaire",
  quinzaine: "Toutes les 2 semaines",
  mensuelle: "Mensuelle",
  president: "Président",
  tresorier: "Trésorier",
  secretaire: "Secrétaire",
  secretaire_adjoint: "Secrétaire adjoint",
  censeur: "Censeur",
  censeur_adjoint: "Censeur adjoint",
  commissaire: "Commissaire aux comptes",
  commissaire_adjoint: "Commissaire aux comptes adjoint",
  membre: "Membre",
  en_attente: "En attente",
  acceptee: "Acceptée",
  refusee: "Refusée",
  caduque: "Caduque",
  a_venir: "À venir",
  ouvert: "Ouvert",
  clos: "Clos",
  due: "Due",
  partielle: "Partielle",
  payee: "Payée",
  en_retard: "En retard",
};

export const libelle = (valeur) => LIBELLES[valeur] ?? valeur;

export const POSTES_BUREAU = [
  "tresorier", "secretaire", "secretaire_adjoint", "censeur", "censeur_adjoint", "commissaire", "commissaire_adjoint",
];

const COULEURS = {
  active: "bg-green-100 text-green-800",
  payee: "bg-green-100 text-green-800",
  clos: "bg-gray-200 text-gray-700",
  terminee: "bg-gray-200 text-gray-700",
  partielle: "bg-amber-100 text-amber-800",
  ouvert: "bg-blue-100 text-blue-800",
  en_retard: "bg-red-100 text-red-800",
  acceptee: "bg-green-100 text-green-800",
  refusee: "bg-red-100 text-red-800",
  en_attente: "bg-amber-100 text-amber-800",
};

export const couleurStatut = (statut) => COULEURS[statut] ?? "bg-gray-100 text-gray-700";
