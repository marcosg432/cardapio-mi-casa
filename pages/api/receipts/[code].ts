import type { NextApiRequest, NextApiResponse } from 'next';
import { get, run } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const { code } = req.query;

  if (req.method === 'GET') {
    try {
      const receipt = await get('SELECT * FROM receipts WHERE code = ?', [code]);

      if (!receipt) {
        return res.status(404).json({ error: 'Via não encontrada' });
      }

      return res.status(200).json({
        ...receipt,
        items: JSON.parse(receipt.items || '[]'),
      });
    } catch (error) {
      console.error('Erro ao buscar via:', error);
      return res.status(500).json({ error: 'Erro ao buscar via' });
    }
  }

  if (req.method === 'DELETE') {
    try {
      await run('DELETE FROM receipts WHERE code = ?', [code]);
      return res.status(200).json({ success: true });
    } catch (error) {
      console.error('Erro ao excluir via:', error);
      return res.status(500).json({ error: 'Erro ao excluir via' });
    }
  }

  return res.status(405).json({ error: 'Método não permitido' });
}
