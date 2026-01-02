import { useState } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import styles from '@/styles/DishEdit.module.css';

export default function NewBeverage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    image_url: '',
    category_id: '',
    price: '',
    display_order: '',
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name) {
      alert('Nome é obrigatório');
      return;
    }

    setLoading(true);

    try {
      const res = await fetch('/api/beverages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...formData,
          price: formData.price ? Number(formData.price.toString().replace(',', '.')) : 0,
          display_order: formData.display_order ? Number(formData.display_order.toString()) : 0,
          category_id: formData.category_id || null,
        }),
      });

      if (res.ok) {
        const data = await res.json();
        router.push('/admin');
      } else {
        alert('Erro ao criar bebida');
      }
    } catch (error) {
      alert('Erro ao criar bebida');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Head>
        <title>Nova Bebida - Admin</title>
      </Head>
      <div className={styles.container}>
        <div className={styles.header}>
          <button onClick={() => router.push('/admin')}>← Voltar</button>
          <h1>Nova Bebida</h1>
        </div>

        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.formGroup}>
            <label>Nome da Bebida *</label>
            <input
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
              placeholder="Ex: Coca-Cola, Água, Suco..."
            />
          </div>

          <div className={styles.formGroup}>
            <label>Descrição</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={4}
              placeholder="Descrição da bebida (opcional)"
            />
          </div>

          <div className={styles.formGroup}>
            <label>URL da Imagem</label>
            <input
              value={formData.image_url}
              onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
              placeholder="https://..."
            />
          </div>

          <div className={styles.formGroup}>
            <label>Valor (R$) *</label>
            <input
              type="text"
              value={formData.price === '' ? '' : (typeof formData.price === 'string' && formData.price !== '' ? formData.price : (typeof formData.price === 'number' ? formData.price.toFixed(2).replace('.', ',') : ''))}
              onChange={(e) => setFormData({ ...formData, price: e.target.value })}
              onBlur={(e) => {
                const value = e.target.value;
                if (value) {
                  const numValue = Number(value.replace(',', '.'));
                  if (!isNaN(numValue)) {
                    setFormData({ ...formData, price: numValue.toFixed(2).replace('.', ',') });
                  }
                }
              }}
              required
              placeholder="0,00"
            />
            <small>Este valor é usado para cálculos no painel</small>
          </div>

          <button type="submit" disabled={loading} className={styles.saveButton}>
            {loading ? 'Criando...' : 'Criar Bebida'}
          </button>
        </form>
      </div>
    </>
  );
}
