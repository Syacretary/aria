create schema if not exists aria_private;

create table if not exists aria_private.provider_config (
  singleton boolean primary key default true check (singleton),
  base_url text not null,
  model text not null,
  allowed_models text[] not null default '{}',
  secret_name text not null,
  max_tokens integer not null default 220 check (max_tokens between 64 and 2048),
  updated_at timestamptz not null default now(),
  constraint provider_base_url_https check (base_url like 'https://%')
);

alter table aria_private.provider_config enable row level security;
revoke all on schema aria_private from public, anon, authenticated;
revoke all on all tables in schema aria_private from public, anon, authenticated;
grant usage on schema aria_private to service_role;
grant select on aria_private.provider_config to service_role;

create table if not exists aria_private.request_limits (
  user_id uuid primary key,
  window_started_at timestamptz not null,
  request_count integer not null default 0
);

alter table aria_private.request_limits enable row level security;
revoke all on aria_private.request_limits from public, anon, authenticated;
grant all on aria_private.request_limits to service_role;

-- Only the Edge Function's service_role can resolve this reference. The
-- provider secret itself lives in Supabase Vault, not in the config table.
create or replace function public.get_aria_provider_config()
returns table (
  base_url text,
  model text,
  allowed_models text[],
  api_key text,
  max_tokens integer
)
language sql
security definer
set search_path = ''
as $$
  select config.base_url,
         config.model,
         config.allowed_models,
         secret.decrypted_secret,
         config.max_tokens
  from aria_private.provider_config as config
  join vault.decrypted_secrets as secret
    on secret.name = config.secret_name
  where config.singleton = true
  limit 1;
$$;

revoke all on function public.get_aria_provider_config() from public, anon, authenticated;
grant execute on function public.get_aria_provider_config() to service_role;

-- Atomic per-user hourly limit. The Edge Function never accepts a user ID
-- from the request body; it passes the ID from the verified JWT.
create or replace function public.consume_aria_request_limit(
  p_user_id uuid,
  p_max_requests integer default 20
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  current_count integer;
  current_window timestamptz := date_trunc('hour', now());
begin
  insert into aria_private.request_limits as limits (
    user_id, window_started_at, request_count
  ) values (p_user_id, current_window, 1)
  on conflict (user_id) do update
    set window_started_at = excluded.window_started_at,
        request_count = case
          when limits.window_started_at = excluded.window_started_at
            then limits.request_count + 1
          else 1
        end
  returning request_count into current_count;

  return current_count <= greatest(1, least(p_max_requests, 60));
end;
$$;

revoke all on function public.consume_aria_request_limit(uuid, integer) from public, anon, authenticated;
grant execute on function public.consume_aria_request_limit(uuid, integer) to service_role;
