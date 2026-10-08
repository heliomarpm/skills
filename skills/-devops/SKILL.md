---
name: -devops
description: Orienta a automação de entregas, configuração de contêineres e esteiras de integração contínua. Use ao criar ou otimizar Dockerfiles, ambientes locais e fluxos de CI/CD.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(docker build *), Bash(docker compose config *), Bash(docker-compose config *), Bash(terraform validate *), Bash(tflint *)
---

# Global Skill: DevOps, Containerization & CI/CD Engineering

Diretrizes para a criação de imagens Docker seguras, leves e otimizadas, ambientes locais consistentes e esteiras de CI/CD modernas.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧠 **Skill Ativa**: `-devops``

---

## 1. Processo de Execução de DevOps

Ao criar ou otimizar contêineres e esteiras de automação:

1. **Higiene do Contexto**: Crie um `.dockerignore` rigoroso para evitar o envio de arquivos locais ou segredos para o daemon do Docker.
2. **Construção Multiestágio (Multi-Stage)**: Isole o ambiente de compilação/testes (`builder`) da imagem final de produção (`runner`).
3. **Hardening & Segurança**: Crie e alterne para um usuário não-root, declare `HEALTHCHECK` e utilize imagens base mínimas (`alpine`, `distroless`, `slim`).
4. **Pipeline CI/CD Eficiente (Fail-Fast)**: Estruture o workflow com cancelamento de concorrência, cache inteligente e validação rápida antes de builds pesados.
5. **Autenticação Federada (OIDC)**: Elimine credenciais de longa duração em segredos usando OpenID Connect com os provedores Cloud.

---

## 2. Snippets Canônicos de Referência

### 2.1. Dockerfile Multi-Stage Otimizado & Seguro (Node.js/TypeScript)
```dockerfile
# ESTÁGIO 1: Build e Instalação de Dependências
FROM node:20-alpine AS builder
WORKDIR /app

# Aproveita o cache de camadas do Docker copiando apenas manifestos
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

COPY . .
RUN pnpm build && pnpm prune --prod

# ESTÁGIO 2: Imagem Final de Produção (Mínima e Segura)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Cria usuário não-root dedicado
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/index.js"]
```

### 2.2. Pipeline GitHub Actions com Concorrência e Cache
```yaml
name: -devops

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

# Cancela builds anteriores na mesma branch quando novos commits são enviados
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node com Cache Nativo
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Instalar Dependências
        run: pnpm install --frozen-lockfile

      - name: Lint e Checagem de Tipos (Fail-Fast)
        run: |
          pnpm lint
          pnpm typecheck

      - name: Executar Testes Automatizados
        run: pnpm test -- --coverage
```

---

## 3. Armadilhas Críticas em DevOps (*Gotchas*)

- ⚠️ **Execução como Root no Contêiner**: Contêineres executados como `root` facilitam escalonamento de privilégios no host caso ocorra uma falha de segurança na aplicação.
- ⚠️ **Ausência de `.dockerignore`**: Enviar a pasta `node_modules` local (geralmente compilada para a arquitetura da sua máquina) quebra a instalação de pacotes dentro de contêineres Linux e infla o contexto de build.
- ⚠️ **Logs Infinitos no Docker Compose**: Deixar serviços locais ou em VPS sem rotação de logs preenche todo o espaço em disco do servidor com arquivos JSON de log (`max-size: "10m"`, `max-file: "3"`).

---

## 4. Padrão de Entrega do Agente

Ao gerar artefatos de DevOps:
1. Forneça sempre o par `Dockerfile` + `.dockerignore`.
2. Para orquestrações locais, entregue um `docker-compose.yml` completo com redes isoladas e arquivo `.env.example`.
3. Garanta que todas as ações e imagens base utilizem versões estáveis declaradas explicitamente.
