#!/bin/bash

# Script para remover duplicatas das variáveis
# Execute: bash limpar-duplicatas.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🧹 Removendo duplicatas das variáveis..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para remover duplicatas
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    i = 0
    in_try_block = False
    found_price_value = False
    found_display_order_value = False
    skip_until_next_line = False
    
    while i < len(lines):
        line = lines[i]
        
        # Detectar início do try
        if 'try {' in line:
            in_try_block = True
            new_lines.append(line)
            i += 1
            continue
        
        # Detectar fim do try
        if '} catch' in line or '}catch' in line:
            in_try_block = False
            found_price_value = False
            found_display_order_value = False
        
        # Se estiver dentro do try e encontrar const priceValue
        if in_try_block and 'const priceValue' in line:
            if found_price_value:
                # Duplicata encontrada, pular esta e as próximas linhas até o final da definição
                i += 1
                while i < len(lines) and ('?' in lines[i] or ':' in lines[i] or 'Number' in lines[i] or 'typeof' in lines[i] or lines[i].strip() == '' or lines[i].strip() == ';'):
                    i += 1
                continue
            else:
                found_price_value = True
                new_lines.append(line)
                i += 1
                # Adicionar as linhas seguintes até o ponto e vírgula
                while i < len(lines) and not (lines[i].strip().endswith(';') and '0);' in lines[i]):
                    new_lines.append(lines[i])
                    i += 1
                if i < len(lines):
                    new_lines.append(lines[i])
                i += 1
                continue
        
        # Se estiver dentro do try e encontrar const displayOrderValue
        if in_try_block and 'const displayOrderValue' in line:
            if found_display_order_value:
                # Duplicata encontrada, pular esta e as próximas linhas até o final da definição
                i += 1
                while i < len(lines) and ('?' in lines[i] or ':' in lines[i] or 'Number' in lines[i] or 'typeof' in lines[i] or lines[i].strip() == '' or lines[i].strip() == ';'):
                    i += 1
                continue
            else:
                found_display_order_value = True
                new_lines.append(line)
                i += 1
                # Adicionar as linhas seguintes até o ponto e vírgula
                while i < len(lines) and not (lines[i].strip().endswith(';') and '0);' in lines[i]):
                    new_lines.append(lines[i])
                    i += 1
                if i < len(lines):
                    new_lines.append(lines[i])
                i += 1
                continue
        
        # Se encontrar comentário duplicado sobre type assertion
        if '// Preparar valores com type assertion' in line:
            # Verificar se já existe nas últimas 5 linhas
            if '// Preparar valores com type assertion' in ''.join(new_lines[-5:]):
                i += 1
                continue
        
        new_lines.append(line)
        i += 1
    
    # Escrever arquivo corrigido
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print("✅ Duplicatas removidas!")
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
    echo "Contagem de variáveis:"
    echo "  priceValue: $(grep -c "const priceValue" "$FILE")"
    echo "  displayOrderValue: $(grep -c "const displayOrderValue" "$FILE")"
    echo ""
    echo "Linhas 53-65:"
    sed -n '53,65p' "$FILE"
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao remover duplicatas"
    exit 1
fi

