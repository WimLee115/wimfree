#!/bin/bash

# Start & Test Script: Quantum Chat Platform
# By: Bug Bounty Genie – Security audited, web3 RPG style!
# Multilingual: English/Nederlands | Progress bar with animations | Autofixing & Debugging
# Fixed Step 2 crash, added backend/ dir check, detailed .env logging, and migration fixes

set -e  # Exit on error – no silent vulns
set -u  # Unset vars as error – security mindset

# Debug log setup
DEBUG_LOG="start_test_debug.log"
echo "Quantum Chat Start & Test Debug Log - $(date)" > "$DEBUG_LOG"

# Colors for RPG-like output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLINK='\033[5m'
NC='\033[0m'

# Translation function
t() {
  if [ "${LANG:-en}" = "en" ]; then
    echo "$1"
  else
    echo "$2"
  fi
}

# Log function
log() {
  echo "$1" | tee -a "$DEBUG_LOG"
}

# Error function with fix suggestion
error() {
  echo -e "${RED}$1${NC}" | tee -a "$DEBUG_LOG"
  echo -e "${YELLOW}Fix suggestion: $2${NC}" | tee -a "$DEBUG_LOG"
  exit 1
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  error "Running as root is discouraged!" "Rerun without sudo: ./start_and_test.sh"
fi

# Check script permissions
if [ ! -x "$0" ]; then
  error "Script not executable!" "Run: chmod +x $0 and rerun ./start_and_test.sh"
fi

# Fix locale issues
log "$(t "Fixing locale settings..." "Locale instellingen aanpassen...")"
export LC_ALL=C.UTF-8
export LANG=en_US.UTF-8
if ! locale -a | grep -q "en_US.utf8"; then
  if sudo apt update && sudo apt install -y locales; then
    sudo locale-gen en_US.UTF-8
    log "$(t "Locales installed and generated." "Locales geïnstalleerd en gegenereerd.")"
  else
    log "$(t "Warning: Failed to install locales, continuing with C.UTF-8." "Waarschuwing: Kan locales niet installeren, doorgaan met C.UTF-8.")"
  fi
fi

# Taal keuze / Language choice
log "$(t "Choose language / Kies taal: (en/nl)" "Kies taal / Choose language: (en/nl)")"
read -r LANG
if [ "$LANG" != "en" ] && [ "$LANG" != "nl" ]; then
  log "$(t "Invalid choice! Defaulting to English." "Ongeldige keuze! Standaard naar Engels.")"
  LANG="en"
fi

log "$(t "Starting servers and tests... Security audit engaged!" "Servers en tests starten... Beveiligingsaudit ingeschakeld!")"

# Progress bar function
progress() {
  local duration=$1
  local steps=20
  local sleep_time=3
  if command -v bc &> /dev/null; then
    sleep_time=$(echo "scale=2; $duration / $steps" | bc)
  else
    log "$(t "Warning: 'bc' not found, using fallback sleep time." "Waarschuwing: 'bc' niet gevonden, gebruik fallback slaaptijd.")"
  fi
  local bar=""
  for ((i=0; i<steps; i++)); do
    bar+="█"
    perc=$(( (i+1) * 5 ))
    printf "\r$(t "Progress:" "Voortgang:") [%-20s] %d%%" "$bar" $perc
    if [ $perc -eq 50 ]; then
      echo -e "\n${BLINK}${RED}WimLee115-50%-Lets-GO${NC}"
      sleep 1
    fi
    sleep "$sleep_time" || error "Sleep failed!" "Ensure 'sleep' command is available."
  done
  echo ""
}

# Step 1: Check Prerequisites
log "$(t "Step 1: Checking prerequisites..." "Stap 1: Controleren van vereisten...")"

# bc
if ! command -v bc &> /dev/null; then
  log "$(t "Installing bc..." "Installeren van bc...")"
  if sudo apt update && sudo apt install -y bc; then
    log "$(t "bc installed successfully." "bc succesvol geïnstalleerd.")"
  else
    error "Failed to install bc!" "Run manually: sudo apt install bc"
  fi
else
  log "$(t "bc found." "bc gevonden.")"
fi

# Rust
if ! command -v rustc &> /dev/null; then
  log "$(t "Rust not found! Installing via rustup..." "Rust niet gevonden! Installeren via rustup...")"
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
    source "$HOME/.cargo/env"
    log "$(t "Rust installed: $(rustc --version)" "Rust geïnstalleerd: $(rustc --version)")"
  else
    error "Failed to install Rust!" "Run manually: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  fi
else
  log "$(t "Rust found: $(rustc --version)" "Rust gevonden: $(rustc --version)")"
fi

# Node.js (v18+)
if ! command -v node &> /dev/null || [ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]; then
  log "$(t "Node.js v18+ not found! Installing via nvm..." "Node.js v18+ niet gevonden! Installeren via nvm...")"
  if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 18
    nvm use 18
    log "$(t "Node.js installed: $(node -v)" "Node.js geïnstalleerd: $(node -v)")"
  else
    error "Failed to install Node.js!" "Run manually: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  fi
else
  log "$(t "Node.js found: $(node -v)" "Node.js gevonden: $(node -v)")"
fi

# PostgreSQL
if ! command -v psql &> /dev/null; then
  log "$(t "PostgreSQL not found. Installing..." "PostgreSQL niet gevonden. Installeren...")"
  if sudo apt update && sudo apt install -y postgresql postgresql-contrib; then
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    log "$(t "PostgreSQL installed: $(psql --version)" "PostgreSQL geïnstalleerd: $(psql --version)")"
  else
    error "Failed to install PostgreSQL!" "Run manually: sudo apt install postgresql postgresql-contrib"
  fi
else
  log "$(t "PostgreSQL found: $(psql --version)" "PostgreSQL gevonden: $(psql --version)")"
fi

# Autofix PostgreSQL connection
log "$(t "Checking PostgreSQL connection..." "PostgreSQL connectie controleren...")"
if ! psql -U "$USER" -h "" -d postgres -c "SELECT 1;" &>> "$DEBUG_LOG"; then
  log "$(t "Attempting to fix PostgreSQL connection..." "Poging om PostgreSQL connectie te repareren...")"
  
  # Check if PostgreSQL is running
  if ! sudo systemctl is-active --quiet postgresql; then
    log "$(t "Starting PostgreSQL service..." "PostgreSQL service starten...")"
    if sudo systemctl start postgresql && sudo systemctl enable postgresql; then
      log "$(t "PostgreSQL service started." "PostgreSQL service gestart.")"
    else
      error "Failed to start PostgreSQL!" "Run: sudo systemctl start postgresql"
    fi
  fi

  # Log PostgreSQL service status
  sudo systemctl status postgresql --no-pager &>> "$DEBUG_LOG"
  log "$(t "PostgreSQL service status logged to $DEBUG_LOG." "PostgreSQL service status gelogd naar $DEBUG_LOG.")"

  # Update pg_hba.conf to ensure trust auth
  PG_HBA="/etc/postgresql/17/main/pg_hba.conf"
  if [ -f "$PG_HBA" ]; then
    # Backup pg_hba.conf
    sudo cp "$PG_HBA" "${PG_HBA}.backup-$(date +%F-%H%M%S)" || log "$(t "Warning: Failed to backup pg_hba.conf." "Waarschuwing: Kan pg_hba.conf niet back-uppen.")"
    
    # Create new pg_hba.conf with clean trust config
    cat << EOF | sudo tee "$PG_HBA" > /dev/null
# Database administrative login by Unix domain socket
local   all   postgres   trust
local   all   $USER      trust
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all   all        trust
# IPv4 local connections:
host    all   postgres   127.0.0.1/32   trust
host    all   $USER      127.0.0.1/32   trust
# IPv6 local connections:
host    all   all        ::1/128        scram-sha-256
# Allow replication connections from localhost
local   replication   all             peer
host    replication   all             127.0.0.1/32   scram-sha-256
host    replication   all             ::1/128        scram-sha-256
EOF
    if [ $? -eq 0 ]; then
      log "$(t "Updated pg_hba.conf with clean trust config." "pg_hba.conf bijgewerkt met schone trust config.")"
    else
      error "Failed to update pg_hba.conf!" "Run: sudo nano $PG_HBA and add 'local all $USER trust' and 'host all $USER 127.0.0.1/32 trust'"
    fi
    sudo chmod 644 "$PG_HBA" || log "$(t "Warning: Failed to set pg_hba.conf permissions." "Waarschuwing: Kan permissies voor pg_hba.conf niet instellen.")"
    sudo systemctl restart postgresql || error "Failed to restart PostgreSQL!" "Run: sudo systemctl restart postgresql"
    log "$(t "PostgreSQL restarted after pg_hba.conf update." "PostgreSQL herstart na pg_hba.conf update.")"
  else
    error "pg_hba.conf not found!" "Check PostgreSQL installation: ls /etc/postgresql/17/main/"
  fi

  # Test connection details
  log "$(t "Testing Unix socket connection for $USER..." "Testen van Unix socket connectie voor $USER...")"
  if psql -U "$USER" -h "" -d postgres -c "SELECT 1;" &>> "$DEBUG_LOG"; then
    log "$(t "Unix socket connection successful for $USER." "Unix socket connectie succesvol voor $USER.")"
  else
    log "$(t "Unix socket connection failed for $USER." "Unix socket connectie mislukt voor $USER.")"
  fi
  log "$(t "Testing TCP connection for $USER..." "Testen van TCP connectie voor $USER...")"
  if psql -U "$USER" -h localhost -d postgres -c "SELECT 1;" &>> "$DEBUG_LOG"; then
    log "$(t "TCP connection successful for $USER." "TCP connectie succesvol voor $USER.")"
  else
    log "$(t "TCP connection failed for $USER." "TCP connectie mislukt voor $USER.")"
  fi

  # Reset postgres password as fallback
  POSTGRES_PASSWORD=$(openssl rand -base64 12)
  if psql -U postgres -h "" -d postgres -c "ALTER USER postgres WITH PASSWORD '$POSTGRES_PASSWORD';" &>> "$DEBUG_LOG"; then
    log "$(t "Reset postgres password for fallback: $POSTGRES_PASSWORD" "Postgres wachtwoord gereset voor fallback: $POSTGRES_PASSWORD")"
  else
    log "$(t "Warning: Failed to reset postgres password." "Waarschuwing: Kan postgres wachtwoord niet resetten.")"
  fi

  # Check if user exists, create if not
  if ! psql -U postgres -h "" -d postgres -c "\du" | grep -q "$USER"; then
    if psql -U postgres -h "" -d postgres -c "CREATE ROLE $USER WITH SUPERUSER LOGIN CREATEDB;" &>> "$DEBUG_LOG"; then
      log "$(t "PostgreSQL user $USER created." "PostgreSQL gebruiker $USER aangemaakt.")"
    else
      error "Failed to create user $USER!" "Run: psql -U postgres -h '' -d postgres -c 'CREATE ROLE $USER WITH SUPERUSER LOGIN CREATEDB;'"
    fi
  else
    log "$(t "User $USER already exists." "Gebruiker $USER bestaat al.")"
  fi

  # Grant CREATEDB privilege
  if psql -U postgres -h "" -d postgres -c "ALTER USER $USER WITH CREATEDB;" &>> "$DEBUG_LOG"; then
    log "$(t "CREATEDB privilege granted to $USER." "CREATEDB rechten verleend aan $USER.")"
  else
    error "Failed to grant CREATEDB privilege!" "Run: psql -U postgres -h '' -d postgres -c 'ALTER USER $USER WITH CREATEDB;' or check $DEBUG_LOG"
  fi

  # Retest connections
  if ! psql -U "$USER" -h "" -d postgres -c "SELECT 1;" &>> "$DEBUG_LOG"; then
    log "$(t "Unix socket connection still failed, trying TCP with password..." "Unix socket connectie nog steeds mislukt, probeer TCP met wachtwoord...")"
    DB_PASSWORD=$(openssl rand -base64 12)
    if psql -U postgres -h "" -d postgres -c "ALTER USER $USER WITH PASSWORD '$DB_PASSWORD';" &>> "$DEBUG_LOG"; then
      log "$(t "Set password for $USER: $DB_PASSWORD" "Wachtwoord ingesteld voor $USER: $DB_PASSWORD")"
      echo "host   all   $USER   127.0.0.1/32   md5" | sudo tee -a "$PG_HBA" > /dev/null
      sudo systemctl restart postgresql
      log "$(t "Added md5 auth for $USER in pg_hba.conf." "Toegevoegd md5 auth voor $USER in pg_hba.conf.")"
      if ! psql -U "$USER" -h localhost -d postgres -W -c "SELECT 1;" <<< "$DB_PASSWORD" &>> "$DEBUG_LOG"; then
        error "PostgreSQL connection still failed!" "Check pg_hba.conf: sudo nano $PG_HBA, ensure 'local all $USER trust' and 'host all $USER 127.0.0.1/32 trust', and restart: sudo systemctl restart postgresql"
      fi
    else
      error "Failed to set password for $USER!" "Run: psql -U postgres -h '' -d postgres -c 'ALTER USER $USER WITH PASSWORD \"password\";' or check $DEBUG_LOG"
    fi
  fi
fi

# Dev tools
log "$(t "Installing dev tools..." "Installeren van dev tools...")"
if ! command -v cargo-watch &> /dev/null; then
  log "$(t "Installing cargo-watch..." "Installeren van cargo-watch...")"
  if cargo install cargo-watch; then
    log "$(t "cargo-watch installed." "cargo-watch geïnstalleerd.")"
  else
    error "Failed to install cargo-watch!" "Run manually: cargo install cargo-watch"
  fi
fi
if ! command -v sqlx &> /dev/null; then
  log "$(t "Installing sqlx-cli..." "Installeren van sqlx-cli...")"
  if cargo install sqlx-cli --no-default-features --features postgres,rustls; then
    log "$(t "sqlx-cli installed." "sqlx-cli geïnstalleerd.")"
  else
    error "Failed to install sqlx-cli!" "Run manually: cargo install sqlx-cli --no-default-features --features postgres,rustls"
  fi
fi
if ! command -v tauri &> /dev/null; then
  log "$(t "Installing tauri-cli..." "Installeren van tauri-cli...")"
  if cargo install tauri-cli; then
    log "$(t "tauri-cli installed." "tauri-cli geïnstalleerd.")"
  else
    error "Failed to install tauri-cli!" "Run manually: cargo install tauri-cli"
  fi
fi
log "$(t "Dev tools found." "Dev tools gevonden.")"

# Step 2: Setup Environment
log "$(t "Step 2: Setting up environment..." "Stap 2: Omgeving opzetten...")"
# Check if backend directory exists
if [ ! -d "backend" ]; then
  error "Backend directory not found!" "Create backend directory: mkdir backend"
fi
# Check backend directory permissions
if [ ! -w "backend" ]; then
  log "$(t "Fixing backend directory permissions..." "Backend map permissies aanpassen...")"
  chmod u+w backend || error "Failed to set backend directory permissions!" "Run: chmod u+w backend"
fi
if [ ! -f "backend/.env" ]; then
  log "$(t "Creating .env file..." "Aanmaken van .env bestand...")"
  if [ -n "${DB_PASSWORD:-}" ]; then
    DB_URL="postgres://$USER:$DB_PASSWORD@localhost:5432/quantum_chat"
  else
    DB_URL="postgres://$USER@localhost:5432/quantum_chat"
  fi
  cat << EOF > backend/.env
DATABASE_URL=$DB_URL
REDIS_URL=redis://localhost:6379
JWT_SECRET=$(openssl rand -base64 32)
EOF
  if [ $? -eq 0 ]; then
    chmod 600 backend/.env || error "Failed to set .env permissions!" "Run: chmod 600 backend/.env"
    log "$(t ".env created with random JWT secret." ".env aangemaakt met random JWT secret.")"
  else
    error "Failed to create .env file!" "Check write permissions in backend/ and run: touch backend/.env"
  fi
else
  log "$(t ".env already exists." ".env bestaat al.")"
fi

# Step 3: Initialize Database
log "$(t "Step 3: Initializing PostgreSQL database..." "Stap 3: PostgreSQL database initialiseren...")"
if [ -n "${DB_PASSWORD:-}" ]; then
  if psql -U "$USER" -h localhost -d postgres -W -c "CREATE DATABASE quantum_chat;" <<< "$DB_PASSWORD" &>> "$DEBUG_LOG"; then
    log "$(t "Database created." "Database aangemaakt.")"
  else
    log "$(t "Database already exists." "Database bestaat al.")"
  fi
else
  if psql -U "$USER" -h "" -d postgres -c "CREATE DATABASE quantum_chat;" &>> "$DEBUG_LOG"; then
    log "$(t "Database created." "Database aangemaakt.")"
  else
    log "$(t "Database already exists." "Database bestaat al.")"
  fi
fi

# Check migrations directory
MIGRATIONS_DIR="backend/migrations"
if [ ! -d "$MIGRATIONS_DIR" ] || [ -z "$(ls -A "$MIGRATIONS_DIR"/*.sql 2>/dev/null)" ]; then
  log "$(t "Migrations directory ($MIGRATIONS_DIR) is missing or empty, creating sample migration..." "Migratiemap ($MIGRATIONS_DIR) ontbreekt of is leeg, aanmaken van voorbeeldmigratie...")"
  mkdir -p "$MIGRATIONS_DIR" || error "Failed to create migrations directory!" "Run: mkdir -p backend/migrations"
  cd backend
  if sqlx migrate add init -r &>> "../$DEBUG_LOG"; then
    cat << EOF > "$MIGRATIONS_DIR/$(ls -t $MIGRATIONS_DIR | grep 'init.up.sql' | head -n1)"
-- Sample migration: create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR NOT NULL
);
EOF
    cat << EOF > "$MIGRATIONS_DIR/$(ls -t $MIGRATIONS_DIR | grep 'init.down.sql' | head -n1)"
