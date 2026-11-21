# Padrões e Exemplos de PHP (`sk-tech-php`)

## 1. DTO com property hook e visibilidade assimétrica (PHP 8.4)

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

## 2. Conexão e repositório com PDO

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
