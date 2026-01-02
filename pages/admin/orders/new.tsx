import { useState } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import styles from '@/styles/OrderNew.module.css';

export default function NewOrder() {
  const router = useRouter();
  const [tableNumber, setTableNumber] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCreateSheet = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!tableNumber) {
      alert('Informe o número da mesa');
      return;
    }

    setLoading(true);

    try {
      // Criar ficha de pedido
      const sheetRes = await fetch('/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          table_number: parseInt(tableNumber),
          customer_name: customerName || ''
        }),
      });

      if (sheetRes.ok) {
        const sheet = await sheetRes.json();
        router.push(`/admin/orders/${sheet.id}`);
      } else {
        alert('Erro ao criar ficha de pedido');
      }
    } catch (error) {
      alert('Erro ao criar ficha de pedido');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Nova Ficha de Pedido - Admin</title>
      </Head>
      <div className={styles.container}>
        <div className={styles.header}>
          <button onClick={() => router.push('/admin')}>← Voltar</button>
          <h1>Nova Ficha de Pedido</h1>
        </div>

        <form onSubmit={handleCreateSheet} className={styles.form}>
          <div className={styles.formGroup}>
            <label>Número da Mesa *</label>
            <input
              type="number"
              value={tableNumber}
              onChange={(e) => setTableNumber(e.target.value)}
              required
              placeholder="Ex: 1, 2, 3..."
            />
          </div>

          <div className={styles.formGroup}>
            <label>Nome do Cliente</label>
            <input
              type="text"
              value={customerName}
              onChange={(e) => setCustomerName(e.target.value)}
              placeholder="Nome da pessoa que está fazendo o pedido (opcional)"
            />
          </div>

          <button
            type="submit"
            disabled={loading || !tableNumber}
            className={styles.createButton}
          >
            {loading ? 'Criando...' : 'Criar Ficha de Pedido'}
          </button>
        </form>
      </div>
    </>
  );
}