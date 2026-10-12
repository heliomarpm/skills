---
name: -design-system
description: "Orienta design systems e interfaces acessíveis: tokens de design em camadas (primitivos, semânticos, de componente) com temas claro e escuro, acessibilidade WCAG 2.2 AA (contraste, teclado, foco, alvos, ARIA), API de componentes por composição e estados de interface. Agnóstica de framework; a implementação fica nas skills -tech-*. Use sempre que o usuário pedir 'crie os tokens', 'design system', 'tema escuro', 'componente acessível', 'audite a acessibilidade', 'contraste', 'foco', 'ARIA', 'migre as cores para tokens' ou 'padronize a UI', mesmo sem a expressão 'design system'. NÃO use para implementar componentes em um framework específico (isso é a -tech-* da stack) nem para lógica de negócio."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Design System: tokens, componentes e acessibilidade

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-design-system`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Estenda o que existe.** Detecte tokens, Tailwind (`@theme`), shadcn, Material, Radix ou biblioteca interna e estenda-os em vez de recriar. O objetivo verificável é **consistência e acessibilidade**, não "apelo premium".

**Valide com ferramenta.** Razões de contraste citadas aqui são aproximadas: confirme com uma ferramenta de contraste antes de adotar uma cor.

**Escopo.** A skill especifica tokens, API de componentes e critérios de acessibilidade; o código em React, Vue, Angular ou Flutter é da `-tech-*` correspondente.

**Idioma.** O do usuário; nomes de tokens e componentes seguem o projeto.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Criar tokens** | Definir ou estender a fundação visual |
| **Projetar componente** | Especificar API, estados e acessibilidade |
| **Auditar** | Avaliar acessibilidade e consistência de telas ou componentes |
| **Migrar** | Trocar valores fixos por tokens |

---

## 2. Workflow

1. **Contexto**: leia o sistema existente (tokens, tema, biblioteca de componentes), `AGENTS.md`, `GUIDELINE.md` e a spec relacionada.
2. Aplique a seção do modo (3 a 6) e os critérios de acessibilidade (seção 5).
3. Entregue a especificação ou os arquivos de tokens e estilos, com os critérios de teste.
4. Registre as pendências (seção 9).

---

## 3. Tokens de design

**Três camadas**
1. **Primitivos**: valores brutos (`--slate-900`, `--indigo-600`, `--space-4`). Nunca usados direto nos componentes.
2. **Semânticos**: a intenção (`--text-primary`, `--bg-surface`, `--action-primary`). Referenciam primitivos, nunca hexadecimais literais. É a camada que troca de tema.
3. **De componente**: ajuste fino local (`--btn-padding-x`).

**Governança**: nomes por **função**, não por aparência (nunca `--blue`); versionamento e depreciação de tokens; formato DTCG e Style Dictionary quando houver múltiplas plataformas. Defina o tema antes da primeira pintura para evitar o flash de tema (FOUC).

**Escalas completas**: tipografia (em `rem`, respeitando o zoom do usuário), espaçamento, raios, elevação, movimento, breakpoints e densidade.

```css
:root {
  /* Primitivos */
  --white: #ffffff;
  --slate-50: #f8fafc;  --slate-200: #e2e8f0; --slate-300: #cbd5e1;
  --slate-400: #94a3b8; --slate-500: #64748b; --slate-600: #475569;
  --slate-700: #334155; --slate-800: #1e293b; --slate-900: #0f172a;
  --indigo-300: #a5b4fc; --indigo-400: #818cf8;
  --indigo-600: #4f46e5; --indigo-700: #4338ca;
  --space-1: 0.25rem; --space-2: 0.5rem; --space-4: 1rem; --space-6: 1.5rem;
  --radius-md: 0.5rem;

  /* Semânticos, tema claro (razões aproximadas sobre --bg-surface) */
  color-scheme: light;
  --bg-canvas: var(--slate-50);
  --bg-surface: var(--white);
  --text-primary: var(--slate-900);
  --text-secondary: var(--slate-600);   /* ≈ 7,6:1 */
  --text-muted: var(--slate-500);       /* ≈ 4,8:1 */
  --border-subtle: var(--slate-200);    /* decorativa */
  --border-control: var(--slate-500);   /* bordas de campos: ≥ 3:1 */
  --action-primary: var(--indigo-600);
  --action-primary-hover: var(--indigo-700);
  --action-primary-fg: var(--white);    /* ≈ 6,3:1 sobre a ação */
  --focus-ring: var(--indigo-600);
}

