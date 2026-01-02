import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import styles from '@/styles/Receipt.module.css';

export default function ReceiptView() {
  const router = useRouter();
  const { code } = router.query;
  const [receipt, setReceipt] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (code) {
      loadReceipt();
    }
  }, [code]);

  const loadReceipt = async () => {
    try {
      const res = await fetch(`/api/receipts/${code}`);
      if (res.ok) {
        const data = await res.json();
        setReceipt(data);
      }
    } catch (error) {
      console.error('Erro ao carregar via:', error);
    } finally {
      setLoading(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const handleWhatsApp = () => {
    const itemsText = receipt.items.map((item: any) => 
      `${item.quantity}x ${item.item_name}${item.observation ? ` (${item.observation})` : ''} - R$ ${item.total_price.toFixed(2)}`
    ).join('\n');

    const message = `*VIA DO PEDIDO*\n\n` +
      `Código: ${receipt.code}\n` +
      `Mesa: ${receipt.table_number}\n` +
      `Cliente: ${receipt.customer_name || 'Não informado'}\n` +
      `\n*ITENS:*\n${itemsText}\n\n` +
      `*TOTAL: R$ ${receipt.total.toFixed(2)}*`;

    const url = `https://wa.me/?text=${encodeURIComponent(message)}`;
    window.open(url, '_blank');
  };

  if (loading || !receipt) {
    return <div className={styles.container}>Carregando...</div>;
  }

  return (
    <>
      <Head>
        <title>Via #{receipt.code} - Admin</title>
      </Head>
      <div className={styles.container}>
        <div className={styles.header}>
          <button onClick={() => router.push('/admin')}>← Voltar</button>
          <h1>Via do Pedido</h1>
        </div>

        <div className={styles.receipt}>
          <div className={styles.receiptHeader}>
            <h2>VIA DO PEDIDO</h2>
            <p className={styles.code}>Código: {receipt.code}</p>
          </div>

          <div className={styles.receiptInfo}>
            <p><strong>Mesa:</strong> {receipt.table_number}</p>
            <p><strong>Cliente:</strong> {receipt.customer_name || 'Não informado'}</p>
          </div>

          <div className={styles.items}>
            <h3>Itens</h3>
            <table className={styles.itemsTable}>
              <thead>
                <tr>
                  <th>Item</th>
                  <th>Qtd</th>
                  <th>Valor</th>
                </tr>
              </thead>
              <tbody>
                {receipt.items.map((item: any, index: number) => (
                  <tr key={index}>
                    <td>
                      {item.item_name}
                      {item.observation && (
                        <span className={styles.observation}> ({item.observation})</span>
                      )}
                    </td>
                    <td>{item.quantity}</td>
                    <td>R$ {item.total_price.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className={styles.total}>
            <strong>TOTAL: R$ {receipt.total.toFixed(2)}</strong>
          </div>

          <div className={styles.actions}>
            <button onClick={handleWhatsApp} className={styles.whatsappButton}>
              Enviar via WhatsApp
            </button>
            <button onClick={handlePrint} className={styles.printButton}>
              Imprimir
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
