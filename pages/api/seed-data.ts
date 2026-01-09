import type { NextApiRequest, NextApiResponse } from 'next';
import { run, query } from '@/lib/db';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método não permitido' });
  }

  try {
    // Verificar se já existem pratos cadastrados
    const existingDishes = await query('SELECT COUNT(*) as count FROM dishes WHERE status = "active"');
    const force = req.body?.force === true;
    
    if (existingDishes[0]?.count > 0 && !force) {
      return res.status(200).json({ 
        success: true, 
        message: `Já existem ${existingDishes[0].count} pratos cadastrados no banco de dados. Use force=true para sobrescrever.`,
        count: existingDishes[0].count 
      });
    }
    
    // Se force=true, limpar pratos e bebidas existentes primeiro
    if (force) {
      await run('DELETE FROM dishes WHERE status = "active"');
      await run('DELETE FROM beverages WHERE status = "active"');
    }

    // Cadastrar pratos (dados reais do banco local)
    const dishes = [
      {
        name: 'Strogonoff de Frango',
        mini_presentation: 'Cubos de frango macios preparados em um molho cremoso e bem temperado, criando um prato clássico, reconfortante e cheio de sabor, ideal para qualquer momento do dia.',
        full_description: 'Nosso strogonoff de frango é preparado com cubos selecionados, cozidos no ponto certo para garantir maciez e suculência.\nO molho cremoso, feito com temperos equilibrados, envolve o frango de forma perfeita, trazendo um sabor marcante e agradável.\n\nÉ uma refeição completa, muito apreciada por quem busca conforto, tradição e qualidade em um único prato.',
        image_url: 'https://i.pinimg.com/736x/45/00/16/45001605a4861cd5f0b7dc9f8335ed7d.jpg',
        price: 29.9,
        display_order: 1,
      },
      {
        name: 'Carne de Panela',
        mini_presentation: 'Carne cozida lentamente com temperos especiais, resultando em uma textura extremamente macia e um sabor encorpado que remete à comida caseira tradicional.',
        full_description: 'A carne de panela é preparada em cozimento lento, permitindo que os temperos sejam absorvidos por completo, garantindo um prato macio, suculento e cheio de sabor.\nO molho encorpado complementa a carne, tornando cada porção ainda mais saborosa.\n\nUma opção ideal para quem aprecia pratos tradicionais, bem servidos e feitos com cuidado.',
        image_url: 'https://i.pinimg.com/1200x/09/36/9e/09369e9a2a2f399fb4bb554fe015cc77.jpg',
        price: 26.89,
        display_order: 2,
      },
      {
        name: 'Bife Acebolado',
        mini_presentation: 'Bife grelhado no ponto certo, acompanhado de cebolas douradas que realçam o sabor da carne e trazem equilíbrio ao prato.',
        full_description: 'O bife acebolado é preparado com carne selecionada, grelhada cuidadosamente para manter maciez e suculência.\nAs cebolas são douradas lentamente, criando um contraste perfeito entre sabor e textura.\n\nUm prato simples, clássico e muito apreciado, ideal para quem valoriza uma refeição tradicional e saborosa.',
        image_url: 'https://i.pinimg.com/736x/8f/43/9b/8f439be0201289d3a71c721b70b7dcf5.jpg',
        price: 21.9,
        display_order: 3,
      },
      {
        name: 'Filé de Frango Grelhado',
        mini_presentation: 'Filé de frango grelhado com temperos suaves, preparado para manter suculência, leveza e um sabor equilibrado.',
        full_description: 'O filé de frango grelhado é preparado com cuidado, utilizando temperos leves que valorizam o sabor natural da carne.\nGrelhado no ponto certo, mantém sua suculência e textura macia.\n\nUma excelente opção para quem busca uma refeição leve, nutritiva e cheia de sabor.',
        image_url: 'https://i.pinimg.com/736x/a2/a2/98/a2a29874a5cb5e017417869a9b8d10d7.jpg',
        price: 23.99,
        display_order: 4,
      },
      {
        name: 'Feijoada Tradicional',
        mini_presentation: 'Feijoada preparada com feijão selecionado, carnes bem temperadas e cozimento lento, resultando em um prato encorpado, saboroso e muito tradicional da culinária brasileira.',
        full_description: 'Nossa feijoada tradicional é preparada com feijão de qualidade e carnes selecionadas, cozidas lentamente para garantir sabor intenso e textura perfeita.\nOs temperos são equilibrados para criar um prato encorpado, aromático e extremamente saboroso.\n\nUma refeição completa e marcante, ideal para quem aprecia pratos tradicionais e bem servidos.',
        image_url: 'https://i.pinimg.com/1200x/14/60/22/1460227cac1ed227355e0818af6b1226.jpg',
        price: 22,
        display_order: 5,
      },
      {
        name: 'Frango à Parmegiana',
        mini_presentation: 'Frango empanado, coberto com molho especial e queijo derretido, criando um prato encorpado, saboroso e irresistível.',
        full_description: 'O frango à parmegiana é empanado com cuidado, garantindo crocância por fora e maciez por dentro.\nCoberto com molho especial e queijo derretido, o prato traz uma combinação intensa de sabores.\n\nUma escolha perfeita para quem aprecia refeições bem servidas e cheias de personalidade.',
        image_url: 'https://i.pinimg.com/1200x/5c/ed/c8/5cedc88b226db0604b587ebd2d4bea6e.jpg',
        price: 19.9,
        display_order: 6,
      },
    ];

    // Cadastrar bebidas (dados reais do banco local)
    const beverages = [
      {
        name: 'coca',
        description: '',
        image_url: 'https://i.pinimg.com/736x/d9/90/b4/d990b4e3fafb7073f2ab7241e48aea0b.jpg',
        price: 9.99,
        display_order: 1,
      },
      {
        name: 'Suco de laranja natural',
        description: '',
        image_url: 'https://i.pinimg.com/1200x/3c/f4/93/3cf4934a1808a643e4ae617d4df470fc.jpg',
        price: 10,
        display_order: 2,
      },
      {
        name: 'agua sem gás ',
        description: '',
        image_url: 'https://i.pinimg.com/736x/da/ab/52/daab522863d80eb4b8df524736bfc1a4.jpg',
        price: 5,
        display_order: 3,
      },
      {
        name: 'agua com gás',
        description: '',
        image_url: 'https://i.pinimg.com/1200x/2b/df/ee/2bdfee219e4ba6f493832cb2f81b5311.jpg',
        price: 5,
        display_order: 4,
      },
      {
        name: 'Suco Natural de Maracujá',
        description: '',
        image_url: 'https://i.pinimg.com/736x/68/b7/aa/68b7aa219f1e77c16a069774cfe2b79c.jpg',
        price: 8,
        display_order: 5,
      },
    ];

    // Inserir pratos
    for (const dish of dishes) {
      await run(
        `INSERT INTO dishes (name, mini_presentation, full_description, image_url, price, display_order, status)
         VALUES (?, ?, ?, ?, ?, ?, 'active')`,
        [
          dish.name,
          dish.mini_presentation,
          dish.full_description,
          dish.image_url,
          dish.price,
          dish.display_order,
        ]
      );
    }

    // Inserir bebidas
    for (const beverage of beverages) {
      await run(
        `INSERT INTO beverages (name, description, image_url, price, display_order, status)
         VALUES (?, ?, ?, ?, ?, 'active')`,
        [
          beverage.name,
          beverage.description,
          beverage.image_url,
          beverage.price,
          beverage.display_order,
        ]
      );
    }

    return res.status(200).json({
      success: true,
      message: `Cadastrados ${dishes.length} pratos e ${beverages.length} bebidas com sucesso!`,
      dishes: dishes.length,
      beverages: beverages.length,
    });
  } catch (error: any) {
    console.error('Erro ao cadastrar dados:', error);
    return res.status(500).json({
      error: 'Erro ao cadastrar dados',
      details: error.message,
    });
  }
}

