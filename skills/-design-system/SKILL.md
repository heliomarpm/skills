---
name: -design-system
description: "Orienta o design e arquitetura de interfaces (UI/UX): criação e consumo de Design Tokens semânticos, acessibilidade WCAG 2.2 AA (A11y, ARIA), padrões de componentização resiliente, micro-interações e estados de tela."
allowed-tools: Read, Edit, Write, Grep, Glob
disallowed-tools: Bash
---

# Global Skill: Design Systems, Semantic Tokens & Accessible UI Architecture (Language-Agnostic)

Diretrizes técnicas especializadas para a criação, consumo e governança de **Design Systems**, arquitetura de componentes escaláveis, especificação de **Design Tokens** semânticos e conformidade rigorosa com acessibilidade digital (**WCAG 2.2 AA / WAI-ARIA**).

Esta skill orienta o desenvolvimento de interfaces com apelo estético de alto nível (*premium*), consistência visual entre ecossistemas (React, Vue, Angular, Flutter, Web Components) e usabilidade universal.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `-design-system``

---

## 1. Processo de Execução em Design Systems & UI

Ao projetar bibliotecas de componentes, tokens visuais ou refatorar interfaces:

1. **Arquitetura de Tokens em 3 Camadas (*3-Tier Token Architecture*)**:
   - **Camada 1: Globais / Primitivos**: Valores literais brutos e imutáveis (`--color-blue-500: #3b82f6`, `--space-4: 16px`, `--font-sans: 'Inter'`). **Nunca consuma primitivos diretamente no markup dos componentes**.
   - **Camada 2: Semânticos / Decisões**: Expressam a intenção do design (`--color-bg-surface`, `--color-text-primary`, `--color-border-subtle`, `--color-feedback-danger`). Esta camada viabiliza temas dinâmicos (*Light/Dark mode*) e trocas de marca sem alterar o código do componente.
   - **Camada 3: Específicos de Componente**: Variáveis locais e isoladas para customização cirúrgica (`--btn-padding-x`, `--input-height`, `--card-elevation`).
2. **Acessibilidade Universal (WCAG 2.2 Nível AA por Padrão)**:
   - **Contraste de Cor**: Mínimo de 4.5:1 para texto normal e 3:1 para texto grande (18pt+ ou 14pt negrito) e componentes essenciais da interface (bordas de campos de entrada, ícones interativos).
   - **Navegação por Teclado**: Todo componente interativo deve ser acessível via `Tab`, ativável por `Enter`/`Space` e dispensável por `Escape`.
   - **Indicador de Foco Visível**: Nunca oculte anéis de foco (`outline: none`) sem fornecer alternativa nítida com `:focus-visible`.
   - **Semântica WAI-ARIA**: Dê preferência absoluta a elementos nativos do HTML (`<button>`, `<dialog>`, `<nav>`, `<aside>`). Use atributos ARIA para expressar estados dinâmicos (`aria-expanded`, `aria-hidden`, `aria-invalid`, `aria-busy`, `aria-live`).
3. **Padrão dos 7 Estados de Interface (*States Checklist*)**:
   - Nenhum componente interativo ou container de dados está pronto sem tratar os 7 estados:
     1. *Default / Idle*: Aparência base em repouso.
     2. *Hover*: Resposta visual tátil à passagem do cursor.
     3. *Active / Pressed*: Feedback de compressão ou clique imediato.
     4. *Focus-Visible*: Destaque inequívoco na navegação por teclado sem interferir no clique do mouse.
     5. *Disabled*: Atenuação visual com `aria-disabled="true"`, prevenindo cliques acidentais.
     6. *Loading / Pending*: Skeletons dimensionados para prevenir salto de layout (*Cumulative Layout Shift - CLS*) ou spinners acessíveis.
     7. *Empty & Error State*: Feedback claro, orientando o usuário para o próximo passo.
4. **Composição e Polimorfismo (*Compound Components & Slots*)**:
   - Evite criar componentes monolíticos com centenas de propriedades booleanas. Estruture com composição modular (ex.: `<Dialog>`, `<Dialog.Trigger>`, `<Dialog.Content>`, `<Dialog.Close>`) e suporte a polimorfismo (`asChild` ou projeção de slots).

---

