# Política de Segurança - TrainEasy

## 🔒 Informações Importantes sobre Segurança

Este documento descreve as práticas de segurança adotadas no projeto TrainEasy e orientações para contribuidores.

## 🔐 Segurança de Credenciais

Este projeto usa uma abordagem de **segurança em camadas** para proteger credenciais sensíveis:

### 🌟 Abordagem de Variáveis de Ambiente

O projeto agora utiliza **exclusivamente variáveis de ambiente** para gerenciar credenciais:

- **`.env`** - Arquivo principal com todas as credenciais do Firebase
- **`EnvironmentConfig`** - Classe Dart que carrega e fornece acesso às variáveis
- **`firebase_options.dart`** - Usa variáveis de ambiente ao invés de valores hardcoded
- **`firebase.json`** - Agora contém apenas placeholders (YOUR_PROJECT_ID, etc.)

Esta abordagem garante que:
- ✅ Credenciais nunca sejam commitadas acidentalmente
- ✅ Configurações possam ser alteradas sem modificar código
- ✅ Diferentes ambientes (dev, staging, prod) usem variáveis diferentes
- ✅ O projeto seja totalmente funcional com o arquivo `.env` correto

### ⚠️ Arquivos que NUNCA devem ser commitados:

- ✅ `android/app/google-services.json` - Configurações do Firebase Android
- ✅ `ios/Runner/GoogleService-Info.plist` - Configurações do Firebase iOS  
- ✅ `lib/firebase_options.dart` - Opções de configuração do Firebase
- ✅ `.env` - Variáveis de ambiente
- ✅ `firebase.json` - Configurações do Firebase (agora usa placeholders)
- ✅ `firestore.rules` - Regras do Firestore
- ✅ `firestore.indexes.json` - Índices do Firestore
- ✅ `*.keystore` - Arquivos de assinatura Android
- ✅ `key.properties` - Propriedades de chaves
- ✅ `local.properties` - Configurações locais
- ✅ `*.jks` - Java Keystore files

### Templates Seguros Disponíveis:

- 📋 `android/app/google-services.json.example`
- 📋 `lib/firebase_options.dart.example`
- 📋 `.env.example`
- 📋 `firebase.json.example`

## 🛡️ Configuração de Segurança

### Firebase Security Rules

Exemplo de regras seguras para Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workouts are user-specific
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Autenticação Firebase

Configure apenas métodos de autenticação necessários:
- ✅ Email/Senha (recomendado para MVP)
- ⚠️ Google Sign-In (adicional, se necessário)
- ❌ Anônimo (não recomendado para dados de usuário)

## 🔍 Verificações de Segurança

### Antes de Commitar

Execute este checklist:

- [ ] Verifique se não há chaves de API hardcoded
- [ ] Confirme que arquivos sensíveis estão no .gitignore
- [ ] Teste se o app funciona sem as credenciais (modo desenvolvimento)
- [ ] Revise se não há logs com informações sensíveis
- [ ] Confirme que está usando HTTPS para todas as chamadas

### Comandos Úteis

Verificar arquivos staged antes de commitar:
```bash
git status
git diff --cached
```

Buscar por padrões sensíveis:
```bash
grep -r "api_key\|API_KEY\|secret\|password" lib/ --exclude-dir=build
```

## 🚨 O que fazer se expor acidentalmente uma credencial?

1. **NÃO** apenas delete o arquivo e faça commit
2. **Revogue imediatamente** a credencial no Firebase Console
3. **Gere novas credenciais** seguindo o processo correto
4. **Remova o histórico** do Git se necessário:
   ```bash
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch path/do/arquivo/sensivel' \
   --prune-empty --tag-name-filter cat -- --all
   ```
5. **Force push** para o repositório remoto
6. **Notifique** outros contribuidores sobre a mudança

## 📋 Configuração de Desenvolvimento Seguro

### Ambiente Local

1. Use o script `./setup_firebase.sh` para configuração inicial
2. Mantenha credenciais em arquivos locais não rastreados
3. Use variáveis de ambiente quando possível
4. Documente suas configurações locais

### Compartilhamento de Credenciais (Time)

- Use serviços seguros de compartilhamento (ex: 1Password, Bitwarden)
- Nunca compartilhe por email ou mensagens
- Mantenha um registro de quem tem acesso
- Revogue acesso quando membros saírem do projeto

## 🧪 Testes de Segurança

### Testes Recomendados

- Teste de autenticação não autorizada
- Validação de permissões Firestore
- Verificação de expiração de tokens
- Teste de injeção de SQL (se aplicável)
- Validação de entrada de usuário

### Ferramentas Úteis

- [Firebase Security Rules Simulator](https://console.firebase.google.com/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Guidelines](https://flutter.dev/docs/security)

## 📞 Reportando Vulnerabilidades

Se você encontrar uma vulnerabilidade de segurança:

1. **NÃO** abra um issue público
2. Envie email para: [seu-email-de-seguranca@example.com]
3. Inclua detalhes técnicos e impacto potencial
4. Aguarde resposta antes de divulgar publicamente

## 📚 Recursos Adicionais

- [Firebase Security Documentation](https://firebase.google.com/docs/rules)
- [Flutter Security Best Practices](https://flutter.dev/docs/security)
- [OWASP Top 10 Mobile](https://owasp.org/www-project-mobile-top-10/)
- [Google Cloud Security Best Practices](https://cloud.google.com/security/best-practices)

## ⚖️ Isenção de Responsabilidade

Este é um projeto educacional. O uso em produção requer:

- Auditoria de segurança profissional
- Testes de penetração
- Conformidade com regulamentações locais (LGPD, GDPR, etc.)
- Monitoramento de segurança contínuo
- Plano de resposta a incidentes

---

**Lembre-se: Segurança é responsabilidade de todos!** 🛡️