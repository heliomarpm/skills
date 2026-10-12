---
name: -devops
description: "Orienta contêineres, integração e entrega contínuas e infraestrutura como código: Dockerfiles seguros e enxutos, Docker Compose, pipelines de CI (GitHub Actions e equivalentes) com cache e permissões mínimas, autenticação OIDC sem credenciais de longa duração, estratégias de deploy e rollback, automação de releases (semantic-release, changelog, tags), Terraform e segurança da cadeia de suprimentos. Use sempre que o usuário pedir 'crie o Dockerfile', 'docker compose', 'pipeline', 'GitHub Actions', 'CI/CD', 'deploy', 'OIDC', 'release automática', 'Terraform' ou 'otimize o build', mesmo sem a palavra 'devops'. NÃO use para segurança de aplicação em profundidade (isso é -security), desenho de arquitetura (isso é -system-design) nem para código da aplicação."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(docker build *), Bash(docker compose config *), Bash(docker-compose config *), Bash(terraform validate *), Bash(terraform fmt -check *), Bash(tflint *), Bash(hadolint *), Bash(actionlint *), Bash(trivy config *), Bash(trivy image *)
---

# DevOps: contêineres, CI/CD e infraestrutura

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-devops`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ações que mudam o mundo exigem pedido explícito**: `terraform apply` e `destroy`, `docker push`, `docker system prune`, publicar release, disparar workflow ou deploy. `terraform plan` usa credenciais: confirme antes. `docker build` executa os passos `RUN` do Dockerfile, então rode só com contexto confiável.

**Siga o projeto.** Detecte o que já existe (GitHub Actions ou GitLab CI, registry, nuvem, gerenciador de pacotes, versão de runtime em `.nvmrc`, `engines` ou `.tool-versions`) e não troque de ferramenta sem pedido. Os exemplos abaixo são ilustrativos: use as versões do projeto.

**Segredos.** Nunca coloque credenciais em arquivos, imagens, logs ou exemplos. Segredos de build usam `--mount=type=secret`, nunca `ARG` ou `ENV`.

**Idioma.** O do usuário; nomes técnicos ficam como estão.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Containerizar** | Dockerfile, `.dockerignore`, Compose |
| **Pipeline CI** | Build, testes, qualidade |
| **Deploy e release** | Entrega, rollback, versionamento |
| **IaC** | Terraform e infraestrutura declarativa |
| **Revisar** | Avaliar o que existe |

---

## 2. Workflow

1. **Contexto**: leia `AGENTS.md`, `ARCHITECTURE.md`, os ADRs e os arquivos existentes de contêiner e pipeline.
2. Aplique a seção do modo (3 a 8) e a de cadeia de suprimentos (9).
3. Valide com as ferramentas permitidas (`hadolint`, `actionlint`, `terraform validate`, `docker compose config`) e informe o resultado, ou que não foi possível executar.
4. Registre as pendências (seção 10).

---

## 3. Contêineres

**Regras**: build multiestágio; imagem final mínima (`slim`, `alpine`, `distroless`) e fixada por versão (e por digest em produção); usuário não root; só os arquivos necessários; segredos fora da imagem; `.dockerignore` sempre junto do Dockerfile.

**PID 1**: o processo principal não trata sinais como um init. Use `docker run --init`, `init: true` no Compose ou `tini`.

**HEALTHCHECK**: útil em Docker e Compose; o Kubernetes o ignora e usa probes (`-observability`). Não use `wget` ou `curl` em imagens que não os têm; use o próprio runtime.

```dockerfile
# syntax=docker/dockerfile:1
FROM node:22-alpine AS builder
WORKDIR /app
RUN corepack enable            # versão do pnpm fixada em "packageManager" no package.json
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile
COPY . .
RUN pnpm build && pnpm prune --prod

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/package.json ./
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["node", "dist/index.js"]
```

```text
# .dockerignore
node_modules
dist
.git
.env
.env.*
!.env.example
coverage
*.log
Dockerfile
docker-compose*.yml
```

Em produção, quando possível: filesystem somente leitura, limites de CPU e memória e `securityContext` restritivo.

---

## 4. Docker Compose

Redes isoladas, `healthcheck` com `depends_on: condition: service_healthy`, rotação de logs, `init: true`, `env_file` com `.env.example` versionado.

```yaml
services:
  api:
    build: .
    init: true
    env_file: .env
    ports: ["3000:3000"]
    networks: [backend]
    depends_on:
      db: { condition: service_healthy }
    logging:
      driver: json-file
      options: { max-size: "10m", max-file: "3" }
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets: [db_password]
    networks: [backend]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      retries: 5
networks:
  backend: {}
secrets:
  db_password:
    file: ./secrets/db_password.txt   # fora do versionamento
