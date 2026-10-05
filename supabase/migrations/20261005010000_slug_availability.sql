-- Live profile-link availability check (PRD 4.1). Runs as owner so it can see
-- hidden cards too, but only ever returns a boolean.
create function public.is_slug_available(p_slug text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (select 1 from public.cards where slug = lower(p_slug));
$$;

revoke all on function public.is_slug_available(text) from public, anon;
grant execute on function public.is_slug_available(text) to authenticated;
