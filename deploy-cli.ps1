# PowerShell script for CLI-based deployment of The Music Besties
# This script uses CLI tools for Vercel and Railway deployment

# Configuration
$timestamp = Get-Date -Format "ddMMMyymm"
$timestamp = $timestamp.ToUpper()
$repoName = "the-music-besties"

Write-Host "=== The Music Besties CLI Deployment Script ===" -ForegroundColor Cyan
Write-Host "This script uses CLI tools to deploy your application to Vercel and Railway." -ForegroundColor Cyan

# Function to check if a CLI tool is installed
function Test-CommandExists {
    param ($command)
    $exists = $null
    try {
        $exists = Get-Command $command -ErrorAction SilentlyContinue
    } catch {}
    return $exists
}

# Check for required CLI tools
Write-Host "`nChecking for required CLI tools..." -ForegroundColor Yellow

# Check for Vercel CLI
$vercelInstalled = Test-CommandExists "vercel"
if ($vercelInstalled) {
    Write-Host "✓ Vercel CLI is installed." -ForegroundColor Green
    $vercelVersion = Invoke-Expression "vercel --version"
    Write-Host "  Version: $vercelVersion" -ForegroundColor Gray
} else {
    Write-Host "✗ Vercel CLI is not installed." -ForegroundColor Red
    Write-Host "  To install: npm i -g vercel" -ForegroundColor Yellow
    $installVercel = Read-Host "Would you like to install Vercel CLI now? (y/n)"
    if ($installVercel -eq "y") {
        Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
        npm i -g vercel
    }
}

# Check for Railway CLI
$railwayInstalled = Test-CommandExists "railway"
if ($railwayInstalled) {
    Write-Host "✓ Railway CLI is installed." -ForegroundColor Green
    $railwayVersion = Invoke-Expression "railway version"
    Write-Host "  Version: $railwayVersion" -ForegroundColor Gray
} else {
    Write-Host "✗ Railway CLI is not installed." -ForegroundColor Red
    Write-Host "  To install: npm i -g @railway/cli" -ForegroundColor Yellow
    $installRailway = Read-Host "Would you like to install Railway CLI now? (y/n)"
    if ($installRailway -eq "y") {
        Write-Host "Installing Railway CLI..." -ForegroundColor Yellow
        npm i -g @railway/cli
    }
}

# Create a Repomix export for AI analysis
Write-Host "`nCreating Repomix export for AI analysis..." -ForegroundColor Yellow
try {
    npx repomix -o "C:\Users\Bravo\Downloads\${repoName}_${timestamp}.txt"
    Write-Host "✓ Repomix export created successfully at: C:\Users\Bravo\Downloads\${repoName}_${timestamp}.txt" -ForegroundColor Green
} catch {
    Write-Host "✗ Error creating Repomix export: $_" -ForegroundColor Red
}

# Deployment options
Write-Host "`nDeployment Options:" -ForegroundColor Cyan
Write-Host "1. Deploy frontend to Vercel (CLI)" -ForegroundColor White
Write-Host "2. Deploy backend to Railway (CLI)" -ForegroundColor White
Write-Host "3. Deploy both frontend and backend" -ForegroundColor White
Write-Host "4. Login to services" -ForegroundColor White
Write-Host "5. Exit" -ForegroundColor White

