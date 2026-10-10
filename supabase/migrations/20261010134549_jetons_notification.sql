-- =============================================================================
-- Jetons Firebase Cloud Messaging : un par téléphone du commerçant, pour lui
-- envoyer des notifications (rappels, abonnement). Table du serveur seulement,
-- pas dans la base du téléphone. Aucune donnée métier.
-- =============================================================================
create table public.jetons_notification (
  utilisateur_id uuid not null references auth.users (id),
  appareil_id text not null,
  boutique_id uuid not null references public.boutiques (id),
  jeton text not null check (length(jeton) > 0),
  -- Langue des notifications (celle de l'app sur ce téléphone).
  langue text not null default 'fr' check (langue in ('fr', 'en')),
  maj_le timestamptz not null default now(),
  primary key (utilisateur_id, appareil_id)
);
comment on table public.jetons_notification is
  'Jeton FCM de chaque téléphone connecté, pour les notifications.';

create index jetons_notification_boutique_idx
  on public.jetons_notification (boutique_id);

revoke all on public.jetons_notification from anon, authenticated;
grant select, insert, update on public.jetons_notification to authenticated;
grant select, insert, update, delete on public.jetons_notification to service_role;

alter table public.jetons_notification enable row level security;

-- Chacun ne lit et n'écrit que les jetons de ses propres téléphones,
-- rattachés à sa boutique.
create policy "jetons_notification : les siens (lire)"
  on public.jetons_notification
  for select to authenticated
  using (utilisateur_id = (select auth.uid()));

create policy "jetons_notification : les siens (créer)"
  on public.jetons_notification
  for insert to authenticated
  with check (
    utilisateur_id = (select auth.uid())
    and boutique_id in (select private.mes_boutiques())
  );

create policy "jetons_notification : les siens (modifier)"
  on public.jetons_notification
  for update to authenticated
  using (utilisateur_id = (select auth.uid()))
  with check (
    utilisateur_id = (select auth.uid())
    and boutique_id in (select private.mes_boutiques())
  );
