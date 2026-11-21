# Modelo do Relatório de Assessment (`sk-assessment`)

Mantenha o relatório analítico, sem floreios e direto ao ponto. Em torno de 150 a 200 linhas no corpo principal:

````markdown
# Diagnóstico de Excelência do Projeto: <nome>

> Data: <AAAA-MM-DD> | Modo: <Completa / Focada / Arquitetura & Consolidação / Evolução> | Objetivo: <objetivo declarado>

## 1. Resumo Executivo e Diagnóstico Geral
- **Estado Geral de Engenharia**: <avaliação honesta e realista em 2-3 frases, sem adulação>.
- **Maiores Fraquezas e Riscos Técnicos**:
  1. ...
  2. ...
- **Maiores Oportunidades de Excelência**:
  1. ...
  2. ...

## 2. Cobertura e Limitações
- **Inspecionado**: <dimensões, diretórios e amostras analisadas>.
- **Não verificado**: <o que não foi analisado e por qual motivo técnico>.

## 3. Simplificação, Poda e Consolidação
*(Mapeamento de duplicidades conceituais e código redundante para mesclar ou eliminar)*

| ID | Alvos de Fusão / Poda | Diagnóstico da Redundância | Proposta de Consolidação | Esforço |
| :--- | :--- | :--- | :--- | :--- |
| C-01 | `src/Services/AuthService.php` e `src/Security/TokenManager.php` | Regras de validação de token duplicadas com implementações divergentes. | Mesclar em um único gerenciador de tokens unificado e eliminar classe redundante. | M |

## 4. Tabela de Achados Críticos

| ID | Dimensão | Achado & Evidência | Diagnóstico Crítico | Impacto | Esforço | Horizonte | Encaminhar |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| A-01 | Performance | Falta de índice composto em `users(tenant_id, email)` em [002.sql](./src/db/migrations/002.sql#L15) | Toda autenticação realiza Seq Scan na tabela de usuários, degradando latência sob carga. | Alto | P | Curto Prazo | `sk-sql` |

## 5. Plano de Ação por Horizontes

### Curto Prazo (Quick Wins & Correções Imediatas)
1. **[A-01]**: Adicionar o índice composto para destravar a performance de busca.
2. ...

### Médio Prazo (Consolidação & Refatoração Tática)
1. **[C-01]**: Concluir a fusão dos serviços de autenticação, eliminando divergências e testes redundantes.
2. ...

### Longo Prazo (Arquitetura-Alvo & Novas Funcionalidades)
1. ...

## 6. Oportunidades de Novas Funcionalidades e Produto (Hipóteses)
| Ideia | Racional e Lacuna Observada | Esforço | Risco | O que validar antes |
| :--- | :--- | :--- | :--- | :--- |
| <funcionalidade> | <dor no fluxo do usuário ou ausência no PRD> | M | <risco técnico/negócio> | <critério de validação> |

## 7. Próximos Passos e Encaminhamento
- Validar hipóteses de evolução e arquitetura com o `sk-challenge`.
- Especificar as soluções aprovadas via `sk-spec`.
- Registrar decisões arquiteturais com o `sk-adr`.
- Registrar pendências no backlog via `sk-tasks`? *(Confirmar com o usuário)*.

## Notas da Equipe

_Espaço reservado para anotações manuais da equipe. A skill não altera esta seção._
````
