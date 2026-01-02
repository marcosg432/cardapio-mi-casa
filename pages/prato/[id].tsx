import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Head from 'next/head';
import Link from 'next/link';
import styles from '@/styles/Prato.module.css';

interface Dish {
  id: number;
  name: string;
  mini_presentation: string;
  full_description: string;
  image_url: string;
  category_name: string;
}

export default function PratoPage() {
  const router = useRouter();
  const { id } = router.query;
  const [dish, setDish] = useState<Dish | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      loadDish();
    }
    
    // Desabilitar scroll na página
    document.body.style.overflow = 'hidden';
    document.documentElement.style.overflow = 'hidden';
    
    // Limpar quando sair da página
    return () => {
      document.body.style.overflow = '';
      document.documentElement.style.overflow = '';
    };
  }, [id]);

  const loadDish = async () => {
    try {
      const res = await fetch(`/api/dishes/${id}`);
      if (res.ok) {
        const data = await res.json();
        setDish(data);
      }
    } catch (error) {
      console.error('Erro ao carregar prato:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className={styles.container}>
        <div className={styles.loading}>Carregando...</div>
      </div>
    );
  }

  if (!dish) {
    return (
      <div className={styles.container}>
        <div className={styles.error}>Prato não encontrado</div>
        <Link href="/">
          <button className={styles.backButton}>Voltar ao Cardápio</button>
        </Link>
      </div>
    );
  }

  return (
    <>
      <Head>
        <title>{dish.name} - Cardápio</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
      </Head>
      <div className={styles.container}>
        <Link href="/" className={styles.backLink}>
          ← Voltar
        </Link>
        <img src="/logos/mi casa.png" alt="Mi Casa" className={styles.logo} />

        <div className={styles.section}>
          {dish.image_url && (
            <div className={styles.imageContainer}>
              <img src={dish.image_url} alt={dish.name} />
            </div>
          )}

          <div className={styles.content}>
            <h1 className={styles.dishTitle}>{dish.name}</h1>
            <p className={styles.description}>
              {(() => {
                const description = dish.full_description || dish.mini_presentation || '';
                // Limite de 400 caracteres para garantir espaço de segurança
                const maxLength = 400;
                if (description.length > maxLength) {
                  return description.substring(0, maxLength).trim() + '...';
                }
                return description;
              })()}
            </p>
          </div>
        </div>
      </div>
    </>
  );
}


