import type { NextApiRequest, NextApiResponse } from 'next';
import { loginUser, generateToken, hashPassword } from '@/lib/auth';
import { get, run } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método não permitido' });
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email e senha são obrigatórios' });
  }

  try {
    // Garantir que o admin existe
    const existing = await get('SELECT * FROM users WHERE email = ?', ['admin@admin.com']);
    
    if (!existing) {
      const hashedPasswordValue = await hashPassword('admin123');
      await run(
        `INSERT INTO users (email, password) VALUES (?, ?)`,
        ['admin@admin.com', hashedPasswordValue]
      );
    }

    const user = await loginUser(email, password);

    if (!user) {
      return res.status(401).json({ error: 'Credenciais inválidas. Email: admin@admin.com, Senha: admin123' });
    }

    const token = generateToken(user);

    res.setHeader('Set-Cookie', `token=${token}; Path=/; HttpOnly; SameSite=Lax; Max-Age=604800`);
    
    return res.status(200).json({ token, user });
  } catch (error: any) {
    console.error('Erro no login:', error);
    return res.status(500).json({ error: `Erro interno: ${error.message || 'Erro desconhecido'}` });
  }
}
