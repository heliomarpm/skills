---
name: _core-tech
description: Fornece diretrizes fundamentais de engenharia de software e arquitetura limpa. Use sempre que estiver projetando sistemas, estruturando código, aplicando boas práticas de segurança, observabilidade ou resiliência.
---

# Core Tech Skill: Senior Software Engineer Mindset (Language-Agnostic)

> **Escopo Global**: Esta skill é **estritamente agnóstica a linguagem e framework**. Seus princípios de arquitetura, segurança, manutenibilidade e resiliência aplicam-se universalmente a qualquer projeto de software (C#, Java, Python, TypeScript, PHP, Go, Rust, Dart, C++, etc.).


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_core-tech``

---

## 1. Processo Universal de Execução de Engenharia

1. **Separação de Camadas & Limites de Domínio**: Isole regras de negócio puras (entidades e casos de uso) de detalhes de entrada e saída (HTTP, banco de dados, mensageria, bibliotecas de terceiros).
2. **Definição Prévia de Contratos & Tipos**: Modele DTOs e interfaces imutáveis com tipagem estrita antes de codificar a execução.
3. **Validação Fail-Fast**: Valide argumentos, estados e autorizações na borda de entrada das funções e endpoints.
4. **Resiliência e Observabilidade**: Configure timeouts explícitos, retentativas com jitter, logs estruturados em JSON e encerramento gracioso (*Graceful Shutdown*).
5. **Auto-Revisão de Segurança**: Verifique ausência de segredos fixados, consultas não parametrizadas e validação rigorosa de schemas de entrada.

---

## 2. Princípios Arquiteturais e Design Limpo

- **SOLID na Prática**:
  - *Single Responsibility*: Módulos e funções com uma única razão para mudar.
  - *Open/Closed*: Extensão via polimorfismo/interfaces sem modificar o código estável.
  - *Liskov Substitution*: Implementações devem honrar o contrato da interface base.
  - *Interface Segregation*: Múltiplas interfaces pequenas e focadas em vez de interfaces inchadas.
  - *Dependency Inversion*: Módulos de alto nível dependem de abstrações, injetadas externamente.
- **KISS, DRY & YAGNI**: Não crie camadas ou abstrações prematuras sem necessidade comprovada.
- **Imutabilidade por Padrão**: Prefira objetos e coleções imutáveis. Mutações devem ser restritas e justificadas por desempenho.
- **Tratamento Robusto de Exceções**:
  - Nunca silencie exceções com blocos `catch` vazios.
  - Erros de domínio devem ser explícitos; falhas de infraestrutura devem ser registradas com contexto e propagadas.

---

## 3. Padrões Universais de Contratos e Banco de Dados

### 3.1. Contrato Universal de Erro HTTP (RFC 7807 Problem Details)
```json
{
  "type": "https://api.exemplo.com/errors/saldo-insuficiente",
  "title": "Saldo Insuficiente",
  "status": 422,
  "detail": "A conta possui saldo de R$ 50,00, insuficiente para o débito de R$ 120,00.",
  "instance": "/contas/12345/transacoes",
  "traceId": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
}
```

### 3.2. Estratégia de Migração de Banco com Zero Downtime (Expand & Contract)
- **Fase 1 (Expandir)**: Crie a nova coluna/tabela sem remover a antiga. A aplicação escreve em ambas.
- **Fase 2 (Migrar dados)**: Popule os dados históricos em background.
- **Fase 3 (Contrair)**: Atualize a aplicação para ler da nova estrutura e remova a coluna antiga no deploy subsequente.

---

## 4. Segurança em Profundidade (OWASP-Driven)

- **Zero Hardcoded Secrets**: Proibido credenciais no código. Use variáveis de ambiente e cofres de segredos.
- **Validação Estrita de Entrada**: Validação obrigatória de schemas em todo dado vindo do exterior.
- **Princípio do Menor Privilégio**: Menor modificador de visibilidade e permissão possível.
- **Consultas Parametrizadas**: Proibida a concatenação direta de strings em comandos SQL ou NoSQL.

---

## 5. Armadilhas Críticas em Produção (*Gotchas*)

- ⚠️ **Timeouts Omitidos em I/O**: Falta de timeouts em chamadas externas esgota threads e derruba o serviço.
- ⚠️ **Thundering Herd**: Retentativas automáticas sem tempo aleatório (*Jitter*) sincronizam instâncias falhas e sobrecarregam a infraestrutura.
- ⚠️ **Vazamento de Dados Pessoais em Logs**: Mascare dados sensíveis (senhas, cartões, CPFs) em logs estruturados.

---

## 6. Padrão de Entrega do Agente

Ao entregar soluções:
1. Adote a linguagem e paradigmas idiomáticos do projeto do usuário.
2. Isole as regras de negócio de detalhes de infraestrutura.
3. Garanta tipagem estrita, testabilidade e tratamento seguro de erros.
