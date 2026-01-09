#!/bin/bash

# Script para corrigir erro de tipo no new.tsx
# Execute: bash corrigir-new-tsx.sh

FILE="pages/admin/beverages/new.tsx"

echo "🔧 Corrigindo erro de tipo no new.tsx..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Corrigir usando sed - adicionar type assertion
sed -i "s/formData\.price\.toFixed(2)/(formData.price as number).toFixed(2)/g" "$FILE"

echo ""
echo "📋 Verificando correção:"
grep -n "formData.price as number" "$FILE" | head -1

if [ $? -eq 0 ]; then
    echo "✅ Correção aplicada com sucesso!"
else
    echo "⚠️  Verifique se a correção foi aplicada"
fi

echo ""
echo "✅ Processo concluído!"

