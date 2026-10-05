-- B Card initial schema (PRD 5.2). Every table is private to its owner via RLS;
-- the public profile reads only the filtered public_cards view.

create table public.cards (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  slug        text not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$'),
  name        text not null check (char_length(name) between 1 and 80),
  title       text not null default '',
  company     text not null default '',
  phone       text not null default '',
  email       text not null default '',
  website     text not null default '',
  linkedin    text not null default '',
  location    text not null default '',
  bio         text not null default '' check (char_length(bio) <= 280),
  links       jsonb not null default '[]',
  photo_url   text,
  logo_url    text,
  is_public   boolean not null default true,
  hide_phone  boolean not null default false,
  hide_email  boolean not null default false,
  indexable   boolean not null default false, -- search engines off by default (PRD 4.8)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.tags (
  id        uuid primary key default gen_random_uuid(),
  owner_id  uuid not null references auth.users (id) on delete cascade,
  name      text not null check (char_length(name) between 1 and 40),
  colour    text not null default '#1B5E8C',
  unique (owner_id, name)
);

create table public.contacts (
  id              uuid primary key, -- generated on device for offline-first sync
  owner_id        uuid not null references auth.users (id) on delete cascade,
  source          text not null check (source in ('qr', 'manual', 'nfc')),
  source_card_id  uuid references public.cards (id) on delete set null,
  name            text not null,
  title           text not null default '',
  company         text not null default '',
  email           text not null default '',
  phone           text not null default '',
  links           jsonb not null default '[]',
  tag_ids         uuid[] not null default '{}',
  notes           text not null default '',
  scanned_at      timestamptz,
  scan_location   text, -- coarse only, and only if the user opted in
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz -- soft delete so deletions sync to other devices
);

-- The same B Card scanned twice never creates two contacts (PRD 4.4).
create unique index contacts_owner_source_card
  on public.contacts (owner_id, source_card_id)
  where source_card_id is not null and deleted_at is null;

create table public.scan_events (
  id             bigint generated always as identity primary key,
  card_id        uuid not null references public.cards (id) on delete cascade,
  type           text not null check (type in ('view', 'scan', 'save')),
  coarse_region  text,
  created_at     timestamptz not null default now()
);

-- updated_at maintenance
create function public.touch_updated_at() returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger cards_touch before update on public.cards
  for each row execute function public.touch_updated_at();
create trigger contacts_touch before update on public.contacts
  for each row execute function public.touch_updated_at();

-- Row-level security
alter table public.cards enable row level security;
alter table public.tags enable row level security;
alter table public.contacts enable row level security;
alter table public.scan_events enable row level security;

create policy "owners manage their cards" on public.cards
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "owners manage their tags" on public.tags
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "owners manage their contacts" on public.contacts
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
-- Events are written by the profile Edge Function (service role); owners read their own.
create policy "owners read their card events" on public.scan_events
  for select using (exists (
    select 1 from public.cards c where c.id = card_id and c.user_id = auth.uid()
  ));

-- Public profile: only live cards, with hidden fields removed.
create view public.public_cards as
  select
    id, slug, name, title, company, location, bio, website, linkedin, links,
    photo_url, logo_url, indexable, updated_at,
    case when hide_phone then null else nullif(phone, '') end as phone,
    case when hide_email then null else nullif(email, '') end as email
  from public.cards
  where is_public;

revoke all on public.public_cards from anon, authenticated;
grant select on public.public_cards to anon, authenticated;
