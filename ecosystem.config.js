module.exports = {
  apps: [
    {
      name: 'cardapio-3007',
      script: 'server.js',
      cwd: '/root/cardapio',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3007,
        HOST: '0.0.0.0'
      },
      error_file: '/root/cardapio/logs/pm2-error.log',
      out_file: '/root/cardapio/logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    }
  ]
};

