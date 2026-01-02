# Cardápio Digital

Sistema completo de cardápio digital com painel administrativo para restaurantes.

## 🚀 Funcionalidades

### 📱 Cardápio Público (Mobile)
- Banner principal personalizado
- Seção horizontal de bebidas com scroll
- Cards de pratos com imagem e mini-apresentação
- Páginas detalhadas dos pratos (privadas)
- Interface otimizada apenas para dispositivos móveis

### 🔐 Painel Administrativo
- **Login seguro** com autenticação JWT
- **Gestão de Pratos e Bebidas**
  - Lista completa com busca e filtros
  - Visualização em fichas/cards
  - Filtro por status (ativo, pausado, excluído)
  - Filtro por categoria
  - Busca por nome
  
- **Sistema de Pedidos (Fichas)**
  - Criação de fichas por mesa
  - Adição de pratos e bebidas aos pedidos
  - Controle de quantidade
  - Observações por item
  - Cálculo automático de valores
  - Finalização de pedidos

- **Planilha de Valores**
  - Lista automática de todos os pratos e bebidas ativos
  - Valores conectados diretamente aos itens
  - Atualização automática quando itens são adicionados/removidos

- **Editor de Pratos**
  - Edição completa de pratos
  - Nome, descrição, imagem
  - Categoria e ordem de exibição
  - Status (ativo/pausado)
  - Valor do prato

- **Criação de Pratos (3 Etapas)**
  1. Dados obrigatórios do cardápio (nome, mini-apresentação, imagem)
  2. Página privada do prato (descrição completa, imagem)
  3. Valor interno (para cálculos, não aparece no cardápio público)

- **Sistema de Vias (Receipts)**
  - Histórico completo de pedidos finalizados
  - Busca por código
  - Visualização de via completa
  - Envio via WhatsApp
  - Impressão

## 🛠️ Tecnologias

- **Frontend:** Next.js 14, React 18, TypeScript
- **Backend:** Next.js API Routes
- **Banco de Dados:** SQLite
- **Autenticação:** JWT (JSON Web Tokens)
- **Criptografia:** bcryptjs para senhas

## 📦 Instalação

1. Instale as dependências:
```bash
npm install
```

2. Execute o servidor de desenvolvimento:
```bash
npm run dev
```

3. Acesse:
- **Cardápio público:** http://localhost:3000
- **Painel admin:** http://localhost:3000/admin

## 🔑 Primeiro Acesso

O sistema cria automaticamente um usuário administrador na primeira vez que o painel é acessado:

- **Email:** admin@admin.com
- **Senha:** admin123

⚠️ **IMPORTANTE:** Altere essas credenciais após o primeiro acesso para produção!

## 📋 Estrutura do Projeto

```
cardapio/
├── pages/
│   ├── api/           # API Routes
│   │   ├── auth/      # Autenticação
│   │   ├── dishes/    # Pratos
│   │   ├── beverages/ # Bebidas
│   │   ├── orders/    # Pedidos/Fichas
│   │   ├── receipts/  # Vias
│   │   └── ...
│   ├── admin/         # Painel administrativo
│   ├── prato/         # Páginas de pratos
│   └── index.tsx      # Cardápio público
├── lib/
│   ├── db.ts          # Conexão e funções do banco
│   └── auth.ts        # Autenticação
├── styles/            # Estilos CSS
└── cardapio.db        # Banco de dados SQLite (criado automaticamente)
```

## 🗄️ Banco de Dados

O sistema usa SQLite e cria automaticamente as seguintes tabelas:

- `users` - Usuários do sistema
- `categories` - Categorias de pratos e bebidas
- `dishes` - Pratos do cardápio
- `beverages` - Bebidas do cardápio
- `order_sheets` - Fichas de pedidos
- `order_items` - Itens dos pedidos
- `receipts` - Vias de pedidos finalizados

## 📝 Status dos Itens

Os pratos e bebidas podem ter os seguintes status:

- **active** - Aparece no cardápio público
- **paused** - Não aparece no cardápio, mas não é excluído
- **deleted** - Removido completamente do sistema

## 🎯 Fluxo de Trabalho

1. **Cadastrar Pratos/Bebidas**
   - Acesse o painel admin
   - Vá em "Pratos & Bebidas"
   - Clique em "Novo Prato"
   - Preencha as 3 etapas

2. **Criar Pedido**
   - Vá em "Fichas"
   - Clique em "Nova Ficha"
   - Informe o número da mesa
   - Selecione um prato inicial
   - Adicione mais itens conforme necessário

3. **Gerenciar Pedido**
   - Edite quantidade e observações
   - Adicione novos itens a qualquer momento
   - O valor total é calculado automaticamente

4. **Finalizar Pedido**
   - Clique em "Finalizar Ficha"
   - Visualize a via
   - Envie via WhatsApp ou imprima

## 🔒 Segurança

- Senhas são criptografadas com bcrypt
- Autenticação via JWT com tokens de 7 dias
- Cookies HttpOnly para segurança
- Middleware de autenticação para rotas protegidas

## 📱 Mobile-First

O cardápio público é otimizado exclusivamente para dispositivos móveis. Em computadores, será exibida uma mensagem informando que o acesso deve ser feito em celular.

## 🚧 Melhorias Futuras

- Upload de imagens (atualmente usa URLs)
- Múltiplos usuários admin
- Relatórios e estatísticas
- Gestão de estoque
- Integração com sistemas de pagamento
- App mobile nativo

## 📄 Licença

Este projeto é privado e proprietário.