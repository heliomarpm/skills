---
name: -task-management
description: Gerencia, planeja, gera e atualiza tarefas do projeto no arquivo TASKS.md. Busca automaticamente em ./TASKS.md, ./agents/TASKS.md ou ./.agents/TASKS.md (com tolerância a TASK.md / task.md) para sincronizar o backlog, acompanhar o progresso e estruturar novas atividades.
allowed-tools: Read, Edit, Write, Grep, Glob
disallowed-tools: Bash
---

# Task Management Skill: Dynamic Project Backlog & Execution Tracking

Esta skill padroniza o ciclo completo de planejamento, geração, decomposição e atualização contínua de tarefas de um projeto de software. Ela garante rastreabilidade técnica, foco de execução e histórico evolutivo consistente através do arquivo padrão **`TASKS.md`** (com tolerância a **`TASK.md`** / **`task.md`**).


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `-task-management``

---

## 1. Processo de Execução Estruturado (Workflow)

### 1.1. Descoberta e Resolução do Arquivo Alvo

Ao receber uma instrução para gerar, atualizar, verificar ou decompor tarefas no projeto, o agente **deve obrigatoriamente** adotar o padrão no **plural (`TASKS.md`)** e inspecionar a existência do arquivo na seguinte ordem de precedência:

1. `./TASKS.md` (raiz do projeto)
2. `./agents/TASKS.md` (pasta de contexto de agentes)
3. `./.agents/TASKS.md` (pasta oculta de configuração de agentes)

#### Regras de Resolução:
- **Arquivo Existente Encontrado**: Utilize o primeiro arquivo localizado na lista acima. **Nunca crie um segundo arquivo** em outro local se já existir um arquivo de tarefas em qualquer uma das localizações monitoradas.
- **Tolerância a Singular (`TASK.md` / `task.md`)**: Caso não encontre nenhum `TASKS.md` (ou `tasks.md`), verifique se o projeto já adota `./TASK.md`, `./agents/TASK.md`, `./.agents/TASK.md` (ou versões em minúsculas como `./task.md`). Se algum existir, preserve a convenção encontrada para manter a compatibilidade.
- **Criação Inicial (Quando nenhum arquivo existe)**: O padrão mandatório de criação é no **plural**:
  - Se a pasta `./.agents/` existir, crie `./.agents/TASKS.md`.
  - Se a pasta `./agents/` existir, crie `./agents/TASKS.md`.
  - Caso contrário, crie diretamente na raiz do projeto: `./TASKS.md`.

---

### 1.2. Auditoria e Sincronização com a Base de Código

Antes de adicionar ou modificar qualquer tarefa:

1. **Leitura Prévia Obrigatória**: Leia o conteúdo integral do arquivo localizado. Jamais execute sobrescrita cega (*blind overwrite*).
2. **Preservação do Histórico**: Mantenha anotações manuais, links, observações do desenvolvedor e o histórico de itens concluídos (`- [x]`).
3. **Checagem de Fato com o Código**:
   - Verifique se tarefas marcadas como pendentes já foram implementadas no repositório.
   - Verifique se novas dependências, migrações ou quebras de contrato surgiram desde a última atualização.
4. **Alinhamento de Escopo**: Valide se os itens propostos atendem ao objetivo atual do projeto sem introduzir complexidade desnecessária (*scope creep*).

---

### 1.3. Decomposição e Quebra de Tarefas (Critérios INVEST)

Tarefas devem ser granulares o suficiente para serem executadas com precisão e testadas de forma determinística:

- **Independentes**: Minimizam acoplamento mútuo ou estabelecem dependências explícitas.
- **Negociáveis / Claras**: Descrevem o objetivo técnico e o valor entregue.
- **Estimáveis / Acessíveis**: Escopo delimitado a poucos arquivos ou a uma única responsabilidade lógica.
- **Pequenas (Small)**: Devem poder ser implementadas e validadas em uma única iteração de trabalho.
- **Testáveis (Testable)**: Possuem critérios claros de aceite (*Definition of Done - DoD*).

---

### 1.4. Ciclo de Vida da Tarefa e Estados de Execução

Utilize checkboxes Markdown padronizados para refletir o estado exato de cada item:

| Estado | Marcador | Significado | Ação do Agente |
| :--- | :---: | :--- | :--- |
| **Pendente** | `- [ ]` | Tarefa no backlog, aguardando início | Pronta para ser selecionada |
| **Em Progresso** | `- [/]` | Trabalho ativo em desenvolvimento | Máximo de 1 a 2 tarefas simultâneas (limite WIP) |
| **Concluída** | `- [x]` | Implementação e testes finalizados | Adicionar data/hora e referência aos arquivos alterados |
| **Bloqueada** | `- [!]` ou `🚨` | Impedimento externo ou dependência pendente | Descrever a causa do bloqueio e a ação necessária |
| **Cancelada** | `- [~]` | Escopo descartado ou substituído | Justificar sucintamente o motivo do cancelamento |

---

### 1.5. Atualização Cirúrgica e Persistência

Ao concluir uma etapa de trabalho ou ao planejar a próxima:

1. Localize o bloco exato no arquivo correspondente (`./TASKS.md`, `./agents/TASKS.md`, `./.agents/TASKS.md` ou arquivo legado em singular).
2. Mude o status dos itens concluídos para `- [x]` e atualize o indicador de progresso no topo.
3. Se novas pendências forem descobertas durante a implementação (bugs colaterais, necessidade de refatoração, débitos técnicos), registre-as imediatamente na seção correspondente de prioridade.
4. Salve o arquivo mantendo a formatação limpa e links navegáveis com o esquema `file:///`.

