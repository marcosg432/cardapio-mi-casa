#!/bin/bash

# Script para corrigir TODOS os erros TypeScript no servidor usando Python
# Execute: bash corrigir-todos-erros-python.sh

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

def fix_beverages_id():
    file_path = "pages/admin/beverages/[id].tsx"
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Verificar se já tem as variáveis
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
    
    # Substituir formData.price e formData.display_order no JSON.stringify por priceValue e displayOrderValue
    # Procurar por body: JSON.stringify({ ...formData, price: formData.price, display_order: formData.display_order
    pattern2 = r'(body:\s*JSON\.stringify\(\s*\{[^\n]*\.\.\.formData,)'
    if re.search(pattern2, content):
        # Substituir price: formData.price por price: priceValue
        content = re.sub(r'price:\s*formData\.price\b', 'price: priceValue', content)
        # Substituir display_order: formData.display_order por display_order: displayOrderValue
        content = re.sub(r'display_order:\s*formData\.display_order\b', 'display_order: displayOrderValue', content)
    
    # Corrigir qualquer replace sem type assertion
    content = re.sub(
        r'formData\.price\.replace\(',
        r'(formData.price as string).replace(',
        content
    )
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ {file_path} corrigido")
        return True
    else:
        print(f"✓ {file_path} já está correto")
        return True

def fix_dishes_id():
    file_path = "pages/admin/dishes/[id].tsx"
    if not os.path.exists(file_path):
        print(f"❌ Arquivo não encontrado: {file_path}")
        return False
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
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
    
    pattern2 = r'(body:\s*JSON\.stringify\(\s*\{[^\n]*\.\.\.formData,)'
    if re.search(pattern2, content):
        content = re.sub(r'price:\s*formData\.price\b', 'price: priceValue', content)
        content = re.sub(r'display_order:\s*formData\.display_order\b', 'display_order: displayOrderValue', content)
    
    content = re.sub(
        r'formData\.price\.replace\(',
        r'(formData.price as string).replace(',
        content
    )
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ {file_path} corrigido")
        return True
    else:
        print(f"✓ {file_path} já está correto")
        return True

# Executar correções
fix_beverages_id()
fix_dishes_id()

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

