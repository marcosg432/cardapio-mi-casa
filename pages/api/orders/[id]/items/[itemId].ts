import type { NextApiRequest, NextApiResponse } from 'next';
import { run, query } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { id, itemId } = req.query;

  if (req.method === 'PUT') {
    try {
      const { quantity, observation } = req.body;

      // Buscar item atual
      const item = await query('SELECT * FROM order_items WHERE id = ? AND sheet_id = ?', [itemId, id]);
      if (!item || item.length === 0) {
        return res.status(404).json({ error: 'Item não encontrado' });
      }

      const unit_price = item[0].unit_price;
      const total_price = unit_price * quantity;

      await run(
        `UPDATE order_items 
         SET quantity = ?, observation = ?, total_price = ?
         WHERE id = ? AND sheet_id = ?`,
        [quantity, observation || '', total_price, itemId, id]
      );

      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('Erro ao atualizar item:', error);
      return res.status(500).json({ error: 'Erro ao atualizar item' });
    }
  }

  if (req.method === 'DELETE') {
    try {
      await run('DELETE FROM order_items WHERE id = ? AND sheet_id = ?', [itemId, id]);
      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('Erro ao remover item:', error);
      return res.status(500).json({ error: 'Erro ao remover item' });
    }
  }

  return res.status(405).json({ error: 'Método não permitido' });
}