---

## 2. Snippets Canônicos de Referência

### 2.1. Modelo Canônico do Arquivo `TASKS.md`

```markdown
# 📋 Project Tasks & Execution Backlog

> **Status Geral**: 🟡 Em Desenvolvimento  
> **Progresso**: 3/8 concluídas (37%)  
> **Última Atualização**: 2026-09-27  
> **Arquivo**: `./TASKS.md`

---

## 🎯 Meta da Iteração / Sprint Atual
Implementar autenticação OAuth 2.1 com suporte a PKCE e proteção CSRF em APIs públicas.

---

## 🚀 1. Em Progresso (WIP - Limite: 2 tarefas)

- [/] **T-004: Implementar middleware de validação do Code Challenge (PKCE)**
  - **Ref**: [auth_middleware.ts](file:///src/middlewares/auth_middleware.ts)
  - **Critérios de Aceite**:
    - [x] Validar desafio SHA-256 com tempo constante (`timingSafeEqual`)
    - [ ] Rejeitar requisições sem `code_verifier` válido
    - [ ] Adicionar testes unitários com vetores da RFC 7636

---

## 🚨 2. Bloqueadores & Alta Prioridade

- [ ] **T-005: Corrigir vulnerabilidade de injeção de parâmetros no fluxo de callback**
  - **Ref**: [callback_handler.ts](file:///src/handlers/callback_handler.ts#L45-L60)
  - **Problema**: O parâmetro `redirect_uri` não é validado contra a whitelist pré-configurada.
  - **Ação**: Implementar validação estrita de URI com esquema `https://`.

---

## 📋 3. Backlog de Tarefas Planejadas

### Etapa 1: Camada de Domínio e Contratos
- [x] **T-001**: Definir DTOs imutáveis para Token Request e Token Response.
- [x] **T-002**: Criar entidade `AuthorizationCode` com TTL e controle de uso único.
- [ ] **T-003**: Implementar repositório Redis para armazenamento transitório de tokens.

### Etapa 2: Endpoints e Integração
- [ ] **T-006**: Criar endpoint `/oauth/v2/token` conforme especificação RFC 6749.
- [ ] **T-007**: Configurar rota de revogação `/oauth/v2/revoke` (RFC 7009).

