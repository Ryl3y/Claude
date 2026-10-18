-- =============================================================================
-- Kassa : schéma serveur (sauvegarde des données du téléphone).
--
-- Mêmes tables que la base locale drift, avec boutique_id partout.
-- Chaque utilisateur ne lit et n'écrit que les lignes de sa boutique (RLS).
-- Aucune suppression définitive : supprime_le sert de suppression logique,
-- donc aucun droit DELETE n'est accordé aux utilisateurs.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Rien n'est exposé par défaut : chaque table reçoit ses droits plus bas.
-- -----------------------------------------------------------------------------
alter default privileges for role postgres in schema public
  revoke select, insert, update, delete on tables from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke execute on functions from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke usage, select on sequences from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke execute on functions from public;

-- Schéma non exposé par l'API, pour les fonctions internes.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- -----------------------------------------------------------------------------
-- 1. Fonctions internes
-- -----------------------------------------------------------------------------

-- Garde la version la plus récente (règle « maj_le le plus récent gagne »)
-- et date chaque écriture avec l'heure du serveur (serveur_maj_le), qui sert
-- de repère pour le téléchargement : l'heure du téléphone peut être fausse.
create function private.horodater_ecriture()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  -- Un téléphone dont l'horloge avance ne doit pas bloquer les corrections
  -- futures : maj_le ne peut pas dépasser l'heure du serveur (+ 5 min de marge).
  if new.maj_le > now() + interval '5 minutes' then
    new.maj_le := now();
  end if;
  if tg_op = 'UPDATE' and new.maj_le < old.maj_le then
    -- Version plus ancienne que celle déjà sauvegardée : on l'ignore.
    return null;
  end if;
  new.serveur_maj_le := now();
  return new;
end;
$$;

revoke all on function private.horodater_ecriture() from public, anon, authenticated;

-- -----------------------------------------------------------------------------
-- 2. Tables
-- Champs de synchronisation sur chaque table : maj_le, supprime_le,
-- appareil_id (venus du téléphone) et serveur_maj_le (heure du serveur).
-- Montants en FCFA entiers (bigint). Dates en UTC (timestamptz).
-- -----------------------------------------------------------------------------

create table public.boutiques (
  id uuid primary key,
  nom text not null check (length(nom) > 0),
  -- Numéro du propriétaire, chiffres seulement (ex. 237690000000).
  telephone text not null check (telephone ~ '^[0-9]{8,15}$'),
  ville text not null,
  quartier text not null,
  type_commerce text not null,
  seuil_alerte_defaut integer not null check (seuil_alerte_defaut >= 0),
  cree_le timestamptz not null,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now()
);
comment on table public.boutiques is 'Une boutique cliente de Kassa.';

create table public.utilisateurs (
  -- Pas de suppression en cascade : l'historique des ventes doit rester.
  -- Pour retirer un compte : supprime_le sur cette ligne, puis bannir le compte Auth.
  id uuid primary key references auth.users (id),
  boutique_id uuid not null references public.boutiques (id),
  nom text not null,
  telephone text not null,
  role text not null default 'proprietaire'
    check (role in ('proprietaire', 'vendeur')),
  -- Code PIN à 4 chiffres, haché sur le téléphone (jamais en clair).
  code_pin text not null,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  unique (boutique_id, id)
);
comment on table public.utilisateurs is 'Compte Supabase Auth relié à une boutique.';

create table public.categories (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  nom text not null check (length(nom) > 0),
  icone text not null,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  unique (boutique_id, id)
);

create table public.produits (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  categorie_id uuid,
  nom text not null check (length(nom) > 0),
  prix_achat bigint not null check (prix_achat >= 0),
  prix_vente bigint not null check (prix_vente >= 0),
  -- Valeur dérivée : chaque téléphone la recalcule depuis mouvements_stock.
  quantite double precision not null default 0,
  unite text not null,
  seuil_alerte double precision not null check (seuil_alerte >= 0),
  photo_locale text,
  code_barre text,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  unique (boutique_id, id),
  foreign key (boutique_id, categorie_id)
    references public.categories (boutique_id, id)
);

