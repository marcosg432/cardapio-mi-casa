#!/bin/bash

# Script para restaurar processos PM2 do dump
# Execute: bash restaurar-pm2.sh

echo "🔄 Restaurando processos PM2 do dump..."

pm2 resurrect

echo ""
echo "✅ Processos restaurados!"
echo ""
echo "📊 Status:"
pm2 status

echo ""
echo "💾 Salvando configuração..."
pm2 save