$choice = Read-Host "`nEnter your choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host "`nDeploying frontend to Vercel using CLI..." -ForegroundColor Yellow
        
        # Check if logged in to Vercel
        $vercelLoggedIn = $false
        try {
            $whoami = Invoke-Expression "vercel whoami" -ErrorAction SilentlyContinue
            if ($whoami -ne $null) {
                $vercelLoggedIn = $true
                Write-Host "✓ Logged in to Vercel as: $whoami" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $vercelLoggedIn) {
            Write-Host "You need to log in to Vercel first." -ForegroundColor Yellow
            $login = Read-Host "Log in now? (y/n)"
            if ($login -eq "y") {
                vercel login
            } else {
                Write-Host "Deployment canceled." -ForegroundColor Red
                break
            }
        }
        
        # Deploy to Vercel
        Write-Host "Deploying to Vercel..." -ForegroundColor Yellow
        Write-Host "This will use your vercel.json configuration." -ForegroundColor Yellow
        
        $deployOptions = Read-Host "Would you like to deploy with production settings? (y/n)"
        if ($deployOptions -eq "y") {
            # Production deployment
            Write-Host "Running production deployment..." -ForegroundColor Yellow
            vercel --prod
        } else {
            # Preview deployment
            Write-Host "Running preview deployment..." -ForegroundColor Yellow
            vercel
        }
    }
    "2" {
        Write-Host "`nDeploying backend to Railway using CLI..." -ForegroundColor Yellow
        
        # Check if logged in to Railway
        $railwayLoggedIn = $false
        try {
            $status = Invoke-Expression "railway status" -ErrorAction SilentlyContinue
            if ($status -ne $null -and -not ($status -match "not logged in")) {
                $railwayLoggedIn = $true
                Write-Host "✓ Logged in to Railway" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $railwayLoggedIn) {
            Write-Host "You need to log in to Railway first." -ForegroundColor Yellow
            $login = Read-Host "Log in now? (y/n)"
            if ($login -eq "y") {
                railway login
            } else {
                Write-Host "Deployment canceled." -ForegroundColor Red
                break
            }
        }
        
        # Check if project is linked
        $projectLinked = $false
        try {
            $projectInfo = Invoke-Expression "railway status" -ErrorAction SilentlyContinue
            if ($projectInfo -ne $null -and -not ($projectInfo -match "not linked")) {
                $projectLinked = $true
                Write-Host "✓ Railway project is linked" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $projectLinked) {
            Write-Host "You need to link a Railway project." -ForegroundColor Yellow
            $linkProject = Read-Host "Link project now? (y/n)"
            if ($linkProject -eq "y") {
                # List projects
                Write-Host "Available projects:" -ForegroundColor Yellow
                railway project list
                
                # Link to project
                Write-Host "Linking to project..." -ForegroundColor Yellow
                railway link
            } else {
                Write-Host "Deployment canceled." -ForegroundColor Red
                break
            }
        }
        
        # Set up environment variables
        Write-Host "Setting up environment variables..." -ForegroundColor Yellow
        $setupEnv = Read-Host "Would you like to set up environment variables now? (y/n)"
        if ($setupEnv -eq "y") {
            # Get variables from .env.master
            if (Test-Path ".env.master") {
                $envContent = Get-Content ".env.master" -Raw
                
                # Extract variables
                $supabaseUrl = if ($envContent -match "SUPABASE_URL=(.+)") { $matches[1] } else { "" }
                $supabaseKey = if ($envContent -match "SUPABASE_KEY=(.+)") { $matches[1] } else { "" }
                $openaiKey = if ($envContent -match "OPENAI_API_KEY=(.+)") { $matches[1] } else { "" }
                
                # Get frontend URL
                $frontendUrl = Read-Host "Enter your frontend URL (from Vercel deployment)"
                
                # Set variables
                if ($supabaseUrl) { railway variables set SUPABASE_URL="$supabaseUrl" }
                if ($supabaseKey) { railway variables set SUPABASE_KEY="$supabaseKey" }
                if ($openaiKey) { railway variables set OPENAI_API_KEY="$openaiKey" }
                if ($frontendUrl) { railway variables set FRONTEND_URL="$frontendUrl" }
                railway variables set PORT="8000"
                
                Write-Host "✓ Environment variables set" -ForegroundColor Green
            } else {
                Write-Host "✗ .env.master file not found. You'll need to set variables manually." -ForegroundColor Red
            }
        }
        
        # Deploy to Railway
        Write-Host "Deploying backend to Railway..." -ForegroundColor Yellow
        Write-Host "This will use your railway.json configuration." -ForegroundColor Yellow
        
        # Change to backend directory
        Set-Location -Path "$PSScriptRoot\backend"
        
        # Deploy
        railway up
        
        # Return to original directory
        Set-Location -Path $PSScriptRoot
    }
    "3" {
        Write-Host "`nDeploying both frontend and backend..." -ForegroundColor Yellow
        
        # Deploy backend first
        Write-Host "Step 1: Deploying backend to Railway..." -ForegroundColor Yellow
        
        # Check if logged in to Railway
        $railwayLoggedIn = $false
        try {
            $status = Invoke-Expression "railway status" -ErrorAction SilentlyContinue
            if ($status -ne $null -and -not ($status -match "not logged in")) {
                $railwayLoggedIn = $true
                Write-Host "✓ Logged in to Railway" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $railwayLoggedIn) {
            Write-Host "You need to log in to Railway first." -ForegroundColor Yellow
            railway login
        }
        
        # Check if project is linked
        $projectLinked = $false
        try {
            $projectInfo = Invoke-Expression "railway status" -ErrorAction SilentlyContinue
            if ($projectInfo -ne $null -and -not ($projectInfo -match "not linked")) {
                $projectLinked = $true
                Write-Host "✓ Railway project is linked" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $projectLinked) {
            Write-Host "Linking to Railway project..." -ForegroundColor Yellow
            railway link
        }
        
        # Set up environment variables
        Write-Host "Setting up environment variables..." -ForegroundColor Yellow
        
        # Get variables from .env.master
        if (Test-Path ".env.master") {
            $envContent = Get-Content ".env.master" -Raw
            
            # Extract variables
            $supabaseUrl = if ($envContent -match "SUPABASE_URL=(.+)") { $matches[1] } else { "" }
            $supabaseKey = if ($envContent -match "SUPABASE_KEY=(.+)") { $matches[1] } else { "" }
            $openaiKey = if ($envContent -match "OPENAI_API_KEY=(.+)") { $matches[1] } else { "" }
            
            # Set variables (will set frontend URL after frontend deployment)
            if ($supabaseUrl) { railway variables set SUPABASE_URL="$supabaseUrl" }
            if ($supabaseKey) { railway variables set SUPABASE_KEY="$supabaseKey" }
            if ($openaiKey) { railway variables set OPENAI_API_KEY="$openaiKey" }
            railway variables set PORT="8000"
            
            Write-Host "✓ Railway environment variables set" -ForegroundColor Green
        } else {
            Write-Host "✗ .env.master file not found. You'll need to set variables manually." -ForegroundColor Red
        }
        
        # Deploy backend
        Write-Host "Deploying backend..." -ForegroundColor Yellow
        Set-Location -Path "$PSScriptRoot\backend"
        railway up
        
        # Get backend URL
        Write-Host "Getting backend URL..." -ForegroundColor Yellow
        $backendUrl = Read-Host "Enter the backend URL from Railway deployment"
        
        # Return to original directory
        Set-Location -Path $PSScriptRoot
        
        # Now deploy frontend
        Write-Host "`nStep 2: Deploying frontend to Vercel..." -ForegroundColor Yellow
        
        # Check if logged in to Vercel
        $vercelLoggedIn = $false
        try {
            $whoami = Invoke-Expression "vercel whoami" -ErrorAction SilentlyContinue
            if ($whoami -ne $null) {
                $vercelLoggedIn = $true
                Write-Host "✓ Logged in to Vercel as: $whoami" -ForegroundColor Green
            }
        } catch {}
        
        if (-not $vercelLoggedIn) {
            Write-Host "You need to log in to Vercel first." -ForegroundColor Yellow
            vercel login
        }
        
        # Set up environment variables for Vercel
        Write-Host "Setting up Vercel environment variables..." -ForegroundColor Yellow
        
        if ($supabaseUrl) { vercel env add NUXT_PUBLIC_SUPABASE_URL production "$supabaseUrl" }
        if ($supabaseKey) { vercel env add NUXT_PUBLIC_SUPABASE_KEY production "$supabaseKey" }
        if ($backendUrl) { vercel env add NUXT_PUBLIC_API_BASE_URL production "$backendUrl" }
        if ($openaiKey) { vercel env add OPENAI_API_KEY production "$openaiKey" }
        
        Write-Host "✓ Vercel environment variables set" -ForegroundColor Green
        
        # Deploy frontend
        Write-Host "Deploying frontend..." -ForegroundColor Yellow
        vercel --prod
        
        # Get frontend URL
        Write-Host "Getting frontend URL..." -ForegroundColor Yellow
        $frontendUrl = Read-Host "Enter the frontend URL from Vercel deployment"
        
        # Update backend with frontend URL
        Write-Host "`nStep 3: Updating backend with frontend URL..." -ForegroundColor Yellow
        Set-Location -Path "$PSScriptRoot\backend"
        railway variables set FRONTEND_URL="$frontendUrl"
        
        # Return to original directory
        Set-Location -Path $PSScriptRoot
        
        Write-Host "`n✓ Deployment complete!" -ForegroundColor Green
        Write-Host "Frontend: $frontendUrl" -ForegroundColor Cyan
        Write-Host "Backend: $backendUrl" -ForegroundColor Cyan
    }
    "4" {
        Write-Host "`nLogin to services..." -ForegroundColor Yellow
        
        $loginVercel = Read-Host "Login to Vercel? (y/n)"
        if ($loginVercel -eq "y") {
            vercel login
        }
        
        $loginRailway = Read-Host "Login to Railway? (y/n)"
        if ($loginRailway -eq "y") {
            railway login
        }
    }
    "5" {
        Write-Host "`nExiting deployment script." -ForegroundColor Cyan
    }
    default {
        Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
    }
}

Write-Host "`nRemember to test your deployed application thoroughly!" -ForegroundColor Yellow
Write-Host "See deploy-full.md for additional information and troubleshooting." -ForegroundColor Yellow
