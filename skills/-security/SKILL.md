---
name: -security
description: "Audita e projeta a segurança de aplicações: autenticação e sessão (OAuth com PKCE, OIDC, JWT), autorização por recurso (RBAC/ABAC, BOLA/IDOR), entrada e injeções, criptografia e segredos, dependências, cabeçalhos web, logs e privacidade, com checklist baseado no OWASP, achados com severidade e plano de remediação. Use sempre que o usuário pedir 'audite a segurança', 'isto é seguro?', 'revise a autenticação', 'proteja este endpoint', 'vazou um segredo', 'vulnerabilidades', 'OWASP', 'hash de senha', 'CSP' ou 'permissões', mesmo sem a palavra 'segurança'. NÃO use para desenhar contratos de API (isso é -api-design), infraestrutura e pipelines (isso é -devops) nem para revisar um diff em geral (isso é -code-review)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm audit), Bash(npm audit --omit=dev), Bash(pnpm audit), Bash(pip-audit), Bash(pip-audit -r *), Bash(composer audit), Bash(cargo audit), Bash(dotnet list * --vulnerable), Bash(trivy fs *), Bash(gitleaks detect *)
---

# Security: segurança defensiva de aplicações

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-security`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Auditar é somente leitura.** No modo Auditar a skill não edita nada. Correções só no modo Corrigir, com aprovação explícita do usuário; corrigir mais de ~3 arquivos ou mudar fluxo de autenticação sempre pede aprovação.

**Sem exploits.** Não escreva exploits funcionais. Prova de conceito mínima só em código do próprio projeto e em ambiente de teste. Não execute scanners ativos contra sistemas de terceiros ou de produção.

**Segredos.** Mascare qualquer credencial encontrada (`sk-****`) e nunca a repita em relatórios, logs ou tarefas.

**Divulgação.** Não detalhe uma vulnerabilidade em PR, issue ou canal público, principalmente em repositório aberto. Recomende canal privado (security advisory, contato do time).

**Evidência.** Todo achado cita arquivo e linha que você leu. Sem evidência, é hipótese. Não use o relatório como garantia de que "está seguro".

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Auditar** | Avaliar código ou design, somente leitura |
| **Projetar** | Definir autenticação, autorização ou proteção de dados antes de implementar |
| **Corrigir** | Aplicar remediações aprovadas |
| **Incidente** | Segredo vazado ou comprometimento suspeito (seção 8) |

---

## 2. Workflow

1. **Contexto**: leia `AGENTS.md`, `ARCHITECTURE.md`, `DATA.md`, ADRs e a stack. Identifique ativos sensíveis (dados pessoais, financeiros, credenciais) e fronteiras de confiança.
2. **Modelagem de ameaças leve (STRIDE)**: para cada fronteira, quem pode falsificar identidade, adulterar dados, negar autoria, vazar informação, derrubar o serviço ou elevar privilégio.
3. **Checklist** (seção 3), priorizando o que toca dados sensíveis e entrada externa.
4. **Achados** no formato da seção 7, com severidade.
5. **Remediação**: no modo Projetar ou Corrigir, a menor mudança que elimina a causa; registre o restante no `-tasks`.

---

## 3. Checklist por área

Referências: OWASP Top 10 e ASVS.

| Área | Verifique |
| :--- | :--- |
| Autenticação e sessão | Fluxo, tokens, logout e revogação, MFA, força bruta (seção 4) |
| Autorização | Checagem por recurso e por ação em toda rota que recebe ID (BOLA/IDOR); nunca confiar só na presença do token; perfis e escopos |
| Entrada e injeções | Consultas parametrizadas, validação de schema, escape de saída (XSS), comandos de shell, SSRF, path traversal, desserialização, upload (tipo, tamanho, local) |
| Dados e criptografia | Senhas (seção 5), AES-GCM com nonce único, chaves em KMS ou gestor, TLS 1.2+, nunca inventar criptografia própria |
| Segredos | Nada no código ou no histórico, scanner de segredos, rotação |
| Dependências | `audit` da stack, lockfile versionado, scripts de instalação, SBOM quando exigido |
| Web | CSP, HSTS, CORS restrito, CSRF, cookies seguros (seção 6) |
| Logs e auditoria | Sem senhas, tokens ou PII em logs; trilha de ações sensíveis (`-observability`) |
| Multitenancy e privacidade | Isolamento entre clientes, minimização de dados, retenção e LGPD |
| Infra e contêineres | Segredos em CI, usuário não root, imagens mínimas (`-devops`) |

---

## 4. Autenticação e sessão

- **OAuth**: Authorization Code com PKCE para todos os clientes; sem implicit e sem password grant; redirect URI com correspondência exata; `state` e `nonce`. Referência vigente: RFC 9700 (OAuth 2.1 ainda é rascunho). OIDC para identidade.
- **Tokens**: access de curta duração (~15 min); refresh com rotação e detecção de reuso.
- **SPA**: prefira o padrão **BFF** (tokens no servidor, sessão em cookie `HttpOnly`, `Secure`, `SameSite`). Token em `localStorage` fica exposto a XSS. Cookie exige proteção CSRF (`SameSite=Lax` mais token ou cabeçalho customizado); `Strict` pode quebrar o retorno do login por redirecionamento.
- **JWT**: algoritmo fixo (rejeite `none`), valide `iss`, `aud` e `exp`, não coloque dados sensíveis, planeje revogação.
- **Força bruta**: rate limit, bloqueio progressivo, MFA em contas sensíveis, mensagens de erro genéricas.
- **Sessão**: regenere o ID no login e invalide no servidor no logout.

---

## 5. Senhas

Use **Argon2id** (ou bcrypt com custo adequado; atenção: ele trunca em 72 bytes). Siga os mínimos atuais do OWASP Password Storage Cheat Sheet e calibre os parâmetros ao ambiente. Qualquer hash rápido (MD5, SHA-1, SHA-256), com ou sem sal, é inadequado para senhas.

```typescript
import argon2 from 'argon2';