## 2. Snippets Canônicos de Referência

### 2.1. Arquitetura de Tokens Semânticos em CSS Moderno (Light & Dark Mode)
```css
:root {
  /* 1. Tokens Primitivos (Escala Bruta) */
  --slate-50:  #f8fafc;
  --slate-100: #f1f5f9;
  --slate-800: #1e293b;
  --slate-900: #0f172a;
  --indigo-500: #6366f1;
  --indigo-600: #4f46e5;
  --emerald-500: #10b981;
  --rose-500: #f43f5e;

  /* 2. Tokens Semânticos (Decisões de Tema Claro) */
  --bg-canvas: var(--slate-50);
  --bg-surface: #ffffff;
  --bg-surface-elevated: #ffffff;
  --text-primary: var(--slate-900);
  --text-secondary: #475569;
  --text-muted: #94a3b8;
  --border-subtle: #e2e8f0;
  --border-strong: #cbd5e1;
  --action-primary: var(--indigo-600);
  --action-primary-hover: var(--indigo-500);
  --action-primary-fg: #ffffff;
  --focus-ring: rgba(99, 102, 241, 0.5);

  /* Escala de Espaçamento (Base 4px) */
  --space-1: 0.25rem; /* 4px */
  --space-2: 0.5rem;  /* 8px */
  --space-3: 0.75rem; /* 12px */
  --space-4: 1rem;    /* 16px */
  --space-6: 1.5rem;  /* 24px */
  --space-8: 2rem;    /* 32px */

  /* Raios de Borda */
  --radius-sm: 0.375rem; /* 6px */
  --radius-md: 0.5rem;   /* 8px */
  --radius-lg: 0.75rem;  /* 12px */
  --radius-full: 9999px;
}

/* 3. Variação Automática para Tema Escuro */
[data-theme='dark'], (prefers-color-scheme: dark) {
  --bg-canvas: var(--slate-900);
  --bg-surface: var(--slate-800);
  --bg-surface-elevated: #334155;
  --text-primary: #f8fafc;
  --text-secondary: #cbd5e1;
  --text-muted: #64748b;
  --border-subtle: #334155;
  --border-strong: #475569;
  --action-primary: var(--indigo-500);
  --action-primary-hover: #818cf8;
  --action-primary-fg: #ffffff;
  --focus-ring: rgba(129, 140, 248, 0.6);
}
```

### 2.2. Botão Acessível & Resiliente a Estados (Exemplo CSS / Web Components / React)
```css
.ds-button {
  /* Uso estrito de tokens semânticos */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  font-family: inherit;
  font-size: 0.875rem;
  font-weight: 500;
  border-radius: var(--radius-md);
  border: 1px solid transparent;
  cursor: pointer;
  transition: background-color 150ms ease, border-color 150ms ease, box-shadow 150ms ease, transform 100ms ease;
  user-select: none;
  background-color: var(--action-primary);
  color: var(--action-primary-fg);
}

/* Hover */
.ds-button:hover:not(:disabled) {
  background-color: var(--action-primary-hover);
}

/* Active / Pressed */
.ds-button:active:not(:disabled) {
  transform: translateY(1px);
}

/* Focus-Visible (Acessibilidade por teclado sem interferir no clique) */
.ds-button:focus {
  outline: none;
}

.ds-button:focus-visible {
  outline: 2px solid var(--action-primary);
  outline-offset: 2px;
  box-shadow: 0 0 0 4px var(--focus-ring);
}

/* Disabled */
.ds-button:disabled,
.ds-button[aria-disabled='true'] {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}
```

### 2.3. Modal com Focus Trap e Semântica WAI-ARIA
```html
<!-- Exemplo de Estrutura de Diálogo Acessível -->
<div 
  class="ds-modal-backdrop"
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-desc"
>
  <div class="ds-modal-content">
    <header class="ds-modal-header">
      <h2 id="modal-title" class="ds-modal-title">Confirmar Alterações</h2>
      <button 
        type="button" 
        class="ds-modal-close" 
        aria-label="Fechar modal de confirmação"
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </header>
    <main id="modal-desc" class="ds-modal-body">
      <p>Deseja aplicar as diretrizes do novo Design System neste repositório?</p>
    </main>
    <footer class="ds-modal-footer">
      <button type="button" class="ds-button ds-button--ghost">Cancelar</button>
      <button type="button" class="ds-button ds-button--primary">Confirmar</button>
    </footer>
  </div>
</div>
```

