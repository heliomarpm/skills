---
name: _refactoring
description: Fornece diretrizes agnósticas de refatoração segura de código legado e complexo, preservação de comportamento externo, testes de caracterização e aplicação cirúrgica de padrões de design em qualquer linguagem.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(pnpm test *), Bash(yarn test *), Bash(pytest *), Bash(go test *), Bash(dotnet test *), Bash(mvn test *), Bash(gradle test *), Bash(composer test *)
---

# Global Skill: Safe & Disciplined Code Refactoring (Language-Agnostic)

> **Escopo Global**: Esta skill é **estritamente agnóstica a linguagem e framework**. Seus princípios, fluxos e transformações aplicam-se a qualquer paradigma (orientado a objetos, funcional ou procedural) e linguagem (C#, Java, Python, TypeScript, PHP, Go, Rust, Dart, etc.).


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_refactoring``

---

## 1. A Regra dos Dois Chapéus (*Two Hats of Refactoring*)

Ao modificar uma base de código existente, alterne conscientemente entre dois modos estritamente separados:
- **Modo Refatoração**: Você **apenas reestrutura** a arquitetura interna do código. Nenhuma regra de negócio é alterada, nenhuma funcionalidade nova é adicionada e o comportamento externo permanece 100% idêntico. Todos os testes devem permanecer verdes.
- **Modo Nova Funcionalidade**: Você **adiciona novos comportamentos** ou altera contratos de negócio sobre uma base de código já limpa e refatorada.

---

## 2. Processo Universal de Execução de Refatoração

1. **Rede de Proteção Prévia (Testes de Caracterização / Golden Master)**:
   - Se o trecho a ser refatorado não possuir testes automatizados confiáveis, **não inicie a refatoração imediatamente**.
   - Escreva testes de caracterização para capturar e congelar o comportamento atual do sistema em múltiplos cenários (entradas válidas, limites e exceções existentes).
2. **Identificação do *Code Smell* Alvo**:
   - Isole o defeito estrutural específico (ex: método longo, responsabilidade múltipla, obsessão por tipos primitivos, estruturas condicionais repetidas, acoplamento indevido).
3. **Aplicação de Movimentos Cirúrgicos em Micro-Passos**:
   - Execute uma única transformação atômica por vez (ex: extrair função ➔ validar testes ➔ introduzir DTO/classe de parâmetro ➔ validar testes ➔ substituir condicional por polimorfismo/mapa ➔ validar testes).
4. **Validação Contínua**:
   - Execute a suíte de testes e a verificação de compilação/tipagem após cada micro-edição.
5. **Limpeza Segura de Código Morto**:
   - Remova estruturas obsoletas ou aplique o padrão *Strangler Fig* para migrações progressivas em subsistemas críticos.

---

## 3. Catálogo de Movimentos Canônicos de Refatoração

*(Os snippets abaixo utilizam pseudocódigo/TypeScript apenas como meio ilustrativo de design; aplique o padrão idiomático da linguagem do projeto).*

### 3.1. Substituir Condicional Complexo por Polimorfismo / Mapa de Estratégias
```
// ANTES: Violação do Princípio Aberto/Fechado com Switch/IFs repetidos
função calcularTaxa(tipoPagamento, valor):
    se tipoPagamento == "PIX" então retorne 0
    senão se tipoPagamento == "CARTAO" então retorne valor * 0.03
    senão se tipoPagamento == "BOLETO" então retorne 2.50
    senão lance Erro("Tipo inválido")

// DEPOIS: Estratégias polimórficas desacopladas e extensíveis
interface EstrategiaTaxa { calcular(valor): numero }
classe TaxaPix : EstrategiaTaxa { calcular(valor) { retorne 0 } }
classe TaxaCartao : EstrategiaTaxa { calcular(valor) { retorne valor * 0.03 } }
classe TaxaBoleto : EstrategiaTaxa { calcular(valor) { retorne 2.50 } }

classe CalculadoraTaxa {
    mapaEstrategias = { "PIX": TaxaPix, "CARTAO": TaxaCartao, "BOLETO": TaxaBoleto }
    calcular(tipo, valor) {
        estrategia = mapaEstrategias[tipo] ou lance Erro("Tipo inválido")
        retorne estrategia.calcular(valor)
    }
}
```

### 3.2. Introduzir Objeto de Parâmetro (*Parameter Object* / DTO)
```
// ANTES: Parâmetros soltos que sempre trafegam juntos (Data Clump)
função buscarPedidos(dataInicio, dataFim, status, valorMinimo, valorMaximo, pagina, tamanhoPagina)

// DEPOIS: Objeto/Estrutura de parâmetro coesa e auto-validada
estrutura FiltroBuscaPedidos {
    intervaloData: { inicio, fim }
    statusOpcional
    intervaloValor: { minimo, maximo }
    paginacao: { pagina, tamanho }
}
função buscarPedidos(filtro: FiltroBuscaPedidos)
```

---

## 4. Armadilhas Críticas na Refatoração (*Gotchas*)

- ⚠️ **Refatorar sem Rede de Testes ("No Net, No Refactor")**: Tentar limpar código complexo sem testes prévios é a causa primária de regressões silenciosas em produção.
- ⚠️ **Reescrever do Zero vs Refatorar**: Reescrever sistemas do zero quase sempre ignora dezenas de correções de casos de borda acumuladas ao longo dos anos. Prefira refatoração incremental.
- ⚠️ **Refatorações Gigantescas em Bloco**: Alterar múltiplos módulos sem commits atômicos impede revisões humanas eficazes e impossibilita a reversão segura (`git revert`).

---

## 5. Padrão de Entrega do Agente

Ao conduzir refatorações:
1. Preserve 100% da API pública e contratos observáveis existentes (a menos que a quebra tenha sido solicitada explicitamente).
2. Adote as convenções e paradigmas idiomáticos da linguagem ativa no projeto do usuário.
3. Entregue o código refatorado acompanhado dos testes automatizados de caracterização correspondentes.

---

## 6. 📝 Gestão de Débitos e Próximos Passos com `_task-management` (Sempre ao Final)

Sempre ao término de uma sessão, proposta ou análise de refatoração, se houver etapas adicionais em aberto, testes de caracterização pendentes ou novos débitos técnicos identificados, **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Identifiquei etapas e débitos técnicos decorrentes da refatoração. Deseja que eu registre ou atualize essas atividades no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a atualizar automaticamente):
1. **Ativação da Skill**: Acione a skill **`_task-management`** para realizar a escrita ou atualização estruturada.
2. **Localização em Cascata**: A skill `_task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`), preservando o histórico existente.
3. **Mapeamento de Ações**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Testes de caracterização prévios obrigatórios antes de refatorar fluxos críticos ou financeiros.
   - `⚠️ 2. Média Prioridade`: Quebra de acoplamento, extração de classes de parâmetro e eliminação de duplicações estruturais.
   - `💡 3. Baixa Prioridade / Otimização`: Renomeações semânticas, limpeza de métodos obsoletos e simplificação cosmética.
   - `✅ 4. Concluído recentemente`: Transformações atômicas já executadas e validadas com sucesso na sessão com `- [x]`.
4. **Navegabilidade**: Cada tarefa cadastrada deve apontar para os arquivos ou trechos exatos via link `[arquivo.ext](file:///...)`.
