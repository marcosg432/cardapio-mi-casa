#!/bin/bash

# Script para corrigir o erro de TypeScript usando variáveis intermediárias
# Execute: bash corrigir-typescript-final.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Corrigindo erro de TypeScript com variáveis intermediárias..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para fazer a substituição de forma precisa
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Padrão para encontrar o bloco do fetch
    pattern = r"(const res = await fetch\(`/api/beverages/\$\{id\}`,\s*\{[^}]*method:\s*'PUT',[^}]*headers:\s*\{[^}]*'Content-Type':\s*'application/json'[^}]*\},\s*body:\s*JSON\.stringify\(\{[^}]*\.\.\.formData,[^}]*price:\s*typeof[^}]*display_order:\s*typeof[^}]*category_id:[^}]*\}\),[^}]*\}\);)"
    
    # Substituição com variáveis intermediárias
    replacement = """      // Preparar valores com type assertion para evitar erro de TypeScript
      const priceValue = typeof formData.price === 'string' 
        ? Number(formData.price.replace(',', '.')) 
        : (typeof formData.price === 'number' ? formData.price : 0);
      
      const displayOrderValue = typeof formData.display_order === 'string' 
        ? Number(formData.display_order) 
        : (typeof formData.display_order === 'number' ? formData.display_order : 0);

      const res = await fetch(`/api/beverages/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          price: priceValue,
          display_order: displayOrderValue,
          category_id: formData.category_id || null,
        }),
      });"""
    
    # Tentar substituição com padrão mais simples
    # Procurar pela linha específica do body
    old_pattern = r"body:\s*JSON\.stringify\(\{\s*\.\.\.formData,\s*price:\s*typeof[^,]*,\s*display_order:\s*typeof[^,]*,\s*category_id:[^}]*\}\),"
    
    # Substituição mais direta - encontrar o bloco completo
    lines = content.split('\n')
    new_lines = []
    i = 0
    found = False
    
    while i < len(lines):
        line = lines[i]
        
        # Procurar pelo início do fetch
        if 'const res = await fetch(`/api/beverages/${id}`' in line and not found:
            found = True
            # Adicionar as variáveis intermediárias
            new_lines.append("      // Preparar valores com type assertion para evitar erro de TypeScript")
            new_lines.append("      const priceValue = typeof formData.price === 'string' ")
            new_lines.append("        ? Number(formData.price.replace(',', '.')) ")
            new_lines.append("        : (typeof formData.price === 'number' ? formData.price : 0);")
            new_lines.append("      ")
            new_lines.append("      const displayOrderValue = typeof formData.display_order === 'string' ")
            new_lines.append("        ? Number(formData.display_order) ")
            new_lines.append("        : (typeof formData.display_order === 'number' ? formData.display_order : 0);")
            new_lines.append("")
            new_lines.append(line)
            i += 1
            # Pular até encontrar o body
            while i < len(lines) and 'body: JSON.stringify({' not in lines[i]:
                new_lines.append(lines[i])
                i += 1
            # Adicionar a linha do body
            if i < len(lines):
                new_lines.append(lines[i])
                i += 1
            # Pular a linha do ...formData
            if i < len(lines) and '...formData,' in lines[i]:
                i += 1
            # Substituir as linhas de price e display_order
            while i < len(lines):
                if 'price: typeof formData.price' in lines[i]:
                    new_lines.append("          price: priceValue,")
                    i += 1
                elif 'display_order: typeof formData.display_order' in lines[i]:
                    new_lines.append("          display_order: displayOrderValue,")
                    i += 1
                elif 'category_id:' in lines[i]:
                    new_lines.append(lines[i])
                    i += 1
                    break
                else:
                    i += 1
        else:
            new_lines.append(line)
            i += 1
    
    if found:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(new_lines))
        print("✅ Correção aplicada com sucesso usando variáveis intermediárias!")
        sys.exit(0)
    else:
        print("⚠️  Padrão não encontrado. Tentando método alternativo...")
        # Método alternativo: substituir apenas as linhas problemáticas
        content_new = re.sub(
            r"price:\s*typeof formData\.price === 'string'\s*\?\s*Number\(formData\.price\.replace\(','\s*,\s*'\.'\)\)\s*:\s*\(typeof formData\.price === 'number'\s*\?\s*formData\.price\s*:\s*0\),",
            "price: priceValue,",
            content
        )
        content_new = re.sub(
            r"display_order:\s*typeof formData\.display_order === 'string'\s*\?\s*Number\(formData\.display_order\)\s*:\s*\(typeof formData\.display_order === 'number'\s*\?\s*formData\.display_order\s*:\s*0\),",
            "display_order: displayOrderValue,",
            content_new
        )
        
        # Adicionar as variáveis antes do fetch se não existirem
        if 'const priceValue' not in content_new:
            # Encontrar a linha do fetch e adicionar antes
            content_new = re.sub(
                r"(const res = await fetch\(`/api/beverages/\$\{id\}`)",
                "      // Preparar valores com type assertion para evitar erro de TypeScript\n      const priceValue = typeof formData.price === 'string' \n        ? Number(formData.price.replace(',', '.')) \n        : (typeof formData.price === 'number' ? formData.price : 0);\n      \n      const displayOrderValue = typeof formData.display_order === 'string' \n        ? Number(formData.display_order) \n        : (typeof formData.display_order === 'number' ? formData.display_order : 0);\n\n      \\1",
                content_new
            )
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content_new)
        print("✅ Correção aplicada (método alternativo)")
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
    grep -A5 "const priceValue" "$FILE" | head -6
    echo ""
    echo "✅ Processo concluído!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

