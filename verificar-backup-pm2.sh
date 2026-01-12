#!/bin/bash

# Script para verificar se há backup do PM2
# Execute: bash verificar-backup-pm2.sh

echo "🔍 Verificando backups do PM2..."

# Verificar dump atual
if [ -f "/root/.pm2/dump.pm2" ]; then
    echo "📄 Dump atual encontrado:"
    cat /root/.pm2/dump.pm2 | head -20
    echo ""
fi

# Verificar se há backups
if [ -f "/root/.pm2/dump.pm2.bak" ]; then
    echo "✅ Backup encontrado! (/root/.pm2/dump.pm2.bak)"
    echo ""
    echo "Para restaurar do backup, execute:"
    echo "cp /root/.pm2/dump.pm2.bak /root/.pm2/dump.pm2"
    echo "pm2 resurrect"
fi

# Verificar histórico do PM2
if [ -d "/root/.pm2/logs" ]; then
    echo ""
    echo "📋 Logs encontrados (podem indicar processos anteriores):"
    ls -la /root/.pm2/logs/ | head -10
fi

# Verificar processos atuais
echo ""
echo "📊 Processos PM2 atuais:"
pm2 list

echo ""
echo "💡 Se não houver backup, você precisará recriar os processos manualmente."
echo "   Me informe quais processos estavam rodando e em quais portas."

