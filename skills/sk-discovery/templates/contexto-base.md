# Modelos Base do `sk-discovery`: `CONTEXT.md` e `AGENTS.md`

> Os modelos mostram estrutura e nível de detalhe. Os valores são ilustrativos. Em cada arquivo real, mantenha somente o que o repositório sustenta.

## 1. `CONTEXT.md`

````markdown
# Contexto do Projeto: Gateway de Pagamentos

> Atualizado em: 2026-10-11

## Propósito
Serviço de processamento de transações (PIX, cartão, boleto), com idempotência de cobranças e webhooks assinados com HMAC.

## Stack

| Componente | Tecnologia | Versão | Origem |
| :--- | :--- | :--- | :--- |
| Runtime | Node.js | <versão> | `package.json` (engines) |
| Web | Fastify | <versão> | `package.json` |
| Banco | PostgreSQL via Prisma | <versão> | `docker-compose.yml` |
| Testes | Vitest | <versão> | `package.json` |

## Comandos

| Ação | Comando | Origem |
| :--- | :--- | :--- |
| Instalar | `npm install` | `package.json` |
| Dev | `npm run dev` | `package.json` (scripts) |
| Testes | `npm run test` | `package.json` (scripts) |
| Migrar | `npm run db:migrate` | `package.json` (scripts) |
| Deploy | não verificado | n/d |

## Topologia de pastas

```text
src/
├── domain/          # Entidades e regras puras
├── application/     # Casos de uso
├── infrastructure/  # Repositórios, clientes externos
└── presentation/    # Rotas e controllers
```

## Índice da documentação

| Documento | Conteúdo |
| :--- | :--- |
| [AGENTS.md](./AGENTS.md) | Regras para IAs |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Módulos e fluxos |
| [DATA.md](./DATA.md) | Dados e integrações |

## Notas da Equipe

_Espaço reservado para anotações manuais da equipe. A skill não altera esta seção._
````

---

## 2. `AGENTS.md`

````markdown
# Diretrizes para Assistentes de IA

> Atualizado em: 2026-10-11

## Regras obrigatórias
1. Tipagem estrita: não use `any`; modele contratos de API. (Origem: `tsconfig.json`, `strict: true`)
2. Erros no formato Problem Details (RFC 9457). (Origem: `src/presentation/errors`)
3. Commits no padrão Conventional Commits. (Origem: histórico git e `commitlint.config.js`)
4. Mutações financeiras exigem o cabeçalho `Idempotency-Key`.

## Restrições (o que não fazer)
- Não execute comandos destrutivos no banco (`drop`, `truncate`, `delete` sem `where`).
- Não adicione dependências fora do fluxo descrito em [GUIDELINE.md](./GUIDELINE.md).
- Não leia nem exponha `.env`; use `.env.example` como referência.

## Skills aplicáveis
Stack detectada: TypeScript, Node.js e PostgreSQL. Use `sk-tech-typescript`, `sk-tech-nodejs`, `sk-sql`, `sk-api-design` e `sk-testing`.

## Decisões críticas
- [ADR-005](./docs/adr/ADR-005.md): Transactional Outbox para eventos financeiros.

## Antes de concluir uma tarefa
Rodar lint e testes (comandos em [CONTEXT.md](./CONTEXT.md)).

## Notas da Equipe

_Espaço reservado para anotações manuais da equipe. A skill não altera esta seção._
````

As seções **Skills aplicáveis** e **Decisões críticas** são opcionais: a primeira mapeia a stack detectada às skills que existirem no ambiente (liste só essas); a segunda linka os ADRs aceitos que restringem o código.
