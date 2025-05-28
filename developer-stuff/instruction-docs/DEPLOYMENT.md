# Deployment Guide: The Music Besties

This document outlines deployment procedures, common issues, and their solutions for The Music Besties application.

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Environment Setup](#environment-setup)
- [Deployment Platforms](#deployment-platforms)
  - [Railway (Backend)](#railway-backend)
  - [Vercel (Frontend)](#vercel-frontend)
- [Common Issues & Solutions](#common-issues--solutions)
- [Deployment Checklist](#deployment-checklist)

## Architecture Overview

The Music Besties uses a split architecture:
- **Frontend**: Nuxt.js application deployed on Vercel
- **Backend**: FastAPI application deployed on Railway
- **Database**: Supabase for authentication and data storage

## Environment Setup

We use a centralized credential management approach:
1. Master environment file (`.env.master`) contains all variables
2. `sync-env.js` distributes variables to component-specific files
3. `vercel-env-sync.js` syncs variables to Vercel deployment

See [CREDENTIALS.md](../CREDENTIALS.md) for detailed setup instructions.

## Deployment Platforms

### Railway (Backend)

#### Configuration Requirements

**Critical: PORT Configuration**
Railway expects applications to use the `PORT` environment variable they provide. Our application handles this through a startup script in the Dockerfile:

```dockerfile
# Create a startup script to handle PORT environment variable properly
RUN echo '#!/bin/bash\n\
PORT=${PORT:-8000}\n\
echo "Starting server on port: $PORT"\n\
exec uvicorn main:app --host 0.0.0.0 --port $PORT' > /app/start.sh \
    && chmod +x /app/start.sh

# Use the startup script
CMD ["/app/start.sh"]
```

**Required Environment Variables**
- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_KEY`: Supabase public API key
- `FRONTEND_URL`: URL of the frontend application (for CORS)
- `OPENAI_API_KEY`: OpenAI API key (for AI functionality)

#### Deployment Steps

1. Ensure you're logged in to Railway CLI:
   ```
   railway login
   ```

2. Link your project (if not already linked):
   ```
   railway link
   ```

3. Set required environment variables:
   ```
   railway variables --set SUPABASE_URL="your_value" --set SUPABASE_KEY="your_value" --set FRONTEND_URL="your_value" --set OPENAI_API_KEY="your_value"
   ```

4. Deploy the application:
   ```
   railway up
   ```

5. Verify deployment:
   ```
   Invoke-RestMethod -Uri "https://your-railway-domain.up.railway.app/" -Method GET
   ```

### Vercel (Frontend)

#### Configuration Requirements

**Required Environment Variables**
- `VUE_APP_FASTAPI_URL`: URL of the backend API
- `VUE_APP_SUPABASE_URL`: Supabase project URL
- `VUE_APP_SUPABASE_KEY`: Supabase public API key

#### Deployment Steps

1. Ensure you're logged in to Vercel CLI:
   ```
   vercel login
   ```

2. Link your project (if not already linked):
   ```
   vercel link
   ```

3. Sync environment variables from master file:
   ```
   node vercel-env-sync.js
   ```

4. Deploy the application:
   ```
   vercel --prod
   ```

## Common Issues & Solutions

### 502 "Application Failed to Respond" on Railway

**Symptoms**:
- Application builds successfully
- Logs show the server starting correctly
- All requests return 502 errors

**Causes**:
1. **PORT configuration mismatch** - Railway expects applications to use their `PORT` environment variable
2. Health check timeouts
3. Memory/resource constraints
4. Network configuration issues

**Solution**:
1. Use a startup script in Dockerfile to properly handle the PORT environment variable
2. Add detailed logging to diagnose startup issues
3. Implement a fast-responding health check endpoint

### "Failed to Fetch" Errors in Frontend

**Symptoms**:
- Browser console shows "Failed to fetch" errors
- API calls from frontend to backend fail

**Causes**:
1. CORS configuration issues
2. Backend URL misconfiguration
3. Backend service unavailability

**Solution**:
1. Ensure backend CORS settings include the frontend domain
2. Verify environment variables are correctly set in Vercel
3. Check that backend service is operational

## Deployment Checklist

**Before Deployment**:
- [ ] All environment variables are set in `.env.master`
- [ ] Run `node sync-env.js` to update component-specific files
- [ ] Test application locally with production configuration
- [ ] Verify Dockerfile has correct PORT handling

**After Deployment**:
- [ ] Verify backend health check endpoint responds
- [ ] Test API endpoints directly
- [ ] Verify frontend can communicate with backend
- [ ] Test complete user flow from frontend to backend

## Troubleshooting Steps

If you encounter deployment issues:

1. **Check logs** for detailed error information
2. **Verify environment variables** are correctly set
3. **Test endpoints directly** to isolate frontend vs. backend issues
4. **Review CORS settings** if frontend-backend communication fails
5. **Validate PORT configuration** in Dockerfile for Railway deployments

---

Last updated: May 28, 2025
