import type { NextApiRequest, NextApiResponse } from 'next';
import { query, run } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    try {
      const { search, category, status } = req.query;
      
      let sql = `SELECT d.*, c.name as category_name 
                 FROM dishes d 
                 LEFT JOIN categories c ON d.category_id = c.id 
                 WHERE d.status != 'deleted'`;
      const params: any[] = [];

      if (status && status !== 'all') {
        sql += ` AND d.status = ?`;
        params.push(status);
      }

      if (search) {
        sql += ` AND d.name LIKE ?`;
        params.push(`%${search}%`);
      }

      if (category) {
        sql += ` AND d.category_id = ?`;
        params.push(category);
      }

      sql += ` ORDER BY d.display_order ASC, d.name ASC`;

      const dishes = await query(sql, params);
      return res.status(200).json(dishes);
    } catch (error) {
      console.error('Erro ao buscar pratos:', error);
      return res.status(500).json({ error: 'Erro ao buscar pratos' });
    }
  }

  if (req.method === 'POST') {
    try {
      const { name, mini_presentation, full_description, image_url, category_id, price, display_order } = req.body;

      if (!name || !mini_presentation || !image_url) {
        return res.status(400).json({ error: 'Nome, mini apresentação e imagem são obrigatórios' });
      }

      const result = await run(
        `INSERT INTO dishes (name, mini_presentation, full_description, image_url, category_id, price, display_order, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, 'active')`,
        [name, mini_presentation, full_description || '', image_url || '', category_id || null, price || 0, display_order || 0]
      );

      return res.status(201).json({ id: result.lastID });
    } catch (error) {
      console.error('Erro ao criar prato:', error);
      return res.status(500).json({ error: 'Erro ao criar prato' });
    }
  }

  return res.status(405).json({ error: 'Método não permitido' });
}
