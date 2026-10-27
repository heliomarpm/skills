---
name: -ai-engineering
description: "Orienta a engenharia de aplicações com LLMs: saídas estruturadas validadas, tool calling e agentes seguros, RAG (chunking, busca híbrida, reranking, permissões), avaliações (evals) com porta de regressão, defesa contra prompt injection, confiabilidade, custo e privacidade. Use sempre que o usuário pedir 'integre um LLM', 'tool calling', 'function calling', 'RAG', 'embeddings', 'agente', 'prompt', 'avalie as respostas', 'reduza alucinação' ou 'structured output', mesmo sem a expressão 'AI engineering'. NÃO use para segurança de aplicação em geral (isso é -security), contratos de API (isso é -api-design) nem para filas e arquitetura (isso é -system-design)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(pytest *), Bash(python -m pytest *), Bash(npm test *), Bash(npm run test *), Bash(npx vitest *)
---

# AI Engineering: LLMs confiáveis em produção

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-ai-engineering`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Custo e dados externos exigem confirmação.** Rodar avaliações ou testes que chamam um provedor de LLM custa dinheiro e envia dados para fora. Confirme antes e prefira respostas gravadas ou fakes nos testes de rotina.

**Detalhes de provedor mudam.** Modelos, limites, preços e parâmetros devem ser confirmados na documentação atual, não na memória. Mantenha o modelo configurável, com versão fixa, e siga o provedor e o framework que o projeto já usa.

**A saída do modelo é entrada não confiável.** Valide, escape e nunca execute sem checagem. Argumentos de ferramentas também.

**Segredos.** Chaves de API só no backend, nunca em prompts, no cliente ou em logs.

**Evidência.** Escolhas de chunking, modelo e prompt se justificam com avaliações. Números como "10 a 15% de sobreposição" são ponto de partida, não regra.

**Timebox e Circuit Breaker.** A calibração de prompts, schemas e parâmetros de IA não roda indefinidamente. Estabeleça um teto de no máximo **3 iterações de ajuste** ao tentar atingir métricas em avaliações (evals) ou validar saídas estruturadas. Ao atingir esse limite sem convergência, interrompa as chamadas ativas e acione o ponto de parada para alinhamento com o usuário (seção 6.1).

**Idioma.** O do usuário; nomes técnicos ficam como estão.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Projetar** | Definir a arquitetura da integração (RAG, agente, ferramentas) |
| **Implementar** | Escrever o código da integração |
| **Avaliar** | Montar ou rodar avaliações (seção 6) |
| **Revisar** | Auditar uma integração existente |

---

## 2. Workflow

1. **Contexto**: provedor, framework, dados, usuários e permissões, requisitos de custo, latência e privacidade. Leia `ARCHITECTURE.md` e os ADRs.
2. **Comece simples**: um prompt bem escrito com saída estruturada resolve muitos casos antes de RAG ou agentes.
3. Aplique as seções 3 a 5 ao desenho.
4. **Avaliações antes de otimizar** (seção 6) com respeito ao circuit breaker de calibração (seção 6.1).
5. Cubra segurança (seção 7) e confiabilidade (seção 8).
6. Registre as pendências (seção 10).

---

## 3. Saídas estruturadas

- Na integração com o backend, use o recurso nativo do provedor (modo JSON schema ou tool use), com **validação sempre** (Pydantic v2, Zod ou JSON Schema).
- Schemas com limites, enums e campos opcionais explícitos.
- Falha de validação: no máximo 1 ou 2 novas tentativas, devolvendo o erro ao modelo; depois, falha controlada.
- Texto livre é adequado nas respostas a pessoas, não nos dados que alimentam a lógica de negócio.
- Prompts são código: versionados no repositório, em templates, e toda mudança roda as avaliações.

---

## 4. Ferramentas e agentes

- **O modelo propõe, o sistema decide.** O que o sistema sabe (usuário da sessão, preços, permissões) nunca vem do modelo.
- Nome e descrição claros, parâmetros descritos, **autorização por usuário** dentro da ferramenta e **chave de idempotência** nas escritas.
- Ações irreversíveis ou financeiras: rascunho e **confirmação humana** antes de efetivar.
- Erro de ferramenta volta ao modelo como resultado claro, para ele se corrigir, com limite de tentativas.
- Agentes: limite de passos, de tempo e de custo; estado e memória explícitos; execução em sandbox quando houver código ou comandos.
- Ferramentas de terceiros (por exemplo MCP) são não confiáveis: revise descrições e permissões, e conceda o mínimo.

---

## 5. RAG

- **Chunking** por estrutura (títulos e seções) com tamanho e sobreposição calibrados por avaliação; metadados em cada chunk (fonte, versão, permissões).
- **Busca híbrida**: vetorial mais lexical (BM25), com fusão por posição (**RRF**), seguida de **reranking** dos melhores candidatos.
- **Permissões antes da recuperação**: filtre por usuário, grupo e tenant na própria busca. Sem isso, a resposta vaza documentos entre usuários.
- **Grounding**: o modelo cita as fontes e responde que não encontrou quando o contexto é insuficiente.
- **Embeddings** têm versão: trocar de modelo exige reindexar. Decida entre vetor no banco (`-sql`) e serviço dedicado com um ADR (`-adr`).
- Mantenha o índice atualizado: reindexação por mudança de documento e remoção de conteúdo apagado.

---

## 6. Avaliações (evals)

Sem avaliação, melhorias são opinião. A base:

- **Conjunto de referência** versionado, com casos reais, de borda e adversariais, sem dados pessoais.
- **Métricas de RAG**: recall@k e MRR da recuperação; fidelidade ao contexto e relevância da resposta na geração.
- **Ferramentas e agentes**: escolha correta da ferramenta, argumentos corretos, número de passos.
- **Juiz-LLM** com ressalvas: pode ter viés, então calibre contra amostras avaliadas por pessoas.
- **Porta de regressão no CI** com limites mínimos; qualquer troca de modelo, prompt, chunking ou embedding roda as avaliações.
- **Tráfego real**: amostre respostas de produção (com privacidade) para alimentar o conjunto.

### 6.1. Ponto de parada: circuit breaker em avaliações

Ajustes de prompt, temperatura ou chunking para aprovação em evals ou validação de schemas não devem rodar indefinidamente. Estabeleça um teto de no máximo **3 iterações de ajuste**:

1. Se após 3 rodadas a métrica mínima não for atingida na porta de regressão ou a validação de schema continuar falhando: pare imediatamente e não dispare novas chamadas à API do modelo.
2. Apresente o estado: métrica observada contra a meta, exemplos específicos de casos que falharam e o custo/latência acumulados.
3. Faça o check-in de continuidade:

> *"Atingi o limite do circuit breaker (3 rodadas de ajuste) sem atingir a meta da porta de regressão para `[funcionalidade/métrica]`. Como deseja proceder?*  
> 1. **Mudar de estratégia**: adicionar few-shot examples ou decompor o prompt em etapas  
> 2. **Ajustar critérios/tolerância**: flexibilizar a métrica de aprovação ou refinar o conjunto de teste  
> 3. **Trocar o modelo**: avaliar um modelo mais capaz (considerando impacto em custo/latência)  
> 4. **Pausar e registrar pendência**: manter o baseline atual e registrar o débito no `TASKS.md` (via `-tasks`)*"

Aguarde a orientação do usuário antes de realizar novas chamadas a provedores ou alterações.

---

## 7. Segurança

Referência: OWASP Top 10 para aplicações com LLM; geral no `-security`.

- **Prompt injection direta e indireta**: o texto de documentos recuperados, páginas e saídas de ferramentas também pode conter instruções hostis. Delimitar o conteúdo ajuda, mas não resolve sozinho.
- **Privilégio mínimo** para ferramentas e credenciais do agente; o que o modelo não precisa fazer, ele não consegue fazer.
- **Saída não confiável**: escape antes de renderizar em HTML, nunca monte SQL ou comandos com ela.
- **Exfiltração**: bloqueie links e imagens markdown para domínios externos na saída renderizada.
- **Humano no circuito** para ações destrutivas ou irreversíveis.
- **Abuso**: rate limit e orçamento por usuário.

---

## 8. Confiabilidade, custo, privacidade e observabilidade

- **Falhas**: timeout; retry com backoff e jitter só em erros transitórios (429, 5xx), respeitando `Retry-After`; fallback de modelo; tratamento de resposta truncada (motivo de parada) e de `max_tokens`.
- **Custo**: orçamento de tokens por requisição e por usuário, cache de prompt e de resposta quando cabe, e histórico longo por janela deslizante ou resumo.
- **Migração de modelo**: com versão fixa e avaliações, a troca é uma decisão medida.
- **Privacidade**: PII redigida antes de enviar ao provedor, termos de retenção do provedor, LGPD.
- **Observabilidade** (`-observability`): trace por chamada com versão do prompt e do modelo, tokens, custo, latência e motivo de parada. Não registre prompts completos nem PII sem política.

---

## 9. Exemplos de referência

### 9.1. Ferramenta com schema estrito (TypeScript e Zod)

```typescript
import { z } from 'zod';