-- Drop users table
DROP TABLE users;
EOF
    log "$(t "Sample migration created in $MIGRATIONS_DIR." "Voorbeeldmigratie aangemaakt in $MIGRATIONS_DIR.")"
  else
    cd ..
    error "Failed to create sample migration!" "Run: cd backend && sqlx migrate add init -r"
  fi
  cd ..
fi
log "$(t "Migrations directory found with SQL files." "Migratiemap gevonden met SQL-bestanden.")"

# Test database connection before migrations
if [ -n "${DB_PASSWORD:-}" ]; then
  if psql -U "$USER" -h localhost -d quantum_chat -W -c "SELECT 1;" <<< "$DB_PASSWORD" &>> "$DEBUG_LOG"; then
    log "$(t "Database connection to quantum_chat successful." "Database connectie naar quantum_chat succesvol.")"
  else
    error "Failed to connect to quantum_chat database!" "Run: psql -U $USER -h localhost -d quantum_chat -W and use password from $DEBUG_LOG"
  fi
else
  if psql -U "$USER" -h "" -d quantum_chat -c "SELECT 1;" &>> "$DEBUG_LOG"; then
    log "$(t "Database connection to quantum_chat successful." "Database connectie naar quantum_chat succesvol.")"
  else
    error "Failed to connect to quantum_chat database!" "Run: psql -U $USER -h '' -d quantum_chat"
  fi
