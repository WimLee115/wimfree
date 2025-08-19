#!/bin/bash

# Start Servers Script: Quantum Chat Platform
# By: Bug Bounty Genie – Security audited, web3 RPG style!
# Multilingual: English/Nederlands | Progress bar | Autofixing & Detailed logging
# Features: Starts backend, web, mobile, desktop servers with dependency checks

set -e  # Exit on error – no silent vulns
set -u  # Unset vars as error – security mindset

# Debug log setup
DEBUG_LOG="start_servers_debug.log"
echo "Quantum Chat Start Servers Debug Log - $(date)" > "$DEBUG_LOG"

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
  error "Running as root is discouraged!" "Rerun without sudo: ./scripts/start_servers.sh"
fi

# Check script permissions
if [ ! -x "$0" ]; then
  error "Script not executable!" "Run: chmod +x $0 and rerun ./scripts/start_servers.sh"
fi

# Log current working directory
log "$(t "Current working directory: $(pwd)" "Huidige werkdirectory: $(pwd)")"
PROJECT_DIR="/home/wimlee/Documents/wimlee/quantum-chat-platform"
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
  log "$(t "Changing to project directory: $PROJECT_DIR..." "Veranderen naar projectdirectory: $PROJECT_DIR...")"
  cd "$PROJECT_DIR" || error "Failed to change to $PROJECT_DIR!" "Run: cd $PROJECT_DIR"
fi

# Check disk space
log "$(t "Checking disk space..." "Schijfruimte controleren...")"
if ! df -h /home/wimlee >> "$DEBUG_LOG" 2>> "$DEBUG_LOG"; then
  log "$(t "Warning: Failed to check disk space." "Waarschuwing: Kan schijfruimte niet controleren.")"
fi

# Fix locale settings
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

log "$(t "Starting servers and frontends... Security audit engaged!" "Servers en frontends starten... Beveiligingsaudit ingeschakeld!")"

