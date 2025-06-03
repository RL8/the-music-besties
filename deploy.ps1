# PowerShell script for deploying The Music Besties application
# This script helps deploy both frontend and backend components

# Configuration
$timestamp = Get-Date -Format "ddMMMyymm"
$timestamp = $timestamp.ToUpper()
$repoName = "the-music-besties"

Write-Host "=== The Music Besties Deployment Script ===" -ForegroundColor Cyan
Write-Host "This script will help you deploy your application to Vercel and Railway." -ForegroundColor Cyan

# Check for required tools
Write-Host "`nChecking for required tools..." -ForegroundColor Yellow

$vercelInstalled = $null
try {
    $vercelInstalled = Invoke-Expression "vercel --version" -ErrorAction SilentlyContinue
} catch {}

if ($vercelInstalled) {
    Write-Host "Vercel CLI is installed." -ForegroundColor Green
} else {
    Write-Host "Vercel CLI is not installed. You'll need to install it for deployment." -ForegroundColor Red
    Write-Host "Run: npm i -g vercel" -ForegroundColor Yellow
    $installVercel = Read-Host "Would you like to install Vercel CLI now? (y/n)"
    if ($installVercel -eq "y") {
        Write-Host "Installing Vercel CLI..." -ForegroundColor Yellow
        npm i -g vercel
    }
}

# Create a deployment package
Write-Host "`nPreparing deployment package..." -ForegroundColor Yellow

# First, create a Repomix export for AI analysis
Write-Host "Creating Repomix export for AI analysis..." -ForegroundColor Yellow
try {
    npx repomix -o "C:\Users\Bravo\Downloads\${repoName}_${timestamp}.txt"
    Write-Host "Repomix export created successfully at: C:\Users\Bravo\Downloads\${repoName}_${timestamp}.txt" -ForegroundColor Green
} catch {
    Write-Host "Error creating Repomix export: $_" -ForegroundColor Red
}

# Deployment options
Write-Host "`nDeployment Options:" -ForegroundColor Cyan
Write-Host "1. Deploy frontend to Vercel" -ForegroundColor White
Write-Host "2. Deploy backend to Railway (manual steps)" -ForegroundColor White
Write-Host "3. View deployment documentation" -ForegroundColor White
Write-Host "4. Exit" -ForegroundColor White

$choice = Read-Host "`nEnter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "`nDeploying frontend to Vercel..." -ForegroundColor Yellow
        Write-Host "This will launch the Vercel deployment process." -ForegroundColor Yellow
        Write-Host "You'll need to authenticate and follow the prompts." -ForegroundColor Yellow
        
        $proceed = Read-Host "Proceed with Vercel deployment? (y/n)"
        if ($proceed -eq "y") {
            Set-Location -Path $PSScriptRoot
            vercel
        }
    }
    "2" {
        Write-Host "`nDeploying backend to Railway (manual steps)..." -ForegroundColor Yellow
        Write-Host "Railway deployment requires the following steps:" -ForegroundColor Yellow
        Write-Host "1. Create a new project in Railway (https://railway.app)" -ForegroundColor White
        Write-Host "2. Connect your GitHub repository" -ForegroundColor White
        Write-Host "3. Set the root directory to '/backend'" -ForegroundColor White
        Write-Host "4. Configure the environment variables from railway.env.template" -ForegroundColor White
        
        $openDocs = Read-Host "Would you like to open the Railway documentation? (y/n)"
        if ($openDocs -eq "y") {
            Start-Process "https://docs.railway.app/deploy/deployments"
        }
    }
    "3" {
        Write-Host "`nOpening deployment documentation..." -ForegroundColor Yellow
        try {
            Invoke-Item "$PSScriptRoot\deploy-full.md"
        } catch {
            Write-Host "Error opening documentation: $_" -ForegroundColor Red
            Write-Host "Please open the file manually: $PSScriptRoot\deploy-full.md" -ForegroundColor Yellow
        }
    }
    "4" {
        Write-Host "`nExiting deployment script." -ForegroundColor Cyan
    }
    default {
        Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
    }
}

Write-Host "`nRemember to update your environment variables and CORS settings after deployment." -ForegroundColor Yellow
Write-Host "See deploy-full.md for detailed instructions." -ForegroundColor Yellow
Write-Host "`nGood luck with your deployment!" -ForegroundColor Cyan
