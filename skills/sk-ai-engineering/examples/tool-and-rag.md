# Exemplos de Tool Calling e RAG Híbrido (`sk-ai-engineering`)

## 1. Ferramenta com schema estrito (TypeScript e Zod)

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

## 2. Recuperação híbrida com permissões e RRF (Python, conceitual)

```python
import asyncio
from collections import defaultdict
from typing import Any, Protocol


class Usuario(Protocol):
    tenant_id: str
    grupos: list[str]


def rrf(rankings: list[list[str]], k: int = 60) -> list[str]:
    """Fusão por posição (Reciprocal Rank Fusion)."""
    scores: dict[str, float] = defaultdict(float)
    for ranking in rankings:
        for pos, doc_id in enumerate(ranking, start=1):
            scores[doc_id] += 1.0 / (k + pos)
    return sorted(scores, key=lambda doc_id: scores[doc_id], reverse=True)


async def retrieve(query: str, usuario: Usuario, top_k: int = 5) -> list[dict[str, Any]]:
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
