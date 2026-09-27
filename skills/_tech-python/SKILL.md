---
name: _tech-python
description: Orienta o desenvolvimento em Python. Use ao escrever scripts, serviços de backend, APIs, validação de dados, tarefas concorrentes e pacotes seguindo os padrões idiomáticos da linguagem.
---

# Tech Skill: Pythonic & Robust Software Engineering (Python 3.11/3.12/3.13+)

Diretrizes técnicas especializadas para o desenvolvimento em Python idiomático, fortemente tipado e com alta performance.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-python``

---

## 1. Processo de Execução de Engenharia Python

Ao implementar código em Python:

1. **Definição de Tipos e Generics Modernos**: Utilize a sintaxe PEP 695 (`type MyType = ...` e `def func[T](val: T):`) com tipagem estrita em todas as assinaturas.
2. **Modelagem de Fronteira com Pydantic v2**: Valide entradas externas e configurações com `BaseModel` e `@field_validator` / `@model_validator`.
3. **Estrutura Interna de Dados**: Utilize `@dataclass(slots=True, frozen=True)` para entidades puramente em memória e imutáveis.
4. **Concorrência Estruturada com AsyncIO**: Orquestre operações de I/O concorrentes utilizando `asyncio.TaskGroup()` e trate exceções em tarefas com `except*`.
5. **Automação e Tooling Moderno**: Utilize `uv` para gestão de dependências e `ruff` para formatação/linting padronizado via `pyproject.toml`.

---

## 2. Snippets Canônicos de Referência

### 2.1. Sintaxe de Generics PEP 695 & Concorrência com TaskGroup
```python
import asyncio
from typing import override
from dataclasses import dataclass

# PEP 695: Declaração nativa de tipo genérico e alias
type EntityId = str | int

@dataclass(slots=True, frozen=True)
class Transaction[T]:
    id: EntityId
    payload: T
    amount: float

class PaymentProcessor:
    async def process_transaction[T](self, tx: Transaction[T]) -> bool:
        await asyncio.sleep(0.05)  # Simula I/O não bloqueante
        return True

async def process_batch[T](transactions: list[Transaction[T]]) -> list[bool]:
    results: list[bool] = []
    processor = PaymentProcessor()

    # AsyncIO estruturado: falhas em uma tarefa cancelam as demais com segurança
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(processor.process_transaction(tx)) for tx in transactions]

    return [task.result() for task in tasks]
```

### 2.2. Tipagem de Decoradores com ParamSpec
```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar
import time

P = ParamSpec("P")
R = TypeVar("R")

def measure_time(func: Callable[P, R]) -> Callable[P, R]:
    """Decorador type-safe que preserva a assinatura e tipos originais da função."""
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            elapsed = time.perf_counter() - start
            print(f"[{func._name__}] Executado em {elapsed:.4f}s")
    return wrapper
```

---

## 3. Armadilhas Críticas em Python (*Gotchas*)

- ⚠️ **Argumentos Padrão Mutáveis**: Definir argumentos com valores mutáveis como `def add_item(item, list=[])` faz a lista ser compartilhada entre todas as invocações da função. Use `def add_item(item, list: list[str] | None = None)`.
- ⚠️ **Captura Genérica de Exceções**: Usar `except: pass` engole exceções do sistema como `KeyboardInterrupt` e mascara bugs graves de código. Sempre capture exceções específicas (`except ValueError:`) ou trate com `logger.exception()`.
- ⚠️ **CPU-Bound Bloqueando AsyncIO**: Executar processamento pesado de CPU (ex: cálculos matemáticos em loops puros de Python) dentro do loop de eventos assíncrono trava todas as demais requisições. Delegue para `ProcessPoolExecutor` ou bibliotecas C (NumPy/Polars).

---

## 4. Padrão de Entrega do Agente

Ao entregar código em Python:
1. Inclua type hints em 100% dos parâmetros e retornos.
2. Use `pathlib.Path` para manipulação de arquivos e caminhos.
3. Forneça código compatível com Python 3.12+ e validado para `mypy`/`ruff`.