---

## 3. Armadilhas Críticas em Interfaces (*Gotchas*)

- ⚠️ **Eliminar Indicador de Foco (`outline: none`)**: Remover o contorno de foco sem disponibilizar uma alternativa visual evidente em `:focus-visible` torna a interface inavegável para pessoas com deficiência motora ou usuárias exclusivas de teclado.
- ⚠️ **Cores Hardcoded sem Camada Semântica**: Declarar cores diretamente nos componentes (ex.: `#1e293b` ou `bg-[#1e293b]`) impede o suporte a múltiplos temas e gera fragmentação estética imediata à medida que o projeto cresce.
- ⚠️ **`<div>` com Evento de Clique em vez de `<button>`**: Elementos `div` ou `span` com `onClick` não recebem foco por teclado, não emitem eventos com `Enter`/`Space` e não anunciam seu papel semântico para leitores de tela. Use sempre elementos interativos nativos (`<button>`, `<a>`, `<input>`).
- ⚠️ **Dependência Exclusiva de Cor para Transmitir Estado**: Sinalizar erros apenas com texto vermelho viola o critério WCAG 1.4.1. Sempre combine cores com ícones semânticos, textos de auxílio e `aria-invalid="true"`.
- ⚠️ **Cumulative Layout Shift (CLS) por Falta de Skeletons**: Carregar elementos de forma assíncrona sem reservar previamente suas dimensões faz o conteúdo "pular" na tela, prejudicando a experiência do usuário e os índices de Core Web Vitals.

---

## 4. Padrão Rigoroso de Entrega

Ao atuar nesta skill:
1. **Assinatura Obrigatória**: Toda mensagem deve iniciar com `> 🧭 **Skill Ativa**: `-design-system``.
2. **Tokens de Primeira Classe**: Utilize e declare exclusivamente tokens semânticos para cores, tipografia, espaçamentos e raios; nunca insira valores mágicos literais.
3. **Conformidade WCAG 2.2 AA**: Garanta que todo componente tenha contraste validado, anel de foco `:focus-visible`, suporte a teclado e atributos `aria-*` apropriados.
4. **Resiliência de Estados**: Implemente ou especifique os estados essenciais de interface (*Idle, Hover, Active, Focus, Disabled, Loading, Error*).
5. **Harmonia com Especialistas Técnicos**: Integre os padrões desta skill às bibliotecas de componentes do ecossistema do projeto ativo ([`-tech-react`](../-tech-react/SKILL.md), [`-tech-vue`](../-tech-vue/SKILL.md), [`-tech-angular`](../-tech-angular/SKILL.md) ou [`-tech-flutter`](../-tech-flutter/SKILL.md)).

---

## 5. 📝 Planejamento de Componentes com `-task-management` (Sempre ao Final)

Sempre ao término da especificação de design tokens, arquitetura de componentes ou implementação de telas no Design System, **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Concluí a especificação e arquitetura dos componentes de interface. Deseja que eu registre as tarefas de desenvolvimento, acessibilidade e testes visuais no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a planejar automaticamente):
1. **Ativação da Skill**: Acione a skill **`-task-management`** para estruturar o backlog de UI/UX.
2. **Localização em Cascata**: A skill `-task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`).
3. **Mapeamento de Tarefas de UI/UX**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Criação da fundação de Design Tokens (CSS variables / theme tokens), reset CSS e estrutura de acessibilidade (Focus rings, A11y baseline).
   - `⚠️ 2. Média Prioridade`: Componentes atômicos e compostos (Buttons, Inputs, Dialogs, Toasts, Form controls) com todos os 7 estados de tela.
   - `💡 3. Baixa Prioridade / Otimização`: Documentação no Storybook, testes de regressão visual, animações fluidas e otimização de CLS.
   - `✅ 4. Concluído recentemente`: Componentes e tokens concluídos na sessão com `- [x]`.
4. **Navegabilidade**: Toda tarefa deve indicar os arquivos de componentes ou estilos correspondentes (`[Componente.tsx](file:///...)`).
