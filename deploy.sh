#!/bin/bash

# Script de deploy para o cardápio na porta 3007
# Uso: ./deploy.sh

set -e

echo "🚀 Iniciando deploy do cardápio na porta 3007..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se está no diretório correto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Erro: package.json não encontrado. Execute este script no diretório do projeto.${NC}"
    exit 1
fi

# Criar diretório de logs se não existir
mkdir -p logs

# Parar o processo PM2 se já estiver rodando
echo -e "${YELLOW}📦 Parando processo PM2 existente (se houver)...${NC}"
pm2 stop cardapio-3007 2>/dev/null || true
pm2 delete cardapio-3007 2>/dev/null || true

# Instalar dependências
echo -e "${YELLOW}📦 Instalando dependências...${NC}"
npm install --production

# Fazer build do Next.js
echo -e "${YELLOW}🔨 Fazendo build do projeto...${NC}"
npm run build

# Iniciar com PM2
echo -e "${YELLOW}🚀 Iniciando aplicação com PM2...${NC}"
pm2 start ecosystem.config.js

# Salvar configuração do PM2
pm2 save

# Mostrar status
echo -e "${GREEN}✅ Deploy concluído!${NC}"
echo -e "${GREEN}📊 Status do PM2:${NC}"
pm2 status

echo -e "${GREEN}📝 Logs disponíveis em:${NC}"
echo "  - /root/cardapio/logs/pm2-out.log"
echo "  - /root/cardapio/logs/pm2-error.log"
echo ""
echo -e "${GREEN}🔍 Para ver os logs em tempo real:${NC}"
echo "  pm2 logs cardapio-3007"
echo ""
echo -e "${GREEN}🌐 Aplicação rodando em: http://193.160.119.67:3007${NC}"