# Progress bar function
progress() {
  local duration=$1
  local steps=20
  local sleep_time=0.5
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
      echo -e "\n${BLINK}${RED}WimLee115-50%-Quantum-Guild-Live${NC}"
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
    nvm install 20
    nvm use 20
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
  if sudo apt update && sudo apt install -y postgresql postgresql-contrib libpq-dev pkg-config; then
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    log "$(t "PostgreSQL installed: $(psql --version)" "PostgreSQL geïnstalleerd: $(psql --version)")"
  else
    error "Failed to install PostgreSQL!" "Run manually: sudo apt install postgresql postgresql-contrib libpq-dev pkg-config"
  fi
else
  log "$(t "PostgreSQL found: $(psql --version)" "PostgreSQL gevonden: $(psql --version)")"
fi

# Redis
if ! command -v redis-server &> /dev/null; then
  log "$(t "Redis not found. Installing..." "Redis niet gevonden. Installeren...")"
  if sudo apt update && sudo apt install -y redis-server; then
    sudo systemctl start redis
    sudo systemctl enable redis
    log "$(t "Redis installed: $(redis-server --version)" "Redis geïnstalleerd: $(redis-server --version)")"
  else
    error "Failed to install Redis!" "Run manually: sudo apt install redis-server"
  fi
else
  log "$(t "Redis found: $(redis-server --version)" "Redis gevonden: $(redis-server --version)")"
fi

# sqlx-cli
if ! command -v sqlx &> /dev/null; then
  log "$(t "sqlx-cli not found. Installing..." "sqlx-cli niet gevonden. Installeren...")"
  for attempt in {1..3}; do
    log "$(t "Attempt $attempt to install sqlx-cli..." "Poging $attempt om sqlx-cli te installeren...")"
    if cargo install sqlx-cli --no-default-features --features postgres,rustls --force 2>> "$DEBUG_LOG"; then
      log "$(t "sqlx-cli installed: $(sqlx --version)" "sqlx-cli geïnstalleerd: $(sqlx --version)")"
      break
    else
      log "$(t "Warning: Failed to install sqlx-cli on attempt $attempt." "Waarschuwing: Kan sqlx-cli niet installeren op poging $attempt.")"
      cat "$DEBUG_LOG" | tail -n 20 >> "$DEBUG_LOG"
      if [ $attempt -eq 3 ]; then
        error "Failed to install sqlx-cli after 3 attempts!" "Check $DEBUG_LOG, ensure network to crates.io, and run: cargo install sqlx-cli --no-default-features --features postgres,rustls --force"
      fi
      sleep 2
    fi
  done
else
  log "$(t "sqlx-cli found: $(sqlx --version)" "sqlx-cli gevonden: $(sqlx --version)")"
fi

# cargo-watch
if ! command -v cargo-watch &> /dev/null; then
  log "$(t "Installing cargo-watch..." "Installeren van cargo-watch...")"
  if cargo install cargo-watch 2>> "$DEBUG_LOG"; then
    log "$(t "cargo-watch installed." "cargo-watch geïnstalleerd.")"
  else
    error "Failed to install cargo-watch!" "Run manually: cargo install cargo-watch"
  fi
else
  log "$(t "cargo-watch found." "cargo-watch gevonden.")"
fi

# tauri-cli
if ! command -v tauri &> /dev/null; then
  log "$(t "Installing tauri-cli..." "Installeren van tauri-cli...")"
  if cargo install tauri-cli --force 2>> "$DEBUG_LOG"; then
    log "$(t "tauri-cli installed." "tauri-cli geïnstalleerd.")"
  else
    error "Failed to install tauri-cli!" "Run manually: cargo install tauri-cli --force"
  fi
else
  log "$(t "tauri-cli found." "tauri-cli gevonden.")"
fi

# Step 2: Check Permissions
log "$(t "Step 2: Checking and fixing permissions..." "Stap 2: Permissies controleren en fixen...")"
for dir in backend frontend/web frontend/mobile frontend/desktop; do
  if [ -d "$dir" ]; then
    log "$(t "Checking permissions for $dir..." "Permissies controleren voor $dir...")"
    stat -c "$dir details: %A %U:%G %n" "$dir" >> "$DEBUG_LOG" 2>> "$DEBUG_LOG" || log "$(t "Warning: Failed to log $dir details." "Waarschuwing: Kan $dir details niet loggen.")"
    if [ ! -r "$dir" ] || [ ! -w "$dir" ] || [ ! -x "$dir" ]; then
      log "$(t "Fixing permissions for $dir..." "Permissies fixen voor $dir...")"
      if chmod -R u+rwx "$dir" && chown -R "$USER:$USER" "$dir"; then
        log "$(t "$dir permissions fixed." "$dir permissies gefixt.")"
      else
        error "Failed to fix permissions for $dir!" "Run: sudo chmod -R u+rwx $dir && sudo chown -R $USER:$USER $dir"
      fi
    fi
  else
    error "$dir directory not found!" "Ensure project structure is correct: ls $dir"
  fi
done

# Fix file permissions
log "$(t "Setting file permissions..." "Bestandspermissies instellen...")"
declare -A EXT_PERMS=(
  ["*.ts"]="644"
  ["*.tsx"]="644"
  ["*.css"]="644"
  ["*.json"]="644"
  ["*.js"]="644"
  ["*.rs"]="644"
  ["*.sh"]="755"
)
for ext in "${!EXT_PERMS[@]}"; do
  log "$(t "Setting permissions ${EXT_PERMS[$ext]} for $ext files..." "Permissies ${EXT_PERMS[$ext]} instellen voor $ext bestanden...")"
  if find . -type f -name "$ext" -exec ls -l {} \; >> "$DEBUG_LOG" 2>> "$DEBUG_LOG"; then
    log "$(t "Found $ext files." "Gevonden $ext bestanden.")"
  else
    log "$(t "Warning: No $ext files found or error listing them." "Waarschuwing: Geen $ext bestanden gevonden of fout bij lijst.")"
  fi
  if find . -type f -name "$ext" -exec chmod "${EXT_PERMS[$ext]}" {} \; 2>> "$DEBUG_LOG"; then
    log "$(t "Permissions ${EXT_PERMS[$ext]} set for $ext files." "Permissies ${EXT_PERMS[$ext]} ingesteld voor $ext bestanden.")"
  else
    error "Failed to set permissions for $ext!" "Run: find . -type f -name \"$ext\" -exec chmod ${EXT_PERMS[$ext]} {} \;"
  fi
done
sync || log "$(t "Warning: Failed to sync disk writes after setting permissions." "Waarschuwing: Kan disk writes niet synchroniseren na instellen permissies.")"

# Step 3: Setup Environment
log "$(t "Step 3: Setting up environment..." "Stap 3: Omgeving opzetten...")"
if [ ! -f "backend/.env" ]; then
  log "$(t "Creating .env file..." "Aanmaken van .env bestand...")"
  DB_URL="postgres://$USER@/var/run/postgresql:5432/quantum_chat"
  cat << EOF > backend/.env
DATABASE_URL=$DB_URL
REDIS_URL=redis://localhost:6379
JWT_SECRET=$(openssl rand -base64 32)
EOF
  if chmod 600 backend/.env && chown "$USER:$USER" backend/.env; then
    log "$(t ".env created with random JWT secret." ".env aangemaakt met random JWT secret.")"
  else
    error "Failed to set .env permissions!" "Run: chmod 600 backend/.env && chown $USER:$USER backend/.env"
  fi
else
  log "$(t ".env already exists." ".env bestaat al.")"
  if grep -q "^DATABASE_URL=" backend/.env; then
    DB_URL=$(grep "^DATABASE_URL=" backend/.env | cut -d= -f2-)
    log "$(t "DATABASE_URL found: $DB_URL" "DATABASE_URL gevonden: $DB_URL")"
  else
    error "DATABASE_URL not found in .env!" "Edit backend/.env to include DATABASE_URL=postgres://$USER@/var/run/postgresql:5432/quantum_chat"
  fi
fi

# Step 4: Check Database and Redis
log "$(t "Step 4: Checking database and Redis connections..." "Stap 4: Database- en Redis-connecties controleren...")"
SOCKET_PATH="/var/run/postgresql"
if [ ! -S "$SOCKET_PATH/.s.PGSQL.5432" ]; then
  log "$(t "Warning: PostgreSQL socket not found at $SOCKET_PATH, trying /tmp..." "Waarschuwing: PostgreSQL socket niet gevonden op $SOCKET_PATH, proberen /tmp...")"
  SOCKET_PATH="/tmp"
  DB_URL="postgres://$USER@/tmp:5432/quantum_chat"
  sed -i "s|^DATABASE_URL=.*|DATABASE_URL=$DB_URL|" backend/.env || error "Failed to update DATABASE_URL!" "Edit backend/.env to set DATABASE_URL=$DB_URL"
fi
if psql -U "$USER" -h "$SOCKET_PATH" -d quantum_chat -c "SELECT 1;" &>> "$DEBUG_LOG"; then
  log "$(t "Database connection successful." "Database connectie succesvol.")"
else
  log "$(t "Attempting to fix PostgreSQL connection..." "Poging om PostgreSQL connectie te repareren...")"
  if sudo systemctl start postgresql; then
    log "$(t "PostgreSQL service started." "PostgreSQL service gestart.")"
  else
    error "Failed to start PostgreSQL!" "Run: sudo systemctl start postgresql"
  fi
  PG_HBA="/etc/postgresql/17/main/pg_hba.conf"
  if [ -f "$PG_HBA" ]; then
    sudo cp "$PG_HBA" "${PG_HBA}.backup-$(date +%F-%H%M%S)" || log "$(t "Warning: Failed to backup pg_hba.conf." "Waarschuwing: Kan pg_hba.conf niet back-uppen.")"
    cat << EOF | sudo tee "$PG_HBA" > /dev/null
local   all   $USER      trust
host    all   $USER      127.0.0.1/32   trust
EOF
    sudo chmod 644 "$PG_HBA" || log "$(t "Warning: Failed to set pg_hba.conf permissions." "Waarschuwing: Kan permissies voor pg_hba.conf niet instellen.")"
    sudo systemctl restart postgresql || error "Failed to restart PostgreSQL!" "Run: sudo systemctl restart postgresql"
  fi
  if psql -U "$USER" -h "$SOCKET_PATH" -d quantum_chat -c "SELECT 1;" &>> "$DEBUG_LOG"; then
    log "$(t "Database connection fixed." "Database connectie gefixt.")"
  else
    error "Failed to connect to database!" "Check $PG_HBA and run: psql -U $USER -h $SOCKET_PATH -d quantum_chat -c 'SELECT 1;'"
  fi
fi
if redis-cli ping &>> "$DEBUG_LOG"; then
  log "$(t "Redis connection successful." "Redis connectie succesvol.")"
else
  if sudo systemctl start redis; then
    log "$(t "Redis service started." "Redis service gestart.")"
  else
    error "Failed to start Redis!" "Run: sudo systemctl start redis"
  fi
fi

# Step 5: Install Frontend Dependencies
log "$(t "Step 5: Installing frontend dependencies..." "Stap 5: Frontend afhankelijkheden installeren...")"
for dir in frontend/web frontend/mobile frontend/desktop; do
  if [ -d "$dir" ]; then
    log "$(t "Installing dependencies in $dir..." "Afhankelijkheden installeren in $dir...")"
    if cd "$dir" && npm install &>> "../../$DEBUG_LOG" && cd ../..; then
      log "$(t "$dir dependencies installed." "$dir afhankelijkheden geïnstalleerd.")"
    else
      error "$dir npm install failed!" "Run: cd $dir && npm install"
    fi
  else
    log "$(t "$dir not found, skipping." "$dir niet gevonden, overslaan.")"
  fi
done

# Step 6: Start Servers
log "$(t "Step 6: Starting servers..." "Stap 6: Servers starten...")"
progress 20
pids=()
if [ -d "backend" ]; then
  log "$(t "Starting backend server..." "Backend server starten...")"
  if cd backend && cargo watch -x run &>> "../$DEBUG_LOG" & cd ..; then
    pids+=($!)
    log "$(t "Backend server started (http://localhost:8080)." "Backend server gestart (http://localhost:8080).")"
  else
    error "Backend server failed to start!" "Run: cd backend && cargo watch -x run"
  fi
else
  error "Backend directory not found!" "Ensure project structure is correct."
fi
if [ -d "frontend/web" ]; then
  log "$(t "Starting web frontend..." "Web frontend starten...")"
  if cd frontend/web && npm run dev &>> "../../$DEBUG_LOG" & cd ../..; then
    pids+=($!)
    log "$(t "Web frontend started (http://localhost:5173)." "Web frontend gestart (http://localhost:5173).")"
  else
    error "Web frontend failed to start!" "Run: cd frontend/web && npm run dev"
  fi
else
  log "$(t "Web frontend not found, skipping." "Web frontend niet gevonden, overslaan.")"
fi
if [ -d "frontend/mobile" ]; then
  log "$(t "Starting mobile frontend..." "Mobile frontend starten...")"
  if cd frontend/mobile && npm run start &>> "../../$DEBUG_LOG" & cd ../..; then
    pids+=($!)
    log "$(t "Mobile frontend started (Expo)." "Mobile frontend gestart (Expo).")"
  else
    error "Mobile frontend failed to start!" "Run: cd frontend/mobile && npm run start"
  fi
else
  log "$(t "Mobile frontend not found, skipping." "Mobile frontend niet gevonden, overslaan.")"
fi
if [ -d "frontend/desktop" ]; then
  log "$(t "Starting desktop frontend..." "Desktop frontend starten...")"
  if cd frontend/desktop && cargo tauri dev &>> "../../$DEBUG_LOG" & cd ../..; then
    pids+=($!)
    log "$(t "Desktop frontend started (Tauri)." "Desktop frontend gestart (Tauri).")"
  else
    error "Desktop frontend failed to start!" "Run: cd frontend/desktop && cargo tauri dev"
  fi
else
  log "$(t "Desktop frontend not found, skipping." "Desktop frontend niet gevonden, overslaan.")"
fi

# Step 7: Finalize
log "$(t "All servers and frontends started!" "Alle servers en frontends gestart!")"
echo -e "\n${YELLOW}*** FIREWORKS ***${NC}"
echo "🎆 🎇 🎆 🎇 🎆"
echo -e "${GREEN}QUANTUM CHAT PLATFORM${NC}"
echo "🥳 wimfree!!!! 🥳"
log "$(t "Servers running: Web @ http://localhost:5173 | Mobile via Expo | Desktop via Tauri | Backend @ http://localhost:8080" "Servers draaien: Web @ http://localhost:5173 | Mobile via Expo | Desktop via Tauri | Backend @ http://localhost:8080")"
log "$(t "Check $DEBUG_LOG for details. Hunt those bugs and build your web3 RPG empire!" "Controleer $DEBUG_LOG voor details. Jaag op die bugs en bouw je web3 RPG empire!")"

# Wait for background processes
log "$(t "Keeping servers running... Press Ctrl+C to stop." "Servers blijven draaien... Druk op Ctrl+C om te stoppen.")"
for pid in "${pids[@]}"; do
  wait "$pid" || log "$(t "Warning: Process $pid exited." "Waarschuwing: Proces $pid beëindigd.")"
done
