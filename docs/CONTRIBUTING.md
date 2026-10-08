# 🤝 Guia de Contribuição

Obrigado por considerar contribuir com este projeto! Sua colaboração é fundamental para torná-lo ainda melhor.

## 📌 Como Contribuir

1. **Faça um Fork do repositório**
2. **Crie uma nova branch** para sua correção ou funcionalidade:

   ```bash
   git checkout -b feature/<nome-da-feature>
   ```

3. **Faça commit das alterações** utilizando o padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/)
4. **Envie para o seu fork (Push)** e abra um Pull Request

## 📖 Regras de Contribuição

* Siga o estilo de código e convenções de nomenclatura existentes.
* Escreva mensagens de commit claras e descritivas.
* Atualize ou adicione testes quando aplicável.
* Ao adicionar novos recursos, atualize a documentação correspondente.

<!-- 
## 📦 Scripts do Projeto

* `npm run test` — executa testes unitários
* `npm run docs:dev` — executa a documentação localmente
* `npm run release:test` — simulação de semantic release 
-->

## Formato das Mensagens de Commit

Todas as mensagens de commit direcionadas à branch principal devem seguir o padrão Conventional Commits. Por exemplo:

```text
 feat: Allowed provided config object to extend other configs
  ^
(tipo)
```

Os tipos suportados são:

* **Sem incremento de versão:**
  * **build**: Alterações que afetam o sistema de build ou dependências externas (escopos de exemplo: composer, npm, etc.)
  * **chore**: Alterações rotineiras que não afetam o código de produção nem a versão de patch (ex.: remover arquivos não utilizados)
  * **ci**: Alterações nos arquivos e scripts de configuração de CI/CD
  * **docs**: Alterações exclusivamente na documentação
  * **perf**: Alteração de código voltada para melhoria de desempenho
  * **refactor**: Alteração de código que não corrige bugs nem adiciona novas features
  * **style**: Alterações que não afetam o comportamento do código (espaçamento, formatação, pontuação faltante, etc.)
  * **test**: Adição de testes faltantes ou correção de testes existentes
* **Atualização de versão Patch:**
  * **fix**: Correção de bug
  * **revert**: Reversão de um commit anterior
* **Atualização de versão Minor:**
  * **feat**: Nova funcionalidade ou recurso
* **Atualização de versão Major:**
  * **breaking** ou **breaking change**: Modificação incompatível com versões anteriores (breaking change)

## 📑 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a [Licença MIT](../LICENSE) do projeto.

Obrigado por ajudar a melhorar este projeto! 🚀
