# PowerShell script to prepare The Music Besties for deployment
# This script checks your project configuration and prepares it for deployment

Write-Host "=== The Music Besties Deployment Preparation ===" -ForegroundColor Cyan

# Check for required files
Write-Host "`nChecking for required files..." -ForegroundColor Yellow
$requiredFiles = @(
    "nuxt.config.js",
    "vercel.json",
    "backend/requirements.txt",
    "backend/main.py",
    "backend/railway.json",
    "Procfile"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Missing required files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
} else {
    Write-Host "All required files are present." -ForegroundColor Green
}

# Check for environment files
Write-Host "`nChecking environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env.master") {
    Write-Host "Found .env.master file." -ForegroundColor Green
    
    # Check for required environment variables
    $envContent = Get-Content ".env.master" -Raw
    $requiredVars = @(
        "SUPABASE_URL",
        "SUPABASE_KEY",
        "OPENAI_API_KEY"
    )
    
    $missingVars = @()
    foreach ($var in $requiredVars) {
        if ($envContent -notmatch "$var=.+") {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Host "Missing or incomplete environment variables in .env.master:" -ForegroundColor Red
        foreach ($var in $missingVars) {
            Write-Host "  - $var" -ForegroundColor Red
        }
    } else {
        Write-Host "All required environment variables are set in .env.master." -ForegroundColor Green
    }
} else {
    Write-Host "Missing .env.master file. Please create one based on env-master-template.txt" -ForegroundColor Red
}

# Check backend configuration
Write-Host "`nChecking backend configuration..." -ForegroundColor Yellow
if (Test-Path "backend/main.py") {
    $mainContent = Get-Content "backend/main.py" -Raw
    
    # Check CORS configuration
    if ($mainContent -match "allow_origins=\[") {
        Write-Host "CORS configuration found in main.py." -ForegroundColor Green
        
        # Check if it includes placeholders for frontend URLs
        if ($mainContent -match "frontend_url" -or $mainContent -match "vercel.app") {
            Write-Host "CORS configuration includes dynamic frontend URL." -ForegroundColor Green
        } else {
            Write-Host "Warning: CORS configuration might not include your production frontend URL." -ForegroundColor Yellow
            Write-Host "  Make sure to update the allowed origins in main.py before deployment." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: CORS configuration not found in main.py." -ForegroundColor Red
    }
} else {
    Write-Host "Cannot check backend configuration: main.py not found." -ForegroundColor Red
}

# Check frontend API configuration
Write-Host "`nChecking frontend API configuration..." -ForegroundColor Yellow
if (Test-Path "nuxt.config.js") {
    $nuxtContent = Get-Content "nuxt.config.js" -Raw
    
    if ($nuxtContent -match "runtimeConfig" -and $nuxtContent -match "apiBaseUrl") {
        Write-Host "API base URL configuration found in nuxt.config.js." -ForegroundColor Green
    } else {
        Write-Host "Warning: API base URL configuration not found in nuxt.config.js." -ForegroundColor Yellow
        Write-Host "  Make sure your frontend can connect to the backend API." -ForegroundColor Yellow
    }
} else {
    Write-Host "Cannot check frontend configuration: nuxt.config.js not found." -ForegroundColor Red
}

# Check package.json for required dependencies
Write-Host "`nChecking package dependencies..." -ForegroundColor Yellow
if (Test-Path "package.json") {
    $packageContent = Get-Content "package.json" -Raw | ConvertFrom-Json
    
    $requiredDeps = @(
        "@supabase/supabase-js",
        "nuxt",
        "nuxt-icon"
    )
    
    $missingDeps = @()
    foreach ($dep in $requiredDeps) {
        if (-not $packageContent.dependencies.$dep) {
            $missingDeps += $dep
        }
    }
    
    if ($missingDeps.Count -gt 0) {
        Write-Host "Missing required npm dependencies:" -ForegroundColor Red
        foreach ($dep in $missingDeps) {
            Write-Host "  - $dep" -ForegroundColor Red
        }
    } else {
        Write-Host "All required npm dependencies are present." -ForegroundColor Green
    }
} else {
    Write-Host "Cannot check dependencies: package.json not found." -ForegroundColor Red
}

# Prepare for deployment
Write-Host "`nPreparing for deployment..." -ForegroundColor Yellow

# Run sync-env if available
if ((Test-Path "sync-env.js") -and (Test-Path ".env.master")) {
    Write-Host "Running environment sync..." -ForegroundColor Yellow
    try {
        npm run sync-env
        Write-Host "Environment variables synced successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error syncing environment variables: $_" -ForegroundColor Red
    }
}

# Create deployment-ready .env files
Write-Host "`nCreating deployment templates..." -ForegroundColor Yellow

# For Vercel
$vercelEnvContent = @"
# Vercel Environment Variables
# Copy these to your Vercel project settings

# Supabase Configuration
NUXT_PUBLIC_SUPABASE_URL=your_supabase_url_here
NUXT_PUBLIC_SUPABASE_KEY=your_supabase_anon_key_here

# API Configuration
NUXT_PUBLIC_API_BASE_URL=your_backend_url_here

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here
"@

# For Railway
$railwayEnvContent = @"
# Railway Environment Variables
# Copy these to your Railway project settings

# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_service_key_here

# Frontend Configuration
FRONTEND_URL=your_frontend_url_here

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Server Configuration
PORT=8000
"@

# Write the files
Set-Content -Path "vercel.env.template" -Value $vercelEnvContent
Set-Content -Path "railway.env.template" -Value $railwayEnvContent

Write-Host "Created deployment environment templates:" -ForegroundColor Green
Write-Host "  - vercel.env.template (for frontend)" -ForegroundColor Green
Write-Host "  - railway.env.template (for backend)" -ForegroundColor Green

# Final instructions
Write-Host "`n=== Deployment Preparation Complete ===" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review the deploy-full.md document for detailed deployment instructions" -ForegroundColor White
Write-Host "2. Set up your Supabase database using the schema in database/schema-phase1.sql" -ForegroundColor White
Write-Host "3. Deploy your backend to Railway or another hosting provider" -ForegroundColor White
Write-Host "4. Deploy your frontend to Vercel" -ForegroundColor White
Write-Host "5. Update the CORS settings in your backend to allow requests from your frontend domain" -ForegroundColor White
Write-Host "6. Test the full application to ensure all components are connected" -ForegroundColor White

Write-Host "`nGood luck with your deployment!" -ForegroundColor Cyan
