#!/bin/bash
# Ollama Setup Script for Token Optimizer
# Installs Ollama and configures it for free OpenClaw heartbeats
#
# Usage: ./setup-ollama.sh
# Optional: ./setup-ollama.sh --model llama3.2:1b  (for low-RAM systems)

set -e

# ============================================================
# CONFIGURATION
# ============================================================

MIN_RAM_GB=4
MIN_DISK_GB=3
OLLAMA_PORT=11434
OLLAMA_URL="http://localhost:$OLLAMA_PORT"
MODEL="${1:-llama3.2:3b}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# ============================================================
# HELPER FUNCTIONS
# ============================================================

step() {
    echo -e "${BLUE}[$1]${NC} $2"
}

success() {
    echo -e "  ${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "  ${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "  ${RED}[X]${NC} $1"
}

info() {
    echo -e "      ${GRAY}$1${NC}"
}

get_ram_gb() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}'
    else
        # Linux
        free -g | awk '/^Mem:/{print $2}'
    fi
}

get_free_disk_gb() {
    df -BG / | awk 'NR==2 {gsub("G",""); print $4}'
}

is_ollama_installed() {
    command -v ollama &> /dev/null
}

is_ollama_running() {
    curl -s "$OLLAMA_URL/api/tags" > /dev/null 2>&1
}

# ============================================================
# MAIN SCRIPT
# ============================================================

echo ""
echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}       Ollama Setup for Token Optimizer                        ${NC}"
echo -e "${CYAN}       Free local LLM for OpenClaw heartbeats                  ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# ------------------------------------------------------------
# STEP 1: System Requirements Check
# ------------------------------------------------------------

step "1/6" "Checking system requirements..."

TOTAL_RAM=$(get_ram_gb)
FREE_DISK=$(get_free_disk_gb)

info "RAM: ${TOTAL_RAM} GB"
info "Free Disk: ${FREE_DISK} GB"

# Check RAM
if [ "$TOTAL_RAM" -lt "$MIN_RAM_GB" ]; then
    warn "Low RAM detected (${TOTAL_RAM} GB)"
    info "Minimum recommended: ${MIN_RAM_GB} GB"
    info "Will use minimal model (llama3.2:1b)"
    MODEL="llama3.2:1b"
else
    success "RAM: ${TOTAL_RAM} GB (sufficient)"
fi

# Check Disk
if [ "$FREE_DISK" -lt "$MIN_DISK_GB" ]; then
    error "Insufficient disk space: ${FREE_DISK} GB"
    info "Minimum required: ${MIN_DISK_GB} GB"
    echo ""
    echo -e "${RED}Please free up disk space and try again.${NC}"
    exit 1
else
    success "Disk: ${FREE_DISK} GB free (sufficient)"
fi

# ------------------------------------------------------------
# STEP 2: Check/Install Ollama
# ------------------------------------------------------------

step "2/6" "Checking Ollama installation..."

if is_ollama_installed; then
    VERSION=$(ollama --version 2>&1)
    success "Ollama already installed: $VERSION"
else
    warn "Ollama not found. Installing..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            info "Installing via Homebrew..."
            brew install ollama
        else
            info "Installing via official script..."
            curl -fsSL https://ollama.com/install.sh | sh
        fi
    else
        # Linux
        info "Installing via official script..."
        curl -fsSL https://ollama.com/install.sh | sh
    fi

    if is_ollama_installed; then
        success "Ollama installed successfully"
    else
        error "Failed to install Ollama"
        echo -e "${YELLOW}Please install manually from: https://ollama.com/download${NC}"
        exit 1
    fi
fi

# ------------------------------------------------------------
# STEP 3: Start Ollama Service
# ------------------------------------------------------------

step "3/6" "Starting Ollama service..."

if is_ollama_running; then
    success "Ollama is already running on port $OLLAMA_PORT"
else
    info "Starting Ollama server..."

    # Start in background
    ollama serve > /dev/null 2>&1 &
    OLLAMA_PID=$!

    # Wait for it to start
    MAX_WAIT=30
    WAITED=0
    while ! is_ollama_running && [ $WAITED -lt $MAX_WAIT ]; do
        sleep 1
        ((WAITED++))
        echo -n "."
    done
    echo ""

    if is_ollama_running; then
        success "Ollama server started (PID: $OLLAMA_PID)"
    else
        error "Failed to start Ollama server"
        info "Try running manually: ollama serve"
        exit 1
    fi
