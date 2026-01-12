#!/bin/bash

# Script para corrigir TODOS os erros TypeScript no servidor
# Execute: bash corrigir-erros-servidor.sh

set -e

echo "🔧 Corrigindo TODOS os erros TypeScript no servidor..."

cd /root/cardapio || exit 1

echo "📥 Atualizando código do GitHub..."
git fetch --all --prune
git reset --hard origin/main
git pull origin main

echo "🔍 Verificando arquivos que precisam de correção..."

# Arquivo 1: pages/admin/beverages/[id].tsx
FILE1="pages/admin/beverages/[id].tsx"
if [ -f "$FILE1" ]; then
    echo "📝 Corrigindo $FILE1..."
    
    # Verificar se já tem as variáveis priceValue e displayOrderValue
    if ! grep -q "const priceValue = typeof formData.price === 'string'" "$FILE1"; then
        echo "  → Adicionando variáveis intermediárias..."
        
        # Usar sed para inserir as variáveis após o try {
        sed -i '/setSaving(true);/a\
    try {\
      // Preparar valores com type assertion para evitar erro de TypeScript\
      const priceValue = typeof formData.price === '\''string'\'' \
        ? Number((formData.price as string).replace('\'','\'', '\''.'\'')) \
        : (typeof formData.price === '\''number'\'' ? formData.price : 0);\
      \
      const displayOrderValue = typeof formData.display_order === '\''string'\'' \
        ? Number(formData.display_order as string) \
        : (typeof formData.display_order === '\''number'\'' ? formData.display_order : 0);
' "$FILE1"
    fi
    
    # Substituir formData.price e formData.display_order no JSON.stringify
    sed -i 's/price: formData\.price/price: priceValue/g' "$FILE1"
    sed -i 's/display_order: formData\.display_order/display_order: displayOrderValue/g' "$FILE1"
    
    # Corrigir qualquer replace sem type assertion
    sed -i 's/formData\.price\.replace(/\(formData.price as string\).replace(/g' "$FILE1"
    
    echo "  ✅ $FILE1 corrigido"
fi

# Arquivo 2: pages/admin/dishes/[id].tsx
FILE2="pages/admin/dishes/[id].tsx"
if [ -f "$FILE2" ]; then
    echo "📝 Corrigindo $FILE2..."
    
    if ! grep -q "const priceValue = typeof formData.price === 'string'" "$FILE2"; then
        echo "  → Adicionando variáveis intermediárias..."
        sed -i '/setSaving(true);/a\
    try {\
      // Preparar valores com type assertion para evitar erro de TypeScript\
      const priceValue = typeof formData.price === '\''string'\'' \
        ? Number((formData.price as string).replace('\'','\'', '\''.'\'')) \
        : (typeof formData.price === '\''number'\'' ? formData.price : 0);\
      \
      const displayOrderValue = typeof formData.display_order === '\''string'\'' \
        ? Number(formData.display_order as string) \
        : (typeof formData.display_order === '\''number'\'' ? formData.display_order : 0);
' "$FILE2"
    fi
    
    sed -i 's/price: formData\.price/price: priceValue/g' "$FILE2"
    sed -i 's/display_order: formData\.display_order/display_order: displayOrderValue/g' "$FILE2"
    sed -i 's/formData\.price\.replace(/\(formData.price as string\).replace(/g' "$FILE2"
    
    echo "  ✅ $FILE2 corrigido"
fi

# Arquivo 3: pages/admin/beverages/new.tsx
FILE3="pages/admin/beverages/new.tsx"
if [ -f "$FILE3" ]; then
    echo "📝 Corrigindo $FILE3..."
    
    # Garantir type assertion no toFixed
    sed -i 's/(formData\.price as number)\.toFixed(2)/(formData.price as number).toFixed(2)/g' "$FILE3" || true
    sed -i 's/formData\.price as number)\.toFixed(2)/(formData.price as number).toFixed(2)/g' "$FILE3" || true
    
    echo "  ✅ $FILE3 corrigido"
fi

# Arquivo 4: pages/admin/dishes/new.tsx
FILE4="pages/admin/dishes/new.tsx"
if [ -f "$FILE4" ]; then
    echo "📝 Corrigindo $FILE4..."
    
    # Garantir type assertion no toFixed
    sed -i 's/(formData\.price as number)\.toFixed(2)/(formData.price as number).toFixed(2)/g' "$FILE4" || true
    sed -i 's/formData\.price as number)\.toFixed(2)/(formData.price as number).toFixed(2)/g' "$FILE4" || true
    
    echo "  ✅ $FILE4 corrigido"
fi

echo ""
echo "✅ Todas as correções aplicadas!"
echo ""
echo "🔨 Fazendo build..."
npm run build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo ""
    echo "🔄 Reiniciando aplicação..."
    pm2 restart cardapio-3007 || pm2 start ecosystem.config.js
    pm2 save
else
    echo ""
    echo "❌ Build falhou. Verifique os erros acima."
    exit 1
fi

