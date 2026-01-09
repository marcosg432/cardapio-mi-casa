#!/bin/bash

# Script completo para configurar o servidor do zero
# Execute este script no servidor: bash <(curl -s) ou copie e cole

set -e

echo "🚀 Configurando servidor para cardápio na porta 3007..."
echo ""

# Verificar se está no diretório correto
if [ ! -d "/root/cardapio" ]; then
    echo "📦 Clonando repositório..."
    cd /root
    git clone https://github.com/marcosg432/cardapiomicasa.git cardapio
    cd cardapio
else
    echo "📂 Entrando no diretório do projeto..."
    cd /root/cardapio
fi

echo "🔄 Forçando atualização do repositório..."
# Limpar cache do git
git fetch --all --prune
git fetch origin

# Verificar qual commit está no origin/main
echo "📋 Commit atual no origin/main:"
git log origin/main --oneline -1

# Resetar para o commit correto
echo "🔄 Resetando para origin/main..."
git reset --hard origin/main

# Verificar se os arquivos existem agora
echo ""
echo "✅ Verificando arquivos de configuração..."
if [ -f "ecosystem.config.js" ]; then
    echo "  ✅ ecosystem.config.js encontrado"
else
    echo "  ❌ ecosystem.config.js NÃO encontrado"
    echo "  📥 Tentando baixar novamente..."
    git checkout origin/main -- ecosystem.config.js || echo "  ⚠️  Falha ao baixar ecosystem.config.js"
fi

if [ -f "server.js" ]; then
    echo "  ✅ server.js encontrado"
else
    echo "  ❌ server.js NÃO encontrado"
    echo "  📥 Tentando baixar novamente..."
    git checkout origin/main -- server.js || echo "  ⚠️  Falha ao baixar server.js"
fi

if [ -f "deploy.sh" ]; then
    echo "  ✅ deploy.sh encontrado"
    chmod +x deploy.sh
else
    echo "  ❌ deploy.sh NÃO encontrado"
    echo "  📥 Tentando baixar novamente..."
    git checkout origin/main -- deploy.sh && chmod +x deploy.sh || echo "  ⚠️  Falha ao baixar deploy.sh"
fi

# Criar arquivos manualmente se não existirem
if [ ! -f "ecosystem.config.js" ]; then
    echo "📝 Criando ecosystem.config.js manualmente..."
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'cardapio-3007',
      script: 'server.js',
      cwd: '/root/cardapio',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3007,
        HOST: '0.0.0.0'
      },
      error_file: '/root/cardapio/logs/pm2-error.log',
      out_file: '/root/cardapio/logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    }
  ]
};
EOF
    echo "  ✅ ecosystem.config.js criado"
fi

if [ ! -f "server.js" ]; then
    echo "📝 Criando server.js manualmente..."
    cat > server.js << 'EOF'
const { createServer } = require('http');
const { parse } = require('url');
const next = require('next');

const dev = process.env.NODE_ENV !== 'production';
const hostname = process.env.HOST || '0.0.0.0';
const port = parseInt(process.env.PORT || '3007', 10);

const app = next({ dev, hostname, port });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  createServer(async (req, res) => {
    try {
      const parsedUrl = parse(req.url, true);
      await handle(req, res, parsedUrl);
    } catch (err) {
      console.error('Error occurred handling', req.url, err);
      res.statusCode = 500;
      res.end('internal server error');
    }
  }).listen(port, hostname, (err) => {
    if (err) throw err;
    console.log(`> Ready on http://${hostname}:${port}`);
  });
});
EOF
    echo "  ✅ server.js criado"
fi

# Corrigir erro de TypeScript
echo ""
echo "🔧 Verificando e corrigindo erro de TypeScript..."
BEVERAGE_FILE="pages/admin/beverages/[id].tsx"
if [ -f "$BEVERAGE_FILE" ]; then
    # Verificar se já está corrigido
    if ! grep -q "typeof formData.price === 'number' ? formData.price : 0" "$BEVERAGE_FILE"; then
        echo "  🔧 Aplicando correção no arquivo beverages/[id].tsx..."
        # Fazer backup
        cp "$BEVERAGE_FILE" "${BEVERAGE_FILE}.backup"
        
        # Aplicar correção
        sed -i "s/price: typeof formData\.price === 'string'? Number(formData\.price\.replace(',', '.')) : (formData\.price || 0),/price: typeof formData.price === 'string' ? Number(formData.price.replace(',', '.')) : (typeof formData.price === 'number' ? formData.price : 0),/g" "$BEVERAGE_FILE"
        sed -i "s/display_order: typeof formData\.display_order === 'string'? Number(formData\.display_order) : (formData\.display_order || 0),/display_order: typeof formData.display_order === 'string' ? Number(formData.display_order) : (typeof formData.display_order === 'number' ? formData.display_order : 0),/g" "$BEVERAGE_FILE"
        sed -i "s/formData\. price/formData.price/g" "$BEVERAGE_FILE"
        echo "  ✅ Correção aplicada"
    else
        echo "  ✅ Arquivo já está corrigido"
    fi
fi

echo ""
echo "✅ Configuração concluída!"
echo ""
echo "📋 Arquivos verificados:"
ls -la ecosystem.config.js server.js deploy.sh 2>/dev/null | head -3

echo ""
echo "🚀 Próximos passos:"
echo "   1. npm install --production"
echo "   2. npm run build"
echo "   3. ./deploy.sh"

