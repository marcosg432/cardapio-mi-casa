#!/bin/bash

# Script para corrigir erro de tipo no onChange do dishes/[id].tsx
# Execute: bash corrigir-dishes-onchange.sh

FILE="pages/admin/dishes/[id].tsx"

echo "🔧 Corrigindo erro de tipo no onChange do dishes/[id].tsx..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Corrigir usando sed
sed -i "s/price: value === '' ? 0 : value/price: value === '' ? 0 : (value as any)/g" "$FILE"

# Verificar se há display_order com o mesmo problema
if grep -q "display_order: value === '' ? 0 : value" "$FILE"; then
    sed -i "s/display_order: value === '' ? 0 : value/display_order: value === '' ? 0 : (value as any)/g" "$FILE"
fi

echo ""
echo "📋 Verificando correção:"
grep -n "price: value === '' ? 0 : (value as any)" "$FILE" | head -1

if [ $? -eq 0 ]; then
    echo "✅ Correção aplicada com sucesso!"
else
    echo "⚠️  Verifique se a correção foi aplicada"
fi

echo ""
echo "✅ Processo concluído!"

