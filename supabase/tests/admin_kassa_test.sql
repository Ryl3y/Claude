-- Tests du côté admin : seuls les admins appellent les fonctions admin_*,
-- les chiffres comptent les vraies boutiques, chaque geste est tracé.
-- Lancer : tool/tester_rls_local.sh
\set ON_ERROR_STOP on

-- Le socle local n'a pas la colonne e-mail de Supabase Auth.
alter table auth.users add column if not exists email text;

create schema if not exists test_admin;
grant usage on schema test_admin to anon, authenticated, service_role;

create function test_admin.egal(obtenu text, attendu text, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;

-- Appelle une requête ; renvoie 'refuse' si l'accès est refusé.
create function test_admin.essayer(requete text) returns text
language plpgsql as $$
begin
  execute requete;
  return 'accepte';
exception when insufficient_privilege then
  return 'refuse';
end;
$$;
grant execute on all functions in schema test_admin to anon, authenticated, service_role;

insert into auth.users (id, phone, phone_confirmed_at, email) values
  ('adadadad-0000-4000-8000-000000000001', null, null, 'rich@kassa.cm'),
  ('cccccccc-0000-4000-8000-000000000008', '237690000008', now(), null);
insert into public.admins (utilisateur_id, email)
values ('adadadad-0000-4000-8000-000000000001', 'rich@kassa.cm');

-- Une boutique réelle (H) et une boutique provisoire (jamais comptée).
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id) values
  ('c0000000-0000-4000-8000-000000000001', 'Boutique H', '237690000008', ' douala ', 'Akwa', 'alimentation', 5, now(), now(), 'tel-h'),
  ('c0000000-0000-4000-8000-000000000002', 'Kassa', '000000000', '', '', '', 5, now(), now(), 'tel-x');
insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
values ('cccccccc-0000-4000-8000-000000000008', 'c0000000-0000-4000-8000-000000000001', '', '237690000008', 'pbkdf2', now(), 'tel-h');
insert into public.paiements_abonnement (reference, boutique_id, utilisateur_id, montant, operateur, statut, maj_le)
values ('kassa-00000000-0000-4000-8000-000000000081', 'c0000000-0000-4000-8000-000000000001',
        'cccccccc-0000-4000-8000-000000000008', 5000, 'cm.mtn', 'reussi', now());

-- Un commerçant n'a accès à rien.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"cccccccc-0000-4000-8000-000000000008","phone":"237690000008","role":"authenticated"}';
select test_admin.egal(public.admin_moi()::text, 'false', 'commerçant : pas admin');
select test_admin.egal(test_admin.essayer('select public.admin_chiffres()'), 'refuse', 'commerçant : chiffres refusés');
select test_admin.egal(test_admin.essayer('select * from public.admin_boutiques()'), 'refuse', 'commerçant : boutiques refusées');
select test_admin.egal(test_admin.essayer('select * from public.admin_paiements()'), 'refuse', 'commerçant : paiements refusés');
select test_admin.egal(test_admin.essayer('select * from public.admin_zones()'), 'refuse', 'commerçant : zones refusées');
select test_admin.egal(
  test_admin.essayer($q$select public.admin_ajuster_abonnement('c0000000-0000-4000-8000-000000000001', 30, 'pro', 'triche')$q$),
  'refuse', 'commerçant : ne se prolonge pas lui-même');
select test_admin.egal(test_admin.essayer('select * from public.admins'), 'refuse', 'commerçant : liste des admins illisible');
commit;

-- Anonyme : aucune fonction admin.
begin;
set local role anon;
select test_admin.egal(test_admin.essayer('select public.admin_chiffres()'), 'refuse', 'anonyme : refusé');
commit;

-- L'admin voit les chiffres des vraies boutiques.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"adadadad-0000-4000-8000-000000000001","email":"rich@kassa.cm","role":"authenticated"}';
select test_admin.egal(public.admin_moi()::text, 'true', 'admin reconnu');
select test_admin.egal(
  ((public.admin_chiffres() ->> 'boutiques')::int >= 1
   and not exists (
     select 1 from public.admin_boutiques('Kassa') where telephone = '000000000'
   ))::text,
  'true', 'boutiques provisoires jamais comptées');
