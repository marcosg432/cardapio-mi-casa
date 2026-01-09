# Verificar imagem de fundo no servidor

## Problema:
O fundo visual não está igual no servidor comparado ao local.

## Solução:

### 1. No servidor, verificar se a imagem existe:
```bash
cd /root/cardapio
ls -la public/imagem/00.png
```

### 2. Se a imagem não existir, fazer pull do código:
```bash
git pull origin main
```

### 3. Verificar se a imagem está em public/imagem:
```bash
ls -la public/imagem/
```

### 4. Se ainda não existir, copiar manualmente:
```bash
# Verificar se existe em outro lugar
find . -name "00.png" -type f

# Se encontrar, copiar para public/imagem
cp imagem/00.png public/imagem/00.png
# ou
cp public/imagem/00.png public/imagem/00.png
```

### 5. Reiniciar o servidor:
```bash
pm2 restart cardapio-3007
```

### 6. Verificar no navegador:
Acesse: http://193.160.119.67:3007/prato/1

O fundo deve mostrar a imagem `00.png`.

### 7. Se ainda não funcionar, verificar o console do navegador (F12):
- Veja se há erros 404 para a imagem
- Verifique o caminho que está tentando carregar
- Confirme que a URL está correta: `/imagem/00.png`

