# Referência: Tailwind CSS, Responsividade e Composição shadcn/ui (`sk-design-system`)

Consulte este guia quando o projeto adotar **Tailwind CSS** (v3 ou v4 com `@theme`) e/ou **componentes baseados em Radix / composição**. A implementação final em React, Vue ou Angular fica na `sk-tech-*` da stack.

## 1. Mapeamento das 3 camadas para Tailwind v4 (`@theme inline`)
- **Primitivos** e **semânticos** continuam definidos como custom properties CSS (`:root` para claro, `[data-theme="dark"]` ou `.dark` para escuro).
- Use `@theme inline` para expor os **tokens semânticos** como utilitários Tailwind (`bg-surface`, `text-primary`, `border-subtle`), mantendo a troca de tema em runtime sem duplicar classes `dark:` por todo componente:

```css
/* 1. Primitivos e 2. Semânticos (CSS puro — único ponto de troca de tema) */
:root {
  --raw-slate-50: #f8fafc;
  --raw-slate-900: #0f172a;
  --raw-indigo-600: #4f46e5;
  --raw-indigo-400: #818cf8;

  --surface: #ffffff;
  --surface-muted: var(--raw-slate-50);
  --foreground: var(--raw-slate-900);
  --primary: var(--raw-indigo-600);
  --ring: var(--raw-indigo-600);
}

[data-theme="dark"],
.dark {
  --surface: var(--raw-slate-900);
  --surface-muted: #1e293b;
  --foreground: var(--raw-slate-50);
  --primary: var(--raw-indigo-400);
  --ring: var(--raw-indigo-400);
}

/* Mapeamento para utilitários Tailwind v4 (referencia as vars semânticas) */
@theme inline {
  --color-surface: var(--surface);
  --color-surface-muted: var(--surface-muted);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-ring: var(--ring);
}
```

> Você pode gerar esse arquivo automaticamente a partir do [design-tokens-starter.json](../templates/design-tokens-starter.json) usando [generate-tokens.cjs](../scripts/generate-tokens.cjs) (`--format tailwind-v4`).

---

## 2. Composição acessível, teclado e leitores de tela (Radix / shadcn)
- **Não trate componentes gerados em `components/ui/*` como caixa-preta**: audite foco, contraste nos dois temas e papéis ARIA ao incorporá-los.
- **Polimorfismo seguro (`asChild` / `Slot`)**: mantenha semântica HTML correta ao compor botão com link (`<Button asChild><a href="...">...</a></Button>`) em vez de aninhar `<a>` dentro de `<button>`.
- **Atalho de salto (*Skip link*)**: forneça `<a href="#main-content" className="sr-only focus:not-sr-only ...">` no topo de layouts com navegação extensa.
- **Regiões dinâmicas (*Live regions*)**: status não urgentes usam `aria-live="polite" aria-atomic="true"`; erros críticos imediatos usam `role="alert"` ou `aria-live="assertive"`.
- **Modais, menus e abas**: garanta armadilha de foco (*focus trap*), fechamento por `Esc`, retorno do foco ao gatilho ao fechar e navegação por setas em listas/menus.
- **Formulários**: agrupe controles relacionados com `<fieldset>` + `<legend>`, associe erros com `aria-invalid` + `aria-describedby` apontando para o `id` da mensagem e reserve indicação de obrigatório para leitores de tela (`sr-only`).
- **Variantes tipadas (`cva` + `cn`) e movimento reduzido**: mantenha anel visível (`focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2`) e respeite `motion-reduce:transition-none` (e `@media (prefers-reduced-motion: reduce)` no CSS global).

---

## 3. Responsividade mobile-first e Container Queries
- **Mobile-first real**: defina o layout base em `1` coluna para telas pequenas (`320–375 px`) e evolua com `md:` / `lg:`. Limite cada componente a **`2–3` breakpoints** consistentes em vez de misturar 6 prefixos diferentes no mesmo elemento.
- **Container Queries (`@container`) para componentes reutilizáveis**: quando um card, widget ou painel precisa se adaptar ao espaço do pai (sidebar vs área principal) e não à viewport, envolva o pai com `@container` e estilize filhos com `@md:grid-cols-2`, `@lg:grid-cols-3`.
- **Limites obrigatórios de teste**: verifique `320–375 px`, `640 px`, `768 px`, `1024 px`, `1280 px`, orientação paisagem e zoom de `200%` (sem scroll horizontal indesejado nem texto sobreposto).

---

## 4. Auditoria de valores fixos e conformidade
Antes de aprovar componentes estilizados com Tailwind:
1. Rode o auditor automático [validate-tokens.cjs](../scripts/validate-tokens.cjs) (`node <pasta-sk-design-system>/scripts/validate-tokens.cjs --dir src/`) ou busque padrões fixos com `Grep`:
   - `bg-\[#|text-\[#|border-\[#|ring-\[#`
   - `#[0-9a-fA-F]{3,8}` fora de arquivos de definição de tokens (`tokens.*`, `globals.css`)
2. Mapeie cada ocorrência para o token semântico equivalente em `@theme inline`.
3. Valide razão de contraste **nos dois temas** (claro e escuro), inclusive em texto secundário (`muted-foreground`), bordas de `input` (`>= 3:1`) e estados de erro.
4. Prefira `rem` (a escala padrão do Tailwind respeita o zoom de fonte do navegador); reserve `px` fixo para bordas (`1px`) e garanta alvos clicáveis de no mínimo `24×24 px` (web) ou `44×44 px` (fluxos mobile).
