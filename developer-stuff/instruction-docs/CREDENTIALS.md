# Credential Management Guide

This project uses a centralized approach to manage credentials across frontend and backend services.

## How It Works

1. A single master file (`.env.master`) contains all credentials
2. The `sync-env.js` script distributes these credentials to the appropriate locations
3. This ensures you only need to update credentials in one place

## Setup Instructions

### 1. Create the Master Environment File

Create a file named `.env.master` in the project root based on the template:

```bash
# Copy the template
cp env-master-template.txt .env.master

# Edit the file with your actual credentials
# (Use your preferred text editor)
```

### 2. Fill in Your Credentials

Edit the `.env.master` file with your actual credentials:

```
# Supabase
SUPABASE_URL=https://your-actual-project.supabase.co
SUPABASE_KEY=your-actual-key

# OpenAI
OPENAI_API_KEY=your-actual-openai-key

# URLs
BACKEND_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000
```

### 3. Sync Your Credentials

Run the sync script to distribute credentials to frontend and backend:

```bash
npm run sync-env
```

This will:
- Create/update `.env` in the project root (for frontend)
- Create/update `.env` in the `backend/` directory (for backend)

### 4. Start Development

The sync script runs automatically when you start the frontend:

```bash
# Start frontend (runs sync-env first)
npm run dev

# Start backend (in a separate terminal)
npm run dev:backend
```

## Deployment

When deploying to Railway and Vercel, you can push all variables at once:

```bash
# For Railway (backend)
railway variables set --from-file .env.master

# For Vercel (frontend)
vercel env import .env.master
```

## Security Notes

- **NEVER commit the `.env.master` file to Git** (it's already in .gitignore)
- Keep a backup of your credentials in a secure location
- Consider using a password manager for team credential sharing
