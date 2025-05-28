# Credential Management for The Music Besties

This document outlines the credential management system for The Music Besties project.

## Overview

The project uses a centralized credential management approach with a master `.env.master` file as the single source of truth. This file contains all environment variables needed for both frontend and backend components.

## Files Structure

- `.env.master`: Master environment file (source of truth)
- `.env`: Frontend environment file (generated)
- `backend/.env`: Backend environment file (generated)
- `env-master-template.txt`: Template for creating `.env.master`
- `sync-env.js`: Script to sync variables from master to component-specific files
- `vercel-env-sync.js`: Script to sync variables from master to Vercel deployment

## Required Environment Variables

### Supabase Credentials
- `SUPABASE_URL`: URL of your Supabase project
- `SUPABASE_KEY`: Public API key for Supabase

### OpenAI API
- `OPENAI_API_KEY`: API key for OpenAI services

### URLs
- `BACKEND_URL`: URL of the backend API (local or production)
- `FRONTEND_URL`: URL of the frontend application (local or production)

## Setup Instructions

1. Create a `.env.master` file based on the template:
   ```
   cp env-master-template.txt .env.master
   ```

2. Fill in your credentials in the `.env.master` file

3. Run the sync script to generate component-specific `.env` files:
   ```
   node sync-env.js
   ```

## Deployment Configuration

### Railway (Backend)

The backend environment variables are automatically configured during deployment.

### Vercel (Frontend)

To sync your environment variables to Vercel:

1. Ensure you're logged in to Vercel CLI:
   ```
   vercel login
   ```

2. Link your project (if not already linked):
   ```
   vercel link
   ```

3. Run the Vercel environment sync script:
   ```
   node vercel-env-sync.js
   ```

This will automatically extract the necessary variables from your `.env.master` file and set them in your Vercel project's production environment.

## Security Considerations

- Never commit `.env*` files to version control
- All environment files are included in `.gitignore`
- Use environment-specific variables in production
