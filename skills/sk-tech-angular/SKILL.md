---
name: sk-tech-angular
description: "Orienta Angular moderno com Signals (signal, computed, linkedSignal, inputs/outputs), standalone, OnPush, novo control flow, RxJS interop e testes. Use para componentes, serviços reativos, rotas ou migração para signals. NÃO use para tokens/WCAG (sk-design-system), tipagem geral (sk-tech-typescript) nem rotas/actions de servidor (sk-tech-nodejs, sk-sql)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(ng test *), Bash(ng build *), Bash(ng lint *), Bash(npx tsc *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run build *)
---

# Angular: Signals, componentes enxutos e renderização eficiente

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-angular`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do `@angular/core` no `package.json` e use só o que ela suporta. Estágio e API de recursos recentes (Resource API, `httpResource`, formulários baseados em signals, zoneless) mudaram entre versões: **confirme na documentação oficial da versão do projeto** antes de usá-los.

**Siga o projeto.** Respeite a estrutura, o gerenciador de estado (NgRx, SignalStore) e o sistema de design existentes. Em projeto legado, migre aos poucos (veja a seção 4). Tipagem: `sk-tech-typescript`.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão (migração para signals e control flow).

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Signals: o modelo de reatividade

| API | Uso |
| :--- | :--- |
| `signal()` | Estado gravável (`set`, `update`) |
| `computed()` | Valor derivado, memoizado e somente leitura |
| `linkedSignal()` | Estado derivado que também aceita escrita e se redefine quando a fonte muda |
| `effect()` | Efeito colateral (log, sincronizar com API externa), **nunca** para derivar estado |
| `input()`, `input.required()` | Entradas do componente como signals |
| `output()` | Eventos do componente |
| `model()` | Binding bidirecional (`[(valor)]`) |
| `viewChild()`, `contentChild()` e variantes | Consultas ao template como signals |
| `toSignal()`, `toObservable()` | Interop com RxJS |
| `untracked()` | Ler um signal sem criar dependência |

**Regras**
- Atualize signals de forma **imutável** (`update` retornando novo valor); mutar um objeto dentro do signal não notifica.
- Em templates e código, **chame o signal** (`valor()`); sem os parênteses, você usa a função e não o valor.
- Estado compartilhado: serviço com signals privados e `asReadonly()` expostos. Para casos mais complexos, NgRx SignalStore.
- RxJS continua indicado para fluxos assíncronos e eventos (debounce, cancelamento, combinação); converta na borda com `toSignal`.
- `computed` não tem efeitos colaterais, e `effect` não é para propagar estado entre signals.

---

## 2. Princípios

- **Standalone** (padrão a partir do Angular 19; em versões anteriores declare `standalone: true`) e **`OnPush`**.
- **Control flow**: `@if`, `@for (... ; track item.id)`, `@switch`, `@let`; `@defer` para conteúdo pesado ou fora da dobra.
- **Sem lógica cara no template**: use `computed` em vez de chamar métodos.
- **Injeção** com `inject()`; guards, resolvers e interceptors funcionais; rotas com `loadComponent` (carregamento sob demanda).
- **Dados assíncronos**: `toSignal` com `switchMap` é a base estável. As APIs de recurso (`resource`, `rxResource`, `httpResource`) são mais novas e variam por versão.
- **Formulários reativos tipados.**
- **Segurança**: o Angular sanitiza por padrão; evite `bypassSecurityTrust*` (`sk-security`).
- **Acessibilidade**: elementos semânticos e CDK a11y (`sk-design-system`).
- **Testes**: `TestBed` e harnesses; entradas com `fixture.componentRef.setInput`, e signals com `set` nos testes (`sk-testing`).

---

## 3. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): serviço de estado com signals (`asReadonly` + `computed`), componente `OnPush` com `input`/`output`, e busca reativa com `model`, `linkedSignal`, `toSignal` e exposição de estado de erro.

---

## 4. Migração e versões

Migre por etapas: control flow (`@if`, `@for`) com o schematic oficial; inputs, outputs e queries para a API baseada em signals; serviços para signals; e, por fim, `OnPush` e o que a versão permitir. Cada etapa com testes verdes. Antes de adotar recursos novos, confirme o estágio na documentação da versão do projeto.

---

## 5. Integrações

`sk-tech-typescript` (tipos), `sk-design-system` (tokens e acessibilidade), `sk-testing` (testes de componente), `sk-api-design` (contratos), `sk-security`, `sk-code-review` e `sk-devops`. Para rotas/actions de servidor SSR com banco, acione `sk-tech-nodejs` e `sk-sql`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 6. Armadilhas

- **Mutar o objeto dentro de um signal**: não notifica e o `OnPush` não atualiza. Atualize de forma imutável.
- **`effect` para derivar estado**: use `computed` ou `linkedSignal`.
- **Esquecer de chamar o signal** (`valor` em vez de `valor()`).
- **`@for` sem `track`**: recria nós do DOM.
- **Método no template**: reexecuta a cada verificação. Use `computed`.
- **`inject()` fora do contexto de injeção**: erro `NG0203`; use `runInInjectionContext` quando necessário.
- **`subscribe` manual sem encerramento**: vazamento. Prefira `toSignal`, `async` pipe ou `takeUntilDestroyed`.
- **`bypassSecurityTrust*`** com conteúdo do usuário: abre XSS.
- **Adotar APIs experimentais sem conferir a versão.**
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 7. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes standalone com `OnPush` e Signals, com estados de carregamento, vazio e erro, com links relativos.
3. Resultado de testes, build e lint, o motivo de não ter executado ou o relato do circuit breaker.
4. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-angular`, P1 a P3; fallback em lista no chat).
