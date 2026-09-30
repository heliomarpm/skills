---
name: _security-appsec
description: Orienta a segurança de aplicações, autenticação moderna (OAuth 2.1, OIDC, JWT, PKCE), controle de acesso (RBAC/ABAC), mitigação de vulnerabilidades OWASP e hardening web.
allowed-tools: Read, Grep, Glob, Bash(npm audit *), Bash(pip audit *), Bash(safety check *), Bash(trivy *), Bash(snyk *)
disallowed-tools: Edit, Write
---

# Global Skill: Application Security (AppSec) & Defensive Engineering

Diretrizes técnicas especializadas para a proteção de aplicações, autenticação moderna com rotação de tokens, autorização granular, criptografia e proteção de infraestrutura web.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_security-appsec``

---

## 1. Processo de Execução de Segurança

Ao implementar autenticação, controle de acesso ou proteção de dados sensíveis:

1. **Autenticação & Gestão Segura de Sessões**:
   - Adote **OAuth 2.1 com PKCE** para clientes públicos (SPA, Mobile) e use **OpenID Connect (OIDC)** para identidade.
   - Utilize Access Tokens de curta duração (15 min) e Refresh Tokens de rotação única (*Refresh Token Rotation*).
2. **Autorização Baseada em Políticas (RBAC / ABAC)**: Nunca confie apenas na presença de um token. Valide permissões no nível de recurso (o usuário X é dono do registro Y?).
3. **Criptografia & Proteção de Segredos**:
   - Senhas devem ser armazenadas exclusivamente com algoritmos modernos adaptativos de hash (**Argon2id** ou **bcrypt** com custo de trabalho adequado).
   - Dados sensíveis em repouso (cartões, documentos) devem usar criptografia autenticada (**AES-256-GCM**).
4. **Hardening de Cabeçalhos HTTP**: Configure cabeçalhos rigorosos (Content-Security-Policy, HSTS, X-Frame-Options, X-Content-Type-Options).
5. **Mitigação de Ataques Comuns**: Proteja contra CSRF em endpoints autenticados por cookies, sanitize saídas contra XSS e bloqueie requisições suspeitas com Rate Limiting.

---

## 2. Snippets Canônicos de Referência

### 2.1. Hash Seguro de Senhas com Argon2id (Node.js)
```typescript
import argon2 from 'argon2';

export async function hashPassword(password: string): Promise<string> {
  return await argon2.hash(password, {
    type: argon2.argon2id,
    memoryCost: 2 ** 16, // 64 MB
    timeCost: 3,         // 3 iterações
    parallelism: 1,
  });
}

export async function verifyPassword(hash: string, plainText: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, plainText);
  } catch {
    return false;
  }
}
```

### 2.2. Cabeçalhos de Segurança Rigorosos (Helmet / Express)
```typescript
import helmet from 'helmet';
import { Express } from 'express';

export function configureSecurityHeaders(app: Express) {
  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          imgSrc: ["'self'", "data:", "https://images.exemplo.com"],
          connectSrc: ["'self'", "https://api.exemplo.com"],
          objectSrc: ["'none'"],
          upgradeInsecureRequests: [],
        },
      },
      crossOriginEmbedderPolicy: true,
      hsts: {
        maxAge: 31536000, // 1 ano
        includeSubDomains: true,
        preload: true,
      },
    })
  );
}
```

---

## 3. Armadilhas Críticas em Segurança (*Gotchas*)

- ⚠️ **Armazenamento de Tokens JWT no `localStorage`**: Tokens sensíveis gravados em `localStorage` ou `sessionStorage` são acessíveis por qualquer script malicioso injetado via XSS. Armazene tokens de autenticação em cookies `HttpOnly`, `Secure` e `SameSite=Strict/Lax`.
- ⚠️ **IDOR (Insecure Direct Object Reference)**: Permitir `GET /api/pedidos/123` sem validar se o `userId` do token é o proprietário do pedido 123 permite a qualquer usuário autenticado ler dados de outros clientes apenas alterando o ID na URL.
- ⚠️ **Uso de Algoritmos Fracos de Hash**: Utilizar MD5, SHA-1 ou SHA-256 simples sem sal (*salt*) para armazenar senhas permite a quebra instantânea via tabelas arco-íris (*Rainbow Tables*). Use estritamente **Argon2id** ou **bcrypt**.

---

## 4. Padrão de Entrega do Agente

Ao entregar soluções de segurança ou autenticação:
1. Nunca insira credenciais, certificados ou salts fixados no código.
2. Forneça configurações seguras de cookies (`httpOnly: true`, `secure: true`, `sameSite: 'lax'`).
3. Adicione sempre verificações de autorização de escopo e propriedade de recurso antes de qualquer mutação.

---

## 5. 📝 Gestão do Plano de Remediação com `_task-management` (Sempre ao Final)

Sempre ao término de qualquer análise, auditoria de segurança ou identificação de vulnerabilidades (OWASP, autenticação, headers, criptografia), se houver apontamentos pendentes de remediação ou hardening, **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Identifiquei vulnerabilidades e oportunidades de hardening. Deseja que eu registre o plano de remediação no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a registrar automaticamente):
1. **Ativação da Skill**: Acione a skill **`_task-management`** para realizar a escrita ou atualização estruturada do backlog.
2. **Localização em Cascata**: A skill `_task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`).
3. **Mapeamento de Severidades**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Injeções (SQL, NoSQL, Comandos), quebra de autenticação, segredos expostos e falhas de IDOR.
   - `⚠️ 2. Média Prioridade`: Ausência de proteção CSRF, configurações fracas de CSP/CORS, falta de rotação de Refresh Tokens e Rate Limiting.
   - `💡 3. Baixa Prioridade / Otimização`: Remoção de cabeçalhos de fingerprint (`X-Powered-By`), ajustes de TTL de cache e auditoria periódica de dependências.
   - `✅ 4. Concluído recentemente`: Vulnerabilidades já corrigidas e validadas com testes na sessão ativa com `- [x]`.
4. **Navegabilidade**: Todo apontamento deve conter link markdown (`[arquivo.ext](file:///...)`) indicando a linha e o arquivo exato da vulnerabilidade.
