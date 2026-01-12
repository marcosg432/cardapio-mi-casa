#!/bin/bash

# Script DEFINITIVO para corrigir TODOS os erros TypeScript de uma vez
# Execute: bash corrigir-todos-erros-definitivo.sh

set -e

echo "🔧 Corrigindo TODOS os erros TypeScript de uma vez..."

cd /root/cardapio || exit 1

echo "📥 Atualizando código do GitHub..."
git fetch --all --prune
git reset --hard origin/main
git pull origin main

echo "🔍 Corrigindo TODOS os arquivos..."

python3 << 'PYTHON_EOF'
import re
import os

def fix_id_file(file_path):
    """Corrige arquivos [id].tsx (beverages e dishes)"""
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changed = False
    
    # CORREÇÃO 1: Adicionar variáveis priceValue e displayOrderValue se não existirem
    if 'const priceValue = typeof formData.price ===' not in content:
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
    if re.search(r'price:\s*formData\.price\b', content):
        content = re.sub(r'price:\s*formData\.price\b', 'price: priceValue', content)
        changed = True
    
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
    # Padrão: price: value === '' ? 0 : value (sem as any)
    patterns_onchange = [
        (r'price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value(?!\s*as\s*any)', r"price: value === '' ? 0 : (value as any)"),
        (r'setFormData\s*\(\s*\{\s*\.\.\.\s*formData,\s*price:\s*value\s*===\s*[''"]\s*[''"]\s*\?\s*0\s*:\s*value\s*\}\)', r"setFormData({ ...formData, price: value === '' ? 0 : (value as any) })"),
        (r'setFormData\s*\(\s*\{\s*\.\.\.\s*formData,\s*price:\s*value\s*\}\)', r"setFormData({ ...formData, price: (value as any) })"),
    ]
    
    for pattern, replacement in patterns_onchange:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            changed = True
    
    # CORREÇÃO 5: Corrigir toFixed sem type assertion
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

def fix_new_file(file_path):
    """Corrige arquivos new.tsx (beverages e dishes) - REMOVE referências a priceValue/displayOrderValue"""
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    changed = False
    
    # CORREÇÃO 1: Remover referências incorretas a priceValue e displayOrderValue
    # Se houver price: priceValue, substituir por formData.price ? Number(formData.price.toString().replace(',', '.')) : 0
    if 'price: priceValue' in content:
        # Encontrar o contexto do JSON.stringify
        pattern = r'(body:\s*JSON\.stringify\(\s*\{[^\n]*\.\.\.formData,)\s*price:\s*priceValue[^,}]*'
        replacement = r'\1\n          price: formData.price ? Number(formData.price.toString().replace(\',\', \'.\')) : 0,'
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        changed = True
    
    if 'display_order: displayOrderValue' in content:
        pattern = r'(price:\s*formData\.price[^,}]*,\s*)\s*display_order:\s*displayOrderValue[^,}]*'
        replacement = r'\1display_order: formData.display_order ? Number(formData.display_order.toString()) : 0,'
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        changed = True
    
    # CORREÇÃO 2: Garantir que não há variáveis priceValue/displayOrderValue sendo usadas sem definição
    # Se houver uso de priceValue mas não houver definição, remover
    if 'priceValue' in content and 'const priceValue' not in content:
        # Substituir priceValue por formData.price ? Number(formData.price.toString().replace(',', '.')) : 0
        content = re.sub(
            r'priceValue\s*\?\s*Number\(formData\.price\.toString\(\)\.replace\([^)]+\)\)\s*:\s*0',
            r'formData.price ? Number(formData.price.toString().replace(\',\', \'.\')) : 0',
            content
        )
        # Se ainda houver priceValue sozinho
        content = re.sub(
            r'price:\s*priceValue',
            r'price: formData.price ? Number(formData.price.toString().replace(\',\', \'.\')) : 0',
            content
        )
        changed = True
    
    # CORREÇÃO 3: Corrigir toFixed sem type assertion
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

# Corrigir TODOS os arquivos
print("📝 Corrigindo arquivos [id].tsx...")
fix_id_file("pages/admin/beverages/[id].tsx")
fix_id_file("pages/admin/dishes/[id].tsx")

print("\n📝 Corrigindo arquivos new.tsx...")
fix_new_file("pages/admin/beverages/new.tsx")
fix_new_file("pages/admin/dishes/new.tsx")

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
    echo "❌ Build falhou. Verificando erros..."
    echo ""
    echo "📄 Verificando arquivos corrigidos..."
    grep -n "priceValue\|displayOrderValue" pages/admin/beverages/new.tsx pages/admin/dishes/new.tsx 2>/dev/null || echo "✓ Nenhuma referência incorreta encontrada"
    exit 1
fi