---

## 💡 4. Débitos Técnicos & Otimizações Futuras

- [ ] **T-008**: Substituir chamadas síncronas de hash por biblioteca nativa Argon2id.
- [ ] **T-009**: Adicionar métricas Prometheus de contagem de tokens emitidos e revogados.

---

## ✅ 5. Concluído Recentemente

- [x] **T-000: Setup do ambiente de testes unitários com Vitest** *(Concluído em 2026-09-26)*
  - **Arquivos**: [vitest.config.ts](file:///vitest.config.ts), [auth.test.ts](file:///tests/auth.test.ts)
```

---

### 2.2. Exemplo de Atualização Incremental Cirúrgica

Ao atualizar o progresso após a conclusão de uma tarefa:

```diff
- > **Progresso**: 2/8 concluídas (25%)  
+ > **Progresso**: 3/8 concluídas (37%)  

## 🚀 1. Em Progresso (WIP - Limite: 2 tarefas)

-- [/] **T-003: Implementar repositório Redis para armazenamento transitório de tokens.**
+- [/] **T-004: Implementar middleware de validação do Code Challenge (PKCE)**

## ✅ 5. Concluído Recentemente

++ [x] **T-003: Implementar repositório Redis para armazenamento transitório de tokens.** *(Concluído em 2026-09-27)*
+  - **Arquivos**: [redis_token_store.ts](file:///src/storage/redis_token_store.ts)
```

---

## 3. Armadilhas Críticas em Produção (*Gotchas*)

- ⚠️ **Sobrescrita Cega (*Blind Overwrite*)**: Apagar o arquivo existente ou gerar um arquivo novo do zero quando já existia histórico, perdendo anotações, subtarefas e decisões registradas pelo desenvolvedor. **Sempre leia antes de editar.**
- ⚠️ **Multiplicação de Arquivos Descoordenados**: Criar um `./TASKS.md` na raiz quando já existia um `./.agents/TASKS.md` ou `./agents/TASKS.md` (ou seus equivalentes singulares), causando fragmentação e tarefas conflitantes.
- ⚠️ **WIP Excessivo (Ausência de Foco)**: Marcar 5 ou mais itens como "Em Progresso" simultaneamente. Mantenha no máximo 1 a 2 tarefas ativas para garantir fluxo e revisões incrementais.
- ⚠️ **Tarefas Monolíticas e Vagas**: Itens como "Refatorar backend" ou "Ajustar testes". Toda tarefa deve ter escopo delimitado, arquivo de referência e critérios observáveis de conclusão.
- ⚠️ **Dessincronização com o Código Real**: Marcar uma tarefa como concluída no markdown sem que os testes tenham passado ou sem que os arquivos tenham sido efetivamente gravados no disco.

---

## 4. Padrão Rigoroso de Entrega

Ao atuar sobre tarefas com esta skill, o agente deve garantir:

1. **Resolução Determinística**: Seguir à risca a busca em cascata no plural como padrão:
   - 1º `./TASKS.md` ➔ 2º `./agents/TASKS.md` ➔ 3º `./.agents/TASKS.md`.
   - Com verificação de tolerância para `./TASK.md`, `./agents/TASK.md`, `./.agents/TASK.md` (e variações minúsculas como `task.md`) antes de criar novo.
2. **Navegabilidade**: Todo apontamento para arquivos ou linhas deve utilizar links markdown navegáveis com o esquema `file:///`.
3. **Consistência Numérica**: Atualizar o contador ou porcentagem de progresso no cabeçalho do documento a cada transição de status.
4. **Sem Pendências Ocultas**: Nenhuma pendência descoberta durante revisões ou testes deve ficar apenas na conversa do chat; ela deve ser materializada no `TASKS.md` na seção adequada.
5. **Transparência**: Informar ao usuário exatamente qual arquivo foi lido/modificado e resumir as alterações de status realizadas.
