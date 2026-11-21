---
name: sk-devops
description: "Orienta contêineres, Kubernetes/Helm, CI/CD e IaC: Dockerfiles seguros, Compose, GitHub Actions (cache/OIDC), deploy/rollback, releases e Terraform. Use para Docker, Kubernetes, pipeline, deploy ou IaC. NÃO use para segurança da aplicação (sk-security), arquitetura (sk-system-design) nem código de negócio."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(docker build *), Bash(docker compose config *), Bash(docker-compose config *), Bash(terraform validate *), Bash(terraform fmt -check *), Bash(tflint *), Bash(hadolint *), Bash(actionlint *), Bash(trivy config *), Bash(trivy image *)
---

# DevOps: contêineres, CI/CD e infraestrutura

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-devops`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ações que mudam o mundo exigem pedido explícito**: `terraform apply` e `destroy`, `docker push`, `docker system prune`, publicar release, disparar workflow ou deploy. `terraform plan` usa credenciais: confirme antes. `docker build` executa os passos `RUN` do Dockerfile, então rode só com contexto confiável.

**Siga o projeto.** Detecte o que já existe (GitHub Actions ou GitLab CI, registry, nuvem, gerenciador de pacotes, versão de runtime em `.nvmrc`, `engines` ou `.tool-versions`) e não troque de ferramenta sem pedido. Os exemplos em [examples/containers-and-ci.md](./examples/containers-and-ci.md) são ilustrativos: use as versões do projeto.

**Segredos.** Nunca coloque credenciais em arquivos, imagens, logs ou exemplos. Segredos de build usam `--mount=type=secret`, nunca `ARG` ou `ENV`.

**Timebox e Circuit Breaker.** Ajustes de containerização e automação de pipelines não devem rodar em ciclos indefinidos de tentativa e erro. Estabeleça um teto de no máximo **3 tentativas de build local (`docker build`) ou validação de linters** (`hadolint`, `actionlint`, `tflint`, `terraform validate`). Se a falha persistir após 3 iterações, interrompa a execução ativa e acione o ponto de parada para check-in com o usuário (seção 9.1).

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
3. Valide com as ferramentas permitidas (`hadolint`, `actionlint`, `terraform validate`, `docker compose config`) ou `docker build` quando aplicável, respeitando o circuit breaker (seção 9.1).
4. Registre as pendências (seção 10).

---

## 3. Contêineres

**Regras**: build multiestágio; imagem final mínima (`slim`, `alpine`, `distroless`) e fixada por versão (e por digest em produção); usuário não root; só os arquivos necessários; segredos fora da imagem; `.dockerignore` sempre junto do Dockerfile.

**PID 1**: o processo principal não trata sinais como um init. Use `docker run --init`, `init: true` no Compose ou `tini`.

**HEALTHCHECK**: útil em Docker e Compose; o Kubernetes o ignora e usa probes (`sk-observability`). Não use `wget` ou `curl` em imagens que não os têm; use o próprio runtime.

Em produção, quando possível: filesystem somente leitura, limites de CPU e memória e `securityContext` restritivo. Veja modelo completo de `Dockerfile` e `.dockerignore` em [examples/containers-and-ci.md](./examples/containers-and-ci.md).

Para workloads em Kubernetes, Helm/Kustomize e GitOps (`Deployment` endurecido, probes com `preStop`, `PDB`, `HPA`, `NetworkPolicy` e segredos externos), consulte [references/kubernetes.md](./references/kubernetes.md).

---

## 4. Docker Compose

Redes isoladas, `healthcheck` com `depends_on: condition: service_healthy`, rotação de logs, `init: true`, `env_file` com `.env.example` versionado (e `secrets:` fora do versionamento). Veja modelo em [examples/containers-and-ci.md](./examples/containers-and-ci.md).

---

## 5. Pipeline de CI

**Regras**: `permissions` mínimas por job; `timeout-minutes`; cache do gerenciador de pacotes; falha rápida (lint e tipos antes dos testes pesados); cancelamento de execuções antigas **só em PRs**, nunca em deploy; actions fixadas por SHA completo, mantidas por Dependabot ou Renovate.

**Segurança do CI**: nunca imprima segredos; cuidado com `pull_request_target` e com PRs de forks (não exponha segredos a código não confiável); dados de eventos (títulos de PR, nomes de branch) usados em `run:` devem passar por variável de ambiente, não por interpolação direta. Veja modelo de workflow em [examples/containers-and-ci.md](./examples/containers-and-ci.md).

---

## 6. Credenciais: OIDC

Elimine chaves de longa duração: o job assume um papel temporário pela identidade OIDC do provedor de CI. A **política de confiança** deve ser restrita por repositório e por branch ou ambiente (`sub`); confiança ampla é o erro mais comum. Use *environments* com aprovação para produção. Veja snippet OIDC + política IAM em [examples/containers-and-ci.md](./examples/containers-and-ci.md).

---

## 7. Deploy e releases

**Deploy**: ambientes com aprovação; estratégia (rolling, blue-green, canary) conforme o risco; rollback testado; migrações de banco compatíveis, com expand and contract (`sk-sql`); smoke test após o deploy.

**Releases automáticas** (semantic-release ou equivalente):
- O tipo de commit define a versão: `fix` gera PATCH, `feat` gera MINOR, quebra de contrato gera MAJOR (convenção no `sk-git`).
- Job de release só em `main`, com `fetch-depth: 0` e as permissões necessárias (`contents: write` e, se preciso, `issues` e `pull-requests`).
- Changelog e tags gerados pela ferramenta. **Publicar uma release só a pedido explícito.**

---

## 8. Infraestrutura como código (Terraform)

State remoto com lock; `plan` no PR e `apply` com aprovação; módulos versionados; `terraform fmt`, `validate` e `tflint`; scanners (`checkov` ou `trivy config`). Nunca versione `*.tfstate` nem variáveis com segredos.

---

## 9. Cadeia de suprimentos

Actions e imagens fixadas (SHA e digest), lockfile versionado, scan de imagem e de dependências (`sk-security`), SBOM quando exigido, assinatura de artefatos (cosign) e atualização automática de dependências.

### 9.1. Ponto de parada: circuit breaker em builds e validações

Ao tentar ajustar um Dockerfile ou pipeline e atingir o teto de **3 tentativas** com falhas consecutivas de build (`docker build`) ou erros persistentes de validação (`actionlint`, `hadolint`, `tflint`, `terraform validate`):

1. **Interrompa a execução ativa imediatamente** — não adicione pacotes indiscriminadamente, não altere permissões sem entender o contexto e não tente soluções de contorno inseguras.
2. Apresente o log de erro exato, o comando executado, as correções que já foram tentadas e a causa suspeita da falha (ex.: dependência nativa ausente na imagem base, incompatibilidade de arquitetura, contexto do `.dockerignore` excluindo arquivos necessários).
3. Faça o check-in de continuidade:

> *"Atingi o limite do circuit breaker (3 tentativas) ao tentar validar/construir `[Dockerfile/Pipeline]`. Como deseja proceder?*  
> 1. **Mudar de estratégia**: testar imagem base alternativa (ex.: Debian slim em vez de Alpine) ou refatorar para build multiestágio  
> 2. **Fornecer contexto do ambiente**: você orienta sobre variáveis de build, permissões locais ou dependências ausentes  
> 3. **Pausar e registrar pendência**: documentar a restrição encontrada e registrar a tarefa no `TASKS.md` (via `sk-tasks`)*"

Aguarde a resposta do usuário antes de novas execuções ou alterações.

---

## 10. Integrações e registro via `sk-tasks`

Se houver pendências relevantes não resolvidas, pergunte ao final:

> *"Deseja que eu registre as melhorias de DevOps no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `sk-tasks` (modo Importar), com origem `devops`, links relativos e a prioridade: contêiner como root, segredo exposto e confiança OIDC ampla P1; pipeline e cache P2; otimizações P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `sk-git` | Convenção de commits que alimenta as releases |
| `sk-changelog` | Detecta automações de release configuradas aqui para evitar edição manual do CHANGELOG |
| `sk-security` | Segredos, scanners e hardening |
| `sk-observability` | Probes, Collector, dashboards e alertas como código |
| `sk-testing` | Estágios de teste no pipeline |
| `sk-sql` | Migrações no deploy |
| `sk-adr` | Decisões de plataforma e estratégia de deploy |
| `sk-system-design` | Arquitetura que a infraestrutura implementa |

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
- **Tentativa e erro em builds (*build loop*)**: alterar repetidamente instruções do Dockerfile ou pipeline sem investigar o log de erro e sem acionar o circuit breaker.
- **`apply`, `push` ou release sem pedido.**

---

## 12. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivos criados ou alterados, com links relativos (Dockerfile sempre com `.dockerignore`).
3. Resultado da validação (`hadolint`, `actionlint`, `terraform validate`) ou, se interrompido pelo circuit breaker, o relato e check-in da seção 9.1.
4. Ações que dependem de confirmação do usuário (deploy, release, `apply`).
5. Pendências e a pergunta condicional sobre o registro em tarefas (seção 10).
