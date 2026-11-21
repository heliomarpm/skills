# Padrões e Exemplos de Python 3.12+ (`sk-tech-python`)

## 1. Genéricos, `Decimal` e `TaskGroup`

```python
import asyncio
import logging
from dataclasses import dataclass
from decimal import Decimal

logger = logging.getLogger(__name__)

type IdEntidade = str | int


@dataclass(slots=True, frozen=True)
class Transacao[T]:
    id: IdEntidade
    carga: T
    valor: Decimal


async def processar[T](tx: Transacao[T]) -> bool:
    await asyncio.sleep(0.05)  # simula I/O não bloqueante
    return True


async def processar_lote[T](transacoes: list[Transacao[T]]) -> list[bool]:
    async with asyncio.TaskGroup() as tg:
        tarefas = [tg.create_task(processar(tx)) for tx in transacoes]
    return [t.result() for t in tarefas]


async def principal(lote: list[Transacao[str]]) -> None:
    try:
        resultados = await processar_lote(lote)
    except* ValueError as grupo:  # TaskGroup agrupa as falhas em um ExceptionGroup
        logger.error("falhas de validação: %s", grupo.exceptions)
    else:
        logger.info("lote concluído: %d itens", len(resultados))
```

## 2. Decorador tipado que preserva a assinatura

```python
import logging
import time
from collections.abc import Callable
from functools import wraps

logger = logging.getLogger(__name__)


def medir_tempo[**P, R](func: Callable[P, R]) -> Callable[P, R]:
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        inicio = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            logger.info("%s executada em %.4fs", func.__name__, time.perf_counter() - inicio)

    return wrapper
```
