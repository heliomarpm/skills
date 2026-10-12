# 🧭 Guia Spec-Driven Development (SDD) "For Dummies"
> **O Manual Definitivo: O que o Humano faz (Manual) vs O que a IA faz (Automático)**

---

## 💡 A Analogia Básica (Para Nunca Mais Esquecer)

Imagine que desenvolver software com IA é igual a construir uma casa:

| Termo | O que é na prática? | Analogia da Construção |
| :--- | :--- | :--- |
| **`SPEC.md`** (`-spec`) | A especificação funcional | **A Planta Baixa do Arquiteto.** Sem ela aprovada com o dono, ninguém bate um tijolo. |
| **`TASKS.md`** (`-tasks`) | O backlog vivo de execução | **O Cronograma do Mestre de Obras.** Lista na prancheta o que fazer hoje, amanhã e o que já foi entregue. |
| **Código** (`-tech-*` + `-testing`) | Os arquivos `.ts`, `.py`, testes | **A Alvenaria e o Teste de Carga.** Subir a parede e conferir se não racha. |
| **`ADR`** (`-adr`) | Decisão arquitetural | **O Registro em Cartório.** Documenta por que escolheu fundação de concreto armado e não estacas de madeira. |

---

## 👥 Quem manda e quem faz?

```mermaid
flowchart LR
    HUMANO["👤 VOCÊ (O Arquiteto / Dono)"]
    IA["🤖 A IA (O Engenheiro Executivo)"]

    HUMANO -->|"Define a intenção e regras de negócio"| IA
    IA -->|"Desenha a Spec técnica"| HUMANO
    HUMANO -->|"🛑 APROVA ou REJEITA (Freio de mão)"| IA
    IA -->|"Quebra em Tasks e Codifica com Testes"| HUMANO
    HUMANO -->|"Valida o resultado final"| IA
```

* 👤 **Você (Humano):** Pensa, define o objetivo, revisa, aprova e decide se está pronto. **Você é o Diretor.**
* 🤖 **A IA:** Pesquisa código existente, formata requisitos, escreve cenários de teste (*Given/When/Then*), decompõe tarefas, codifica e roda testes. **Ela é o Braço Operacional.**

---

## 🟢 Ciclo 1: Criando uma Feature do Zero (Spec 001)

Imagine o cenário deste repositório: precisamos de um **Script para sincronizar e validar as skills locais com a pasta global**.

---

### Passo 1: Pedir a Especificação
* 👤 **VOCÊ FAZ (Manual):** Você dá o comando inicial proibindo código antecipado.
  > **Prompt:**  
  > *"Preciso de uma solução para validar o frontmatter das skills locais e copiar a pasta `skills/` para `~/.gemini/config/skills/`. Crie a especificação antes de qualquer código usando a skill `-spec`."*

* 🤖 **A IA FAZ (Automático):**
  1. Ativa a skill com a assinatura: `> 🧠 **Skill Ativa**: -spec`.
  2. Cria o arquivo `docs/specs/001-sync-skills.md` com `status: rascunho`.
  3. Escreve os requisitos (`RF-01`, `RF-02`), os cenários de teste Given/When/Then (`CA-01`, `CA-02`) e o plano preliminar (`T-01..T-04`).
  4. 🛑 **A IA PUXA O FREIO DE MÃO:** Ela **para obrigatoriamente** e pergunta: *"Posso aprovar e gerar as tarefas?"*.

---

### Passo 2: Revisar e Aprovar a Spec
* 👤 **VOCÊ FAZ (Manual):** Você lê o arquivo gerado. Se faltar algo, pede ajuste. Se estiver certo, dá a aprovação formal.
  > **Prompt:**  
  > *"Aprovado! Atualize o status da spec e importe as tarefas para o TASKS.md usando -tasks."*

* 🤖 **A IA FAZ (Automático):**
  1. Altera o frontmatter da spec para `status: aprovada`.
  2. Aciona `-tasks` no modo **Importar**.
  3. Registra as tarefas no `TASKS.md` com origem, prioridade e vínculo aos requisitos.

---

### Passo 3: Implementação Tarefa por Tarefa
* 👤 **VOCÊ FAZ (Manual):** Você autoriza o início da codificação.
  > **Prompt:**  
  > *"Inicie a implementação da T-001 e T-002 seguindo -tech-typescript e -testing."*

* 🤖 **A IA FAZ (Automático):**
  1. Cria o teste automatizado primeiro (TDD) refletindo o critério Given/When/Then.
  2. Executa o teste e confirma que falhou (vermelho).
  3. Escreve a implementação em TypeScript estrito.
  4. Executa o teste novamente e confirma que passou (verde).
  5. Vai no `TASKS.md` e marca a tarefa com `[x]`.

---

### Passo 4: Fechando a Spec
* 👤 **VOCÊ FAZ (Manual):** Após ver todas as tarefas concluídas, pede o fechamento.
  > **Prompt:**  
  > *"Todas as tarefas da Spec 001 foram concluídas com os testes passando. Finalize a spec e gere o commit."*

* 🤖 **A IA FAZ (Automático):**
  1. Abre `docs/specs/001-sync-skills.md` e muda para `status: implementada`.
  2. Preenche a tabela de rastreabilidade (ligando cada critério `CA-NN` ao arquivo de teste real criado).
  3. Aciona a skill `-git` e prepara o commit semântico (ex: `feat(sync): ✨ script de validacao e sincronizacao`).

