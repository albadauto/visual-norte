// Configuração do Supabase usada pelo site e pelo painel /admin.
// Pegue os dois valores em: Supabase > Project Settings > API (ou "API Keys").
// A chave "anon" / "publishable" pode ficar pública: quem protege os dados são as regras (RLS) do schema.sql.
// NUNCA coloque aqui a chave "service_role" / "secret".
window.VN_CONFIG = {
  supabaseUrl: "https://ntsfrhtsdichyvlojthi.supabase.co",
  supabaseAnonKey: "sb_publishable_nRSsSOS-qY9ElVm5PI8QDg_N8Uz_nra",
  bucket: "videos",
};
