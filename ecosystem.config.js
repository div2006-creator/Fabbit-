module.exports = {
  apps: [
    {
      name: 'fabbit-web',
      script: 'node_modules/next/dist/bin/next',
      args: 'start',
      instances: 'max', // utilizes all available CPU cores for clustering
      exec_mode: 'cluster', // cluster mode for load balancing
      autorestart: true, // auto restart on crashes
      watch: false,
      max_memory_restart: '1G', // restart if memory exceeds 1GB
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      // Logs configuration
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-access.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    }
  ]
};
