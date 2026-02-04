# Ollama Setup Script for Token Optimizer
# Installs Ollama and configures it for free OpenClaw heartbeats
#
# Usage: .\setup-ollama.ps1
# Optional: .\setup-ollama.ps1 -Model "llama3.2:1b"  (for low-RAM systems)

param(
    [string]$Model = "llama3.2:3b"
)

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$MIN_RAM_GB = 4
$MIN_DISK_GB = 3
$OLLAMA_PORT = 11434
$OLLAMA_URL = "http://localhost:$OLLAMA_PORT"

# Model options based on available RAM
$MODELS = @{
    "minimal" = @{ name = "llama3.2:1b"; ram = 2; disk = 1.3 }
    "recommended" = @{ name = "llama3.2:3b"; ram = 4; disk = 2.0 }
    "performance" = @{ name = "llama3.1:8b"; ram = 8; disk = 4.7 }
}

# ============================================================
# HELPER FUNCTIONS
# ============================================================

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  [!] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  [X] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "      $Message" -ForegroundColor Gray
}

function Get-SystemRAM {
    $ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    return [math]::Round($ram / 1GB, 1)
}

function Get-FreeDiskSpace {
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    return [math]::Round($disk.FreeSpace / 1GB, 1)
}

function Test-OllamaInstalled {
    try {
        $null = Get-Command ollama -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Test-OllamaRunning {
    try {
        $response = Invoke-WebRequest -Uri "$OLLAMA_URL/api/tags" -Method GET -TimeoutSec 5 -ErrorAction Stop
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Get-RecommendedModel {
    param([double]$AvailableRAM)

    if ($AvailableRAM -ge 8) {
        return $MODELS["performance"]
    } elseif ($AvailableRAM -ge 4) {
        return $MODELS["recommended"]
    } else {
        return $MODELS["minimal"]
    }
}

# ============================================================
# MAIN SCRIPT
# ============================================================

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "       Ollama Setup for Token Optimizer                        " -ForegroundColor Cyan
Write-Host "       Free local LLM for OpenClaw heartbeats                  " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# STEP 1: System Requirements Check
# ------------------------------------------------------------

Write-Step "1/6" "Checking system requirements..."

$totalRAM = Get-SystemRAM
$freeDisk = Get-FreeDiskSpace

Write-Info "RAM: $totalRAM GB"
Write-Info "Free Disk: $freeDisk GB"

# Check RAM
if ($totalRAM -lt $MIN_RAM_GB) {
    Write-Warning "Low RAM detected ($totalRAM GB)"
    Write-Info "Minimum recommended: $MIN_RAM_GB GB"
    Write-Info "Will use minimal model (llama3.2:1b)"
    $Model = "llama3.2:1b"
} else {
    Write-Success "RAM: $totalRAM GB (sufficient)"
}

# Check Disk
if ($freeDisk -lt $MIN_DISK_GB) {
    Write-Error "Insufficient disk space: $freeDisk GB"
    Write-Info "Minimum required: $MIN_DISK_GB GB"
    Write-Host ""
    Write-Host "Please free up disk space and try again." -ForegroundColor Red
    exit 1
} else {
    Write-Success "Disk: $freeDisk GB free (sufficient)"
}

# Recommend model based on RAM
$recommended = Get-RecommendedModel -AvailableRAM $totalRAM
Write-Info "Recommended model for your system: $($recommended.name)"

# ------------------------------------------------------------
# STEP 2: Check/Install Ollama
# ------------------------------------------------------------

Write-Step "2/6" "Checking Ollama installation..."

if (Test-OllamaInstalled) {
    $version = ollama --version 2>&1
    Write-Success "Ollama already installed: $version"
} else {
    Write-Warning "Ollama not found. Installing..."

    # Try winget first
    $wingetAvailable = $false
    try {
        $null = Get-Command winget -ErrorAction Stop
        $wingetAvailable = $true
    } catch {}

    if ($wingetAvailable) {
        Write-Info "Installing via winget..."
        try {
            winget install Ollama.Ollama --accept-package-agreements --accept-source-agreements
            Write-Success "Ollama installed via winget"

            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        } catch {
            Write-Warning "Winget installation failed. Trying direct download..."
            $wingetAvailable = $false
        }
    }

    if (-not $wingetAvailable) {
        # Direct download
        Write-Info "Downloading Ollama installer..."
        $installerUrl = "https://ollama.com/download/OllamaSetup.exe"
        $installerPath = Join-Path $env:TEMP "OllamaSetup.exe"

        try {
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
            Write-Info "Running installer (this may take a moment)..."

            Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            # Clean up
            Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

            Write-Success "Ollama installed successfully"
        } catch {
            Write-Error "Failed to download/install Ollama"
            Write-Host ""
            Write-Host "Please install manually from: https://ollama.com/download" -ForegroundColor Yellow
            exit 1
        }
    }
}

# Verify installation
if (-not (Test-OllamaInstalled)) {
    Write-Error "Ollama installation could not be verified"
    Write-Host "Please restart PowerShell and run this script again." -ForegroundColor Yellow
    exit 1
}

# ------------------------------------------------------------
# STEP 3: Start Ollama Service
# ------------------------------------------------------------

Write-Step "3/6" "Starting Ollama service..."

if (Test-OllamaRunning) {
    Write-Success "Ollama is already running on port $OLLAMA_PORT"
} else {
    Write-Info "Starting Ollama server..."

    # Start Ollama in background
    $ollamaProcess = Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru

    # Wait for it to start
    $maxWait = 30
    $waited = 0
    while (-not (Test-OllamaRunning) -and $waited -lt $maxWait) {
        Start-Sleep -Seconds 1
        $waited++
        Write-Host "." -NoNewline
    }
    Write-Host ""

    if (Test-OllamaRunning) {
        Write-Success "Ollama server started (PID: $($ollamaProcess.Id))"
    } else {
        Write-Error "Failed to start Ollama server"
        Write-Info "Try running manually: ollama serve"
        exit 1
    }
}

# ------------------------------------------------------------
# STEP 4: Download Model
# ------------------------------------------------------------

Write-Step "4/6" "Downloading LLM model..."

# Check if model already exists
$existingModels = ollama list 2>&1
if ($existingModels -match $Model.Replace(":", "")) {
    Write-Success "Model '$Model' already downloaded"
} else {
    Write-Info "Pulling $Model (this may take several minutes)..."
    Write-Info "Model size: ~$($recommended.disk) GB"
    Write-Host ""

    try {
        # Run ollama pull and show progress
        $pullProcess = Start-Process -FilePath "ollama" -ArgumentList "pull $Model" -NoNewWindow -Wait -PassThru

        if ($pullProcess.ExitCode -eq 0) {
            Write-Success "Model '$Model' downloaded successfully"
        } else {
            Write-Error "Failed to download model"
            exit 1
        }
    } catch {
        Write-Error "Error pulling model: $_"
        exit 1
    }
}

# ------------------------------------------------------------
# STEP 5: Test Model
# ------------------------------------------------------------

Write-Step "5/6" "Testing model..."

Write-Info "Sending test prompt..."

try {
    $testBody = @{
        model = $Model
        prompt = "Say OK"
        stream = $false
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$OLLAMA_URL/api/generate" -Method POST -Body $testBody -ContentType "application/json" -TimeoutSec 60

    if ($response.response) {
        Write-Success "Model responded: $($response.response.Substring(0, [Math]::Min(50, $response.response.Length)))..."
    } else {
        Write-Warning "Model responded but output was empty"
    }
} catch {
    Write-Warning "Test failed: $_"
    Write-Info "Model may still work. Continue with verification."
}

# ------------------------------------------------------------
# STEP 6: Configure Auto-Start (Optional)
# ------------------------------------------------------------

Write-Step "6/6" "Configuring auto-start..."

$setupAutostart = Read-Host "Start Ollama automatically on Windows startup? (Y/n)"
if ($setupAutostart -ne "n" -and $setupAutostart -ne "N") {
    $startupFolder = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolder "Ollama.lnk"

    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = (Get-Command ollama).Source
        $Shortcut.Arguments = "serve"
        $Shortcut.WindowStyle = 7  # Minimized
        $Shortcut.Description = "Ollama LLM Server"
        $Shortcut.Save()

        Write-Success "Auto-start configured"
        Write-Info "Shortcut created at: $shortcutPath"
    } catch {
        Write-Warning "Could not configure auto-start: $_"
        Write-Info "You can start Ollama manually with: ollama serve"
    }
} else {
    Write-Info "Skipped auto-start configuration"
    Write-Info "Remember to run 'ollama serve' before using OpenClaw"
}

# ============================================================
# SUMMARY
# ============================================================

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "       Ollama Setup Complete!                                  " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Configuration:" -ForegroundColor White
Write-Host "  Model:    $Model"
Write-Host "  Endpoint: $OLLAMA_URL"
Write-Host "  RAM Used: ~$($recommended.ram) GB"
Write-Host "  Disk:     ~$($recommended.disk) GB"
Write-Host ""

Write-Host "OpenClaw Heartbeat Config:" -ForegroundColor White
Write-Host '  {' -ForegroundColor Cyan
Write-Host '    "heartbeat": {' -ForegroundColor Cyan
Write-Host "      `"model`": `"ollama/$Model`"" -ForegroundColor Cyan
Write-Host '    }' -ForegroundColor Cyan
Write-Host '  }' -ForegroundColor Cyan
Write-Host ""

Write-Host "Useful Commands:" -ForegroundColor White
Write-Host "  ollama list          - Show installed models"
Write-Host "  ollama serve         - Start server manually"
Write-Host "  ollama run $Model    - Interactive chat"
Write-Host "  ollama rm $Model     - Remove model"
Write-Host ""

Write-Host "Next step:" -ForegroundColor Yellow
Write-Host "  Run the Token Optimizer to apply all optimizations:"
Write-Host "  python src/optimizer.py --mode full" -ForegroundColor Cyan
Write-Host ""

Write-Host "Monthly savings from free heartbeats: " -NoNewline
Write-Host "`$10-15" -ForegroundColor Green
Write-Host ""
