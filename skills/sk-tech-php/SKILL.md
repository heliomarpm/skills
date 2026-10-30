---
name: sk-tech-php
description: "Orienta PHP moderno em PHP puro ou frameworks (Laravel, Symfony): strict_types, tipagem completa, enums e readonly, property hooks e visibilidade assimétrica quando a versão permite, PDO com prepared statements, hash de senhas, escape de saída, N+1, Composer, OPcache e análise estática. Use sempre que o usuário pedir 'código PHP', 'PDO', 'Laravel', 'Symfony', 'DTO em PHP', 'PHPStan' ou 'migre de versão do PHP', mesmo sem dizer 'PHP'. NÃO use para modelagem e SQL em si (isso é sk-sql), contratos de API (isso é sk-api-design) nem para segurança em profundidade (isso é sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(composer test *), Bash(vendor/bin/phpunit *), Bash(vendor/bin/pest *), Bash(vendor/bin/phpstan *), Bash(vendor/bin/php-cs-fixer fix --dry-run *)
---

# PHP: tipado, seguro e previsível

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-php`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia `require.php` no `composer.json` e use só o que a versão suporta: propriedades `readonly` e enums (8.1), classes `readonly` (8.2), *property hooks* e visibilidade assimétrica (8.4). Em versões anteriores, valide no construtor. Recursos novos: confirme na documentação oficial.

**Siga o projeto.** Respeite o framework, o padrão de estilo (PSR-12 ou PER) e o nível do PHPStan já adotados.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código seguem o projeto.

---

## 1. Princípios

- **`declare(strict_types=1);`** em todo arquivo; tipos em propriedades, parâmetros e retornos; `===` em vez de `==`.
- **Strings e interpolação**: use sempre interpolação de strings com aspas duplas por padrão (`"Olá, {$nome}"`) em vez de concatenação (`'Olá, ' . $nome`). Use chaves explícitas (`{$var}`, `{$obj->prop}`) para clareza e consistência (evite `${var}`, descontinuada no PHP 8.2); para textos multilinhas ou blocos extensos, use *heredoc* (`<<<TEXT ... TEXT;`) em vez de concatenar quebras de linha; reserve a concatenação com ponto (`.`) apenas para expressões complexas que não possam ser interpoladas diretamente.
- **Modelagem**: enums, `readonly`, promoção de propriedades no construtor, `match`. Atenção: classes `readonly` **não** podem ter *property hooks*.
- **Banco**: PDO com `ERRMODE_EXCEPTION` e `ATTR_EMULATE_PREPARES => false`, sempre com *prepared statements*; N+1 evitado com carregamento antecipado (`with()` no Eloquent, *fetch join* no Doctrine). Para modelagem e consultas, `sk-sql`.
- **Saída**: `htmlspecialchars($texto, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')` ou mecanismo de template com escape automático.
- **Senhas**: `password_hash` e `password_verify` (Argon2id ou o padrão atual), nunca hash rápido (`sk-security`).
- **Dinheiro**: inteiros em centavos, `bcmath` ou uma biblioteca de valores monetários; nunca `float`.
- **Erros**: exceções, sem o operador `@`; logs PSR-3; `display_errors` desligado em produção.
- **Produção**: `composer install --no-dev --optimize-autoloader --classmap-authoritative`, `composer.lock` versionado e OPcache ativo.
- **Qualidade**: PHPStan no nível mais alto viável, formatação automática, testes com PHPUnit ou Pest (`sk-testing`).

---

## 2. Exemplos

### 2.1. DTO com property hook e visibilidade assimétrica (PHP 8.4)

```php
<?php

declare(strict_types=1);

namespace App\Domain\DTO;

use InvalidArgumentException;

final class CriarUsuarioDTO
{
    // Leitura pública, escrita só dentro da classe; o hook valida e normaliza
    public private(set) string $email {
        set {
            if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                throw new InvalidArgumentException("E-mail inválido: {$value}");
            }
            $this->email = mb_strtolower(trim($value));
        }
    }

    public private(set) string $nome;

    public function __construct(string $nome, string $email)
    {
        if (mb_strlen(trim($nome)) < 2) {
            throw new InvalidArgumentException('O nome deve ter ao menos 2 caracteres.');
        }
        $this->nome = trim($nome);
        $this->email = $email;
    }
}
```

Em PHP 8.3 ou anterior, valide no construtor e use propriedades `readonly`.

### 2.2. Conexão e repositório com PDO

```php
<?php

declare(strict_types=1);

namespace App\Infrastructure\Repository;

use App\Domain\DTO\CriarUsuarioDTO;
use DateTimeImmutable;
use DateTimeZone;
use PDO;

// Conexão (credenciais vindas do ambiente, nunca do código)
// $pdo = new PDO($dsn, $usuario, $senha, [
//     PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
//     PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
//     PDO::ATTR_EMULATE_PREPARES   => false,
// ]);

final class PdoUsuarioRepository
{
    public function __construct(private readonly PDO $pdo) {}

    public function criar(CriarUsuarioDTO $dto): int
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO usuarios (nome, email, criado_em) VALUES (:nome, :email, :criado_em)'
        );
        $stmt->bindValue(':nome', $dto->nome, PDO::PARAM_STR);
        $stmt->bindValue(':email', $dto->email, PDO::PARAM_STR);
        $stmt->bindValue(
            ':criado_em',
            (new DateTimeImmutable('now', new DateTimeZone('UTC')))->format('Y-m-d H:i:s'),
            PDO::PARAM_STR,
        );
        $stmt->execute();

        return (int) $this->pdo->lastInsertId(); // PostgreSQL: informe o nome da sequence
    }
}
```

---

## 3. Integrações

`sk-sql` (modelagem e consultas), `sk-security` (senhas, sessões, uploads), `sk-api-design`, `sk-testing`, `sk-observability`, `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Sem `strict_types`**: conversões silenciosas (`"123"` aceito como `int`).
- **SQL por concatenação**: injeção, mesmo em variáveis que "parecem seguras".
- **N+1 em Eloquent ou Doctrine**: relacionamentos acessados dentro de laços.
- **`==` com comparação frouxa**: resultados surpreendentes entre tipos.
- **`@` para silenciar erros** e `display_errors` ligado em produção.
- **`unserialize` ou `include` com dados do usuário.**
- **`float` para dinheiro.**
- **Classe `readonly` com property hooks**: combinação inválida.
- **Concatenação excessiva com `.`** onde a interpolação `"...{$var}..."` ou *heredoc* (`<<<TEXT`) tornaria o código mais limpo e legível (ou uso da sintaxe obsoleta `${var}`).

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `strict_types`, tipos completos e compatível com a versão do projeto, com links relativos.
3. Resultado de testes, PHPStan e estilo, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-php`, P1 a P3; fallback em lista no chat).