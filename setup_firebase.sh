#!/bin/bash

# Script de configuração inicial do Firebase para TrainEasy
# Este script ajuda a configurar os arquivos necessários do Firebase

echo "🚀 Configurador Firebase - TrainEasy"
echo "=================================="
echo ""

# Verifica se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Por favor, instale o Flutter primeiro."
    exit 1
fi

echo "✅ Flutter encontrado"

# Cria estrutura de diretórios necessários
echo "📁 Criando estrutura de diretórios..."
mkdir -p android/app
mkdir -p ios/Runner
mkdir -p lib

# Verifica se os arquivos de exemplo existem
if [ -f "android/app/google-services.json.example" ]; then
    echo "📄 Template Android encontrado: google-services.json.example"
else
    echo "❌ Template Android não encontrado"
fi

if [ -f "lib/firebase_options.dart.example" ]; then
    echo "📄 Template Firebase Options encontrado: firebase_options.dart.example"
else
    echo "❌ Template Firebase Options não encontrado"
fi

if [ -f ".env.example" ]; then
    echo "📄 Template de variáveis de ambiente encontrado: .env.example"
else
    echo "❌ Template de variáveis de ambiente não encontrado"
fi

if [ -f "firebase.json.example" ]; then
    echo "📄 Template Firebase JSON encontrado: firebase.json.example"
else
    echo "❌ Template Firebase JSON não encontrado"
fi

echo ""
echo "📝 Próximos passos:"
echo "1. Copie o arquivo de variáveis de ambiente:"
echo "   cp .env.example .env"
echo "2. Edite o arquivo .env com suas credenciais do Firebase"
echo "3. Copie o firebase.json.example (já está limpo com placeholders)"
echo "4. Acesse o Firebase Console: https://console.firebase.google.com/"
echo "5. Crie um novo projeto"
echo "6. Adicione aplicativo Android com pacote: br.com.pablocustodio"
echo "7. Adicione aplicativo iOS com bundle ID: br.com.pablocustodio"
echo "8. Baixe o google-services.json e coloque em: android/app/"
echo "9. Baixe o GoogleService-Info.plist e coloque em: ios/Runner/"
echo "10. Execute: flutterfire configure"
echo "11. Rode o gerador de .env a partir dos arquivos nativos:"
echo "    scripts/extract_firebase_env.sh"
echo "    Isso criará .env.generated; se estiver correto, faça: cp .env.generated .env"
echo "12. Ou copie firebase_options.dart.example para firebase_options.dart e preencha manualmente"
echo ""
echo "🔐 Lembre-se: Nunca commite credenciais reais!"
echo ""
echo "📚 Links úteis:"
echo "- Firebase Console: https://console.firebase.google.com/"
echo "- FlutterFire CLI: https://firebase.flutter.dev/docs/cli/"
echo "- Documentação Firebase: https://firebase.google.com/docs"
echo ""
echo "✨ Após configurar, execute: flutter run"