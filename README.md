# Visual Norte — site + painel de vídeos

Site estático (HTML, sem build) com um painel secreto em `/admin`, protegido por login do Supabase.

```
index.html          site público
config.js           URL e chave pública do Supabase (editar)
admin/index.html    painel: enviar/trocar vídeos, títulos, categorias e links
supabase/schema.sql tabelas, regras de segurança e bucket
robots.txt          impede o Google de indexar /admin
```

## Como funciona a segurança

- O visitante só **lê**: a lista de vídeos (tabela `media_slots`) e os arquivos do bucket público `videos`.
- Gravar na tabela e enviar/apagar arquivos exige **login + estar na tabela `admins`**. Isso é conferido no servidor do Supabase (Row Level Security), não no navegador. Descobrir o endereço `/admin` não dá acesso a nada.
- A chave do `config.js` é a pública (`anon`/`publishable`). Ela pode ficar no site. **Nunca** use a `service_role`/`secret`.

## Passo a passo

### 1. Criar o projeto no Supabase
1. Crie uma conta em supabase.com e um projeto novo (plano Free).
2. Em **SQL Editor > New query**, cole todo o `supabase/schema.sql` e clique em **Run**.

### 2. Criar a sua conta de admin
1. **Authentication > Users > Add user > Create new user**: seu e-mail e uma senha forte. Marque a confirmação automática.
2. Volte ao **SQL Editor** e rode, com o seu e-mail:
   ```sql
   insert into public.admins (user_id) select id from auth.users where email = 'seu@email.com';
   ```
3. Em **Authentication > Sign In / Providers**, **desative o cadastro de novos usuários** (allow new users to sign up). Mesmo que fique ligado, quem se cadastrar não consegue editar nada, porque não está em `admins`.

### 3. Configurar o site
Em **Project Settings > API** (ou **API Keys**), copie a *Project URL* e a chave *anon/publishable* para o `config.js`.

### 4. Publicar
Qualquer hospedagem estática funciona: Vercel, Netlify ou Cloudflare Pages. Envie a pasta inteira (ou conecte um repositório Git), sem comando de build. Depois aponte o seu domínio.

Teste local: `npx serve .` dentro da pasta e abra `http://localhost:3000` e `http://localhost:3000/admin/`.

### 5. Usar o painel
Abra `seudominio.com.br/admin/`, entre e envie os vídeos:
- **Showreel**: vídeo principal, toca com som quando o visitante ativa.
- **Painéis** (5): loops curtos e sem som.
- **Projetos** (8): vídeo de prévia + título, categoria, duração e link do vídeo completo (YouTube/Vimeo).

Tudo o que você salva aparece no site na próxima vez que a página for aberta.

## Limites do plano Free do Supabase
- 1 GB de armazenamento, arquivos de até 50 MB.
- 5 GB de tráfego por mês: cada visita baixa os vídeos que aparecem na tela. Mantenha os loops leves (10–20 s, 1080p, H.264 ~6–8 Mbps, sem áudio nos painéis) e deixe os vídeos longos no YouTube.
- Projetos Free podem ser pausados após 1 semana sem atividade; reative no painel do Supabase se acontecer.
- Se o tráfego crescer, dá para mover só os vídeos para o Cloudflare R2 (sem cobrança de tráfego) mudando a URL em `src()` no `index.html`.

## Trocar textos fixos
Título dos serviços, textos "Sobre", e-mail de contato e afins estão direto no `index.html`. O e-mail `contato@visualnorte.com.br` é provisório.
