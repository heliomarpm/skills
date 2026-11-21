# Referência: Tokens no Tailwind CSS v4 e Composição shadcn/ui (`sk-design-system`)

Consulte este guia quando o projeto adotar **Tailwind CSS** (especialmente v4 com `@theme`) e/ou **shadcn/ui + Radix UI**. A implementação final de código React/Vue/Angular fica na `sk-tech-*` da stack.

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

## 2. Regras de composição com shadcn/ui e Radix
- **Não trate shadcn/ui como biblioteca opaca**: os componentes vivem no repositório do projeto (`components/ui/*`). Audite foco, contraste e estados ao adicioná-los e ajuste usando os tokens semânticos acima.
- **Polimorfismo seguro (`asChild` / `Slot`)**: mantenha semântica HTML correta ao compor botão com link (`<Button asChild><a href="...">...</a></Button>`) em vez de aninhar `<a>` dentro de `<button>`.
- **Variantes tipadas (`cva` + `cn`)**: concentre variantes (`variant`, `size`) e classes de foco (`focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2`) no componente base; nunca remova `ring` sem substituto visível.
- **Estados obrigatórios**: garanta estilos distintos para `hover`, `active`, `focus-visible`, `disabled` / `aria-disabled` e `aria-invalid="true"` nos controles de formulário.
- **Tema sem FOUC**: em apps SSR/Next.js, sincronize a classe `.dark` ou `data-theme` em script inline mínimo antes da hidratação para evitar flash claro→escuro.

## 3. Auditoria de valores fixos (`Grep`) e checklist
Antes de aprovar componentes estilizados com Tailwind:
1. Busque cores e dimensões arbitrárias hardcoded com `Grep`:
   - `bg-\[#|text-\[#|border-\[#|ring-\[#`
   - `#[0-9a-fA-F]{3,8}` em componentes UI fora da definição de tokens primitivos
2. Mapeie cada ocorrência para o token semântico equivalente em `@theme inline`.
3. Valide razão de contraste **nos dois temas** (claro e escuro), inclusive em texto secundário (`muted-foreground`), bordas de `input` (>= 3:1) e estados de erro.
4. Prefira `rem` (escala padrão do Tailwind respeita o zoom de fonte do navegador); reserve `px` fixo para bordas (`1px`) e ícones alinhados ao alvo mínimo de `24×24 px` (ou área clicável equivalente).
