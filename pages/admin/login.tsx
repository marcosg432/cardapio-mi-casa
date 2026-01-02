import { useState } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import styles from '@/styles/Login.module.css';

export default function Login() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // Garantir que o admin existe primeiro
      await fetch('/api/init', { method: 'POST' }).catch(() => {});

      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();

      if (res.ok && data.token) {
        // Salvar token no cookie
        if (typeof window !== 'undefined') {
          document.cookie = `token=${data.token}; Path=/; SameSite=Lax; Max-Age=604800`;
          // Usar window.location para garantir reload completo
          window.location.href = '/admin';
        }
      } else {
        setError(data.error || 'Credenciais inválidas. Use: admin@admin.com / admin123');
        console.error('Erro no login:', data);
      }
    } catch (error) {
      console.error('Erro ao fazer login:', error);
      setError('Erro ao conectar ao servidor. Verifique se o servidor está rodando.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Login - Painel Administrativo</title>
      </Head>
      <div className={styles.container}>
        <div className={styles.loginBox}>
          <h1>Painel Administrativo</h1>
          <form onSubmit={handleSubmit}>
            <div className={styles.formGroup}>
              <label>Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="admin@admin.com"
              />
            </div>
            <div className={styles.formGroup}>
              <label>Senha</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder="admin123"
              />
            </div>
            {error && (
              <div className={styles.error} style={{ marginBottom: '15px' }}>
                {error}
              </div>
            )}
            <button type="submit" disabled={loading} className={styles.submitButton}>
              {loading ? 'Entrando...' : 'Entrar'}
            </button>
            <div style={{ marginTop: '15px', fontSize: '12px', color: '#666', textAlign: 'center' }}>
              <p>Primeira vez? Use:</p>
              <p><strong>Email:</strong> admin@admin.com</p>
              <p><strong>Senha:</strong> admin123</p>
            </div>
          </form>
        </div>
      </div>
    </>
  );
}
