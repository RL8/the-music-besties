# Railway Deployment Script for The Music Besties
# This script follows Railway best practices with development/production environments
# Created: May 29, 2025

Write-Host "=== The Music Besties Railway Deployment ===" -ForegroundColor Cyan
Write-Host "This script helps deploy your application following Railway best practices" -ForegroundColor Cyan

# Check if Railway CLI is installed
$railwayInstalled = $null
try {
    $railwayInstalled = Get-Command railway -ErrorAction SilentlyContinue
} catch {}

if (-not $railwayInstalled) {
    Write-Host "Railway CLI is not installed." -ForegroundColor Red
    Write-Host "Please install it with: npm i -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
Write-Host "`nChecking Railway login status..." -ForegroundColor Yellow
$loggedIn = $false
try {
    $whoami = railway whoami
    if ($whoami -match "Logged in as") {
        $loggedIn = $true
        Write-Host "✓ Logged in as $($whoami.Split(' ')[3])" -ForegroundColor Green
    }
} catch {}

if (-not $loggedIn) {
    Write-Host "! You need to log in to Railway" -ForegroundColor Red
    Write-Host "Run 'railway login' and follow the prompts" -ForegroundColor Yellow
    exit 1
}

# Deployment options
Write-Host "`nDeployment Options:" -ForegroundColor Cyan
Write-Host "1. Set up development environment variables" -ForegroundColor White
Write-Host "2. Deploy to development environment" -ForegroundColor White
Write-Host "3. Deploy to production environment" -ForegroundColor White
Write-Host "4. Check deployment status" -ForegroundColor White
Write-Host "5. View deployment logs" -ForegroundColor White
Write-Host "6. Create GitHub Actions workflow file" -ForegroundColor White
Write-Host "7. Exit" -ForegroundColor White

$choice = Read-Host "`nEnter your choice (1-7)"

switch ($choice) {
    "1" {
        Write-Host "`nSetting up development environment variables..." -ForegroundColor Yellow
        
        # This requires user interaction
        Write-Host "! INTERACTIVE STEP: You need to select the development environment" -ForegroundColor Magenta
        Write-Host "Run: railway environment development" -ForegroundColor Yellow
        
        $proceed = Read-Host "Have you selected the development environment? (y/n)"
        if ($proceed -ne "y") {
            Write-Host "Exiting. Please run the script again after selecting the development environment." -ForegroundColor Red
            exit 1
        }
        
        # Check current environment
        $currentEnv = railway status | Select-String -Pattern "Environment: (.+)"
        if ($currentEnv -and $currentEnv.Matches.Groups[1].Value -eq "development") {
            Write-Host "✓ Development environment selected" -ForegroundColor Green
            
            # Set development-specific variables
            Write-Host "Setting development environment variables..." -ForegroundColor Yellow
            
            # Get frontend URL
            $frontendUrl = Read-Host "Enter your development frontend URL (e.g., https://the-music-besties-dev.vercel.app)"
            if ($frontendUrl) {
                railway variables set FRONTEND_URL="$frontendUrl"
                Write-Host "✓ FRONTEND_URL set to $frontendUrl" -ForegroundColor Green
            }
            
            Write-Host "✓ Development environment variables configured" -ForegroundColor Green
        } else {
            Write-Host "! Development environment not selected. Please run 'railway environment development' first." -ForegroundColor Red
        }
    }
    "2" {
        Write-Host "`nDeploying to development environment..." -ForegroundColor Yellow
        
        # This requires user interaction
        Write-Host "! INTERACTIVE STEP: You need to select the development environment" -ForegroundColor Magenta
        Write-Host "Run: railway environment development" -ForegroundColor Yellow
        
        $proceed = Read-Host "Have you selected the development environment? (y/n)"
        if ($proceed -ne "y") {
            Write-Host "Exiting. Please run the script again after selecting the development environment." -ForegroundColor Red
            exit 1
        }
        
        # Check current environment
        $currentEnv = railway status | Select-String -Pattern "Environment: (.+)"
        if ($currentEnv -and $currentEnv.Matches.Groups[1].Value -eq "development") {
            Write-Host "✓ Development environment selected" -ForegroundColor Green
            
            # Navigate to backend directory
            Set-Location -Path "$PSScriptRoot\backend"
            
            # Deploy
            Write-Host "Deploying backend to development environment..." -ForegroundColor Yellow
            Write-Host "Running: railway up" -ForegroundColor Yellow
            
            # This is where the actual deployment happens
            railway up
            
            # Return to original directory
            Set-Location -Path $PSScriptRoot
            
            Write-Host "✓ Deployment to development environment completed" -ForegroundColor Green
        } else {
            Write-Host "! Development environment not selected. Please run 'railway environment development' first." -ForegroundColor Red
        }
    }
    "3" {
        Write-Host "`nDeploying to production environment..." -ForegroundColor Yellow
        
        # This requires user interaction
        Write-Host "! INTERACTIVE STEP: You need to select the production environment" -ForegroundColor Magenta
        Write-Host "Run: railway environment production" -ForegroundColor Yellow
        
        $proceed = Read-Host "Have you selected the production environment? (y/n)"
        if ($proceed -ne "y") {
            Write-Host "Exiting. Please run the script again after selecting the production environment." -ForegroundColor Red
            exit 1
        }
        
        # Check current environment
        $currentEnv = railway status | Select-String -Pattern "Environment: (.+)"
        if ($currentEnv -and $currentEnv.Matches.Groups[1].Value -eq "production") {
            Write-Host "✓ Production environment selected" -ForegroundColor Green
            
            # Confirm production deployment
            $confirmProd = Read-Host "Are you sure you want to deploy to PRODUCTION? This will affect live users. (y/n)"
            if ($confirmProd -ne "y") {
                Write-Host "Production deployment cancelled." -ForegroundColor Yellow
                exit 0
            }
            
            # Navigate to backend directory
            Set-Location -Path "$PSScriptRoot\backend"
            
            # Deploy
            Write-Host "Deploying backend to production environment..." -ForegroundColor Yellow
            Write-Host "Running: railway up" -ForegroundColor Yellow
            
            # This is where the actual deployment happens
            railway up
            
            # Return to original directory
            Set-Location -Path $PSScriptRoot
            
            Write-Host "✓ Deployment to production environment completed" -ForegroundColor Green
        } else {
            Write-Host "! Production environment not selected. Please run 'railway environment production' first." -ForegroundColor Red
        }
    }
    "4" {
        Write-Host "`nChecking deployment status..." -ForegroundColor Yellow
        
        # Get current status
        Write-Host "Current Railway status:" -ForegroundColor Yellow
        railway status
        
        # Check if a service is selected
        $currentService = railway status | Select-String -Pattern "Service: (.+)"
        if ($currentService -and $currentService.Matches.Groups[1].Value -ne "None") {
            # Get deployment info
            Write-Host "`nDeployment information:" -ForegroundColor Yellow
            railway logs --limit 1
        } else {
            Write-Host "! No service selected. Run 'railway service' to select a service." -ForegroundColor Red
        }
    }
    "5" {
        Write-Host "`nViewing deployment logs..." -ForegroundColor Yellow
        
        # Get logs
        Write-Host "Fetching logs (press Ctrl+C to exit):" -ForegroundColor Yellow
        railway logs
    }
    "6" {
        Write-Host "`nCreating GitHub Actions workflow file..." -ForegroundColor Yellow
        
        # Create GitHub Actions directory if it doesn't exist
        $workflowsDir = "$PSScriptRoot\.github\workflows"
        if (-not (Test-Path $workflowsDir)) {
            New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
            Write-Host "Created .github/workflows directory" -ForegroundColor Green
        }
        
        # Create workflow file
        $workflowFile = "$workflowsDir\railway-deploy.yml"
        $workflowContent = @"
name: Deploy to Railway

on:
  push:
    branches: [main]
    paths:
      - 'backend/**'  # Only trigger on backend changes

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    container: ghcr.io/railwayapp/cli:latest
    env:
      RAILWAY_TOKEN: `${{ secrets.RAILWAY_TOKEN }}
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to development
        if: github.ref == 'refs/heads/develop'
        run: |
          cd backend
          railway up --environment development
      - name: Deploy to production
        if: github.ref == 'refs/heads/main'
        run: |
          cd backend
          railway up --environment production
"@
        
        Set-Content -Path $workflowFile -Value $workflowContent
        Write-Host "✓ Created GitHub Actions workflow file at: $workflowFile" -ForegroundColor Green
        
        Write-Host "`nIMPORTANT: You need to add a Railway token to your GitHub repository secrets:" -ForegroundColor Magenta
        Write-Host "1. Go to Railway dashboard > Project settings > Tokens" -ForegroundColor White
        Write-Host "2. Create a new token" -ForegroundColor White
        Write-Host "3. Go to GitHub repository > Settings > Secrets > Actions" -ForegroundColor White
        Write-Host "4. Add a new secret named RAILWAY_TOKEN with the value of your token" -ForegroundColor White
    }
    "7" {
        Write-Host "`nExiting deployment script." -ForegroundColor Cyan
        exit 0
    }
    default {
        Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nDeployment script completed." -ForegroundColor Cyan
Write-Host "Run this script again to perform other deployment tasks." -ForegroundColor Cyan