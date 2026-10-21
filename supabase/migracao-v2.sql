-- Visual Norte v2 — rode UMA vez no Supabase (SQL Editor > New query > Run).
-- Adiciona o campo "Descrição curta" dos projetos do portfólio.
alter table public.media_slots add column if not exists summary text;
