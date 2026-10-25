---
name: -assessment
description: "Avalia um projeto existente como um todo e recomenda melhorias, evoluções e ideias de novas funcionalidades, com evidências e prioridade: parte do contexto (CONTEXT.md, ARCHITECTURE.md, PRD.md, ADRs), examina as dimensões (arquitetura, qualidade e testes, segurança, dados, observabilidade, entrega, dependências, documentação e produto) e entrega um relatório com achados, quick wins e roadmap, encaminhando cada item para a skill certa. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'avalie o projeto', 'o que posso melhorar?', 'faça um diagnóstico do projeto', 'sugira evoluções e novas funcionalidades' ou 'faça um health check do repositório'. NÃO use para revisar um diff (isso é -code-review), mapear o contexto (isso é -discovery), decidir ou especificar (isso é -challenge e -spec) nem para corrigir os problemas encontrados."
disable-model-invocation: true
allowed-tools: Read, Write, Grep, Glob, Bash(git log *), Bash(git ls-files *), Bash(git status *), Bash(git shortlog *), Bash(git remote *), Bash(npm audit), Bash(npm outdated), Bash(pnpm audit), Bash(pnpm outdated), Bash(pip-audit), Bash(composer audit), Bash(dotnet list * --vulnerable), Bash(dotnet list * --outdated)
---

# Assessment: avaliar o projeto e apontar o próximo passo

