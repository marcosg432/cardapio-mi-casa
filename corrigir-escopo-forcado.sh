#!/bin/bash

# Script para forçar correção do escopo das variáveis
# Execute: bash corrigir-escopo-forcado.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Forçando correção do escopo das variáveis..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para fazer a correção completa
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

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
        
        # Detectar início da função handleSubmit
        if 'const handleSubmit' in line or 'handleSubmit' in line and 'async' in line:
            in_handle_submit = True
            new_lines.append(line)
            i += 1
            # Pular até encontrar o try
            while i < len(lines) and 'try {' not in lines[i]:
                new_lines.append(lines[i])
                i += 1
            # Adicionar o try
            if i < len(lines):
                new_lines.append(lines[i])
                in_try_block = True
                i += 1
                # Adicionar as variáveis imediatamente após o try
                if 'const priceValue' not in ''.join(new_lines[-10:]):
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
        
        # Se encontrar const priceValue fora do try, remover
        if 'const priceValue' in line and not in_try_block:
            # Pular esta linha e as próximas até displayOrderValue
            while i < len(lines) and 'const displayOrderValue' not in lines[i]:
                i += 1
            if i < len(lines):
                i += 1  # Pular a linha do displayOrderValue também
            continue
        
        # Se encontrar const displayOrderValue fora do try, remover
        if 'const displayOrderValue' in line and not in_try_block:
            i += 1
            continue
        
        # Se encontrar price: priceValue mas não tem as variáveis definidas antes, adicionar
        if 'price: priceValue' in line and not variables_added and in_try_block:
            # Inserir as variáveis antes desta linha
            insert_pos = len(new_lines)
            new_lines.insert(insert_pos, "      // Preparar valores com type assertion para evitar erro de TypeScript\n")
            new_lines.insert(insert_pos + 1, "      const priceValue = typeof formData.price === 'string' \n")
            new_lines.insert(insert_pos + 2, "        ? Number((formData.price as string).replace(',', '.')) \n")
            new_lines.insert(insert_pos + 3, "        : (typeof formData.price === 'number' ? formData.price : 0);\n")
            new_lines.insert(insert_pos + 4, "      \n")
            new_lines.insert(insert_pos + 5, "      const displayOrderValue = typeof formData.display_order === 'string' \n")
            new_lines.insert(insert_pos + 6, "        ? Number(formData.display_order as string) \n")
            new_lines.insert(insert_pos + 7, "        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n")
            new_lines.insert(insert_pos + 8, "\n")
            variables_added = True
        
        # Detectar fim do try
        if '} catch' in line or '}catch' in line:
            in_try_block = False
        
        new_lines.append(line)
        i += 1
    
    # Escrever arquivo corrigido
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print("✅ Correção de escopo aplicada!")
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
    echo "Localização do try:"
    grep -n "try {" "$FILE" | grep -A1 "handleSubmit" | head -2
    echo ""
    echo "Variáveis definidas:"
    grep -n "const priceValue" "$FILE"
    echo ""
    echo "Variáveis usadas:"
    grep -n "price: priceValue" "$FILE"
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

