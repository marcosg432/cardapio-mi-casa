import type { NextApiRequest, NextApiResponse } from 'next';
import { query } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Método não permitido' });
  }

  try {
    const dishes = await query('SELECT * FROM dishes WHERE status = "active"');
    const beverages = await query('SELECT * FROM beverages WHERE status = "active"');
    const categories = await query('SELECT * FROM categories');

    return res.status(200).json({
      success: true,
      dishes,
      beverages,
      categories,
      counts: {
        dishes: dishes.length,
        beverages: beverages.length,
        categories: categories.length,
      }
    });
  } catch (error: any) {
    console.error('Erro ao exportar dados:', error);
    return res.status(500).json({
      error: 'Erro ao exportar dados',
      details: error.message,
    });
  }
}

