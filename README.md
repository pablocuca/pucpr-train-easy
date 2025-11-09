# TrainEasy 🏋️‍♂️

Um aplicativo Flutter para gerenciamento de treinos pessoais, permitindo que usuários acompanhem seus exercícios, monitorem progresso e mantenham uma rotina fitness organizada.

## 📱 Funcionalidades

- ✅ **Autenticação de Usuários** - Login e registro com Firebase Auth
- 📊 **Dashboard de Treinos** - Visualize seu progresso
- 📝 **Gerenciamento de Exercícios** - Adicione e acompanhe exercícios
- 🎨 **Design System** - Interface moderna e responsiva
- 🔒 **Segurança** - Proteção de dados com Firebase Security Rules

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** com separação clara de camadas:

```
lib/
├── core/           # Classes base e utilitários
├── features/       # Funcionalidades (auth, workouts, etc.)
└── presentation/   # UI e controllers
```

### Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Firebase** - Backend como serviço
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Dart** - Linguagem de programação
- **Widgetbook** - Documentação de componentes UI

## 🚀 Começando

### Pré-requisitos

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase CLI (opcional, mas recomendado)

### Instalação

1. **Clone o repositório**

```bash
git clone https://github.com/[seu-usuario]/traineasy.git
cd traineasy
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Configure o Firebase** (veja seção abaixo)

4. **Execute o aplicativo**

```bash
flutter run
```

## 🔥 Configuração do Firebase

### ⚠️ IMPORTANTE: Segurança

Este projeto **NÃO** inclui as credenciais do Firebase por questões de segurança. Você precisa configurar seu próprio projeto Firebase.

### Passo a Passo para Configurar o Firebase

#### 1. Crie um Projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Dê um nome (ex: "meu-traineasy")
4. Ative o Google Analytics (opcional)
5. Clique em "Criar projeto"

#### 2. Adicione seu Aplicativo

**Para Android:**

1. No Firebase Console, clique em "Adicionar aplicativo" → Android
2. Registre o pacote: `br.com.pablocustodio` (ou altere no seu projeto)
3. Baixe o `google-services.json`
4. Coloque em: `android/app/google-services.json`

**Para iOS:**

1. No Firebase Console, clique em "Adicionar aplicativo" → iOS
2. Registre o bundle ID: `br.com.pablocustodio`
3. Baixe o `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

#### 3. Ative os Serviços Necessários

**Autenticação:**

1. Vá para "Authentication" → "Método de login"
2. Ative "Email/Senha"
3. Configure as regras de segurança

**Firestore Database:**

1. Vá para "Firestore Database"
2. Crie um banco de dados (modo de teste inicialmente)
3. Configure as regras de segurança:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == resource.data.userId;
    }
  }
}
```

#### 4. Configure as Variáveis de Ambiente

Copie o arquivo de exemplo e configure suas credenciais:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do Firebase:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=seu_project_id_aqui
FIREBASE_ANDROID_APP_ID=seu_android_app_id_aqui
FIREBASE_IOS_APP_ID=seu_ios_app_id_aqui
FIREBASE_WEB_APP_ID=seu_web_app_id_aqui
FIREBASE_API_KEY=sua_api_key_aqui
FIREBASE_AUTH_DOMAIN=sua_auth_domain_aqui
FIREBASE_DATABASE_URL=sua_database_url_aqui
FIREBASE_STORAGE_BUCKET=sua_storage_bucket_aqui
FIREBASE_MESSAGING_SENDER_ID=seu_messaging_sender_id_aqui

# Platform Configuration
ANDROID_PACKAGE_NAME=com.seu.dominio.traineasy
IOS_BUNDLE_ID=com.seu.dominio.traineasy
```

#### 5. Configure as Opções do Firebase

Execute o comando FlutterFire CLI:

```bash
flutterfire configure
```

Ou crie manualmente o arquivo `lib/firebase_options.dart` com suas credenciais:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY_AQUI',
    appId: 'SEU_APP_ID_AQUI',
    messagingSenderId: 'SEU_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    databaseURL: 'SUA_DATABASE_URL',
    storageBucket: 'SEU_STORAGE_BUCKET',
  );

  // Configure também para web e iOS se necessário
}
```

### 🔐 Regras de Segurança Importantes

- **Nunca** commite credenciais reais
- Use variáveis de ambiente para dados sensíveis
- Configure regras de segurança no Firebase
- Ative a autenticação antes de liberar para produção

## 🧪 Testes

Execute os testes unitários:

```bash
flutter test
```

Execute testes de widget:

```bash
flutter test test/widget/
```

## 📦 Build e Deploy

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🎨 Design System

O projeto inclui um pacote separado de design system em `train_easy_design_system/`:

```bash
cd train_easy_design_system
flutter pub get
flutter run -d chrome
```

Acesse o Widgetbook para ver todos os componentes em: `http://localhost:8080`

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👥 Autor

**[Pablo Custódio]** - [LinkedIn](https://linkedin.com/in/pablocustodio) - [GitHub](https://github.com/pablocuca)

## 🙏 Agradecimentos

- Equipe Flutter pela excelente documentação
- Firebase pela plataforma robusta
- Comunidade open source pelos recursos compartilhados

---

## ⚠️ Disclaimer

Este é um projeto educacional. Para uso em produção:

- Configure corretamente as regras de segurança do Firebase
- Implemente monitoramento e analytics
- Realize testes de segurança
- Configure CI/CD adequado
- Revise e teste todas as funcionalidades

---

**⭐ Se este projeto te ajudou, considere dar uma estrela no GitHub!**