interface Sessao {
  usuarioId: string;
}

// O modelo propõe; o sistema decide. Preço e cliente NÃO vêm do modelo.
export const CriarPedidoArgs = z
  .object({
    itens: z
      .array(
        z.object({
          sku: z.string().regex(/^[A-Z]{3}-\d{4}$/),
          quantidade: z.number().int().positive().max(100),
        }),
      )
      .min(1)
      .max(50),
    enderecoEntregaId: z.string().uuid(), // endereço já cadastrado do usuário
  })
  .strict();

export const definicaoFerramenta = {
  name: 'criar_pedido',
  description:
    'Prepara um pedido com os itens informados. O pedido só é efetivado após a confirmação do usuário.',
  // Zod 4: z.toJSONSchema. No Zod 3, use zod-to-json-schema. O formato varia por provedor.
  parameters: z.toJSONSchema(CriarPedidoArgs),
};

export async function executarCriarPedido(args: unknown, sessao: Sessao): Promise<void> {
  const dados = CriarPedidoArgs.parse(args); // argumentos do modelo são entrada não confiável
  // 1. Autorizar: o endereço pertence a sessao.usuarioId?
  // 2. Preços e disponibilidade vêm do catálogo, não do modelo.
  // 3. Gravar como rascunho e pedir confirmação humana; efetivar com chave de idempotência.
  void dados;
  void sessao;
}
```

### 9.2. Recuperação híbrida com permissões e RRF (Python, conceitual)

```python
import asyncio
from collections import defaultdict
from typing import Any


