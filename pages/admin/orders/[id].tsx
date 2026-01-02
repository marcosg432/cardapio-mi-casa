import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import styles from '@/styles/OrderDetail.module.css';

export default function OrderDetail() {
  const router = useRouter();
  const { id } = router.query;
  const [sheet, setSheet] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [dishes, setDishes] = useState<any[]>([]);
  const [beverages, setBeverages] = useState<any[]>([]);
  const [showAddItem, setShowAddItem] = useState(false);

  useEffect(() => {
    if (id) {
      loadSheet();
      loadItems();
    }
  }, [id]);

  const loadSheet = async () => {
    try {
      const res = await fetch(`/api/orders/${id}`);
      if (res.ok) {
        const data = await res.json();
        setSheet(data);
      }
    } catch (error) {
      console.error('Erro ao carregar ficha:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadItems = async () => {
    try {
      const [dishesRes, beveragesRes] = await Promise.all([
        fetch('/api/dishes?status=active'),
        fetch('/api/beverages?status=active'),
      ]);
      const dishesData = await dishesRes.json();
      const beveragesData = await beveragesRes.json();
      setDishes(dishesData.map((d: any) => ({ ...d, type: 'dish' })));
      setBeverages(beveragesData.map((b: any) => ({ ...b, type: 'beverage' })));
    } catch (error) {
      console.error('Erro ao carregar itens:', error);
    }
  };

  const handleUpdateSheet = async (field: string, value: any) => {
    try {
      await fetch(`/api/orders/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ [field]: value }),
      });
      loadSheet();
    } catch (error) {
      console.error('Erro ao atualizar:', error);
    }
  };

  const handleAddItem = async (itemType: string, itemId: number) => {
    try {
      await fetch(`/api/orders/${id}/items`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          item_type: itemType,
          item_id: itemId,
          quantity: 1,
        }),
      });
      loadSheet();
      setShowAddItem(false);
    } catch (error) {
      console.error('Erro ao adicionar item:', error);
    }
  };

  const handleUpdateQuantity = async (itemId: number, quantity: number) => {
    try {
      await fetch(`/api/orders/${id}/items/${itemId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ quantity }),
      });
      loadSheet();
    } catch (error) {
      console.error('Erro ao atualizar quantidade:', error);
    }
  };

  const handleUpdateObservation = async (itemId: number, observation: string) => {
    try {
      const item = sheet.items.find((i: any) => i.id === itemId);
      await fetch(`/api/orders/${id}/items/${itemId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ quantity: item.quantity, observation }),
      });
      loadSheet();
    } catch (error) {
      console.error('Erro ao atualizar observação:', error);
    }
  };

  const handleRemoveItem = async (itemId: number) => {
    if (!confirm('Remover este item?')) return;
    try {
      await fetch(`/api/orders/${id}/items/${itemId}`, {
        method: 'DELETE',
      });
      loadSheet();
    } catch (error) {
      console.error('Erro ao remover item:', error);
    }
  };

  const handleFinalize = async () => {
    if (!confirm('Finalizar esta ficha de pedido?')) return;
    try {
      const res = await fetch(`/api/orders/${id}/finalize`, {
        method: 'POST',
      });
      if (res.ok) {
        const data = await res.json();
        router.push(`/admin/receipts/${data.code}`);
      }
    } catch (error) {
      console.error('Erro ao finalizar:', error);
    }
  };

  if (loading || !sheet) {
    return <div className={styles.container}>Carregando...</div>;
  }

  const allItems = [...dishes, ...beverages];
  const filteredItems = allItems.filter((item: any) =>
    item.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      <Head>
        <title>Ficha de Pedido #{id} - Admin</title>
      </Head>
      <div className={styles.container}>
        <div className={styles.header}>
          <button onClick={() => router.push('/admin')}>← Voltar</button>
          <h1>Ficha de Pedido - Mesa {sheet.table_number}</h1>
        </div>

        <div className={styles.form}>
          <div className={styles.formGroup}>
            <label>Nome do Cliente</label>
            <input
              value={sheet.customer_name || ''}
              onChange={(e) => handleUpdateSheet('customer_name', e.target.value)}
              onBlur={(e) => handleUpdateSheet('customer_name', e.target.value)}
              placeholder="Nome do cliente"
            />
          </div>

          <div className={styles.formGroup}>
            <label>Número da Mesa</label>
            <input
              type="number"
              value={sheet.table_number}
              onChange={(e) => handleUpdateSheet('table_number', parseInt(e.target.value))}
              onBlur={(e) => handleUpdateSheet('table_number', parseInt(e.target.value))}
            />
          </div>

          <div className={styles.itemsSection}>
            <div className={styles.itemsHeader}>
              <h2>Itens</h2>
              <button onClick={() => setShowAddItem(!showAddItem)} className={styles.addButton}>
                + Adicionar Item
              </button>
            </div>

            {showAddItem && (
              <div className={styles.addItemPanel}>
                <input
                  type="text"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  placeholder="Buscar prato ou bebida..."
                  className={styles.searchInput}
                />
                <div className={styles.itemsList}>
                  {filteredItems.map((item: any) => (
                    <div
                      key={`${item.type}-${item.id}`}
                      className={styles.itemOption}
                      onClick={() => handleAddItem(item.type, item.id)}
                    >
                      {item.image_url && <img src={item.image_url} alt={item.name} />}
                      <div>
                        <h3>{item.name}</h3>
                        <p>R$ {item.price?.toFixed(2) || '0.00'}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className={styles.itemsList}>
              {sheet.items?.map((item: any) => (
                <div key={item.id} className={styles.orderItem}>
                  <div className={styles.itemInfo}>
                    <h3>{item.item_name}</h3>
                    {item.observation && <p className={styles.observation}>{item.observation}</p>}
                  </div>
                  <div className={styles.itemControls}>
                    <div className={styles.quantity}>
                      <button onClick={() => handleUpdateQuantity(item.id, Math.max(1, item.quantity - 1))}>
                        -
                      </button>
                      <span>{item.quantity}</span>
                      <button onClick={() => handleUpdateQuantity(item.id, item.quantity + 1)}>+</button>
                    </div>
                    <input
                      type="text"
                      value={item.observation || ''}
                      onChange={(e) => handleUpdateObservation(item.id, e.target.value)}
                      onBlur={(e) => handleUpdateObservation(item.id, e.target.value)}
                      placeholder="Observação..."
                      className={styles.observationInput}
                    />
                    <span className={styles.itemPrice}>R$ {item.total_price.toFixed(2)}</span>
                    <button onClick={() => handleRemoveItem(item.id)} className={styles.removeButton}>
                      ×
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <div className={styles.total}>
              <strong>Total: R$ {sheet.total?.toFixed(2) || '0.00'}</strong>
            </div>

            <button onClick={handleFinalize} className={styles.finalizeButton}>
              Finalizar Ficha de Pedido
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
