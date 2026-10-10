-- Tests des règles de synchronisation côté serveur, avec les mêmes requêtes
-- que l'app (upsert = INSERT … ON CONFLICT (id) DO UPDATE) et les droits
-- d'un commerçant connecté (RLS).
-- Lancer : tool/tester_rls_local.sh
\set ON_ERROR_STOP on

create schema if not exists test_synchro;
grant usage on schema test_synchro to authenticated;

create function test_synchro.egal(obtenu text, attendu text, cas text) returns void
language plpgsql as $$
begin
  if obtenu is distinct from attendu then
    raise exception 'ÉCHEC : % (obtenu %, attendu %)', cas, obtenu, attendu;
  end if;
  raise notice 'OK : %', cas;
end;
$$;
grant execute on all functions in schema test_synchro to authenticated;

insert into auth.users (id, phone, phone_confirmed_at) values
  ('eeeeeeee-0000-4000-8000-000000000005', '237690000005', now());

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"eeeeeeee-0000-4000-8000-000000000005","phone":"237690000005","role":"authenticated"}';

-- Premier envoi, dans l'ordre de l'app : boutique, utilisateur, produit.
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, supprime_le, appareil_id)
values ('e0000000-0000-4000-8000-000000000001', 'Boutique E', '237690000005', 'Douala', 'Bonapriso', 'alimentation', 5, now(), now(), null, 'tel-e')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;

insert into public.utilisateurs (id, boutique_id, nom, telephone, role, code_pin, maj_le, supprime_le, appareil_id)
values ('eeeeeeee-0000-4000-8000-000000000005', 'e0000000-0000-4000-8000-000000000001', '', '237690000005', 'proprietaire', 'pbkdf2', now(), null, 'tel-e')
on conflict (id) do update set code_pin = excluded.code_pin, maj_le = excluded.maj_le;

insert into public.produits (id, boutique_id, categorie_id, nom, prix_achat, prix_vente, quantite, unite, seuil_alerte, code_barre, maj_le, supprime_le, appareil_id)
values ('e2000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000001', null, 'Riz', 3000, 3500, 10, 'sacs', 2, null,
        '2026-10-10T09:00:00Z', null, 'tel-e')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;
select test_synchro.egal((select nom from public.produits where id = 'e2000000-0000-4000-8000-000000000001'), 'Riz', 'premier envoi accepté');

-- Deuxième envoi des mêmes lignes (passage suivant) : accepté sans erreur.
insert into public.boutiques (id, nom, telephone, ville, quartier, type_commerce, seuil_alerte_defaut, cree_le, maj_le, supprime_le, appareil_id)
values ('e0000000-0000-4000-8000-000000000001', 'Boutique E bis', '237690000005', 'Douala', 'Bonapriso', 'alimentation', 5, now(), now() + interval '1 second', null, 'tel-e')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;
select test_synchro.egal((select nom from public.boutiques where id = 'e0000000-0000-4000-8000-000000000001'), 'Boutique E bis', 'boutique renvoyée et modifiée');

insert into public.utilisateurs (id, boutique_id, nom, telephone, role, code_pin, maj_le, supprime_le, appareil_id)
values ('eeeeeeee-0000-4000-8000-000000000005', 'e0000000-0000-4000-8000-000000000001', '', '237690000005', 'proprietaire', 'pbkdf2-nouveau', now() + interval '1 second', null, 'tel-e')
on conflict (id) do update set code_pin = excluded.code_pin, maj_le = excluded.maj_le;
select test_synchro.egal((select code_pin from public.utilisateurs where id = 'eeeeeeee-0000-4000-8000-000000000005'), 'pbkdf2-nouveau', 'code PIN changé et renvoyé');

