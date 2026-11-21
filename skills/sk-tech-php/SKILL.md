---
name: sk-tech-php
description: "Orienta PHP moderno (puro, Laravel, Symfony): strict_types, tipagem, enums/readonly, property hooks, PDO com prepared statements, queries performáticas com índices, sem N+1, PHPStan e PHPUnit/Pest. Use para código ou APIs PHP. NÃO use para SQL avançado (sk-sql), OpenAPI (sk-api-design) nem segurança em profundidade (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(composer test *), Bash(vendor/bin/phpunit *), Bash(vendor/bin/pest *), Bash(vendor/bin/phpstan *), Bash(vendor/bin/php-cs-fixer fix --dry-run *)
---

# PHP: tipado, seguro e previsível

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-php`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia `require.php` no `composer.json` e use só o que a versão suporta: propriedades `readonly` e enums (8.1), classes `readonly` (8.2), *property hooks* e visibilidade assimétrica (8.4). Em versões anteriores, valide no construtor. Recursos novos: confirme na documentação oficial.

**Siga o projeto.** Respeite o framework, o padrão de estilo (PSR-12 ou PER) e o nível do PHPStan já adotados.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código seguem o projeto.

---

## 1. Princípios

- **`declare(strict_types=1);`** em todo arquivo; tipos em propriedades, parâmetros e retornos; `===` em vez de `==`.
- **Strings e interpolação**: respeite o padrão do projeto; sem convenção definida, prefira interpolação com chaves explícitas (`"Olá, {$nome}"`, `{$obj->prop}`) ou *heredoc* (`<<<TEXT ... TEXT;`) para blocos multilinhas em vez de concatenações longas (evite `${var}`, obsoleta no PHP 8.2).
- **Modelagem**: enums, `readonly`, promoção de propriedades no construtor, `match`. Atenção: classes `readonly` **não** podem ter *property hooks*.
- **Banco**: PDO com `ERRMODE_EXCEPTION` e `ATTR_EMULATE_PREPARES => false`, sempre com *prepared statements*; N+1 evitado com carregamento antecipado (`with()` no Eloquent, *fetch join* no Doctrine). Toda nova consulta (SQL puro ou ORM) deve ser performática: verifique filtros, junções e ordenação e **entregue obrigatoriamente o script DDL/migration com a criação dos índices adequados** à query proposta, com respectivo rollback. Para modelagem e consultas avançadas, `sk-sql`.
- **Saída**: `htmlspecialchars($texto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')` ou mecanismo de template com escape automático.
- **Senhas**: `password_hash` e `password_verify` (Argon2id ou o padrão atual), nunca hash rápido (`sk-security`).
- **Dinheiro**: inteiros em centavos, `bcmath` ou uma biblioteca de valores monetários; nunca `float`.
- **Erros**: exceções, sem o operador `@`; logs PSR-3; `display_errors` desligado em produção.
- **Produção**: `composer install --no-dev --optimize-autoloader --classmap-authoritative`, `composer.lock` versionado e OPcache ativo.
- **Qualidade**: PHPStan no nível mais alto viável, formatação automática, testes com PHPUnit ou Pest (`sk-testing`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): DTO com *property hook* e visibilidade assimétrica (PHP 8.4+) e repositório PDO seguro com *prepared statements* e UTC.

---

## 3. Integrações

`sk-sql` (modelagem e consultas), `sk-security` (senhas, sessões, uploads), `sk-api-design`, `sk-testing`, `sk-observability`, `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Nova query SQL ou ORM sem verificar performance e sem entregar o script/migration de criação de índices adequados.**
- **Sem `strict_types`**: conversões silenciosas (`"123"` aceito como `int`).
- **SQL por concatenação**: injeção, mesmo em variáveis que "parecem seguras".
- **N+1 em Eloquent ou Doctrine**: relacionamentos acessados dentro de laços.
- **`==` com comparação frouxa**: resultados surpreendentes entre tipos.
- **`@` para silenciar erros** e `display_errors` ligado em produção.
- **`unserialize` ou `include` com dados do usuário.**
- **`float` para dinheiro.**
- **Classe `readonly` com property hooks**: combinação inválida.
- **Concatenação excessiva ou sintaxe obsoleta `${var}`** em strings interpoladas.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `strict_types`, tipos completos e compatível com a versão do projeto, com links relativos.
3. Se implementar nova consulta SQL/ORM: verificação de performance e script/migration de criação dos índices adequados (com rollback).
4. Resultado de testes, PHPStan e estilo, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-php`, P1 a P3; fallback em lista no chat).
