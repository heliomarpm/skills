---
name: -tech-python
description: "Orienta Python moderno e tipado: type hints (PEP 695 quando a versão permite), Pydantic v2 nas fronteiras, dataclasses imutáveis, Decimal para dinheiro, asyncio estruturado (TaskGroup, timeouts, trabalho bloqueante fora do loop), erros específicos, logging, empacotamento com pyproject e ferramentas (uv, ruff, mypy, pytest). Use sempre que o usuário pedir 'script em Python', 'API em Python', 'tipagem', 'asyncio', 'Pydantic', 'pyproject' ou 'migre de versão do Python', mesmo sem dizer 'Python'. NÃO use para integração com LLMs (isso é -ai-engineering), modelagem e SQL em si (isso é -sql) nem para contratos de API (isso é -api-design)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(pytest *), Bash(python -m pytest *), Bash(ruff check *), Bash(ruff format --check *), Bash(mypy *), Bash(uv run pytest *), Bash(uv run ruff *), Bash(uv run mypy *)
---

# Python: idiomático, tipado e robusto

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tech-python`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia `requires-python` no `pyproject.toml` e use só o que a versão suporta: `TaskGroup` e `except*` (3.11); sintaxe PEP 695 (`type X = ...`, `def f[T]()`) e `typing.override` (3.12). Em versões anteriores use `TypeVar` e `Generic`. Recursos novos: confirme na documentação oficial.

**Siga o projeto.** Respeite o framework (FastAPI, Django, Flask), o gerenciador de dependências (uv, Poetry, pip) e as ferramentas de qualidade existentes.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem o PEP 8.

---

## 1. Princípios

- **Tipos**: anotações em todas as assinaturas públicas; `Protocol` para contratos estruturais; verificador (`mypy` ou `pyright`) no CI.
- **Fronteiras**: Pydantic v2 para entradas externas e configuração; `@dataclass(slots=True, frozen=True)` para entidades internas imutáveis.
- **Dinheiro**: `Decimal`, nunca `float`. **Datas**: sempre com fuso (*timezone-aware*).
- **Async**: `asyncio.TaskGroup` (falha de uma tarefa cancela as outras e levanta `ExceptionGroup`, tratado com `except*`), `asyncio.timeout`, e trabalho bloqueante ou de CPU fora do loop (`asyncio.to_thread`, `ProcessPoolExecutor`).
- **Erros**: exceções específicas, `raise ... from e`, nada de `except:` vazio; `logging` com `logger.exception`, sem `print`.
- **Recursos**: `pathlib.Path`, gerenciadores de contexto, geradores para dados grandes.
- **Projeto**: `pyproject.toml`, dependências travadas (`uv.lock` ou equivalente), `ruff` para lint e formatação.
- **Segurança**: nada de `eval` ou `pickle` com dados não confiáveis; `subprocess` sem `shell=True`; consultas parametrizadas; segredos fora do código (`-security`).
- **Testes**: `pytest` com fixtures e parametrização (`-testing`).

---

## 2. Exemplos (Python 3.12+)

### 2.1. Genéricos, `Decimal` e `TaskGroup`

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

### 2.2. Decorador tipado que preserva a assinatura

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

---

## 3. Integrações

`-testing` (pytest), `-security`, `-sql`, `-api-design`, `-observability`, `-devops`, `-code-review`, `-ai-engineering` (integrações com LLM). Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Argumento padrão mutável** (`def f(x, lista=[])`): a lista é compartilhada entre chamadas. Use `None` e crie dentro da função.
- **`except:` vazio ou `except Exception: pass`**: engole erros e interrupções.
- **CPU ou chamada bloqueante dentro do loop async**: trava todas as tarefas.
- **`float` para dinheiro.**
- **`datetime` sem fuso.**
- **`shell=True` com entrada externa**: injeção de comando.
- **Efeitos colaterais na importação de módulos.**
- **Dependências sem versão travada.**

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código tipado, compatível com a versão do projeto, com links relativos.
3. Resultado de `pytest`, `ruff` e `mypy`, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `-tasks` (modo Importar, origem `tech-python`, P1 a P3; fallback em lista no chat).