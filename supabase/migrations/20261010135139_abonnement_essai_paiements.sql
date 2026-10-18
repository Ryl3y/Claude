-- =============================================================================
-- Abonnement Kassa Pro : essai gratuit de 30 jours, puis 5 000 FCFA par mois
-- payés par Mobile Money (Notch Pay).
--
-- - abonnements.date_fin : dernier jour où la boutique peut enregistrer.
--   Créé à la première sauvegarde de la boutique (fin de l'essai), prolongé
--   d'un mois à chaque paiement confirmé.
-- - paiements_abonnement : chaque demande de paiement et son résultat. Écrit
--   seulement par les fonctions du serveur (Edge Functions), lu par l'app.
-- =============================================================================

-- Jour à Douala (UTC+1, sans heure d'été).
create function private.aujourdhui_douala()
returns date
language sql
stable
set search_path = ''
as $$
  select (now() at time zone 'Africa/Douala')::date
$$;

-- Essai : 30 jours à partir de la première sauvegarde de la boutique. La date
-- vient du serveur, pas du téléphone (son horloge peut être changée).
create function private.creer_essai()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.abonnements (boutique_id, formule, date_fin)
  values (new.id, 'gratuit', private.aujourdhui_douala() + 30)
  on conflict (boutique_id) do nothing;
  return new;
end;
$$;

revoke all on function private.aujourdhui_douala() from public, anon, authenticated;
revoke all on function private.creer_essai() from public, anon, authenticated;

create trigger creer_essai after insert on public.boutiques
  for each row execute function private.creer_essai();

-- Boutiques déjà sauvegardées : même essai.
insert into public.abonnements (boutique_id, formule, date_fin)
select b.id, 'gratuit', private.aujourdhui_douala() + 30
from public.boutiques b
on conflict (boutique_id) do nothing;

create table public.paiements_abonnement (
  -- Notre référence, envoyée à Notch Pay (trxref).
  reference text primary key check (reference ~ '^kassa-[0-9a-f-]{36}$'),
  boutique_id uuid not null references public.boutiques (id),
  utilisateur_id uuid not null references auth.users (id),
  montant bigint not null check (montant > 0),
  operateur text not null check (operateur in ('cm.mtn', 'cm.orange')),
  statut text not null default 'en_attente'
    check (statut in ('en_attente', 'reussi', 'echoue')),
  -- Référence de la transaction chez Notch Pay (trx.…).
  reference_notch text,
  cree_le timestamptz not null default now(),
  maj_le timestamptz not null default now()
);
comment on table public.paiements_abonnement is
  'Paiements de l''abonnement Kassa Pro (Notch Pay). Écrit par le serveur.';

create index paiements_abonnement_boutique_idx
  on public.paiements_abonnement (boutique_id, cree_le desc);
create index paiements_abonnement_utilisateur_idx
  on public.paiements_abonnement (utilisateur_id);
create unique index paiements_abonnement_notch_idx
  on public.paiements_abonnement (reference_notch)
  where reference_notch is not null;

revoke all on public.paiements_abonnement from anon, authenticated;
grant select on public.paiements_abonnement to authenticated;
grant select, insert, update on public.paiements_abonnement to service_role;

alter table public.paiements_abonnement enable row level security;

-- Le commerçant voit les paiements de sa boutique ; seul le serveur écrit.
create policy "paiements_abonnement : ma boutique (lire)"
  on public.paiements_abonnement
  for select to authenticated
  using (boutique_id in (select private.mes_boutiques()));

-- Paiement confirmé par Notch Pay : Pro un mois de plus, à partir de la fin
-- de l'abonnement en cours (ou d'aujourd'hui s'il est fini). Sans effet si
-- ce paiement a déjà été compté (Notch Pay peut renvoyer l'événement).
-- Appelée seulement par la fonction serveur notchpay-webhook (service_role).
create function public.confirmer_paiement_abonnement(
  p_reference text,
  p_reference_notch text,
  p_montant bigint
)
returns date
language plpgsql
set search_path = ''
as $$
declare
  paiement public.paiements_abonnement;
  fin date;
begin
  select * into paiement
  from public.paiements_abonnement
  where reference = p_reference
  for update;
  if not found then
    raise exception 'paiement inconnu : %', p_reference;
  end if;
  if paiement.statut = 'reussi' then
    select date_fin into fin from public.abonnements
    where boutique_id = paiement.boutique_id;
    return fin;
  end if;
  if p_montant < paiement.montant then
    raise exception 'montant insuffisant : % < %', p_montant, paiement.montant;
  end if;

  update public.paiements_abonnement
  set statut = 'reussi',
      reference_notch = coalesce(p_reference_notch, reference_notch),
      maj_le = now()
  where reference = p_reference;

  insert into public.abonnements (boutique_id, formule, date_fin)
  values (paiement.boutique_id, 'gratuit', private.aujourdhui_douala())
  on conflict (boutique_id) do nothing;

  update public.abonnements
  set formule = 'pro',
      date_fin = (greatest(
        coalesce(date_fin, private.aujourdhui_douala()),
        private.aujourdhui_douala()
      ) + interval '1 month')::date,
      reference_paiement = p_reference,
      montant = p_montant,
      maj_le = now()
  where boutique_id = paiement.boutique_id
  returning date_fin into fin;
  return fin;
end;
$$;

-- Paiement refusé, annulé ou expiré : noté, l'abonnement ne change pas.
create function public.echouer_paiement_abonnement(p_reference text)
returns void
language sql
set search_path = ''
as $$
  update public.paiements_abonnement
  set statut = 'echoue', maj_le = now()
  where reference = p_reference and statut = 'en_attente'
$$;

revoke all on function public.confirmer_paiement_abonnement(text, text, bigint)
  from public, anon, authenticated;
revoke all on function public.echouer_paiement_abonnement(text)
  from public, anon, authenticated;
grant execute on function public.confirmer_paiement_abonnement(text, text, bigint)
  to service_role;
grant execute on function public.echouer_paiement_abonnement(text)
  to service_role;
grant execute on function private.aujourdhui_douala() to service_role;
grant usage on schema private to service_role;
