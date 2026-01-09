#!/bin/bash

# Script para corrigir TODOS os erros de TypeScript de uma vez
# Execute: bash corrigir-todos-erros.sh

echo "🔍 Fazendo varredura completa e corrigindo todos os erros..."

# Lista de arquivos para verificar
FILES=(
    "pages/admin/beverages/[id].tsx"
    "pages/admin/beverages/new.tsx"
    "pages/admin/dishes/[id].tsx"
    "pages/admin/dishes/new.tsx"
)

for FILE in "${FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo "⚠️  Arquivo não encontrado: $FILE"
        continue
    fi
    
    echo ""
    echo "📝 Processando: $FILE"
    
    # Fazer backup
    cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Corrigir todos os problemas usando Python
    python3 << PYTHON_SCRIPT
import re
import sys

file_path = "$FILE"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # 1. Corrigir formData.price.toFixed sem type assertion
    content = re.sub(
        r'formData\.price\.toFixed\(',
        '(formData.price as number).toFixed(',
        content
    )
    
    # 2. Corrigir formData.display_order.toFixed se existir
    content = re.sub(
        r'formData\.display_order\.toFixed\(',
        '(formData.display_order as number).toFixed(',
        content
    )
    
    # 3. Corrigir price: value === '' ? 0 : value (sem type assertion)
    content = re.sub(
        r'price:\s*value\s*===\s*[''"]\s*\?\s*0\s*:\s*value(?!\s*as\s*any)',
        'price: value === \'\' ? 0 : (value as any)',
        content
    )
    
    # 4. Corrigir display_order: value === '' ? 0 : value (sem type assertion)
    content = re.sub(
        r'display_order:\s*value\s*===\s*[''"]\s*\?\s*0\s*:\s*value(?!\s*as\s*any)',
        'display_order: value === \'\' ? 0 : (value as any)',
        content
    )
    
    # 5. Corrigir uso direto de formData.price.replace no body (se ainda existir)
    # Procurar por padrão: price: typeof formData.price === 'string' ? Number(formData.price.replace...
    if 'price: typeof formData.price ===' in content and 'priceValue' not in content:
        # Adicionar variáveis antes do fetch se não existirem
        if 'const priceValue' not in content:
            # Encontrar o try dentro de handleSubmit e adicionar variáveis
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
        
        # Substituir uso direto por variáveis
        content = re.sub(
            r"price:\s*typeof\s+formData\.price\s*===\s*['\"]string['\"]\s*\?\s*Number\s*\(\s*formData\.price\.replace[^,]*,\s*\(\s*formData\.price\s*\|\|\s*0\s*\)",
            'price: priceValue',
            content
        )
        content = re.sub(
            r"display_order:\s*typeof\s+formData\.display_order\s*===\s*['\"]string['\"]\s*\?\s*Number[^,]*,\s*\(\s*formData\.display_order\s*\|\|\s*0\s*\)",
            'display_order: displayOrderValue',
            content
        )
    
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ Correções aplicadas em {file_path}")
    else:
        print(f"  ✓ Nenhuma correção necessária em {file_path}")
    
except Exception as e:
    print(f"  ❌ Erro ao processar {file_path}: {e}")
    sys.exit(1)
PYTHON_SCRIPT
    
    if [ $? -ne 0 ]; then
        echo "  ❌ Erro ao processar $FILE"
    fi
done

echo ""
echo "✅ Varredura completa concluída!"
echo ""
echo "📋 Resumo das correções:"
echo "  - formData.price.toFixed -> (formData.price as number).toFixed"
echo "  - price: value === '' ? 0 : value -> price: value === '' ? 0 : (value as any)"
echo "  - Uso direto no body -> Variáveis intermediárias com type assertion"
echo ""
echo "🚀 Agora teste o build:"
echo "   npm run build"

