#!/bin/bash

# Script para verificar e restaurar processos PM2
# Execute: bash verificar-pm2.sh

echo "🔍 Verificando processos PM2..."

pm2 list

echo ""
echo "📋 Verificando dump do PM2..."
if [ -f "/root/.pm2/dump.pm2" ]; then
    echo "✅ Arquivo dump encontrado!"
    echo ""
    echo "Para restaurar todos os processos, execute:"
    echo "pm2 resurrect"
else
    echo "❌ Arquivo dump não encontrado"
fi

echo ""
echo "📊 Status atual:"
pm2 status