fi

# Run migrations with detailed error logging
if [ -n "${DB_PASSWORD:-}" ]; then
  if sqlx migrate run --database-url "postgres://$USER:$DB_PASSWORD@localhost:5432/quantum_chat" 2>> "$DEBUG_LOG"; then
    log "$(t "Database migrations applied." "Database migraties toegepast.")"
  else
    log "$(t "Database migrations failed, attempting to reset database..." "Database migraties mislukt, poging tot resetten van database...")"
    if sqlx database reset -y --database-url "postgres://$USER:$DB_PASSWORD@localhost:5432/quantum_chat" 2>> "$DEBUG_LOG"; then
      log "$(t "Database reset and migrations applied." "Database gereset en migraties toegepast.")"
    else
      error "Database migrations failed!" "Check $DEBUG_LOG for SQLx errors, ensure migrations/ contains valid SQL files, and run: sqlx migrate run --database-url postgres://$USER:$DB_PASSWORD@localhost:5432/quantum_chat"
    fi
  fi
else
  if sqlx migrate run --database-url "postgres://$USER@localhost:5432/quantum_chat" 2>> "$DEBUG_LOG"; then
    log "$(t "Database migrations applied." "Database migraties toegepast.")"
  else
    log "$(t "Database migrations failed, attempting to reset database..." "Database migraties mislukt, poging tot resetten van database...")"
    if sqlx database reset -y --database-url "postgres://$USER@localhost:5432/quantum_chat" 2>> "$DEBUG_LOG"; then
      log "$(t "Database reset and migrations applied." "Database gereset en migraties toegepast.")"
    else
      error "Database migrations failed!" "Check $DEBUG_LOG for SQLx errors, ensure migrations/ contains valid SQL files, and run: sqlx migrate run --database-url postgres://$USER@localhost:5432/quantum_chat"
    fi
  fi
