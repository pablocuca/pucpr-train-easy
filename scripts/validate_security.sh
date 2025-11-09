#!/bin/bash

# Script de validação de segurança para TrainEasy
# Verifica se não há credenciais expostas no código

echo "🔍 Validador de Segurança - TrainEasy"
echo "====================================="
echo ""

# Contador de problemas
PROBLEMS=0

echo "📋 Verificando arquivos sensíveis..."
echo ""

# Verifica se arquivos sensíveis existem
if [ -f "android/app/google-services.json" ]; then
    echo "⚠️  Encontrado: android/app/google-services.json"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Encontrado: ios/Runner/GoogleService-Info.plist"
fi

if [ -f ".env" ]; then
    echo "⚠️  Encontrado: .env"
    if grep -q "^\.env$" .gitignore; then
        echo "✅ OK: .env está no .gitignore"
    else
        echo "❌ PROBLEMA: .env não está no .gitignore"
        PROBLEMS=$((PROBLEMS + 1))
    fi
fi

# .env.generated deve existir localmente, mas estar ignorado
if [ -f ".env.generated" ]; then
    echo "⚠️  Encontrado: .env.generated"
    if grep -q "^\.env.generated$" .gitignore; then
        echo "✅ OK: .env.generated está no .gitignore"
    else
        echo "❌ PROBLEMA: .env.generated não está no .gitignore"
        PROBLEMS=$((PROBLEMS + 1))
    fi
fi

if [ -f "lib/firebase_options.dart" ]; then
    echo "⚠️  Encontrado: lib/firebase_options.dart"
fi

if [ -f "firebase.json" ]; then
    echo "⚠️  Encontrado: firebase.json"
    if grep -q "YOUR_PROJECT_ID\|YOUR_ANDROID_APP_ID\|YOUR_IOS_APP_ID\|YOUR_WEB_APP_ID" firebase.json; then
        echo "✅ OK: firebase.json usa placeholders"
    else
        echo "❌ PROBLEMA: firebase.json pode conter credenciais reais"
        PROBLEMS=$((PROBLEMS + 1))
    fi
fi

echo ""
echo "📊 Resumo da Validação:"
echo "======================="

if [ $PROBLEMS -eq 0 ]; then
    echo "✅ SEGURANÇA VALIDADA!"
    echo "   Nenhum problema de segurança encontrado."
    echo "   Seu projeto está configurado corretamente com variáveis de ambiente."
else
    echo "❌ ${PROBLEMS} PROBLEMA(S) ENCONTRADO(S)"
    echo "   Por favor, revise e corrija os problemas acima."
fi

echo ""
echo "💡 Dicas de Segurança:"
echo "   - Sempre use .env para credenciais"
echo "   - Nunca commite arquivos com credenciais reais"
echo "   - Use flutterfire configure para gerar configurações"
echo "   - Verifique .gitignore regularmente"

exit $PROBLEMS