-- Version plus ancienne : ignorée, sans erreur.
insert into public.produits (id, boutique_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
values ('e2000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000001', 'Riz ancien', 3000, 3500, 'sacs', 2,
        '2026-10-10T08:00:00Z', 'tel-f')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;
select test_synchro.egal((select nom from public.produits where id = 'e2000000-0000-4000-8000-000000000001'), 'Riz', 'version plus ancienne ignorée');

-- Version plus récente : acceptée.
insert into public.produits (id, boutique_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
values ('e2000000-0000-4000-8000-000000000001', 'e0000000-0000-4000-8000-000000000001', 'Riz parfumé', 3000, 3500, 'sacs', 2,
        '2026-10-10T10:00:00Z', 'tel-f')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;
select test_synchro.egal((select nom from public.produits where id = 'e2000000-0000-4000-8000-000000000001'), 'Riz parfumé', 'version plus récente acceptée');

-- Horloge du téléphone en avance : maj_le ramené à l'heure du serveur.
insert into public.produits (id, boutique_id, nom, prix_achat, prix_vente, unite, seuil_alerte, maj_le, appareil_id)
values ('e2000000-0000-4000-8000-000000000002', 'e0000000-0000-4000-8000-000000000001', 'Sucre', 700, 900, 'kg', 2,
        now() + interval '2 days', 'tel-e')
on conflict (id) do update set nom = excluded.nom, maj_le = excluded.maj_le;
select test_synchro.egal(
  ((select maj_le from public.produits where id = 'e2000000-0000-4000-8000-000000000002') <= now() + interval '5 minutes')::text,
  'true', 'maj_le futur ramené à l''heure du serveur');

-- Téléchargement : repère (serveur_maj_le, id), comme l'app.
select test_synchro.egal(
  (select count(*)::text from public.produits
   where serveur_maj_le > '-infinity'::timestamptz
      or (serveur_maj_le = '-infinity'::timestamptz and id > '00000000-0000-0000-0000-000000000000')),
  '2', 'téléchargement complet de sa boutique');
commit;

-- Jetons de notification : les siens seulement, renvoi (upsert) accepté.
begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"eeeeeeee-0000-4000-8000-000000000005","phone":"237690000005","role":"authenticated"}';
insert into public.jetons_notification (utilisateur_id, appareil_id, boutique_id, jeton, langue)
values ('eeeeeeee-0000-4000-8000-000000000005', 'tel-e', 'e0000000-0000-4000-8000-000000000001', 'jeton-1', 'fr')
on conflict (utilisateur_id, appareil_id) do update set jeton = excluded.jeton;
insert into public.jetons_notification (utilisateur_id, appareil_id, boutique_id, jeton, langue)
values ('eeeeeeee-0000-4000-8000-000000000005', 'tel-e', 'e0000000-0000-4000-8000-000000000001', 'jeton-2', 'en')
on conflict (utilisateur_id, appareil_id) do update set jeton = excluded.jeton, langue = excluded.langue;
select test_synchro.egal((select jeton from public.jetons_notification where appareil_id = 'tel-e'), 'jeton-2', 'jeton renouvelé');
commit;

begin;
set local role authenticated;
set local request.jwt.claims = '{"sub":"aaaaaaaa-0000-4000-8000-000000000001","phone":"237690000001","role":"authenticated"}';
select test_synchro.egal((select count(*)::text from public.jetons_notification), '0', 'jetons des autres invisibles');
do $$
begin
  insert into public.jetons_notification (utilisateur_id, appareil_id, boutique_id, jeton)
  values ('eeeeeeee-0000-4000-8000-000000000005', 'pirate', 'e0000000-0000-4000-8000-000000000001', 'x');
  raise exception 'ÉCHEC : jeton écrit pour un autre';
exception when insufficient_privilege or check_violation then
  raise notice 'OK (refusé comme prévu) : jeton pour un autre compte';
end $$;
do $$
begin
  insert into public.jetons_notification (utilisateur_id, appareil_id, boutique_id, jeton)
  values ('aaaaaaaa-0000-4000-8000-000000000001', 'tel-a', 'e0000000-0000-4000-8000-000000000001', 'x');
  raise exception 'ÉCHEC : jeton rattaché à la boutique d''un autre';
exception when insufficient_privilege or check_violation then
  raise notice 'OK (refusé comme prévu) : jeton dans la boutique d''un autre';
end $$;
commit;