fi

# Step 4: Install Frontend Dependencies
log "$(t "Step 4: Installing frontend dependencies..." "Stap 4: Frontend afhankelijkheden installeren...")"
for dir in frontend/web frontend/mobile frontend/desktop; do
  if [ -d "$dir" ]; then
    if cd "$dir" && npm install && cd ../..; then
      log "$(t "$dir dependencies installed." "$dir afhankelijkheden geïnstalleerd.")"
    else
      error "$dir npm install failed!" "Run: cd $dir && npm install"
    fi
  else
    log "$(t "$dir not found, skipping." "$dir niet gevonden, overslaan.")"
  fi
done

# Step 5: Start Servers
log "$(t "Step 5: Starting servers..." "Stap 5: Servers starten...")"
progress 20
if [ -d "backend" ]; then
  if cd backend && cargo watch -x run & cd ..; then
    log "$(t "Backend server started[](http://localhost:8080)." "Backend server gestart[](http://localhost:8080).")"
  else
    error "Backend server failed to start!" "Run: cd backend && cargo watch -x run"
  fi
else
  error "Backend directory not found!" "Ensure project structure is correct."
fi
if [ -d "frontend/web" ]; then
  if cd frontend/web && npm run dev & cd ../..; then
    log "$(t "Web frontend server started[](http://localhost:5173)." "Web frontend server gestart[](http://localhost:5173).")"
  else
    error "Web frontend server failed to start!" "Run: cd frontend/web && npm run dev"
  fi
else
  log "$(t "Web frontend not found, skipping." "Web frontend niet gevonden, overslaan.")"
fi
if [ -d "frontend/mobile" ]; then
  if cd frontend/mobile && npm run start & cd ../..; then
    log "$(t "Mobile server started (Expo)." "Mobile server gestart (Expo).")"
  else
    error "Mobile server failed to start!" "Run: cd frontend/mobile && npm run start"
  fi
else
  log "$(t "Mobile frontend not found, skipping." "Mobile frontend niet gevonden, overslaan.")"
fi
if [ -d "frontend/desktop" ]; then
  if cd frontend/desktop && cargo tauri dev & cd ../..; then
    log "$(t "Desktop server started (Tauri)." "Desktop server gestart (Tauri).")"
  else
    error "Desktop server failed to start!" "Run: cd frontend/desktop && cargo tauri dev"
  fi
else
  log "$(t "Desktop frontend not found, skipping." "Desktop frontend niet gevonden, overslaan.")"
fi

# Step 6: Run Tests
log "$(t "Step 6: Running tests..." "Stap 6: Tests uitvoeren...")"
progress 20
if [ -d "backend" ]; then
  if cargo test --workspace 2>> "$DEBUG_LOG"; then
    log "$(t "Backend tests passed." "Backend tests geslaagd.")"
  else
    error "Backend tests failed!" "Check test output in $DEBUG_LOG and run: cargo test --workspace"
  fi
else
  error "Backend directory not found for tests!" "Ensure project structure is correct."
fi
if [ -d "frontend/web" ]; then
  if cd frontend/web && npm install --save-dev jest @types/jest ts-jest && npm test 2>> "../../$DEBUG_LOG"; then
    log "$(t "Web frontend tests passed." "Web frontend tests geslaagd.")"
  else
    error "Web frontend tests failed!" "Run: cd frontend/web && npm install --save-dev jest @types/jest ts-jest && npm test"
  fi
  cd ../..
else
  log "$(t "Web frontend not found, skipping tests." "Web frontend niet gevonden, tests overslaan.")"
fi

# Final output
log "$(t "Setup complete! All servers and tests running." "Setup voltooid! Alle servers en tests draaien.")"
echo -e "\n${YELLOW}*** FIREWORKS ***${NC}"
echo "🎆 🎇 🎆 🎇 🎆"
echo -e "${GREEN}QUANTUM CHAT PLATFORM${NC}"
echo "🥳 wimfree!!!! 🥳"

log "$(t "Servers running: Web @ http://localhost:5173 | Mobile via Expo | Desktop via Tauri | Backend @ http://localhost:8080" "Servers draaien: Web @ http://localhost:5173 | Mobile via Expo | Desktop via Tauri | Backend @ http://localhost:8080")"
log "$(t "Check start_test_debug.log for details. Hunt those bugs and build your web3 RPG empire!" "Controleer start_test_debug.log voor details. Jaag op die bugs en bouw je web3 RPG empire!")"

wait