/* Tema escuro automático, a menos que o usuário tenha forçado o claro */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme='light']) {
    color-scheme: dark;
    --bg-canvas: var(--slate-900);
    --bg-surface: var(--slate-800);
    --text-primary: var(--slate-50);
    --text-secondary: var(--slate-300);
    --text-muted: var(--slate-400);     /* ≈ 5,7:1 */
    --border-subtle: var(--slate-700);
    --border-control: var(--slate-400);
    --action-primary: var(--indigo-400);
    --action-primary-hover: var(--indigo-300);
    --action-primary-fg: var(--slate-900);  /* ≈ 6:1 sobre a ação */
    --focus-ring: var(--indigo-400);
  }
}

/* Tema escuro forçado: repita os mesmos valores do bloco acima
   (ou gere os dois blocos por ferramenta, como Style Dictionary) */
:root[data-theme='dark'] { color-scheme: dark; /* mesmos tokens escuros */ }
```

---

## 4. Componentes

**API por composição**: evite componentes monolíticos com dezenas de props booleanas. Prefira partes (`Dialog`, `Dialog.Trigger`, `Dialog.Content`) e polimorfismo por slot ou `asChild`. Documente o contrato de props, os eventos e os padrões ARIA seguidos (WAI-ARIA Authoring Practices).

**Estados aplicáveis ao componente**: padrão, hover (não existe em toque), ativo, foco visível, desabilitado, carregando, vazio e erro; e, conforme o caso, selecionado, marcado, indeterminado, inválido e somente leitura. Defina todos antes de implementar.

**Carregamento**: reserve as dimensões (skeleton) para evitar salto de layout.

**Formulários**: rótulo visível sempre (placeholder não é rótulo), erro associado ao campo (`aria-describedby`) com `aria-invalid`, e erro nunca comunicado só por cor.

### 4.1. Botão

```css
.ds-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  min-height: 2.5rem;                    /* alvo ≥ 24px (WCAG 2.5.8); 44px em toque */
  padding: var(--space-2) var(--space-4);
  font: inherit;
  font-weight: 500;
  border: 1px solid transparent;
  border-radius: var(--radius-md);
  background: var(--action-primary);
  color: var(--action-primary-fg);
  cursor: pointer;
  transition: background-color 150ms ease;
}
.ds-button:hover:not([aria-disabled='true']) { background: var(--action-primary-hover); }
.ds-button:active:not([aria-disabled='true']) { transform: translateY(1px); }

.ds-button:focus-visible {
  outline: 2px solid var(--focus-ring);  /* contraste ≥ 3:1 com o fundo */
  outline-offset: 2px;
}

.ds-button[aria-disabled='true'] { opacity: 0.6; cursor: not-allowed; }

@media (prefers-reduced-motion: reduce) { .ds-button { transition: none; transform: none; } }
@media (forced-colors: active) { .ds-button { border-color: ButtonText; } }
```

Para desabilitar, `disabled` nativo remove o botão do foco; `aria-disabled="true"` o mantém focável (útil para explicar o motivo), mas exige bloquear a ação no código. Não use `pointer-events: none`, que impede tooltips.

### 4.2. Diálogo modal

Prefira o `<dialog>` nativo com `showModal()`: o navegador prende o foco, fecha com Esc, torna o fundo inerte e devolve o foco a quem o abriu.

```html
<dialog id="confirmar" aria-labelledby="modal-titulo" aria-describedby="modal-desc">
  <h2 id="modal-titulo">Confirmar alterações</h2>
  <p id="modal-desc">Deseja aplicar as alterações a este projeto?</p>
  <form method="dialog">
    <button class="ds-button" value="cancelar">Cancelar</button>
    <button class="ds-button" value="confirmar">Confirmar</button>
  </form>
