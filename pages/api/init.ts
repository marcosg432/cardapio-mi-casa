import type { NextApiRequest, NextApiResponse } from 'next';
import { hashPassword } from '@/lib/auth';
import { get, run } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método não permitido' });
  }

  try {
    // Verificar se já existe admin
    const existing = await get('SELECT * FROM users WHERE email = ?', ['admin@admin.com']);
    
    if (!existing) {
      const hashedPassword = await hashPassword('admin123');
      await run(
        `INSERT INTO users (email, password) VALUES (?, ?)`,
        ['admin@admin.com', hashedPassword]
      );
      return res.status(200).json({ success: true, message: 'Usuário admin criado' });
    }

    return res.status(200).json({ success: true, message: 'Usuário admin já existe' });
  } catch (error) {
    console.error('Erro ao inicializar:', error);
    return res.status(500).json({ error: 'Erro ao inicializar' });
  }
}
