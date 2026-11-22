---
name: sk-tech-react-native
description: "Orienta React Native e Expo: New Architecture, navegação tipada, listas virtualizadas (FlashList), armazenamento seguro, a11y mobile, persistência local SQLite com índices e testes. Use para telas, estado ou performance no app RN. NÃO use para React web (sk-tech-react), tipagem (sk-tech-typescript) nem tokens/WCAG (sk-design-system)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx tsc *), Bash(npx jest *), Bash(npx eslint *), Bash(npx expo-doctor *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *)
---

# React Native & Expo: interfaces móveis fluidas e resilientes

Orienta aplicativos iOS e Android com React Native ou Expo, equilibrando fluidez na UI thread, consumo de memória, segurança em dispositivo, acessibilidade móvel e persistência offline previsível.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-react-native`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ambiente e arquitetura.** Leia `package.json`, `app.json` / `app.config.*`, `tsconfig.json` e pasta `ios/`/`android/` (quando existir) para confirmar: React Native vs Expo (managed vs CNG/bare), roteador (`expo-router` vs `@react-navigation/*`) e habilitação da *New Architecture* (Fabric / TurboModules / Hermes). Use apenas APIs compatíveis com as versões instaladas e delegue tipagem estrita ao `sk-tech-typescript`.

**Alterações nativas pedem cautela.** Permissões em `Info.plist`/`AndroidManifest.xml`, *config plugins* e módulos nativos exigem novo prebuild ou build nativo: sinalize antes de exigir recompilação binária ou instalar bibliotecas com código nativo.

**Timebox e Circuit Breaker.** Ao corrigir erros de tipos, bundler (Metro), lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Navegação tipada e *deep linking***: defina parâmetros de rota com contratos TypeScript (`expo-router` tipado ou `NativeStackScreenProps`), validando parâmetros externos recebidos por *deep link* na borda da tela.
- **Estado no lugar certo**: estado local mínimo na tela; estado de servidor com TanStack Query integrado ao foco de tela (`useFocusEffect`) e reconexão via `AppState`/estado de rede; estado global de cliente apenas quando compartilhado.
- **Listas e desempenho sob medição**: nunca renderize listas dinâmicas extensas com `ScrollView` + `.map()`. Use `FlashList` (ou `FlatList` configurado com `keyExtractor` estável e `estimatedItemSize`), evitando criar funções inline pesadas ou re-renders em cascata. Aplique `memo` apenas onde o profiler indicar ganho real.
- **Animações e gestos fora da JS thread**: animações contínuas e transições de gesto usam `react-native-reanimated` e `react-native-gesture-handler` na UI thread; evite `Animated` clássico em JS quando o projeto já usa Reanimated.
- **Armazenamento seguro e zero segredos no bundle**: tokens de sessão, chaves privadas e segredos do dispositivo vão obrigatoriamente para `expo-secure-store` ou Keychain/Keystore nativo. Nunca salve credenciais em `AsyncStorage`, `MMKV` sem criptografia ou em variáveis públicas (`EXPO_PUBLIC_*`, `.env` embutido no JS) (`sk-security`).
- **Acessibilidade e ergonomia móvel**: use `useSafeAreaInsets` / `SafeAreaView` para respeitar notch e barras do sistema; garanta alvos de toque `>= 44×44 pt` (iOS) / `>= 48×48 dp` (Android); preencha `accessibilityRole`, `accessibilityLabel` e `accessibilityState`; suporte escalonamento de fonte do sistema (`allowFontScaling`) e contraste nos modos claro/escuro (`sk-design-system`).
- **Persistência local (SQLite / Drizzle / WatermelonDB)**: consultas locais devem ser parametrizadas, sem `SELECT *` e sem N+1. Analise filtros, junções e ordenações e **entregue obrigatoriamente o script/migration de criação dos índices adequados** com script de rollback (`sk-sql`).
- **Imagens, teclado e ciclo de app**: trate `KeyboardAvoidingView`/scroll de formulários, otimize imagens em listas (`expo-image` com política de cache/tamanho) e limpe assinaturas de `AppState`, listeners nativos e temporizadores no desmonte.
- **Erros e observabilidade**: isole falhas por fluxo com *Error Boundaries*, exiba estados explícitos de carregamento, vazio e erro com ação de tentar novamente, e registre erros tratados sem PII (`sk-observability`).
- **Testes**: React Native Testing Library (`getByRole`, `getByText`) com Jest + mocks de módulos nativos e MSW para camada HTTP (`sk-testing`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): lista virtualizada acessível com *safe area* e estados completos integrada ao TanStack Query, repositório isolado de `expo-secure-store` e consulta `expo-sqlite` parametrizada com migration de índice composto + rollback.

---

## 3. Integrações

`sk-tech-typescript` (tipagem), `sk-design-system` (tokens, contraste claro/escuro e a11y mobile), `sk-sql` (consultas e índices em SQLite local), `sk-security` (Keychain/Keystore, *deep links* e segredos), `sk-testing` (RNTL, mocks nativos e Jest), `sk-api-design` (contratos), `sk-observability` (telemetria de falhas e desempenho), `sk-devops` (EAS Build / pipelines iOS e Android), `sk-upgrade` (upgrades Expo SDK / React Native), `sk-tech-react`, `sk-code-review` e `sk-tasks`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Salvar tokens de autenticação em `AsyncStorage`**: texto puro acessível no sistema de arquivos do aparelho em backups ou root.
- **Colocar segredos de API em `EXPO_PUBLIC_*` ou no bundle JS**: qualquer string no pacote é extraível do APK/IPA.
- **Usar `ScrollView` com `.map()` para dezenas/centenas de itens**: picos de memória e travamento de rolagem.
- **Consultas SQLite/ORM locais sem índices adequados e sem rollback**: bloqueiam a ponte e congelam transições de tela.
- **Ignorar `useSafeAreaInsets` ou teclado virtual**: botões inferiores sobrepostos por barra de gestos ou teclado escondendo o campo ativo.
- **Passar funções anônimas instáveis e objetos novos em `renderItem` sem estabilização**: invalida a reciclagem de células do `FlashList`/`FlatList`.
- **Assumir `window`/`document` de navegador**: quebra em Hermes/runtime nativo ou gera divergência no SSR/Web.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Telas e serviços tipados com virtualização de listas, *safe areas*, acessibilidade e estados de carregamento/vazio/erro, com links relativos.
3. Se implementar nova query ou tabela local (SQLite/Drizzle/WatermelonDB): verificação de performance e **script/migration de criação dos índices adequados com rollback**.
4. Resultado de `tsc`, testes e lint (`expo-doctor` quando aplicável), o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-react-native`, P1 a P3; fallback em lista no chat).
