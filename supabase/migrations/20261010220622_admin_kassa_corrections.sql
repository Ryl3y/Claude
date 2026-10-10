-- Corrections du côté admin (revue de code) :
-- 1. admin_boutiques : la page de boutiques est choisie d'abord, puis les
--    ventes ne sont comptées que pour ces boutiques (plus de calcul sur
--    toutes les ventes à chaque recherche). « % », « _ » et « \ » tapés
--    dans la recherche sont cherchés tels quels.
-- 2. admin_ajuster_abonnement : l'historique garde la formule réellement
--    appliquée (des jours d'essai offerts à un Pro en cours prolongent Pro).

create or replace function public.admin_boutiques(
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
  motif text := '%' || replace(replace(replace(
    coalesce(btrim(p_recherche), ''), '\', '\\'), '%', '\%'), '_', '\_') || '%';
begin
  perform private.exiger_admin();
  return query
  with page as (
    select b.id, b.nom, b.telephone, b.ville, b.quartier, b.type_commerce,
           b.cree_le, b.serveur_maj_le, count(*) over () as total
    from public.boutiques b
    where b.supprime_le is null
      and b.telephone <> '000000000'
      and (b.nom ilike motif or b.telephone ilike motif
           or b.ville ilike motif or b.quartier ilike motif)
    order by b.cree_le desc
    limit least(greatest(p_limite, 1), 200)
    offset greatest(p_decalage, 0)
  )
  select p.id, p.nom, p.telephone, p.ville, p.quartier, p.type_commerce,
         p.cree_le, a.formule, a.date_fin,
         greatest(p.serveur_maj_le, v.derniere) as derniere_activite,
         coalesce(v.nombre, 0) as ventes,
         p.total
  from page p
  left join public.abonnements a on a.boutique_id = p.id
  left join lateral (
    select max(x.serveur_maj_le) as derniere,
           count(*) filter (where not x.annulee and x.supprime_le is null) as nombre
    from public.ventes x
    where x.boutique_id = p.id
  ) v on true
  order by p.cree_le desc;
end;
$$;

create or replace function public.admin_ajuster_abonnement(
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
  appliquee text;
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

  -- Des jours d'essai offerts ne retirent pas un Pro en cours.
  appliquee := case
    when p_formule = 'gratuit' and ancienne_formule = 'pro'
         and ancienne >= aujourdhui then 'pro'
    else p_formule
  end;
  -- Les jours s'ajoutent à la fin en cours (aucun jour perdu) ; offrir du
  -- Pro pendant l'essai fait passer les jours d'essai restants en Pro.
  nouvelle := greatest(coalesce(ancienne, aujourdhui), aujourdhui) + p_jours;
  update public.abonnements
  set formule = appliquee, date_fin = nouvelle, maj_le = now()
  where boutique_id = p_boutique_id;

  insert into public.ajustements_abonnement
    (boutique_id, admin_id, jours, formule, ancienne_fin, nouvelle_fin, motif)
  values
    (p_boutique_id, (select auth.uid()), p_jours, appliquee, ancienne, nouvelle,
     btrim(p_motif));
  return nouvelle;
end;
$$;
