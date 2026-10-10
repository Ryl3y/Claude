-- Tests du contrôle serveur : lecture seule après l'abonnement, et une
-- seule demande de paiement en attente à la fois.
-- Lancer : tool/tester_rls_local.sh
\set ON_ERROR_STOP on

create schema if not exists test_controle;
grant usage on schema test_controle to authenticated, service_role;

create function test_controle.egal(obtenu text, attendu text, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;

-- Écrit un produit comme le commerçant connecté ; renvoie 'accepte' ou le
-- message d'erreur.
create function test_controle.ecrire(p_id uuid, p_boutique uuid, p_maj timestamptz) returns text
language plpgsql as $$
begin
  insert into public.produits (id, boutique_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
  values (p_id, p_boutique, 'Savon', 200, 250, 'pièce', 0, p_maj, 'tel-g');
  return 'accepte';
exception when others then
  return sqlerrm;
end;
$$;
grant execute on all functions in schema test_controle to authenticated, service_role;

insert into auth.users (id, phone, phone_confirmed_at) values
  ('99999999-0000-4000-8000-000000000007', '237690000007', now());

-- La boutique G se sauvegarde : essai en cours, elle écrit normalement.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, appareil_id)
values ('90000000-0000-4000-8000-000000000001', 'Boutique G', '237690000007', 'Yaoundé', 'Bastos', 'alimentation', 5, now(), now(), 'tel-g');
insert into public.utilisateurs (id, boutique_id, nom, telephone, code_pin, maj_le, appareil_id)
values ('99999999-0000-4000-8000-000000000007', '90000000-0000-4000-8000-000000000001', '', '237690000007', 'pbkdf2', now(), 'tel-g');
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000001', '90000000-0000-4000-8000-000000000001', now()),
  'accepte', 'essai en cours : écriture acceptée');
commit;

-- L'essai s'est terminé il y a 2 jours.
update public.abonnements
set date_fin = (now() at time zone 'Africa/Douala')::date - 2
where boutique_id = '90000000-0000-4000-8000-000000000001';

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000002', '90000000-0000-4000-8000-000000000001', now()),
  'abonnement_termine', 'essai terminé : nouvelle écriture refusée');
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000003', '90000000-0000-4000-8000-000000000001', now() - interval '3 days'),
  'accepte', 'écriture faite pendant l''essai, envoyée en retard : acceptée');
commit;

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
-- Modifier (supprimer) un produit existant est aussi une écriture.
do $$
begin
  update public.produits set supprime_le = now(), maj_le = now()
  where id = '92000000-0000-4000-8000-000000000001';
  raise exception 'ÉCHEC : modification acceptée après l''essai';
exception when raise_exception then
  if sqlerrm like 'ÉCHEC%' then raise; end if;
  raise notice 'OK (refusé comme prévu) : modification après l''essai';
end $$;
-- Le profil et le code PIN restent modifiables.
update public.utilisateurs set code_pin = 'pbkdf2-nouveau', maj_le = now()
where id = '99999999-0000-4000-8000-000000000007';
select test_controle.egal(
  (select code_pin from public.utilisateurs where id = '99999999-0000-4000-8000-000000000007'),
  'pbkdf2-nouveau', 'code PIN modifiable après l''essai');
commit;

-- L'essai s'est terminé il y a 10 jours : même une écriture datée d'avant
-- la fin est refusée (horloge du téléphone reculée).
update public.abonnements
set date_fin = (now() at time zone 'Africa/Douala')::date - 10
where boutique_id = '90000000-0000-4000-8000-000000000001';
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000004', '90000000-0000-4000-8000-000000000001', now() - interval '11 days'),
  'abonnement_termine', 'écriture antidatée de plus de 7 jours : refusée');
commit;

-- Le serveur (service_role) n'est pas bloqué.
begin;
set local role service_role;
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000005', '90000000-0000-4000-8000-000000000001', now()),
  'accepte', 'fonctions du serveur non bloquées');
commit;

-- Pro payé : on écrit de nouveau.
update public.abonnements
set formule = 'pro', date_fin = (now() at time zone 'Africa/Douala')::date + 30
where boutique_id = '90000000-0000-4000-8000-000000000001';
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
select test_controle.egal(
  test_controle.ecrire('92000000-0000-4000-8000-000000000006', '90000000-0000-4000-8000-000000000001', now()),
  'accepte', 'Pro en cours : écriture acceptée');
commit;

-- Une seule demande de paiement en attente à la fois.
begin;
set local role service_role;
select test_controle.egal(
  public.reserver_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000071',
    '90000000-0000-4000-8000-000000000001', '99999999-0000-4000-8000-000000000007', 5000, 'cm.mtn', 300)::text,
  'true', 'première demande de paiement réservée');
select test_controle.egal(
  public.reserver_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000072',
    '90000000-0000-4000-8000-000000000001', '99999999-0000-4000-8000-000000000007', 5000, 'cm.orange', 300)::text,
  'false', 'deuxième demande pendant l''attente : refusée');
commit;
update public.paiements_abonnement set cree_le = now() - interval '6 minutes'
where reference = 'kassa-00000000-0000-4000-8000-000000000071';
begin;
set local role service_role;
select test_controle.egal(
  public.reserver_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000073',
    '90000000-0000-4000-8000-000000000001', '99999999-0000-4000-8000-000000000007', 5000, 'cm.orange', 300)::text,
  'true', 'nouvelle demande après 5 minutes : acceptée');
commit;

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"99999999-0000-4000-8000-000000000007","phone":"237690000007","role":"authenticated"}';
do $$
begin
  perform public.reserver_paiement_abonnement('kassa-00000000-0000-4000-8000-000000000074',
    '90000000-0000-4000-8000-000000000001', '99999999-0000-4000-8000-000000000007', 1, 'cm.mtn', 0);
  raise exception 'ÉCHEC : réservation depuis l''app acceptée';
exception when insufficient_privilege then
  raise notice 'OK (refusé comme prévu) : réserver un paiement depuis l''app';
end $$;
commit;
