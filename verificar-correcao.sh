#!/bin/bash

# Script para verificar se todas as correções foram aplicadas
# Execute: bash verificar-correcao.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔍 Verificando correções em $FILE..."
echo ""

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Verificar price
echo "📋 Verificando linha do price:"
PRICE_LINE=$(grep -n "price: typeof formData.price" "$FILE" | head -1)
echo "$PRICE_LINE"

if echo "$PRICE_LINE" | grep -q "typeof formData.price === 'number' ? formData.price : 0"; then
    echo "✅ Linha do price está CORRETA!"
else
    echo "❌ Linha do price ainda precisa de correção"
    echo "🔧 Aplicando correção..."
    sed -i "s/typeof formData\.price 'number'/typeof formData.price === 'number'/g" "$FILE"
    sed -i "s/(formData\.price || 0)/(typeof formData.price === 'number' ? formData.price : 0)/g" "$FILE"
    echo "✅ Correção aplicada"
fi

echo ""

# Verificar display_order
echo "📋 Verificando linha do display_order:"
DISPLAY_LINE=$(grep -n "display_order: typeof formData.display_order" "$FILE" | head -1)
echo "$DISPLAY_LINE"

if echo "$DISPLAY_LINE" | grep -q "typeof formData.display_order === 'number' ? formData.display_order : 0"; then
    echo "✅ Linha do display_order está CORRETA!"
else
    echo "❌ Linha do display_order ainda precisa de correção"
    echo "🔧 Aplicando correção..."
    sed -i "s/typeof formData\.display_order 'number'/typeof formData.display_order === 'number'/g" "$FILE"
    sed -i "s/(formData\.display_order || 0)/(typeof formData.display_order === 'number' ? formData.display_order : 0)/g" "$FILE"
    echo "✅ Correção aplicada"
fi

echo ""
echo "📋 Verificação final das duas linhas:"
grep -A1 "price: typeof formData.price" "$FILE" | head -2

echo ""
echo "✅ Verificação concluída!"
echo ""
echo "🚀 Agora você pode testar o build:"
echo "   npm run build"

