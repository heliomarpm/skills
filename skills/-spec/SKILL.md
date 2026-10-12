---
name: -sdd
description: "Orienta a criação e manutenção de artefatos de Spec-Driven Development (SDD), como arquivos SPEC.md, garantindo que o desenvolvimento seja guiado por especificações claras, testáveis e compreensíveis por IA."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
---

# 📝 Spec-Driven Development (SDD) Skill

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧠 **Skill Ativa**: \`-sdd\``

Esta skill fornece diretrizes detalhadas para atuar no modelo **Spec-Driven Development (SDD)**, onde a especificação (comportamento, arquitetura, contratos) é o artefato central que antecede e guia toda a implementação de código.

---

## 1. Processo de Execução Estruturado (Workflow)

1. **Discovery / Entendimento:** Se o usuário solicitar uma funcionalidade de forma vaga, faça perguntas objetivas ou ofereça um esboço (rascunho mental) para delimitar o escopo antes de gerar a especificação completa.
2. **Geração do Artefato:** Escreva o arquivo `SPEC.md` (ou arquivo equivalente, ex: `.agents/specs/<nome-da-feature>.md` ou `docs/specs/<nome-da-feature>.md`) utilizando a Estrutura Canônica. Seja o mais específico e determinístico possível quanto a nomes de variáveis, schemas e regras.
3. **Ponto de Parada Obrigatório (Check-in):** Após gerar a especificação, **PARE E SOLICITE FEEDBACK**. Peça ao usuário para revisar, ajustar ou aprovar o conteúdo. **NÃO avance para a geração de código sem validação explícita.**
4. **Evolução Contínua (Single Source of Truth):** Durante a fase de codificação, caso uma limitação técnica exija mudança de rota, **atualize o documento de especificação primeiro** antes de alterar o código.

---

## 2. Estrutura Canônica de um `SPEC.md`

Ao gerar uma especificação, utilize os seguintes tópicos (ajustando a profundidade conforme a necessidade):

### 1. Visão Geral (Overview)
- **Objetivo:** O que está sendo construído e o problema que resolve.
- **Escopo:** O que está dentro e o que está fora do escopo.

### 2. Casos de Uso (Use Cases)
- Interação do ator (usuário ou sistema) com a funcionalidade.

### 3. Requisitos Técnicos
- **Funcionais:** Comportamentos esperados.
- **Não Funcionais:** Restrições de performance, segurança, resiliência, escalabilidade.

### 4. Contratos de Integração (API / Mensageria)
- Endpoints REST, queries GraphQL, contratos gRPC ou schemas de eventos.
- Payload explícito de Request/Response e códigos de status HTTP.

### 5. Modelo de Dados (Data Model)
- Estrutura de BD, `erDiagram` (Mermaid) ou schemas estritos NoSQL.

### 6. Regras de Negócio e Casos Limite (Edge Cases)
- Lógica condicional, cálculos, tratamentos de exceções.

### 7. Critérios de Aceite (Acceptance Criteria)
- Regras testáveis e binárias (Definition of Done), recomendando a sintaxe BDD (`Given` / `When` / `Then`).

### 8. Plano de Implementação (Task List)
- Quebra da especificação em etapas técnicas menores. Pode alimentar o `TASKS.md`.

---

## 3. Armadilhas em Produção (Gotchas)

- **Ambiguidade:** Deixar a especificação sem nomes exatos de campos no banco ou na API. Isso força a IA a "adivinhar" durante a codificação.
- **Divergência Contrato vs Código:** Atualizar o código por uma restrição técnica descoberta de última hora e não refletir a alteração no `SPEC.md`.
- **Pulando o Ponto de Parada:** Assumir a aprovação tácita e começar a gerar código em cascata sem a validação do usuário.

---

## 4. Padrão Rigoroso de Entrega

- **Sem Código de Produção Antecipado:** Nunca inclua código de implementação no seu retorno ao usuário antes da aprovação do SPEC.
- **Cobertura 1:1:** O código dos testes automatizados (`-testing`) deve espelhar exatamente os "Critérios de Aceite" do SPEC.
- **Integração:** Combine esta skill com `-arch-adr` (decisões arquiteturais), `-api-design` (boas práticas de contrato) e `-task-management` (para organizar a execução).
