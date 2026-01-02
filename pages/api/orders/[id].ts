import type { NextApiRequest, NextApiResponse } from 'next';
import { query, run, get } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id } = req.query;

  if (req.method === 'GET') {
    try {
      const sheet = await get(
        `SELECT * FROM order_sheets WHERE id = ?`,
        [id]
      );

      if (!sheet) {
        return res.status(404).json({ error: 'Ficha não encontrada' });
      }

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
        [id]
      );

      const total = items.reduce((sum: number, item: any) => sum + item.total_price, 0);

      return res.status(200).json({ ...sheet, items, total });
    } catch (error) {
      console.error('Erro ao buscar ficha:', error);
      return res.status(500).json({ error: 'Erro ao buscar ficha' });
    }
  }

  if (req.method === 'PUT') {
    try {
      const { customer_name, table_number } = req.body;

      await run(
        `UPDATE order_sheets 
         SET customer_name = ?, table_number = ?, updated_at = CURRENT_TIMESTAMP
         WHERE id = ?`,
        [customer_name, table_number, id]
      );

      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('Erro ao atualizar ficha:', error);
      return res.status(500).json({ error: 'Erro ao atualizar ficha' });
    }
  }

  if (req.method === 'DELETE') {
    try {
      // Deletar todos os itens da ficha primeiro
      await run('DELETE FROM order_items WHERE sheet_id = ?', [id]);
      // Deletar a ficha
      await run('DELETE FROM order_sheets WHERE id = ?', [id]);
      
      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('Erro ao excluir ficha:', error);
      return res.status(500).json({ error: 'Erro ao excluir ficha' });
    }
  }

  return res.status(405).json({ error: 'Método não permitido' });
}
