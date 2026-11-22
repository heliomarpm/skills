---
name: sk-design-system
description: "Orienta design systems e UI acessível: tokens em 3 camadas, claro/escuro, WCAG 2.2 AA, composição, estados e Tailwind v4/shadcn em referência de apoio. Use para tokens, acessibilidade, Tailwind tokens ou padronizar UI. NÃO use para código da stack (sk-tech-react/vue/angular/flutter) nem lógica de negócio."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Design System: tokens, componentes e acessibilidade

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-design-system`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Estenda o que existe.** Detecte tokens, Tailwind (`@theme`), shadcn, Material, Radix ou biblioteca interna e estenda-os em vez de recriar. O objetivo verificável é **consistência e acessibilidade**, não "apelo premium".

**Valide com ferramenta.** Razões de contraste citadas aqui são aproximadas: confirme com uma ferramenta de contraste antes de adotar uma cor.

**Escopo.** A skill especifica tokens, API de componentes e critérios de acessibilidade; o código em React, Vue, Angular, Ionic, React Native, Kotlin/Compose ou Flutter é da `sk-tech-*` correspondente.

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
4. Registre as pendências (seção 8).

---

## 3. Tokens de design

**Três camadas**
1. **Primitivos**: valores brutos (`--slate-900`, `--indigo-600`, `--space-4`). Nunca usados direto nos componentes.
2. **Semânticos**: a intenção (`--text-primary`, `--bg-surface`, `--action-primary`). Referenciam primitivos, nunca hexadecimais literais. É a camada que troca de tema.
3. **De componente**: ajuste fino local (`--btn-padding-x`).

**Governança**: nomes por **função**, não por aparência (nunca `--blue`); versionamento e depreciação de tokens; formato DTCG e Style Dictionary quando houver múltiplas plataformas. Defina o tema antes da primeira pintura para evitar o flash de tema (FOUC).

**Escalas completas**: tipografia (em `rem`, respeitando o zoom do usuário), espaçamento, raios, elevação, movimento, breakpoints e densidade. Consulte o starter JSON DTCG em [templates/design-tokens-starter.json](./templates/design-tokens-starter.json), o gerador CSS/`@theme` em [scripts/generate-tokens.cjs](./scripts/generate-tokens.cjs) e a implementação CSS completa (claro e escuro) em [examples/tokens-and-components.md](./examples/tokens-and-components.md).

Para direção visual (*Design Dials*), memória hierárquica (`MASTER.md` + `pages/<tela>.md`), proporção cromática `60/30/10`, ícones vetoriais e regras mobile, consulte [references/ui-craft-and-audit.md](./references/ui-craft-and-audit.md). Para mapeamento em **Tailwind CSS v4 (`@theme inline`)**, Container Queries e composição acessível, consulte [references/tailwind-and-shadcn.md](./references/tailwind-and-shadcn.md).

---

## 4. Componentes

**API por composição**: evite componentes monolíticos com dezenas de props booleanas. Prefira partes (`Dialog`, `Dialog.Trigger`, `Dialog.Content`) e polimorfismo por slot ou `asChild`. Documente o contrato de props, os eventos e os padrões ARIA seguidos (WAI-ARIA Authoring Practices).

**Estados aplicáveis ao componente**: padrão, hover (não existe em toque), ativo, foco visível, desabilitado, carregando, vazio e erro; e, conforme o caso, selecionado, marcado, indeterminado, inválido e somente leitura. Defina todos antes de implementar.

**Carregamento**: reserve as dimensões (skeleton) para evitar salto de layout.

**Formulários**: rótulo visível sempre (placeholder não é rótulo), erro associado ao campo (`aria-describedby`) com `aria-invalid`, e erro nunca comunicado só por cor.

**Referências de implementação**: para desabilitar mantendo foco acessível, prefira `aria-disabled="true"` (bloqueando a ação no código) sem `pointer-events: none` (que impede tooltips); para modais, prefira `<dialog>` nativo com `showModal()`. Veja os exemplos CSS/HTML completos de botão e modal em [examples/tokens-and-components.md](./examples/tokens-and-components.md).

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

**Auditar**: liste os achados com critério WCAG, local (`[arquivo.ext](./caminho/arquivo.ext#L15-L28)`), impacto e correção, com severidade (bloqueia uso, atrapalha, melhoria), seguindo o checklist pré-entrega e paridade claro/escuro de [references/ui-craft-and-audit.md](./references/ui-craft-and-audit.md). Não declare "acessível": o resultado é uma lista de achados.

**Migrar para tokens**: encontre valores fixos com `Grep` ou orientando a execução de [scripts/validate-tokens.cjs](./scripts/validate-tokens.cjs) (`node <pasta-da-skill>/scripts/validate-tokens.cjs --dir src/`), mapeie para o token semântico mais próximo e migre por componente com revisão visual nos dois temas.

---

## 8. Integrações e registro via `sk-tasks`

Se houver pendências relevantes não resolvidas, pergunte ao final:

> *"Deseja que eu registre as tarefas de UI e acessibilidade no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `sk-tasks` (modo Importar), com origem `design-system`, links relativos e a prioridade: tokens base e linha de base de acessibilidade P1; componentes P2; documentação e testes visuais P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `sk-tech-react`, `sk-tech-vue`, `sk-tech-angular`, `sk-tech-ionic`, `sk-tech-react-native`, `sk-tech-kotlin`, `sk-tech-flutter` | Implementam os componentes e tokens na stack |
| `sk-testing` | Testes de acessibilidade e regressão visual |
| `sk-code-review` | Verifica tokens e acessibilidade em PRs |
| `sk-spec` | Estados e critérios de aceite de interface |
| `sk-devops` | Storybook e testes visuais no CI |
| `sk-adr` | Decisões de sistema de design e de tema |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 9. Armadilhas

- **`outline: none` sem alternativa**: interface inavegável por teclado.
- **Cores fixas nos componentes**: impede temas e fragmenta o visual.
- **Tokens semânticos com hexadecimais literais**: a camada deixa de trocar de tema.
- **Tokens nomeados pela aparência** (`--blue`): quebram quando a marca muda.
- **`div` com clique no lugar de `button`**: sem foco, sem teclado, sem papel anunciado.
- **Cor como único indicador**: viola o critério 1.4.1.
- **Contraste não validado**: textos "discretos" e bordas de campos costumam reprovar.
- **`pointer-events: none` em desabilitado**: tira tooltips e explicações.
- **Salto de layout** por conteúdo assíncrono sem dimensões reservadas.
- **Emojis usados como ícones estruturais** ou **contraste do tema escuro inferido pelo tema claro** sem validação independente.
- **Declarar o resultado de uma ferramenta automática como "acessível".**

---

## 10. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Sistema existente detectado e o que foi estendido.
3. Tokens, especificação de componente ou lista de achados, com links relativos.
4. Critérios de teste (automáticos e manuais) e o que ainda precisa de validação com ferramenta.
5. Pendências e a pergunta condicional sobre o registro em tarefas (seção 8).
