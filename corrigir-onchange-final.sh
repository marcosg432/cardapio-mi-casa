#!/bin/bash

# Script para corrigir o onChange de forma mais robusta
# Execute: bash corrigir-onchange-final.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Corrigindo onChange de forma robusta..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para fazer substituição mais precisa
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Padrões variados para encontrar e corrigir
    patterns = [
        # Padrão 1: price: value === '' ? 0 : value
        (r"price:\s*value\s*===\s*''\s*\?\s*0\s*:\s*value", "price: value === '' ? 0 : (value as any)"),
        # Padrão 2: price: value == '' ? 0 : value
        (r"price:\s*value\s*==\s*''\s*\?\s*0\s*:\s*value", "price: value === '' ? 0 : (value as any)"),
        # Padrão 3: price: value === ''? 0: value (sem espaços)
        (r"price:\s*value\s*===\s*''\s*\?\s*0\s*:\s*value", "price: value === '' ? 0 : (value as any)"),
    ]
    
    original_content = content
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    # Se não encontrou nenhum padrão, tentar encontrar a linha e substituir manualmente
    if content == original_content:
        # Procurar por setFormData com price
        lines = content.split('\n')
        new_lines = []
        for line in lines:
            if 'setFormData' in line and 'price:' in line and 'value' in line:
                # Substituir qualquer variação
                line = re.sub(r"price:\s*value\s*===\s*''\s*\?\s*0\s*:\s*value", "price: value === '' ? 0 : (value as any)", line)
                line = re.sub(r"price:\s*value\s*==\s*''\s*\?\s*0\s*:\s*value", "price: value === '' ? 0 : (value as any)", line)
            new_lines.append(line)
        content = '\n'.join(new_lines)
    
    # Escrever arquivo
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
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
    grep -n "price: value === '' ? 0 : (value as any)" "$FILE" | head -1
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

echo ""
echo "✅ Processo concluído!"

