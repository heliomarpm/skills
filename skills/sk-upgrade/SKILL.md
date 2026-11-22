---
name: sk-upgrade
description: "ATIVAÇÃO EXPLÍCITA: planeja e executa upgrades de versões major de frameworks, runtimes e bibliotecas com matriz de EOL e breaking changes, saltos incrementais, codemods, rollback e circuit breaker. Use para migrar versão major ou remediar CVE com quebra. NÃO use para refatorar sem troca de versão (sk-refactor) nem CI/CD (sk-devops)."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(npm outdated), Bash(npm audit), Bash(npm test *), Bash(npm run test *), Bash(npm run build *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(pnpm outdated), Bash(pnpm audit), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run build *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(dotnet list * --outdated), Bash(dotnet list * --vulnerable), Bash(dotnet build *), Bash(dotnet test *), Bash(mvn test *), Bash(./mvnw test *), Bash(gradle test *), Bash(./gradlew test *), Bash(go test *), Bash(go vet *), Bash(go build *), Bash(pytest *), Bash(python -m pytest *), Bash(uv run pytest *), Bash(pip-audit), Bash(composer outdated), Bash(composer audit), Bash(composer test *), Bash(flutter test *), Bash(flutter analyze *), Bash(dart pub outdated), Bash(cargo check *), Bash(cargo test *), Bash(cargo clippy *), Bash(cargo audit)
---

# Upgrade: migrações de versão major e remediação com quebra

Conduz atualizações estruturais de runtimes, frameworks, SDKs e bibliotecas críticas sem saltos cegos, com inventário real, validação por salto e plano de reversão testável.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-upgrade`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita e plano aprovado.** Nunca inicie um upgrade por inferência durante outra tarefa. Mapeie versões e *breaking changes*, apresente o plano em saltos e aguarde confirmação explícita antes de alterar manifestos (`package.json`, `pom.xml`, `Cargo.toml`, `*.csproj`, `pyproject.toml`, `go.mod`, `composer.json`, `pubspec.yaml`), lockfiles, imagens base ou rodar scripts de atualização.

**Execução de pacotes e codemods pede confirmação.** Comandos de instalação, atualização de dependências (`npm install`, `ng update`, `pnpm up`, `dotnet add`, `cargo update`, `composer require`) e codemods externos executam código de terceiros e ficam fora de `allowed-tools` de propósito: peça aprovação a cada salto antes de rodar.

**Um salto major por vez.** Nunca pule múltiplos majors simultaneamente sem guia oficial de salto direto e validação intermediária. Cada salto sai de um estado verde para outro estado verde antes do próximo.

**Evidência e versões reais.** Leia manifestos, lockfiles, `.nvmrc`, `global.json`, `Dockerfile` e workflows de CI antes de propor alvos. Confirme *end-of-life* (EOL), matriz de compatibilidade e *breaking changes* na documentação ou *release notes* oficiais da versão alvo; marque lacunas com `[A CONFIRMAR]`.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, testes ou build dentro de um salto, pare após **3 tentativas consecutivas** sobre a mesma falha. Acione o ponto de parada da seção 4 e aguarde decisão antes de insistir ou adicionar pacotes de contorno.

**Idioma.** O do usuário; identificadores e comandos seguem o projeto.

---

## 1. Modos de operação

| Modo | Quando usar | Entregável principal |
| :--- | :--- | :--- |
| **Planejar** | Avaliar upgrade de runtime, framework ou biblioteca major | Inventário, matriz EOL/breaking changes, rota de saltos e estratégia de rollback |
| **Executar salto** | Aplicar um salto já aprovado no plano | Manifestos e código ajustados para o salto atual + suíte verde + checklist de smoke |
| **Remediar CVE** | Vulnerabilidade crítica só tem correção em versão com quebra | Análise de impacto da CVE, escopo mínimo de atualização e mitigação temporária se adiado |
| **Auditar EOL** | Levantar runtimes e dependências sem suporte de segurança | Inventário priorizado por risco e dependências bloqueadoras (*peer dependencies*) |

---

## 2. Workflow

1. **Inventário e linha de base**:
   - Leia manifestos, lockfiles, arquivo de versão de runtime (`.nvmrc`, `.tool-versions`, `rust-toolchain.toml`, `global.json`), `Dockerfile` e `.github/workflows/`.
   - Rode comandos somente leitura (`outdated`, `audit`, suíte atual de testes/build/tipos) para registrar a linha de base antes de qualquer alteração.
   - Se a suíte atual já estiver quebrada ou sem cobertura mínima no caminho afetado, alerte o usuário e proponha estabilizar ou criar testes de caracterização (`sk-testing`) antes do salto.
2. **Matriz de EOL e *breaking changes***:
   - Mapeie dependências diretas, transitivas acopladas (*peer dependencies*, plugins de framework, ORMs, runners de teste) e versão mínima exigida de runtime/OS.
   - Liste remoções de API, mudanças de comportamento padrão (nullability, serialização, CORS, compilador, scheduler), impacto em build/CI/Docker e bibliotecas abandonadas que bloqueiam o salto.
3. **Plano em saltos e rollback**:
   - Quebre upgrades multi-major em saltos sequenciais verificáveis (ex.: Angular 16 -> 17 -> 18 -> 19, ou React + tipos antes de UI kits).
   - Defina estratégia de branch/rollback (`git` em branch isolada, *feature flags* para camada de compatibilidade quando necessário e critério objetivo de abortar).
4. **Portão de aprovação**:
   - Apresente plano, riscos, comandos que serão executados e saltos previstos. Só avance com autorização expressa.
5. **Execução incremental (um salto por vez)**:
   - Execute ou oriente o codemod/schematic oficial quando disponível antes de ajustes manuais.
   - Isole adaptações de API por módulo; evite misturar refatoração estética fora do escopo do upgrade.
   - Atualize runtime em CI, `Dockerfile` (digest/tag fixa) e arquivos de configuração no mesmo salto quando exigido pela versão.
   - Rode build, verificação de tipos, lint, testes e auditoria de vulnerabilidades ao fim do salto, respeitando o Circuit Breaker (seção 4).
6. **Fechamento e registro**:
   - Confirme compatibilidade com o contrato externo, documentação e changelog; registre saltos adiados ou débitos remanescentes via `sk-tasks`.

---

## 3. Estratégia de saltos, codemods e rollback

Antes de iniciar qualquer salto multi-major ou upgrade de plataforma, consulte [references/upgrade-playbook.md](./references/upgrade-playbook.md) para:
- Modelo de **Matriz de Inventário, EOL e Breaking Changes**;
- Mapa de **codemods e ferramentas oficiais** por ecossistema (`ng update`, `@next/codemod`, OpenRewrite, `.NET Upgrade Assistant`, `ruff`, `dart fix`, `cargo fix`, `cap migrate`);
- Checklist de verificação pós-salto (lockfile, runtime em CI/contêiner, regressão e smoke test);
- Playbook de **rollback seguro** sem perder histórico.

---

## 4. Ponto de parada: circuit breaker

Se um mesmo erro de compilação, resolução de dependências (*peer dependency conflict*), tipagem ou teste persistir após **3 tentativas consecutivas** dentro do salto atual:

1. **Interrompa as edições imediatamente** — não force flags permissivas (`--legacy-peer-deps`, `--force`, supressão global de lint/tipos) para "fazer passar".
2. Informe o salto em curso, o comando executado, a mensagem exata do erro e as 3 hipóteses já testadas e descartadas.
3. Proponha opções claras:
   - **A. Recortar o salto ou trocar biblioteca bloqueadora**: isolar ou substituir a dependência incompatível primeiro.
   - **B. Camada de compatibilidade temporária**: manter adaptador/feature flag documentado como débito no `TASKS.md`.
   - **C. Reverter o salto atual**: restaurar o último commit verde e replanejar os pré-requisitos.

Aguarde a decisão do usuário antes de retomar.

---

## 5. Integrações e registro via `sk-tasks`

Se restarem saltos futuros, bibliotecas bloqueadoras ou débitos de depreciação adiados, pergunte ao final:

> *"Deseja que eu registre os próximos saltos e pendências de upgrade no `TASKS.md` do projeto?"*

Com a confirmação, acione `sk-tasks` (modo Importar), com origem `upgrade`, links relativos e prioridade: CVE crítica ou runtime fora de EOL sem mitigação P0/P1; próximo salto planejado e dependências obsoletas P2; limpeza de código legado/deprecado P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `sk-tech-*` | Idiomas, APIs modernas e ferramentas oficiais da stack alvo |
| `sk-assessment` | Diagnostica runtimes em EOL e dependências obsoletas antes de priorizar upgrades |
| `sk-security` | Prioriza CVEs críticas e valida se a correção exige salto major ou mitigação temporária |
| `sk-testing` | Cria testes de caracterização antes do salto e valida regressões após cada etapa |
| `sk-refactor` | Prepara desacoplamento estrutural antes de migrar ou remove camadas antigas depois |
| `sk-devops` | Alinha versões de runtime, imagens base Docker e workflows de CI/CD |
| `sk-adr` | Registra decisões de troca de biblioteca/framework bloqueador ou adoção de LTS |
| `sk-git` e `sk-changelog` | Isolamento em branch, commits por salto (`build:`/`chore:`) e registro de breaking changes |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 6. Armadilhas

- **Saltar múltiplos majors de uma vez**: multiplica *breaking changes* simultâneos e inviabiliza isolar regressões.
- **Usar `--force` ou `--legacy-peer-deps` para silenciar conflitos**: mascara incompatibilidade real que quebra em runtime.
- **Upgrade sem linha de base verde**: impossível distinguir erro novo do que já falhava antes.
- **Atualizar framework no código sem alinhar runtime no CI e `Dockerfile`**: build passa local e falha no pipeline ou produção.
- **Misturar novas funcionalidades e refatoração ampla no mesmo diff do upgrade**: dificulta code review e rollback.
- **Ignorar migração de dados/ORM ou remoção silenciosa de defaults**: quebra contratos ou consultas sem erro de compilação.
- **Não registrar ou testar rollback**: transforma falha parcial em bloqueio prolongado da branch principal.
- **Loop de correção após 3 falhas**: contornar erros insistindo sem acionar o circuit breaker.

---

## 7. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0), modo usado (seção 1) e linha de base observada.
2. Matriz de inventário, EOL, *breaking changes* confirmados e dependências bloqueadoras (com links relativos para manifestos e CI).
3. Plano sequencial por saltos incrementais com estratégia de rollback e pedido explícito de aprovação (no modo Planejar) ou diff restrito ao salto aprovado (no modo Executar salto).
4. Resultado exato de build, tipos, lint, testes e auditoria pós-salto, ou o relato estruturado do circuit breaker.
5. Próximos saltos/pendências e a pergunta condicional sobre o registro no `TASKS.md` (seção 5).