create table public.clients (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  nom text not null check (length(nom) > 0),
  telephone text,
  -- Valeur dérivée : ventes à crédit − versements, recalculée sur le téléphone.
  solde_dette bigint not null default 0,
  note text,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  unique (boutique_id, id)
);

create table public.ventes (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  numero integer not null check (numero > 0),
  client_id uuid,
  utilisateur_id uuid not null,
  total bigint not null check (total >= 0),
  montant_paye bigint not null check (montant_paye >= 0),
  reste_a_payer bigint not null check (reste_a_payer >= 0),
  mode_paiement text not null
    check (mode_paiement in ('especes', 'momo', 'orange_money', 'credit')),
  benefice bigint not null,
  date_vente timestamptz not null,
  annulee boolean not null default false,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  unique (boutique_id, id),
  foreign key (boutique_id, client_id)
    references public.clients (boutique_id, id),
  foreign key (boutique_id, utilisateur_id)
    references public.utilisateurs (boutique_id, id)
);

create table public.lignes_vente (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  vente_id uuid not null,
  produit_id uuid not null,
  -- Copies au moment de la vente : un changement de prix ne fausse pas l'historique.
  nom_produit text not null,
  quantite double precision not null check (quantite > 0),
  prix_unitaire bigint not null check (prix_unitaire >= 0),
  prix_achat_unitaire bigint not null check (prix_achat_unitaire >= 0),
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  foreign key (boutique_id, vente_id)
    references public.ventes (boutique_id, id),
  foreign key (boutique_id, produit_id)
    references public.produits (boutique_id, id)
);

create table public.versements_dette (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  client_id uuid not null,
  montant bigint not null check (montant > 0),
  mode_paiement text not null
    check (mode_paiement in ('especes', 'momo', 'orange_money')),
  date_versement timestamptz not null,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  foreign key (boutique_id, client_id)
    references public.clients (boutique_id, id)
);

create table public.mouvements_stock (
  id uuid primary key,
  boutique_id uuid not null references public.boutiques (id),
  produit_id uuid not null,
  type text not null
    check (type in ('entree', 'vente', 'perte', 'correction', 'annulation')),
  -- Positive pour une entrée, négative pour une sortie.
  quantite double precision not null,
  prix_achat_unitaire bigint check (prix_achat_unitaire >= 0),
  -- Vente liée (mouvements « vente » et « annulation »).
  reference_id uuid,
  date_mouvement timestamptz not null,
  maj_le timestamptz not null,
  supprime_le timestamptz,
  appareil_id text not null,
  serveur_maj_le timestamptz not null default now(),
  foreign key (boutique_id, produit_id)
    references public.produits (boutique_id, id)
);

