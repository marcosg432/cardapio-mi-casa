#!/bin/bash

# Script para corrigir o erro de TypeScript diretamente no servidor
# Execute: bash corrigir-typescript.sh

set -e

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Corrigindo erro de TypeScript em $FILE..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Aplicar correção - substituir a linha problemática
# Procurar e substituir todas as variações possíveis

# Padrão 1: com espaço após ?
sed -i "s/price: typeof formData\.price === 'string'? Number(formData\.price\.replace(',', '.')) : (formData\.price || 0),/price: typeof formData.price === 'string' ? Number(formData.price.replace(',', '.')) : (typeof formData.price === 'number' ? formData.price : 0),/g" "$FILE"

# Padrão 2: sem espaço após ?
sed -i "s/price: typeof formData\.price === 'string'?Number(formData\.price\.replace(',', '.')) : (formData\.price || 0),/price: typeof formData.price === 'string' ? Number(formData.price.replace(',', '.')) : (typeof formData.price === 'number' ? formData.price : 0),/g" "$FILE"

# Padrão 3: com espaço em formData. price
sed -i "s/formData\. price/formData.price/g" "$FILE"

# Corrigir display_order também
sed -i "s/display_order: typeof formData\.display_order === 'string'? Number(formData\.display_order) : (formData\.display_order || 0),/display_order: typeof formData.display_order === 'string' ? Number(formData.display_order) : (typeof formData.display_order === 'number' ? formData.display_order : 0),/g" "$FILE"

sed -i "s/display_order: typeof formData\.display_order === 'string'?Number (formData\.display_order): (formData\.display_order || 0),/display_order: typeof formData.display_order === 'string' ? Number(formData.display_order) : (typeof formData.display_order === 'number' ? formData.display_order : 0),/g" "$FILE"

# Verificar se a correção foi aplicada
if grep -q "typeof formData.price === 'number' ? formData.price : 0" "$FILE"; then
    echo "✅ Correção aplicada com sucesso!"
    echo ""
    echo "📋 Linha corrigida:"
    grep -n "price: typeof formData.price" "$FILE" | head -1
else
    echo "⚠️  Verificando se precisa de correção manual..."
    echo "📋 Linha atual:"
    grep -n "price: typeof formData.price" "$FILE" | head -1
fi

echo ""
echo "✅ Processo concluído!"

