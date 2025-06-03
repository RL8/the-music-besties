# Simple Railway Deployment Script for The Music Besties
# This script follows Railway best practices with development/production environments

Write-Host "=== The Music Besties Railway Deployment ===" -ForegroundColor Cyan
Write-Host "This script helps deploy your application following Railway best practices" -ForegroundColor Cyan

# Check if logged in
Write-Host "`nChecking Railway login status..." -ForegroundColor Yellow
$whoami = railway whoami
Write-Host "Logged in as: $whoami" -ForegroundColor Green

# Deployment options
Write-Host "`nDeployment Options:" -ForegroundColor Cyan
Write-Host "1. Set up development environment variables" -ForegroundColor White
Write-Host "2. Deploy to development environment" -ForegroundColor White
Write-Host "3. Deploy to production environment" -ForegroundColor White
Write-Host "4. Link to a service" -ForegroundColor White
Write-Host "5. Check deployment status" -ForegroundColor White
Write-Host "6. View deployment logs" -ForegroundColor White
Write-Host "7. Exit" -ForegroundColor White

$choice = Read-Host "`nEnter your choice (1-7)"

if ($choice -eq "1") {
    Write-Host "`nSetting up development environment variables..." -ForegroundColor Yellow
    
    # This requires user interaction
    Write-Host "! INTERACTIVE STEP: You need to select the development environment" -ForegroundColor Magenta
    Write-Host "Run: railway environment development" -ForegroundColor Yellow
    
    $proceed = Read-Host "Have you selected the development environment? (y/n)"
    if ($proceed -ne "y") {
        Write-Host "Exiting. Please run the script again after selecting the development environment." -ForegroundColor Red
        exit 1
    }
    
    # Set development-specific variables
    Write-Host "Setting development environment variables..." -ForegroundColor Yellow
    
    # Get frontend URL
    $frontendUrl = Read-Host "Enter your development frontend URL (e.g., https://the-music-besties-dev.vercel.app)"
    if ($frontendUrl) {
        railway variables set FRONTEND_URL="$frontendUrl"
        Write-Host "FRONTEND_URL set to $frontendUrl" -ForegroundColor Green
    }
    
    Write-Host "Development environment variables configured" -ForegroundColor Green
}
elseif ($choice -eq "2") {
    Write-Host "`nDeploying to development environment..." -ForegroundColor Yellow
    
    # This requires user interaction
    Write-Host "! INTERACTIVE STEP: You need to select the development environment" -ForegroundColor Magenta
    Write-Host "Run: railway environment development" -ForegroundColor Yellow
    
    $proceed = Read-Host "Have you selected the development environment? (y/n)"
    if ($proceed -ne "y") {
        Write-Host "Exiting. Please run the script again after selecting the development environment." -ForegroundColor Red
        exit 1
    }
    
    # Navigate to backend directory
    Set-Location -Path "$PSScriptRoot\backend"
    
    # Deploy
    Write-Host "Deploying backend to development environment..." -ForegroundColor Yellow
    Write-Host "Running: railway up" -ForegroundColor Yellow
    
    # This is where the actual deployment happens
    railway up
    
    # Return to original directory
    Set-Location -Path $PSScriptRoot
    
    Write-Host "Deployment to development environment completed" -ForegroundColor Green
}
elseif ($choice -eq "3") {
    Write-Host "`nDeploying to production environment..." -ForegroundColor Yellow
    
    # This requires user interaction
    Write-Host "! INTERACTIVE STEP: You need to select the production environment" -ForegroundColor Magenta
    Write-Host "Run: railway environment production" -ForegroundColor Yellow
    
    $proceed = Read-Host "Have you selected the production environment? (y/n)"
    if ($proceed -ne "y") {
        Write-Host "Exiting. Please run the script again after selecting the production environment." -ForegroundColor Red
        exit 1
    }
    
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
    
    Write-Host "Deployment to production environment completed" -ForegroundColor Green
}
elseif ($choice -eq "4") {
    Write-Host "`nLinking to a service..." -ForegroundColor Yellow
    
    # This requires user interaction
    Write-Host "! INTERACTIVE STEP: You will be prompted to select a service" -ForegroundColor Magenta
    Write-Host "Running: railway service" -ForegroundColor Yellow
    
    # Link to service
    railway service
    
    Write-Host "Service linking completed" -ForegroundColor Green
}
elseif ($choice -eq "5") {
    Write-Host "`nChecking deployment status..." -ForegroundColor Yellow
    
    # Get current status
    Write-Host "Current Railway status:" -ForegroundColor Yellow
    railway status
}
elseif ($choice -eq "6") {
    Write-Host "`nViewing deployment logs..." -ForegroundColor Yellow
    
    # Get logs
    Write-Host "Fetching logs (press Ctrl+C to exit):" -ForegroundColor Yellow
    railway logs
}
elseif ($choice -eq "7") {
    Write-Host "`nExiting deployment script." -ForegroundColor Cyan
    exit 0
}
else {
    Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "`nDeployment script completed." -ForegroundColor Cyan
Write-Host "Run this script again to perform other deployment tasks." -ForegroundColor Cyan
