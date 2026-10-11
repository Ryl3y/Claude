-- =============================================================================
-- Lieux : Région → Département → Arrondissement → Ville ou village → Quartier.
--
-- - regions, departements, arrondissements : découpage officiel (OCHA COD-AB
--   Cameroun v01), aussi embarqué dans l'app (assets/geo/decoupage.json).
-- - localites : villes et villages par arrondissement. Au départ ceux
--   d'OpenStreetMap (© contributeurs OpenStreetMap, ODbL 1.0), puis ceux
--   ajoutés par les commerçants, visibles tout de suite par tous.
-- - quartiers : par localité, ajoutés par les commerçants. Un même nom peut
--   exister dans plusieurs localités (« Haoussa » à Dschang, Koutaba,
--   Bafoussam…) : ce sont des quartiers différents.
-- - Des noms qui ne diffèrent que par les accents, les majuscules ou la
--   ponctuation (« Haoussa », « HAOUSSA », « haoussa ») sont une seule
--   entrée (même cle).
-- - Lecture et ajout seulement par les fonctions lieux_* (compte connecté).
-- =============================================================================

create extension if not exists unaccent with schema extensions;

-- Clé de comparaison : minuscules, sans accents, ponctuation → espace.
create function private.cle_lieu(nom text)
returns text
language sql
stable
set search_path = ''
as $$
  select btrim(regexp_replace(
    lower(extensions.unaccent(coalesce(nom, ''))), '[^a-z0-9]+', ' ', 'g'
  ))
$$;

-- Nom propre : espaces superflus retirés.
create function private.nom_lieu(nom text)
returns text
language sql
immutable
set search_path = ''
as $$
  select btrim(regexp_replace(coalesce(nom, ''), '\s+', ' ', 'g'))
$$;

create table public.regions (
  code text primary key check (code ~ '^CM[0-9]{3}$'),
  nom_fr text not null,
  nom_en text not null
);

create table public.departements (
  code text primary key check (code ~ '^CM[0-9]{6}$'),
  region text not null references public.regions (code),
  nom text not null
);
create index departements_region_idx on public.departements (region);

create table public.arrondissements (
  code text primary key check (code ~ '^CM[0-9]{9}$'),
  departement text not null references public.departements (code),
  nom text not null
);
create index arrondissements_departement_idx
  on public.arrondissements (departement);

create table public.localites (
  id uuid primary key default gen_random_uuid(),
  arrondissement text not null references public.arrondissements (code),
  nom text not null check (length(nom) between 2 and 60),
  cle text not null,
  -- 'osm' : OpenStreetMap ; 'commercant' : ajoutée depuis l'app.
  source text not null default 'commercant' check (source in ('osm', 'commercant')),
  cree_par uuid references auth.users (id) on delete set null,
  cree_le timestamptz not null default now(),
  unique (arrondissement, cle)
);
comment on table public.localites is
  'Villes et villages par arrondissement (OpenStreetMap, ODbL 1.0, et ajouts des commerçants).';
create index localites_source_idx on public.localites (source, cree_le desc);
create index localites_cree_par_idx on public.localites (cree_par);

create table public.quartiers (
  id uuid primary key default gen_random_uuid(),
  localite_id uuid not null references public.localites (id) on delete cascade,
  nom text not null check (length(nom) between 2 and 60),
  cle text not null,
  cree_par uuid references auth.users (id) on delete set null,
  cree_le timestamptz not null default now(),
  unique (localite_id, cle)
);
create index quartiers_cree_le_idx on public.quartiers (cree_le desc);
create index quartiers_cree_par_idx on public.quartiers (cree_par);

-- Nom nettoyé et clé calculés par le serveur, jamais par l'app.
create function private.preparer_lieu()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.nom := private.nom_lieu(new.nom);
  new.cle := private.cle_lieu(new.nom);
  if new.cle = '' then
    raise exception 'nom_invalide' using errcode = '22023';
  end if;
  return new;
end;
$$;

create trigger preparer before insert or update of nom on public.localites
  for each row execute function private.preparer_lieu();
create trigger preparer before insert or update of nom on public.quartiers
  for each row execute function private.preparer_lieu();

alter table public.regions enable row level security;
alter table public.departements enable row level security;
alter table public.arrondissements enable row level security;
alter table public.localites enable row level security;
alter table public.quartiers enable row level security;
revoke all on public.regions, public.departements, public.arrondissements,
  public.localites, public.quartiers from anon, authenticated;

