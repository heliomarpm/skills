---
name: sk-tech-ionic
description: "Orienta Ionic 7/8 + Capacitor (iOS, Android e Web): ciclo ionView*, standalone, Shadow DOM/::part, plugins nativos, permissões, armazenamento seguro, SQLite offline com índices e testes. Use para apps híbridos Ionic. NÃO use para reatividade base (sk-tech-angular/react/vue), tipagem (sk-tech-typescript) nem tokens/WCAG (sk-design-system)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx cap doctor *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *)
---

# Ionic + Capacitor: aplicativos híbridos previsíveis

Foca nas particularidades de arquitetura, ciclo de vida de pilha móvel, Web Components em Shadow DOM, ponte nativa Capacitor e persistência offline em apps Ionic 7/8 com Angular, React ou Vue.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-ionic`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e framework hospedeiro.** Leia `@ionic/angular`, `@ionic/react` ou `@ionic/vue`, `@capacitor/core` e `capacitor.config.*` no projeto antes de editar. APIs de standalone components, `addIcons`, roteamento e Capacitor 5/6/7 mudam entre versões: confirme compatibilidade no projeto e delegue reatividade base ao `sk-tech-angular`, `sk-tech-react` ou `sk-tech-vue` (e tipos ao `sk-tech-typescript`).

**Sincronização nativa pede atenção.** Alterações em plugins nativos, `Info.plist`, `AndroidManifest.xml` e `npx cap sync` impactam código nativo iOS/Android: confirme alterações fora da camada web e peça aprovação antes de instalar novos plugins nativos.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, build web/nativo, tipos, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Ciclo de vida da pilha Ionic**: o `IonRouterOutlet` mantém páginas anteriores em cache no DOM. Não dependa apenas de `ngOnInit`, `useEffect([])` ou `onMounted` para recarregar dados ou gerenciar listeners: use `ionViewWillEnter`, `ionViewDidEnter`, `ionViewWillLeave` e `ionViewDidLeave` (ou os hooks equivalentes do framework) com limpeza garantida na saída.
- **Standalone e registro explícito de ícones (Ionic 7/8)**: importe apenas os componentes `Ion*` utilizados por tela e registre ícones vetoriais via `addIcons({ ... })` para evitar falha de renderização silenciosa e preservar *tree-shaking*.
- **Shadow DOM sem gambiarras**: componentes Ionic encapsulam estilo em Shadow DOM. Personalize exclusivamente via propriedades CSS customizadas (`--background`, `--padding-start`), `::part(...)` expostos na documentação oficial ou componentes internos leves — nunca use `::ng-deep` nem seletores acoplados a nós internos.
- **Ponte Capacitor segura e com fallback**: verifique `Capacitor.isNativePlatform()` e `Capacitor.isPluginAvailable('Nome')` antes de invocar APIs nativas, encapsulando plugins atrás de adaptadores testáveis com fallback para Web/PWA.
- **Permissões e hardware**: solicite permissões nativas (câmera, localização, notificações) de forma contextual (*just-in-time*), tratando negação permanente com instrução para abrir ajustes do sistema. Trate o botão físico voltar no Android (`App.addListener('backButton', ...)`) respeitando modais e raiz da navegação.
- **Rede e CORS em WebView**: requisições em WKWebView/Android WebView têm origem própria (`capacitor://localhost` / `http://localhost`). Configure CORS no backend ou utilize `CapacitorHttp` conforme decisão do projeto, com timeout e cancelamento.
- **Armazenamento seguro e segredos**: nunca armazene tokens JWT, refresh tokens, PINs ou dados sensíveis em `localStorage`, `sessionStorage` ou `@capacitor/preferences` em claro; use plugin apoiado em Keychain (iOS) e Keystore (Android) e nunca embuta segredos de API no bundle web (`sk-security`).
- **UI móvel e acessibilidade**: respeite `env(safe-area-inset-top/bottom)` para notch e barras do sistema, ajuste comportamento de teclado (`Keyboard` plugin / scroll ao focar campo), garanta alvos de toque `>= 44×44 pt` (iOS) e `>= 48×48 dp` (Android), contraste claro/escuro e listas longas virtualizadas (`IonInfiniteScroll` ou virtualização dedicada) (`sk-design-system`).
- **Persistência offline (SQLite / `@capacitor-community/sqlite`)**: todas as consultas locais devem usar parâmetros vinculados (sem interpolação SQL), projeção estrita (sem `SELECT *`) e paginação/filtros eficientes; **entregue obrigatoriamente o script/migration de criação dos índices adequados** com script de rollback para filtros, junções e ordenações (`sk-sql`).
- **Testes**: isole plugins Capacitor e repositórios locais com dublês em Vitest/Jest (`sk-testing`); valide que `cap doctor` não aponte desalinhamento entre pacote web e projeto nativo.

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): página standalone Ionic com `ionViewWillEnter`/`ionViewWillLeave` e `addIcons`, adaptador seguro para plugin Capacitor com detecção de plataforma/permissão e repositório SQLite offline com migration de índice composto + rollback.

---

## 3. Integrações

`sk-tech-angular`, `sk-tech-react` e `sk-tech-vue` (reatividade e estrutura do framework hospedeiro), `sk-tech-typescript` (tipos estritos), `sk-design-system` (tokens, contraste claro/escuro e a11y mobile), `sk-sql` (consultas e índices no SQLite offline), `sk-security` (armazenamento seguro, CORS/WebView e ausência de segredos no bundle), `sk-testing` (mocks de plugins e testes de página), `sk-api-design`, `sk-observability`, `sk-devops`, `sk-upgrade`, `sk-code-review` e `sk-tasks`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Confiar só em `ngOnInit`/`useEffect([])`/`onMounted`**: a página continua em cache no `IonRouterOutlet` e deixa de atualizar ao voltar na pilha de navegação.
- **Esquecer `addIcons()` em build standalone**: ícones desaparecem sem lançar erro de compilação.
- **Quebrar Shadow DOM com `::ng-deep` ou `!important` em seletores internos**: quebra em atualizações de patch do Ionic.
- **Guardar token em `localStorage` ou `@capacitor/preferences`**: ambos são legíveis em dispositivos com acesso local ou XSS; use armazenamento apoiado em Keychain/Keystore.
- **Chamar plugin nativo sem checar `isPluginAvailable`/`isNativePlatform`**: lança `unimplemented` na Web ou em plataformas sem suporte.
- **Esquecer `npx cap sync` após instalar ou atualizar plugin**: o app nativo executa binários desatualizados em relação ao código TypeScript.
- **Consultas SQLite offline sem índices adequados e sem rollback**: travam a tela ou degradam sincronização em listas offline grandes.
- **Ignorar `safe-area-inset` e sobreposição do teclado**: cabeçalhos colidem com a barra de status e inputs ficam ocultos pelo teclado.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código Ionic + Capacitor respeitando ciclo de vida `ionView*`, Shadow DOM, permissões/fallback nativo e tratamento de erros/loading/vazio, com links relativos.
3. Se alterar plugins ou persistência local (SQLite): lembrete explícito de sincronização nativa (`npx cap sync`) quando aplicável, verificação de performance da query e **script/migration de criação dos índices adequados com rollback**.
4. Resultado de testes, tipos, lint e `cap doctor` quando executado, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-ionic`, P1 a P3; fallback em lista no chat).
