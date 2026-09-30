---
name: _tech-php
description: Orienta o desenvolvimento em PHP moderno. Use ao criar aplicações web, estruturar rotas, modelos de domínio, consultas seguras a banco de dados e APIs em PHP puro ou frameworks.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(composer test *), Bash(vendor/bin/phpunit *), Bash(vendor/bin/pest *)
---

# Tech Skill: Modern PHP Specialist (PHP 8.3/8.4+)

Diretrizes técnicas especializadas para desenvolvimento em PHP moderno corporativo, aplicáveis tanto a código em PHP puro quanto a frameworks como Laravel e Symfony.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-php``

---

## 1. Processo de Execução de Engenharia PHP

Ao implementar soluções em PHP:

1. **Ativação de Tipagem Estrita**: Inicie 100% dos arquivos `.php` com `declare(strict_types=1);`.
2. **Modelagem de Domínio com DTOs e Property Hooks**: Utilize recursos do PHP 8.4 (*Property Hooks* e *Asymmetric Visibility*) para criar DTOs e entidades imutáveis e auto-validadas.
3. **Acesso Seguro a Banco (PDO / ORM)**: Utilize exclusivamente *Prepared Statements* com `bindValue` parametrizado no PDO e previna problemas N+1 em ORMs com *Eager Loading*.
4. **Segurança de Entrada e Saída**: Valide payloads na borda e aplique `htmlspecialchars()` com codificação UTF-8 explícita em todas as saídas HTML.
5. **Otimização de Produção**: Configure o autoloader do Composer com `--classmap-authoritative` e ative o OPcache nos contêineres de produção.

---

## 2. Snippets Canônicos de Referência

### 2.1. PHP 8.4 Property Hooks, Asymmetric Visibility e DTO Imutável
```php
<?php

declare(strict_types=1);

namespace App\Domain\DTO;

use InvalidArgumentException;

final readonly class CreateUserDTO
{
    // PHP 8.4: Property Hooks para validação limpa integrada à propriedade
    public string $email {
        set {
            if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                throw new InvalidArgumentException("Endereço de e-mail inválido: {$value}");
            }
            $this->email = mb_strtolower(trim($value));
        }
    }

    // PHP 8.4: Visibilidade assimétrica (leitura pública, escrita privada)
    public private(set) string $name;

    public function _construct(string $name, string $email)
    {
        if (mb_strlen(trim($name)) < 2) {
            throw new InvalidArgumentException("O nome deve ter pelo menos 2 caracteres.");
        }
        $this->name = trim($name);
        $this->email = $email;
    }
}
```

### 2.2. Repositório Seguro com PDO e Prepared Statements
```php
<?php

declare(strict_types=1);

namespace App\Infrastructure\Repository;

use PDO;
use App\Domain\DTO\CreateUserDTO;

final class PDOUserRepository
{
    public function _construct(private readonly PDO $pdo) {}

    public function create(CreateUserDTO $dto): int
    {
        $sql = "INSERT INTO users (name, email, created_at) VALUES (:name, :email, NOW())";
        $stmt = $this->pdo->prepare($sql);
        
        // Parametrização segura contra SQL Injection
        $stmt->bindValue(':name', $dto->name, PDO::PARAM_STR);
        $stmt->bindValue(':email', $dto->email, PDO::PARAM_STR);
        $stmt->execute();

        return (int) $this->pdo->lastInsertId();
    }
}
```

---

## 3. Armadilhas Críticas em PHP (*Gotchas*)

- ⚠️ **Ausência de `declare(strict_types=1)`**: Sem essa declaração no topo do arquivo, o PHP converte tipos silenciosamente (ex: a string `"123"` é aceita em um parâmetro tipado como `int`), gerando comportamentos imprevisíveis.
- ⚠️ **Concatenação em Consultas SQL**: Concatenar variáveis diretamente na string de query mesmo que pareçam seguras abre vetores graves de SQL Injection. Use sempre *Prepared Statements*.
- ⚠️ **N+1 Queries em Eloquent / Doctrine**: Iterar sobre uma coleção executando acessos a relacionamentos em loops sem `with(['relacao'])` gera centenas de consultas desnecessárias ao banco de dados.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em PHP:
1. Declare `declare(strict_types=1);` no início de cada arquivo.
2. Especifique tipos explícitos para todas as propriedades, parâmetros e retornos.
3. Garanta que o código siga as normas PSR-12/PER e passe na análise do PHPStan (Nível 8+).
