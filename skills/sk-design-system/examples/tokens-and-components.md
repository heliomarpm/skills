# Exemplos de Tokens e Componentes Acessíveis (`sk-design-system`)

## 1. Tokens em três camadas e tema claro/escuro

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

## 2. Botão acessível

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

## 3. Diálogo modal nativo (`<dialog>`)

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
