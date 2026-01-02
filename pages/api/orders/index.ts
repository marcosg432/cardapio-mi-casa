import type { NextApiRequest, NextApiResponse } from 'next';
import { query, run, get } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'GET') {
    try {
      const { status } = req.query;
      
      let sql = `SELECT o.*, 
                        (SELECT SUM(oi.total_price) FROM order_items oi WHERE oi.sheet_id = o.id) as calculated_total
                 FROM order_sheets o`;
      const params: any[] = [];

      if (status) {
        sql += ` WHERE o.status = ?`;
        params.push(status);
      } else {
        sql += ` WHERE o.status = 'active'`;
      }

      sql += ` ORDER BY o.created_at ASC`;

      const sheets = await query(sql, params);

      // Buscar itens de cada ficha
      for (const sheet of sheets) {
        const items = await query(
          `SELECT oi.*, 
                  CASE 
                    WHEN oi.item_type = 'dish' THEN d.name
                    WHEN oi.item_type = 'beverage' THEN b.name
                  END as item_name,
                  CASE 
                    WHEN oi.item_type = 'dish' THEN d.image_url
                    WHEN oi.item_type = 'beverage' THEN b.image_url
                  END as item_image
           FROM order_items oi
           LEFT JOIN dishes d ON oi.item_type = 'dish' AND oi.item_id = d.id
           LEFT JOIN beverages b ON oi.item_type = 'beverage' AND oi.item_id = b.id
           WHERE oi.sheet_id = ?
           ORDER BY oi.created_at ASC`,
          [sheet.id]
        );
        sheet.items = items;
        sheet.total = sheet.calculated_total || 0;
      }

      return res.status(200).json(sheets);
    } catch (error) {
      console.error('Erro ao buscar fichas:', error);
      return res.status(500).json({ error: 'Erro ao buscar fichas' });
    }
  }

  if (req.method === 'POST') {
    try {
      const { table_number, customer_name } = req.body;

      if (!table_number) {
        return res.status(400).json({ error: 'Número da mesa é obrigatório' });
      }

      const result = await run(
        `INSERT INTO order_sheets (table_number, customer_name, status, total)
         VALUES (?, ?, 'active', 0)`,
        [table_number, customer_name || '']
      );

      return res.status(201).json({ id: result.lastID });
    } catch (error) {
      console.error('Erro ao criar ficha:', error);
      return res.status(500).json({ error: 'Erro ao criar ficha' });
    }
  }

  return res.status(405).json({ error: 'Método não permitido' });
}
