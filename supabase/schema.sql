-- Visual Norte — estrutura do Supabase
-- Rode este arquivo inteiro no Supabase: SQL Editor > New query > colar > Run.
-- Pode rodar de novo sem problema (é idempotente).

-- 1) Quem é administrador -------------------------------------------------
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- 2) O que aparece em cada espaço do site ---------------------------------
-- slot: 'reel' (showreel), 'p-Eventos', 'p-Imobiliário', 'p-Terrenos', 'p-Rural', 'p-Turismo' (painéis)
--       'w1'..'w8' (projetos do portfólio)
create table if not exists public.media_slots (
  slot       text primary key,
  path       text,                                   -- caminho do arquivo no bucket
  kind       text check (kind in ('video','image')),
  file_name  text,
  link       text,                                   -- vídeo completo no YouTube/Vimeo (projetos)
  title      text,                                   -- título do projeto
  category   text check (category in ('Eventos','Imobiliário','Terrenos','Rural','Turismo')),
  duration   text,                                   -- ex.: 02:40
  summary    text,                                   -- descrição curta do projeto
  updated_at timestamptz not null default now()
);

alter table public.media_slots add column if not exists summary text;

alter table public.admins      enable row level security;
alter table public.media_slots enable row level security;

-- Função que diz se o usuário logado é admin
create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- Regras: qualquer visitante LÊ os espaços; só admin ESCREVE
drop policy if exists "slots: leitura publica" on public.media_slots;
create policy "slots: leitura publica" on public.media_slots
  for select using (true);

drop policy if exists "slots: admin escreve" on public.media_slots;
create policy "slots: admin escreve" on public.media_slots
  for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins: ve a si mesmo" on public.admins;
create policy "admins: ve a si mesmo" on public.admins
  for select to authenticated using (user_id = auth.uid());

-- 3) Bucket dos vídeos ------------------------------------------------------
-- Público para leitura (o site toca os vídeos pela URL pública).
-- Limite de 50 MB por arquivo (máximo do plano Free).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('videos', 'videos', true, 52428800,
        array['video/mp4','video/webm','video/quicktime','image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Só admin envia, troca e apaga arquivos
drop policy if exists "videos: admin le" on storage.objects;
create policy "videos: admin le" on storage.objects
  for select to authenticated using (bucket_id = 'videos' and public.is_admin());

drop policy if exists "videos: admin envia" on storage.objects;
create policy "videos: admin envia" on storage.objects
  for insert to authenticated with check (bucket_id = 'videos' and public.is_admin());

drop policy if exists "videos: admin atualiza" on storage.objects;
create policy "videos: admin atualiza" on storage.objects
  for update to authenticated using (bucket_id = 'videos' and public.is_admin());

drop policy if exists "videos: admin apaga" on storage.objects;
create policy "videos: admin apaga" on storage.objects
  for delete to authenticated using (bucket_id = 'videos' and public.is_admin());

-- 4) Torne a sua conta admin ----------------------------------------------
-- Depois de criar o seu usuário em Authentication > Users, rode a linha abaixo
-- trocando o e-mail:
-- insert into public.admins (user_id) select id from auth.users where email = 'seu@email.com';
