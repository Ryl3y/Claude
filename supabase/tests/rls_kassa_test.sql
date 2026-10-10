-- Tests des règles RLS de Kassa : chaque boutique ne voit que ses données.
-- Lancer : tool/tester_rls_local.sh (PostgreSQL local + socle_supabase_local.sql).
\set ON_ERROR_STOP on

create schema test_kassa;
grant usage on schema test_kassa to anon, authenticated;

-- Vérifie qu'une requête échoue.
create function test_kassa.doit_echouer(requete text, cas text) returns void
language plpgsql as $$
begin
  begin
    execute requete;
  exception when others then
    raise notice 'OK (refusé comme prévu) : %', cas;
    return;
  end;
  raise exception 'ÉCHEC : la requête aurait dû être refusée : %', cas;
end;
$$;

-- Vérifie une valeur.
create function test_kassa.egal(obtenu bigint, attendu bigint, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;
grant execute on all functions in schema test_kassa to anon, authenticated;

-- Deux commerçants : A (237690000001) et B (237690000002).
insert into auth.users (id, phone) values
  ('aaaaaaaa-0000-4000-8000-000000000001', '237690000001'),
  ('bbbbbbbb-0000-4000-8000-000000000002', '237690000002');

-- ---------------------------------------------------------------- Commerçant A
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","phone":"237690000001","role":"authenticated"}';

insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id)
values ('a0000000-0000-4000-8000-000000000001', 'Boutique A', '237690000001', 'Douala', 'Akwa', 'alimentation', 5, now(), now(), 'tel-a');

select test_kassa.doit_echouer($q$
  insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id)
  values ('a0000000-0000-4000-8000-000000000009', 'Fausse', '237690000002', 'Douala', 'Bali', 'alimentation', 5, now(), now(), 'tel-a')
$q$, 'créer une boutique au numéro d''un autre');

insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
values ('aaaaaaaa-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A', '237690000001', 'hache', now(), 'tel-a');

insert into public.categories (id, boutique_id, nom, icone, maj_le, appareil_id)
values ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Épicerie', 'grocery', now(), 'tel-a');

insert into public.produits (id, boutique_id, categorie_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
values ('a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001',
        'Riz 5 kg', 3000, 3500, 'sac', 2, '2026-10-10 09:00:00+00', 'tel-a');

insert into public.clients (id, boutique_id, nom, maj_le, appareil_id)
values ('a3000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Maman Brigitte', now(), 'tel-a');

insert into public.ventes (id, boutique_id, numero, client_id, utilisateur_id, total, montant_paye, reste_a_payer, mode_paiement, benefice, date_vente, maj_le, appareil_id)
values ('a4000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 1,
        'a3000000-0000-4000-8000-000000000001', 'aaaaaaaa-0000-4000-8000-000000000001',
        7000, 2000, 5000, 'credit', 1000, now(), now(), 'tel-a');

insert into public.lignes_vente (id, boutique_id, vente_id, produit_id, nom_produit, quantite, prix_unitaire, prix_achat_unitaire, maj_le, appareil_id)
values ('a5000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
        'a4000000-0000-4000-8000-000000000001', 'a2000000-0000-4000-8000-000000000001',
        'Riz 5 kg', 2, 3500, 3000, now(), 'tel-a');

insert into public.versements_dette (id, boutique_id, client_id, montant, mode_paiement, date_versement, maj_le, appareil_id)
values ('a6000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
        'a3000000-0000-4000-8000-000000000001', 1000, 'momo', now(), now(), 'tel-a');

insert into public.mouvements_stock (id, boutique_id, produit_id, type, quantite, reference_id, date_mouvement, maj_le, appareil_id)
values ('a7000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
        'a2000000-0000-4000-8000-000000000001', 'vente', -2, 'a4000000-0000-4000-8000-000000000001', now(), now(), 'tel-a');

select test_kassa.egal((select count(*) from public.produits), 1, 'A voit son produit');
select test_kassa.egal((select count(*) from public.abonnements), 0, 'A ne voit aucun abonnement');

select test_kassa.doit_echouer($q$ delete from public.produits $q$, 'suppression définitive interdite');
select test_kassa.doit_echouer($q$
  insert into public.abonnements (boutique_id, formule) values ('a0000000-0000-4000-8000-000000000001', 'pro')
$q$, 'un commerçant ne peut pas s''offrir Pro');
commit;

-- -------------------------------------------- Règle « maj_le le plus récent gagne »
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","phone":"237690000001","role":"authenticated"}';

-- Version plus ancienne : ignorée.
update public.produits set prix_vente = 1, maj_le = '2026-10-10 08:00:00+00'
where id = 'a2000000-0000-4000-8000-000000000001';
select test_kassa.egal((select prix_vente from public.produits), 3500, 'version plus ancienne ignorée');

-- Version plus récente : appliquée.
update public.produits set prix_vente = 4000, maj_le = '2026-10-10 10:00:00+00'
where id = 'a2000000-0000-4000-8000-000000000001';
select test_kassa.egal((select prix_vente from public.produits), 4000, 'version plus récente appliquée');

-- L'heure serveur est imposée par le serveur.
update public.produits set serveur_maj_le = '2000-01-01', maj_le = '2026-10-10 11:00:00+00'
where id = 'a2000000-0000-4000-8000-000000000001';
select test_kassa.egal(
  (select (serveur_maj_le > '2020-01-01')::int from public.produits), 1,
  'serveur_maj_le fixé par le serveur');
commit;

-- ---------------------------------------------------------------- Commerçant B
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"bbbbbbbb-0000-4000-8000-000000000002","phone":"237690000002","role":"authenticated"}';

