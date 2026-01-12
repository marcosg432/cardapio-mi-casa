#!/bin/bash

# Script para forçar atualização e garantir que os arquivos corretos sejam usados
# Execute: bash forcar-atualizacao-correta.sh

set -e

echo "🔄 Forçando atualização completa do repositório..."

cd /root/cardapio || exit 1

# Limpar tudo e baixar novamente
echo "🧹 Limpando repositório local..."
rm -rf .git
git init
git remote add origin https://github.com/marcosg432/cardapio-mi-casa.git
git fetch origin
git checkout -b main
git reset --hard origin/main

echo "✅ Repositório atualizado!"
echo ""
echo "🔨 Fazendo build..."
npm install
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo ""
    echo "🔄 Reiniciando aplicação..."
    pm2 stop cardapio-3007 || true
    pm2 delete cardapio-3007 || true
    pm2 start ecosystem.config.js
    pm2 save
    echo ""
    echo "✅ Processo concluído!"
else
    echo ""
    echo "❌ Build falhou. Verificando arquivos..."
    echo ""
    echo "📄 Verificando linha 157 de pages/admin/beverages/[id].tsx:"
    sed -n '155,160p' "pages/admin/beverages/[id].tsx" 2>/dev/null || echo "Arquivo não encontrado"
    exit 1
fi

