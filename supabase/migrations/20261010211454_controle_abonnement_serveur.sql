-- =============================================================================
-- 1. Lecture seule après l'abonnement, aussi sur le serveur.
--
-- L'app bloque déjà les enregistrements quand l'essai ou Pro est fini. Le
-- serveur refuse en plus les écritures du commerçant (ventes, stock,
-- clients, dettes) dans ce cas : reculer l'horloge du téléphone ne suffit
-- plus à continuer longtemps.
--
-- Exception : une écriture datée d'avant la fin (téléphone resté hors ligne
-- pendant l'abonnement) est acceptée si elle arrive moins de 7 jours après
-- sa date. Au-delà, l'horloge du téléphone a sans doute été reculée.
-- Boutiques et utilisateurs ne sont pas concernés (profil, code PIN).
-- =============================================================================

create function private.verifier_abonnement()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  fin date;
begin
  -- Fonctions du serveur (service_role, sans utilisateur) : pas de contrôle.
  if (select auth.uid()) is null then
    return new;
  end if;
  select a.date_fin into fin
  from public.abonnements a
  where a.boutique_id = new.boutique_id;
  if fin is null or private.aujourdhui_douala() <= fin then
    return new;
  end if;
  if (new.maj_le at time zone 'Africa/Douala')::date <= fin
     and new.maj_le >= now() - interval '7 days' then
    return new;
  end if;
  raise exception 'abonnement_termine'
    using errcode = 'P0001',
          hint = 'Essai ou Kassa Pro terminé : passer à Pro pour enregistrer.';
end;
$$;

revoke all on function private.verifier_abonnement() from public, anon, authenticated;

-- Après le trigger « horodater » (ordre alphabétique) : une version plus
-- ancienne déjà ignorée n'est pas contrôlée, et maj_le est déjà ramené à
-- l'heure du serveur s'il était dans le futur.
create trigger verifier_abonnement before insert or update on public.categories
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.produits
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.clients
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.ventes
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.lignes_vente
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.versements_dette
  for each row execute function private.verifier_abonnement();
create trigger verifier_abonnement before insert or update on public.mouvements_stock
  for each row execute function private.verifier_abonnement();

-- =============================================================================
-- 2. Une seule demande de paiement en attente à la fois par boutique.
--
-- Vérifier puis noter la demande en une seule opération, sous un verrou
-- propre à la boutique : deux appels au même instant (deux téléphones,
-- double appui) ne peuvent pas lancer deux débits Mobile Money.
-- Renvoie faux si une demande en attente a moins de p_delai_secondes.
-- Appelée seulement par la fonction serveur abonnement-payer (service_role).
-- =============================================================================

create function public.reserver_paiement_abonnement(
  p_reference text,
  p_boutique_id uuid,
  p_utilisateur_id uuid,
  p_montant bigint,
  p_operateur text,
  p_delai_secondes integer
)
returns boolean
language plpgsql
set search_path = ''
as $$
begin
  perform pg_advisory_xact_lock(hashtextextended(p_boutique_id::text, 0));
  if exists (
    select 1 from public.paiements_abonnement
    where boutique_id = p_boutique_id
      and statut = 'en_attente'
      and cree_le >= now() - make_interval(secs => p_delai_secondes)
  ) then
    return false;
  end if;
  insert into public.paiements_abonnement
    (reference, boutique_id, utilisateur_id, montant, operateur)
  values
    (p_reference, p_boutique_id, p_utilisateur_id, p_montant, p_operateur);
  return true;
end;
$$;

revoke all on function public.reserver_paiement_abonnement(text, uuid, uuid, bigint, text, integer)
  from public, anon, authenticated;
grant execute on function public.reserver_paiement_abonnement(text, uuid, uuid, bigint, text, integer)
  to service_role;