> 📌 **Resultado do Ciclo 1:** A `Spec 001` está no repositório com `status: implementada`. Ela **NÃO é deletada** nem arquivada; ela é agora a documentação viva e oficial de como o script funciona!

---

## 🟡 Ciclo 2: O Requisito Mudou! (Tornando a Spec 001 Obsoleta)

**O Problema:** Dois meses depois, descobrimos que copiar arquivos manualmente é ruim. Queremos uma **CLI Universal instalável** (`skills link`) com detecção automática de ambiente e links simbólicos (symlinks).

> ❓ **Dúvida comum for dummies:**  
> *"Eu apago a Spec 001 do repositório?"*  
> 👉 **NÃO!** Documentação histórica é patrimônio do projeto. Você apenas declara que ela ficou **obsoleta** e aponta a substituta.

---

### Passo 1: Solicitar a Nova Spec com Vínculo Histórico
* 👤 **VOCÊ FAZ (Manual):** Você explica a nova demanda e avisa que ela substitui a antiga.
  > **Prompt:**  
  > *"O script da Spec 001 não atende mais. Queremos substituir por uma CLI multiplataforma (@heliomarpm/skills-cli) com symlinks automáticos. Crie a Spec 002 substituindo a Spec 001."*

* 🤖 **A IA FAZ (Automático):**
  1. Cria `docs/specs/002-skills-cli.md` com `status: rascunho` e metadado `substitui: 001`.
  2. Na seção de Impacto no Legado, adiciona a remoção do script antigo da Spec 001.
  3. 🛑 **Freio de mão:** Pede sua confirmação para tornar a 001 obsoleta e avançar.

---

### Passo 2: Aprovação Cruzada
* 👤 **VOCÊ FAZ (Manual):** Você autoriza a transição.
  > **Prompt:**  
  > *"Confirmado! Marque a Spec 001 como obsoleta, aprove a Spec 002 e atualize o TASKS.md."*

* 🤖 **A IA FAZ (Automático):**
  1. **Na Spec 001 (`docs/specs/001-sync-skills.md`):**  
     Muda para `status: obsoleta` e adiciona `substituida-por: 002` com data e motivo.
  2. **Na Spec 002 (`docs/specs/002-skills-cli.md`):**  
     Muda para `status: aprovada`.
  3. **No `TASKS.md`:**  
     Adiciona as novas tarefas (incluindo a tarefa de deletar o script antigo com segurança).

---

### Passo 3: Implementação e Limpeza do Legado
* 👤 **VOCÊ FAZ (Manual):**
  > **Prompt:**  
  > *"Implemente as tarefas da Spec 002, remova o script legado da Spec 001 e rode a suíte de testes."*

* 🤖 **A IA FAZ (Automático):**
  1. Remove o arquivo legado `sync-skills.ts` (sem medo, pois a Spec 002 previa isso).
  2. Constrói a nova CLI com testes cobrindo os novos requisitos.
  3. Atualiza o `TASKS.md` com todas as tarefas concluídas.

---

### Passo 4: Fechando a Nova Spec
* 👤 **VOCÊ FAZ (Manual):**
  > **Prompt:**  
  > *"Tudo testado e aprovado. Feche a Spec 002 e prepare o commit."*

* 🤖 **A IA FAZ (Automático):**
  1. Muda a `Spec 002` para `status: implementada`.
  2. Preenche a rastreabilidade com os novos testes da CLI.
  3. Gera o commit semântico:  
     `feat(cli): ✨ criar skills-cli multiplataforma e descontinuar script legado`

---

## 📋 Resumo Visual "For Dummies": O que muda em cada arquivo?

| Arquivo | Antes do Ciclo 2 | Depois do Ciclo 2 |
| :--- | :--- | :--- |
| `docs/specs/001-sync-skills.md` | `status: implementada` | `status: obsoleta` (com link para a 002) |
| `docs/specs/002-skills-cli.md` | *(Não existia)* | `status: implementada` (Fonte viva atual) |
| `src/legacy-sync.ts` | Existia no código | **Removido** pelo plano de migração da Spec 002 |
| `src/cli/index.ts` | *(Não existia)* | **Criado** e coberto por testes |
| `TASKS.md` | Tarefas antigas arquivadas | Novas tarefas executadas e concluídas |

---

## 🛑 Os 3 Mandamentos para o Desenvolvedor

1. **Nunca deixe a IA pular direto para o código:**  
   Se ela tentar criar classes ou funções antes de você aprovar a spec, corte imediatamente: *"Pare. Primeiro crie a especificação e espere minha aprovação"*.
2. **Spec antiga nunca vai para a lixeira:**  
   Não delete arquivos de spec. Mudar para `status: obsoleta` preserva a memória histórica de por que o sistema funcionava daquele jeito antes.
3. **Spec é O QUÊ / ADR é POR QUÊ:**  
   - Se você está definindo regras de negócio, telas, rotas e testes $\to$ **Use `-spec`**.
   - Se você está escolhendo entre MongoDB ou PostgreSQL, Kafka ou RabbitMQ $\to$ **Use `-adr`**.
