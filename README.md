# Quantum Chat Platform

Welcome to **Quantum Chat**, a secure, decentralized, web3-ready chat platform built for the next-gen RPG guild experience! Powered by Rust, Tauri, PostgreSQL, and Node.js, this app delivers quantum-encrypted communication for your web, mobile, and desktop adventures. Whether you're a bug bounty hunter securing the backend or a game dev crafting epic RPGs, this README guides you through setup, configuration, and deployment with zero exploits. Let's build your empire! 🚀

## Prerequisites

Before diving into the quantum realm, ensure you have the following tools installed:

- **Rust**: Version 1.89.0 or higher (`rustc --version`)
  - Install via: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Node.js**: Version 18 or higher (`node -v`)
  - Install via nvm: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && nvm install 18`
- **PostgreSQL**: Version 17.5 or higher (`psql --version`)
  - Install on Debian/Ubuntu: `sudo apt update && sudo apt install -y postgresql postgresql-contrib`
- **bc**: For progress bar calculations
  - Install: `sudo apt install bc`
- **Development Tools**:
  - `cargo-watch`: `cargo install cargo-watch`
  - `sqlx-cli`: `cargo install sqlx-cli --no-default-features --features postgres,rustls`
  - `tauri-cli`: `cargo install tauri-cli`
- **Redis**: For session management
  - Install: `sudo apt install redis-server`
- **OpenSSL**: For generating JWT secrets
  - Install: `sudo apt install openssl`

Ensure you're running as a non-root user (e.g., `wimlee`) with `sudo` privileges for system-level operations.

## Project Structure

```
quantum-chat-platform/
├── backend/                    # Rust backend with Axum and SQLx
│   ├── migrations/             # PostgreSQL migration files
│   ├── src/                    # Backend source code
│   └── .env                    # Environment variables (DATABASE_URL, REDIS_URL, JWT_SECRET)
├── frontend/
│   ├── web/                    # Web frontend (Vite + React)
│   ├── mobile/                 # Mobile app (React Native + Expo)
│   └── desktop/                # Desktop app (Tauri)
├── start_and_test.sh           # Setup and test script
└── README.md                   # This file
```

## Setup Instructions

Follow these steps to set up and run Quantum Chat like a pro bug bounty hunter securing a smart contract!

### 1. Clone the Repository

```bash
git clone https://github.com/WimLee115/quantum-chat-platform.git
cd quantum-chat-platform
```

### 2. Set Up Environment

Copy the provided `start_and_test.sh` script into the project root and make it executable:

```bash
chmod +x start_and_test.sh
```

This script automates dependency installation, environment setup, database initialization, migrations, and server startup. It supports English (`en`) and Dutch (`nl`) prompts.

### 3. Configure PostgreSQL

Ensure PostgreSQL is running and accessible via Unix socket (`/var/run/postgresql/.s.PGSQL.5432`):

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

Verify the socket exists:

```bash
ls -l /var/run/postgresql/.s.PGSQL.5432
```

Expected output:
```
srwxrwxrwx 1 postgres postgres 0 ... /var/run/postgresql/.s.PGSQL.5432
```

If the socket is in `/tmp`, update `backend/.env` later. Configure `pg_hba.conf` for trust authentication (development only):

```bash
sudo nano /etc/postgresql/17/main/pg_hba.conf
```

Add at the top:
```
local   all   wimlee   trust
local   all   postgres trust
host    all   wimlee   127.0.0.1/32   trust
host    all   postgres 127.0.0.1/32   trust
```

Restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

### 4. Run the Setup Script

Execute the setup script:

```bash
./start_and_test.sh
```

- **Language Choice**: Select `en` (English) or `nl` (Dutch).
- **Sudo Prompts**: The script may request `sudo` for installing packages, fixing permissions, or updating PostgreSQL configs.
- **Output**: Check `start_test_debug.log` for detailed logs.

The script will:
- Install dependencies (`bc`, Rust, Node.js, PostgreSQL, dev tools).
- Create and configure `backend/.env` with:
  - `DATABASE_URL=postgres://wimlee@/var/run/postgresql:5432/quantum_chat`
  - `REDIS_URL=redis://localhost:6379`
  - `JWT_SECRET=<randomly generated>`
