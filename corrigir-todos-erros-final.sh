#!/bin/bash

# Script para corrigir TODOS os erros TypeScript de uma vez
# Execute: bash corrigir-todos-erros-final.sh

set -e

echo "🔧 Corrigindo TODOS os erros TypeScript..."

cd /root/cardapio || exit 1

# Arquivo: pages/admin/beverages/[id].tsx
echo "📝 Corrigindo pages/admin/beverages/[id].tsx..."

# Verificar se o arquivo existe
if [ ! -f "pages/admin/beverages/[id].tsx" ]; then
    echo "❌ Arquivo não encontrado: pages/admin/beverages/[id].tsx"
    exit 1
fi

# Criar backup
cp "pages/admin/beverages/[id].tsx" "pages/admin/beverages/[id].tsx.bak"

# Usar Python para fazer a correção de forma mais robusta
python3 << 'PYTHON_SCRIPT'
import re

file_path = "pages/admin/beverages/[id].tsx"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Padrão 1: Corrigir se houver price: typeof formData.price === 'string'? Number(formData.price.replace( dentro do JSON.stringify
# Substituir por variável intermediária
pattern1 = r'body:\s*JSON\.stringify\(\s*\{[^}]*price:\s*typeof\s+formData\.price\s*===\s*[\'"]string[\'"]\s*\?\s*Number\(formData\.price\.replace\([^)]+\)\)[^}]*\}\)'

# Padrão 2: Se não houver as variáveis priceValue e displayOrderValue antes do try, adicionar
if 'const priceValue = typeof formData.price ===' not in content:
    # Procurar pelo handleSubmit e adicionar as variáveis após o try {
    pattern2 = r'(const handleSubmit = async \(e: React\.FormEvent\) => \{[^}]*setSaving\(true\);\s*try\s*\{)'
    replacement2 = r'\1\n      // Preparar valores com type assertion para evitar erro de TypeScript\n      const priceValue = typeof formData.price === \'string\' \n        ? Number((formData.price as string).replace(\',\', \'.\')) \n        : (typeof formData.price === \'number\' ? formData.price : 0);\n      \n      const displayOrderValue = typeof formData.display_order === \'string\' \n        ? Number(formData.display_order as string) \n        : (typeof formData.display_order === \'number\' ? formData.display_order : 0);'
    
    content = re.sub(pattern2, replacement2, content, flags=re.DOTALL)

# Padrão 3: Substituir formData.price e formData.display_order no JSON.stringify por priceValue e displayOrderValue
pattern3 = r'(body:\s*JSON\.stringify\(\s*\{[^}]*\.\.\.formData,)\s*price:\s*formData\.price[^,}]*,\s*display_order:\s*formData\.display_order[^,}]*'
replacement3 = r'\1\n          price: priceValue,\n          display_order: displayOrderValue,'
content = re.sub(pattern3, replacement3, content, flags=re.DOTALL)

# Se ainda houver formData.price.replace sem type assertion, corrigir
content = re.sub(
    r'formData\.price\.replace\(',
    r'(formData.price as string).replace(',
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Correção aplicada em pages/admin/beverages/[id].tsx")
PYTHON_SCRIPT

# Aplicar a mesma correção para dishes/[id].tsx
echo "📝 Corrigindo pages/admin/dishes/[id].tsx..."

if [ -f "pages/admin/dishes/[id].tsx" ]; then
    cp "pages/admin/dishes/[id].tsx" "pages/admin/dishes/[id].tsx.bak"
    
    python3 << 'PYTHON_SCRIPT'
import re

file_path = "pages/admin/dishes/[id].tsx"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Mesmas correções
if 'const priceValue = typeof formData.price ===' not in content:
    pattern2 = r'(const handleSubmit = async \(e: React\.FormEvent\) => \{[^}]*setSaving\(true\);\s*try\s*\{)'
    replacement2 = r'\1\n      // Preparar valores com type assertion para evitar erro de TypeScript\n      const priceValue = typeof formData.price === \'string\' \n        ? Number((formData.price as string).replace(\',\', \'.\')) \n        : (typeof formData.price === \'number\' ? formData.price : 0);\n      \n      const displayOrderValue = typeof formData.display_order === \'string\' \n        ? Number(formData.display_order as string) \n        : (typeof formData.display_order === \'number\' ? formData.display_order : 0);'
    
    content = re.sub(pattern2, replacement2, content, flags=re.DOTALL)

pattern3 = r'(body:\s*JSON\.stringify\(\s*\{[^}]*\.\.\.formData,)\s*price:\s*formData\.price[^,}]*,\s*display_order:\s*formData\.display_order[^,}]*'
replacement3 = r'\1\n          price: priceValue,\n          display_order: displayOrderValue,'
content = re.sub(pattern3, replacement3, content, flags=re.DOTALL)

content = re.sub(
    r'formData\.price\.replace\(',
    r'(formData.price as string).replace(',
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Correção aplicada em pages/admin/dishes/[id].tsx")
PYTHON_SCRIPT
fi

echo ""
echo "✅ Todas as correções aplicadas!"
echo ""
echo "🔨 Tentando fazer build..."
npm run build

