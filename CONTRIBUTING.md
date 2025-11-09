# Contribuindo para TrainEasy

Obrigado por considerar contribuir para o TrainEasy! Este documento fornece diretrizes e informações para contribuidores.

## 📋 Código de Conduta

- Seja respeitoso e inclusivo
- Aceite críticas construtivas com graça
- Foque no que é melhor para a comunidade
- Mostre empatia com outros contribuidores

## 🚀 Como Contribuir

### Reportando Bugs

Antes de criar um bug report, por favor verifique se já não existe um issue similar. Quando criar um novo issue, inclua:

- Versão do Flutter usada
- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs atual
- Screenshots se aplicável

### Sugerindo Melhorias

- Use o template de issue para feature requests
- Explique por que essa melhoria seria útil
- Forneça exemplos de uso
- Se possível, mostre implementações alternativas

### Pull Requests

1. Fork o repositório
2. Crie uma branch a partir da `main` (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Diretrizes de Código

- Siga o estilo de código Dart/Flutter oficial
- Mantenha a cobertura de testes acima de 80%
- Documente funções e classes públicas
- Use commits semânticos:
  - `feat:` para novas funcionalidades
  - `fix:` para correções de bugs
  - `docs:` para documentação
  - `style:` para formatação
  - `refactor:` para refatoração
  - `test:` para adicionar testes
  - `chore:` para manutenção

### Segurança

⚠️ **IMPORTANTE:** Nunca commite informações sensíveis:

- Credenciais do Firebase
- Chaves de API
- Informações pessoais
- Tokens de acesso

Sempre use:
- Arquivos `.example` para templates
- Variáveis de ambiente
- Arquivos adicionados ao `.gitignore`

### Testes

- Escreva testes unitários para novas funcionalidades
- Execute todos os testes antes de submeter (`flutter test`)
- Teste em diferentes dispositivos/resoluções
- Verifique se não há regressões

### Documentação

- Atualize o README se necessário
- Documente novas funcionalidades
- Mantenha exemplos atualizados
- Adicione screenshots para mudanças visuais

## 📁 Estrutura do Projeto

```
lib/
├── core/           # Código base e utilitários
├── features/       # Funcionalidades
└── presentation/   # UI e controllers
```

## 🏗️ Arquitetura

O projeto segue Clean Architecture:

- **Domain**: Entidades e regras de negócio
- **Data**: Implementações de repositórios
- **Presentation**: UI e estado

## 🐛 Debug

Use o comando para rodar em modo debug:
```bash
flutter run --debug
```

Para análise de performance:
```bash
flutter run --profile
```

## 📊 Performance

- Use `const` construtores quando possível
- Evite rebuilds desnecessários
- Implemente lazy loading para listas
- Use imagens otimizadas

## 📱 Compatibilidade

- Android: SDK 21+ (Android 5.0+)
- iOS: 11.0+
- Web: Chrome, Firefox, Safari, Edge

## 🎯 Roadmap

Veja os issues abertos para funcionalidades planejadas. Prioridades:

1. Estabilidade e performance
2. Novas funcionalidades solicitadas
3. Melhorias de UX/UI
4. Suporte a novas plataformas

## 💬 Comunicação

- Use issues para discussões técnicas
- Mantenha discussões relacionadas no mesmo issue
- Seja claro e objetivo nas mensagens

## 🙏 Agradecimentos

Sua contribuição é muito valiosa! Mesmo pequenas melhorias ajudam a tornar o TrainEasy melhor para todos.

---

**Dúvidas?** Abra um issue ou entre em contato com os mantenedores do projeto.