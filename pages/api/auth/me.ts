import type { NextApiRequest, NextApiResponse } from 'next';
import { verifyToken } from '@/lib/auth';
import { parse } from 'cookie';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const cookies = parse(req.headers.cookie || '');
  const token = req.headers.authorization?.replace('Bearer ', '') || cookies.token;

  if (!token) {
    return res.status(401).json({ error: 'Não autorizado' });
  }

  const user = verifyToken(token);

  if (!user) {
    return res.status(401).json({ error: 'Token inválido' });
  }

  return res.status(200).json({ user });
}
