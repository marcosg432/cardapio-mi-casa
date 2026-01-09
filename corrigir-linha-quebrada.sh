#!/bin/bash

# Script para corrigir linha quebrada do displayOrderValue
# Execute: bash corrigir-linha-quebrada.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Corrigindo linha quebrada..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Procurar pela linha quebrada e corrigir
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    new_lines = []
    i = 0
    
    while i < len(lines):
        line = lines[i]
        
        # Se encontrar uma linha que começa com ? (operador ternário sozinho)
        # e a linha anterior não tem const displayOrderValue, corrigir
        if line.strip().startswith('?') and 'Number(formData.display_order' in line:
            # Verificar linha anterior
            if i > 0 and 'const displayOrderValue' not in lines[i-1]:
                # Adicionar a linha completa
                new_lines.append("      const displayOrderValue = typeof formData.display_order === 'string' \n")
                new_lines.append(line)
            else:
                new_lines.append(line)
        # Se encontrar linha que começa com : e é parte do displayOrderValue
        elif line.strip().startswith(':') and 'typeof formData.display_order === \'number\'' in line:
            new_lines.append(line)
        # Se encontrar const res = await fetch mas não tem as variáveis antes
        elif 'const res = await fetch' in line and i > 0:
            # Verificar se as variáveis existem nas últimas linhas
            last_20_lines = ''.join(new_lines[-20:])
            if 'const priceValue' not in last_20_lines or 'const displayOrderValue' not in last_20_lines:
                # Adicionar as variáveis antes do fetch
                new_lines.append("      // Preparar valores com type assertion para evitar erro de TypeScript\n")
                new_lines.append("      const priceValue = typeof formData.price === 'string' \n")
                new_lines.append("        ? Number((formData.price as string).replace(',', '.')) \n")
                new_lines.append("        : (typeof formData.price === 'number' ? formData.price : 0);\n")
                new_lines.append("      \n")
                new_lines.append("      const displayOrderValue = typeof formData.display_order === 'string' \n")
                new_lines.append("        ? Number(formData.display_order as string) \n")
                new_lines.append("        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n")
                new_lines.append("\n")
            new_lines.append(line)
        else:
            new_lines.append(line)
        
        i += 1
    
    # Escrever arquivo corrigido
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print("✅ Linha quebrada corrigida!")
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
    echo "Linhas ao redor da linha 30:"
    sed -n '28,35p' "$FILE"
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