```

---

## 5. Pipeline de CI

**Regras**: `permissions` mínimas por job; `timeout-minutes`; cache do gerenciador de pacotes; falha rápida (lint e tipos antes dos testes pesados); cancelamento de execuções antigas **só em PRs**, nunca em deploy; actions fixadas por SHA completo, mantidas por Dependabot ou Renovate.

```yaml
name: CI

on:
  push: { branches: [main] }
  pull_request: { branches: [main] }

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

jobs:
  validate:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@<sha-completo>      # v4
      - uses: pnpm/action-setup@<sha-completo>     # v4, lê "packageManager"
      - uses: actions/setup-node@<sha-completo>    # v4
        with:
          node-version-file: .nvmrc
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint && pnpm typecheck
      - run: pnpm test -- --coverage
```

**Segurança do CI**: nunca imprima segredos; cuidado com `pull_request_target` e com PRs de forks (não exponha segredos a código não confiável); dados de eventos (títulos de PR, nomes de branch) usados em `run:` devem passar por variável de ambiente, não por interpolação direta.

---

## 6. Credenciais: OIDC

Elimine chaves de longa duração: o job assume um papel temporário pela identidade OIDC do provedor de CI. A **política de confiança** deve ser restrita por repositório e por branch ou ambiente (`sub`); confiança ampla é o erro mais comum.

```yaml
permissions:
  id-token: write
  contents: read
steps:
  - uses: aws-actions/configure-aws-credentials@<sha-completo>   # v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/deploy-producao
      aws-region: us-east-1
```

```json
"Condition": {
  "StringEquals": {
    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
    "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:environment:production"
  }
}
```

Use *environments* com aprovação para produção.

---

## 7. Deploy e releases

**Deploy**: ambientes com aprovação; estratégia (rolling, blue-green, canary) conforme o risco; rollback testado; migrações de banco compatíveis, com expand and contract (`-sql`); smoke test após o deploy.

**Releases automáticas** (semantic-release ou equivalente):
- O tipo de commit define a versão: `fix` gera PATCH, `feat` gera MINOR, quebra de contrato gera MAJOR (convenção no `-git`).
- Job de release só em `main`, com `fetch-depth: 0` e as permissões necessárias (`contents: write` e, se preciso, `issues` e `pull-requests`).
- Changelog e tags gerados pela ferramenta. **Publicar uma release só a pedido explícito.**

---

## 8. Infraestrutura como código (Terraform)

State remoto com lock; `plan` no PR e `apply` com aprovação; módulos versionados; `terraform fmt`, `validate` e `tflint`; scanners (`checkov` ou `trivy config`). Nunca versione `*.tfstate` nem variáveis com segredos.

---

## 9. Cadeia de suprimentos

Actions e imagens fixadas (SHA e digest), lockfile versionado, scan de imagem e de dependências (`-security`), SBOM quando exigido, assinatura de artefatos (cosign) e atualização automática de dependências.

---

## 10. Registro via `-tasks` e integrações

Se houver pendências, pergunte ao final:

> *"Deseja que eu registre as melhorias de DevOps no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `devops`, links relativos e a prioridade: contêiner como root, segredo exposto e confiança OIDC ampla P1; pipeline e cache P2; otimizações P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `-git` | Convenção de commits que alimenta as releases |
| `-security` | Segredos, scanners e hardening |
| `-observability` | Probes, Collector, dashboards e alertas como código |
| `-testing` | Estágios de teste no pipeline |
| `-sql` | Migrações no deploy |
| `-adr` | Decisões de plataforma e estratégia de deploy |
| `-system-design` | Arquitetura que a infraestrutura implementa |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 11. Armadilhas

- **Contêiner como root.**
- **Sem `.dockerignore`**: contexto enorme e segredos na imagem.
- **Segredo em `ARG`, `ENV` ou camada da imagem.**
- **Tag `latest` ou actions por tag móvel**: builds não reproduzíveis e risco de cadeia de suprimentos.
- **`cancel-in-progress` em deploy**: interrompe uma implantação no meio.
- **Permissões padrão do workflow**: use o mínimo por job.
- **Confiança OIDC ampla**: qualquer repositório assume o papel.
- **Interpolar dados de eventos em `run:`**: injeção de comando.
- **Logs sem rotação**: enchem o disco.
- **PID 1 sem init**: sinais ignorados e processos zumbis.
- **`apply`, `push` ou release sem pedido.**

---

## 12. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivos criados ou alterados, com links relativos (Dockerfile sempre com `.dockerignore`).
3. Resultado da validação (`hadolint`, `actionlint`, `terraform validate`) ou o motivo de não ter executado.
4. Ações que dependem de confirmação do usuário (deploy, release, `apply`).
5. Pendências e a pergunta sobre o registro em tarefas (seção 10).