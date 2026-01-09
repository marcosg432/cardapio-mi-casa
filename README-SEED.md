# Como popular o banco de dados no servidor

Este guia explica como cadastrar pratos e bebidas no banco de dados quando o cardápio está vazio no servidor.

## Método 1: Via API (Recomendado)

1. Certifique-se de que o servidor está rodando
2. Acesse a API de seed de dados:

```bash
# Para popular o banco (só funciona se estiver vazio)
curl -X POST http://seu-dominio.com/api/seed-data

# Para forçar a população (limpa e recria os dados)
curl -X POST http://seu-dominio.com/api/seed-data \
  -H "Content-Type: application/json" \
  -d '{"force": true}'
```

## Método 2: Via navegador

1. Acesse: `http://seu-dominio.com/api/seed-data` via POST (use um cliente REST ou extensão do navegador)
2. Ou faça um POST com `force: true` para sobrescrever dados existentes

## Dados que serão cadastrados

### Pratos (6):
- Strogonoff de Frango (R$ 29,90)
- Carne de Panela (R$ 26,89)
- Bife Acebolado (R$ 21,90)
- Filé de Frango Grelhado (R$ 23,99)
- Feijoada Tradicional (R$ 22,00)
- Frango à Parmegiana (R$ 19,90)

### Bebidas (5):
- coca (R$ 9,99)
- Suco de laranja natural (R$ 10,00)
- agua sem gás (R$ 5,00)
- agua com gás (R$ 5,00)
- Suco Natural de Maracujá (R$ 8,00)

## Exportar dados do banco local

Para exportar os dados do banco local:

```bash
# Via API
curl http://localhost:3000/api/export-data > dados-exportados.json
```

## Importar dados personalizados

Se você tiver dados personalizados, edite o arquivo `pages/api/seed-data.ts` e ajuste os arrays `dishes` e `beverages` conforme necessário.

