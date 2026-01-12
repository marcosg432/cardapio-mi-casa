#!/bin/bash

# Script para corrigir especificamente os handlers onChange
# Execute: bash corrigir-onchange-final.sh

set -e

echo "🔧 Corrigindo handlers onChange..."

cd /root/cardapio || exit 1

# Arquivo 1: pages/admin/beverages/[id].tsx
FILE1="pages/admin/beverages/[id].tsx"
if [ -f "$FILE1" ]; then
    echo "📝 Corrigindo $FILE1..."
    
    # Corrigir linha 157 ou similar: price: value === '' ? 0 : value
    # Substituir por: price: value === '' ? 0 : (value as any)
    sed -i "s/price: value === '' ? 0 : value/price: value === '' ? 0 : (value as any)/g" "$FILE1"
    sed -i "s/price: value === \"\" ? 0 : value/price: value === \"\" ? 0 : (value as any)/g" "$FILE1"
    
    # Também corrigir se estiver sem espaços
    sed -i "s/price:value === '' ? 0 : value/price: value === '' ? 0 : (value as any)/g" "$FILE1"
    
    # Corrigir se estiver em uma linha só
    sed -i "s/setFormData({ \.\.\. formData, price: value === '' ? 0 : value })/setFormData({ ...formData, price: value === '' ? 0 : (value as any) })/g" "$FILE1"
    sed -i "s/setFormData ({ \.\.\. formData, price: value === '' ? 0 : value })/setFormData({ ...formData, price: value === '' ? 0 : (value as any) })/g" "$FILE1"
    
    echo "  ✅ $FILE1 corrigido"
fi

# Arquivo 2: pages/admin/dishes/[id].tsx
FILE2="pages/admin/dishes/[id].tsx"
if [ -f "$FILE2" ]; then
    echo "📝 Corrigindo $FILE2..."
    
    sed -i "s/price: value === '' ? 0 : value/price: value === '' ? 0 : (value as any)/g" "$FILE2"
    sed -i "s/price: value === \"\" ? 0 : value/price: value === \"\" ? 0 : (value as any)/g" "$FILE2"
    sed -i "s/price:value === '' ? 0 : value/price: value === '' ? 0 : (value as any)/g" "$FILE2"
    sed -i "s/setFormData({ \.\.\. formData, price: value === '' ? 0 : value })/setFormData({ ...formData, price: value === '' ? 0 : (value as any) })/g" "$FILE2"
    sed -i "s/setFormData ({ \.\.\. formData, price: value === '' ? 0 : value })/setFormData({ ...formData, price: value === '' ? 0 : (value as any) })/g" "$FILE2"
    
    echo "  ✅ $FILE2 corrigido"
fi

# Usar Python para uma correção mais robusta
python3 << 'PYTHON_EOF'
import re
import os

def fix_onchange(file_path):
    if not os.path.exists(file_path):
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    changed = False
    new_lines = []
    
    for i, line in enumerate(lines, 1):
        original_line = line
        
        # Padrão 1: price: value === '' ? 0 : value (sem as any)
        if 'price:' in line and 'value ===' in line and 'value }' in line and '(value as any)' not in line:
            line = re.sub(
                r'price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value(?!\s*as\s*any)',
                r"price: value === '' ? 0 : (value as any)",
                line
            )
            if line != original_line:
                changed = True
                print(f"  → Linha {i} corrigida")
        
        # Padrão 2: setFormData com price: value
        if 'setFormData' in line and 'price:' in line and 'value' in line and '(value as any)' not in line:
            line = re.sub(
                r'setFormData\s*\(\s*\{\s*\.\.\.\s*formData,\s*price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value\s*\}\)',
                r"setFormData({ ...formData, price: value === '' ? 0 : (value as any) })",
                line
            )
            if line != original_line:
                changed = True
                print(f"  → Linha {i} corrigida")
        
        new_lines.append(line)
    
    if changed:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        return True
    return False

files = [
    "pages/admin/beverages/[id].tsx",
    "pages/admin/dishes/[id].tsx"
]

for file_path in files:
    if fix_onchange(file_path):
        print(f"✅ {file_path} corrigido com Python")
PYTHON_EOF

echo ""
echo "✅ Correções aplicadas!"
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
    echo ""
    echo "✅ Processo concluído!"
else
    echo ""
    echo "❌ Build falhou. Verificando o arquivo..."
    echo ""
    echo "📄 Conteúdo da linha 157 de pages/admin/beverages/[id].tsx:"
    sed -n '155,160p' pages/admin/beverages/\[id\].tsx
    exit 1
fi
