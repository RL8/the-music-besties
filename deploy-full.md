# Full Deployment Guide for The Music Besties

This guide will walk you through deploying the complete Music Besties application with connected frontend and backend components.

## Prerequisites

Before starting the deployment process, ensure you have:

1. A Supabase account and project set up
2. A Vercel account for frontend deployment
3. A Railway account for backend deployment (or alternative like Heroku)
4. An OpenAI API key for the chat functionality
5. Git repository set up (GitHub recommended for easy integration)

## Step 1: Prepare Your Database

### Set Up Supabase Tables

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Execute the schema from `database/schema-phase1.sql`
4. Verify all tables are created correctly

### Configure Row-Level Security (RLS)

Set up RLS policies for your tables to ensure data security:

1. Go to Authentication → Policies in Supabase
2. For each table, create appropriate policies as outlined in the DEPLOYMENT.md document

## Step 2: Deploy the Backend

### Using Railway

1. Create a new project in Railway
2. Connect your GitHub repository
3. Configure the deployment to use the backend directory:
   - Root Directory: `/backend`
   - Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

4. Set up the following environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_KEY`: Your Supabase service role key
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `FRONTEND_URL`: This will be your Vercel deployment URL (you can update this later)
   - `PORT`: 8000 (or as required by Railway)

5. Deploy the backend and note the deployed URL (e.g., `https://music-besties-backend.up.railway.app`)

## Step 3: Deploy the Frontend

### Using Vercel

1. Create a new project in Vercel
2. Connect your GitHub repository
3. Configure the build settings:
   - Framework Preset: Nuxt.js
   - Build Command: `npm run build`
   - Output Directory: `.output/public`

4. Set up environment variables in Vercel:
   - `NUXT_PUBLIC_SUPABASE_URL`: Your Supabase project URL
   - `NUXT_PUBLIC_SUPABASE_KEY`: Your Supabase anon/public key (not the service role key)
   - `NUXT_PUBLIC_API_BASE_URL`: The URL of your deployed backend from Step 2
   - `OPENAI_API_KEY`: Your OpenAI API key

5. Deploy the frontend and note the deployed URL (e.g., `https://music-besties.vercel.app`)

## Step 4: Update Cross-Origin Settings

Now that both services are deployed, you need to update the CORS settings on the backend to allow requests from your frontend domain:

1. Go back to Railway
2. Update the `FRONTEND_URL` environment variable with your actual Vercel URL
3. Verify in your `main.py` file that the CORS middleware includes your frontend domain
4. Redeploy the backend if necessary

## Step 5: Test the Deployed Application

1. Open your Vercel deployment URL in a browser
2. Test the complete user flow:
   - Register a new account
   - Log in with the created account
   - Select an artist and curate music
   - Verify that the sideboard displays your curation

3. Check that all API calls are working correctly by monitoring the Network tab in browser developer tools

## Step 6: Set Up Custom Domain (Optional)

### For Vercel Frontend

1. Go to your Vercel project settings
2. Navigate to the Domains section
3. Add your custom domain (e.g., `musicbesties.app`)
4. Follow Vercel's instructions to configure DNS settings

### For Railway Backend

1. Go to your Railway project settings
2. Navigate to the Domains section
3. Add your custom domain (e.g., `api.musicbesties.app`)
4. Follow Railway's instructions to configure DNS settings

5. Update your frontend environment variable:
   - `NUXT_PUBLIC_API_BASE_URL`: Your new backend domain (e.g., `https://api.musicbesties.app`)

## Step 7: Set Up Monitoring (Optional)

1. Implement logging with a service like Sentry:
   - Create a Sentry account
   - Add Sentry SDK to both frontend and backend
   - Configure error tracking

2. Set up uptime monitoring with UptimeRobot:
   - Create an UptimeRobot account
   - Add monitors for both frontend and backend URLs
   - Configure alert notifications

## Troubleshooting Common Issues

### CORS Errors

If you see CORS errors in the browser console:
1. Verify the `FRONTEND_URL` in your backend environment variables
2. Check that the CORS middleware in `main.py` includes your frontend domain
3. Ensure you're using HTTPS consistently (or HTTP for local development)

### Authentication Issues

If users can't log in or register:
1. Check Supabase configuration and keys
2. Verify the authentication endpoints are working correctly
3. Check for any errors in the browser console or backend logs

### API Connection Problems

If the frontend can't connect to the backend:
1. Verify the `NUXT_PUBLIC_API_BASE_URL` is correct
2. Check that the backend is running and accessible
3. Test the backend endpoints directly using a tool like Postman

## Maintenance and Updates

### Updating the Application

1. Make changes to your codebase locally and test
2. Push changes to your GitHub repository
3. Vercel and Railway will automatically deploy the updates

### Database Migrations

For database schema changes:
1. Create migration scripts
2. Test migrations locally
3. Apply migrations to production database through Supabase SQL Editor
4. Update your application code to work with the new schema

## Security Best Practices

1. Regularly rotate API keys and credentials
2. Monitor application logs for suspicious activity
3. Keep dependencies updated to patch security vulnerabilities
4. Implement rate limiting for API endpoints

## Backup and Recovery

1. Regularly export your Supabase database for backup
2. Document your deployment configuration
3. Set up a staging environment for testing changes before production

---

By following this guide, you should have a fully deployed and connected Music Besties application with both frontend and backend components working together seamlessly. If you encounter any issues during the deployment process, refer to the troubleshooting section or consult the documentation for the specific services you're using.
