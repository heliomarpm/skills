# Padrões e Exemplos de Flutter (`sk-tech-flutter`)

## 1. Estado assíncrono com Riverpod e UI declarativa

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

## 2. Processamento pesado fora da thread de interface

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
