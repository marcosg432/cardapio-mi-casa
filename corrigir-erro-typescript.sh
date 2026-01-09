#!/bin/bash

# Script para corrigir automaticamente o erro de TypeScript
# Erro: Property 'replace' does not exist on type 'never' em beverages/[id].tsx:59

set -e

FILE_PATH="pages/admin/beverages/[id].tsx"

echo "🔧 Corrigindo erro de TypeScript..."

if [ ! -f "$FILE_PATH" ]; then
    echo "❌ Arquivo não encontrado: $FILE_PATH"
    exit 1
fi

# Fazer backup
cp "$FILE_PATH" "${FILE_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Tentar corrigir a linha 59
# Procurar pela linha problemática e substituir
sed -i "s/price: typeof formData\.price === 'string' ? Number(formData\.price\.replace(',', '.')) : (formData\.price || 0),/price: typeof formData.price === 'string' ? Number(formData.price.replace(',', '.')) : (typeof formData.price === 'number' ? formData.price : 0),/g" "$FILE_PATH"

# Corrigir display_order também
sed -i "s/display_order: typeof formData\.display_order === 'string' ? Number(formData\.display_order) : (formData\.display_order || 0),/display_order: typeof formData.display_order === 'string' ? Number(formData.display_order) : (typeof formData.display_order === 'number' ? formData.display_order : 0),/g" "$FILE_PATH"

echo "✅ Correção aplicada"