// Mínimo OWASP no momento da escrita (19 MiB, 2 iterações): calibre para o seu ambiente.
const OPCOES = { type: argon2.argon2id, memoryCost: 19456, timeCost: 2, parallelism: 1 } as const;

export const hashPassword = (senha: string): Promise<string> => argon2.hash(senha, OPCOES);

export async function verifyPassword(hash: string, senha: string): Promise<boolean> {
  try {
    return await argon2.verify(hash, senha);
  } catch {
    return false;
  }
}
// No login bem-sucedido, se a biblioteca suportar, use argon2.needsRehash(hash, OPCOES)
// e regrave o hash com os parâmetros atuais.
```

---

## 6. Cabeçalhos web

Comece a CSP em modo somente relatório, observe e só então ative. Evite `'unsafe-inline'` (use nonce). `crossOriginEmbedderPolicy` só se você precisar de isolamento, porque quebra recursos de terceiros. HSTS `preload` só depois de validar todos os subdomínios, pois é difícil de desfazer.

```typescript
import helmet from 'helmet';
import type { Express } from 'express';

export function configureSecurityHeaders(app: Express): void {
  app.use(
    helmet({
      contentSecurityPolicy: {
        reportOnly: true, // valide sem quebrar; depois ative
        directives: {
          defaultSrc: ["'self'"],
          scriptSrc: ["'self'"], // nonce em vez de 'unsafe-inline'
          styleSrc: ["'self'"],
          imgSrc: ["'self'", 'data:'],
          connectSrc: ["'self'"],
          objectSrc: ["'none'"],
          frameAncestors: ["'none'"],
          upgradeInsecureRequests: [],
        },
      },
      hsts: { maxAge: 31536000, includeSubDomains: true },
    }),
  );
}
```

Cookies de autenticação: `HttpOnly`, `Secure`, `SameSite` e escopo mínimo de domínio e caminho.

---

## 7. Severidade e formato do achado

| Severidade | Quando |
| :--- | :--- |
| **Crítico** | Exploração remota sem autenticação com impacto alto: execução de código, injeção, bypass de autenticação, segredo de produção exposto |
| **Alto** | BOLA/IDOR, quebra de autorização, XSS armazenado, exposição de dados sensíveis |
| **Médio** | CSRF em ação sensível, CSP ou CORS fracos, ausência de rate limit, refresh sem rotação |
| **Baixo** | Hardening, vazamento de fingerprint, TTLs, higiene |

Cada achado traz: **ID** (`S-01`), severidade, título, **local** (`arquivo:linhas`), **evidência** (segredos mascarados), **impacto**, **correção sugerida** e **confiança** (alta, média, baixa).

---

## 8. Incidente: segredo vazado

1. **Rotacione ou revogue primeiro** a credencial.
2. Verifique uso indevido (logs do provedor).
3. Remova do código e passe a usar um gestor de segredos.
4. Reescrever o histórico do Git é o último passo, via `-git` e com confirmação.
5. Adicione um scanner de segredos ao CI (`-devops`).

Apagar o segredo num commit novo não o remove do histórico.

---

## 9. Registro via `-tasks` e integrações

Se houver achados ou hardening pendente, pergunte ao final:

> *"Deseja que eu registre o plano de remediação no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `security`, links relativos e a prioridade: Crítico P0, Alto P1, Médio P2, Baixo P3. **Detalhes sensíveis ficam fora das tarefas** se o repositório for público. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `-code-review` | Usa este checklist no Eixo 2 |
| `-api-design` | Autenticação, BOLA e schemes do contrato |
| `-testing` | Casos negativos de autorização e entrada maliciosa |
| `-devops` | Segredos em CI, contêineres e scanners |
| `-sql` | Parametrização e permissões de banco |
| `-adr` | Decisões de autenticação e criptografia |
| `-observability` | Logs de auditoria e alertas |
| `-git` | Reescrita de histórico após vazamento |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 10. Armadilhas

- **Token em `localStorage`**: exposto a XSS. Prefira BFF.
- **IDOR**: rota com ID sem validar o dono.
- **Hash rápido para senha**: MD5, SHA-1 e SHA-256 são inadequados, com ou sem sal.
- **Confiar só no token**: autorização por recurso é obrigatória.
- **CSP com `'unsafe-inline'`**: anula boa parte da proteção.
- **Ativar CSP, COEP ou HSTS preload sem testar**: quebra o site ou prende o domínio.
- **Segredo apagado só no commit seguinte**: continua no histórico.
- **Segredo repetido no relatório**: o relatório vira o vazamento.
- **Detalhar a falha em canal público**: expõe a vulnerabilidade antes da correção.
- **Criptografia inventada**: use bibliotecas e modos consolidados.
- **Declarar "seguro"**: o resultado é uma lista de achados, não um atestado.

---

## 11. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Escopo avaliado, ameaças consideradas e o que não foi coberto.
3. Achados no formato da seção 7, do mais grave ao menos grave.
4. No modo Corrigir: arquivos alterados, com links relativos, e o resultado dos testes.
5. Pendências e a pergunta sobre o registro em tarefas (seção 9).