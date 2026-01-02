import sqlite3 from 'sqlite3';
import path from 'path';
import { existsSync } from 'fs';
import { promisify } from 'util';

const dbPath = path.join(process.cwd(), 'cardapio.db');

async function initDatabase() {
  return new Promise<sqlite3.Database>((resolve, reject) => {
    const db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Erro ao criar/abrir banco de dados:', err);
        reject(err);
        return;
      }
      console.log('Banco de dados conectado:', dbPath);
      resolve(db);
    });
  });
}

async function runQuery(db: sqlite3.Database, sql: string): Promise<void> {
  return new Promise((resolve, reject) => {
    db.run(sql, (err) => {
      if (err) {
        console.error('Erro ao executar query:', err);
        console.error('SQL:', sql);
        reject(err);
      } else {
        resolve();
      }
    });
  });
}

async function initTables() {
  const db = await initDatabase();

  try {
    console.log('Criando tabelas...');

    // Tabela de usuários
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ Tabela users criada');

    // Tabela de categorias
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        order_index INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ Tabela categories criada');

    // Tabela de pratos
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS dishes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mini_presentation TEXT,
        full_description TEXT,
        image_url TEXT,
        price REAL DEFAULT 0,
        category_id INTEGER,
        display_order INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    `);
    console.log('✓ Tabela dishes criada');

    // Tabela de bebidas
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS beverages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        price REAL DEFAULT 0,
        category_id INTEGER,
        display_order INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    `);
    console.log('✓ Tabela beverages criada');

    // Tabela de fichas de pedido
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS order_sheets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER NOT NULL,
        customer_name TEXT,
        status TEXT DEFAULT 'active',
        total REAL DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✓ Tabela order_sheets criada');

    // Tabela de itens dos pedidos
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sheet_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        observation TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sheet_id) REFERENCES order_sheets(id)
      )
    `);
    console.log('✓ Tabela order_items criada');

    // Tabela de vias (receipts)
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        sheet_id INTEGER NOT NULL,
        table_number INTEGER NOT NULL,
        customer_name TEXT,
        total REAL NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sheet_id) REFERENCES order_sheets(id)
      )
    `);
    console.log('✓ Tabela receipts criada');

    // Tabela de itens das vias
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS receipt_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        item_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        observation TEXT,
        FOREIGN KEY (receipt_id) REFERENCES receipts(id)
      )
    `);
    console.log('✓ Tabela receipt_items criada');

    console.log('\n✅ Banco de dados inicializado com sucesso!');
    
  } catch (error) {
    console.error('Erro ao inicializar banco de dados:', error);
    throw error;
  } finally {
    db.close((err) => {
      if (err) {
        console.error('Erro ao fechar banco de dados:', err);
      } else {
        console.log('Banco de dados fechado.');
      }
    });
  }
}

// Executar se for chamado diretamente
if (require.main === module) {
  initTables().catch(console.error);
}

export { initTables };

