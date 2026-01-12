#!/bin/bash

# Script COMPLETO para corrigir TODOS os erros TypeScript no servidor
# Execute: bash corrigir-todos-erros-completo.sh

set -e

echo "🔧 Corrigindo TODOS os erros TypeScript no servidor..."

cd /root/cardapio || exit 1

echo "📥 Atualizando código do GitHub..."
git fetch --all --prune
git reset --hard origin/main
git pull origin main

echo "🔍 Corrigindo arquivos..."

python3 << 'PYTHON_EOF'
import re
import os

def fix_file(file_path):
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changed = False
    
    # CORREÇÃO 1: Adicionar variáveis priceValue e displayOrderValue se não existirem
    if 'const priceValue = typeof formData.price ===' not in content:
        # Encontrar o handleSubmit e adicionar variáveis após setSaving(true) e try {
        pattern = r'(setSaving\(true\);\s*try\s*\{)'
        replacement = r'''setSaving(true);

    try {
      // Preparar valores com type assertion para evitar erro de TypeScript
      const priceValue = typeof formData.price === 'string' 
        ? Number((formData.price as string).replace(',', '.')) 
        : (typeof formData.price === 'number' ? formData.price : 0);
      
      const displayOrderValue = typeof formData.display_order === 'string' 
        ? Number(formData.display_order as string) 
        : (typeof formData.display_order === 'number' ? formData.display_order : 0);'''
        
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        changed = True
    
    # CORREÇÃO 2: Substituir formData.price e formData.display_order no JSON.stringify
    # Substituir price: formData.price por price: priceValue
    if re.search(r'price:\s*formData\.price\b', content):
        content = re.sub(r'price:\s*formData\.price\b', 'price: priceValue', content)
        changed = True
    
    # Substituir display_order: formData.display_order por display_order: displayOrderValue
    if re.search(r'display_order:\s*formData\.display_order\b', content):
        content = re.sub(r'display_order:\s*formData\.display_order\b', 'display_order: displayOrderValue', content)
        changed = True
    
    # CORREÇÃO 3: Corrigir replace sem type assertion
    if re.search(r'formData\.price\.replace\(', content):
        content = re.sub(
            r'formData\.price\.replace\(',
            r'(formData.price as string).replace(',
            content
        )
        changed = True
    
    # CORREÇÃO 4: Corrigir onChange handlers - adicionar (value as any)
    # Padrão: setFormData({ ...formData, price: value === '' ? 0 : value })
    pattern_onchange1 = r'setFormData\(\s*\{\s*\.\.\.formData,\s*price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value\s*\}\)'
    if re.search(pattern_onchange1, content):
        content = re.sub(
            pattern_onchange1,
            r"setFormData({ ...formData, price: value === '' ? 0 : (value as any) })",
            content
        )
        changed = True
    
    # Padrão alternativo: setFormData({ ...formData, price: value })
    pattern_onchange2 = r'setFormData\(\s*\{\s*\.\.\.formData,\s*price:\s*value\s*\}\)'
    if re.search(pattern_onchange2, content) and '(value as any)' not in content:
        content = re.sub(
            pattern_onchange2,
            r"setFormData({ ...formData, price: (value as any) })",
            content
        )
        changed = True
    
    # Padrão: price: value === '' ? 0 : value (sem setFormData completo)
    pattern_onchange3 = r'price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value(?!\s*as\s*any)'
    if re.search(pattern_onchange3, content):
        content = re.sub(
            pattern_onchange3,
            r"price: value === '' ? 0 : (value as any)",
            content
        )
        changed = True
    
    # CORREÇÃO 5: Corrigir toFixed sem type assertion
    # Padrão: formData.price as number).toFixed(2) (sem parênteses antes)
    if re.search(r'formData\.price\s+as\s+number\)\.toFixed\(', content):
        content = re.sub(
            r'formData\.price\s+as\s+number\)\.toFixed\(',
            r'(formData.price as number).toFixed(',
            content
        )
        changed = True
    
    if changed:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ {file_path} corrigido")
        return True
    else:
        print(f"✓ {file_path} já está correto")
        return True

# Corrigir todos os arquivos
files = [
    "pages/admin/beverages/[id].tsx",
    "pages/admin/dishes/[id].tsx",
    "pages/admin/beverages/new.tsx",
    "pages/admin/dishes/new.tsx"
]

for file_path in files:
    fix_file(file_path)

print("\n✅ Todas as correções aplicadas!")
PYTHON_EOF

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
    echo "❌ Build falhou. Verifique os erros acima."
    exit 1
fi

