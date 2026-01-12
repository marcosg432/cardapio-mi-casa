#!/bin/bash

# Script para reativar TODOS os processos PM2 de uma vez
# Execute: bash reativar-todos.sh

echo "🔄 Restaurando TODOS os processos PM2..."

# Tentar restaurar do dump
pm2 resurrect

echo ""
echo "✅ Processos restaurados!"
echo ""
echo "📊 Status atual:"
pm2 status

echo ""
echo "💾 Salvando configuração..."
pm2 save

echo ""
echo "✅ Todos os processos foram reativados!"

