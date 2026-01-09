#!/bin/bash

# Script para adicionar type assertion explícita
# Execute: bash corrigir-type-assertion.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Adicionando type assertion explícita..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Adicionar type assertion usando sed
sed -i "s/formData\.price\.replace(',', '.')/(formData.price as string).replace(',', '.')/g" "$FILE"
sed -i "s/Number(formData\.display_order)/Number(formData.display_order as string)/g" "$FILE"

# Verificar
echo ""
echo "📋 Verificando correção:"
grep -A3 "const priceValue" "$FILE" | head -4

if grep -q "as string" "$FILE"; then
    echo ""
    echo "✅ Type assertion adicionada com sucesso!"
else
    echo ""
    echo "⚠️  Type assertion pode não ter sido aplicada. Verifique manualmente."
fi

echo ""
echo "✅ Processo concluído!"

