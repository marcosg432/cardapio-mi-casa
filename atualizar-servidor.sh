#!/bin/bash

# Script para atualizar o servidor na Hostinger
# Execute: bash atualizar-servidor.sh

set -e  # Para o script se houver erro

echo "🚀 Iniciando atualização do servidor..."

# Ir para o diretório do projeto
cd /root/cardapio || exit 1

echo "📥 Atualizando código do GitHub..."
git fetch --all --prune
git reset --hard origin/main
git pull origin main

echo "📦 Instalando dependências..."
npm install

echo "🔨 Fazendo build do projeto..."
rm -rf .next
npm run build

echo "🔄 Reiniciando aplicação no PM2..."
pm2 stop cardapio-3007 || true
pm2 delete cardapio-3007 || true
pm2 start ecosystem.config.js
pm2 save

echo "✅ Atualização concluída!"
echo ""
echo "📊 Status do PM2:"
pm2 status

echo ""
echo "📝 Últimos logs (últimas 20 linhas):"
pm2 logs cardapio-3007 --lines 20 --nostream

echo ""
echo "🌐 Aplicação rodando em: http://193.160.119.67:3007"
