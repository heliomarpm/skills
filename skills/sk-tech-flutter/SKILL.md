---
name: sk-tech-flutter
description: "Orienta aplicativos Flutter e Dart: Dart 3 (records, tipos selados, pattern matching), gerenciamento de estado (Riverpod ou BLoC), arquitetura em camadas com repositórios, renderização eficiente, descarte de recursos, navegação com go_router, isolates, tratamento de erros, segurança no dispositivo e testes. Use sempre que o usuário pedir 'tela em Flutter', 'Riverpod', 'estado', 'navegação', 'otimize o desempenho do app', 'isolate' ou 'migre de versão do Flutter', mesmo sem dizer 'Flutter'. NÃO use para tokens e acessibilidade em profundidade (isso é sk-design-system), contratos de API (isso é sk-api-design) nem para segurança em profundidade (isso é sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(flutter test *), Bash(flutter analyze *), Bash(dart test *), Bash(dart analyze *), Bash(dart format --set-exit-if-changed *)
---

# Flutter: interfaces fluidas, estado previsível

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-flutter`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia o SDK do Dart e do Flutter no `pubspec.yaml` e a versão do pacote de estado em uso. As APIs do Riverpod, do `go_router` e dos geradores de código mudam entre versões principais: **confirme na documentação oficial da versão do projeto** antes de aplicar um exemplo.

**Siga o projeto.** Respeite a solução de estado (Riverpod, BLoC), a estrutura de pastas e o sistema de design existentes.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem as convenções do Dart.

---

## 1. Princípios

- **Dart 3**: records, classes seladas e `switch` com padrões para estados previsíveis; segurança contra nulos sempre; dados imutáveis.
- **Camadas**: apresentação (widgets sem lógica de negócio), domínio e dados; I/O atrás de **repositórios** com interface abstrata, o que viabiliza testes.
- **Estado**: Riverpod (com `AsyncNotifier`) ou BLoC, conforme o projeto; widgets declarativos que apenas leem o estado.
- **Renderização**: construtores `const`, widgets pequenos, `ListView.builder` para listas, `ref.watch(...select(...))` para reconstruir só o necessário, `MediaQuery.sizeOf(context)` em vez de `MediaQuery.of(context)`. `RepaintBoundary` e outras otimizações **só com medição** (DevTools, em modo *profile*).
- **Ciclo de vida**: descarte `TextEditingController`, `AnimationController` e `ScrollController` no `dispose()`; após um `await`, confira `context.mounted` antes de usar o `BuildContext`.
- **Navegação**: `go_router` com rotas tipadas e redirecionamentos centralizados para telas privadas.
- **Processamento pesado** fora da thread de interface: `Isolate.run` (não existe na web; use `compute` ou um *web worker* nesse caso).
- **Erros**: mapeie para mensagens ao usuário; nunca exiba a exceção bruta; registre em um serviço de observabilidade (`sk-observability`).
- **Segurança**: nenhuma chave secreta dentro do app (é extraível); armazenamento seguro para tokens; validação no servidor (`sk-security`).
- **Acessibilidade**: `Semantics`, contraste, alvos de toque e texto ampliável (`sk-design-system`).
- **Testes**: testes de widget, *golden*, `integration_test` e `mocktail`, com repositórios falsos (`sk-testing`).

---

## 2. Exemplos

### 2.1. Estado assíncrono com Riverpod e UI declarativa

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'perfil_notifier.g.dart';

@immutable
class Perfil {
  const Perfil({required this.id, required this.nome});
  final String id;
  final String nome;
}

abstract interface class PerfilRepository {
  Future<Perfil> buscar(String id);
  Future<Perfil> renomear(String id, String nome);
}

// perfilRepositoryProvider: provider do repositório, definido na camada de dados.

@riverpod
class PerfilNotifier extends _$PerfilNotifier {
  @override
  Future<Perfil> build(String id) => ref.watch(perfilRepositoryProvider).buscar(id);

  Future<void> renomear(String novoNome) async {
    final atual = state.requireValue; // captura ANTES de alterar o estado
    state = const AsyncLoading<Perfil>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(perfilRepositoryProvider).renomear(atual.id, novoNome),
    );
  }
}

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfil = ref.watch(perfilNotifierProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: perfil.when(
        data: (p) => Center(child: Text('Bem-vindo, ${p.nome}')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Não foi possível carregar o perfil.')),
      ),
    );
  }
}
```

### 2.2. Processamento pesado fora da thread de interface

```dart
import 'dart:convert';
import 'dart:isolate';

// Mobile e desktop. Na web, Isolate.run não está disponível: use compute() ou um web worker.
Future<List<Map<String, dynamic>>> parseJsonGrande(String bruto) {
  return Isolate.run(
    () => (jsonDecode(bruto) as List<dynamic>).cast<Map<String, dynamic>>(),
  );
}
```

---

## 3. Integrações

`sk-design-system` (tokens e acessibilidade), `sk-testing`, `sk-security` (armazenamento e segredos), `sk-api-design` (contratos), `sk-observability` (erros e desempenho), `sk-devops` (build e distribuição), `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Controladores sem `dispose()`**: vazamento de memória.
- **`MediaQuery.of(context)` só para o tamanho**: reconstrói a cada mudança de teclado ou orientação.
- **`state.value!` depois de definir `loading`**: lança erro. Capture o valor antes.
- **Usar `BuildContext` após um `await`** sem checar `context.mounted`.
- **Exibir a exceção bruta ao usuário.**
- **`RepaintBoundary` e outras otimizações sem medir.**
- **Lista grande sem `ListView.builder`.**
- **Chave de API ou segredo dentro do app.**
- **`Isolate.run` sem considerar a web.**

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `const`, estados de carregamento, erro e dados tratados, e I/O atrás de repositórios, com links relativos.
3. Resultado de `flutter analyze` e `flutter test`, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-flutter`, P1 a P3; fallback em lista no chat).