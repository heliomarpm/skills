# Playbook de Upgrade: matriz, codemods e rollback

Referência complementar da `sk-upgrade`. Leia sob demanda ao planejar ou executar migrações multi-major e remediações de EOL/CVE.

---

## 1. Template: Matriz de Inventário, EOL e *Breaking Changes*

| Componente / Pacote | Versão atual | EOL / Status | Versão alvo (salto) | *Breaking changes* críticos | Bloqueadores / Acoplamentos |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Runtime (ex.: Node/Java/.NET/Rust) | `[manifesto]` | `[suportada/EOL]` | `[LTS / alvo]` | `[ex.: TLS, remoção API]` | `[CI, Dockerfile, imagem base]` |
| Framework principal | `[manifesto]` | `[suportada/EOL]` | `[salto N+1]` | `[ex.: ciclo de vida, DI, router]` | `[plugins, UI kit, SSR]` |
| ORM / Persistência | `[manifesto]` | `[suportada/EOL]` | `[compatível]` | `[ex.: dialect, queries, pools]` | `[migrations, drivers nativos]` |
| Runners de teste / Lint / Build | `[manifesto]` | `[suportada/EOL]` | `[compatível]` | `[ex.: ESM, TS target, mocks]` | `[config CI, scripts]` |

Marque itens não confirmados na documentação oficial da versão alvo como `[A CONFIRMAR]`.

---

## 2. Ferramentas e codemods oficiais por ecossistema

Confirme sempre a sintaxe exata na versão instalada antes de executar e peça confirmação antes de rodar comandos que modifiquem pacotes ou executem código remoto:

| Ecossistema | Auditoria / Desatualizados | Codemod / Assistente oficial | Pós-ajuste obrigatório |
| :--- | :--- | :--- | :--- |
| **Angular** | `npm outdated` | `ng update @angular/core@<N> @angular/cli@<N>` | Migrar schematics opcionais em passo separado (`@angular/core:control-flow`, signals) |
| **React / Next.js** | `npm outdated` / `pnpm outdated` | `npx @next/codemod <transform> <dir>` / `npx react-codemod` | Conferir tipagem (`@types/react`), `Suspense`, async APIs e Server Actions |
| **Ionic + Capacitor** | `npx cap doctor` / `npm outdated` | `npx cap migrate` | Rodar `npx cap sync`, validar permissões iOS/Android (`Info.plist`, `AndroidManifest.xml`) e Gradle/Xcode |
| **.NET / C#** | `dotnet list package --outdated --vulnerable` | `.NET Upgrade Assistant` (`upgrade-assistant`) | Conferir `TargetFramework`, `global.json`, EF Core migrations e pacotes nativos |
| **Java / Kotlin (JVM)** | `mvn versions:display-dependency-updates` / Gradle version catalog | OpenRewrite (`rewrite-migrate-java`, receitas Spring Boot/Kotlin) | Validar compatibilidade de JVM em CI/Docker, `open-in-view`, Hibernate/Exposed e reflection |
| **Go** | `go list -m -u all` / `govulncheck ./...` | `go mod tidy` + `go fix` | Conferir diretiva `go` no `go.mod`, toolchains e `go test -race ./...` |
| **Python** | `uv pip list --outdated` / `pip-audit` | `ruff check --select UP --fix` (`pyupgrade`) | Validar `requires-python`, wheels nativos, Pydantic v1->v2 e `asyncio` |
| **Rust** | `cargo outdated` / `cargo audit` | `cargo fix --edition` (para troca de edition) | Conferir MSRV em `Cargo.toml`, `cargo clippy --all-targets -- -D warnings` |
| **PHP** | `composer outdated` / `composer audit` | Rector (regras de versão do projeto) | Conferir extensões PHP no `Dockerfile`, `phpstan` e tipos estritos |
| **Flutter / Dart** | `dart pub outdated` | `dart fix --apply` | Conferir SDK constraint no `pubspec.yaml`, Gradle/AGP, CocoaPods e Xcode |

---

## 3. Checklist por salto incremental

Antes de iniciar o salto:
- [ ] Branch limpa e exclusiva para o salto (ex.: `chore/upgrade-angular-18`).
- [ ] Linha de base medida: `build`, `typecheck`, `lint` e `test` passam antes de alterar o manifesto.
- [ ] Documentação oficial e guia de migração da versão alvo lidos (mudanças de comportamento padrão listadas).
- [ ] Aprovação explícita do usuário para modificar manifestos/lockfiles e instalar pacotes do salto.

Durante e após o salto:
- [ ] Lockfile regenerado de forma determinística pelo gerenciador adotado no projeto (sem editar hash manualmente).
- [ ] Configurações de compilador/linter/runtime atualizadas (`tsconfig.json`, `Cargo.toml`, `Dockerfile`, `.github/workflows/`).
- [ ] Nenhuma supressão temporária (`@ts-ignore`, `any`, testes ignorados/enfraquecidos) adicionada sem registro explícito.
- [ ] Testes unitários, integração, contrato e smoke build/execução verdes.
- [ ] Auditoria de vulnerabilidades (`audit`) executada e zero novas regressões críticas.
- [ ] Commit atômico do salto concluído antes de iniciar o próximo salto.

---

## 4. Playbook de rollback seguro

Use quando um salto revela incompatibilidade bloqueadora, degradação grave de performance ou erro após deploy:

1. **Em branch antes do merge**:
   - Se o salto inteiro precisa ser abortado, preserve o diagnóstico (erros, dependência bloqueadora) antes de restaurar a branch ao último commit verde (`git switch` / criação de issue ou registro no `TASKS.md`).
   - Nunca reescreva histórico compartilhado sem confirmação explícita (`sk-git`).
2. **Em produção após merge**:
   - Reverta via novo commit (`git revert`) no código + manifesto + lockfile juntos (nunca reverta apenas `package.json` deixando o lockfile novo).
   - Se o upgrade incluiu **migração de banco** ou alteração de formato persistido em sessão/cache, confirme compatibilidade reversa antes do revert (`sk-sql` expand and contract).
   - Registre causa raiz, dependência bloqueadora e pré-requisito pendente no `TASKS.md` (`origem: upgrade`).
