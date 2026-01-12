#!/bin/bash

# Script para corrigir problemas no servidor
# Execute: bash corrigir-servidor.sh

set -e

echo "🔧 Corrigindo problemas no servidor..."

cd /root/cardapio || exit 1

echo "🛑 Parando todos os processos do cardapio-3007..."
pm2 stop cardapio-3007 || true
pm2 delete cardapio-3007 || true

echo "🔍 Verificando processos na porta 3007..."
lsof -ti:3007 | xargs kill -9 2>/dev/null || echo "Nenhum processo encontrado na porta 3007"

echo "🧹 Limpando build anterior..."
rm -rf .next
rm -rf node_modules/.cache

echo "📦 Reinstalando dependências..."
npm install

echo "🔨 Fazendo novo build..."
npm run build

echo "✅ Verificando se o build foi criado..."
if [ -f ".next/BUILD_ID" ]; then
    echo "✅ Build criado com sucesso!"
else
    echo "❌ ERRO: Build não foi criado corretamente!"
    exit 1
fi

echo "🚀 Iniciando aplicação no PM2..."
pm2 start ecosystem.config.js
pm2 save

echo "⏳ Aguardando 3 segundos..."
sleep 3

echo "📊 Status do PM2:"
pm2 status

echo ""
echo "📝 Últimos logs (últimas 30 linhas):"
pm2 logs cardapio-3007 --lines 30 --nostream

echo ""
echo "✅ Processo concluído!"
