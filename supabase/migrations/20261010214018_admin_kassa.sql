-- =============================================================================
-- Côté admin (équipe Kassa) : tableau de bord web.
--
-- - admins : comptes Supabase (e-mail et mot de passe) de l'équipe. Ajoutés à
--   la main (SQL ou tableau de bord), jamais depuis une app.
-- - Les admins ne lisent pas les tables des boutiques directement : ils
--   passent par les fonctions admin_* ci-dessous, qui vérifient d'abord que
--   l'appelant est admin, et ne renvoient que des chiffres et des fiches de
--   boutique (pas le détail des ventes ni les clients des commerçants).
-- - ajustements_abonnement : trace de chaque geste commercial (qui, quand,
--   combien de jours, pourquoi).
-- =============================================================================

create table public.admins (
  utilisateur_id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  cree_le timestamptz not null default now()
);
comment on table public.admins is
  'Équipe Kassa : accès au tableau de bord admin. Géré à la main.';

alter table public.admins enable row level security;
revoke all on public.admins from anon, authenticated;
-- Aucune règle RLS : ni les apps ni les admins ne lisent cette table
-- directement (seules les fonctions ci-dessous).

create table public.ajustements_abonnement (
  id bigint generated always as identity primary key,
  boutique_id uuid not null references public.boutiques (id),
  admin_id uuid not null references auth.users (id),
  jours integer not null check (jours between 1 and 366),
  formule text not null check (formule in ('gratuit', 'pro')),
  ancienne_fin date,
  nouvelle_fin date not null,
  motif text not null check (length(btrim(motif)) between 3 and 500),
  cree_le timestamptz not null default now()
);
comment on table public.ajustements_abonnement is
  'Jours offerts ou Pro prolongé à la main par un admin (trace).';

create index ajustements_abonnement_boutique_idx
  on public.ajustements_abonnement (boutique_id, cree_le desc);
create index ajustements_abonnement_admin_idx
  on public.ajustements_abonnement (admin_id);
create index paiements_abonnement_statut_idx
  on public.paiements_abonnement (statut, cree_le desc);

alter table public.ajustements_abonnement enable row level security;
revoke all on public.ajustements_abonnement from anon, authenticated;

-- -----------------------------------------------------------------------------
-- Contrôle d'accès
-- -----------------------------------------------------------------------------

create function private.est_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admins where utilisateur_id = (select auth.uid())
  )
$$;

create function private.exiger_admin()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not private.est_admin() then
    raise exception 'admin_requis' using errcode = '42501';
  end if;
end;
$$;

revoke all on function private.est_admin() from public, anon, authenticated;
revoke all on function private.exiger_admin() from public, anon, authenticated;

