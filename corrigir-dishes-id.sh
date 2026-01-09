#!/bin/bash

# Script para corrigir erro de tipo no dishes/[id].tsx
# Execute: bash corrigir-dishes-id.sh

FILE="pages/admin/dishes/[id].tsx"

echo "🔧 Corrigindo erro de tipo no dishes/[id].tsx..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para aplicar a mesma correção que fizemos em beverages
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/dishes/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    i = 0
    in_handle_submit = False
    in_try_block = False
    variables_added = False
    
    while i < len(lines):
        line = lines[i]
        
        # Detectar handleSubmit
        if 'const handleSubmit' in line or ('handleSubmit' in line and 'async' in line):
            in_handle_submit = True
            new_lines.append(line)
            i += 1
            continue
        
        # Detectar try dentro de handleSubmit
        if in_handle_submit and 'try {' in line:
            in_try_block = True
            new_lines.append(line)
            i += 1
            # Adicionar variáveis imediatamente após o try
            if not variables_added:
                new_lines.append("      // Preparar valores com type assertion para evitar erro de TypeScript\n")
                new_lines.append("      const priceValue = typeof formData.price === 'string' \n")
                new_lines.append("        ? Number((formData.price as string).replace(',', '.')) \n")
                new_lines.append("        : (typeof formData.price === 'number' ? formData.price : 0);\n")
                new_lines.append("      \n")
                new_lines.append("      const displayOrderValue = typeof formData.display_order === 'string' \n")
                new_lines.append("        ? Number(formData.display_order as string) \n")
                new_lines.append("        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n")
                new_lines.append("\n")
                variables_added = True
            continue
        
        # Se encontrar const res = await fetch mas não tem as variáveis, adicionar antes
        if in_handle_submit and in_try_block and 'const res = await fetch' in line and not variables_added:
            new_lines.append("      // Preparar valores com type assertion para evitar erro de TypeScript\n")
            new_lines.append("      const priceValue = typeof formData.price === 'string' \n")
            new_lines.append("        ? Number((formData.price as string).replace(',', '.')) \n")
            new_lines.append("        : (typeof formData.price === 'number' ? formData.price : 0);\n")
            new_lines.append("      \n")
            new_lines.append("      const displayOrderValue = typeof formData.display_order === 'string' \n")
            new_lines.append("        ? Number(formData.display_order as string) \n")
            new_lines.append("        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n")
            new_lines.append("\n")
            variables_added = True
        
        # Substituir uso direto no body por variáveis
        if 'price: typeof formData.price ===' in line:
            # Substituir toda a linha por price: priceValue,
            new_lines.append("          price: priceValue,\n")
            i += 1
            continue
        
        if 'display_order: typeof formData.display_order ===' in line:
            # Substituir toda a linha por display_order: displayOrderValue,
            new_lines.append("          display_order: displayOrderValue,\n")
            i += 1
            continue
        
        # Detectar fim do try
        if '} catch' in line or '}catch' in line:
            in_try_block = False
            variables_added = False
        
        new_lines.append(line)
        i += 1
    
    # Escrever arquivo
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print("✅ Correção aplicada!")
    sys.exit(0)
    
except Exception as e:
    print(f"❌ Erro: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
PYTHON_SCRIPT

if [ $? -eq 0 ]; then
    echo ""
    echo "📋 Verificando correção:"
    echo ""
    echo "Variáveis definidas:"
    grep -A3 "const priceValue" "$FILE" | head -4
    echo ""
    echo "Variáveis usadas:"
    grep -A2 "price: priceValue" "$FILE" | head -3
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

echo ""
echo "✅ Processo concluído!"

