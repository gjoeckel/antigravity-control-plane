# Antigravity IDE - Windows Absolute Zero Bootstrap Setup
# Version: 1.1.0 (Refined with Symlink Automation)

Write-Host "🛸 Initializing Antigravity Windows Node..." -ForegroundColor Cyan

# 1. Path Definitions
$ConfigDir = "$env:APPDATA\antigravity"
$McpConfigFile = Join-Path $ConfigDir "mcp_config.json"
$GlobalRules = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
$RepoDir = Get-Location

# 2. Dependency Audit
function Check-and-Install ($ToolName, $InstallCmd, $VerifyCmd) {
    if (-not (Get-Command $VerifyCmd -ErrorAction SilentlyContinue)) {
        Write-Warning "⚠️  MISSING: $ToolName"
        $choice = Read-Host "Authorize Winget installation? (y/n)"
        if ($choice -eq 'y') {
            Write-Host "📦 Installing $ToolName..."
            Invoke-Expression $InstallCmd
        } else {
            Write-Error "❌ Setup halted. $ToolName is required."
            exit
        }
    } else {
        Write-Host "✅ $ToolName is already installed." -ForegroundColor Green
    }
}

# --- Phase 0: Prerequisites ---
Check-and-Install "Git" "winget install --id Git.Git -e" "git"
Check-and-Install "FNM" "winget install Schniz.fnm" "fnm"

# --- Phase 1: Runtimes ---
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm install --latest
    fnm use latest
}

# --- Phase 2: Operations Linkage ---
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force
}

$RepoMcpConfig = Join-Path $RepoDir "config\mcp.json"
if (Test-Path $RepoMcpConfig) {
    Write-Host "🔗 Linking Antigravity Logic..." -ForegroundColor Yellow
    # Create symlink (Requires Developer Mode or Admin)
    try {
        New-Item -ItemType SymbolicLink -Path $McpConfigFile -Value $RepoMcpConfig -Force
    } catch {
        Write-Warning "Failed to create symlink automatically. Ensure Developer Mode is enabled or run as Admin."
        Write-Host "Manual Action: mklink `"$McpConfigFile`" `"$RepoMcpConfig`""
    }
}

# --- Phase 3: Global Rules ---
Write-Host "📝 Initializing Global Rules..." -ForegroundColor Yellow
$TemplatePath = Join-Path $RepoDir "docs\GLOBAL-RULES-TEMPLATE.md"

if (Test-Path $TemplatePath) {
    if (Test-Path $GlobalRules) {
        $currentRules = Get-Content $GlobalRules
        if (-not ($currentRules -match "Project & Resources Pattern")) {
            Write-Host "�� Appending Antigravity patterns to $GlobalRules"
            Add-Content $GlobalRules (Get-Content $TemplatePath)
        }
    } else {
        Write-Host "📝 Creating new $GlobalRules"
        $parentDir = Split-Path $GlobalRules
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force }
        Copy-Item $TemplatePath -Destination $GlobalRules
    }
}

Write-Host "-----------------------------------------------"
Write-Host "✅ WINDOWS BOOTSTRAP COMPLETE" -ForegroundColor Green
Write-Host "Mission: run 'start-project' to map your workspace."
Write-Host "-----------------------------------------------"
