# Exemplos de Contêineres, CI e OIDC (`sk-devops`)

> Adapte sempre as versões de runtime, gerenciador de pacotes e ferramentas aos arquivos do projeto (`.nvmrc`, `engines`, `packageManager`, `.tool-versions`).

## 1. Dockerfile multiestágio e `.dockerignore`

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

## 2. Docker Compose

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

## 3. Pipeline de CI (GitHub Actions)

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

## 4. Credenciais OIDC (GitHub Actions → AWS)

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
