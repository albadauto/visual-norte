// Configuração do site Visual Norte (usada pelo site e pelo painel /admin).
// A chave "publishable" pode ficar pública: quem protege os dados são as regras (RLS) do schema.sql.
// NUNCA coloque aqui a chave "secret" / "service_role".
window.VN_CONFIG = {
  supabaseUrl: "https://ntsfrhtsdichyvlojthi.supabase.co",
  supabaseAnonKey: "sb_publishable_nRSsSOS-qY9ElVm5PI8QDg_N8Uz_nra",
  bucket: "videos",

  // WhatsApp com DDI + DDD + número, só dígitos. Ex.: "5511987654321"
  whatsapp: "",
  // Opcional: Instagram sem @ (deixe "" para esconder)
  instagram: "",
  email: "contato@visualnorte.com.br",
  region: "São Paulo e região",
};
