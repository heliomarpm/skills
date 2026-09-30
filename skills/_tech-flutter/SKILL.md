---
name: _tech-flutter
description: Orienta o desenvolvimento de aplicativos com Flutter e Dart. Use ao construir interfaces móveis, organizar estado da aplicação, navegar entre telas e gerenciar recursos do dispositivo.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(flutter test *), Bash(flutter analyze *), Bash(dart test *), Bash(dart analyze *)
---

# Tech Skill: Flutter & Dart Specialist (Dart 3+ & Modern Flutter)

Diretrizes técnicas especializadas para a criação de aplicativos móveis fluidos (60/120 FPS), responsivos e escaláveis com Flutter e Dart.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-flutter``

---

## 1. Processo de Execução de Engenharia Flutter

Ao desenvolver telas e fluxos em Flutter:

1. **Modelagem com Dart 3 (Records & Sealed Classes)**: Modele dados de domínio com imutabilidade estrita e use *sealed classes* para estados previsíveis da UI.
2. **Gerenciamento de Estado com Riverpod / BLoC**:
   - Utilize **Riverpod 2.x com gerador de código** (`@riverpod`, `AsyncNotifier`) e trate estados com `AsyncValue.when()`.
   - Mantenha os widgets puramente visuais e declarativos (Stateless).
3. **Otimização de Renderização & Descarte de Recursos**: Aplique construtores `const`, isole animações frequentes com `RepaintBoundary` e garanta o fechamento de controladores no `dispose()`.
4. **Navegação Declarativa com `go_router`**: Estruture rotas fortemente tipadas e proteja acessos a telas privadas com redirecionamentos centralizados.
5. **Processamento Pesado em Isolates**: Execute parsing de grandes arquivos JSON e processamento de imagem fora da thread principal utilizando `Isolate.run()`.

---

## 2. Snippets Canônicos de Referência

### 2.1. Riverpod 2.x com Notifier Assíncrono e UI Declarativa
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_notifier.g.dart';

@immutable
sealed class UserState {
  const UserState();
}

class UserProfileData extends UserState {
  final String id;
  final String name;
  const UserProfileData({required this.id, required this.name});
}

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  FutureOr<UserProfileData> build(String userId) async {
    // Chamada assíncrona ao repositório
    return UserProfileData(id: userId, name: 'Carlos Eduardo');
  }

  Future<void> updateName(String newName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Simulação de atualização na API
      return UserProfileData(id: state.value!.id, name: newName);
    });
  }
}

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileNotifierProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: userAsync.when(
        data: (user) => Center(child: Text('Bem-vindo, ${user.name}')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
```

### 2.2. Parsing de JSON Pesado em Background com `Isolate.run`
```dart
import 'dart:convert';
import 'dart:isolate';

Future<List<Map<String, dynamic>>> parseLargeJsonPayload(String rawJson) async {
  // Executa o parsing em uma thread isolada sem travar a renderização (UI thread)
  return await Isolate.run(() {
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  });
}
```

---

## 3. Armadilhas Críticas em Flutter (*Gotchas*)

- ⚠️ **Controladores Não Descartados no `dispose()`**: Deixar de chamar `dispose()` em instâncias de `TextEditingController`, `AnimationController` ou `ScrollController` impede o Garbage Collector de liberar os recursos, causando *Memory Leaks* graves.
- ⚠️ **Rebuilds Globais por Uso Incorreto de `MediaQuery`**: Chamar `MediaQuery.of(context)` inteiro para ler apenas o tamanho da tela faz o widget reconstruir a cada abertura do teclado virtual. Use a API granular: `MediaQuery.sizeOf(context)`.
- ⚠️ **Repintura de Tela Inteira em Animações**: Animar widgets com atualizações contínuas de layout sem envolvê-los em um `RepaintBoundary` força o Flutter a repintar todos os elementos estáticos vizinhos na tela.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em Flutter / Dart:
1. Use construtores `const` em todos os widgets e instâncias estáticas.
2. Isole chamadas de rede e persistência atrás de contratos de repositório abstratos.
3. Garanta tratamento de estados assíncronos (Loading, Error, Data) em todas as telas.