-- La boutique garde son lieu : codes et identifiants (sans clé étrangère :
-- une entrée corrigée par l'équipe ne doit pas bloquer la sauvegarde),
-- et toujours les noms dans ville et quartier.
alter table public.boutiques
  add column arrondissement text check (arrondissement ~ '^CM[0-9]{9}$'),
  add column localite_id uuid,
  add column quartier_id uuid;

-- -----------------------------------------------------------------------------
-- Fonctions de l'app (compte connecté)
-- -----------------------------------------------------------------------------

-- Villes et villages d'un arrondissement, par ordre alphabétique.
create function public.lieux_localites(p_arrondissement text)
returns table (id uuid, nom text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'connexion_requise' using errcode = '42501';
  end if;
  return query
  select l.id, l.nom from public.localites l
  where l.arrondissement = p_arrondissement
  order by l.cle
  limit 5000;
end;
$$;

-- Quartiers d'une localité, par ordre alphabétique.
create function public.lieux_quartiers(p_localite_id uuid)
returns table (id uuid, nom text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    raise exception 'connexion_requise' using errcode = '42501';
  end if;
  return query
  select q.id, q.nom from public.quartiers q
  where q.localite_id = p_localite_id
  order by q.cle
  limit 2000;
end;
$$;

-- Un commerçant ne peut pas ajouter plus de 30 lieux en 24 heures.
create function private.verifier_ajouts()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  n integer;
begin
  if (select auth.uid()) is null then
    raise exception 'connexion_requise' using errcode = '42501';
  end if;
  select (select count(*) from public.localites
          where cree_par = (select auth.uid()) and cree_le > now() - interval '1 day')
       + (select count(*) from public.quartiers
          where cree_par = (select auth.uid()) and cree_le > now() - interval '1 day')
  into n;
  if n >= 30 then
    raise exception 'trop_d_ajouts' using errcode = '54000';
  end if;
end;
$$;

-- Ajoute une ville ou un village (ou renvoie celui qui existe déjà avec
-- les mêmes lettres).
create function public.lieux_ajouter_localite(p_arrondissement text, p_nom text)
returns table (id uuid, nom text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  propre text := private.nom_lieu(p_nom);
begin
  perform private.verifier_ajouts();
  if length(propre) not between 2 and 60 or private.cle_lieu(propre) = '' then
    raise exception 'nom_invalide' using errcode = '22023';
  end if;
  if not exists (select 1 from public.arrondissements x where x.code = p_arrondissement) then
    raise exception 'arrondissement_inconnu' using errcode = '22023';
  end if;
  insert into public.localites (arrondissement, nom, cree_par)
  values (p_arrondissement, propre, (select auth.uid()))
  on conflict (arrondissement, cle) do nothing;
  return query
  select l.id, l.nom from public.localites l
  where l.arrondissement = p_arrondissement
    and l.cle = private.cle_lieu(propre);
end;
$$;

-- Ajoute un quartier à une localité (ou renvoie celui qui existe déjà).
create function public.lieux_ajouter_quartier(p_localite_id uuid, p_nom text)
returns table (id uuid, nom text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  propre text := private.nom_lieu(p_nom);
begin
  perform private.verifier_ajouts();
  if length(propre) not between 2 and 60 or private.cle_lieu(propre) = '' then
    raise exception 'nom_invalide' using errcode = '22023';
  end if;
  if not exists (select 1 from public.localites x where x.id = p_localite_id) then
    raise exception 'localite_inconnue' using errcode = '22023';
  end if;
  insert into public.quartiers (localite_id, nom, cree_par)
  values (p_localite_id, propre, (select auth.uid()))
  on conflict (localite_id, cle) do nothing;
  return query
  select q.id, q.nom from public.quartiers q
  where q.localite_id = p_localite_id
    and q.cle = private.cle_lieu(propre);
end;
$$;

-- -----------------------------------------------------------------------------
-- Admin : corriger les ajouts des commerçants
-- -----------------------------------------------------------------------------

-- Derniers lieux ajoutés depuis l'app (villes, villages et quartiers).
create function public.admin_lieux_ajoutes(
  p_limite integer default 50,
  p_decalage integer default 0
)
returns table (
  type text,
  id uuid,
  nom text,
  localite text,
  arrondissement text,
  departement text,
  cree_le timestamptz,
  boutiques bigint,
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
  with ajouts as (
    select 'localite'::text as type, l.id, l.nom, null::text as localite,
           l.arrondissement as code, l.cree_le
    from public.localites l where l.source = 'commercant'
    union all
    select 'quartier', q.id, q.nom, l.nom, l.arrondissement, q.cree_le
    from public.quartiers q join public.localites l on l.id = q.localite_id
  ),
  page as (
    select a.*, count(*) over () as total from ajouts a
    order by a.cree_le desc
    limit least(greatest(p_limite, 1), 200)
    offset greatest(p_decalage, 0)
  )
  select p.type, p.id, p.nom, p.localite, ar.nom, d.nom, p.cree_le,
         (select count(*) from public.boutiques b
          where b.supprime_le is null
            and (b.localite_id = p.id or b.quartier_id = p.id)),
         p.total
  from page p
  join public.arrondissements ar on ar.code = p.code
  join public.departements d on d.code = ar.departement
  order by p.cree_le desc;
end;
$$;

-- Corrige le nom d'une ville, d'un village ou d'un quartier ajouté.
create function public.admin_renommer_lieu(p_type text, p_id uuid, p_nom text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  propre text := private.nom_lieu(p_nom);
begin
  perform private.exiger_admin();
  if length(propre) not between 2 and 60 or private.cle_lieu(propre) = '' then
    raise exception 'nom_invalide' using errcode = '22023';
  end if;
  begin
    if p_type = 'localite' then
      update public.localites set nom = propre where id = p_id;
      update public.boutiques set ville = propre, maj_le = now()
      where localite_id = p_id;
    elsif p_type = 'quartier' then
      update public.quartiers set nom = propre where id = p_id;
      update public.boutiques set quartier = propre, maj_le = now()
      where quartier_id = p_id;
    else
      raise exception 'type_invalide' using errcode = '22023';
    end if;
  exception when unique_violation then
    raise exception 'nom_existe_deja' using errcode = '23505';
  end;
end;
$$;

-- Retire un ajout (faute, doublon, abus). Les boutiques gardent leur nom
-- de ville et de quartier ; seul le lien vers la liste disparaît.
create function public.admin_supprimer_lieu(p_type text, p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.exiger_admin();
  if p_type = 'localite' then
    -- Seuls les ajouts des commerçants se retirent, pas la liste OSM.
    delete from public.localites where id = p_id and source = 'commercant';
    if found then
      update public.boutiques
      set localite_id = null, quartier_id = null, maj_le = now()
      where localite_id = p_id;
    end if;
  elsif p_type = 'quartier' then
    update public.boutiques set quartier_id = null, maj_le = now()
    where quartier_id = p_id;
    delete from public.quartiers where id = p_id;
  else
    raise exception 'type_invalide' using errcode = '22023';
  end if;
end;
$$;

revoke all on function private.cle_lieu(text) from public, anon, authenticated;
revoke all on function private.nom_lieu(text) from public, anon, authenticated;
revoke all on function private.preparer_lieu() from public, anon, authenticated;
revoke all on function private.verifier_ajouts() from public, anon, authenticated;

revoke all on function public.lieux_localites(text) from public, anon;
revoke all on function public.lieux_quartiers(uuid) from public, anon;
revoke all on function public.lieux_ajouter_localite(text, text) from public, anon;
revoke all on function public.lieux_ajouter_quartier(uuid, text) from public, anon;
revoke all on function public.admin_lieux_ajoutes(integer, integer) from public, anon;
revoke all on function public.admin_renommer_lieu(text, uuid, text) from public, anon;
revoke all on function public.admin_supprimer_lieu(text, uuid) from public, anon;
grant execute on function public.lieux_localites(text) to authenticated;
grant execute on function public.lieux_quartiers(uuid) to authenticated;
grant execute on function public.lieux_ajouter_localite(text, text) to authenticated;
grant execute on function public.lieux_ajouter_quartier(uuid, text) to authenticated;
grant execute on function public.admin_lieux_ajoutes(integer, integer) to authenticated;
grant execute on function public.admin_renommer_lieu(text, uuid, text) to authenticated;
grant execute on function public.admin_supprimer_lieu(text, uuid) to authenticated;
