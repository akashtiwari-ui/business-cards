-- Nearby (Beacon mode): phones broadcast a random, short-lived token over
-- Bluetooth instead of any personal data. Only signed-in B Card users can turn
-- a token into the public fields of a live card.

create table public.beacon_tokens (
  token       text primary key check (token ~ '^[0-9a-f]{16}$'),
  card_id     uuid not null references public.cards (id) on delete cascade,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null check (expires_at <= created_at + interval '12 hours')
);

create index beacon_tokens_card on public.beacon_tokens (card_id);

alter table public.beacon_tokens enable row level security;

create policy "owners manage tokens for their cards" on public.beacon_tokens
  for all
  using (exists (select 1 from public.cards c where c.id = card_id and c.user_id = auth.uid()))
  with check (exists (select 1 from public.cards c where c.id = card_id and c.user_id = auth.uid()));

-- Tokens -> public card fields. Hidden cards are excluded by public_cards.
create function public.resolve_beacon_tokens(p_tokens text[])
returns table (token text, card_id uuid, slug text, name text, title text, company text)
language sql
stable
security definer
set search_path = ''
as $$
  select t.token, p.id, p.slug, p.name, p.title, p.company
  from public.beacon_tokens t
  join public.public_cards p on p.id = t.card_id
  where t.token = any (p_tokens[1:50])
    and t.expires_at > now();
$$;

revoke all on function public.resolve_beacon_tokens(text[]) from public, anon;
grant execute on function public.resolve_beacon_tokens(text[]) to authenticated;
