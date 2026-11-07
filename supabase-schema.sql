-- RESTOQUEUE: skema database Supabase
-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor > New query.
-- app_state: data lengkap, hanya dapat dibaca/ditulis oleh pengguna yang login.
-- monitor_state: salinan data publik terbatas untuk layar monitor (pesanan belum selesai saja).

create table if not exists public.app_state (
  id text primary key check (id = 'main'),
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.monitor_state (
  id text primary key check (id = 'main'),
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;
alter table public.monitor_state enable row level security;

-- Hapus policy bernama sama agar skrip aman dijalankan ulang.
drop policy if exists "Authenticated users can read app state" on public.app_state;
drop policy if exists "Authenticated users can insert app state" on public.app_state;
drop policy if exists "Authenticated users can update app state" on public.app_state;
drop policy if exists "Public can read monitor state" on public.monitor_state;
drop policy if exists "Authenticated users can insert monitor state" on public.monitor_state;
drop policy if exists "Authenticated users can update monitor state" on public.monitor_state;

create policy "Authenticated users can read app state"
  on public.app_state for select to authenticated using (true);
create policy "Authenticated users can insert app state"
  on public.app_state for insert to authenticated with check (true);
create policy "Authenticated users can update app state"
  on public.app_state for update to authenticated using (true) with check (true);

-- Monitor hanya dapat membaca salinan publik yang tidak berisi riwayat pesanan selesai.
create policy "Public can read monitor state"
  on public.monitor_state for select to anon, authenticated using (true);
create policy "Authenticated users can insert monitor state"
  on public.monitor_state for insert to authenticated with check (true);
create policy "Authenticated users can update monitor state"
  on public.monitor_state for update to authenticated using (true) with check (true);

grant select, insert, update on public.app_state to authenticated;
grant select on public.monitor_state to anon, authenticated;
grant insert, update on public.monitor_state to authenticated;

-- Aktifkan Realtime untuk kedua tabel (abaikan jika sudah terdaftar).
do $$
begin
  alter publication supabase_realtime add table public.app_state;
exception when duplicate_object then null;
when undefined_object then
  raise notice 'Publication supabase_realtime belum tersedia; aktifkan Realtime untuk app_state dan monitor_state dari Dashboard.';
end $$;

do $$
begin
  alter publication supabase_realtime add table public.monitor_state;
exception when duplicate_object then null;
when undefined_object then
  raise notice 'Publication supabase_realtime belum tersedia; aktifkan Realtime untuk monitor_state dari Dashboard.';
end $$;
