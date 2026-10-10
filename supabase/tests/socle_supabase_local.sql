-- Socle minimal qui imite Supabase (rôles, schéma auth) pour tester la
-- migration sur un PostgreSQL local. NE PAS appliquer sur le vrai projet.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
grant anon, authenticated, service_role to postgres;

create schema auth;
create table auth.users (id uuid primary key, phone text, phone_confirmed_at timestamptz);

create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb
$$;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(auth.jwt() ->> 'sub', '')::uuid
$$;

grant usage on schema auth to anon, authenticated, service_role;
grant execute on function auth.jwt(), auth.uid() to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;
