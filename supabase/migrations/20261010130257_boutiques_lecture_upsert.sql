-- =============================================================================
-- Premier envoi d'une boutique par « upsert » (INSERT … ON CONFLICT DO UPDATE).
--
-- Avec ON CONFLICT DO UPDATE, PostgreSQL vérifie aussi la règle de LECTURE sur
-- la nouvelle ligne. L'ancienne règle passait par private.boutiques_a_rattacher(),
-- qui lit la table et ne voit pas encore la ligne en cours d'insertion : le
-- premier envoi de l'app était refusé (« new row violates row-level security »).
--
-- Nouvelle règle de lecture : sa boutique, ou une boutique à son numéro
-- confirmé qui n'a encore aucun utilisateur, vérifiée sur la ligne elle-même.
-- Même portée qu'avant : un numéro réattribué ne donne pas accès à une
-- boutique qui a déjà son propriétaire.
-- =============================================================================

-- Vrai si la boutique a déjà au moins un utilisateur. SECURITY DEFINER pour
-- voir les utilisateurs des autres (cachés par RLS) ; ne renvoie qu'un booléen,
-- vit dans le schéma private (non exposé par l'API).
create function private.boutique_a_un_utilisateur(boutique uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.utilisateurs u where u.boutique_id = boutique
  )
$$;

revoke all on function private.boutique_a_un_utilisateur(uuid) from public, anon, authenticated;
grant execute on function private.boutique_a_un_utilisateur(uuid) to authenticated;

drop policy "boutiques : lire la sienne" on public.boutiques;

create policy "boutiques : lire la sienne" on public.boutiques
  for select to authenticated
  using (
    id in (select private.mes_boutiques())
    or (
      telephone = (select private.mon_telephone_confirme())
      and not private.boutique_a_un_utilisateur(id)
    )
  );

-- -----------------------------------------------------------------------------
-- Même cause pour utilisateurs : avec ON CONFLICT DO UPDATE, la règle de
-- création est vérifiée sur la ligne proposée même quand elle existe déjà.
-- Au deuxième envoi (PIN changé…), la boutique n'est plus « à rattacher » :
-- on accepte aussi sa propre ligne dans sa propre boutique. Rien de plus :
-- id = auth.uid() existe déjà, l'insertion devient forcément une mise à jour,
-- elle-même limitée par « utilisateurs : modifier sa ligne ».
-- -----------------------------------------------------------------------------
drop policy "utilisateurs : créer sa ligne" on public.utilisateurs;

create policy "utilisateurs : créer sa ligne" on public.utilisateurs
  for insert to authenticated
  with check (
    id = (select auth.uid())
    and (
      boutique_id in (select private.boutiques_a_rattacher())
      or boutique_id in (select private.mes_boutiques())
    )
  );
