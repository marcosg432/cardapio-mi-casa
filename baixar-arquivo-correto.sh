#!/bin/bash

# Script para baixar o arquivo correto do GitHub
# Execute: bash baixar-arquivo-correto.sh

FILE="pages/admin/beverages/[id].tsx"

echo "📥 Baixando arquivo correto do GitHub..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Baixar o arquivo correto do GitHub (usando git checkout)
git fetch origin main
git checkout origin/main -- "pages/admin/beverages/[id].tsx" 2>/dev/null || {
    # Se git checkout falhar, tentar curl com URL codificada
    curl -s "https://raw.githubusercontent.com/marcosg432/cardapiomicasa/main/pages/admin/beverages/%5Bid%5D.tsx" -o "$FILE" || {
        echo "⚠️  Não foi possível baixar do GitHub. Removendo duplicatas manualmente..."
        # Remover todas as declarações e adicionar apenas uma
        python3 << 'PYTHON_FIX'
import re
file_path = "pages/admin/beverages/[id].tsx"
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remover todas as declarações de priceValue e displayOrderValue
content = re.sub(r'const priceValue[^;]*;', '', content, flags=re.DOTALL)
content = re.sub(r'const displayOrderValue[^;]*;', '', content, flags=re.DOTALL)

# Encontrar o try dentro de handleSubmit e adicionar as variáveis
try_pattern = r'(const handleSubmit[^}]*?try\s*\{)'
replacement = r'''\1
      // Preparar valores com type assertion para evitar erro de TypeScript
      const priceValue = typeof formData.price === 'string' 
        ? Number((formData.price as string).replace(',', '.')) 
        : (typeof formData.price === 'number' ? formData.price : 0);
      
      const displayOrderValue = typeof formData.display_order === 'string' 
        ? Number(formData.display_order as string) 
        : (typeof formData.display_order === 'number' ? formData.display_order : 0);

'''
content = re.sub(try_pattern, replacement, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("✅ Duplicatas removidas e variáveis adicionadas")
PYTHON_FIX
    }
}

if [ $? -eq 0 ]; then
    echo "✅ Arquivo baixado do GitHub com sucesso!"
    
    # Verificar contagem
    echo ""
    echo "📋 Verificando contagem de variáveis:"
    PRICE_COUNT=$(grep -c "const priceValue" "$FILE")
    DISPLAY_COUNT=$(grep -c "const displayOrderValue" "$FILE")
    echo "  priceValue: $PRICE_COUNT"
    echo "  displayOrderValue: $DISPLAY_COUNT"
    
    if [ "$PRICE_COUNT" -eq 1 ] && [ "$DISPLAY_COUNT" -eq 1 ]; then
        echo ""
        echo "✅ Perfeito! Apenas uma declaração de cada variável."
    else
        echo ""
        echo "⚠️  Ainda há duplicatas. Tentando remover manualmente..."
        
        # Usar sed para remover todas as declarações e adicionar apenas uma
        # Encontrar a linha do try dentro de handleSubmit
        TRY_LINE=$(grep -n "const handleSubmit" "$FILE" | head -1 | cut -d: -f1)
        if [ -n "$TRY_LINE" ]; then
            # Encontrar o try após handleSubmit
            TRY_LINE=$(sed -n "${TRY_LINE},\$p" "$FILE" | grep -n "try {" | head -1 | cut -d: -f1)
            TRY_LINE=$((TRY_LINE + $(grep -n "const handleSubmit" "$FILE" | head -1 | cut -d: -f1) - 1))
            
            if [ -n "$TRY_LINE" ]; then
                echo "📝 Encontrado try na linha $TRY_LINE"
                # Remover todas as declarações existentes primeiro
                sed -i '/const priceValue/d' "$FILE"
                sed -i '/const displayOrderValue/d' "$FILE"
                # Adicionar após o try
                sed -i "${TRY_LINE}a\      // Preparar valores com type assertion para evitar erro de TypeScript\n      const priceValue = typeof formData.price === 'string' \n        ? Number((formData.price as string).replace(',', '.')) \n        : (typeof formData.price === 'number' ? formData.price : 0);\n      \n      const displayOrderValue = typeof formData.display_order === 'string' \n        ? Number(formData.display_order as string) \n        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n" "$FILE"
                echo "✅ Duplicatas removidas e variáveis adicionadas corretamente"
            fi
        fi
    fi
else
    echo "❌ Erro ao baixar arquivo do GitHub"
    exit 1
fi

echo ""
echo "✅ Processo concluído!"

