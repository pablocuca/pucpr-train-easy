#!/bin/bash

# Script de inicialização do repositório Git para TrainEasy
# Este script configura o repositório de forma segura

echo "🚀 Inicializando Repositório TrainEasy"
echo "======================================"
echo ""

# Verifica se está em um repositório git
if [ -d ".git" ]; then
    echo "⚠️  Repositório Git já existe!"
    read -p "Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
else
    echo "📁 Inicializando novo repositório Git..."
    git init
fi

# Configura usuário (opcional)
echo ""
echo "👤 Configuração de Usuário Git (opcional)"
read -p "Seu nome: " git_name
read -p "Seu email: " git_email

if [ ! -z "$git_name" ]; then
    git config user.name "$git_name"
fi

if [ ! -z "$git_email" ]; then
    git config user.email "$git_email"
fi

# Verifica se os arquivos sensíveis existem
echo ""
echo "🔍 Verificando arquivos sensíveis..."

sensitive_files=(
    "android/app/google-services.json"
    "ios/Runner/GoogleService-Info.plist"
    "lib/firebase_options.dart"
    ".env"
)

for file in "${sensitive_files[@]}"; do
    if [ -f "$file" ]; then
        echo "⚠️  Arquivo sensível encontrado: $file"
        echo "   Este arquivo será ignorado pelo .gitignore"
    fi
done

# Verifica se os templates existem
echo ""
echo "📋 Verificando templates de configuração..."

template_files=(
    "android/app/google-services.json.example"
    "lib/firebase_options.dart.example"
    ".env.example"
)

for file in "${template_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Template encontrado: $file"
    else
        echo "❌ Template não encontrado: $file"
    fi
done

# Adiciona arquivos ao stage
echo ""
echo "📦 Preparando arquivos para commit..."
git add .gitignore
git add *.md
git add *.sh
git add *.example
git add LICENSE
git add lib/
git add pubspec.*
git add analysis_options.yaml
git add train_easy_design_system/

# Remove arquivos sensíveis se foram adicionados por engano
git reset HEAD android/app/google-services.json 2>/dev/null || true
git reset HEAD ios/Runner/GoogleService-Info.plist 2>/dev/null || true
git reset HEAD lib/firebase_options.dart 2>/dev/null || true
git reset HEAD .env 2>/dev/null || true

# Primeiro commit
echo ""
echo "💾 Realizando primeiro commit..."
git commit -m "🎉 Initial commit: TrainEasy Flutter project

- Clean Architecture implementation
- Firebase integration setup
- Design system package
- Security configuration (credentials excluded)
- Documentation and setup scripts"

# Adiciona repositório remoto (opcional)
echo ""
echo "🔗 Configuração de Repositório Remoto"
echo "Para adicionar seu repositório do GitHub:"
echo "git remote add origin https://github.com/SEU_USUARIO/traineasy.git"
echo "git branch -M main"
echo "git push -u origin main"
echo ""

# Status final
echo "📊 Status do Repositório:"
git status

echo ""
echo "✅ Repositório configurado com sucesso!"
echo ""
echo "🎯 Próximos passos:"
echo "1. Configure o Firebase (execute: ./setup_firebase.sh)"
echo "2. Adicione seu repositório remoto do GitHub"
echo "3. Configure suas credenciais seguindo o README.md"
echo "4. Desenvolva com segurança!"
echo ""
echo "🔒 Lembre-se: Nunca commite credenciais reais!"