Examina o projeto inteiro, dimensão por dimensão, e transforma o que encontra em recomendações **com evidência e prioridade**. A skill diagnostica e recomenda; quem decide e quem executa são o usuário e as outras skills.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-assessment`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** Nunca execute por conta própria durante outras tarefas.

**Somente leitura.** Não altere código. A única escrita é o relatório, e só se o usuário pedir (`docs/assessments/AAAA-MM-DD-assessment.md`). Não instale dependências nem execute scanners ativos contra sistemas de produção.

**Evidência.** Todo achado cita arquivo, linha, comando ou medição. O que não tiver evidência é marcado `(hipótese)`. Seja explícito sobre o que **não** foi verificado.

**Sem objetivos de negócio inventados.** Ideias de funcionalidades e de evolução são hipóteses `[A CONFIRMAR]`, derivadas do `PRD.md` e de lacunas observadas, nunca fatos.

**Recomendar não é decidir.** Decisões vão para o `-challenge` e o `-adr`; a especificação, para o `-spec`.

**Segredos e vulnerabilidades.** Mascare credenciais encontradas (`sk-****`). Não detalhe falhas de segurança em canal público; o relatório de segurança segue as regras do `-security`.

**Pessoas.** Não avalie indivíduos. Dados de autoria entram agregados por área, apenas para indicar concentração de conhecimento.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Completa** | Todas as dimensões (seção 3) |
| **Focada** | O usuário escolhe as dimensões ("só segurança e dados") |
| **Evolução** | Só oportunidades de produto e roadmap, a partir do PRD e das lacunas |

---

## 2. Workflow

1. **Contexto**: leia `CONTEXT.md`, `ARCHITECTURE.md`, `PRD.md`, `DATA.md`, ADRs, `TASKS.md`, `CHANGELOG.md` e o README. Sem esses documentos, sugira o `-discovery` primeiro; só siga com uma varredura leve se o usuário pedir, declarando a limitação.
2. **Objetivo e restrições**: pergunte, em no máximo 3 perguntas, o que o usuário busca (reduzir risco, escalar, preparar uma venda ou transferência, planejar evolução) e as restrições (prazo, equipe, orçamento). Sem resposta, assuma "avaliação geral" e declare.
3. **Coleta por dimensão** (seção 3), guiada por metadados e por amostragem. Não leia o código inteiro.
4. **Achados** (seção 4) e **priorização** (seção 5).
5. **Relatório** (seção 6) e **encaminhamento** (seção 7).

---

## 3. Dimensões

| Dimensão | O que examinar | Skill de apoio |
| :--- | :--- | :--- |
| **Arquitetura e design** | Estilo, acoplamento, fronteiras, dívida estrutural, coerência com os ADRs | `-system-design`, `-refactor` |
| **Qualidade e testes** | Relatórios de cobertura existentes, testes instáveis, *hotspots* (arquivos mais alterados no `git log`), complexidade e smells | `-testing`, `-code-review`, `-refactor` |
| **Segurança** | Segredos, dependências vulneráveis (`audit`), autenticação e autorização, configuração | `-security` |
| **Dados** | Modelagem, índices, migrações, consultas problemáticas | `-sql` |
| **Observabilidade e operação** | Logs, métricas, SLOs, health checks, tratamento de falhas | `-observability` |
| **Entrega** | CI/CD, contêiner, releases, ambientes | `-devops`, `-git` |
| **Dependências e manutenção** | Pacotes desatualizados ou abandonados (`outdated`), versão do runtime fora de suporte, licenças | `-security`, as `-tech-*` |
| **Documentação** | README, contexto, ADRs e specs desatualizados | `-readme`, `-discovery` |
| **Produto e evolução** | Funcionalidades do PRD, fluxos incompletos, `TODO` e `FIXME`, lacunas e oportunidades | `-challenge`, `-spec` |
| **Concentração de conhecimento** (opcional) | Áreas mantidas por poucas pessoas, em dados agregados (`git shortlog`) | n/d |

---

## 4. Formato do achado

Cada achado tem: **ID** (`A-01`), dimensão, título, **evidência**, **impacto** (alto, médio, baixo), **recomendação**, **esforço** (P, M, G), **confiança** (alta, média, baixa) e a **skill de encaminhamento**.

---

## 5. Priorização

| Grupo | Critério |
| :--- | :--- |
| **Quick wins** | Impacto alto, esforço baixo |
| **Melhorias planejadas** | Impacto alto, esforço alto: precisam de plano |
| **Manutenção contínua** | Impacto baixo, esforço baixo |
| **Não fazer agora** | Impacto baixo, esforço alto (registre o motivo) |

Riscos de segurança críticos (segredo exposto, vulnerabilidade explorável) sobem para o topo, independentemente do esforço.

**Ideias de evolução** entram em uma seção própria, como hipóteses: o racional (qual lacuna ou dado as motiva), o esforço estimado, o risco e **o que validar antes** de especificar.

---

## 6. Relatório

Mantenha o corpo em até ~150 linhas, com o detalhe em anexo.

````markdown
# Avaliação do projeto: <nome>

> Atualizado em: <AAAA-MM-DD> | Modo: Completa | Objetivo: <objetivo informado ou "avaliação geral">

## Resumo executivo
- **Estado geral**: <duas ou três frases>
- **Maiores riscos**: 1) ... 2) ... 3) ...
- **Maiores oportunidades**: 1) ... 2) ... 3) ...

## Cobertura e limitações
- Avaliado: <dimensões e amostra>. Não verificado: <o que ficou de fora e por quê>.

## Achados

| ID | Dimensão | Achado | Evidência | Impacto | Esforço | Encaminhar para |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| A-01 | Segurança | Dependência com vulnerabilidade conhecida | `package.json`, saída do `npm audit` | Alto | P | `-security` |

## Quick wins
1. A-01: atualizar a dependência.

## Roadmap sugerido
- **Agora**: ... | **Próximo**: ... | **Depois**: ...

## Ideias de evolução (hipóteses)
| Ideia | Racional | Esforço | Risco | Validar antes |
| :--- | :--- | :--- | :--- | :--- |
| <ideia> | <lacuna observada> | M | <risco> | <o que confirmar com quem usa> |

## Próximos passos
- Validar a ideia X com o `-challenge`; especificar com o `-spec`; registrar a decisão Y com o `-adr`.

## Notas da Equipe
*(Espaço reservado para anotações manuais da equipe. A skill não altera esta seção.)*
````

---

## 7. Encaminhamento e integrações

| Skill | Como se integra |
| :--- | :--- |
| `-discovery` | Fonte do contexto; sugerido antes se o contexto não existir |
| `-challenge` | Valida as ideias de evolução antes de especificar |
| `-spec`, `-adr` | Especificar o que foi aprovado e registrar as decisões |
| `-refactor`, `-testing`, `-security`, `-sql`, `-observability`, `-devops`, `-readme` | Executam os achados da sua dimensão |
| `-tasks` | Registro das recomendações |

Se restaram recomendações, pergunte se o usuário quer registrá-las via `-tasks` (modo Importar, origem `assessment`): riscos críticos em P0, quick wins em P1, melhorias planejadas em P2, manutenção e evolução em P3; fallback em lista no chat.

---

## 8. Armadilhas

- **Avaliação genérica**: toda recomendação aponta para algo observado no projeto.
- **Achado sem evidência**: marque como hipótese.
- **Misturar fato e hipótese**, principalmente nas ideias de produto.
- **Inventar necessidades de negócio.**
- **Lista sem prioridade**: ela não ajuda a decidir.
- **Relatório gigante**: use o limite e os anexos.
- **Avaliar pessoas** em vez do sistema.
- **Recomendar reescrever do zero** sem evidência de que a refatoração incremental não serve.
- **Agir sem pedido**: corrigir, instalar ou alterar código.
- **Ignorar o objetivo do usuário**: a prioridade muda conforme o que ele busca.

---

## 9. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0), o modo e o objetivo considerado.
2. O relatório (no chat, ou em arquivo se pedido), com cobertura e limitações explícitas.
3. Achados priorizados, quick wins e roadmap.
4. Ideias de evolução marcadas como hipóteses, com o que validar antes.
5. Próximos passos por skill e a pergunta sobre o registro em tarefas (seção 7).