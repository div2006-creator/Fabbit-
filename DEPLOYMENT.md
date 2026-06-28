# Fabbit Production Deployment Guide

This guide details the steps required to deploy the **Fabbit** Next.js application to a production Linux server (e.g. Ubuntu LTS).

---

## 1. Environment Variables Configuration Checklist

Create a `.env` file in the project root containing your production configurations:

```env
# Database Settings
DATABASE_URL="file:./dev.db" # Or use Postgres connection string

# JWT Secret Token
JWT_SECRET="generate-a-secure-random-hash-key-here"

# Razorpay API Credentials
RAZORPAY_KEY_ID="rzp_live_your_live_key_id"
RAZORPAY_KEY_SECRET="your_live_key_secret"
RAZORPAY_WEBHOOK_SECRET="your_custom_webhook_secret_phrase"

# Google OAuth 2.0 Credentials
GOOGLE_CLIENT_ID="your_google_oauth_client_id.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="your_google_oauth_client_secret"
GOOGLE_REDIRECT_URI="https://fabbit.org/api/auth/google/callback"
```

---

## 2. Option A: Containerized Deployment (Docker & Compose)

Using Docker is highly recommended to guarantee dependency sandboxing.

### Step 1: Install Docker
Run these commands on your VPS:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose
```

### Step 2: Build and Launch Containers
Navigate to the repository folder and execute:
```bash
# Build the Docker image and start the container in detached (background) mode
docker-compose up -d --build
```
The application will boot up and bind to port `3000`. Persistent database storage is automatically mapped inside a named Docker volume (`sqlite-data`) so your inventory database survives restarts.

---

## 3. Option B: Local PM2 Node Cluster Deployment

For hosting providers not supporting Docker containers, PM2 clustering is the ideal option to scale across multiple CPU cores.

### Step 1: Install Node.js, PM2, and Project Packages
```bash
# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2 globally
sudo npm install -y pm2 -g

# Install project packages
npm ci
```

### Step 2: Build Code and Generate Client
```bash
# Generate Prisma bindings matching SQLite/Postgres schemas
npx prisma generate

# Compile production-optimized pages
npm run build
```

### Step 3: Startup the PM2 Cluster
Launch the application using the ecosystem process file:
```bash
pm2 start ecosystem.config.js
```
Save the process list to load automatically on server reboots:
```bash
pm2 save
pm2 startup
```

---

## 4. Nginx Reverse Proxy Setup (with HTTPS/SSL)

Nginx is used to reverse proxy external web requests to port `3000` with static caching, rate limits, gzip compression, and security headers.

### Step 1: Install Nginx
```bash
sudo apt install -y nginx
```

### Step 2: Apply the Server Config block
1. Copy the contents of the local `nginx.conf` file.
2. Edit `/etc/nginx/sites-available/fabbit`:
   ```bash
   sudo nano /etc/nginx/sites-available/fabbit
   ```
3. Paste the contents, update `fabbit.org` with your domain, and save.
4. Enable the config block and reload Nginx:
   ```bash
   sudo ln -s /etc/nginx/sites-available/fabbit /etc/nginx/sites-enabled/
   sudo rm /etc/nginx/sites-enabled/default
   sudo nginx -t # Verify syntax is correct
   sudo systemctl restart nginx
   ```

### Step 3: Install SSL/HTTPS Certificates via Certbot (Let's Encrypt)
Configure automatic certificate issuing and renewals:
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d fabbit.org -d www.fabbit.org
```
This utility automatically modifies your `/etc/nginx/sites-available/fabbit` file, installs valid certificate parameters, and restarts Nginx.

---

## 5. Automated Daily Database Backups

Ensure database protection by backing up copy-dumps daily.

### Step 1: Register Cron Job
1. Grant execution rights to the script:
   ```bash
   chmod +x backup.sh
   ```
2. Open crontab schedules editor:
   ```bash
   crontab -e
   ```
3. Add this line at the bottom to trigger database backups daily at 2:00 AM:
   ```bash
   0 2 * * * /bin/sh /var/www/fabbit/backup.sh >> /var/log/fabbit-backup.log 2>&1
   ```

---

## 6. Logging Verification & Monitoring

*   **Docker Logs**: Run `docker logs fabbit-web -f`
*   **PM2 Logs**: Run `pm2 logs` or view `./logs/pm2-error.log`
*   **Nginx Logs**: Access log at `/var/log/nginx/access.log`, errors at `/var/log/nginx/error.log`
