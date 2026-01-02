import sqlite3 from 'sqlite3';
import path from 'path';
import { existsSync } from 'fs';

const dbPath = path.join(process.cwd(), 'cardapio.db');

let db: sqlite3.Database | null = null;

function getDb(): sqlite3.Database {
  if (!db) {
    try {
      if (!existsSync(dbPath)) {
        console.error('Banco de dados não encontrado:', dbPath);
      }
      db = new sqlite3.Database(dbPath, (err) => {
        if (err) {
          console.error('Erro ao conectar ao banco de dados:', err);
          db = null;
        }
      });
    } catch (error) {
      console.error('Erro ao inicializar banco de dados:', error);
      throw error;
    }
  }
  return db!;
}

export async function query(sql: string, params: any[] = []): Promise<any[]> {
  return new Promise((resolve, reject) => {
    try {
      const database = getDb();
      if (!database) {
        return resolve([]);
      }
      database.all(sql, params, (err, rows) => {
        if (err) {
          console.error('Erro na query:', err, 'SQL:', sql);
          reject(err);
        } else {
          resolve(rows || []);
        }
      });
    } catch (error) {
      console.error('Erro ao executar query:', error);
      resolve([]);
    }
  });
}

export async function get(sql: string, params: any[] = []): Promise<any | null> {
  return new Promise((resolve, reject) => {
    const database = getDb();
    database.get(sql, params, (err, row) => {
      if (err) {
        reject(err);
      } else {
        resolve(row || null);
      }
    });
  });
}

export async function run(sql: string, params: any[] = []): Promise<{ lastID: number; changes: number }> {
  return new Promise((resolve, reject) => {
    const database = getDb();
    database.run(sql, params, function(err) {
      if (err) {
        reject(err);
      } else {
        resolve({ lastID: this.lastID, changes: this.changes });
      }
    });
  });
}
