```text
 __  __       _ _   _           _   
|  \/  | ___ | | |_| |__   ___ | |_ 
| |\/| |/ _ \| | __| '_ \ / _ \| __|
| |  | | (_) | | |_| |_) | (_) | |_ 
|_|  |_|\___/|_|\__|_.__/ \___/ \__|
  ____            _        _                   
 / ___|___  _ __ | |_ __ _(_)_ __   ___ _ __ ___ 
| |   / _ \| '_ \| __/ _` | | '_ \ / _ \ '__/ __|
| |__| (_) | | | | || (_| | | | | |  __/ |  \__ \
 \____\___/|_| |_|\__\__,_|_|_| |_|\___|_|  |___/
                                                 
```

# Moltbot Docker Containers

**Professional Docker Compose templates for deploying [Moltbot](https://github.com/moltbot/moltbot) - the AI Agent System.**

This repository provides a production-ready stack designed for stability, security, and ease of use. It orchestrates the following services:
- **Moltbot**: The core AI agent runtime.
- **Caddy**: Automatic HTTPS, reverse proxy, and security headers.
- **PostgreSQL**: Robust persistent storage for agent memory.
- **Redis**: High-performance caching and message queuing.
- **Scripts**: Built-in utilities for health checks, automated backups, and disaster recovery.

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose (v2)
- Linux environment (Ubuntu, Debian, or **WSL2 on Windows**)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sarpound/moltbot-containers.git
   cd moltbot-containers
   ```

2. **Configure Environment**
   Copy the example environment file. This is where your secrets live—never commit the real `.env` file to Git!
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your preferred editor (e.g., `nano .env`):
   - Set `CLAWDBOT_GATEWAY_TOKEN` (Generate one: `openssl rand -hex 32`)
   - Set `POSTGRES_PASSWORD` to a strong password.
   - Configure AI Provider keys (Anthropic, Moonshot, etc.) if needed.

3. **Config file (required)**
   The app reads `/home/node/.moltbot/moltbot.json`. Copy the example so the container gets valid JSON (avoids "JSON5: invalid end of input" from an empty/corrupt file):
   ```bash
   cp moltbot.json.example moltbot.json
   ```
   Edit `moltbot.json` if you need to change gateway token, models, or channels. Do not commit `moltbot.json` (it is gitignored).

4. **Launch the Stack**
   ```bash
   docker compose up -d
   ```

5. **Verify Deployment**
   ```bash
   ./scripts/healthcheck.sh
   ```

---

## ❓ Troubleshooting & Common Issues (Problem vs. Solution)

We've designed this section to pair common problems with their exact solutions.

| 🔴 **The Problem** | 🟢 **The Solution** |
| :--- | :--- |
| **"I can't access `https://localhost`"**<br>Browser says "Your connection is not private" or "Warning: Potential Security Risk". | **This is expected behavior.**<br>We use self-signed certificates for local development. You must manually click **"Advanced"** → **"Proceed to localhost (unsafe)"** in your browser. For production, set a real domain in `Caddyfile` to get a valid Let's Encrypt certificate. |
| **"Scripts fail with `permission denied`"**<br>Running `./scripts/healthcheck.sh` gives an error. | **The files need execution rights.**<br>Linux security requires scripts to be explicitly executable. Run this command once:<br>`chmod +x scripts/*.sh` |
| **"Database connection refused"**<br>Moltbot logs show it cannot connect to Postgres on `localhost`. | **Don't use `localhost` inside containers.**<br>In Docker, `localhost` refers to *that specific container*. To talk to the database, use the service name defined in compose: **`postgres`**. (e.g., `POSTGRES_HOST=postgres`). |
| **"I'm on Windows and volumes are empty"**<br>Files aren't saving, or permission errors occur on mounts. | **Use WSL2 properly.**<br>Do **not** run this from Windows PowerShell/CMD in a path like `C:\Users\...`.<br>1. Open your WSL terminal (Ubuntu).<br>2. Move the project to the Linux filesystem (e.g., `cd ~ && git clone ...`).<br>3. Run Docker commands from there. |
| **"Changes to `.env` aren't applying"**<br>I changed the password/token, but the app still uses the old one. | **Containers need to be recreated.**<br>`docker compose restart` is often not enough for environment variables. Use:<br>`docker compose up -d --force-recreate` |

---

## 📂 Directory Structure

```
.
├── compose.yml            # Main Docker Compose stack definition
├── Caddyfile             # Web server configuration (HTTPS/Proxy)
├── .env                  # Secrets and configuration (Not committed)
├── data/                 # Persistent data storage (Postgres/Redis)
├── backup/               # Database backups
├── scripts/              # Management utilities
│   ├── healthcheck.sh    # Service status checker
│   ├── backup_postgres.sh # Database backup script
│   └── restore_postgres.sh # Database restoration script
└── templates/            # Agent identity and behavior templates
```

## 🛠️ Management

### Accessing the Interface
- **URL**: `https://localhost` (or your server IP)
- **Setup**: Enter your `CLAWDBOT_GATEWAY_TOKEN` (from `.env`) in the Settings panel.

### Backups
Run the backup script to create a gzipped SQL dump in the `backup/` directory.
```bash
./scripts/backup_postgres.sh
```
*Tip: Add this to your crontab for daily backups.*

### Restoration
To restore from a backup file (use with caution, overwrites current DB):
```bash
./scripts/restore_postgres.sh backup/postgres-moltbot-YYYYMMDD-HHMMSS.sql.gz
```

### Updates
Pull the latest images and restart the services:
```bash
docker compose pull
docker compose up -d
```

## 🔒 Security Best Practices

- **Never commit `.env`**: This file contains sensitive keys.
- **Change Default Passwords**: Always update `POSTGRES_PASSWORD` and `CLAWDBOT_GATEWAY_TOKEN`.
- **Firewall**: Ensure only ports 80/443 are exposed to the internet. Database ports should remain internal.

## 📄 License

This project is open-source. Please refer to the [Moltbot](https://github.com/moltbot/moltbot) repository for core software licensing.
