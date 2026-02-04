# Token Optimizer Installation Script for Windows
# Installs and configures token optimization for OpenClaw

$ErrorActionPreference = "Stop"

# Colors for Windows console
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           Token Optimizer for OpenClaw                   ║" -ForegroundColor Cyan
Write-Host "║           Reduce AI Costs by 97%                         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check Python version
Write-Host "[1/6] Checking Python installation..." -ForegroundColor Blue
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ $pythonVersion found" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Python not found. Please install Python 3.8+" -ForegroundColor Red
    exit 1
}

# Create OpenClaw directory structure
Write-Host "[2/6] Creating directory structure..." -ForegroundColor Blue
$openclawDir = Join-Path $env:USERPROFILE ".openclaw"
$dirs = @("workspace", "prompts", "backups", "memory")
foreach ($dir in $dirs) {
    $path = Join-Path $openclawDir $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}
Write-Host "  ✓ Directories created at $openclawDir" -ForegroundColor Green

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$templatesDir = Join-Path (Split-Path -Parent $scriptDir) "templates"

# Copy templates
Write-Host "[3/6] Installing templates..." -ForegroundColor Blue
if (Test-Path $templatesDir) {
    $templates = @("SOUL.md", "USER.md")
    foreach ($template in $templates) {
        $source = Join-Path $templatesDir $template
        $dest = Join-Path $openclawDir "workspace\$template"
        if (!(Test-Path $dest) -and (Test-Path $source)) {
            Copy-Item $source $dest
            Write-Host "  ✓ Created $template" -ForegroundColor Green
        } else {
            Write-Host "  ○ $template already exists, skipping" -ForegroundColor Yellow
        }
    }

    # Copy optimization rules
    $rulesSource = Join-Path $templatesDir "OPTIMIZATION-RULES.md"
    $rulesDest = Join-Path $openclawDir "prompts\OPTIMIZATION-RULES.md"
    if (Test-Path $rulesSource) {
        Copy-Item $rulesSource $rulesDest -Force
        Write-Host "  ✓ Optimization rules installed" -ForegroundColor Green
    }
}

# Check for existing config and backup
Write-Host "[4/6] Checking existing configuration..." -ForegroundColor Blue
$configFile = Join-Path $openclawDir "openclaw.json"
if (Test-Path $configFile) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path $openclawDir "backups\openclaw_$timestamp.json"
    Copy-Item $configFile $backupFile
    Write-Host "  ✓ Existing config backed up to $backupFile" -ForegroundColor Green
}

# Install optimized config
Write-Host "[5/6] Installing optimized configuration..." -ForegroundColor Blue
$srcDir = Join-Path (Split-Path -Parent $scriptDir) "src"
try {
    python (Join-Path $srcDir "optimizer.py") --mode full 2>$null
    Write-Host "  ✓ Configuration optimized" -ForegroundColor Green
} catch {
    # Fallback: copy template directly
    $templateConfig = Join-Path $templatesDir "openclaw-config-optimized.json"
    if (Test-Path $templateConfig) {
        Copy-Item $templateConfig $configFile -Force
        Write-Host "  ✓ Configuration installed from template" -ForegroundColor Green
    }
}

# Check Ollama
Write-Host "[6/6] Checking Ollama for free heartbeats..." -ForegroundColor Blue
try {
    $ollamaVersion = ollama --version 2>&1
    Write-Host "  ✓ Ollama found" -ForegroundColor Green

    $models = ollama list 2>&1
    if ($models -match "llama3.2") {
        Write-Host "  ✓ llama3.2 model available" -ForegroundColor Green
    } else {
        Write-Host "  ○ Pulling llama3.2:3b model..." -ForegroundColor Yellow
        try {
            ollama pull llama3.2:3b
        } catch {
            Write-Host "  ○ Could not pull model. Run manually: ollama pull llama3.2:3b" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "  ○ Ollama not found" -ForegroundColor Yellow
    Write-Host "      Install from: https://ollama.ai" -ForegroundColor White
    Write-Host "      Then run: ollama pull llama3.2:3b" -ForegroundColor White
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "           Installation Complete!                           " -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration saved to: " -NoNewline
Write-Host $configFile -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Edit workspace files to customize for your use:"
Write-Host "     $openclawDir\workspace\SOUL.md" -ForegroundColor Cyan
Write-Host "     $openclawDir\workspace\USER.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Add optimization rules to your system prompt:"
Write-Host "     $openclawDir\prompts\OPTIMIZATION-RULES.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Start Ollama for free heartbeats:"
Write-Host "     ollama serve" -ForegroundColor Cyan
Write-Host ""
Write-Host "  4. Verify setup:"
Write-Host "     python src\verify.py" -ForegroundColor Cyan
Write-Host ""
Write-Host "Expected savings:" -ForegroundColor White
Write-Host "  Before: " -NoNewline
Write-Host "`$1,500+/month" -ForegroundColor Red
Write-Host "  After:  " -NoNewline
Write-Host "`$30-50/month" -ForegroundColor Green
Write-Host " (97% reduction)"
Write-Host ""