select test_admin.egal(
  ((public.admin_chiffres() ->> 'revenus_mois')::bigint >= 5000)::text, 'true', 'revenus du mois');
select test_admin.egal(
  jsonb_array_length(public.admin_chiffres() -> 'inscriptions')::text, '30', 'courbe des inscriptions : 30 jours');
select test_admin.egal(
  jsonb_array_length(public.admin_chiffres() -> 'revenus')::text, '6', 'courbe des revenus : 6 mois');
select test_admin.egal(
  (select nom from public.admin_boutiques('boutique h')), 'Boutique H', 'recherche d''une boutique');
select test_admin.egal(
  (select count(*)::text from public.admin_paiements('reussi') where reference = 'kassa-00000000-0000-4000-8000-000000000081'),
  '1', 'paiements réussis listés');
select test_admin.egal(
  ((select boutiques from public.admin_zones() where ville = 'Douala') >= 1)::text, 'true', 'zones : ville nettoyée (« Douala »)');
commit;

-- Geste commercial : 10 jours de Pro offerts, tracés.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"adadadad-0000-4000-8000-000000000001","email":"rich@kassa.cm","role":"authenticated"}';
select test_admin.egal(
  (public.admin_ajuster_abonnement('c0000000-0000-4000-8000-000000000001', 10, 'pro', 'Geste commercial : panne réseau')
   >= (now() at time zone 'Africa/Douala')::date + 10)::text,
  'true', 'Pro prolongé de 10 jours');
select test_admin.egal(
  (select formule from public.admin_boutiques('Boutique H')), 'pro', 'formule Pro après le geste');
select test_admin.egal(
  (select admin_email || ' / ' || jours || ' / ' || motif from public.admin_ajustements('c0000000-0000-4000-8000-000000000001')),
  'rich@kassa.cm / 10 / Geste commercial : panne réseau', 'geste tracé (qui, combien, pourquoi)');
-- Des jours d'essai offerts ne retirent pas le Pro en cours.
select public.admin_ajuster_abonnement('c0000000-0000-4000-8000-000000000001', 5, 'gratuit', 'Jours offerts');
select test_admin.egal(
  (select formule from public.admin_boutiques('Boutique H')), 'pro', 'jours d''essai offerts : Pro gardé');
select test_admin.egal(
  (select formule from public.admin_ajustements('c0000000-0000-4000-8000-000000000001') limit 1),
  'pro', 'historique : formule réellement appliquée');
select test_admin.egal(
  (select count(*)::text from public.admin_boutiques('%')), '0', 'recherche « % » prise telle quelle');
select test_admin.egal(
  (select ventes::text from public.admin_boutiques('Boutique H')), '0', 'ventes comptées pour la page');
commit;

do $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config('request.jwt.claims', '{"sub":"adadadad-0000-4000-8000-000000000001","role":"authenticated"}', true);
  perform public.admin_ajuster_abonnement('c0000000-0000-4000-8000-000000000001', 0, 'pro', 'zéro jour');
  raise exception 'ÉCHEC : 0 jour accepté';
exception when invalid_parameter_value then
  raise notice 'OK (refusé comme prévu) : nombre de jours invalide';
end $$;
do $$
begin
  perform set_config('role', 'authenticated', true);
  perform set_config('request.jwt.claims', '{"sub":"adadadad-0000-4000-8000-000000000001","role":"authenticated"}', true);
  perform public.admin_ajuster_abonnement('c0000000-0000-4000-8000-000000000001', 3, 'pro', ' ');
  raise exception 'ÉCHEC : motif vide accepté';
exception when invalid_parameter_value then
  raise notice 'OK (refusé comme prévu) : motif obligatoire';
end $$;