-- Le compte connecté est-il admin ? (écran de connexion de l'admin)
create function public.admin_moi()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.est_admin()
$$;

-- -----------------------------------------------------------------------------
-- Tableau de bord : chiffres clés et courbes
-- -----------------------------------------------------------------------------

create function public.admin_chiffres()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  aujourdhui date := private.aujourdhui_douala();
  debut_mois date := date_trunc('month', aujourdhui)::date;
  resultat jsonb;
begin
  perform private.exiger_admin();
  with boutiques as (
    -- Boutiques réelles (pas les données provisoires d'avant l'inscription).
    select b.id, b.cree_le from public.boutiques b
    where b.supprime_le is null and b.telephone <> '000000000'
  ),
  etats as (
    select a.formule, a.date_fin from public.abonnements a
    join boutiques b on b.id = a.boutique_id
  ),
  jours as (
    select generate_series(aujourdhui - 29, aujourdhui, interval '1 day')::date as jour
  ),
  mois as (
    select (date_trunc('month', aujourdhui) - make_interval(months => n))::date as mois
    from generate_series(0, 5) as n
  )
  select jsonb_build_object(
    'boutiques', (select count(*) from boutiques),
    'nouvelles_7_jours', (
      select count(*) from boutiques
      where (cree_le at time zone 'Africa/Douala')::date > aujourdhui - 7
    ),
    'essais', (select count(*) from etats where formule = 'gratuit' and date_fin >= aujourdhui),
    'pro', (select count(*) from etats where formule = 'pro' and date_fin >= aujourdhui),
    'termines', (select count(*) from etats where date_fin < aujourdhui),
    'revenus_mois', (
      select coalesce(sum(p.montant), 0) from public.paiements_abonnement p
      where p.statut = 'reussi'
        and (p.maj_le at time zone 'Africa/Douala')::date >= debut_mois
    ),
    'paiements_mois', (
      select count(*) from public.paiements_abonnement p
      where p.statut = 'reussi'
        and (p.maj_le at time zone 'Africa/Douala')::date >= debut_mois
    ),
    'inscriptions', (
      select jsonb_agg(jsonb_build_object(
        'jour', j.jour,
        'nombre', (
          select count(*) from boutiques b
          where (b.cree_le at time zone 'Africa/Douala')::date = j.jour
        )
      ) order by j.jour)
      from jours j
    ),
    'revenus', (
      select jsonb_agg(jsonb_build_object(
        'mois', m.mois,
        'montant', (
          select coalesce(sum(p.montant), 0) from public.paiements_abonnement p
          where p.statut = 'reussi'
            and date_trunc('month', p.maj_le at time zone 'Africa/Douala')::date = m.mois
        )
      ) order by m.mois)
      from mois m
    )
  ) into resultat;
  return resultat;
end;
$$;

-- -----------------------------------------------------------------------------
-- Boutiques, paiements, zones
-- -----------------------------------------------------------------------------

create function public.admin_boutiques(
  p_recherche text default '',
  p_limite integer default 50,
  p_decalage integer default 0
)
returns table (
  id uuid,
  nom text,
  telephone text,
  ville text,
  quartier text,
  type_commerce text,
  cree_le timestamptz,
  formule text,
  date_fin date,
  derniere_activite timestamptz,
  ventes bigint,
  total bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  motif text := '%' || coalesce(btrim(p_recherche), '') || '%';
begin
  perform private.exiger_admin();
  return query
  select b.id, b.nom, b.telephone, b.ville, b.quartier, b.type_commerce,
         b.cree_le, a.formule, a.date_fin,
         greatest(b.serveur_maj_le, v.derniere) as derniere_activite,
         coalesce(v.nombre, 0) as ventes,
         count(*) over () as total
  from public.boutiques b
  left join public.abonnements a on a.boutique_id = b.id
  left join lateral (
    select max(x.serveur_maj_le) as derniere,
           count(*) filter (where not x.annulee and x.supprime_le is null) as nombre
    from public.ventes x
    where x.boutique_id = b.id
  ) v on true
  where b.supprime_le is null
    and b.telephone <> '000000000'
    and (b.nom ilike motif or b.telephone ilike motif
         or b.ville ilike motif or b.quartier ilike motif)
  order by b.cree_le desc
  limit least(greatest(p_limite, 1), 200)
  offset greatest(p_decalage, 0);
end;
$$;

create function public.admin_paiements(
  p_statut text default null,
  p_limite integer default 50,
  p_decalage integer default 0
)
returns table (
  reference text,
  boutique_id uuid,
  boutique_nom text,
  montant bigint,
  operateur text,
  statut text,
  cree_le timestamptz,
  maj_le timestamptz,
  total bigint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform private.exiger_admin();
  return query
  select p.reference, p.boutique_id, b.nom, p.montant, p.operateur, p.statut,
         p.cree_le, p.maj_le, count(*) over () as total
  from public.paiements_abonnement p
  join public.boutiques b on b.id = p.boutique_id
  where p_statut is null or p.statut = p_statut
  order by p.cree_le desc
  limit least(greatest(p_limite, 1), 200)
  offset greatest(p_decalage, 0);
end;
$$;

-- Boutiques par ville (carte des zones couvertes).
create function public.admin_zones()
returns table (ville text, boutiques bigint, pro bigint)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform private.exiger_admin();
  return query
  select initcap(btrim(b.ville)) as ville,
         count(*) as boutiques,
         count(*) filter (
           where a.formule = 'pro' and a.date_fin >= private.aujourdhui_douala()
         ) as pro
  from public.boutiques b
  left join public.abonnements a on a.boutique_id = b.id
  where b.supprime_le is null and b.telephone <> '000000000'
  group by 1
  order by 2 desc;
end;
$$;

-- -----------------------------------------------------------------------------
-- Gestes commerciaux
-- -----------------------------------------------------------------------------

-- Offre p_jours d'essai (formule 'gratuit') ou de Pro (formule 'pro') à la
-- boutique, à partir de la fin actuelle (ou d'aujourd'hui si elle est
-- passée). Chaque geste est tracé. Renvoie la nouvelle date de fin.
create function public.admin_ajuster_abonnement(
  p_boutique_id uuid,
  p_jours integer,
  p_formule text,
  p_motif text
)
returns date
language plpgsql
security definer
set search_path = ''
as $$
declare
  aujourdhui date := private.aujourdhui_douala();
  ancienne date;
  ancienne_formule text;
  nouvelle date;
begin
  perform private.exiger_admin();
  if p_jours is null or p_jours not between 1 and 366 then
    raise exception 'jours_invalides' using errcode = '22023';
  end if;
  if p_formule is null or p_formule not in ('gratuit', 'pro') then
    raise exception 'formule_invalide' using errcode = '22023';
  end if;
  if p_motif is null or length(btrim(p_motif)) not between 3 and 500 then
    raise exception 'motif_invalide' using errcode = '22023';
  end if;
  if not exists (select 1 from public.boutiques where id = p_boutique_id) then
    raise exception 'boutique_inconnue' using errcode = '22023';
  end if;

  insert into public.abonnements (boutique_id, formule, date_fin)
  values (p_boutique_id, 'gratuit', aujourdhui)
  on conflict (boutique_id) do nothing;

  select date_fin, formule into ancienne, ancienne_formule
  from public.abonnements
  where boutique_id = p_boutique_id
  for update;

  nouvelle := greatest(coalesce(ancienne, aujourdhui), aujourdhui) + p_jours;
  update public.abonnements
  set formule = case
        -- Des jours d'essai offerts ne retirent pas un Pro en cours.
        when p_formule = 'gratuit' and ancienne_formule = 'pro'
             and ancienne >= aujourdhui then 'pro'
        else p_formule
      end,
      date_fin = nouvelle,
      maj_le = now()
  where boutique_id = p_boutique_id;

  insert into public.ajustements_abonnement
    (boutique_id, admin_id, jours, formule, ancienne_fin, nouvelle_fin, motif)
  values
    (p_boutique_id, (select auth.uid()), p_jours, p_formule, ancienne, nouvelle,
     btrim(p_motif));
  return nouvelle;
end;
$$;

-- Historique des gestes pour une boutique (fiche boutique).
create function public.admin_ajustements(p_boutique_id uuid)
returns table (
  cree_le timestamptz,
  admin_email text,
  jours integer,
  formule text,
  ancienne_fin date,
  nouvelle_fin date,
  motif text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform private.exiger_admin();
  return query
  select j.cree_le, ad.email, j.jours, j.formule, j.ancienne_fin,
         j.nouvelle_fin, j.motif
  from public.ajustements_abonnement j
  left join public.admins ad on ad.utilisateur_id = j.admin_id
  where j.boutique_id = p_boutique_id
  order by j.cree_le desc
  limit 50;
end;
$$;

-- Fonctions appelées par le tableau de bord (compte admin connecté).
revoke all on function public.admin_moi() from public, anon;
revoke all on function public.admin_chiffres() from public, anon;
revoke all on function public.admin_boutiques(text, integer, integer) from public, anon;
revoke all on function public.admin_paiements(text, integer, integer) from public, anon;
revoke all on function public.admin_zones() from public, anon;
revoke all on function public.admin_ajuster_abonnement(uuid, integer, text, text) from public, anon;
revoke all on function public.admin_ajustements(uuid) from public, anon;
grant execute on function public.admin_moi() to authenticated;
grant execute on function public.admin_chiffres() to authenticated;
grant execute on function public.admin_boutiques(text, integer, integer) to authenticated;
grant execute on function public.admin_paiements(text, integer, integer) to authenticated;
grant execute on function public.admin_zones() to authenticated;
grant execute on function public.admin_ajuster_abonnement(uuid, integer, text, text) to authenticated;
grant execute on function public.admin_ajustements(uuid) to authenticated;
