# PowerShell script for deploying the frontend to Vercel using CLI
# This script focuses on frontend-specific deployment tasks

Write-Host "=== The Music Besties Frontend CLI Deployment ===" -ForegroundColor Cyan
Write-Host "This script deploys the frontend to Vercel using CLI commands." -ForegroundColor Cyan

# Check if Vercel CLI is installed
$vercelInstalled = $null
try {
    $vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
} catch {}

if (-not $vercelInstalled) {
    Write-Host "Vercel CLI is not installed." -ForegroundColor Red
    Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
    npm i -g vercel
}

# Login to Vercel if needed
$loggedIn = $false
try {
    $whoami = vercel whoami 2>&1
    if (-not ($whoami -match "Error")) {
        $loggedIn = $true
        Write-Host "Already logged in to Vercel as: $whoami" -ForegroundColor Green
    }
} catch {}

if (-not $loggedIn) {
    Write-Host "Logging in to Vercel..." -ForegroundColor Yellow
    vercel login
}

# Project setup
Write-Host "`nProject Setup:" -ForegroundColor Yellow
$projectExists = $false
try {
    $projectInfo = vercel project ls 2>&1
    if (-not ($projectInfo -match "Error")) {
        $projectExists = $true
    }
} catch {}

if ($projectExists) {
    Write-Host "Checking if project is already linked..." -ForegroundColor Yellow
    $linkProject = Read-Host "Link to an existing project? (y/n)"
    if ($linkProject -eq "y") {
        vercel link
    }
} else {
    Write-Host "Project will be created during deployment." -ForegroundColor Yellow
}

# Environment setup
Write-Host "`nEnvironment Setup:" -ForegroundColor Yellow
$setupEnv = Read-Host "Set up environment variables from .env.master? (y/n)"

if ($setupEnv -eq "y") {
    # Check for .env.master
    if (Test-Path ".env.master") {
        Write-Host "Reading variables from .env.master..." -ForegroundColor Yellow
        $envContent = Get-Content ".env.master" -Raw
        
        # Extract variables
        $supabaseUrl = if ($envContent -match "SUPABASE_URL=(.+)") { $matches[1] } else { "" }
        $supabaseKey = if ($envContent -match "SUPABASE_KEY=(.+)") { $matches[1] } else { "" }
        $openaiKey = if ($envContent -match "OPENAI_API_KEY=(.+)") { $matches[1] } else { "" }
        
        # Backend URL
        $backendUrl = Read-Host "Enter backend URL from Railway deployment"
        
        # Set variables for all environments (development, preview, production)
        Write-Host "Setting environment variables..." -ForegroundColor Yellow
        
        foreach ($env in @("development", "preview", "production")) {
            if ($supabaseUrl) { 
                Write-Host "Setting NUXT_PUBLIC_SUPABASE_URL for $env..." -ForegroundColor Yellow
                vercel env add NUXT_PUBLIC_SUPABASE_URL $env "$supabaseUrl" --yes
            }
            
            if ($supabaseKey) { 
                Write-Host "Setting NUXT_PUBLIC_SUPABASE_KEY for $env..." -ForegroundColor Yellow
                vercel env add NUXT_PUBLIC_SUPABASE_KEY $env "$supabaseKey" --yes
            }
            
            if ($backendUrl) { 
                Write-Host "Setting NUXT_PUBLIC_API_BASE_URL for $env..." -ForegroundColor Yellow
                vercel env add NUXT_PUBLIC_API_BASE_URL $env "$backendUrl" --yes
            }
            
            if ($openaiKey) { 
                Write-Host "Setting OPENAI_API_KEY for $env..." -ForegroundColor Yellow
                vercel env add OPENAI_API_KEY $env "$openaiKey" --yes
            }
        }
        
        Write-Host "Environment variables set successfully." -ForegroundColor Green
    } else {
        Write-Host ".env.master not found. Please set variables manually." -ForegroundColor Red
        
        # Manual variable entry
        $supabaseUrl = Read-Host "Enter NUXT_PUBLIC_SUPABASE_URL"
        $supabaseKey = Read-Host "Enter NUXT_PUBLIC_SUPABASE_KEY"
        $backendUrl = Read-Host "Enter NUXT_PUBLIC_API_BASE_URL"
        $openaiKey = Read-Host "Enter OPENAI_API_KEY"
        
        foreach ($env in @("development", "preview", "production")) {
            if ($supabaseUrl) { vercel env add NUXT_PUBLIC_SUPABASE_URL $env "$supabaseUrl" --yes }
            if ($supabaseKey) { vercel env add NUXT_PUBLIC_SUPABASE_KEY $env "$supabaseKey" --yes }
            if ($backendUrl) { vercel env add NUXT_PUBLIC_API_BASE_URL $env "$backendUrl" --yes }
            if ($openaiKey) { vercel env add OPENAI_API_KEY $env "$openaiKey" --yes }
        }
    }
}

# Deployment
Write-Host "`nDeployment:" -ForegroundColor Yellow
$deployType = Read-Host "Deploy as production or preview? (prod/preview)"

if ($deployType -eq "prod") {
    Write-Host "Deploying frontend to Vercel (production)..." -ForegroundColor Yellow
    vercel --prod
} else {
    Write-Host "Deploying frontend to Vercel (preview)..." -ForegroundColor Yellow
    vercel
}

# Get deployment URL
Write-Host "`nGetting deployment information..." -ForegroundColor Yellow
$deploymentInfo = vercel list

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "You can view your deployment in the Vercel dashboard." -ForegroundColor Cyan
Write-Host "Remember to update the FRONTEND_URL variable in your Railway backend deployment." -ForegroundColor Yellow

# Open dashboard
$openDashboard = Read-Host "`nOpen Vercel dashboard? (y/n)"
if ($openDashboard -eq "y") {
    vercel dashboard
}

Write-Host "`nFrontend deployment script completed." -ForegroundColor Cyan