</dialog>
<!-- Abrir: document.getElementById('confirmar').showModal() -->
```

---

## 5. Acessibilidade (WCAG 2.2 AA)

- **Contraste**: 4,5:1 para texto normal, 3:1 para texto grande (1.4.3), e 3:1 para componentes de interface, bordas de campos e indicadores de foco (1.4.11).
- **Teclado**: tudo operável por `Tab`, `Enter`, `Espaço` e `Esc`, sem armadilhas de foco.
- **Foco**: sempre visível (`:focus-visible`) e **não obscurecido** por barras fixas ou sobreposições (2.4.11).
- **Alvos**: mínimo de 24×24 px (2.5.8).
- **Arrastar**: toda ação de arrastar tem alternativa por clique ou teclado (2.5.7).
- **Autenticação**: sem teste cognitivo obrigatório, e campos aceitam colar e gerenciadores de senha (3.3.8). Sem reentrada de dados já informados (3.3.7) e ajuda em local consistente (3.2.6).
- **Cor**: nunca como único indicador de estado (1.4.1).
- **Semântica**: elementos nativos primeiro (`button`, `a`, `input`, `dialog`, `nav`); ARIA só quando o HTML não basta.
- **Movimento e preferências**: respeite `prefers-reduced-motion`, `forced-colors`, zoom e texto ampliado (reflow em 320 px de largura).
- **Internacionalização**: suporte a RTL e textos de tamanho variável.

---

## 6. Teste de acessibilidade

Ferramentas automáticas (axe, Lighthouse, jest-axe) detectam apenas parte dos problemas. Complete com testes manuais: navegação só por teclado, leitor de tela (NVDA, VoiceOver), zoom de 200% e reflow, e contraste de todos os estados. Use Storybook e testes de regressão visual para proteger os componentes.

---

## 7. Auditoria e migração

**Auditar**: liste os achados com critério WCAG, local (`arquivo:linhas`), impacto e correção, com severidade (bloqueia uso, atrapalha, melhoria). Não declare "acessível": o resultado é uma lista de achados.

**Migrar para tokens**: encontre valores fixos com `Grep` (hexadecimais, `px` de espaçamento), mapeie para o token semântico mais próximo, proponha novos tokens só para valores recorrentes e migre por componente, com revisão visual.

---

## 8. Integrações

| Skill | Como se integra |
| :--- | :--- |
| `-tech-react`, `-tech-vue`, `-tech-angular`, `-tech-flutter` | Implementam os componentes e tokens na stack |
| `-testing` | Testes de acessibilidade e regressão visual |
| `-code-review` | Verifica tokens e acessibilidade em PRs |
| `-spec` | Estados e critérios de aceite de interface |
| `-devops` | Storybook e testes visuais no CI |
| `-adr` | Decisões de sistema de design e de tema |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 9. Registro via `-tasks`

Se houver pendências, pergunte ao final:

> *"Deseja que eu registre as tarefas de UI e acessibilidade no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `design-system`, links relativos e a prioridade: tokens base e linha de base de acessibilidade P1; componentes P2; documentação e testes visuais P3. **Fallback**: lista no chat.

---

## 10. Armadilhas

- **`outline: none` sem alternativa**: interface inavegável por teclado.
- **Cores fixas nos componentes**: impede temas e fragmenta o visual.
- **Tokens semânticos com hexadecimais literais**: a camada deixa de trocar de tema.
- **Tokens nomeados pela aparência** (`--blue`): quebram quando a marca muda.
- **`div` com clique no lugar de `button`**: sem foco, sem teclado, sem papel anunciado.
- **Cor como único indicador**: viola o critério 1.4.1.
- **Contraste não validado**: textos "discretos" e bordas de campos costumam reprovar.
- **`pointer-events: none` em desabilitado**: tira tooltips e explicações.
- **Salto de layout** por conteúdo assíncrono sem dimensões reservadas.
- **Declarar o resultado de uma ferramenta automática como "acessível".**

---

## 11. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Sistema existente detectado e o que foi estendido.
3. Tokens, especificação de componente ou lista de achados, com links relativos.
4. Critérios de teste (automáticos e manuais) e o que ainda precisa de validação com ferramenta.
5. Pendências e a pergunta sobre o registro em tarefas (seção 9).