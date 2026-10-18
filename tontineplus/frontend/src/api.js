// Client de l'API Django. Le jeton d'accès (15 min) reste en mémoire ;
// le jeton de renouvellement est gardé pour que la session survive au rechargement.

const BASE = import.meta.env.VITE_API_URL ?? "/api/v1";
const CLE_REFRESH = "tontineplus.refresh";

let access = null;
let renouvellement = null;

export class ErreurApi extends Error {
  constructor(status, corps) {
    super(messageDe(status, corps));
    this.status = status;
    this.code = corps?.code;
  }
}

function messageDe(status, corps) {
  if (corps?.champs && typeof corps.champs === "object") {
    return Object.entries(corps.champs)
      .map(([champ, erreurs]) => {
        const texte = [].concat(erreurs).join(" ");
        return champ === "non_field_errors" ? texte : `${champ} : ${texte}`;
      })
      .join(" · ");
  }
  return corps?.message ?? `Erreur ${status}`;
}

export const jetons = {
  definir({ access: nouveau, refresh }) {
    access = nouveau;
    if (refresh) localStorage.setItem(CLE_REFRESH, refresh);
  },
  effacer() {
    access = null;
    localStorage.removeItem(CLE_REFRESH);
  },
  refresh: () => localStorage.getItem(CLE_REFRESH),
};

// Un seul renouvellement à la fois : le backend invalide l'ancien jeton à chaque rotation.
function renouveler() {
  const refresh = jetons.refresh();
  if (!refresh) return Promise.resolve(false);
  renouvellement ??= fetch(`${BASE}/auth/refresh/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ refresh }),
  })
    .then(async (reponse) => {
      if (!reponse.ok) {
        jetons.effacer();
        return false;
      }
      jetons.definir(await reponse.json());
      return true;
    })
    .finally(() => {
      renouvellement = null;
    });
  return renouvellement;
}

export async function api(chemin, { methode = "GET", corps, reessai = true } = {}) {
  const headers = { "Content-Type": "application/json" };
  if (access) headers.Authorization = `Bearer ${access}`;
  const reponse = await fetch(BASE + chemin, {
    method: methode,
    headers,
    body: corps === undefined ? undefined : JSON.stringify(corps),
  });
  if (reponse.status === 401 && reessai && (await renouveler())) {
    return api(chemin, { methode, corps, reessai: false });
  }
  if (reponse.status === 204) return null;
  const donnees = await reponse.json().catch(() => null);
  if (!reponse.ok) throw new ErreurApi(reponse.status, donnees);
  return donnees;
}