select test_kassa.egal((select count(*) from public.boutiques), 0, 'B ne voit pas la boutique de A');
select test_kassa.egal((select count(*) from public.produits), 0, 'B ne voit pas les produits de A');
select test_kassa.egal((select count(*) from public.ventes), 0, 'B ne voit pas les ventes de A');
select test_kassa.egal((select count(*) from public.clients), 0, 'B ne voit pas les clients de A');
select test_kassa.egal((select count(*) from public.utilisateurs), 0, 'B ne voit pas le compte de A');

select test_kassa.doit_echouer($q$
  insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
  values ('bbbbbbbb-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'B', '237690000002', 'x', now(), 'tel-b')
$q$, 'B se rattache à la boutique de A');

select test_kassa.doit_echouer($q$
  insert into public.produits (id, boutique_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
  values ('b2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Intrus', 1, 1, 'pièce', 0, now(), 'tel-b')
$q$, 'B écrit dans la boutique de A');

update public.produits set prix_vente = 1, maj_le = '2030-01-01' where id = 'a2000000-0000-4000-8000-000000000001';
commit;

-- B crée sa boutique, puis tente de lier son produit à une catégorie de A.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"bbbbbbbb-0000-4000-8000-000000000002","phone":"237690000002","role":"authenticated"}';
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id)
values ('b0000000-0000-4000-8000-000000000002', 'Boutique B', '237690000002', 'Douala', 'Bonapriso', 'cosmétique', 3, now(), now(), 'tel-b');
insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
values ('bbbbbbbb-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002', 'B', '237690000002', 'x', now(), 'tel-b');
select test_kassa.egal((select count(*) from public.boutiques), 1, 'B voit seulement sa boutique');
select test_kassa.doit_echouer($q$
  insert into public.produits (id, boutique_id, categorie_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
  values ('b2000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000002',
          'a1000000-0000-4000-8000-000000000001', 'Savon', 200, 250, 'pièce', 0, now(), 'tel-b')
$q$, 'B utilise une catégorie de A');
commit;

-- Après la tentative de B, le produit de A est intact.
select test_kassa.egal((select prix_vente from public.produits where id = 'a2000000-0000-4000-8000-000000000001'), 4000,
  'B n''a pas pu modifier le produit de A');

-- ------------------------------------------------------------------- Anonyme
begin;
set local role anon;
select test_kassa.doit_echouer($q$ select count(*) from public.produits $q$, 'anonyme : aucune lecture');
commit;

\echo 'Tous les tests RLS sont passés.'
