#!/bin/bash

# Script completo para corrigir o arquivo beverages/[id].tsx
# Execute: bash corrigir-completo.sh

FILE="pages/admin/beverages/[id].tsx"

echo "🔧 Aplicando correção completa no arquivo..."

if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Fazer backup
cp "$FILE" "${FILE}.backup.$(date +%Y%m%d_%H%M%S)"
echo "✅ Backup criado"

# Usar Python para fazer a substituição completa
python3 << 'PYTHON_SCRIPT'
import re
import sys

file_path = "pages/admin/beverages/[id].tsx"

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Padrão para encontrar o bloco do fetch PUT
    # Procurar desde o início do try até o final do fetch
    pattern = r"(try\s*\{[^}]*// Preparar valores[^}]*const priceValue[^}]*const displayOrderValue[^}]*const res = await fetch\(`/api/beverages/\$\{id\}`,\s*\{[^}]*method:\s*'PUT',[^}]*headers:\s*\{[^}]*'Content-Type':\s*'application/json'[^}]*\},\s*body:\s*JSON\.stringify\(\{[^}]*\.\.\.formData,[^}]*price:\s*priceValue,[^}]*display_order:\s*displayOrderValue,[^}]*category_id:[^}]*\}\),[^}]*\}\);)"
    
    # Se não encontrar o padrão completo, tentar encontrar e substituir apenas o bloco problemático
    if 'const priceValue' not in content or 'price: priceValue' not in content:
        print("⚠️  Variáveis intermediárias não encontradas. Aplicando correção completa...")
        
        # Encontrar o bloco do fetch PUT
        # Procurar pelo padrão: body: JSON.stringify({ ...formData, price: ..., display_order: ..., category_id: ... })
        old_pattern = r"(body:\s*JSON\.stringify\(\{\s*\.\.\.formData,\s*price:\s*typeof[^,]*,\s*display_order:\s*typeof[^,]*,\s*category_id:[^}]*\}\),)"
        
        replacement = """body: JSON.stringify({
          ...formData,
          price: priceValue,
          display_order: displayOrderValue,
          category_id: formData.category_id || null,
        }),"""
        
        # Se encontrar o padrão antigo, substituir
        if re.search(old_pattern, content):
            # Primeiro, adicionar as variáveis antes do fetch
            fetch_pattern = r"(const res = await fetch\(`/api/beverages/\$\{id\}`,\s*\{)"
            if 'const priceValue' not in content:
                # Adicionar as variáveis antes do fetch
                content = re.sub(
                    fetch_pattern,
                    """      // Preparar valores com type assertion para evitar erro de TypeScript
      const priceValue = typeof formData.price === 'string' 
        ? Number((formData.price as string).replace(',', '.')) 
        : (typeof formData.price === 'number' ? formData.price : 0);
      
      const displayOrderValue = typeof formData.display_order === 'string' 
        ? Number(formData.display_order as string) 
        : (typeof formData.display_order === 'number' ? formData.display_order : 0);

      \\1""",
                    content
                )
            
            # Depois substituir o body
            content = re.sub(old_pattern, replacement, content)
            print("✅ Correção aplicada!")
        else:
            # Verificar se já está correto mas falta as variáveis
            if 'price: priceValue' in content and 'const priceValue' not in content:
                # Adicionar apenas as variáveis
                fetch_pattern = r"(const res = await fetch\(`/api/beverages/\$\{id\}`,\s*\{)"
                content = re.sub(
                    fetch_pattern,
                    """      // Preparar valores com type assertion para evitar erro de TypeScript
      const priceValue = typeof formData.price === 'string' 
        ? Number((formData.price as string).replace(',', '.')) 
        : (typeof formData.price === 'number' ? formData.price : 0);
      
      const displayOrderValue = typeof formData.display_order === 'string' 
        ? Number(formData.display_order as string) 
        : (typeof formData.display_order === 'number' ? formData.display_order : 0);

      \\1""",
                    content
                )
                print("✅ Variáveis adicionadas!")
            else:
                print("⚠️  Padrão não encontrado. Arquivo pode já estar correto ou ter estrutura diferente.")
    else:
        # Verificar se tem type assertion
        if 'as string' not in content:
            print("⚠️  Type assertion não encontrada. Adicionando...")
            content = re.sub(
                r"formData\.price\.replace\(",
                "(formData.price as string).replace(",
                content
            )
            content = re.sub(
                r"Number\(formData\.display_order\)",
                "Number(formData.display_order as string)",
                content
            )
            print("✅ Type assertion adicionada!")
        else:
            print("✅ Arquivo já está correto!")
    
    # Salvar arquivo
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Processo concluído!")
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
    echo "Variáveis definidas:"
    grep -A3 "const priceValue" "$FILE" | head -4
    echo ""
    echo "Variáveis usadas:"
    grep -A2 "price: priceValue" "$FILE" | head -3
    echo ""
    echo "✅ Verificação concluída!"
else
    echo "❌ Erro ao aplicar correção"
    exit 1
fi

