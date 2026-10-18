-- Essai de 7 jours, jour de création compris : date_fin (dernier jour où
-- l'on peut enregistrer) = 7e jour, soit aujourd'hui + 6.
create or replace function private.creer_essai()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.abonnements (boutique_id, formule, date_fin)
  values (new.id, 'gratuit', private.aujourdhui_douala() + 6)
  on conflict (boutique_id) do nothing;
  return new;
end;
$$;
