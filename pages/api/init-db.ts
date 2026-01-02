import type { NextApiRequest, NextApiResponse } from 'next';
import sqlite3 from 'sqlite3';
import path from 'path';

const dbPath = path.join(process.cwd(), 'cardapio.db');

async function runQuery(db: sqlite3.Database, sql: string): Promise<void> {
  return new Promise((resolve, reject) => {
    db.run(sql, (err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
}

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método não permitido' });
  }

  try {
    const db = new sqlite3.Database(dbPath);

    // Criar todas as tabelas
    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await runQuery(db, `
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        order_index INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

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

    db.close();

    return res.status(200).json({ success: true, message: 'Banco de dados inicializado com sucesso!' });
  } catch (error: any) {
    console.error('Erro ao inicializar banco de dados:', error);
    return res.status(500).json({ error: error.message || 'Erro ao inicializar banco de dados' });
  }
}

