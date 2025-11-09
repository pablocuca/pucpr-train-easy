#!/bin/bash

# Script para limpar credenciais sensíveis do firebase.json
# Mantém apenas as configurações estruturais necessárias

echo "🧹 Limpando credenciais sensíveis do firebase.json..."

# Verifica se o firebase.json existe
if [ ! -f "firebase.json" ]; then
    echo "❌ Arquivo firebase.json não encontrado!"
    exit 1
fi

# Faz backup do arquivo original
cp firebase.json firebase.json.backup

# Cria novo firebase.json limpo
cat > firebase.json << 'EOF'
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "YOUR_PROJECT_ID",
          "appId": "YOUR_ANDROID_APP_ID",
          "fileOutput": "android/app/google-services.json"
        }
      },
      "dart": {
        "lib/firebase_options.dart": {
          "projectId": "YOUR_PROJECT_ID",
          "configurations": {
            "android": "YOUR_ANDROID_APP_ID",
            "ios": "YOUR_IOS_APP_ID",
            "web": "YOUR_WEB_APP_ID"
          }
        }
      }
    }
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
EOF

echo "✅ firebase.json limpo com sucesso!"
echo "📋 Backup criado: firebase.json.backup"
echo ""
echo "⚠️  Importante:"
echo "   - As credenciais reais agora devem ser gerenciadas apenas via .env"
echo "   - Use 'flutterfire configure' para regenerar as configurações quando necessário"
echo "   - O arquivo firebase.json.example já contém o template correto"

# Remove o backup após confirmação
echo ""
read -p "Deseja remover o backup (firebase.json.backup)? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    rm firebase.json.backup
    echo "✅ Backup removido"
else
    echo "💾 Backup mantido: firebase.json.backup"
fi