def rrf(rankings: list[list[str]], k: int = 60) -> list[str]:
    """Fusão por posição (Reciprocal Rank Fusion)."""
    scores: dict[str, float] = defaultdict(float)
    for ranking in rankings:
        for pos, doc_id in enumerate(ranking, start=1):
            scores[doc_id] += 1.0 / (k + pos)
    return sorted(scores, key=scores.get, reverse=True)


async def retrieve(query: str, usuario, top_k: int = 5) -> list[dict[str, Any]]:
    # Permissões aplicadas NA busca, antes de recuperar
    filtro = {"tenant": usuario.tenant_id, "acl": usuario.grupos}

    densos, lexicais = await asyncio.gather(
        vector_store.search(query, k=top_k * 4, filtro=filtro),
        lexical_index.search(query, k=top_k * 4, filtro=filtro),
    )

    candidatos = {d["id"]: d for d in densos + lexicais}
    ordem = rrf([[d["id"] for d in densos], [d["id"] for d in lexicais]])[: top_k * 4]

    # O reranker recebe só os melhores candidatos da fusão
    reranqueados = await reranker.rerank(
        query, [candidatos[i]["text"] for i in ordem], top_n=top_k
    )
    return [candidatos[ordem[r.index]] for r in reranqueados]
```

---

## 10. Registro via `-tasks` e integrações

Se houver pendências, pergunte ao final:

> *"Deseja que eu registre as pendências e avaliações no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `ai-engineering`, links relativos e a prioridade: ferramenta destrutiva sem confirmação e chave exposta P0; falta de avaliação e de validação de schema P1; resiliência e custo P2; ajustes P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `-security` | OWASP LLM Top 10, segredos e abuso |
| `-api-design` | Endpoint, streaming e contratos |
| `-testing` | Testes determinísticos com fakes ou respostas gravadas |
| `-system-design` | Inferência assíncrona, filas e cache |
| `-sql` | Vetores e busca no banco |
| `-observability` | Traces, tokens e custo |
| `-devops` | Porta de avaliação no CI |
| `-adr` | Provedor, banco vetorial e estratégia de RAG |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 11. Armadilhas

- **JSON sem validação de schema**: quebra com campos faltantes ou alucinados.
- **Dados do sistema vindos do modelo**: preço, cliente e permissões decididos pelo modelo.
- **RAG sem filtro de permissão**: vaza documentos entre usuários.
- **Otimizar sem avaliação**: mudanças de chunking ou prompt viram opinião.
- **Confiar em documentos recuperados**: injeção indireta.
- **Ação destrutiva sem confirmação humana.**
- **Chave de API no cliente.**
- **Modelo sem versão fixa**: o comportamento muda sem aviso.
- **Retry sem limite**: amplifica custo e falhas.
- **Loop de calibração cego (*prompt loop*)**: ajustar sucessivamente prompts e rodar avaliações repetidas vezes sem pausar para alinhar com o usuário quando as métricas estagnarem.
- **Registrar prompts completos e PII em logs.**
- **Juiz-LLM sem calibração**: mede o viés do juiz.

---

## 12. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Premissas declaradas (provedor, dados, permissões, requisitos) e o que precisa de confirmação na documentação atual.
3. Arquivos criados ou alterados, com links relativos, e o resultado dos testes ou o motivo de não ter executado.
4. Plano de avaliação, riscos de segurança tratados e, se interrompido pelo circuit breaker, o relato e check-in da seção 6.1.
5. Pendências e a pergunta sobre o registro em tarefas (seção 10).