-- Côté serveur seulement : écrit par l'Edge Function de paiement (étape 9).
create table public.abonnements (
  boutique_id uuid primary key references public.boutiques (id),
  formule text not null default 'gratuit' check (formule in ('gratuit', 'pro')),
  date_fin date,
  reference_paiement text,
  montant bigint check (montant >= 0),
  maj_le timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- 2 bis. Boutique de l'utilisateur connecté
--
-- SECURITY DEFINER : lit utilisateurs sans repasser par ses règles RLS, ce qui
-- évite une boucle entre les règles de boutiques et d'utilisateurs. Elle reste
-- sûre : elle ne renvoie que la boutique de auth.uid(), vit dans le schéma
-- private (non exposé par l'API) et seul le rôle authenticated peut l'appeler.
-- -----------------------------------------------------------------------------
create function private.mes_boutiques()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select u.boutique_id
  from public.utilisateurs u
  where u.id = (select auth.uid())
    and u.supprime_le is null
$$;

-- Boutiques que l'utilisateur connecté peut rejoindre : enregistrées à son
-- numéro (confirmé par SMS) et sans aucun utilisateur. Une fois le propriétaire
-- rattaché, le numéro ne donne plus accès : un numéro réattribué par
-- l'opérateur ne permet donc pas de prendre une boutique existante.
create function private.boutiques_a_rattacher()
returns setof uuid
language sql
stable
security definer
set search_path = ''
as $$
  select b.id
  from public.boutiques b
  join auth.users au on au.id = (select auth.uid())
  where au.phone_confirmed_at is not null
    and b.telephone = regexp_replace(coalesce(au.phone, ''), '[^0-9]', '', 'g')
    and not exists (select 1 from public.utilisateurs u where u.boutique_id = b.id)
$$;

-- Numéro confirmé de l'utilisateur connecté (chiffres seulement), ou null.
create function private.mon_telephone_confirme()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select regexp_replace(au.phone, '[^0-9]', '', 'g')
  from auth.users au
  where au.id = (select auth.uid())
    and au.phone_confirmed_at is not null
    and coalesce(au.phone, '') <> ''
$$;

revoke all on function private.mes_boutiques() from public, anon, authenticated;
revoke all on function private.boutiques_a_rattacher() from public, anon, authenticated;
revoke all on function private.mon_telephone_confirme() from public, anon, authenticated;
grant usage on schema private to authenticated;
grant execute on function private.mes_boutiques() to authenticated;
grant execute on function private.boutiques_a_rattacher() to authenticated;
grant execute on function private.mon_telephone_confirme() to authenticated;

-- -----------------------------------------------------------------------------
-- 3. Index : RLS (boutique_id), téléchargement (serveur_maj_le), clés étrangères
-- -----------------------------------------------------------------------------
create index boutiques_serveur_maj_le_idx on public.boutiques (serveur_maj_le);
create index utilisateurs_boutique_idx on public.utilisateurs (boutique_id, serveur_maj_le);
create index categories_boutique_idx on public.categories (boutique_id, serveur_maj_le);
create index produits_boutique_idx on public.produits (boutique_id, serveur_maj_le);
create index produits_categorie_idx on public.produits (boutique_id, categorie_id);
create index clients_boutique_idx on public.clients (boutique_id, serveur_maj_le);
create index ventes_boutique_idx on public.ventes (boutique_id, serveur_maj_le);
create index ventes_client_idx on public.ventes (boutique_id, client_id);
create index ventes_utilisateur_idx on public.ventes (boutique_id, utilisateur_id);
create index lignes_vente_boutique_idx on public.lignes_vente (boutique_id, serveur_maj_le);
create index lignes_vente_vente_idx on public.lignes_vente (boutique_id, vente_id);
create index lignes_vente_produit_idx on public.lignes_vente (boutique_id, produit_id);
create index versements_dette_boutique_idx on public.versements_dette (boutique_id, serveur_maj_le);
create index versements_dette_client_idx on public.versements_dette (boutique_id, client_id);
create index mouvements_stock_boutique_idx on public.mouvements_stock (boutique_id, serveur_maj_le);
create index mouvements_stock_produit_idx on public.mouvements_stock (boutique_id, produit_id);

-- -----------------------------------------------------------------------------
-- 4. Horodatage serveur et règle du plus récent
-- -----------------------------------------------------------------------------
create trigger horodater before insert or update on public.boutiques
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.utilisateurs
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.categories
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.produits
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.clients
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.ventes
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.lignes_vente
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.versements_dette
  for each row execute function private.horodater_ecriture();
create trigger horodater before insert or update on public.mouvements_stock
  for each row execute function private.horodater_ecriture();

-- -----------------------------------------------------------------------------
-- 5. Droits : utilisateurs connectés seulement, jamais anon, jamais DELETE
-- -----------------------------------------------------------------------------
revoke all on public.boutiques, public.utilisateurs, public.categories,
  public.produits, public.clients, public.ventes, public.lignes_vente,
  public.versements_dette, public.mouvements_stock, public.abonnements
  from anon, authenticated;

grant select, insert, update on public.boutiques, public.utilisateurs,
  public.categories, public.produits, public.clients, public.ventes,
  public.lignes_vente, public.versements_dette, public.mouvements_stock
  to authenticated;
grant select on public.abonnements to authenticated;

grant select, insert, update, delete on public.boutiques, public.utilisateurs,
  public.categories, public.produits, public.clients, public.ventes,
  public.lignes_vente, public.versements_dette, public.mouvements_stock,
  public.abonnements
  to service_role;

-- -----------------------------------------------------------------------------
-- 6. Row Level Security : chaque boutique ne voit que ses données
--
-- « Ma boutique » = private.mes_boutiques() (section 2 bis).
-- Les appels sont entourés de (select …) pour n'être évalués qu'une fois.
-- -----------------------------------------------------------------------------
alter table public.boutiques enable row level security;
alter table public.utilisateurs enable row level security;
alter table public.categories enable row level security;
alter table public.produits enable row level security;
alter table public.clients enable row level security;
alter table public.ventes enable row level security;
alter table public.lignes_vente enable row level security;
alter table public.versements_dette enable row level security;
alter table public.mouvements_stock enable row level security;
alter table public.abonnements enable row level security;

-- utilisateurs : chacun ne voit et ne modifie que sa propre ligne.
create policy "utilisateurs : lire sa ligne" on public.utilisateurs
  for select to authenticated
  using (id = (select auth.uid()));

-- On ne peut se rattacher qu'à une boutique enregistrée à son numéro confirmé
-- et encore sans utilisateur (lu dans auth.users, jamais dans user_metadata).
create policy "utilisateurs : créer sa ligne" on public.utilisateurs
  for insert to authenticated
  with check (
    id = (select auth.uid())
    and boutique_id in (select private.boutiques_a_rattacher())
  );

-- Modifier son nom, son PIN… sans changer de boutique.
create policy "utilisateurs : modifier sa ligne" on public.utilisateurs
  for update to authenticated
  using (id = (select auth.uid()))
  with check (
    id = (select auth.uid())
    and boutique_id in (select private.mes_boutiques())
  );

-- boutiques : la sienne, ou celle qu'on vient de créer à son numéro.
create policy "boutiques : lire la sienne" on public.boutiques
  for select to authenticated
  using (
    id in (select private.mes_boutiques())
    or id in (select private.boutiques_a_rattacher())
  );

create policy "boutiques : créer à son numéro" on public.boutiques
  for insert to authenticated
  with check (telephone = (select private.mon_telephone_confirme()));

create policy "boutiques : modifier la sienne" on public.boutiques
  for update to authenticated
  using (id in (select private.mes_boutiques()))
  with check (id in (select private.mes_boutiques()));

-- Tables métier : même règle pour lire, créer et modifier.
create policy "categories : ma boutique (lire)" on public.categories
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "categories : ma boutique (créer)" on public.categories
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "categories : ma boutique (modifier)" on public.categories
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "produits : ma boutique (lire)" on public.produits
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "produits : ma boutique (créer)" on public.produits
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "produits : ma boutique (modifier)" on public.produits
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "clients : ma boutique (lire)" on public.clients
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "clients : ma boutique (créer)" on public.clients
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "clients : ma boutique (modifier)" on public.clients
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "ventes : ma boutique (lire)" on public.ventes
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "ventes : ma boutique (créer)" on public.ventes
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "ventes : ma boutique (modifier)" on public.ventes
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "lignes_vente : ma boutique (lire)" on public.lignes_vente
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "lignes_vente : ma boutique (créer)" on public.lignes_vente
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "lignes_vente : ma boutique (modifier)" on public.lignes_vente
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "versements_dette : ma boutique (lire)" on public.versements_dette
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "versements_dette : ma boutique (créer)" on public.versements_dette
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "versements_dette : ma boutique (modifier)" on public.versements_dette
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

create policy "mouvements_stock : ma boutique (lire)" on public.mouvements_stock
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
create policy "mouvements_stock : ma boutique (créer)" on public.mouvements_stock
  for insert to authenticated
  with check (boutique_id in (select private.mes_boutiques()));
create policy "mouvements_stock : ma boutique (modifier)" on public.mouvements_stock
  for update to authenticated
  using (boutique_id in (select private.mes_boutiques()))
  with check (boutique_id in (select private.mes_boutiques()));

-- abonnements : lecture seule pour la boutique ; écrit par le serveur uniquement.
create policy "abonnements : ma boutique (lire)" on public.abonnements
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));
