---
name: sk-tech-flutter
description: "Orienta Flutter e Dart 3: records, tipos selados, estado (Riverpod/BLoC), arquitetura em camadas, persistência local performática com índices, go_router, isolates e testes. Use para telas, estado ou desempenho no app. NÃO use para design tokens/WCAG (sk-design-system), OpenAPI (sk-api-design) nem segurança no servidor (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(flutter test *), Bash(flutter analyze *), Bash(dart test *), Bash(dart analyze *), Bash(dart format --set-exit-if-changed *)
---

# Flutter: interfaces fluidas, estado previsível

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-flutter`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia o SDK do Dart e do Flutter no `pubspec.yaml` e a versão do pacote de estado em uso. As APIs do Riverpod, do `go_router` e dos geradores de código mudam entre versões principais: **confirme na documentação oficial da versão do projeto** antes de aplicar um exemplo.

**Siga o projeto.** Respeite a solução de estado (Riverpod, BLoC), a estrutura de pastas e o sistema de design existentes.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem as convenções do Dart.

---

## 1. Princípios

- **Dart 3**: records, classes seladas e `switch` com padrões para estados previsíveis; segurança contra nulos sempre; dados imutáveis.
- **Camadas**: apresentação (widgets sem lógica de negócio), domínio e dados; I/O atrás de **repositórios** com interface abstrata, o que viabiliza testes.
- **Persistência local (SQLite / Drift / sqflite)**: ao implementar consultas locais, garanta que a query seja performática; entregue o script de criação dos índices adequados para as colunas filtradas/ordenadas, evitando bloqueio do isolate.
- **Estado**: Riverpod (com `AsyncNotifier`) ou BLoC, conforme o projeto; widgets declarativos que apenas leem o estado.
- **Renderização**: construtores `const`, widgets pequenos, `ListView.builder` para listas, `ref.watch(...select(...))` para reconstruir só o necessário, `MediaQuery.sizeOf(context)` em vez de `MediaQuery.of(context)`. `RepaintBoundary` e outras otimizações **só com medição** (DevTools, em modo *profile*).
- **Ciclo de vida**: descarte `TextEditingController`, `AnimationController` e `ScrollController` no `dispose()`; após um `await`, confira `context.mounted` antes de usar o `BuildContext`.
- **Navegação**: `go_router` com rotas tipadas e redirecionamentos centralizados para telas privadas.
- **Processamento pesado** fora da thread de interface: `Isolate.run` (não existe na web; use `compute` ou um *web worker* nesse caso).
- **Erros**: mapeie para mensagens ao usuário; nunca exiba a exceção bruta; registre em um serviço de observabilidade (`sk-observability`).
- **Segurança**: nenhuma chave secreta dentro do app (é extraível); armazenamento seguro para tokens; validação no servidor (`sk-security`).
- **Acessibilidade**: `Semantics`, alvos de toque `>= 44×44 pt` (iOS) / `>= 48×48 dp` (Android), `SafeArea` em cabeçalhos e barras fixas, ícones vetoriais (sem emojis estruturais), texto ampliável e contraste validado em claro e escuro (`sk-design-system`).
- **Testes**: testes de widget, *golden*, `integration_test` e `mocktail`, com repositórios falsos (`sk-testing`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): estado assíncrono com Riverpod (`AsyncNotifier` + `copyWithPrevious`) e processamento de JSON pesado com `Isolate.run`.

---

## 3. Integrações

`sk-design-system` (tokens e acessibilidade), `sk-testing`, `sk-sql` (consultas e índices em persistência local SQLite/Drift), `sk-security` (armazenamento e segredos), `sk-api-design` (contratos), `sk-observability` (erros e desempenho), `sk-devops` (build e distribuição), `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Consultas em banco local (SQLite/Drift) sem índices adequados**, gerando lentidão e travamentos de interface.
- **Controladores sem `dispose()`**: vazamento de memória.
- **`MediaQuery.of(context)` só para o tamanho**: reconstrói a cada mudança de teclado ou orientação.
- **`state.value!` depois de definir `loading`**: lança erro. Capture o valor antes.
- **Usar `BuildContext` após um `await`** sem checar `context.mounted`.
- **Exibir a exceção bruta ao usuário.**
- **`RepaintBoundary` e outras otimizações sem medir.**
- **Lista grande sem `ListView.builder`.**
- **Chave de API ou segredo dentro do app.**
- **`Isolate.run` sem considerar a web.**
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `const`, estados de carregamento, erro e dados tratados, e I/O atrás de repositórios, com links relativos.
3. Se implementar nova query em banco local (SQLite/Drift): verificação de performance e script de criação dos índices adequados.
4. Resultado de `flutter analyze` e `flutter test`, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-flutter`, P1 a P3; fallback em lista no chat).
