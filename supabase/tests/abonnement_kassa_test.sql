-- Tests de l'abonnement : essai créé à la première sauvegarde, paiements
-- visibles seulement par la boutique, confirmation idempotente, droits.
-- Lancer : tool/tester_rls_local.sh
\set ON_ERROR_STOP on

create schema if not exists test_abonnement;
grant usage on schema test_abonnement to authenticated, service_role;

create function test_abonnement.egal(obtenu text, attendu text, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;
grant execute on all functions in schema test_abonnement to authenticated, service_role;

insert into auth.users (id, phone, phone_confirmed_at) values
  ('ffffffff-0000-4000-8000-000000000006', '237690000006', now());

-- La boutique F se sauvegarde : l'essai de 7 jours commence.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"ffffffff-0000-4000-8000-000000000006","phone":"237690000006","role":"authenticated"}';
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id)
values ('f0000000-0000-4000-8000-000000000001', 'Boutique F', '237690000006', 'Douala', 'Deïdo', 'alimentation', 5, now(), now(), 'tel-f');
insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
values ('ffffffff-0000-4000-8000-000000000006', 'f0000000-0000-4000-8000-000000000001', '', '237690000006', 'pbkdf2', now(), 'tel-f');
select test_abonnement.egal(
  (select (date_fin - (now() at time zone 'Africa/Douala')::date)::text
   from public.abonnements where boutique_id = 'f0000000-0000-4000-8000-000000000001'),
  '7', 'essai de 7 jours créé à la première sauvegarde');
select test_abonnement.egal(
  (select formule from public.abonnements where boutique_id = 'f0000000-0000-4000-8000-000000000001'),
  'gratuit', 'formule gratuite pendant l''essai');
do $$
begin
  update public.abonnements set date_fin = '2099-01-01'
  where boutique_id = 'f0000000-0000-4000-8000-000000000001';
  if found then raise exception 'ÉCHEC : le commerçant a prolongé son abonnement'; end if;
  raise notice 'OK (refusé comme prévu) : prolonger soi-même';
exception when insufficient_privilege then
  raise notice 'OK (refusé comme prévu) : prolonger soi-même';
end $$;
do $$
begin
  insert into public.paiements_abonnement (reference, boutique_id, utilisateur_id, montant, operateur)
  values ('kassa-00000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001',
          'ffffffff-0000-4000-8000-000000000006', 1, 'cm.mtn');
  raise exception 'ÉCHEC : paiement inventé par le commerçant';
exception when insufficient_privilege then
  raise notice 'OK (refusé comme prévu) : créer un paiement depuis l''app';
end $$;
do $$
begin
  perform public.confirmer_paiement_abonnement('kassa-x', null, 5000);
  raise exception 'ÉCHEC : confirmation appelée par le commerçant';
exception when insufficient_privilege then
  raise notice 'OK (refusé comme prévu) : confirmer un paiement depuis l''app';
end $$;
commit;

-- Le serveur (Edge Function, service_role) enregistre et confirme.
begin;
set local role service_role;
insert into public.paiements_abonnement (reference, boutique_id, utilisateur_id, montant, operateur)
values ('kassa-00000000-0000-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000001',
        'ffffffff-0000-4000-8000-000000000006', 5000, 'cm.orange');
select test_abonnement.egal(
  (public.confirmer_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000002', 'trx.test', 5000)
   - (now() at time zone 'Africa/Douala')::date >= 35)::text,
  'true', 'paiement pendant l''essai : un mois ajouté après l''essai');
select test_abonnement.egal(
  (select formule from public.abonnements where boutique_id = 'f0000000-0000-4000-8000-000000000001'),
  'pro', 'formule Pro après paiement');
-- Notch Pay renvoie le même événement : rien ne change.
select test_abonnement.egal(
  (select date_fin::text from public.abonnements where boutique_id = 'f0000000-0000-4000-8000-000000000001'),
  public.confirmer_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000002', 'trx.test', 5000)::text,
  'confirmation en double : sans effet');
insert into public.paiements_abonnement (reference, boutique_id, utilisateur_id, montant, operateur)
values ('kassa-00000000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000001',
        'ffffffff-0000-4000-8000-000000000006', 5000, 'cm.mtn');
do $$
begin
  perform public.confirmer_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000003', 'trx.x', 100);
  raise exception 'ÉCHEC : montant trop petit accepté';
exception when raise_exception then
  if sqlerrm like 'ÉCHEC%' then raise; end if;
  raise notice 'OK (refusé comme prévu) : montant plus petit que le prix';
end $$;
select public.echouer_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000003');
select test_abonnement.egal(
  (select statut from public.paiements_abonnement where reference = 'kassa-00000000-0000-4000-8000-000000000003'),
  'echoue', 'paiement refusé noté');
commit;

-- Le commerçant voit ses paiements ; un autre ne voit rien.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"ffffffff-0000-4000-8000-000000000006","phone":"237690000006","role":"authenticated"}';
select test_abonnement.egal((select count(*)::text from public.paiements_abonnement), '2', 'ses paiements visibles');
commit;
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","phone":"237690000001","role":"authenticated"}';
select test_abonnement.egal((select count(*)::text from public.paiements_abonnement), '0', 'paiements des autres invisibles');
select test_abonnement.egal(
  (select count(*)::text from public.abonnements where boutique_id = 'f0000000-0000-4000-8000-000000000001'),
  '0', 'abonnement des autres invisible');
commit;