- Initialize the `quantum_chat` database.
- Apply migrations (`create_users`, `create_quantum_keys`, `create_invitations`, `create_chats`, `streaming_features`).
- Start servers (backend, web, mobile, desktop).
- Run tests.

### 5. Verify Database Setup

Check if the database and migrations are applied:

```bash
psql -U wimlee -h /var/run/postgresql -d quantum_chat -c "SELECT * FROM _sqlx_migrations;"
```

List tables:
```bash
psql -U wimlee -h /var/run/postgresql -d quantum_chat -c "\dt"
```

Expected tables:
- `users`
- `quantum_keys`
- `invitations`
- `chats`

### 6. Access the App

Once the script completes, the servers will be running:
- **Backend**: `http://localhost:8080`
- **Web Frontend**: `http://localhost:5173` (Vite)
- **Mobile**: Via Expo (scan QR code from `npm run start` in `frontend/mobile`)
- **Desktop**: Tauri app (launched via `cargo tauri dev` in `frontend/desktop`)

### 7. Troubleshooting

If the script fails, check `start_test_debug.log`:

```bash
cat start_test_debug.log
```

Common issues and fixes:
- **Directory Not Found**:
  ```bash
  mkdir -p backend/migrations
  sudo chown -R wimlee:wimlee backend
  sudo chmod -R u+rw backend
  ```
- **PostgreSQL Connection**:
  Test Unix socket:
  ```bash
  psql -U wimlee -h /var/run/postgresql -d quantum_chat -c "SELECT 1;"
  ```
  Test TCP fallback:
  ```bash
  psql -U wimlee -h localhost -d quantum_chat -c "SELECT 1;"
  ```
  Update `backend/.env` if socket is in `/tmp`:
  ```bash
  echo "DATABASE_URL=postgres://wimlee@/tmp:5432/quantum_chat" > backend/.env
  ```
- **Migration Errors**:
  Run migrations manually:
  ```bash
  cd backend
  sqlx migrate run --database-url postgres://wimlee@/var/run/postgresql:5432/quantum_chat --host /var/run/postgresql
  ```
  Check migration files:
  ```bash
  ls -l backend/migrations/
  cat backend/migrations/*.sql
  ```
- **SQLx Issues**:
  Update `sqlx-cli`:
  ```bash
  cargo install sqlx-cli --no-default-features --features postgres,rustls --force
  ```

If issues persist, share:
- `pwd`
- `ls -ld backend backend/migrations`
- `ls -l backend/migrations/`
- `cat backend/.env`
- `cat backend/migrations/*.sql`
- `sudo cat /etc/postgresql/17/main/pg_hba.conf`
- `tail -n 50 start_test_debug.log`

## Security Notes

- **Development**: Uses `trust` authentication in `pg_hba.conf` for simplicity. For production, switch to `md5`:
  ```
  host    all   wimlee   127.0.0.1/32   md5
  ```
- **.env**: Contains sensitive data (`JWT_SECRET`). Ensure `chmod 600 backend/.env`.
- **Input Sanitization**: The setup script sanitizes inputs to prevent injection attacks.
- **Permissions**: Backend and migration directories are set to `u+rw` for `wimlee`.

## Contributing

Found a bug? Squash it like a true bounty hunter! Submit issues or PRs to the repository. For web3 RPG features (e.g., NFT-based chat roles, blockchain key storage), ping the guild on Discord or X.

## License

MIT License – free to use, modify, and distribute. Build your quantum empire! 🌌

---

**WimLee115's Quantum Chat Platform**  
*Hunt bugs, secure the chain, and chat like a web3 legend!*  
🥳 wimfree!!!! 🥳  
🎆 🎇 🎆 🎇 🎆
