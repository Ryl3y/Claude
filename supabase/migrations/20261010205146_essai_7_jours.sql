-- Essai gratuit raccourci à 7 jours pour les nouvelles boutiques.
-- Les essais déjà commencés gardent leur date de fin.
create or replace function private.creer_essai()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.abonnements (boutique_id, formule, date_fin)
  values (new.id, 'gratuit', private.aujourdhui_douala() + 7)
  on conflict (boutique_id) do nothing;
  return new;
end;
$$;
