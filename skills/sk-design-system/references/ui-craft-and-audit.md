# Referência: Direção Visual, Paleta, Mobile UI e Auditoria (`sk-design-system`)

Consulte este guia ao definir direção visual para um produto novo, estruturar projetos multipágina, validar paridade claro/escuro ou auditar interfaces web e mobile.

## 1. Direção visual explícita (3 eixos / *Design Dials*)

Declare os 3 eixos antes de gerar tokens ou componentes:

| Eixo | Baixo (`1–3`) | Médio (`4–7`) | Alto (`8–10`) |
| :--- | :--- | :--- | :--- |
| **Densidade** | Espaçoso (`24–96 px`): marketing, onboarding | Padrão (`16–64 px`): SaaS e apps gerais | Denso (`8–32 px`): dashboards e consoles operacionais |
| **Estrutura** | Minimalista e centrado | Grade modular equilibrada | Assimétrico / *Bento grid* com cartões de destaque |
| **Movimento** | Microinterações sutis (`120–180 ms`) | Transições padrão com respeito a `prefers-reduced-motion` | Coreografia coordenada em etapas (sem bloquear leitura) |

---

## 2. Memória hierárquica (`MASTER.md` + `pages/<tela>.md`)

Em aplicações com várias páginas ou telas, evite conflito visual mantendo dois níveis de verdade:
1. **`design-system/MASTER.md`**: fonte única do produto (tokens semânticos, escala tipográfica, espaçamento, ícones e regras de estado).
2. **`design-system/pages/<tela>.md`** *(opcional)*: apenas os **desvios intencionais** daquela tela (ex.: tabela densa no painel administrativo). Se existir arquivo da página, suas regras sobrescrevem o `MASTER.md` só naquele contexto; sem ele, vale exclusivamente o `MASTER.md`.

---

## 3. Hierarquia cromática, proporção e paridade Claro/Escuro

- **Estrutura da paleta**:
  - **Primárias (`1–2`)**: ação principal (CTA), links ativos e anel de foco.
  - **Secundárias / Acento (`1–2`)**: destaques não concorrentes com o CTA primário.
  - **Neutras (`3–5`)**: fundo de página, superfície de card, textos (primário/secundário) e bordas. Evite `#000000` puro em texto longo sobre branco; prefira tons escuros suaves (`#0f172a` / `#111827`).
  - **Semânticas (`4`)**: `success`, `warning`, `error`, `info` (sempre acompanhadas de ícone ou texto — nunca cor isolada).
- **Proporção de uso (`60 / 30 / 10`)**: ~`60–70%` neutros e superfícies, ~`20–30%` elementos estruturais e secundários, ~`5–10%` cor de ação/acento.
- **Paridade obrigatória Claro/Escuro**:
  - Nunca assuma que valores de contraste do tema claro valem no escuro.
  - Valide texto normal (`>= 4,5:1`) e secundário/silenciado em **ambos os temas** (texto secundário no tema escuro é a reprovação mais comum).
  - Confira separação de superfícies (cards vs canvas), bordas de inputs/divisores (`>= 3:1`), estados `hover`/`focus`/`disabled` e opacidade de *scrim* em modais/drawers nos dois modos.

---

## 4. Ícones vetoriais e matriz `Propriedade × Estado`

- **Proibido usar emojis (`🎨`, `🚀`, `⚙️`) como ícones estruturais** de navegação, botões ou status de sistema: eles variam por plataforma e não obedecem tokens de cor/tamanho. Use apenas família vetorial única em SVG (ex.: Lucide, Phosphor ou equivalente já adotada no projeto) com espessura de traço e estilo consistentes por nível hierárquico.
- **Semântica do ícone**:
  - Decorativo ao lado de texto visível → `aria-hidden="true"`.
  - Botão só-ícone → nome acessível explícito (`aria-label` ou texto oculto para leitor de tela) e contraste `>= 3:1`.
  - Tamanhos em tokens (`icon-sm`, `icon-md`, `icon-lg`) e alinhamento à linha de base do texto.
- **Matriz mínima `Propriedade × Estado`** (sem alterar dimensões nem causar salto de layout):

| Propriedade | Padrão | Hover | Ativo / Press | Foco | Desabilitado | Erro |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Fundo** | `--action-primary` | `--action-primary-hover` | tom +1 escuro | igual ao estado | `--surface-muted` | `--danger-surface` |
| **Texto** | `--action-primary-fg` | `--action-primary-fg` | `--action-primary-fg` | igual ao estado | `--text-muted` | `--danger-fg` |
| **Borda / Anel** | `--border-control` | `--border-strong` | `--border-strong` | `2px` `--focus-ring` | `--border-subtle` | `--danger-border` |

---

## 5. Regras específicas para Mobile / App UI

Quando o alvo for app nativo/híbrido ou web responsiva em toque:
- **Alvos de toque**: web `>= 24×24 px` (WCAG 2.5.8); em telas touch / mobile nativo, adote **`>= 44×44 pt`** (iOS) / **`>= 48×48 dp`** (Android), expandindo o padding clicável quando o ícone visual for menor.
- **Safe areas e barras do sistema**: respeite recuos de *notch*, barra de status e barra de gestos em cabeçalhos fixos, abas inferiores e botões ancorados; adicione *inset* inferior para listas roláveis não ficarem escondidas atrás de barras fixas.
- **Ergonomia de leitura e gestos**: evite linhas longas de ponta a ponta em tablets (`max-width` confortável); nunca aninhe gestos conflitantes (ex.: *swipe* horizontal dentro de carrossel perto da borda de voltar do sistema).
- **Texto dinâmico e validação**: suporte *Dynamic Type* / zoom `200%` sem cortar texto nem botões; em formulários com múltiplos erros após envio, mantenha erros inline por campo e mova o foco para um resumo de erros com links.

---

## 6. Checklist pré-entrega e automação local

Antes de concluir tokens ou componentes:
- [ ] Zero emojis usados como ícones funcionais; família SVG única e tamanhos tokenizados.
- [ ] Contraste validado separadamente nos temas **claro** e **escuro** (`>= 4,5:1` texto, `>= 3:1` bordas/ícones).
- [ ] Estados completos definidos (`default`, `hover`, `active`, `focus-visible`, `disabled`/`aria-disabled`, `loading` com skeleton reservado, `empty`/`error`) sem salto de layout.
- [ ] Navegação por teclado, foco não obscurecido, alternativas a arrastar e `prefers-reduced-motion`.
- [ ] Alvos de toque, *safe areas* e reflow testados em `320–375 px` e zoom `200%`.

### Ferramentas incluídas nesta skill (Node.js puro, zero dependências)
Para projetos que geram ou auditam tokens a partir de JSON DTCG:
- Esqueleto inicial em 3 camadas + dark mode: [design-tokens-starter.json](../templates/design-tokens-starter.json)
- Gerar CSS Variables ou `@theme inline` (Tailwind v4):
  `node <pasta-sk-design-system>/scripts/generate-tokens.cjs --config tokens.json --format tailwind-v4 -o tokens.css`
- Auditar valores hardcoded (`#hex`, `rgb()`, `bg-[#...]`, `px`/`rem` fora dos arquivos de token):
  `node <pasta-sk-design-system>/scripts/validate-tokens.cjs --dir src/`
