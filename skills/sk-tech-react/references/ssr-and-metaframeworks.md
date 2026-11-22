# Meta-frameworks React: SSR, Server Components (RSC) e Server Actions

Referência complementar da `sk-tech-react`. Leia ao atuar em projetos com Next.js App Router, Remix ou React Router (modo framework), sempre respeitando as APIs da versão instalada no `package.json`.

---

## 1. Fronteira Servidor vs. Cliente

- **Server Components (RSC) por padrão**: mantenha busca inicial de dados, composição de layouts e leitura de segredos ou variáveis privadas no servidor para reduzir JavaScript enviado ao navegador.
- **`'use client'` na folha da árvore**: marque apenas o menor subcomponente que precisa de interatividade (`useState`, `useEffect`, event handlers, APIs de browser). Mover `'use client'` para o layout raiz envia toda a subárvore ao bundle do navegador.
- **Serialização estrita nas props**: tudo que atravessa de Server Component para Client Component precisa ser serializável e público para o usuário final. Nunca passe objetos crus do banco com campos internos, hashes, tokens ou variáveis de ambiente privadas.

---

## 2. Server Actions e Mutations são endpoints públicos

- **Autenticação e autorização em toda Action**: trate cada Server Action (`'use server'`) e loader/action do Remix com o mesmo rigor de uma rota HTTP REST (`sk-security`):
  1. Revalide a sessão autenticada dentro da própria action (nunca confie em UI oculta ou ID passado pelo cliente).
  2. Verifique autorização por recurso/tenant (proteção contra BOLA/IDOR).
  3. Valide e estreite toda entrada (`FormData` ou argumentos JSON) com schema (Zod/Valibot) no servidor.
- **Erros seguros e previsíveis**: retorne erros estruturados de validação/domínio no estado da action (`useActionState`) em vez de deixar exceções brutas chegarem ao cliente ou vazar detalhes de banco/stack trace.
- **Fronteira de backend (`sk-tech-nodejs`, `sk-sql`)**: mantenha regras de negócio pesadas, transações SQL/Prisma/Drizzle (com projeções estritas e **índices + rollback obrigatórios**) e chamadas a filas em serviços de backend bem encapsulados, não espalhados dentro de arquivos de UI.

---

## 3. Hidratação, *streaming* e *waterfalls*

- **Zero *hydration mismatch***: no primeiro render do cliente o HTML deve bater exatamente com o SSR. Evite ler `Date.now()`, `Math.random()`, `window.innerWidth` ou `localStorage` durante a renderização inicial; quando inevitável, renderize estado neutro inicial e sincronize após montagem (`useEffect`) ou use cookies lidos no servidor.
- **Evite *request waterfalls***: dispare buscas independentes em paralelo (`Promise.all`) no Server Component/loader e envolva trechos lentos e independentes com `<Suspense fallback={...}>` para fazer *streaming* progressivo sem bloquear a página inteira.
- **Navegação e cancelamento**: prefira links declarativos e prefetch controlado do framework; não bloqueie transições de rota com efeitos síncronos pesados.

---

## 4. Cache, revalidação e isolamento entre usuários

- **Nunca compartilhe cache com dados privados**: qualquer rota ou busca que lê sessão, cookie ou dados específicos de um tenant/usuário deve permanecer dinâmica/isolada por chave autenticada (ou sem cache compartilhado), evitando *cache poisoning* ou vazamento entre usuários.
- **Dados públicos e revalidação**: defina explicitamente estratégia de cache/revalidação (tempo ou tag após mutação) conforme a versão do framework — confirme no `package.json` porque os padrões de cache mudaram entre versões do Next.js (ex.: v14 vs v15+).
- **Evite duplicar dados entre RSC e cliente**: quando um Server Component busca os dados e um Client Component precisa mutar/recarregar, hidrate um único dono claro da verdade ou invalide via revalidação do roteador / `queryClient.invalidateQueries`.
