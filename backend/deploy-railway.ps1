# PowerShell script for deploying the backend to Railway using CLI
# This script focuses on backend-specific deployment tasks

Write-Host "=== The Music Besties Backend CLI Deployment ===" -ForegroundColor Cyan
Write-Host "This script deploys the backend to Railway using CLI commands." -ForegroundColor Cyan

# Check if Railway CLI is installed
$railwayInstalled = $null
try {
    $railwayInstalled = Get-Command railway -ErrorAction SilentlyContinue
} catch {}

if (-not $railwayInstalled) {
    Write-Host "Railway CLI is not installed." -ForegroundColor Red
    Write-Host "Installing Railway CLI..." -ForegroundColor Yellow
    npm i -g @railway/cli
}

# Login to Railway if needed
$loggedIn = $false
try {
    $status = railway status 2>&1
    if (-not ($status -match "not logged in")) {
        $loggedIn = $true
        Write-Host "Already logged in to Railway." -ForegroundColor Green
    }
} catch {}

if (-not $loggedIn) {
    Write-Host "Logging in to Railway..." -ForegroundColor Yellow
    railway login
}

# Project selection
Write-Host "`nProject Selection:" -ForegroundColor Yellow
Write-Host "1. Create a new project" -ForegroundColor White
Write-Host "2. Use existing project" -ForegroundColor White

$projectChoice = Read-Host "Enter your choice (1-2)"

if ($projectChoice -eq "1") {
    # Create new project
    Write-Host "Creating new Railway project..." -ForegroundColor Yellow
    $projectName = Read-Host "Enter project name (default: music-besties-backend)"
    if (-not $projectName) {
        $projectName = "music-besties-backend"
    }
    railway project create $projectName
    railway link
} else {
    # List existing projects
    Write-Host "Listing existing projects..." -ForegroundColor Yellow
    railway project list
    
    # Link to existing project
    Write-Host "Linking to existing project..." -ForegroundColor Yellow
    railway link
}

# Environment setup
Write-Host "`nEnvironment Setup:" -ForegroundColor Yellow
$setupEnv = Read-Host "Set up environment variables from .env.master? (y/n)"

if ($setupEnv -eq "y") {
    # Check for .env.master
    if (Test-Path "../.env.master") {
        Write-Host "Reading variables from .env.master..." -ForegroundColor Yellow
        $envContent = Get-Content "../.env.master" -Raw
        
        # Extract variables
        $supabaseUrl = if ($envContent -match "SUPABASE_URL=(.+)") { $matches[1] } else { "" }
        $supabaseKey = if ($envContent -match "SUPABASE_KEY=(.+)") { $matches[1] } else { "" }
        $openaiKey = if ($envContent -match "OPENAI_API_KEY=(.+)") { $matches[1] } else { "" }
        
        # Set variables
        Write-Host "Setting environment variables..." -ForegroundColor Yellow
        if ($supabaseUrl) { railway variables set SUPABASE_URL="$supabaseUrl" }
        if ($supabaseKey) { railway variables set SUPABASE_KEY="$supabaseKey" }
        if ($openaiKey) { railway variables set OPENAI_API_KEY="$openaiKey" }
        
        # Frontend URL
        $frontendUrl = Read-Host "Enter frontend URL (leave blank if not available yet)"
        if ($frontendUrl) {
            railway variables set FRONTEND_URL="$frontendUrl"
        }
        
        # Port
        railway variables set PORT="8000"
        
        Write-Host "Environment variables set successfully." -ForegroundColor Green
    } else {
        Write-Host ".env.master not found. Please set variables manually." -ForegroundColor Red
        
        # Manual variable entry
        $supabaseUrl = Read-Host "Enter SUPABASE_URL"
        $supabaseKey = Read-Host "Enter SUPABASE_KEY"
        $openaiKey = Read-Host "Enter OPENAI_API_KEY"
        $frontendUrl = Read-Host "Enter FRONTEND_URL (leave blank if not available yet)"
        
        if ($supabaseUrl) { railway variables set SUPABASE_URL="$supabaseUrl" }
        if ($supabaseKey) { railway variables set SUPABASE_KEY="$supabaseKey" }
        if ($openaiKey) { railway variables set OPENAI_API_KEY="$openaiKey" }
        if ($frontendUrl) { railway variables set FRONTEND_URL="$frontendUrl" }
        railway variables set PORT="8000"
    }
}

# Service configuration
Write-Host "`nService Configuration:" -ForegroundColor Yellow
$setupService = Read-Host "Configure service settings? (y/n)"

if ($setupService -eq "y") {
    # Set root directory
    Write-Host "Setting root directory to current directory..." -ForegroundColor Yellow
    railway service root-directory .
    
    # Set start command
    Write-Host "Setting start command..." -ForegroundColor Yellow
    railway service start-command "uvicorn main:app --host 0.0.0.0 --port \$PORT"
}

# Deployment
Write-Host "`nDeployment:" -ForegroundColor Yellow
$deploy = Read-Host "Deploy backend now? (y/n)"

if ($deploy -eq "y") {
    Write-Host "Deploying backend to Railway..." -ForegroundColor Yellow
    railway up
    
    # Get deployment URL
    Write-Host "`nGetting deployment information..." -ForegroundColor Yellow
    railway status
    
    Write-Host "`nDeployment complete!" -ForegroundColor Green
    Write-Host "You can view your deployment in the Railway dashboard." -ForegroundColor Cyan
    Write-Host "Remember to update the FRONTEND_URL variable once your frontend is deployed." -ForegroundColor Yellow
}

# Open dashboard
$openDashboard = Read-Host "`nOpen Railway dashboard? (y/n)"
if ($openDashboard -eq "y") {
    railway open
}

Write-Host "`nBackend deployment script completed." -ForegroundColor Cyan