fi

# ------------------------------------------------------------
# STEP 4: Download Model
# ------------------------------------------------------------

step "4/6" "Downloading LLM model..."

# Check if model already exists
if ollama list 2>&1 | grep -q "${MODEL%:*}"; then
    success "Model '$MODEL' already downloaded"
else
    info "Pulling $MODEL (this may take several minutes)..."
    echo ""

    if ollama pull "$MODEL"; then
        success "Model '$MODEL' downloaded successfully"
    else
        error "Failed to download model"
        exit 1
    fi
fi

# ------------------------------------------------------------
# STEP 5: Test Model
# ------------------------------------------------------------

step "5/6" "Testing model..."

info "Sending test prompt..."

RESPONSE=$(curl -s "$OLLAMA_URL/api/generate" \
    -d "{\"model\": \"$MODEL\", \"prompt\": \"Say OK\", \"stream\": false}" \
    2>/dev/null | grep -o '"response":"[^"]*"' | cut -d'"' -f4)

if [ -n "$RESPONSE" ]; then
    success "Model responded: ${RESPONSE:0:50}..."
else
    warn "Test completed (response may be empty for simple prompts)"
fi

# ------------------------------------------------------------
# STEP 6: Configure Auto-Start (Optional)
# ------------------------------------------------------------

step "6/6" "Configuring auto-start..."

echo -n "Start Ollama automatically on system startup? (Y/n): "
read SETUP_AUTOSTART

if [[ "$SETUP_AUTOSTART" != "n" && "$SETUP_AUTOSTART" != "N" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use launchd
        PLIST_PATH="$HOME/Library/LaunchAgents/com.ollama.server.plist"
        cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which ollama)</string>
        <string>serve</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
        launchctl load "$PLIST_PATH" 2>/dev/null || true
        success "Auto-start configured (launchd)"
        info "Plist created at: $PLIST_PATH"
    else
        # Linux - use systemd if available
        if command -v systemctl &> /dev/null; then
            # Check if systemd service already exists
            if systemctl --user cat ollama.service &> /dev/null; then
                systemctl --user enable ollama.service
                success "Auto-start enabled (existing systemd service)"
            else
                # Create user service
                mkdir -p "$HOME/.config/systemd/user"
                cat > "$HOME/.config/systemd/user/ollama.service" << EOF
[Unit]
Description=Ollama LLM Server
After=network.target

[Service]
ExecStart=$(which ollama) serve
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF
                systemctl --user daemon-reload
                systemctl --user enable ollama.service
                success "Auto-start configured (systemd user service)"
            fi
        else
            warn "systemd not available"
            info "Add 'ollama serve &' to your ~/.bashrc or ~/.profile"
        fi
    fi
else
    info "Skipped auto-start configuration"
    info "Remember to run 'ollama serve' before using OpenClaw"
fi

# ============================================================
# SUMMARY
# ============================================================

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}       Ollama Setup Complete!                                  ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo ""

echo "Configuration:"
echo "  Model:    $MODEL"
echo "  Endpoint: $OLLAMA_URL"
echo ""

echo "OpenClaw Heartbeat Config:"
echo -e "${CYAN}  {"
echo -e "    \"heartbeat\": {"
echo -e "      \"model\": \"ollama/$MODEL\""
echo -e "    }"
echo -e "  }${NC}"
echo ""

echo "Useful Commands:"
echo "  ollama list          - Show installed models"
echo "  ollama serve         - Start server manually"
echo "  ollama run $MODEL    - Interactive chat"
echo "  ollama rm $MODEL     - Remove model"
echo ""

echo -e "${YELLOW}Next step:${NC}"
echo "  Run the Token Optimizer to apply all optimizations:"
echo -e "${CYAN}  python src/optimizer.py --mode full${NC}"
echo ""

echo -n "Monthly savings from free heartbeats: "
echo -e "${GREEN}\$10-15${NC}"
echo ""
