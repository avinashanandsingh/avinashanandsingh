module.exports = {
  apps: [
    {
      name: "redis-server",
      script: "redis-server", // The command to start Redis
      args: "--port 6379", // Optional arguments for Redis
      exec_mode: "fork", // Redis typically runs as a single process
      instances: 1,
      autorestart: true,
      watch: false, // Don't watch for file changes in a production Redis container
      max_memory_restart: "1G", // Restart if memory usage exceeds 1GB
      env: {
        NODE_ENV: "production",
      },
    },
    {
      name: "api",
      script: "./src/app.js",
      port: 8001,
    },    
  ],
};
