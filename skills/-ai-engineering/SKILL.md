---
name: -ai-engineering
description: "Orienta a engenharia de aplicações com IA generativa e LLMs: Tool/Function Calling com schemas estritos (Pydantic/Zod), pipelines de RAG (chunking semântico, busca híbrida), Structured Outputs, guardrails e mitigação de alucinações."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(pytest *), Bash(python *), Bash(npm test *)
---

# Global Skill: AI Engineering, LLM Patterns & RAG Systems (Language-Agnostic)

Esta skill orienta o desenvolvimento de software robusto integrado a Modelos de Linguagem de Larga Escala (LLMs), agentes autônomos e sistemas de Recuperação Aumentada por Geração (RAG). Ela estabelece padrões de engenharia para transformar respostas probabilísticas de IA em fluxos determinísticos, auditáveis e resilientes para produção.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧠 **Skill Ativa**: `-ai-engineering``

---

## 1. Processo de Execução em Engenharia de IA

Ao projetar integrações com LLMs, agentes ou fluxos de recuperação:

1. **Saídas Estruturadas & Schemas Rígidos (Zero Texto Livre para Integrações)**:
   - Toda comunicação entre o modelo e sistemas backend deve utilizar **Structured Outputs** validados por esquemas de tipagem estrita (**Pydantic v2** em Python, **Zod** em TypeScript/Node, ou **JSON Schema** nativo).
   - Defina validações de limites, expressões regulares e campos opcionais explícitos.
2. **Design de Ferramentas Idempotentes (*Tool / Function Calling*)**:
   - Cada ferramenta fornecida ao agente deve ter nome semântico autoexplicativo, descrição rica e parâmetros com descrições detalhadas.
   - Ferramentas de mutação crítica (pagamentos, deleção) devem implementar confirmação explícita ou *Human-in-the-loop*.
   - Tratamento de erro resiliente: se a chamada da ferramenta falhar, retorne uma mensagem de erro clara como *tool response* para que o modelo possa se auto-corrigir.
3. **Pipeline de RAG de Alta Precisão (Recuperação Aumentada)**:
   - **Chunking Semântico**: Prefira quebras por parágrafo/seção lógica com sobreposição (*overlap* de 10% a 15%) em vez de quebras cegas por contagem de caracteres.
   - **Busca Híbrida**: Combine busca vetorial densa (similaridade de cosseno em embeddings) com busca esparsa lexical (**BM25 / Full-Text Search**) para capturar jargões e códigos exatos.
   - **Reranking**: Utilize modelos de reranking (Cohere, Cross-Encoders) nos top-N resultados antes de injetar os documentos no contexto do prompt.
   - **Grounding & Citação**: Force o modelo a citar fontes exatas e responder *"Não encontrei informações nos documentos fornecidos"* quando o contexto for insuficiente.
4. **Gerenciamento de Janela de Contexto & Sanitização de Prompts**:
   - Monitore o consumo de tokens e aplique estratégias de *sliding window* ou resumo semântico para histórico de conversas longas.
   - Isole instruções do sistema (*system prompt*) do conteúdo não confiável fornecido pelo usuário para prevenir ataques de **Prompt Injection**.

---

## 2. Snippets Canônicos de Referência

### 2.1. Tool Calling com Validação de Schema Estrito (TypeScript + Zod)
```typescript
import { z } from 'zod';

// 1. Schema rígido com validações determinísticas
export const CreateOrderToolSchema = z.object({
  customerId: z.string().uuid({ message: "O ID do cliente deve ser um UUID válido." }),
  items: z.array(
    z.object({
      sku: z.string().regex(/^[A-Z]{3}-\d{4}$/, { message: "SKU deve seguir o formato ABC-1234." }),
      quantity: z.number().int().positive({ message: "Quantidade deve ser inteira e positiva." }),
      unitPrice: z.number().positive(),
    })
  ).min(1, { message: "O pedido deve conter ao menos 1 item." }),
  shippingAddress: z.object({
    street: z.string().min(5),
    zipCode: z.string().regex(/^\d{5}-\d{3}$/, { message: "CEP no formato 00000-000." }),
  }),
});

export type CreateOrderParams = z.infer<typeof CreateOrderToolSchema>;

// 2. Definição da ferramenta para o LLM
export const createOrderToolDefinition = {
  name: "create_order",
  description: "Registra um novo pedido de compra no sistema com itens, valores e endereço de entrega.",
  parameters: zodToJsonSchema(CreateOrderToolSchema),
};
```

### 2.2. Pipeline de Busca Híbrida RAG com Reranker (Conceitual Python)
```python
from typing import List, Dict, Any

class HybridRAGPipeline:
    def __init__(self, vector_store, lexical_index, reranker_client):
        self.vector_store = vector_store
        self.lexical_index = lexical_index
        self.reranker = reranker_client

    async def retrieve(self, query: str, top_k: int = 5) -> List[Dict[str, Any]]:
        # 1. Busca vetorial densa (semântica) e busca lexical BM25 (termos exatos)
        dense_results = await self.vector_store.similarity_search(query, k=top_k * 2)
        sparse_results = await self.lexical_index.search(query, k=top_k * 2)

        # 2. Desduplicação por ID do documento
        combined = {doc["id"]: doc for doc in dense_results + sparse_results}.values()

        # 3. Reranking com modelo de alta precisão
        scored_docs = await self.reranker.rerank(
            query=query, 
            documents=[doc["text"] for doc in combined],
            top_n=top_k
        )
        return scored_docs
```

---

## 3. Armadilhas Críticas em Engenharia de IA (*Gotchas*)

- ⚠️ **Confiar em JSON sem Validação de Schema**: Presumir que o modelo sempre retornará JSON com a estrutura solicitada. Sem `try/catch` e parser de schema, caracteres de escape ou alucinações de campos quebram a aplicação em produção.
- ⚠️ **RAG com Chunks Grandes sem Overlap**: Chunks de 2.000 tokens perdem a especificidade semântica dos embeddings; chunks sem sobreposição cortam frases e raciocínios pela metade, degradando a resposta.
- ⚠️ **Vazamento de Chaves de API no Frontend**: Invocar APIs de LLM diretamente do cliente web/mobile expondo a API Key. Todo tráfego deve passar por um gateway/backend seguro com rate-limiting.
- ⚠️ **Execução Cega de Ações Destrutivas por Agentes**: Permitir que agentes excluam registros ou executem comandos de sistema sem barreira humana (*Human-in-the-loop*) ou confirmação reversível.

---

## 4. Padrão Rigoroso de Entrega

Ao implementar fluxos de IA:
1. **Assinatura Obrigatória**: Iniciar a resposta com `> 🧠 **Skill Ativa**: -ai-engineering`.
2. **Schemas Exaustivos**: Todo input/output de LLM para lógica de negócio deve possuir schema de validação (Pydantic/Zod).
3. **Resiliência a Falhas**: Inclua tratamento explícito para timeouts de inferência, rate-limits do provedor (HTTP 429) e respostas truncadas.
4. **Integração com Tarefas**: Ao finalizar integrações de IA, pergunte ao usuário se deseja registrar pendências ou avaliações de prompt em `TASKS.md` via `-task-management`.
