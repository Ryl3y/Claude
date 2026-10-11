-- Tests des lieux : découpage chargé, villages d'OpenStreetMap, ajouts des
-- commerçants visibles par tous, doublons évités, même nom de quartier dans
-- plusieurs localités, limites, correction par l'admin.
-- Lancer : tool/tester_rls_local.sh
\set ON_ERROR_STOP on

create schema if not exists test_lieux;
grant usage on schema test_lieux to anon, authenticated, service_role;

create function test_lieux.egal(obtenu text, attendu text, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;

create function test_lieux.code_erreur(requete text) returns text
language plpgsql as $$
begin
  execute requete;
  return 'accepte';
exception when others then
  return sqlerrm;
end;
$$;
grant execute on all functions in schema test_lieux to anon, authenticated, service_role;

select test_lieux.egal((select count(*)::text from public.regions), '10', '10 régions');
select test_lieux.egal((select count(*)::text from public.departements), '58', '58 départements');
select test_lieux.egal((select count(*)::text from public.arrondissements), '360', '360 arrondissements');
select test_lieux.egal(
  ((select count(*) from public.localites where source = 'osm') > 10000)::text,
  'true', 'villages d''OpenStreetMap chargés');
select test_lieux.egal(
  (select count(*)::text from public.arrondissements a
   where not exists (select 1 from public.localites l where l.arrondissement = a.code)),
  '0', 'chaque arrondissement a au moins une localité');

insert into auth.users (id, phone, phone_confirmed_at) values
  ('11111111-0000-4000-8000-0000000000a1', '237690000101', now()),
  ('11111111-0000-4000-8000-0000000000a2', '237690000102', now());

-- Un commerçant ajoute un village et un quartier ; un autre les retrouve.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000a1","role":"authenticated"}';
select test_lieux.egal(
  (select nom from public.lieux_ajouter_localite('CM008005001', '  Village   Test  ')),
  'Village Test', 'village ajouté, espaces nettoyés');
select test_lieux.egal(
  (select nom from public.lieux_ajouter_quartier(
     (select id from public.lieux_localites('CM008005001') where nom = 'Dschang'), 'Haoussa')),
  'Haoussa', 'quartier Haoussa ajouté à Dschang');
commit;

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000a2","role":"authenticated"}';
select test_lieux.egal(
  (select count(*)::text from public.lieux_localites('CM008005001') where nom = 'Village Test'),
  '1', 'village visible par un autre commerçant');
select test_lieux.egal(
  (select string_agg(nom, ',') from public.lieux_quartiers(
     (select id from public.lieux_localites('CM008005001') where nom = 'Dschang'))),
  'Haoussa', 'quartier proposé à un autre commerçant');
-- Même nom autrement écrit : pas de doublon, l'entrée existante revient.
select test_lieux.egal(
  (select nom from public.lieux_ajouter_quartier(
     (select id from public.lieux_localites('CM008005001') where nom = 'Dschang'), 'HAOUSSA ')),
  'Haoussa', 'même nom en majuscules : pas de doublon');
select test_lieux.egal(
  (select nom from public.lieux_ajouter_localite('CM008005001', 'village-test')),
  'Village Test', 'même village avec un tiret : pas de doublon');
-- Haoussa existe aussi à Koutaba : c'est un autre quartier.
select test_lieux.egal(
  (select nom from public.lieux_ajouter_quartier(
     (select id from public.lieux_localites('CM008008005') where nom = 'Koutaba'), 'Haoussa')),
  'Haoussa', 'Haoussa ajouté aussi à Koutaba');
commit;

select test_lieux.egal(
  (select count(*)::text from public.quartiers where cle = 'haoussa'),
  '2', 'deux quartiers Haoussa, dans deux localités');

-- Saisies refusées.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000a2","role":"authenticated"}';
select test_lieux.egal(
  test_lieux.code_erreur($q$select public.lieux_ajouter_localite('CM008005001', ' - ')$q$),
  'nom_invalide', 'nom sans lettre refusé');
select test_lieux.egal(
  test_lieux.code_erreur($q$select public.lieux_ajouter_localite('CM999999999', 'Ailleurs')$q$),
  'arrondissement_inconnu', 'arrondissement inconnu refusé');
select test_lieux.egal(
  test_lieux.code_erreur($q$select * from public.localites$q$),
  'permission denied for table localites', 'table lue seulement par les fonctions');
commit;

begin;
set local role anon;
select test_lieux.egal(
  test_lieux.code_erreur($q$select * from public.lieux_localites('CM008005001')$q$),
  'permission denied for function lieux_localites', 'anonyme : refusé');
commit;

-- 30 ajouts au plus en 24 heures.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000a1","role":"authenticated"}';
do $$
begin
  for i in 1..30 loop
    perform public.lieux_ajouter_localite('CM008006001', 'Essai ' || i);
  end loop;
  raise exception 'ÉCHEC : 31e ajout accepté';
exception when program_limit_exceeded then
  raise notice 'OK (refusé comme prévu) : plus de 30 ajouts en 24 heures';
end $$;
commit;

-- L'admin voit les ajouts, corrige et supprime.
alter table auth.users add column if not exists email text;
insert into auth.users (id, email) values ('11111111-0000-4000-8000-0000000000ad', 'equipe@kassa.cm');
insert into public.admins (utilisateur_id, email) values ('11111111-0000-4000-8000-0000000000ad', 'equipe@kassa.cm');
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000ad","role":"authenticated"}';
select test_lieux.egal(
  (select count(*)::text from public.admin_lieux_ajoutes(200) where type = 'quartier' and nom = 'Haoussa'),
  '2', 'admin : ajouts listés avec leur localité');
select test_lieux.egal(
  (select departement from public.admin_lieux_ajoutes(200) where localite = 'Koutaba'),
  'Noun', 'admin : département affiché');
select public.admin_renommer_lieu('localite',
  (select id from public.admin_lieux_ajoutes(200) where nom = 'Village Test'), 'Village Témoin');
select public.admin_supprimer_lieu('quartier',
  (select id from public.admin_lieux_ajoutes(200) where localite = 'Koutaba'));
commit;

select test_lieux.egal(
  (select count(*)::text from public.localites where nom = 'Village Témoin'), '1', 'admin : nom corrigé');
select test_lieux.egal(
  (select count(*)::text from public.quartiers where cle = 'haoussa'), '1', 'admin : ajout supprimé');

-- Un village de la liste OSM ne se supprime pas ; un ajout, si.
begin;
select set_config('test.osm', (select id::text from public.localites
  where arrondissement = 'CM008005001' and cle = 'dschang'), true);
select set_config('test.ajout', (select id::text from public.localites
  where nom = 'Village Témoin'), true);
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000ad","role":"authenticated"}';
select public.admin_supprimer_lieu('localite', current_setting('test.osm')::uuid);
select public.admin_supprimer_lieu('localite', current_setting('test.ajout')::uuid);
commit;
select test_lieux.egal(
  (select count(*)::text from public.localites where arrondissement = 'CM008005001' and cle = 'dschang'),
  '1', 'admin : village OSM gardé');
select test_lieux.egal(
  (select count(*)::text from public.localites where nom = 'Village Témoin'), '0', 'admin : village ajouté supprimé');

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"11111111-0000-4000-8000-0000000000a2","role":"authenticated"}';
select test_lieux.egal(
  test_lieux.code_erreur($q$select * from public.admin_lieux_ajoutes()$q$),
  'admin_requis', 'commerçant : pas de correction possible');
commit;
